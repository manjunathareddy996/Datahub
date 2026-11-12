#!/usr/bin/env python3
"""
Satellite overlap analysis across the six dbt vault projects.

Question answered: which satellites are built by MORE THAN ONE project -- across LOBs
(partner / travel / health) and/or across source systems inside one LOB (MAXIMUS vs OPUS) --
which macro each project uses (native AutomateDV vs the project wrappers), and where the
shared physical table is written with a different shape by each writer.

Physical sharing: five projects land in BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL, so a
satellite of the same name there is ONE table written by several pipelines (rows told apart by
RECORD_SOURCE). maximus_health_dv_dbt writes its own schemas (std_/aug_automate_dv_maximus_health),
so it matches by NAME only -- reported as 'logical', never as a physical collision.

Output: BGIL_DBT/validation/SAT_CROSS_LOB_ANALYSIS.xlsx (re-run to refresh).

    python3 BGIL_DBT/validation/tools/analyze_sat_overlap.py
"""
import collections
import glob
import os
import re
from pathlib import Path

import yaml
from openpyxl import Workbook
from openpyxl.styles import Alignment, Font, PatternFill
from openpyxl.utils import get_column_letter

ROOT = Path(__file__).resolve().parents[2]          # BGIL_DBT
OUT = ROOT / "validation" / "SAT_CROSS_LOB_ANALYSIS.xlsx"

PROJECTS = collections.OrderedDict([
    ("maximus_partner_dv_dbt", ("MAXIMUS", "PARTNER")),
    ("opus_partner_dv_dbt", ("OPUS", "PARTNER")),
    ("maximus_travel_dv_dbt", ("MAXIMUS", "TRAVEL")),
    ("opus_travel_dv_dbt", ("OPUS", "TRAVEL")),
    ("maximus_health_dv_dbt", ("MAXIMUS", "HEALTH")),
    ("opus_health_dv_dbt", ("OPUS", "HEALTH")),
])
ISOLATED = "maximus_health_dv_dbt"                  # own schemas, not the shared vault
NATIVE = {"automate_dv.sat", "automate_dv.ma_sat"}
MACRO_RE = re.compile(r"\b(automate_dv\.ma_sat|automate_dv\.sat|ma_sat_multi_source|sat_multi_source)\s*\(")
SHORT = {"automate_dv.sat": "sat", "automate_dv.ma_sat": "ma_sat",
         "sat_multi_source": "sat_multi_source", "ma_sat_multi_source": "ma_sat_multi_source"}


def _strip(sql):
    sql = re.sub(r"\{#.*?#\}", "", sql, flags=re.S)
    return re.sub(r"--[^\n]*", "", sql)


def parse(path, proj):
    body = _strip(Path(path).read_text())
    m = re.search(r"\{%-?\s*set yaml_metadata\s*-?%\}(.*?)\{%-?\s*endset\s*-?%\}", body, re.S)
    meta = (yaml.safe_load(m.group(1)) or {}) if m else {}
    mc = MACRO_RE.search(body)
    am = re.search(r"config\([^)]*\balias\s*=\s*['\"]([^'\"]+)['\"]", body)
    table = (am.group(1) if am else os.path.basename(path)[:-4]).upper()
    sm = meta.get("source_model")
    sm = [sm] if isinstance(sm, str) else (sm or [])
    cdk = meta.get("src_cdk") or []
    al = re.search(r"src_hashdiff_alias\s*=\s*['\"]([^'\"]+)", body)
    hd = meta.get("src_hashdiff")
    if isinstance(hd, dict):
        hd = list(hd.values())[0]
    system, lob = PROJECTS[proj]
    return dict(project=proj, system=system, lob=lob, table=table,
                layer="augmented" if "/augmented/" in str(path) else "standard",
                macro=mc.group(1) if mc else "?", feeds=len(sm), pk=meta.get("src_pk"),
                cdk=tuple(cdk if isinstance(cdk, list) else [cdk]),
                hd_phys=(al.group(1) if al else hd),
                payload=frozenset(str(x).upper() for x in (meta.get("src_payload") or [])),
                file=os.path.relpath(path, ROOT))


def load():
    rows = []
    for proj in PROJECTS:
        for p in glob.glob(str(ROOT / proj / "models" / "**" / "sat_*.sql"), recursive=True):
            if "/dbt_packages/" not in p:
                rows.append(parse(p, proj))
    return rows


def issues(ws):
    """ws = rows of ONE table from the shared-vault projects. Return list of issue strings."""
    out = []
    macros = {r["project"]: r["macro"] for r in ws}
    if len(set(macros.values())) > 1:
        out.append("MACRO MIX: " + ", ".join(f"{p.rsplit('_dv', 1)[0]}={SHORT[m]}" for p, m in macros.items()))
    if len({r["pk"] for r in ws}) > 1:
        out.append("PK DIFFERS: " + ", ".join(f"{r['project'].rsplit('_dv', 1)[0]}={r['pk']}" for r in ws))
    ma = {bool(r["cdk"]) for r in ws}
    if len(ma) > 1:
        out.append("MULTI-ACTIVE vs SINGLE-ROW: " + ", ".join(
            f"{r['project'].rsplit('_dv', 1)[0]}={'cdk ' + '+'.join(r['cdk']) if r['cdk'] else 'no cdk'}" for r in ws))
    elif len({r["cdk"] for r in ws}) > 1:
        out.append("CHILD KEY NAMES DIFFER: " + ", ".join(
            f"{r['project'].rsplit('_dv', 1)[0]}={'+'.join(r['cdk'])}" for r in ws))
    if len({r["hd_phys"] for r in ws}) > 1:
        out.append("HASHDIFF COLUMN DIFFERS: " + ", ".join(
            f"{r['project'].rsplit('_dv', 1)[0]}={r['hd_phys']}" for r in ws))
    return out


def main():
    rows = load()
    by = collections.defaultdict(list)
    for r in rows:
        by[r["table"]].append(r)

    def macro_cells(rs):
        d = {r["project"]: r for r in rs}
        return [SHORT[d[p]["macro"]] + (f" ({d[p]['feeds']} feed)" if d[p]["feeds"] > 1 else "") if p in d else ""
                for p in PROJECTS]

    all_rows, cross_lob, same_lob, conflicts = [], [], [], []
    for t in sorted(by):
        rs = by[t]
        shared = [r for r in rs if r["project"] != ISOLATED]
        sp = sorted({r["project"] for r in shared})
        lobs = sorted({r["lob"] for r in rs})
        shared_lobs = sorted({r["lob"] for r in shared})
        lob_sys = collections.defaultdict(set)
        for r in rs:
            lob_sys[r["lob"]].add(r["system"])
        multi_src = sorted(l for l, s in lob_sys.items() if len(s) > 1)
        native = sorted({SHORT[r["macro"]] for r in rs if r["macro"] in NATIVE})
        phys = len(sp) >= 2
        iss = issues(shared) if phys else []
        scope = ("CROSS-LOB" if len(lobs) > 1 else "") + (" + " if len(lobs) > 1 and multi_src else "") + \
                ("SAME-LOB CROSS-SOURCE (" + "/".join(multi_src) + ")" if multi_src else "")
        base = [t, rs[0]["layer"], len(rs), ", ".join(lobs), ", ".join(sorted({r["system"] for r in rs})),
                scope or "single project",
                "PHYSICAL (shared vault)" if phys else ("logical only (maximus_health)" if len(rs) > 1 else ""),
                ", ".join(native) or "none (wrapper only)"]
        line = base + macro_cells(rs) + ["; ".join(iss)]
        all_rows.append(line)
        if len(rs) < 2 or not native:
            continue
        if len(lobs) > 1:
            cross_lob.append(line)
        if multi_src:
            same_lob.append(line)
        if iss:
            conflicts.append(line)

    head = ["SATELLITE", "LAYER", "# PROJECTS", "LOBs", "SOURCE SYSTEMS", "OVERLAP TYPE", "SHARING",
            "NATIVE AutomateDV MACRO USED"] + [p.rsplit("_dv", 1)[0] for p in PROJECTS] + ["SHARED-TABLE ISSUES"]

    # ---- summary numbers
    multi = [r for r in all_rows if r[2] > 1]
    n_phys = sum(1 for r in all_rows if r[6].startswith("PHYSICAL"))
    mix = collections.Counter(tuple(sorted(set(x for x in r[8:14] if x))) for r in conflicts if "MACRO MIX" in r[14])
    summary = [
        ("Models scanned", len(rows)),
        ("Distinct satellite tables", len(by)),
        ("Built by only one project", len(by) - len(multi)),
        ("Built by 2+ projects (name overlap)", len(multi)),
        ("  of which physically shared (>=2 shared-vault projects)", n_phys),
        ("  CROSS-LOB, native AutomateDV in >=1 project", len(cross_lob)),
        ("  SAME-LOB, different source system (MAXIMUS+OPUS), native in >=1", len(same_lob)),
        ("Physically shared tables with at least one issue", len(conflicts)),
        ("  macro mix", sum(1 for r in conflicts if "MACRO MIX" in r[14])),
        ("  PK differs", sum(1 for r in conflicts if "PK DIFFERS" in r[14])),
        ("  multi-active vs single-row", sum(1 for r in conflicts if "MULTI-ACTIVE" in r[14])),
        ("  child key names differ", sum(1 for r in conflicts if "CHILD KEY" in r[14])),
        ("  hashdiff column differs", sum(1 for r in conflicts if "HASHDIFF COLUMN" in r[14])),
    ]

    # ---- plain presence table: native-AutomateDV sats and every project that also has them
    pres = []
    for t in sorted(by):
        rs = by[t]
        if len(rs) < 2 or not any(r["macro"] in NATIVE for r in rs):
            continue
        d = {r["project"]: r for r in rs}
        pres.append([t, rs[0]["layer"]] + [SHORT[d[p]["macro"]] if p in d else "-" for p in PROJECTS] + [len(rs)])
    pres.sort(key=lambda r: (-r[-1], r[1], r[0]))
    pres_head = ["SATELLITE", "LAYER"] + [p.rsplit("_dv", 1)[0] for p in PROJECTS] + ["# PROJECTS"]

    wb = Workbook()
    hfill = PatternFill("solid", fgColor="1F4E78")

    def sheet(ws, title, headers, data, widths=None):
        ws.title = title
        ws.append(headers)
        for c in ws[1]:
            c.font = Font(bold=True, color="FFFFFF")
            c.fill = hfill
            c.alignment = Alignment(wrap_text=True, vertical="center")
        for d in data:
            ws.append(d)
        ws.freeze_panes = "B2"
        ws.auto_filter.ref = ws.dimensions
        for i, h in enumerate(headers, 1):
            w = (widths or {}).get(h) or min(60, max(12, len(str(h)) + 2))
            ws.column_dimensions[get_column_letter(i)].width = w
        for row in ws.iter_rows(min_row=2):
            for c in row:
                c.alignment = Alignment(wrap_text=True, vertical="top")

    sheet(wb.active, "Presence", pres_head, pres, {"SATELLITE": 42})
    ws = wb.create_sheet()
    sheet(ws, "Summary", ["Metric", "Count"], summary, {"Metric": 70, "Count": 10})
    ws.append([])
    ws.append(["Notes"])
    for n in [
        "Physical sharing = same table name in >=2 of the 5 projects that land in BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.",
        "maximus_health_dv_dbt writes its own schemas, so it overlaps by NAME only (never a physical collision).",
        "Macro cell: sat / ma_sat = native automate_dv.sat / automate_dv.ma_sat; sat_multi_source / ma_sat_multi_source = project wrappers over AutomateDV.",
        "'N feed' = number of source_model inputs of that project's model for the sat.",
        "Regenerate: python3 BGIL_DBT/validation/tools/analyze_sat_overlap.py",
    ]:
        ws.append([n])
    sheet(wb.create_sheet(), "Cross-LOB (native)", head, cross_lob)
    sheet(wb.create_sheet(), "SameLOB-CrossSource (native)", head, same_lob)
    sheet(wb.create_sheet(), "Shared-table issues", head, conflicts, {"SHARED-TABLE ISSUES": 90})
    sheet(wb.create_sheet(), "All satellites", head, all_rows)
    wb.save(OUT)
    for k, v in summary:
        print(f"{k}: {v}")
    print("macro-mix combos:", dict(mix))
    print("presence rows:", len(pres))
    print("wrote", OUT)


if __name__ == "__main__":
    main()
