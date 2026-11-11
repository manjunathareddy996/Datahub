# -*- coding: utf-8 -*-
"""Static verification of the emitted models. Writes build_artifacts/reports/verification.json.

Every check reads the EMITTED SQL, not the generator's manifest: the manifest is what the
generator believes it wrote, and a check that reads the writer's own account of itself verifies
nothing. Four outcomes, never two -- PASS, FAIL, NOT RUN, DID NOT COMPLETE -- each with the
population it ran over. A PASS over an empty population is reported as NOT RUN.
"""
import collections
import glob
import io
import os
import re
import subprocess
import sys
import traceback

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import v5_common as C  # noqa: E402
import v5_guard as G  # noqa: E402
import v5_keys as K  # noqa: E402

ALLOWED_DIRS = {"staging/health", "automate_dv/standard/stitched", "automate_dv/standard/staging",
                "automate_dv/standard/hubs", "automate_dv/standard/links",
                "automate_dv/standard/satellites", "automate_dv/standard/references",
                "automate_dv/augmented/staging", "automate_dv/augmented/satellites"}
VAULT_MACRO = {"automate_dv/standard/hubs": ("hub",), "automate_dv/standard/links": ("link",),
               "automate_dv/standard/satellites": ("sat", "ma_sat"),
               "automate_dv/augmented/satellites": ("sat", "ma_sat")}
STAGE_DIRS = {"automate_dv/standard/staging", "automate_dv/augmented/staging"}
RE_REF = re.compile(r"\{\{\s*ref\('([^']+)'\)\s*\}\}")
RE_SRC = re.compile(r"\{\{\s*source\('([^']+)',\s*'([^']+)'\)\s*\}\}")
RE_YAML = re.compile(r"\{%- set yaml_metadata -%\}\n(.*?)\n\{%- endset -%\}", re.S)
YAML_LINE = re.compile(r"^(?:[a-z_]+:(?: '(?:[^']|'')*')?|  - '(?:[^']|'')*'|  [A-Z0-9_]+: (?:'(?:[^']|'')*'|\"[^\"\\]*\")"
                       r"|  [A-Z0-9_]+:|    is_hashdiff: true|    columns:|      - '(?:[^']|'')*')$")

RESULTS = []


def record(name, status, population, detail=None):
    if status == "PASS" and not population:
        status = "NOT RUN"
    RESULTS.append({"check": name, "status": status, "population": population,
                    "detail": detail or {}})
    print("  %-14s %-62s n=%s" % (status, name[:62], population))


def run(name, fn):
    try:
        fn(name)
    except Exception as e:
        record(name, "DID NOT COMPLETE", 0, {"error": "%s: %s" % (type(e).__name__, e),
                                             "trace": traceback.format_exc()[-1500:]})


def load_models():
    out = {}
    for p in glob.glob(os.path.join(C.MODELS, "**", "*.sql"), recursive=True):
        rel = os.path.relpath(os.path.dirname(p), C.MODELS).replace("\\", "/")
        name = os.path.basename(p)[:-4]
        out[name] = {"dir": rel, "text": io.open(p, encoding="utf-8").read(), "path": p,
                     "bytes": os.path.getsize(p)}
    return out


def parse_yaml(text):
    """The yaml_metadata block of a generated model, read back from the SQL."""
    m = RE_YAML.search(text)
    if not m:
        return None, None
    lines = m.group(1).split("\n")
    meta, cur, sub = {}, None, None
    for l in lines:
        if not l.startswith(" "):
            k, _, v = l.partition(":")
            v = v.strip()
            cur = k
            meta[k] = v.strip("'") if v else []
            sub = None
        elif l.startswith("  - "):
            meta[cur].append(l[4:].strip().strip("'"))
        elif l.startswith("      - "):
            meta[cur][sub]["columns"].append(l[8:].strip().strip("'"))
        elif l.startswith("    "):
            pass
        elif l.startswith("  "):
            k, _, v = l[2:].partition(":")
            v = v.strip()
            if not isinstance(meta[cur], dict):
                meta[cur] = {}
            if v:
                meta[cur][k] = v[1:-1] if v[0] in "'\"" else v
            else:
                meta[cur][k] = {"columns": []}
            sub = k
    return meta, lines


def view_final_aliases(text):
    tail = text[text.rindex("\nselect\n") + 8:]
    tail = tail[:tail.rindex("\nfrom merged")]
    out = []
    for line in tail.split(",\n"):
        line = line.strip()
        m = re.search(r"\bas\s+([A-Za-z_][A-Za-z0-9_]*)$", line)
        out.append(m.group(1) if m else line)
    return out


def view_branches(text):
    body = text[text.index("with merged as (") + len("with merged as ("):text.rindex("\n)\n\nselect\n")]
    out = []
    for blk in body.split("\n\n    union all\n\n"):
        sel = blk[blk.index("    select\n") + len("    select\n"):blk.index("\n    from {{ ref(")]
        ref = RE_REF.search(blk).group(1)
        cols = []
        for line in sel.split(",\n"):
            line = line.strip()
            m = re.match(r"^(.*)\s+as\s+([A-Za-z_][A-Za-z0-9_]*)$", line, re.S)
            cols.append((m.group(1), m.group(2)) if m else (line, None))
        where = blk[blk.index("\n    where ") + len("\n    where "):]
        out.append({"ref": ref, "cols": cols, "where": where})
    return out


def staging_aliases(text):
    return re.findall(r"\)\), ''\) as ([a-z_][a-z0-9_$]*)", text)


def main():
    M = load_models()
    P = C.read_json("stitch_plan.json")
    F = C.read_json("feeds.json")
    prof = C.profile()

    def c_layout(n):
        bad = sorted({m["dir"] for m in M.values()} - ALLOWED_DIRS)
        missing = sorted(d for d in ALLOWED_DIRS if not os.path.isdir(os.path.join(C.MODELS, d)))
        record(n, "FAIL" if bad or missing else "PASS", len(M),
               {"unexpected_dirs": bad, "missing_dirs": missing})

    def c_macros(n):
        bad = []
        pop = 0
        for name, m in M.items():
            code = re.sub(r"--[^\n]*", "", m["text"])      # comments are not calls
            if m["dir"] in VAULT_MACRO:
                pop += 1
                calls = re.findall(r"automate_dv\.([a-z_]+)\(", code)
                if len(calls) != 1 or calls[0] not in VAULT_MACRO[m["dir"]]:
                    bad.append(name)
            elif m["dir"] in STAGE_DIRS:
                pop += 1
                if re.findall(r"automate_dv\.([a-z_]+)\(", code) != ["stage"]:
                    bad.append(name)
            elif "automate_dv." in code:
                bad.append(name)
        record(n, "FAIL" if bad else "PASS", pop, {"offenders": bad[:20]})

    def c_no_hand_hash(n):
        bad = []
        for name, m in M.items():
            t = m["text"].lower()
            if re.search(r"\b(md5|md5_binary|md5_hex|sha1|sha2|sha2_binary)\s*\(", t):
                bad.append(name)
            for h in re.finditer(r"\bhash\s*\(", t):
                if not t[h.start():].startswith("hash(*) as __rid"):
                    bad.append(name)
        record(n, "FAIL" if bad else "PASS", len(M), {"offenders": sorted(set(bad))[:20],
               "note": "hash(*) as __RID is the deterministic tie-break inside a central view's "
                       "merge, not a key; every key hash is computed by automate_dv.stage()."})

    def c_packages(n):
        t = io.open(os.path.join(C.PROJECT, "packages.yml"), encoding="utf-8").read()
        ok = all(p["package"] in t and all(v in t for v in p["version"])
                 for p in prof["macro_library"]["packages"])
        record(n, "PASS" if ok else "FAIL", len(prof["macro_library"]["packages"]))

    def c_refs(n):
        dangling, srcs_bad, used = [], [], set()
        yml = io.open(os.path.join(C.DIRS["staging"], "_health__sources.yml"), encoding="utf-8").read()
        declared = set(re.findall(r"- name: ([A-Z0-9_$]+)", yml))
        for name, m in M.items():
            for r in RE_REF.findall(m["text"]):
                used.add(r)
                if r not in M:
                    dangling.append("%s -> %s" % (name, r))
            meta, _ = parse_yaml(m["text"])
            if meta:
                sm = meta.get("source_model")
                for r in (sm if isinstance(sm, list) else [sm] if sm else []):
                    used.add(r)
                    if r not in M:
                        dangling.append("%s -> %s" % (name, r))
            for s, t in RE_SRC.findall(m["text"]):
                if s != "health_raw" or t not in declared:
                    srcs_bad.append("%s -> %s.%s" % (name, s, t))
        orphans = sorted(x for x, m in M.items() if x not in used and m["dir"] not in VAULT_MACRO)
        record(n, "FAIL" if dangling or srcs_bad or orphans else "PASS", len(M),
               {"dangling": dangling[:20], "bad_sources": srcs_bad[:20], "orphans": orphans[:20]})

    def c_yaml(n):
        bad, pop = [], 0
        for name, m in M.items():
            meta, lines = parse_yaml(m["text"])
            if lines is None:
                continue
            pop += 1
            for l in lines:
                if not YAML_LINE.match(l) or any(t in l for t in ("{{", "{%", "{#")):
                    bad.append("%s: %s" % (name, l[:80]))
        record(n, "FAIL" if bad else "PASS", pop, {"offenders": bad[:20]})

    stage_cols = {}

    def produced(stage):
        if stage not in stage_cols:
            meta, _ = parse_yaml(M[stage]["text"])
            stage_cols[stage] = set(meta["hashed_columns"]) | set(meta["derived_columns"])
        return stage_cols[stage]

    def c_vault_contract(n):
        bad, pop = [], 0
        for name, m in M.items():
            if m["dir"] not in VAULT_MACRO:
                continue
            meta, _ = parse_yaml(m["text"])
            need = []
            for k in ("src_pk", "src_nk", "src_hashdiff", "src_ldts", "src_source"):
                if meta.get(k):
                    need.append(meta[k])
            for k in ("src_fk", "src_cdk", "src_payload"):
                need += meta.get(k) or []
            sm = meta["source_model"]
            for s in (sm if isinstance(sm, list) else [sm]):
                pop += 1
                miss = [c for c in need if c not in produced(s)]
                if miss:
                    bad.append("%s <- %s missing %s" % (name, s, miss))
            if meta.get("src_cdk") and set(meta["src_cdk"]) & set(meta.get("src_payload") or []):
                bad.append("%s: a child-key leg is also a payload column" % name)
        record(n, "FAIL" if bad else "PASS", pop, {"offenders": bad[:20]})

    def c_stage_to_view(n):
        bad, pop = [], 0
        for name, m in M.items():
            if m["dir"] not in STAGE_DIRS:
                continue
            meta, _ = parse_yaml(m["text"])
            src = meta["source_model"]
            cols = set(view_final_aliases(M[src]["text"]))
            hashed = meta["hashed_columns"]
            derived = meta["derived_columns"]
            for k, v in derived.items():
                pop += 1
                if v.startswith("!"):
                    continue
                ids = set(K.identifiers(v)) - {"case", "when", "then", "end", "is", "not", "null"}
                miss = sorted(i for i in ids if i not in cols)
                if miss:
                    bad.append("%s.%s references %s, not on %s" % (name, k, miss, src))
            for k, v in hashed.items():
                srcs = v["columns"] if isinstance(v, dict) else [v]
                for c in srcs:
                    if c not in derived:
                        bad.append("%s.%s hashes %s, which the stage does not derive" % (name, k, c))
        record(n, "FAIL" if bad else "PASS", pop, {"offenders": bad[:20]})

    def c_view_to_staging(n):
        bad, pop = [], 0
        for name, m in M.items():
            if m["dir"] != "automate_dv/standard/stitched":
                continue
            final = view_final_aliases(m["text"])
            if len(set(final)) != len(final):
                bad.append("%s: final select repeats an alias" % name)
            brs = view_branches(m["text"])
            shape0 = [a for _e, a in brs[0]["cols"]]
            for i, b in enumerate(brs):
                pop += 1
                shape = [a for _e, a in b["cols"]]
                if shape != shape0:
                    bad.append("%s branch %d: column list differs from branch 0" % (name, i))
                if len(set(shape)) != len(shape):
                    bad.append("%s branch %d: alias repeated" % (name, i))
                st = set(staging_aliases(M[b["ref"]]["text"]))
                for e, a in b["cols"] + [(b["where"], "where")]:
                    if e.startswith("cast(null") or e.startswith("hash(*)") or re.match(r"^\d+$", e):
                        continue
                    miss = sorted(i for i in K.identifiers(e) if i.lower() not in st)
                    if miss:
                        bad.append("%s branch %d %s: %s not on %s" % (name, i, a, miss, b["ref"]))
            if set(shape0[:-2]) != set(final):
                bad.append("%s: final select and branch columns disagree" % name)
        record(n, "FAIL" if bad else "PASS", pop, {"offenders": bad[:20]})

    def c_rule(n):
        bad = []
        limit = prof["central_view_rule"]["table_limit"]
        tables_of = collections.defaultdict(set)
        for f in F["feeds"]:
            tables_of[f["sat"]].add(f["table"])
        home = collections.Counter()
        sat_view = {}
        for name, m in M.items():
            if m["dir"] in ("automate_dv/standard/satellites", "automate_dv/augmented/satellites"):
                meta, _ = parse_yaml(m["text"])
                stage = meta["source_model"]
                if isinstance(stage, list):
                    bad.append("%s reads more than one stage" % name)
                    continue
                sat_view[name] = parse_yaml(M[stage]["text"])[0]["source_model"]
        for v in P["views"]:
            refs = set(RE_REF.findall(M[v["stitch_model"]]["text"]))
            tabs = {r[len("stg_health__"):].upper() for r in refs}
            if tabs != set(v["tables"]):
                bad.append("%s joins tables the plan does not list" % v["name"])
            if len(tabs) > limit:
                need = max([len(tables_of[s]) for s in v["satellites"]] or [0])
                if len(tabs) != need:
                    bad.append("%s exceeds %d tables beyond what one satellite needs" % (
                        v["name"], limit))
            for s in v["satellites"]:
                home[s] += 1
                mname = "sat_" + C.short(s).lower()
                if sat_view.get(mname) != v["stitch_model"]:
                    bad.append("%s is not fed from its planned view" % s)
                if not tables_of[s] <= tabs:
                    bad.append("%s split: a feeding table is not on its view" % s)
        bad += ["%s placed %d times" % (s, k) for s, k in home.items() if k != 1]
        for name, m in M.items():
            if m["dir"] in ("automate_dv/standard/hubs", "automate_dv/standard/links"):
                meta, _ = parse_yaml(m["text"])
                for s in meta["source_model"]:
                    src = parse_yaml(M[s]["text"])[0]["source_model"]
                    if not src.startswith("stitch_"):
                        bad.append("%s reads %s, which is not off a central view" % (name, s))
        record(n, "FAIL" if bad else "PASS", len(home), {"offenders": bad[:20]})

    def c_notation(n):
        bad = []
        for name, m in M.items():
            body = re.sub(r"--[^\n]*", "", m["text"])
            body = re.sub(r"\{\{.*?\}\}|\{%-?.*?-?%\}", "", body, flags=re.S)
            for pat in ("LNK(", "spine[", " >> ", "normalise(", "{", "}"):
                if pat in body:
                    bad.append("%s: %r" % (name, pat))
        record(n, "FAIL" if bad else "PASS", len(M), {"offenders": bad[:20]})

    def c_size(n):
        big = sorted(("%s: %d bytes" % (k, m["bytes"])) for k, m in M.items() if m["bytes"] >= 1000000)
        record(n, "FAIL" if big else "PASS", len(M),
               {"largest": max(m["bytes"] for m in M.values()), "offenders": big,
                "why": "Snowflake rejects a statement over 1 MB"})

    def c_coverage(n):
        reg = C.read_json("register_feeds.json")
        refused = {(i["subject"], i.get("satellite")) for i in reg}
        refused_subj = {i["subject"] for i in reg}
        landed = {}
        for name, m in M.items():
            if m["dir"] in ("automate_dv/standard/satellites", "automate_dv/augmented/satellites"):
                meta, _ = parse_yaml(m["text"])
                landed[name] = set(meta["src_payload"])
        feed_ok = {("%s.%s" % (f["table"], f["column"].upper()), f["sat"]) for f in F["feeds"]
                   if f["payload"] in landed.get("sat_" + C.short(f["sat"]).lower(), set())}
        feed_ok_lower = {(s.upper(), sat) for s, sat in feed_ok}
        pop, unacc, by = 0, [], collections.Counter()
        for r in C.map_rows():
            t = r.get("target") if isinstance(r.get("target"), dict) else {}
            if not (r["outcome"] == "mapped" and t.get("kind") == "satellite_attribute"
                    and t.get("satellite")):
                continue
            pop += 1
            subj = "%s.%s" % (r["table_name"], r["column_name"])
            if (subj.upper(), t["satellite"]) in feed_ok_lower:
                by["landed in its satellite"] += 1
            elif t.get("redundant_of"):
                by["dropped: redundant_of another mapped column"] += 1
            elif (subj, t["satellite"]) in refused or subj in refused_subj:
                by["refused and registered"] += 1
            else:
                unacc.append("%s -> %s" % (subj, t["satellite"]))
        record(n, "FAIL" if unacc else "PASS", pop, {"accounted": dict(by),
                                                      "unaccounted": unacc[:20],
                                                      "n_unaccounted": len(unacc)})

    def c_guard(n):
        s, d = G.check()
        record(n, s, d.get("files_compared", 0), d)

    def c_gates(n):
        vt = os.path.join(C.WORKSPACE, "vault_tools")
        out = {}
        cmds = {
            "check_internal": [sys.executable, os.path.join(vt, "check_internal.py"), C.PROJECT],
            "check_patterns": [sys.executable, os.path.join(vt, "check_patterns.py"), C.PROJECT],
            "check_prose_counts": [sys.executable, os.path.join(vt, "check_prose_counts.py"), C.PROJECT],
            "check_prose_shape": [sys.executable, os.path.join(vt, "check_prose_shape.py"), C.PROJECT],
            "check_vault_alignment": [sys.executable, os.path.join(vt, "check_vault_alignment.py"),
                                      C.PROJECT, os.path.join(C.WORKSPACE, "health_dv_dbt"),
                                      C.pinned("SourceMapping_Skill/Health Consolidated/outputs/"
                                               "04_column_map.json")],
        }
        for k, cmd in cmds.items():
            p = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="replace")
            out[k] = {"exit": p.returncode, "tail": p.stdout[-6000:]}
        C.write_json("shared_gates.json", out)
        for k in ("check_internal", "check_patterns", "check_prose_counts", "check_prose_shape"):
            # exit 2 is the gates' own NOT RUN: nothing was examined
            st = {0: "PASS", 2: "NOT RUN"}.get(out[k]["exit"], "FAIL")
            record("shared gate: " + k, st, 1, {"tail": out[k]["tail"][-600:]})
        va = out["check_vault_alignment"]
        fails = re.findall(r"FAIL ([0-9]\. [^:]+): (\d+)", va["tail"])
        record("shared gate: check_vault_alignment (vs health_dv_dbt)",
               "PASS" if va["exit"] == 0 else "FAIL", 1,
               {"findings": {k: int(v) for k, v in fails},
                "triage": "see BUILD_STATUS.json shared_gate_triage; vault_tools is shared and is "
                          "not edited by this build"})

    checks = [
        ("layout: models only in the partner/travel directory set", c_layout),
        ("every hub/link/sat is an automate_dv macro; every stage is stage()", c_macros),
        ("no hash written by hand: every key is hashed by stage()", c_no_hand_hash),
        ("packages.yml declares automate_dv + dbt_utils at the pinned ranges", c_packages),
        ("refs and sources resolve; no orphan model", c_refs),
        ("yaml_metadata blocks are in the generated grammar, no Jinja inside", c_yaml),
        ("vault contract: every src_* column is produced by every source stage", c_vault_contract),
        ("stage contract: every stage column comes from its central view", c_stage_to_view),
        ("view contract: every branch column comes from its staging model", c_view_to_staging),
        ("central-view rule: whole satellites, <=10 tables or rule 3, hubs/links off views", c_rule),
        ("no mapper notation or undefined function survives into SQL", c_notation),
        ("every model under Snowflake's 1 MB statement limit", c_size),
        ("every mapped satellite row lands, is refused with a reason, or is a declared dedup",
         c_coverage),
        ("ABSOLUTE: no file outside this project changed", c_guard),
        ("shared gates", c_gates),
    ]
    for name, fn in checks:
        run(name, fn)
    tally = collections.Counter(r["status"] for r in RESULTS)
    C.write_json("verification.json", {"tally": dict(tally), "checks": RESULTS})
    print("  tally:", dict(tally))
    return 0 if not tally.get("FAIL") and not tally.get("DID NOT COMPLETE") else 1


if __name__ == "__main__":
    sys.exit(main())
