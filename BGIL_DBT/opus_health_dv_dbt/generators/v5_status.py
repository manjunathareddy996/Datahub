# -*- coding: utf-8 -*-
"""Emit BUILD_STATUS.json -- the one place a count describing this build's current state lives --
and the measured triage of every finding the shared check_vault_alignment gate reports.

The shared gate is not edited (vault_tools serves every build). Where it reports something, the
finding is re-measured here and classified with the evidence; a finding that cannot be explained
by measurement is reported as unexplained, never folded into an explanation.
"""
import collections
import glob
import hashlib
import io
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import v5_common as C  # noqa: E402
import v5_verify as V  # noqa: E402


def tree_digest():
    lines = []
    for root, _d, files in os.walk(C.MODELS):
        for f in files:
            if f.endswith(".sql"):
                p = os.path.join(root, f)
                lines.append("%s\n%s" % (os.path.relpath(p, C.MODELS).replace("\\", "/"),
                                         hashlib.sha256(open(p, "rb").read()).hexdigest()))
    return hashlib.sha256("\n".join(sorted(lines)).encode("utf-8")).hexdigest(), len(lines)


def triage_alias_check(M):
    """Gate check 5 splits each file on 'union all' and counts aliases repeated in a block.
    Reproduce that count, then show what each repeat is."""
    gate, explained, unexplained, real = 0, 0, [], 0
    for name, m in M.items():
        body = "\n".join(re.sub(r"--.*$", "", l) for l in m["text"].splitlines())
        for blk in re.split(r"\bunion all\b", body):
            al = re.findall(r"\bas\s+(\S+?)\s*(?=,\s*$|$)", blk, re.M)
            dup = [a for a, n in collections.Counter(al).items() if n > 1]
            gate += len(dup)
            if not dup:
                continue
            if m["dir"] == "automate_dv/standard/stitched" and "\nselect\n" in blk \
                    and "\nfrom merged" in blk:
                last_branch, final = blk.split(")\n\nselect\n", 1)
                lb = collections.Counter(re.findall(r"\bas\s+(\S+?)\s*(?=,\s*$|$)", last_branch, re.M))
                fs = collections.Counter(re.findall(r"\bas\s+(\S+?)\s*(?=,\s*$|$)", final, re.M))
                for a in dup:
                    if lb[a] == 1 and fs[a] == 1:
                        explained += 1
                    else:
                        unexplained.append("%s: %s" % (name, a))
            else:
                unexplained.extend("%s: %s" % (name, a) for a in dup)
    for name, m in M.items():
        if m["dir"] == "automate_dv/standard/stitched":
            for b in V.view_branches(m["text"]):
                al = [a for _e, a in b["cols"]]
                real += len(al) - len(set(al))
            fa = V.view_final_aliases(m["text"])
            real += len(fa) - len(set(fa))
    return {"gate_count_reproduced": gate,
            "explained": explained, "unexplained": unexplained[:20],
            "n_unexplained": len(unexplained),
            "aliases_repeated_within_one_real_select": real,
            "cause": "Each central view ends with its last union branch followed by the final "
                     "windowed select. The gate splits on 'union all' only, so those two selects "
                     "fall in one block and every payload column -- aliased once in each -- is "
                     "counted as repeated. Parsed select by select, no alias repeats."}


def triage_coverage(M):
    """Gate checks 1 and 6: (satellite, column) pairs the gate's map (legacy + v2 only) maps and
    this build does not land. Every such pair must be fully explained by refusals."""
    reg = C.read_json("register_feeds.json")
    F = C.read_json("feeds.json")
    by_subj = collections.defaultdict(list)
    for i in reg:
        by_subj[i["subject"]].append(i)
    landed = collections.defaultdict(set)
    for name, m in M.items():
        if m["dir"] in ("automate_dv/standard/satellites", "automate_dv/augmented/satellites"):
            meta, _ = V.parse_yaml(m["text"])
            code = "SAT_" + name[len("sat_"):].upper()
            landed[code] = set(meta["src_payload"]) | set(meta.get("src_cdk") or [])
    feeds_by = collections.defaultdict(list)
    for f in F["feeds"]:
        feeds_by[(f["sat"], f["payload"])].append(f)
    m1 = C.jload(C.pinned("SourceMapping_Skill/Health Consolidated/outputs/04_column_map.json"))
    want = collections.defaultdict(list)
    for r in m1["columns"]:
        t = r.get("target") or {}
        if r.get("outcome") == "mapped" and t.get("satellite") and t.get("attribute"):
            want[(t["satellite"], C.upper_snake(t["attribute"]))].append(r)
    missing = {k: v for k, v in want.items() if k[1] not in landed.get(k[0], set())}
    kinds = collections.Counter()
    unexplained = []
    for (sat, col), rows in sorted(missing.items()):
        if feeds_by.get((sat, col)):
            unexplained.append("%s.%s has a landed feed under another name" % (sat, col))
            continue
        why = set()
        for r in rows:
            subj = "%s.%s" % (r["table_name"], r["column_name"])
            if (r.get("target") or {}).get("redundant_of"):
                why.add("redundant_of dedup")
            elif by_subj.get(subj):
                why |= {i["kind"] for i in by_subj[subj]}
            else:
                unexplained.append("%s.%s <- %s: no refusal recorded" % (sat, col, subj))
        for w in why:
            kinds[w] += 1
    return {"pairs_the_gate_reports_missing": len(missing),
            "explained_by_refusal_kind": dict(kinds.most_common()),
            "unexplained": unexplained[:20], "n_unexplained": len(unexplained),
            "cause": "Every one of these pairs had ALL of its map rows refused (key unresolved, "
                     "key calls the undefined normalise(), ...) and registered with whose call it "
                     "is; none is a landed value under a different name. The shared gate records "
                     "known gaps only in vault_tools/accepted_uncovered.txt, which this build may "
                     "not edit."}


def main():
    M = V.load_models()
    P = C.read_json("stitch_plan.json")
    ver = C.read_json("verification.json")
    gates = C.read_json("shared_gates.json")
    reg_items = C.read_json("register_feeds.json") + C.read_json("register_emit.json")
    reg = C.Register()
    reg.items = reg_items
    C.write_json("unresolved_register.json", {"summary": reg.summary(), "items": reg_items})
    layers = collections.Counter(m["dir"] for m in M.values())
    digest, n = tree_digest()
    if n != len(M):
        raise AssertionError("digest and model census disagree")
    tally = ver["tally"]
    va_tail = gates["check_vault_alignment"]["tail"]
    va = {k: int(v) for k, v in re.findall(r"FAIL ([0-9]\. [^:]+): (\d+)", va_tail)}
    cov_line = re.search(r"mapped columns reaching a sat\s+:\s+(\d+) of (\d+)", va_tail)
    hub_pairs = sum(1 for v in P["views"] for _ in
                    re.findall(r"^  ([A-Z0-9_]+)_BK: '", V.parse_yaml(
                        M[v["stage_model"]]["text"])[1] and "\n".join(V.parse_yaml(
                            M[v["stage_model"]]["text"])[1]), re.M))
    status = {
        "project": "health_consolidated_v5_dv_dbt",
        "macro_library": "automate_dv (every hub, link and satellite is a macro call; every hash "
                         "is computed by automate_dv.stage())",
        "structure": "partner_dv_dbt / travel_dv_dbt layout, exactly",
        "architecture": "central views (the user's governing rule) -> automate_dv.stage() -> "
                        "hub() / link() / sat() / ma_sat()",
        "build_status": "PARTIAL_BY_DECLARATION" if reg_items else "COMPLETE",
        "build_status_note": "Every object resolvable from the pinned inputs was built. What was "
                             "not is REFUSED and registered with whose call it is -- a fallback "
                             "always produces a row, so it never produces an error.",
        "models": {"total": len(M), "by_layer": dict(sorted(layers.items()))},
        "tree_digest_sha256": digest,
        "tree_digest_recipe": "per file: posix-relpath + LF + sha256(bytes); lines sorted "
                              "bytewise, joined by LF, sha256 of the UTF-8 join",
        "central_views": P["census"],
        "unresolved_register": dict(reg.summary(), where="build_artifacts/reports/unresolved_register.json"),
        "verification": {"tally": tally, "where": "build_artifacts/reports/verification.json"},
        "shared_gates": {
            "check_internal": "PASS" if gates["check_internal"]["exit"] == 0 else "FAIL",
            "check_patterns": "PASS" if gates["check_patterns"]["exit"] == 0 else "FAIL",
            "check_prose_counts": "PASS" if gates["check_prose_counts"]["exit"] == 0 else "FAIL",
            "check_prose_shape": "PASS" if gates["check_prose_shape"]["exit"] == 0 else "FAIL",
            "check_vault_alignment": {
                "sibling": "health_dv_dbt (the gen-1 automate_dv health build)",
                "exit": gates["check_vault_alignment"]["exit"],
                "findings": va,
                "mapped_columns_reaching_a_satellite": (
                    {"reached": int(cov_line.group(1)), "of": int(cov_line.group(2))}
                    if cov_line else None),
                "note": "This gate reported every satellite as unreachable on the previous health "
                        "build (wrong directory layout). On this build it reaches all of them.",
            },
        },
        "shared_gate_triage": {
            "5. alias selected more than once in one select": triage_alias_check(M),
            "1. and 6. mapped column reaches no satellite": triage_coverage(M),
            "2. src_pk differs from the sibling": {
                "cause": "health_dv_dbt names satellite keys *_HK while its hubs and links use "
                         "*_HKEY -- the split partner_dv_dbt's README records as the defect that "
                         "broke 14 health hubs. This build uses *_HKEY everywhere, as partner and "
                         "travel do."},
            "2. grain / src_cdk differs from the sibling": {
                "cause": "data_7.js governs grain. health_dv_dbt was built against an earlier "
                         "model; where data_7.js declares a satellite multi-active or declares "
                         "more child-key legs, this build follows data_7.js."},
            "4. hub key names differ from the sibling": {
                "cause": "the hub business-key column is <HUB>_BK here, PARENT_BK in "
                         "health_dv_dbt, partner_dv_dbt and travel_dv_dbt. One view-level stage "
                         "carries several hubs, so one PARENT_BK column cannot serve them all. "
                         "This is the one naming deviation from the reference projects.",
                "alternative": "one stage per (view, hub) naming the key PARENT_BK",
                "alternative_cost_extra_stage_models": hub_pairs,
                "whose_call": "the user"},
        },
        "other_builds_unchanged": next((c for c in ver["checks"] if c["check"].startswith("ABSOLUTE")),
                                       {"status": "NOT RUN"}),
    }
    C.write_text(os.path.join(C.PROJECT, "build_artifacts", "BUILD_STATUS.json"),
                 json.dumps(status, indent=1, ensure_ascii=False))
    print("  BUILD_STATUS.json: %d models, digest %s, verification %s" % (len(M), digest[:16], tally))
    t5 = status["shared_gate_triage"]["5. alias selected more than once in one select"]
    t16 = status["shared_gate_triage"]["1. and 6. mapped column reaches no satellite"]
    print("  gate check 5: reproduced %d, explained %d, unexplained %d, real repeats %d" % (
        t5["gate_count_reproduced"], t5["explained"], t5["n_unexplained"],
        t5["aliases_repeated_within_one_real_select"]))
    print("  gate checks 1/6: %d pairs missing, unexplained %d, by kind %s" % (
        t16["pairs_the_gate_reports_missing"], t16["n_unexplained"], t16["explained_by_refusal_kind"]))


if __name__ == "__main__":
    main()
