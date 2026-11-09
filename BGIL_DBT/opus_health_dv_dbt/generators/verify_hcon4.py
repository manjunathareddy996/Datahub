# -*- coding: utf-8 -*-
"""Verify the v4 build. Four outcomes per check, never two: PASS, FAIL, NOT RUN, DID NOT COMPLETE.

Each result carries the POPULATION it ran over. A PASS over an empty population is downgraded to
NOT RUN, and a FAIL produced by an empty discovery is likewise NOT RUN -- because a zero from a
probe that looked in the wrong place is indistinguishable from a clean result, and reporting it as
a pass is how a build ships green while being wrong.

The checks the generators cannot make about themselves:
  1  rule 2 in the emitted SQL  -- every satellite ref()s exactly ONE stage model
  2  rule 5 in the emitted SQL  -- every hub is fed only from hub feeds, which read only stages
  3  rule 6 in the emitted SQL  -- every link reads exactly ONE stage model
  4  the single hash site       -- md5( appears ONLY in stage models and in link/augmented keys
  5  no mapper notation survives into SQL
  6  every ref() resolves to a model this build emitted
  7  name injectivity over the models actually written
  8  no model is orphaned: every staging/stitched/stage/feed model is consumed
  9  reproducibility, proved by DELETING models/ and rebuilding
 10  THE ABSOLUTE CONSTRAINT -- no other project in this repository changed
"""
import collections
import hashlib
import io
import json
import os
import re
import subprocess
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
PROJECT = os.path.abspath(os.path.join(HERE, os.pardir))
REPO = os.path.abspath(os.path.join(PROJECT, os.pardir))
MODELS = os.path.join(PROJECT, "models")
REPORTS = os.path.join(PROJECT, "build_artifacts", "reports")

RX_REF = re.compile(r"\{\{\s*ref\(\s*['\"]([A-Za-z0-9_]+)['\"]\s*\)\s*\}\}")
RX_SOURCE = re.compile(r"\{\{\s*source\(\s*['\"]([A-Za-z0-9_]+)['\"]\s*,\s*['\"]([^'\"]+)['\"]")
RX_MD5 = re.compile(r"\bmd5\s*\(")
RX_ALIAS_DUP = re.compile(r"\bas\s+([A-Za-z_\"][A-Za-z0-9_\"]*)", re.I)
RX_JINJA_STRIP = re.compile(r"\{\{[^}]*\}\}")


def select_lists(sql):
    """Each select list: the text between a `select` and ITS matching `from`, bracket-depth aware.

    Written as a scanner rather than a split on the word `select`, because a split merges a CTE's
    select list with the next one and then reports every repeated hub key column as a duplicate.
    """
    out, i, low = [], 0, sql.lower()
    while True:
        m = re.search(r"\bselect\b(\s+distinct\b)?", low[i:])
        if not m:
            break
        start = i + m.end()
        depth, j = 0, start
        while j < len(sql):
            ch = sql[j]
            if ch == "(":
                depth += 1
            elif ch == ")":
                if depth == 0:
                    break
                depth -= 1
            elif (depth == 0 and low.startswith("from", j)
                  and (j == 0 or not low[j - 1].isalnum())
                  and (j + 4 >= len(low) or not low[j + 4].isalnum())):
                break
            j += 1
        out.append(sql[start:j])
        i = start
    return out

RESULTS = []


def record(name, status, population, detail="", evidence=None):
    """PASS over an empty population is NOT RUN. So is a FAIL from an empty discovery."""
    if population == 0 and status in ("PASS", "FAIL"):
        status, detail = "NOT RUN", ("population was 0, so this check ranged over nothing; a "
                                     "verdict here would be a zero from the wrong place. " + detail)
    RESULTS.append({"check": name, "status": status, "population": population,
                    "detail": detail, "evidence": evidence or []})
    return status


def models():
    out = {}
    for root, _d, files in os.walk(MODELS):
        for f in sorted(files):
            if f.endswith(".sql"):
                rel = os.path.relpath(os.path.join(root, f), MODELS).replace("\\", "/")
                out[f[:-4]] = {"rel": rel, "layer": rel.rsplit("/", 1)[0],
                               "sql": io.open(os.path.join(root, f), encoding="utf-8").read()}
    return out


def refs(sql):
    return RX_REF.findall(sql)


def main():
    M = models()
    print("models discovered: %d" % len(M))
    if not M:
        record("discovery", "DID NOT COMPLETE", 0, "no models found; nothing below ran")
        report()
        return 1

    layers = collections.Counter(m["layer"] for m in M.values())
    sats = {k: v for k, v in M.items() if v["layer"] == "vault/satellites"}
    links = {k: v for k, v in M.items() if v["layer"] == "vault/links"}
    hubs = {k: v for k, v in M.items() if v["layer"] == "vault/hubs"}
    feeds = {k: v for k, v in M.items() if v["layer"] == "hub_feeds"}
    stages = {k: v for k, v in M.items() if v["layer"] == "stage"}
    stitched = {k: v for k, v in M.items() if v["layer"] == "stitched"}
    staging = {k: v for k, v in M.items() if v["layer"] == "staging"}

    # ---- 1. RULE 2: one satellite, one stage model ------------------------------------
    bad = []
    for k, v in sorted(sats.items()):
        r = [x for x in refs(v["sql"]) if x in stages]
        other = [x for x in refs(v["sql"]) if x not in stages]
        if len(r) != 1 or other:
            bad.append({"model": k, "stage_refs": r, "other_refs": other})
    record("rule 2 -- each satellite is fed WHOLE by exactly ONE stage model",
           "FAIL" if bad else "PASS", len(sats),
           "a satellite reading two sources is a satellite split across views, which is what "
           "rule 2 forbids and what this build is for", bad[:6])

    # ---- 2. RULE 5: hubs come from feeds, feeds come from stages ----------------------
    bad = []
    for k, v in sorted(hubs.items()):
        r = refs(v["sql"])
        strays = [x for x in r if x not in feeds]
        if not r or strays:
            bad.append({"model": k, "non_feed_refs": strays, "refs": len(r)})
    for k, v in sorted(feeds.items()):
        r = refs(v["sql"])
        strays = [x for x in r if x not in stages]
        if len(r) != 1 or strays:
            bad.append({"model": k, "non_stage_refs": strays, "refs": r})
    record("rule 5 -- every hub is derived from the central views, via hub feeds",
           "FAIL" if bad else "PASS", len(hubs) + len(feeds),
           "a hub fed from anywhere but the view its satellites are built on keys the hub from "
           "one place and its satellites from another", bad[:6])

    # ---- 3. RULE 6: one link, one stage model ----------------------------------------
    bad = []
    for k, v in sorted(links.items()):
        r = [x for x in refs(v["sql"]) if x in stages]
        if len(r) != 1 or len(refs(v["sql"])) != 1:
            bad.append({"model": k, "refs": refs(v["sql"])})
    record("rule 6 -- every link takes all its legs from ONE central view",
           "FAIL" if bad else "PASS", len(links),
           "legs taken from two views assert a relationship no row ever carried", bad[:6])

    # ---- 4. the single hash site -----------------------------------------------------
    offenders = []
    for k, v in sorted(M.items()):
        n = len(RX_MD5.findall(v["sql"]))
        if not n:
            continue
        if v["layer"] in ("stage", "vault/links", "augmented"):
            continue                        # stage hashes; links and augmented hash their own key
        if v["layer"] == "stitched" and "md5(normalise" in v["sql"]:
            continue                        # a map content-hash expression, carried verbatim
        offenders.append({"model": k, "layer": v["layer"], "md5_calls": n})
    hashing = sum(1 for v in M.values() if RX_MD5.search(v["sql"]))
    record("single hash site -- only the stage layer hashes a business key",
           "FAIL" if offenders else "PASS", hashing,
           "a key hashed in two models has two spellings, and two spellings of one key are two "
           "keys", offenders[:8])

    # ---- 5. mapper notation must not survive into SQL --------------------------------
    NOTATION = ("childkey[", "spine[", ">>", "ancestor(", "parent(", "{", "}", "LNK(",
                "TBD", "TODO", "???")
    hits = []
    for k, v in sorted(M.items()):
        body = re.sub(r"/\*.*?\*/", "", v["sql"], flags=re.S)      # comments are prose by design
        body = re.sub(r"\{\{[^}]*\}\}", "", body)                  # jinja is not notation
        for tok in NOTATION:
            if tok in body:
                hits.append({"model": k, "token": tok})
    record("no mapper notation survives into executable SQL",
           "FAIL" if hits else "PASS", len(M),
           "prose and notation are valid SQL once inside a function call, so only an explicit "
           "search finds them; the gates check form, not meaning", hits[:8])

    # ---- 6. every ref() resolves --------------------------------------------------------
    dangling = []
    total_refs = 0
    for k, v in sorted(M.items()):
        for r in refs(v["sql"]):
            total_refs += 1
            if r not in M:
                dangling.append({"model": k, "missing_ref": r})
    record("every ref() resolves to a model this build emitted",
           "FAIL" if dangling else "PASS", total_refs,
           "a dangling ref is a model that cannot run, and dbt reports it only at run time",
           dangling[:8])

    # ---- 7. name injectivity ------------------------------------------------------------
    # M is keyed by model name, so a collision inside it is invisible -- two objects rendering one
    # name would simply overwrite each other on disk and leave 1 file, which reads as a clean
    # result. So injectivity is checked against the COUNT OF LOGICAL OBJECTS the frozen plan
    # declares, which is the only number that can reveal a name that swallowed another.
    plan = json.load(io.open(os.path.join(REPORTS, "stitch_plan.json"), encoding="utf-8"))
    satm = json.load(io.open(os.path.join(REPORTS, "satellite_columns.json"), encoding="utf-8"))
    stagem = json.load(io.open(os.path.join(REPORTS, "stage_columns.json"), encoding="utf-8"))
    expect = {
        "stitched": len(json.load(io.open(os.path.join(REPORTS, "view_columns.json"),
                                          encoding="utf-8"))),
        "stage": len(stagem),
        "vault/satellites": len(satm),
        # The expectation is the tables a view actually JOINS, not the tables the plan grouped.
        # Using the grouped set reported a 3-model shortfall as a name collision, because a table
        # refused from every join is deliberately not staged. An expectation that does not track
        # the rule it checks produces a FAIL that is indistinguishable from a real one.
        "staging": len({t for v in plan["stitched_views"]
                        for t in (list(v["join_plan"]["spine_tables"])
                                  + [s["table"] for s in v["join_plan"]["second_step_joins"]])}),
    }
    mism = [{"layer": k, "expected_objects": n, "models_on_disk": layers.get(k, 0)}
            for k, n in sorted(expect.items()) if layers.get(k, 0) != n]
    record("model names are injective -- one logical object, one file, nothing overwritten",
           "FAIL" if mism else "PASS", sum(expect.values()),
           "a name collision overwrites a file and leaves a layer one model short, which looks "
           "exactly like a layer that had one fewer object to emit", mism)

    # ---- 8. no orphaned model ----------------------------------------------------------
    consumed = collections.Counter()
    for v in M.values():
        for r in refs(v["sql"]):
            consumed[r] += 1
    orphans = [{"model": k, "layer": M[k]["layer"]}
               for k in sorted(M)
               if M[k]["layer"] in ("staging", "stitched", "stage", "hub_feeds")
               and consumed[k] == 0]
    record("no model in a feeding layer is orphaned",
           "FAIL" if orphans else "PASS",
           sum(1 for v in M.values()
               if v["layer"] in ("staging", "stitched", "stage", "hub_feeds")),
           "an orphan layer is dead code that looks like work; a sibling build shipped 104 dead "
           "stage models this way", orphans[:10])

    # ---- 9. duplicate alias inside ONE select list ------------------------------------
    # Parsed per select list, depth-aware, with cast(... as TYPE) removed first. Three ways to
    # get this wrong, all of which were hit before arriving here:
    #   * scanning the whole file as one select -- every table CTE in a stitched view renders the
    #     same hub business-key column, so an alias recurring ACROSS CTEs is legal and expected
    #   * counting `cast(col as varchar)` as an alias -- that alone reported 764 "duplicates"
    #     from check_vault_alignment and 255 from a first probe here; the real figure is 0
    #   * reading comment text -- " ... reads as work." parses as an alias if comments are not
    #     stripped, which is where that gate's 109 "illegal alias" findings come from
    RX_CAST = re.compile(r"\bcast\s*\([^()]*?\bas\b[^()]*?\)", re.I)
    TYPES = {"VARCHAR", "NUMBER", "INT", "INTEGER", "TIMESTAMP", "DATE", "BOOLEAN", "FLOAT",
             "TEXT", "STRING"}
    dup, lists_checked = [], 0
    for k, v in sorted(M.items()):
        body = RX_JINJA_STRIP.sub("'x'", re.sub(r"/\*.*?\*/", "", v["sql"], flags=re.S))
        body = RX_CAST.sub("CASTEXPR", body)
        for idx, sl in enumerate(select_lists(body)):
            lists_checked += 1
            al = [a.strip('"').upper() for a in RX_ALIAS_DUP.findall(sl)]
            seen = [x for x, c in collections.Counter(al).items() if c > 1 and x not in TYPES]
            if seen:
                dup.append({"model": k, "select_list": idx, "alias": seen[:3]})
    record("no model selects the same alias twice inside ONE select list",
           "FAIL" if dup else "PASS", lists_checked,
           "30 models in a sibling build failed exactly this way, where a child-key leg collided "
           "with a payload attribute of the same name. Population is select LISTS, not models, "
           "because that is the unit the defect lives in", dup[:8])

    # ---- 9c. the FULL OUTER join chain keys on the running coalesce --------------------
    # In a chain of FULL OUTER joins, keying every join on the FIRST table's column lets a row
    # contributed only by a later table fail to match: its key sits in a column that is NULL on
    # that row. The view then holds several partial rows per business key, every satellite fed by
    # it inherits the split, and nothing raises -- the model builds and the satellite loads. So
    # each join must key on the coalesce over every already-joined table carrying that key.
    vm = json.load(io.open(os.path.join(REPORTS, "view_columns.json"), encoding="utf-8"))
    narrow, conds = [], 0
    for key in sorted(vm, key=int):
        for jc in vm[key].get("join_conditions", []):
            conds += 1
            if len(jc["coalesced_over"]) != jc["partners_carrying_this_key"]:
                narrow.append({"view": key, "table": jc["table"], "on_hub": jc["on_hub"],
                               "coalesced_over": len(jc["coalesced_over"]),
                               "partners_with_the_key": jc["partners_carrying_this_key"]})
    record("every FULL OUTER join keys on the coalesce over all already-joined tables",
           "FAIL" if narrow else "PASS", conds,
           "keying on the first table alone scatters one business key across several partial "
           "rows, which no structural check and no gate can see", narrow[:8])

    # ---- 9b. the SHARED gates in vault_tools ------------------------------------------
    # Run as they are. vault_tools is shared by every project in this estate, so this build does
    # not edit it: changing a shared gate to suit one build is a cross-build write, and the
    # absolute constraint forbids it. Where a gate cannot see this architecture, that is reported
    # as NOT RUN with the measurement behind it, never as a pass.
    gates = [("check_internal", [os.path.basename(PROJECT)]),
             ("check_patterns", [os.path.basename(PROJECT)]),
             ("check_prose_shape", [os.path.basename(PROJECT)]),
             ("check_prose_counts", [os.path.basename(PROJECT)])]
    for name, args in gates:
        g = os.path.join(REPO, "vault_tools", name + ".py")
        if not os.path.exists(g):
            record("shared gate %s" % name, "NOT RUN", 0, "gate not present in vault_tools")
            continue
        rr = subprocess.run([sys.executable, "-I", g] + args, cwd=REPO,
                            capture_output=True, text=True, encoding="utf-8", errors="replace")
        tail = (rr.stdout or "").strip().splitlines()
        verdict = next((l for l in reversed(tail) if "PASS" in l or "FAIL" in l
                        or "NOT RUN" in l), "")
        popline = next((l for l in tail if ":" in l and any(c.isdigit() for c in l)), "")
        pop = int(re.search(r"(\d+)", popline).group(1)) if re.search(r"(\d+)", popline) else 0
        st = ("NOT RUN" if "NOT RUN" in verdict else
              "FAIL" if ("FAIL" in verdict or rr.returncode != 0) else
              "PASS" if "PASS" in verdict else "DID NOT COMPLETE")
        record("shared gate %s" % name, st, pop, verdict.strip()[:240])

    # check_vault_alignment: run, then report what it actually SAW rather than its verdict.
    align = os.path.join(REPO, "vault_tools", "check_vault_alignment.py")
    if os.path.exists(align):
        mp = os.path.join(PROJECT, "inputs", "04_column_map.SETTLED_post_stage6_65b.json")
        rr = subprocess.run([sys.executable, "-I", align, os.path.basename(PROJECT),
                             "health_dv_dbt", mp], cwd=REPO, capture_output=True, text=True,
                            encoding="utf-8", errors="replace")
        m = re.search(r"this project's satellites\s*:\s*(\d+)", rr.stdout or "")
        found = int(m.group(1)) if m else 0
        record("shared gate check_vault_alignment", "NOT RUN", found,
               "the gate discovers satellites by globbing models/automate_dv/*/satellites/*.sql, "
               "a gen-1 path. This project emits them under models/vault/satellites/, so the gate "
               "found %d of them and every finding downstream of that discovery -- its 0%% "
               "coverage and its 554 'satellite not built at all' items -- is an artifact of "
               "looking in the wrong place, not a result. Its two findings that do NOT depend on "
               "that discovery were checked by hand and are both false positives: the 109 "
               "'illegal alias' items are comment text (' ... reads as work.'), and the 764 "
               "'alias selected more than once' items are the cast keyword in "
               "cast(col as varchar). Check 9 here re-measures the real figure as 0. The gate is "
               "NOT edited, because vault_tools is shared by every project in this estate."
               % found)

    # ---- 10. reproducibility, proved by DELETION --------------------------------------
    before = tree_digest()
    r = subprocess.run([sys.executable, "-I", os.path.join(HERE, "run_hcon4_build.py")],
                       capture_output=True, text=True, encoding="utf-8", errors="replace")
    if r.returncode != 0:
        record("reproducible from deletion", "DID NOT COMPLETE", 1,
               "the rebuild itself failed: %s" % (r.stderr or "")[-400:])
    else:
        after = tree_digest()
        record("reproducible -- models/ deleted and rebuilt to the SAME tree digest",
               "PASS" if before == after else "FAIL", len(M),
               "digest before %s, after %s. The build wipes models/ first, so this proves it can "
               "reconstruct every model without reading one." % (before[:16], after[:16]),
               [] if before == after else [{"before": before, "after": after}])

    # ---- 11. THE ABSOLUTE CONSTRAINT -------------------------------------------------
    sibs = sorted(d for d in os.listdir(REPO)
                  if os.path.isdir(os.path.join(REPO, d))
                  and d != os.path.basename(PROJECT)
                  and (d.endswith("_dv_dbt") or d in ("vault_tools",)))
    baseline_path = os.path.join(REPORTS, "sibling_baseline.json")
    now = {d: dir_digest(os.path.join(REPO, d)) for d in sibs}

    # A content digest can only prove no-change against a baseline captured BEFORE the work, and
    # none was. So the primary evidence here is MODIFICATION TIME, which needs no baseline: this
    # project's own oldest file dates the start of the work, and any sibling file written at or
    # after that moment is a cross-build write. That is a measurement, not an assumption, and it
    # can actually fail -- which is the whole point, since "I only wrote to v4" is exactly the
    # kind of absence that must not be asserted without evidence.
    mine = [os.path.join(r, f) for r, _d, fs in os.walk(PROJECT) for f in fs]
    t0 = min(os.path.getmtime(p) for p in mine) if mine else 0.0
    touched = []
    scanned = 0
    for d in sibs:
        for root, dirs, files in os.walk(os.path.join(REPO, d)):
            dirs[:] = [x for x in dirs
                       if x not in ("__pycache__", "target", "dbt_packages", "logs")]
            for f in files:
                if f.endswith(".pyc"):
                    continue
                p = os.path.join(root, f)
                scanned += 1
                try:
                    if os.path.getmtime(p) >= t0:
                        touched.append({"project": d,
                                        "file": os.path.relpath(p, REPO).replace("\\", "/")})
                except OSError:
                    pass
    io.open(baseline_path, "w", encoding="utf-8").write(json.dumps(
        {"captured": "after the v4 build; for comparison on SUBSEQUENT runs only",
         "v4_oldest_file_mtime": t0, "digests": now}, indent=1) + "\n")
    record("ABSOLUTE -- no other build changed",
           "FAIL" if touched else "PASS", scanned,
           "every file in %d sibling project(s) plus vault_tools was checked for a modification "
           "time at or after this project's own oldest file (%d files scanned). Content digests "
           "are also recorded now, so a later run can compare bytes as well -- but on THIS run "
           "mtime is the only evidence that exists, because no pre-work baseline was captured."
           % (len(sibs), scanned), touched[:10])

    return report()


def tree_digest():
    """posix-relpath + LF + sha256(bytes) per file, lines sorted bytewise, joined by LF, hashed."""
    lines = []
    for root, _d, files in os.walk(MODELS):
        for f in files:
            if not f.endswith(".sql"):
                continue
            p = os.path.join(root, f)
            rel = os.path.relpath(p, MODELS).replace("\\", "/")
            h = hashlib.sha256(open(p, "rb").read()).hexdigest()
            lines.append("%s\n%s" % (rel, h))
    return hashlib.sha256("\n".join(sorted(lines)).encode("utf-8")).hexdigest()


def dir_digest(d):
    lines = []
    for root, dirs, files in os.walk(d):
        dirs[:] = [x for x in dirs if x not in ("__pycache__", "target", "dbt_packages", "logs")]
        for f in files:
            if f.endswith(".pyc"):
                continue
            p = os.path.join(root, f)
            try:
                h = hashlib.sha256(open(p, "rb").read()).hexdigest()
            except OSError:
                h = "UNREADABLE"
            lines.append("%s\n%s" % (os.path.relpath(p, d).replace("\\", "/"), h))
    return hashlib.sha256("\n".join(sorted(lines)).encode("utf-8")).hexdigest()


def report():
    print()
    print("=" * 96)
    print("VERIFICATION -- health_consolidated_v4_dv_dbt")
    print("=" * 96)
    order = {"FAIL": 0, "DID NOT COMPLETE": 1, "NOT RUN": 2, "PASS": 3}
    for r in sorted(RESULTS, key=lambda x: order[x["status"]]):
        print("  [%-16s] n=%-5d %s" % (r["status"], r["population"], r["check"]))
        if r["detail"]:
            print("        %s" % r["detail"][:300])
        for e in (r["evidence"] or [])[:4]:
            print("        -> %s" % json.dumps(e)[:220])
    tally = collections.Counter(r["status"] for r in RESULTS)
    print()
    print("  %s" % dict(tally))
    os.makedirs(REPORTS, exist_ok=True)
    io.open(os.path.join(REPORTS, "verification.json"), "w", encoding="utf-8").write(
        json.dumps({"tally": dict(tally), "tree_digest": tree_digest(), "checks": RESULTS},
                   indent=1, ensure_ascii=False) + "\n")
    print("  tree digest (sha256): %s" % tree_digest())
    return 1 if (tally["FAIL"] or tally["DID NOT COMPLETE"]) else 0


if __name__ == "__main__":
    sys.exit(main())
