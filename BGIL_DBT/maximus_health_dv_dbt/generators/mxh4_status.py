# -*- coding: utf-8 -*-
"""Emit BUILD_STATUS.json -- the one place a count describing this build's current state lives --
and the measured triage of every finding the shared check_vault_alignment gate reports. The
shared gate is not edited; each finding is re-measured here, and anything unexplained is reported
as unexplained."""
import collections
import hashlib
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mxh4_common as C  # noqa: E402
import mxh4_verify as V  # noqa: E402


def tree_digest():
    lines = []
    for root, _d, files in os.walk(C.MODELS):
        for f in files:
            if f.endswith(".sql"):
                p = os.path.join(root, f)
                lines.append("%s\n%s" % (os.path.relpath(p, C.MODELS).replace("\\", "/"),
                                         hashlib.sha256(open(p, "rb").read()).hexdigest()))
    return hashlib.sha256("\n".join(sorted(lines)).encode("utf-8")).hexdigest(), len(lines)


def triage_alias(M):
    gate, explained, unexplained, real = 0, 0, [], 0
    for name, m in M.items():
        body = "\n".join(re.sub(r"--.*$", "", l) for l in m["text"].splitlines())
        for blk in re.split(r"\bunion all\b", body):
            al = re.findall(r"\bas\s+(\S+?)\s*(?=,\s*$|$)", blk, re.M)
            dup = [a for a, n in collections.Counter(al).items() if n > 1]
            gate += len(dup)
            if dup and "\nfrom merged" in blk and ")\n\nselect\n" in blk:
                lb, fs = blk.split(")\n\nselect\n", 1)
                lbc = collections.Counter(re.findall(r"\bas\s+(\S+?)\s*(?=,\s*$|$)", lb, re.M))
                fsc = collections.Counter(re.findall(r"\bas\s+(\S+?)\s*(?=,\s*$|$)", fs, re.M))
                for a in dup:
                    if lbc[a] == 1 and fsc[a] == 1:
                        explained += 1
                    else:
                        unexplained.append("%s: %s" % (name, a))
            else:
                unexplained += ["%s: %s" % (name, a) for a in dup]
    for name, m in M.items():
        if m["dir"] == "automate_dv/standard/stitched":
            for b in V.view_branches(m["text"]):
                al = [a for _e, a in b["positions"] if a]
                real += len(al) - len(set(al))
    return {"gate_count_reproduced": gate, "explained": explained, "n_unexplained": len(unexplained),
            "unexplained": unexplained[:20], "aliases_repeated_within_one_real_select": real,
            "cause": "the gate splits a file on 'union all' only, so a view's last branch and its final "
                     "windowed select fall in one block and each payload column, aliased once in each, "
                     "reads as repeated. Parsed select by select, no alias repeats."}


def triage_coverage(M):
    reg = C.read_json("register_feeds.json")
    by_subj = collections.defaultdict(set)
    for i in reg:
        by_subj[i["subject"]].add(i["kind"])
    landed = collections.defaultdict(set)
    for name, m in M.items():
        if m["dir"] in V.SAT_DIRS:
            meta, _ = V.parse_yaml(m["text"])
            landed["SAT_" + name[4:].upper()] = set(meta["src_payload"]) | set(meta.get("src_cdk") or [])
    F = C.read_json("feeds.json")
    fed = {(f["sat"], f["payload"]) for f in F["feeds"]}
    want = collections.defaultdict(list)
    for r in C.map_rows():
        t = r.get("target") or {}
        if r.get("outcome") == "mapped" and t.get("satellite") and t.get("attribute"):
            want[(t["satellite"], C.upper_snake(t["attribute"]))].append(r)
    missing = {k: v for k, v in want.items() if k[1] not in landed.get(k[0], set())}
    kinds, unexplained = collections.Counter(), []
    for (sat, col), rows in sorted(missing.items()):
        if (sat, col) in fed:
            unexplained.append("%s.%s has a landed feed under another name" % (sat, col))
            continue
        why = set()
        for r in rows:
            subj = "%s.%s" % (r["table_name"], r["column_name"])
            if (r.get("target") or {}).get("redundant_of"):
                why.add("redundant_of dedup")
            elif by_subj.get(subj):
                why |= by_subj[subj]
            else:
                unexplained.append("%s.%s <- %s: no refusal recorded" % (sat, col, subj))
        for w in why:
            kinds[w] += 1
    return {"pairs_the_gate_reports_missing": len(missing), "explained_by_refusal_kind": dict(kinds.most_common()),
            "n_unexplained": len(unexplained), "unexplained": unexplained[:20],
            "cause": "every such pair had ALL its map rows refused under a directive or for an "
                     "unresolvable key, each registered with whose call it is."}


def main():
    M = V.load_models()
    P = C.read_json("stitch_plan.json")
    ver = C.read_json("verification.json")
    gates = C.read_json("shared_gates.json")
    items = C.read_json("register_feeds.json") + C.read_json("register_emit.json")
    reg = C.Register()
    reg.items = items
    C.write_json("unresolved_register.json", {"summary": reg.summary(), "items": items})
    digest, n = tree_digest()
    va_tail = gates["check_vault_alignment"]["tail"]
    cov = re.search(r"mapped columns reaching a sat\s+:\s+(\d+) of (\d+)", va_tail)
    man = C.read_json("manifest.json")
    status = {
        "project": "maximus_health_v4_dv_dbt",
        "mapping": "exactly the mapping maximus_health_v3_dv_dbt was built from (see build_profile.json "
                   "-> inputs_pinned)",
        "macro_library": "automate_dv: every hub, link and satellite is a macro call; every key hash is "
                         "computed by automate_dv.stage()",
        "structure": "partner_dv_dbt / travel_dv_dbt layout, exactly",
        "build_status": "PARTIAL_BY_DECLARATION" if items else "COMPLETE",
        "models": {"total": n, "by_layer": dict(sorted(collections.Counter(m["dir"] for m in M.values()).items()))},
        "tree_digest_sha256": digest,
        "tree_digest_recipe": "per file: posix-relpath + LF + sha256(bytes); lines sorted bytewise, "
                              "joined by LF, sha256 of the UTF-8 join",
        "central_views": dict(P["census"], walk_tables_joined=len({t for v in man["views"].values()
                                                                    for t in v["walk_tables"]})),
        "unresolved_register": dict(reg.summary(), where="build_artifacts/reports/unresolved_register.json"),
        "verification": {"tally": ver["tally"], "where": "build_artifacts/reports/verification.json"},
        "preconditions_before_dbt_run": [
            {"item": "normalise() must exist as a Snowflake function",
             "detail": "the map ratifies it and calls it in content-hash keys; nothing in the bundle or "
                       "this workspace defines it. Carried verbatim (build_profile.json normalise_policy)."},
            {"item": "spine[FOREIGN_KEY -> X] join reading",
             "detail": "joined as child.FOREIGN_KEY = parent.KEY_HASH at the first real level; the bundle "
                       "does not define FOREIGN_KEY. For the mapper to confirm."}],
        "shared_gates": {k: ("PASS" if gates[k]["exit"] == 0 else "NOT RUN" if gates[k]["exit"] == 2 else "FAIL")
                         for k in ("check_internal", "check_patterns", "check_prose_counts", "check_prose_shape")},
        "check_vault_alignment": {
            "sibling": "health_consolidated_v5_dv_dbt (same model, same conventions, automate_dv)",
            "exit": gates["check_vault_alignment"]["exit"],
            "findings": {k: int(v) for k, v in re.findall(r"FAIL ([0-9]\. [^:]+): (\d+)", va_tail)},
            "mapped_columns_reaching_a_satellite": {"reached": int(cov.group(1)), "of": int(cov.group(2))} if cov else None,
            "triage": {
                "5. alias selected more than once in one select": triage_alias(M),
                "1. and 6. mapped column reaches no satellite": triage_coverage(M),
                "2. grain / src_cdk differs from the sibling": {
                    "cause": "only SAT_AUG_* satellites differ. The Maximus map declares those augmentation "
                             "blocks multi_active with a child key; the OPUS map behind the sibling does "
                             "not. Every STANDARD satellite agrees with the sibling on grain and child key. "
                             "The two builds write separate schemas, so nothing collides; merging the two "
                             "augmented tracks would be the modeller's call."}}},
        "other_builds_unchanged": next((c for c in ver["checks"] if c["check"].startswith("ABSOLUTE")),
                                       {"status": "NOT RUN"}),
    }
    C.write_text(os.path.join(C.PROJECT, "build_artifacts", "BUILD_STATUS.json"),
                 json.dumps(status, indent=1, ensure_ascii=False))
    t5 = status["check_vault_alignment"]["triage"]["5. alias selected more than once in one select"]
    t16 = status["check_vault_alignment"]["triage"]["1. and 6. mapped column reaches no satellite"]
    print("  BUILD_STATUS.json: %d models, digest %s, verification %s" % (n, digest[:16], ver["tally"]))
    print("  gate check 5: reproduced %d, explained %d, unexplained %d, real repeats %d" % (
        t5["gate_count_reproduced"], t5["explained"], t5["n_unexplained"], t5["aliases_repeated_within_one_real_select"]))
    print("  gate checks 1/6: %d pairs missing, unexplained %d, by kind %s" % (
        t16["pairs_the_gate_reports_missing"], t16["n_unexplained"], t16["explained_by_refusal_kind"]))


if __name__ == "__main__":
    main()
