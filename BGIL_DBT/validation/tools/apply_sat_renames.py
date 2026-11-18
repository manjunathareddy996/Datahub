#!/usr/bin/env python3
"""Apply column renames from validation/SAT_COLUMN_CONSISTENCY_ALL_LOBS.xlsx ('Name differences').

For every open row (not Done) whose Difference is in --kinds it renames the column, for every project in
'Rename in', in the satellite model and in the models on its feed chain:

  sat      'OLD' -> 'NEW'                       (payload, cdk, src_column_map, src_object_columns)
  satfeed  `x as OLD` -> `x as NEW`, bare `OLD,` select item -> `NEW,`
  stg2     hashdiff list entry of THIS sat's hashdiff, and the derived key `OLD: ...`.  If another satellite that
           reads the same stage still needs OLD, OLD stays and a NEW key with the same expression is added.
  stitch   quoted lower-case 'old' (tgt / output_columns / coalesce_rules); never 'src' / 'key_column' / 'ldts_column'
  unpivot  `as old` select aliases (lower case)

A row is applied only when every project of the row can be applied and no other satellite that shares a
stitch / unpivot / satfeed file and still uses the old name would be broken.  Rows that depend on each
other (shared upstream file) are applied together or not at all.  Files are read and written as bytes, so CRLF
line endings stay as they are.  Finished rows are appended to sat_column_done.json.

    apply_sat_renames.py [--kinds "Underscores,_CK suffix"] [--limit N] [--fix PROJ:SAT:OLD:NEW ...] [--apply]
    apply_sat_renames.py --differs "MAXIMUS vs OPUS" --kinds "Extra word,Spelling" [--apply]
        only rows whose 'Differs between' cell contains the text (any --kinds value works with it)
    apply_sat_renames.py --drop-ck [--apply]     rows whose Difference involves _CK: every project that has
        the name with _CK (or with other underscore differences) is renamed to the plain name WITHOUT _CK.
        A row is skipped when the plain name already exists in that satellite (collision).

Dry run unless --apply.  --fix renames a column that is not a workbook row (spelling fixes); such renames are not
recorded in sat_column_done.json."""
import json
import re
import sys
from collections import defaultdict
from pathlib import Path

import openpyxl

ROOT = Path(__file__).resolve().parents[2]
DIRS = {"OP": "opus_partner_dv_dbt", "MP": "maximus_partner_dv_dbt", "OT": "opus_travel_dv_dbt",
        "MT": "maximus_travel_dv_dbt", "OH": "opus_health_dv_dbt", "MH": "maximus_health_dv_dbt",
        "OM": "opus_motor_dv_dbt"}
CODES = list(DIRS)
UPSTREAM = ("stg2", "satfeed", "stitch", "unpivot")
# Team decisions that override the sheet (modeller-learnings 2026-11-16): never rename these automatically.
KEEP = set()   # 2026-11-18: user lifted the SAT_PARTY_KYC_REFERENCE / KYCREFERENCETYPE exception


def arg(name, default=None):
    return sys.argv[sys.argv.index(name) + 1] if name in sys.argv else default


def args(name):
    return [sys.argv[i + 1] for i, a in enumerate(sys.argv) if a == name]


def models(code):
    return {p.stem: p for p in (ROOT / DIRS[code] / "models").rglob("*.sql") if "dbt_packages" not in p.parts}


def kind_of(stem):
    if stem.startswith("sat_"):
        return "sat"
    for k in UPSTREAM:
        if k in stem:
            return k
    return None


def word(tok, flags=0):
    return re.compile(r"(?<![\w])" + re.escape(tok) + r"(?![\w])", flags)


def strip_comments(t):
    t = re.sub(r"\{#.*?#\}", "", t, flags=re.S)
    return re.sub(r"--[^\n]*", "", t)


class Project:
    def __init__(self, code):
        self.code, self.M = code, models(code)
        self.cache = {}                      # path -> current text
        self.chains = {}

    def text(self, p):
        if p not in self.cache:
            self.cache[p] = p.read_bytes().decode()
        return self.cache[p]

    def chain(self, sat_stem):
        """sat file + every satfeed / stg2 / stitch / unpivot reachable from it (names as they appear in text)."""
        if sat_stem in self.chains:
            return self.chains[sat_stem]
        out, todo = {}, [self.M.get(sat_stem)]
        while todo:
            p = todo.pop()
            if p is None or p.stem in out:
                continue
            out[p.stem] = p
            for t in set(re.findall(r"\w+", strip_comments(p.read_bytes().decode()))):
                q = self.M.get(t)
                if q and q.stem not in out and kind_of(t) in UPSTREAM and t != p.stem:
                    todo.append(q)
        self.chains[sat_stem] = out
        return out


class Fail(Exception):
    pass


def sat_columns(code, sat, cache={}):
    """cdk + payload names of a satellite as declared in its yaml_metadata."""
    import yaml
    M = cache.setdefault(code, models(code))
    p = M.get(sat.lower())
    if not p:
        return set()
    m = re.search(r"\{%-?\s*set\s+yaml_metadata\s*-?%\}(.*?)\{%-?\s*endset\s*-?%\}", p.read_text(), re.S)
    meta = yaml.safe_load(m.group(1)) if m else {}
    cdk = meta.get("src_cdk") or []
    cdk = [cdk] if isinstance(cdk, str) else cdk
    return {str(x).upper() for x in cdk} | {str(x).upper() for x in meta.get("src_payload") or []}


def hashdiff_name(proj, sat_stem, stg2_stem):
    """Name of the hashdiff column in the stage that this satellite reads."""
    t = proj.text(proj.M[sat_stem])
    m = re.search(r"src_hashdiff:\s*'?(\w+)'?", t)
    name = m.group(1) if m else "HASHDIFF"
    for stem, p in proj.chain(sat_stem).items():
        if kind_of(stem) == "satfeed":
            mm = re.search(r"(\w+)\s+as\s+HASHDIFF\b", strip_comments(proj.text(p)), re.I)
            if mm:
                name = mm.group(1)
    return name.upper()


def edit_stg2(proj, p, sat_stem, old, new, readers):
    t = proj.text(p)
    nl = "\r\n" if "\r\n" in t else "\n"
    lines = t.split("\n")
    me = hashdiff_name(proj, sat_stem, p.stem)
    in_hashed, block, done_any = False, None, False
    for i, line in enumerate(lines):
        body = line.rstrip("\r")
        if re.match(r"^\s*hashed_columns:\s*$", body):
            in_hashed, block = True, None
            continue
        if in_hashed and re.match(r"^\S", body):
            in_hashed = False
        if in_hashed:
            mb = re.match(r"^\s{2}(\w+):\s*$", body)
            if mb:
                block = mb.group(1).upper()
            ml = re.match(r"^(\s*-\s*')" + re.escape(old) + r"('\s*)$", body)
            if ml and block == me:
                lines[i] = ml.group(1) + new + ml.group(2) + ("\r" if line.endswith("\r") else "")
                done_any = True
    t = "\n".join(lines)
    proj.cache[p] = t
    # derived key
    key = re.compile(r"(?m)^(\s*)" + re.escape(old) + r":([ \t].*)$")
    newkey = re.compile(r"(?m)^\s*" + re.escape(new) + r":")
    km = key.search(t)
    if km:
        needed = False
        for rd in readers:                       # another satellite still reading OLD from this stage
            if rd == sat_stem:
                continue
            blob = proj.text(proj.M[rd]) + "".join(proj.text(q) for s, q in proj.chain(rd).items() if kind_of(s) == "satfeed")
            if word(old).search(strip_comments(blob)):
                needed = True
        if re.search(r"(?m)^\s+-\s*'" + re.escape(old) + r"'\s*$", proj.cache[p]):
            needed = True                         # another hashdiff block of this stage still lists OLD
        if needed:
            if not newkey.search(t):
                t = key.sub(lambda m: m.group(1) + old + ":" + m.group(2) + nl + m.group(1) + new + ":" + m.group(2),
                            t, count=1)
        elif newkey.search(t):
            t = re.sub(r"(?m)^\s*" + re.escape(old) + r":[ \t].*\r?\n", "", t, count=1)
        else:
            t = key.sub(lambda m: m.group(1) + new + ":" + m.group(2), t, count=1)
        done_any = True
    proj.cache[p] = t
    return done_any


def rewrite_upstream(kind, s, old, new):
    """Text of a satfeed / stitch / unpivot model after renaming old -> new (unchanged text = file not affected)."""
    lo, ln = old.lower(), new.lower()
    if kind == "satfeed":
        s = re.sub(r"(?m)^(\s*)" + re.escape(old) + r"(\s+as\s+" + re.escape(old) + r"(?![\w]))",
                   lambda m: m.group(1) + new + m.group(2), s, flags=re.I)        # `OLD as OLD`: stage key is renamed too
        s = re.sub(r"(\bas\s+)" + re.escape(old) + r"(?![\w])", lambda m: m.group(1) + new, s, flags=re.I)
        return re.sub(r"(?m)^(\s*)" + re.escape(old) + r"(\s*,?[ \t]*\r?)$", lambda m: m.group(1) + new + m.group(2), s)
    if kind == "stitch":
        def sub(m):
            before = s[max(0, m.start() - 20):m.start()]
            if re.search(r"'(src|key_column|ldts_column|model|alias)'\s*:\s*$", before):
                return m.group(0)
            return "'" + ln + "'"
        return re.sub(r"'" + re.escape(lo) + r"'", sub, s)
    if kind == "unpivot":
        return re.sub(r"(\bas\s+)" + re.escape(lo) + r"(?![\w])", lambda m: m.group(1) + ln, s, flags=re.I)
    return s


def apply_one(proj, sat, old, new, plan, readers_of):
    """Edit the working texts of one project for one (sat, old -> new). Raises Fail."""
    sat_stem = sat.lower()
    chain = proj.chain(sat_stem)
    if sat_stem not in proj.M:
        raise Fail("satellite file not found")
    sat_p = proj.M[sat_stem]
    t = proj.text(sat_p)
    if f"'{old}'" not in t:
        raise Fail(f"{old} not in satellite file")
    deps = set()
    for stem, p in chain.items():
        k = kind_of(stem)
        if k in ("stitch", "unpivot", "satfeed") and rewrite_upstream(k, proj.text(p), old, new) != proj.text(p):
            for other in readers_of(stem):                # shared file that this rename edits: every user of old must rename too
                if other == sat_stem:
                    continue
                ot = proj.text(proj.M[other])
                if f"'{old}'" in ot:
                    if plan.get((other.upper(), old)) != new:
                        raise Fail(f"{stem} is shared with {other}, which keeps {old}")
                    deps.add(other.upper())
    proj.cache[sat_p] = t.replace(f"'{old}'", f"'{new}'")
    touched = 0
    for stem, p in chain.items():
        k = kind_of(stem)
        before = proj.text(p)
        if k == "stg2":
            edit_stg2(proj, p, sat_stem, old, new, readers_of(stem))
        elif k in ("satfeed", "stitch", "unpivot"):
            proj.cache[p] = rewrite_upstream(k, before, old, new)
        if k and proj.cache[p] != before:
            touched += 1
    if not touched:
        raise Fail(f"{old}: nothing to rename in satfeed / stage / stitch / unpivot of {sat}")
    return deps


def main():
    kinds = {k.strip() for k in arg("--kinds", "Underscores,_CK suffix").split(",")}
    limit = int(arg("--limit", "100000"))
    apply = "--apply" in sys.argv
    ws = openpyxl.load_workbook(ROOT / "validation/SAT_COLUMN_CONSISTENCY_ALL_LOBS.xlsx")["Name differences"]
    wbrows = [r for r in ws.iter_rows(min_row=3, values_only=True) if not r[-1]][:limit]
    work = []                                            # (key, row or None, [(code, sat, old, new)])
    drop_ck = "--drop-ck" in sys.argv
    differs = arg("--differs")
    for r in wbrows:
        if differs and differs not in (r[14] or ""):
            continue
        sat, kind, new, rin = r[0], r[2], r[10], r[11]
        cells = {c: (r[3 + i] or "").replace(" [cdk]", "") for i, c in enumerate(CODES) if r[3 + i]}
        if drop_ck:
            if "_CK suffix" not in kind:
                continue
            new = re.sub(r"_CK$", "", new)
            items = [(c, sat, n, new) for c, n in cells.items() if n != new]
            if any((sat, o) in KEEP for _, _, o, _ in items):
                print("KEEP", sat, "(team decision, not renamed)")
                continue
            clash = [c for c, _, _, _ in items if new in sat_columns(c, sat)]
            if clash:
                print(f"CLASH {sat}: {new} already exists in {clash}; row left open")
                continue
            r = list(r)
            r[10], r[11] = new, ", ".join(c for c, _, _, _ in items)     # what was actually done
            work.append((len(work), tuple(r), items))
            continue
        if kind not in kinds:
            continue
        if any((sat, cells.get(c.strip(), "")) in KEEP for c in rin.split(",")):
            print("KEEP", sat, "(team decision, not renamed)")
            continue
        items = [(c.strip(), sat, cells[c.strip()], new) for c in rin.split(",")]
        clash = [c for c, _, _, n in items if n in sat_columns(c, sat)]
        if clash:
            print(f"CLASH {sat}: {new} already exists in {clash}; row left open")
            continue
        work.append((len(work), r, items))
    for spec in args("--fix"):
        code, sat, old, new = spec.split(":")
        work.append((len(work), None, [(code, sat.upper(), old, new)]))
    disabled, reasons = set(), {}
    projects = {}
    while True:
        projects = {c: Project(c) for c in DIRS}
        plan = {}
        for key, r, items in work:
            if key not in disabled:
                for code, sat, old, new in items:
                    plan[(code, sat, old)] = new
        results, needs = {}, {}
        for key, r, items in work:
            if key in disabled:
                continue
            try:
                need = set()
                for code, sat, old, new in items:
                    pl = {(s, o): n for (c, s, o), n in plan.items() if c == code}
                    proj = projects[code]
                    readers = lambda stem, proj=proj: [s for s in proj.M if s.startswith("sat_") and stem in proj.chain(s)]
                    for d in apply_one(proj, sat, old, new, pl, readers):
                        need.add((code, d, old))
                results[key], needs[key] = items, need
            except Fail as e:
                disabled.add(key)
                reasons[key] = f"{items[0][1]} {[(c, o) for c, s, o, n in items]}: {e}"
                break                                    # texts are dirty: rebuild from scratch
        else:
            # dependency closure: a row that needs another satellite's row must find it applied
            bad = {k for k, need in needs.items()
                   if any(not any(c == code and s == sat and o == old and k2 in results for k2, _, its in work
                                  for c, s, o, n in its) for code, sat, old in need)}
            if not bad:
                break
            for k in bad:
                disabled.add(k)
                reasons[k] = "depends on a row that cannot be applied"
    ok = [(key, r, items) for key, r, items in work if key in results]
    print(f"rows applied: {len(ok)}   rows skipped: {len(work) - len(ok)}")
    for key, r, items in ok:
        print("OK  ", items[0][1], [(c, o, n) for c, s, o, n in items])
    for key, r, items in work:
        if key not in results:
            print("SKIP", reasons.get(key, f"{items[0][1]} {[(c, o) for c, s, o, n in items]}: not applied"))
    changed = []
    for proj in projects.values():
        for p, t in proj.cache.items():
            if t.encode() != p.read_bytes():
                changed.append((p, t))
    print(f"files changed: {len(changed)}")
    if apply:
        for p, t in changed:
            p.write_bytes(t.encode())
        f = ROOT / "validation/tools/sat_column_done.json"
        d = json.loads(f.read_text()) if f.exists() else {}
        for key, r, items in ok:
            if r is not None:
                d.setdefault(r[0], []).append(list(r[:-1]))
        f.write_text(json.dumps(d, indent=1))
        print("written")


main()
