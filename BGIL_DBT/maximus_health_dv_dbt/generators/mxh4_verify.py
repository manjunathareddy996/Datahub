# -*- coding: utf-8 -*-
"""Static verification of the emitted models. Writes build_artifacts/reports/verification.json.

Every check reads the EMITTED SQL, not the generator's manifest. Four outcomes -- PASS, FAIL,
NOT RUN, DID NOT COMPLETE -- each with its population; a PASS over nothing is NOT RUN.
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
import mxh4_common as C  # noqa: E402
import mxh4_guard as G  # noqa: E402

ALLOWED = {"staging/maximus_health", "automate_dv/standard/stitched", "automate_dv/standard/staging",
           "automate_dv/standard/hubs", "automate_dv/standard/links", "automate_dv/standard/satellites",
           "automate_dv/standard/references", "automate_dv/augmented/staging",
           "automate_dv/augmented/satellites"}
VAULT = {"automate_dv/standard/hubs": ("hub",), "automate_dv/standard/links": ("link",),
         "automate_dv/standard/satellites": ("sat", "ma_sat"),
         "automate_dv/augmented/satellites": ("sat", "ma_sat")}
STAGE_DIRS = {"automate_dv/standard/staging", "automate_dv/augmented/staging"}
SAT_DIRS = ("automate_dv/standard/satellites", "automate_dv/augmented/satellites")
RE_REF = re.compile(r"\{\{\s*ref\('([^']+)'\)\s*\}\}")
RE_SRC = re.compile(r"\{\{\s*source\('([^']+)',\s*'([^']+)'\)\s*\}\}")
RE_YAML = re.compile(r"\{%- set yaml_metadata -%\}\n(.*?)\n\{%- endset -%\}", re.S)
RE_BIND = re.compile(r"\{\{ ref\('([^']+)'\) \}\} ([a-z]\d+)\b")
RE_QCOL = re.compile(r"\b([a-z]\d+)\.([A-Za-z0-9_]+)")
YAML_LINE = re.compile(r"^(?:[a-z_]+:(?: '(?:[^']|'')*')?|  - '(?:[^']|'')*'|  [A-Z0-9_]+: (?:'(?:[^']|'')*'|\"[^\"\\]*\")"
                       r"|  [A-Z0-9_]+:|    is_hashdiff: true|    columns:|      - '(?:[^']|'')*')$")
RESULTS = []


def record(name, status, population, detail=None):
    if status == "PASS" and not population:
        status = "NOT RUN"
    RESULTS.append({"check": name, "status": status, "population": population, "detail": detail or {}})
    print("  %-14s %-64s n=%s" % (status, name[:64], population))


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
        out[os.path.basename(p)[:-4]] = {"dir": rel, "text": io.open(p, encoding="utf-8").read(),
                                         "bytes": os.path.getsize(p)}
    return out


def parse_yaml(text):
    m = RE_YAML.search(text)
    if not m:
        return None, None
    lines = m.group(1).split("\n")
    meta, cur, sub = {}, None, None
    for l in lines:
        if not l.startswith(" "):
            k, _, v = l.partition(":")
            cur, sub = k, None
            meta[k] = v.strip().strip("'") if v.strip() else []
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
            meta[cur][k] = (v[1:-1] if v[0] in "'\"" else v) if v else {"columns": []}
            sub = k
    return meta, lines


def identifiers(e):
    s = re.sub(r"'(?:[^']|'')*'", "''", e)
    s = re.sub(r"\b[a-z]\d+\.(?:[A-Za-z0-9_]+|\*)", "", s)   # alias.col and alias.*
    out = []
    for m in re.finditer(r"[A-Za-z_][A-Za-z0-9_]*", s):
        tok = m.group(0)
        if s[m.end():].lstrip().startswith("(") or tok.lower() in {
                "case", "when", "then", "else", "end", "is", "not", "null", "and", "or", "as", "varchar",
                "number"}:
            continue
        out.append(tok)
    return out


def view_final_aliases(text):
    tail = text[text.rindex("\nselect\n") + 8:text.rindex("\nfrom merged")]
    out = []
    for line in tail.split(",\n"):
        m = re.search(r"\bas\s+([A-Za-z_][A-Za-z0-9_]*)$", line.strip())
        out.append(m.group(1) if m else line.strip())
    return out


def view_branches(text):
    body = text[text.index("with merged as (") + len("with merged as ("):text.rindex("\n)\n\nselect\n")]
    out = []
    for blk in body.split("\n\n    union all\n\n"):
        sel = blk[blk.index("    select\n") + len("    select\n"):blk.index("\n    from {{ ref(")]
        positions = []
        for piece in sel.split(",\n"):
            piece = piece.strip()
            if re.match(r"^null(, null)*$", piece):
                positions += [(None, None)] * (piece.count("null"))
                continue
            m = re.match(r"^(.*)\s+as\s+([A-Za-z_][A-Za-z0-9_]*)$", piece, re.S)
            positions.append((m.group(1), m.group(2)) if m else (piece, None))
        out.append({"text": blk, "positions": positions,
                    "base": re.search(r"\n    from \{\{ ref\('([^']+)'\) \}\} t0", blk).group(1)})
    return out


def staging_aliases(text):
    return set(re.findall(r"\)\), ''\) as ([a-z_][a-z0-9_$]*)", text))


def main():
    M = load_models()
    P = C.read_json("stitch_plan.json")
    F = C.read_json("feeds.json")
    prof = C.profile()

    def c_layout(n):
        bad = sorted({m["dir"] for m in M.values()} - ALLOWED)
        missing = sorted(d for d in ALLOWED if not os.path.isdir(os.path.join(C.MODELS, d)))
        record(n, "FAIL" if bad or missing else "PASS", len(M), {"unexpected": bad, "missing": missing})

    def c_macros(n):
        bad, pop = [], 0
        for name, m in M.items():
            code = re.sub(r"--[^\n]*", "", m["text"])
            calls = re.findall(r"automate_dv\.([a-z_]+)\(", code)
            if m["dir"] in VAULT:
                pop += 1
                if len(calls) != 1 or calls[0] not in VAULT[m["dir"]]:
                    bad.append(name)
            elif m["dir"] in STAGE_DIRS:
                pop += 1
                if calls != ["stage"]:
                    bad.append(name)
            elif calls:
                bad.append(name)
        record(n, "FAIL" if bad else "PASS", pop, {"offenders": bad[:20]})

    def c_hash(n):
        """No hash KEY is written by hand. md5() inside a map-supplied CONTENT-HASH business key
        is the mapper's key expression (tier4) and is carried verbatim, then hashed by stage()."""
        bad, carried = [], 0
        for name, m in M.items():
            t = m["text"].lower()
            for h in re.finditer(r"\bhash\s*\(", t):
                if not t[h.start():].startswith("hash(t0.*) as __rid"):
                    bad.append(name)
            if m["dir"] != "automate_dv/standard/stitched" and re.search(r"\bmd5\s*\(", t):
                bad.append(name)
            carried += len(re.findall(r"\bmd5\s*\(", t)) if m["dir"] == "automate_dv/standard/stitched" else 0
        record(n, "FAIL" if bad else "PASS", len(M), {"offenders": sorted(set(bad))[:20],
               "md5_inside_map_content_hash_business_keys": carried})

    def c_packages(n):
        t = io.open(os.path.join(C.PROJECT, "packages.yml"), encoding="utf-8").read()
        ok = all(p["package"] in t and all(v in t for v in p["version"]) for p in prof["macro_library"]["packages"])
        record(n, "PASS" if ok else "FAIL", 2)

    def c_refs(n):
        dangling, bad_src, used = [], [], set()
        yml = io.open(os.path.join(C.DIRS["staging"], "_maximus_health__sources.yml"), encoding="utf-8").read()
        declared = set(re.findall(r"- name: ([A-Za-z0-9_$]+)", yml))
        for name, m in M.items():
            refs = RE_REF.findall(m["text"])
            meta, _ = parse_yaml(m["text"])
            if meta:
                sm = meta.get("source_model")
                refs += sm if isinstance(sm, list) else [sm]
            for r in refs:
                used.add(r)
                if r not in M:
                    dangling.append("%s -> %s" % (name, r))
            for s, t in RE_SRC.findall(m["text"]):
                if s != "maximus_raw" or t not in declared:
                    bad_src.append("%s -> %s" % (name, t))
        orphans = sorted(x for x, m in M.items() if x not in used and m["dir"] not in VAULT)
        record(n, "FAIL" if dangling or bad_src or orphans else "PASS", len(M),
               {"dangling": dangling[:20], "bad_sources": bad_src[:20], "orphans": orphans[:20]})

    def c_yaml(n):
        bad, pop = [], 0
        for name, m in M.items():
            meta, lines = parse_yaml(m["text"])
            if lines is None:
                continue
            pop += 1
            bad += ["%s: %s" % (name, l[:80]) for l in lines if not YAML_LINE.match(l)
                    or any(t in l for t in ("{{", "{%", "{#"))]
        record(n, "FAIL" if bad else "PASS", pop, {"offenders": bad[:20]})

    cache = {}

    def produced(stage):
        if stage not in cache:
            meta, _ = parse_yaml(M[stage]["text"])
            cache[stage] = set(meta["hashed_columns"]) | set(meta["derived_columns"])
        return cache[stage]

    def c_vault(n):
        bad, pop = [], 0
        for name, m in M.items():
            if m["dir"] not in VAULT:
                continue
            meta, _ = parse_yaml(m["text"])
            need = [meta[k] for k in ("src_pk", "src_nk", "src_hashdiff", "src_ldts", "src_source") if meta.get(k)]
            for k in ("src_fk", "src_cdk", "src_payload"):
                need += meta.get(k) or []
            sm = meta["source_model"]
            for s in (sm if isinstance(sm, list) else [sm]):
                pop += 1
                miss = [c for c in need if c not in produced(s)]
                if miss:
                    bad.append("%s <- %s missing %s" % (name, s, miss))
            if set(meta.get("src_cdk") or []) & set(meta.get("src_payload") or []):
                bad.append("%s: child-key leg also in payload" % name)
        record(n, "FAIL" if bad else "PASS", pop, {"offenders": bad[:20]})

    def c_stage_view(n):
        bad, pop = [], 0
        for name, m in M.items():
            if m["dir"] not in STAGE_DIRS:
                continue
            meta, _ = parse_yaml(m["text"])
            cols = set(view_final_aliases(M[meta["source_model"]]["text"]))
            for k, v in meta["derived_columns"].items():
                pop += 1
                if not v.startswith("!"):
                    miss = sorted(i for i in identifiers(v) if i not in cols)
                    if miss:
                        bad.append("%s.%s -> %s not on view" % (name, k, miss))
            for k, v in meta["hashed_columns"].items():
                for c in (v["columns"] if isinstance(v, dict) else [v]):
                    if c not in meta["derived_columns"]:
                        bad.append("%s.%s hashes underived %s" % (name, k, c))
        record(n, "FAIL" if bad else "PASS", pop, {"offenders": bad[:20]})

    def c_view_staging(n):
        bad, pop = [], 0
        for name, m in M.items():
            if m["dir"] != "automate_dv/standard/stitched":
                continue
            final = view_final_aliases(m["text"])
            if len(set(final)) != len(final):
                bad.append("%s: final select repeats an alias" % name)
            brs = view_branches(m["text"])
            shape0 = [a for _e, a in brs[0]["positions"]]
            if None in shape0:
                bad.append("%s: branch 0 has an unaliased column" % name)
            for i, b in enumerate(brs):
                pop += 1
                if len(b["positions"]) != len(shape0):
                    bad.append("%s branch %d: %d columns, branch 0 has %d" % (name, i, len(b["positions"]), len(shape0)))
                    continue
                for (e, a), a0 in zip(b["positions"], shape0):
                    if a is not None and a != a0:
                        bad.append("%s branch %d: %s sits where branch 0 has %s" % (name, i, a, a0))
                binds = collections.defaultdict(set)
                for r, al in RE_BIND.findall(b["text"]):
                    binds[al].add(r)
                for al, col in RE_QCOL.findall(b["text"]):
                    if col.startswith("_"):
                        continue
                    if not any(col.lower() in staging_aliases(M[r]["text"]) or col in ("KEY_HASH", "PARENT_KEY_HASH", "FOREIGN_KEY")
                               and col.lower() in staging_aliases(M[r]["text"]) for r in binds.get(al, ())):
                        bad.append("%s branch %d: %s.%s not on %s" % (name, i, al, col, sorted(binds.get(al, ()))))
                for e, a in b["positions"]:
                    if e and identifiers(e):
                        bad.append("%s branch %d %s: unqualified %s" % (name, i, a, identifiers(e)[:3]))
            if set(x for x in shape0[:-2]) != set(final):
                bad.append("%s: final select and branch columns disagree" % name)
        record(n, "FAIL" if bad else "PASS", pop, {"offenders": bad[:20], "n": len(bad)})

    def c_rule(n):
        bad = []
        limit = prof["central_view_rule"]["table_limit"]
        tables_of = collections.defaultdict(set)
        for f in F["feeds"]:
            tables_of[f["sat"]].add(f["table"])
        slug = {C.staging_model(t): t for f in F["feeds"] for t in [f["table"]]}
        home, sat_view = collections.Counter(), {}
        for name, m in M.items():
            if m["dir"] in SAT_DIRS:
                st = parse_yaml(m["text"])[0]["source_model"]
                if isinstance(st, list):
                    bad.append("%s reads more than one stage" % name)
                    continue
                sat_view[name] = parse_yaml(M[st]["text"])[0]["source_model"]
        for v in P["views"]:
            feeding = {slug.get(b["base"], b["base"]) for b in view_branches(M[v["stitch_model"]]["text"])}
            if feeding != set(v["tables"]):
                bad.append("%s: feeding tables differ from the plan" % v["name"])
            if len(feeding) > limit and len(feeding) != max([len(tables_of[s]) for s in v["satellites"]] or [0]):
                bad.append("%s exceeds the limit beyond what one satellite needs" % v["name"])
            for s in v["satellites"]:
                home[s] += 1
                if sat_view.get("sat_" + C.short(s).lower()) != v["stitch_model"]:
                    bad.append("%s not fed from its planned view" % s)
                if not tables_of[s] <= feeding:
                    bad.append("%s split" % s)
        bad += ["%s placed %d times" % (s, k) for s, k in home.items() if k != 1]
        for name, m in M.items():
            if m["dir"] in ("automate_dv/standard/hubs", "automate_dv/standard/links"):
                for s in parse_yaml(m["text"])[0]["source_model"]:
                    if not parse_yaml(M[s]["text"])[0]["source_model"].startswith("stitch_"):
                        bad.append("%s reads %s, not a central view" % (name, s))
        record(n, "FAIL" if bad else "PASS", len(home), {"offenders": bad[:20]})

    def c_notation(n):
        bad, norm = [], 0
        for name, m in M.items():
            body = re.sub(r"--[^\n]*", "", m["text"])
            body = re.sub(r"\{\{.*?\}\}|\{%-?.*?-?%\}", "", body, flags=re.S)
            for pat in ("spine[", "spine:", " >> ", "->", "LNK(", "{", "}"):
                if pat in body:
                    bad.append("%s: %r" % (name, pat))
            norm += body.count("normalise(")
        if norm and prof["normalise_policy"] != "emit":
            bad.append("normalise() present while normalise_policy is %r" % prof["normalise_policy"])
        record(n, "FAIL" if bad else "PASS", len(M), {"offenders": bad[:20],
               "normalise_calls_carried_verbatim": norm})

    def c_size(n):
        est = {k: m["bytes"] + 64 * len(RE_REF.findall(m["text"])) for k, m in M.items()}
        big = sorted("%s: ~%d bytes compiled" % (k, b) for k, b in est.items() if b >= 1000000)
        record(n, "FAIL" if big else "PASS", len(M), {"largest_compiled_estimate": max(est.values()),
               "offenders": big, "why": "Snowflake rejects a statement over 1 MB; a ref() compiles to a "
                                        "fully qualified name, estimated at 64 bytes"})

    def c_coverage(n):
        reg = C.read_json("register_feeds.json")
        refused = {i["subject"] for i in reg if not i.get("landed")}
        landed = {}
        for name, m in M.items():
            if m["dir"] in SAT_DIRS:
                landed[name] = set(parse_yaml(m["text"])[0]["src_payload"])
        ok = {("%s.%s" % (f["table"], f["column"]), f["sat"]) for f in F["feeds"]
              if f["payload"] in landed.get("sat_" + C.short(f["sat"]).lower(), set())}
        pop, unacc, by = 0, [], collections.Counter()
        for r in C.map_rows():
            t = r.get("target") if isinstance(r.get("target"), dict) else {}
            if not (r["outcome"] == "mapped" and t.get("kind") == "satellite_attribute" and t.get("satellite")):
                continue
            pop += 1
            subj = "%s.%s" % (r["table_name"], r["column_name"])
            if (subj, t["satellite"]) in ok:
                by["landed in its satellite"] += 1
            elif t.get("redundant_of"):
                by["dropped: redundant_of another mapped column"] += 1
            elif subj in refused:
                by["refused and registered"] += 1
            else:
                unacc.append("%s -> %s" % (subj, t["satellite"]))
        record(n, "FAIL" if unacc else "PASS", pop, {"accounted": dict(by), "unaccounted": unacc[:20],
                                                      "n_unaccounted": len(unacc)})

    def c_guard(n):
        s, d = G.check()
        record(n, s, d.get("files_compared", 0), d)

    def c_gates(n):
        vt = os.path.join(C.WORKSPACE, "vault_tools")
        sib = os.path.join(C.WORKSPACE, "health_consolidated_v5_dv_dbt")
        cmds = {"check_internal": [os.path.join(vt, "check_internal.py"), C.PROJECT],
                "check_patterns": [os.path.join(vt, "check_patterns.py"), C.PROJECT],
                "check_prose_counts": [os.path.join(vt, "check_prose_counts.py"), C.PROJECT],
                "check_prose_shape": [os.path.join(vt, "check_prose_shape.py"), C.PROJECT],
                "check_vault_alignment": [os.path.join(vt, "check_vault_alignment.py"), C.PROJECT, sib,
                                          C.pinned(C.MAP)]}
        out = {}
        for k, args in cmds.items():
            p = subprocess.run([sys.executable] + args, capture_output=True, text=True, encoding="utf-8",
                               errors="replace")
            out[k] = {"exit": p.returncode, "tail": p.stdout[-6000:]}
        C.write_json("shared_gates.json", out)
        for k in ("check_internal", "check_patterns", "check_prose_counts", "check_prose_shape"):
            record("shared gate: " + k, {0: "PASS", 2: "NOT RUN"}.get(out[k]["exit"], "FAIL"), 1,
                   {"tail": out[k]["tail"][-600:]})
        va = out["check_vault_alignment"]
        record("shared gate: check_vault_alignment (vs health_consolidated_v5_dv_dbt)",
               "PASS" if va["exit"] == 0 else "FAIL", 1,
               {"findings": {k: int(v) for k, v in re.findall(r"FAIL ([0-9]\. [^:]+): (\d+)", va["tail"])}})

    checks = [
        ("layout: models only in the partner/travel directory set", c_layout),
        ("every hub/link/sat is an automate_dv macro; every stage is stage()", c_macros),
        ("no hash KEY written by hand: every key is hashed by stage()", c_hash),
        ("packages.yml declares automate_dv + dbt_utils at the pinned ranges", c_packages),
        ("refs and sources resolve; no orphan model", c_refs),
        ("yaml_metadata blocks are in the generated grammar, no Jinja inside", c_yaml),
        ("vault contract: every src_* column is produced by every source stage", c_vault),
        ("stage contract: every stage column comes from its central view", c_stage_view),
        ("view contract: every qualified column is on the model its alias binds", c_view_staging),
        ("central-view rule: whole satellites, <=10 feeding tables or rule 3", c_rule),
        ("no spine notation, LNK() or display form survives into SQL", c_notation),
        ("every model under Snowflake's 1 MB statement limit once compiled", c_size),
        ("every mapped satellite row lands, is refused with a reason, or is a declared dedup", c_coverage),
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
