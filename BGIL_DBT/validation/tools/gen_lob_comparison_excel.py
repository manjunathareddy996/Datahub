"""
LOB comparison workbook.

Partner (signed off) is our baseline. Everything else is scored against it.

Sheets:
  1. Summary       - how each LOB loads data + the issues it carries
  2. Structure     - which layers each project actually has
  3. Incremental   - how each project scans data
  4. Slow Models   - open bucket to drop timings into after each run
  5. Change Log    - running notes

Run:
    python BGIL_DBT/validation/tools/gen_lob_comparison_excel.py
Output:
    BGIL_DBT/validation/LOB_Structure_Comparison.xlsx
"""
from __future__ import annotations
from pathlib import Path

from openpyxl import Workbook
from openpyxl.styles import Alignment, Border, Font, PatternFill, Side
from openpyxl.utils import get_column_letter

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "validation" / "LOB_Structure_Comparison.xlsx"

HDR_FILL = PatternFill("solid", fgColor="C65911")  # orange
HDR_FONT = Font(name="Calibri", size=11, bold=True, color="FFFFFF")
TITLE_COLOR = "000000"  # black for section titles / side headings
GOOD = PatternFill("solid", fgColor="C6EFCE")
WARN = PatternFill("solid", fgColor="FFEB9C")
BAD = PatternFill("solid", fgColor="FFC7CE")
INFO = PatternFill("solid", fgColor="DDEBF7")
WRAP = Alignment(wrap_text=True, vertical="top")
CENTER = Alignment(wrap_text=True, vertical="center", horizontal="center")
thin = Side(border_style="thin", color="000000")
BORDER = Border(left=thin, right=thin, top=thin, bottom=thin)
BODY = Font(name="Calibri", size=10)


def header(ws, row, cols):
    for i, v in enumerate(cols, start=1):
        c = ws.cell(row=row, column=i, value=v)
        c.fill = HDR_FILL
        c.font = HDR_FONT
        c.alignment = CENTER
        c.border = BORDER


def rows(ws, start, data, widths, color_cols=None, row_h=28):
    color_cols = color_cols or []
    for r_off, row in enumerate(data):
        r = start + r_off
        ws.row_dimensions[r].height = row_h
        for i, val in enumerate(row, start=1):
            c = ws.cell(row=r, column=i, value=val)
            c.alignment = WRAP
            c.font = BODY
            c.border = BORDER
            if i in color_cols:
                s = str(val or "").strip().lower()
                if s in {"yes", "ok", "aligned", "good", "clean", "low"}:
                    c.fill = GOOD
                elif s in {"partial", "slow", "watch", "needs tuning", "medium"}:
                    c.fill = WARN
                elif s in {"no", "missing", "diverged", "risk", "needs rework", "high"}:
                    c.fill = BAD
                elif s in {"baseline"}:
                    c.fill = INFO
    for i, w in enumerate(widths, start=1):
        ws.column_dimensions[get_column_letter(i)].width = w


def summary(wb):
    ws = wb.active
    ws.title = "Summary"
    ws.cell(1, 1, "LOB structure and divergence - summary").font = Font(size=14, bold=True, color=TITLE_COLOR)
    ws.cell(2, 1, "Baseline is opus_partner + maximus_partner (both released for sign-off). Everything else is compared to them.").font = Font(size=10, italic=True)

    # --- Issue catalogue ------------------------------------------------
    ISSUES = {
        1: {
            "title": "Unpivot inside stg2 hides the watermark",
            "severity": "High",
            "why": "In maximus the unpivot sits inside a stg2 view that already does UNION ALL. "
                   "sat_multi_source adds its per-source LOAD_DATETIME filter on top, so every branch "
                   "of the union still runs on each sat execution. Only the final insert into the sat "
                   "is incremental.",
            "lobs": {
                "maximus_partner": "5 sats carry this: sat_lnk_party_role_core, sat_party_digital_identity, "
                                   "sat_party_contact_address_link, sat_party_org_directors, "
                                   "sat_party_provider_capability.",
                "maximus_travel":  "13 augmented sats carry this: sat_aug_claim_document_reminder, "
                                   "sat_aug_claim_exclusion_applied, sat_aug_coverage_sub_cover_element, "
                                   "sat_aug_document_requirement_reminder, sat_aug_fintxn_tax, "
                                   "sat_aug_org_unit_contact, sat_aug_party_identification, "
                                   "sat_aug_party_loyalty_classification, sat_aug_quote_coverage_schedule, "
                                   "sat_aug_quote_premium_head, sat_aug_quote_sum_insured_breakup, "
                                   "sat_aug_risk_travel_cover_terms, sat_aug_risk_travel_rating_input.",
            },
            "fix": "Follow the opus layout: one stg2 per (stg1, sat) with plain automate_dv.stage(), no "
                   "UNION ALL inside. That way the watermark lands on a single table.",
        },
        2: {
            "title": "Satfeed is a UNION ALL view below the sat",
            "severity": "High",
            "why": "In maximus_travel the satfeed itself unions many stg2 feeders. automate_dv.sat / "
                   "ma_sat is incremental, but it sits on top of that view, so the full UNION is "
                   "replayed on every run before the sat filter kicks in. "
                   "maximus_partner is clean here because its satfeeds are rename-only wrappers (no UNION).",
            "lobs": {
                "maximus_travel": "Roughly 125 sats sit above a UNION-ALL satfeed (53 augmented + 72 "
                                  "standard), plus 15 hubs read from the same shape of hubfeed.",
            },
            "fix": "Push LOAD_DATETIME into each ref() inside the satfeed, or skip the satfeed and let "
                   "sat_multi_source read the stg2 feeders directly so its per-source watermark reaches them.",
        },
        3: {
            "title": "Custom macros are ours to maintain",
            "severity": "Low",
            "why": "sat_multi_source / ma_sat_multi_source / stitch_incremental were written in-house. "
                   "They are not part of automate_dv, so upgrades of the package do not touch them.",
            "lobs": {
                "All projects using sat_multi_source": "Macro upgrades are manual. Worth keeping one "
                                                       "shared copy rather than per-project forks.",
            },
            "fix": "Keep a single copy under utils/ and import it from each project.",
        },
        4: {
            "title": "Same sat, different macro / pk / cdk across LOBs",
            "severity": "High",
            "why": "For the same logical satellite, different projects pick different macros "
                   "(ma_sat vs sat_multi_source vs plain sat), different src_pk and sometimes "
                   "different CDK. Rows written by different projects end up with incompatible grain "
                   "even though the physical sat is shared. See the 'Macro consistency' tab for the "
                   "exact mismatches.",
            "lobs": {
                "maximus_travel vs opus_partner / maximus_partner":
                    "Known examples: sat_party_banking (ma_sat with cdk=ACCOUNT_NUMBER_MASKED in "
                    "maximus_travel vs sat_multi_source no-cdk in partner), sat_lnk_policy_party_role "
                    "(cdk mismatch), sat_party_kyc_reference / sat_policy_endorsement / "
                    "sat_policy_coverage_schedule (ma_sat with cdk in maximus_travel vs sat/no-cdk in "
                    "partner), sat_common_contact / sat_party_identification (cdk only on travel side), "
                    "sat_lnk_role_agent / sat_lnk_role_customer (src_pk differs: PARTY_ROLE_HKEY vs "
                    "PARTY_HKEY).",
                "opus_travel":
                    "Missing sats that partner builds (e.g. sat_party_banking has no opus_travel feed) - "
                    "same shared table with partial coverage.",
            },
            "fix": "Agree one grain per logical sat (macro + pk + cdk + hashdiff column) and freeze it. "
                   "Projects that need to narrow the grain should fork the sat, not redefine it on the "
                   "shared table.",
        },
    }
    SEV_FILL = {"High": BAD, "Medium": WARN, "Low": GOOD}

    # Which LOBs are currently flagged in the top table. Issue #3 is informational
    # (macro ownership) and stays in the Issue cards below but is not shown as a chip
    # on each LOB row. maximus_partner used to carry #1 but is being reworked to drop
    # the custom macro on those sats, so no chip in the top table today.
    #
    # Chip semantics:
    #   list of ids -> project runs on our macro stack and these issues apply
    #   []          -> project runs on our macro stack, no open issues (blank chip)
    #   None        -> project does not run on our macro stack (chip renders as "-")
    LOB_ISSUES = {
        "maximus_partner":  [],
        "opus_partner":     [],
        "opus_travel":      [4],
        "maximus_travel":   [1, 2, 4],
        "maximus_health":   None,
        "opus_health":      None,
        "Other LOBs":       None,
    }

    # --- LOB table ------------------------------------------------------
    header(ws, 4, ["LOB", "Issues", "Load lineage (left -> right)", "Incremental", "Reuses our macros", "Verdict"])
    data = [
        ["opus_partner",
         "Hub branch: source -> stg_partner__* (stg1) -> stg2_hub_<stg1>__<entity> (automate_dv.stage, 1:1 per stg1, no UNION) -> hub (automate_dv.hub).\n"
         "Sat branch: source -> stg_partner__* (stg1) -> stg2_sat_<stg1>__<sat> (automate_dv.stage, 1:1 per stg1, no UNION) -> sat (sat_multi_source / automate_dv.sat).\n"
         "Stitched branch: source -> stg_partner__* -> stitched_* (stitch_incremental).",
         "Yes, per-source watermark",      "All",  "Baseline"],
        ["maximus_partner",
         "Hub branch: source -> stg_partner__* (stg1) -> stg2_mp__* (automate_dv.stage) OR stg2_mp_up__* (inline unpivot view, UNION ALL per role) -> "
         "hubfeed_* (view, UNION ALL across the stg2 feeders) -> hub (automate_dv.hub).\n"
         "Sat branch: source -> stg_partner__* (stg1) -> stg2_mp__* / stg2_mp_up__* -> "
         "satfeed_mp_sat__* (rename-only view, HASHDIFF alias) -> sat (sat_multi_source / automate_dv.sat).",
         "Yes, per-source watermark",      "All",  "Baseline"],
        ["opus_travel",
         "Hub branch: source -> stg_travel__* (stg1) -> stg2_hub_<stg1>__<entity> (automate_dv.stage, 1:1 per stg1, no UNION) -> hub (automate_dv.hub).\n"
         "Sat branch: source -> stg_travel__* (stg1) -> stg2_<entity>_<stg1>__<suffix> (automate_dv.stage, 1:1 per stg1, no UNION) -> sat (sat_multi_source / automate_dv.sat).\n"
         "Stitched branch: source -> stg_travel__* -> stitched_* (stitch_incremental).",
         "Yes, same macros",               "All",  "Good"],
        ["maximus_travel",
         "Hub branch: source -> stg_mt__* (stg1) -> resolved_mt__* (child-key resolver view) -> "
         "stg2_mt_* / stg2_hub_mt_* (automate_dv.stage) -> hubfeed_mt_* (view, UNION ALL across stg2 feeders) -> hub (automate_dv.hub).\n"
         "Sat branch: source -> stg_mt__* (stg1) -> resolved_mt__* -> "
         "up_mt__* (inline unpivot view, UNION ALL per child-key branch) -> stg2_mt_aug__* / stg2_mt_up__* (automate_dv.stage) -> "
         "satfeed_mt_* (view, UNION ALL across stg2 feeders) -> sat (automate_dv.sat / ma_sat).",
         "Partial - UNION replays",        "All",
         "Needs rework for incremental load, at present built on current view approach"],
        ["maximus_health",
         "Hub branch: source -> staging stg__* -> stage/* -> unpivot/* -> resolvers/* -> augmented/* (aug_* with inline UNION ALL feeders) -> vault/hubs (incremental, UNION ALL, no watermark).\n"
         "Sat branch: source -> staging stg__* -> stage/* -> unpivot/* -> resolvers/* -> augmented/* -> vault/satellites (incremental, UNION ALL, no watermark).\n"
         "Side layers: hopviews, quarantine, reject_log, reference_decode, tests.",
         "Partial, no per-source filter",  "None", "Diverged"],
        ["opus_health",
         "Same shape as maximus_health.\n"
         "Hub branch: source -> staging -> stage -> unpivot -> augmented -> vault/hubs (UNION ALL, no watermark).\n"
         "Sat branch: source -> staging -> stage -> unpivot -> augmented -> vault/satellites (UNION ALL, no watermark).",
         "Partial",                        "None", "Diverged"],
        ["Other LOBs",
         "Hub branch: source -> stg -> hub (plain UNION ALL across sources).\n"
         "Sat branch: source -> stg -> sat (plain UNION ALL across sources).\n"
         "No stg2 / satfeed / custom macro layer.",
         "No, full scan every run",        "None", "Risk"],
    ]

    def top_sev(ids):
        # Only tint when something is actually broken. Low (#3) is informational.
        if not ids:
            return None
        for s in ("High", "Medium"):
            if any(ISSUES[i]["severity"] == s for i in ids):
                return s
        return None

    def chip_text(ids):
        if ids is None:
            return "-"
        if not ids:
            return ""
        return "  ".join(f"#{i}" for i in ids)

    start_row = 5
    for r_off, (lob, approach, inc, macros, verdict) in enumerate(data):
        r = start_row + r_off
        # multi-branch lineage wraps across 3-5 lines, so grow the row
        ws.row_dimensions[r].height = 130
        issues = LOB_ISSUES.get(lob, [])
        active_ids = issues if isinstance(issues, list) else []
        sev = top_sev(active_ids)

        c = ws.cell(row=r, column=1, value=lob)
        c.font = Font(bold=True, size=10)
        c.alignment = WRAP
        c.border = BORDER
        if sev:
            c.fill = SEV_FILL[sev]

        cx = ws.cell(row=r, column=2, value=chip_text(issues))
        cx.alignment = CENTER
        cx.font = Font(bold=True, size=10)
        cx.border = BORDER
        if sev:
            cx.fill = SEV_FILL[sev]

        for col_i, val in enumerate([approach, inc, macros, verdict], start=3):
            cell = ws.cell(row=r, column=col_i, value=val)
            cell.alignment = WRAP
            cell.font = BODY
            cell.border = BORDER
            if col_i == 6:
                v = str(val).strip().lower()
                if v == "baseline":
                    cell.fill = INFO
                elif v.startswith("needs rework") or v in {"diverged", "risk"}:
                    cell.fill = BAD
                elif v in {"aligned", "good"}:
                    cell.fill = GOOD

    for i, w in enumerate([20, 10, 72, 24, 16, 20], start=1):
        ws.column_dimensions[get_column_letter(i)].width = w

    # --- Issue cards ----------------------------------------------------
    cur = start_row + len(data) + 2
    ws.cell(row=cur, column=1,
            value="What the chips mean").font = Font(bold=True, color=TITLE_COLOR, size=12)
    cur += 1
    ws.cell(row=cur, column=1,
            value="Each row below is one issue as it shows up in one LOB. Pick the LOB in the table above, "
                  "find the matching chip, and read the row here.").font = Font(size=9, italic=True, color="7F7F7F")
    cur += 2

    header(ws, cur, ["#", "Severity", "What it is", "Why it happens", "LOB", "Where it hits", "Suggested fix"])
    cur += 1
    for i in sorted(ISSUES):
        meta = ISSUES[i]
        sev = meta["severity"]
        tint = SEV_FILL[sev]
        for lob, scope in meta["lobs"].items():
            ws.row_dimensions[cur].height = 70
            row_vals = [f"#{i}", sev, meta["title"], meta["why"], lob, scope, meta["fix"]]
            for col, val in enumerate(row_vals, start=1):
                cell = ws.cell(row=cur, column=col, value=val)
                cell.alignment = WRAP
                cell.font = BODY
                cell.border = BORDER
                if col in (1, 2, 5):
                    cell.fill = tint
                    if col in (1, 2):
                        cell.alignment = CENTER
                        cell.font = Font(bold=True, size=10)
            cur += 1

    for i, w in enumerate([5, 10, 36, 56, 24, 50, 44], start=1):
        if ws.column_dimensions[get_column_letter(i)].width < w:
            ws.column_dimensions[get_column_letter(i)].width = w

    ws.freeze_panes = "A5"


def structure(wb):
    ws = wb.create_sheet("Structure")
    ws.cell(1, 1, "What each project actually has on disk").font = Font(bold=True, color=TITLE_COLOR, size=12)
    ws.cell(2, 1, "'Yes' means the folder/layer is present. Note column flags anything worth calling out.").font = Font(size=9, italic=True, color="7F7F7F")

    header(ws, 4, ["Layer", "maximus_partner", "opus_partner", "opus_travel", "maximus_travel", "maximus_health", "Note"])
    data = [
        ["staging (stg1)",                                      "Yes", "Yes", "Yes", "Yes", "Yes", "same across the board"],
        ["stg2",                                                "Yes", "Yes", "Yes", "Yes", "No",  "health swaps this out for stage + unpivot"],
        ["unpivot layer",                                       "Yes", "No",  "No",  "No",  "Yes", "maximus_partner keeps it inside raw_vault; health lifts it to the top"],
        ["hubs",                                                "Yes", "Yes", "Yes", "Yes", "Yes", "health just uses a different folder path"],
        ["links",                                               "Yes", "Yes", "No",  "Yes", "Yes", "opus_travel does not have this yet"],
        ["satellites",                                          "Yes", "Yes", "Yes", "Yes", "Yes", "aligned"],
        ["hubfeed",                                             "Yes", "No",  "No",  "No",  "Yes", "health calls it hub_feeds; opus skips it"],
        ["satfeed",                                             "Yes", "No",  "No",  "No",  "No",  "maximus_partner only - rename-only wrapper"],
        ["stitched",                                            "No",  "Yes", "Yes", "No",  "No",  "opus-only pattern driven by stitch_incremental"],
        ["augmented (stg + sat)",                               "Yes", "Yes", "Yes", "Yes", "Yes", "health keeps it as a flat folder"],
        ["hopviews / quarantine / reject / resolvers / tests",  "No",  "No",  "No",  "No",  "Yes", "health has these as extra operational layers"],
    ]
    rows(ws, 5, data, widths=[32, 18, 16, 16, 18, 18, 50], color_cols=[2, 3, 4, 5, 6], row_h=22)
    ws.freeze_panes = "B5"


def incremental(wb):
    ws = wb.create_sheet("Incremental")
    ws.cell(1, 1, "How each project decides what to re-read").font = Font(bold=True, color=TITLE_COLOR, size=12)
    ws.cell(2, 1, "Short version: partner family uses our macros with a watermark; health uses plain UNION ALL with no filter.").font = Font(size=9, italic=True, color="7F7F7F")

    header(ws, 4, ["LOB", "What it does", "Why it's nice", "What hurts"])
    data = [
        ["maximus_partner",
         "sat_multi_source / ma_sat_multi_source with MAX(DBT_RUN_TS) per source",
         "True incremental, already proven in sign-off",
         "The macro is ours, so maintenance stays with us"],
        ["opus_partner",
         "Same macros as maximus_partner",
         "Reuses the sign-off path with less layer overhead",
         "No hubfeed / satfeed buffer, so lineage is a bit shorter"],
        ["opus_travel",
         "Same macros, one stg2 per stg1",
         "Watermark pushes cleanly to a single table",
         "A few sats / hubs are still slow (see Slow Models)"],
        ["maximus_travel",
         "Same macros, but with up_mt UNIONs below and satfeed UNIONs above",
         "Follows partner's shape overall",
         "UNIONs replay on every run (see issues #1 and #2)"],
        ["maximus_health / opus_health",
         "Plain UNION ALL in generated SQL; incremental set on sats but no watermark",
         "No macro code to maintain",
         "Every feeder is re-scanned each run"],
        ["Other LOBs",
         "Plain UNION ALL, no macros",
         "Simplest to read",
         "Full scan every time"],
    ]
    rows(ws, 5, data, widths=[22, 50, 36, 46], row_h=52)
    ws.freeze_panes = "A5"

    # Macro mini-matrix
    hdr_row = 5 + len(data) + 2
    ws.cell(row=hdr_row, column=1, value="Which custom macros each project uses").font = Font(bold=True, color=TITLE_COLOR)
    header(ws, hdr_row + 1, ["Macro", "maximus_partner", "opus_partner", "opus_travel", "maximus_travel", "Health"])
    macros = [
        ["sat_multi_source",      "Yes", "Yes", "Yes", "Yes", "No"],
        ["ma_sat_multi_source",   "Yes", "Yes", "Yes", "Yes", "No"],
        ["stitch_incremental",    "Yes", "Yes", "Yes", "Yes", "No"],
        ["watermark",             "Yes", "Yes", "Yes", "Yes", "No"],
    ]
    rows(ws, hdr_row + 2, macros, widths=[22, 18, 16, 16, 18, 14], color_cols=[2, 3, 4, 5, 6], row_h=20)


def macro_consistency(wb):
    ws = wb.create_sheet("Macro consistency")
    ws.cell(1, 1, "Same sat, different definition across projects (issue #4)").font = Font(bold=True, color=TITLE_COLOR, size=12)
    ws.cell(2, 1, "Each row is one shared satellite. Columns show how each project defines macro / pk / cdk / hashdiff. "
                  "Highlighted cells are the mismatches to resolve.").font = Font(size=9, italic=True, color="7F7F7F")

    def _write_block(title, start, headers, data, widths, highlight_cols=None):
        highlight_cols = highlight_cols or []
        ws.cell(row=start, column=1, value=title).font = Font(bold=True, color=TITLE_COLOR, size=11)
        header(ws, start + 1, headers)
        for r_off, row in enumerate(data):
            r = start + 2 + r_off
            ws.row_dimensions[r].height = 44
            for i, val in enumerate(row, start=1):
                cell = ws.cell(row=r, column=i, value=val)
                cell.alignment = WRAP
                cell.font = BODY
                cell.border = BORDER
                if i in highlight_cols:
                    cell.fill = BAD
        for i, w in enumerate(widths, start=1):
            if ws.column_dimensions[get_column_letter(i)].width < w:
                ws.column_dimensions[get_column_letter(i)].width = w
        return start + 2 + len(data) + 2

    cur = 4
    # Block 1: sat_party_banking (image 1 + 2 - same content)
    cur = _write_block(
        "sat_party_banking - macro + grain differs",
        cur,
        ["Sat", "opus_travel", "maximus_travel", "opus_partner", "maximus_partner"],
        [
            ["sat_party_banking",
             "-",
             "ma_sat, pk=PARTY_HKEY, cdk=ACCOUNT_NUMBER_MASKED, hd=HASHDIFF",
             "sat_multi_source, pk=PARTY_HKEY, no cdk, hd=HASHDIFF",
             "sat_multi_source, pk=PARTY_HKEY, no cdk, hd=HASHDIFF_PARTY_BANKING (aliased to HASHDIFF)"],
        ],
        widths=[22, 10, 44, 36, 50],
        highlight_cols=[3, 5],
    )

    # Block 2: maximus_travel vs opus_partner grain mismatches (image 3)
    cur = _write_block(
        "Multiple sats - maximus_travel adds ma_sat + cdk, partner stays on sat / sat_multi_source",
        cur,
        ["Sat", "maximus_travel", "opus_partner"],
        [
            ["sat_lnk_policy_party_role",
             "ma_sat, pk=POLICY_PARTY_HKEY, cdk=PARTY_ROLE_TYPE,ROLE_SEQUENCE, hd=HASHDIFF",
             "ma_sat, pk=POLICY_PARTY_HKEY, cdk=ROLE_SEQUENCE, hd=HASHDIFF"],
            ["sat_party_kyc_reference",
             "ma_sat, pk=PARTY_HKEY, cdk=KYC_REFERENCE_TYPE, hd=HASHDIFF",
             "sat_multi_source (no cdk), pk=PARTY_HKEY, hd=HASHDIFF"],
            ["sat_policy_endorsement",
             "ma_sat, pk=POLICY_HKEY, cdk=ENDORSEMENT_NUMBER, hd=HASHDIFF",
             "sat, pk=POLICY_HKEY, no cdk, hd=HASHDIFF"],
            ["sat_policy_coverage_schedule",
             "ma_sat, pk=POLICY_HKEY, cdk=COVERAGE_REFERENCE,COVERAGE_SEQUENCE, hd=HASHDIFF",
             "sat, pk=POLICY_HKEY, no cdk, hd=HASHDIFF"],
        ],
        widths=[32, 54, 46],
        highlight_cols=[2, 3],
    )

    # Block 3: sat_common_contact / sat_party_identification (image 4)
    cur = _write_block(
        "sat_common_contact / sat_party_identification - cdk only on travel side",
        cur,
        ["Sat", "maximus_travel", "opus_partner"],
        [
            ["sat_common_contact",
             "ma_sat, cdk=CONTACT_POINT_TYPE,CONTACT_PRIORITY_ORDER",
             "sat_multi_source, no cdk"],
            ["sat_party_identification",
             "ma_sat, cdk=IDENTIFICATION_TYPE_CODE",
             "sat_multi_source, no cdk"],
        ],
        widths=[32, 54, 36],
        highlight_cols=[2, 3],
    )

    # Block 4: src_pk differs (image 5)
    _write_block(
        "sat_lnk_role_agent / sat_lnk_role_customer - src_pk differs",
        cur,
        ["Satellite", "Travel declares", "Partner declares"],
        [
            ["sat_lnk_role_agent",    "src_pk: 'PARTY_ROLE_HKEY'", "src_pk: 'PARTY_HKEY'"],
            ["sat_lnk_role_customer", "src_pk: 'PARTY_ROLE_HKEY'", "src_pk: 'PARTY_HKEY'"],
        ],
        widths=[26, 30, 30],
        highlight_cols=[2, 3],
    )

    ws.freeze_panes = "A4"


def slow_models(wb):
    ws = wb.create_sheet("Slow Models")
    ws.cell(1, 1, "Slow models to look at after each run").font = Font(bold=True, color=TITLE_COLOR, size=12)
    ws.cell(2, 1, "Drop timings here from run_results.json (or screenshots). One row per model.").font = Font(size=9, italic=True, color="7F7F7F")

    header(ws, 4, ["LOB", "Model / query", "Type", "Duration", "Warehouse", "Why we think it's slow", "What to try"])
    data = [
        ["maximus_travel",
         "hub_location (query 01c834a8-0002-fe32-0006-8602570dd046, hash 4f6831e0d8c5093aea23eba25a69c6a8)",
         "hub",
         "1h 06m 04s",
         "BAGIC_DPM_MAXI_RAW_WH (X-Small)",
         "hub_location sits above a hubfeed_mt_* view that UNION ALLs many stg2 feeders (issue #2). The whole UNION replays on every run and X-Small warehouse amplifies it.",
         "Apply the issue #2 fix for hub_location: push LOAD_DATETIME watermark into each ref() inside hubfeed_mt_location, or let the hub read the stg2 feeders directly."],
    ]
    rows(ws, 5, data, widths=[22, 40, 10, 14, 32, 44, 44], row_h=46)
    ws.freeze_panes = "A5"


def changelog(wb):
    ws = wb.create_sheet("Change Log")
    ws.cell(1, 1, "Rolling notes").font = Font(bold=True, color=TITLE_COLOR, size=12)
    ws.cell(2, 1, "New points go at the bottom. Keep each entry short.").font = Font(size=9, italic=True, color="7F7F7F")

    header(ws, 4, ["Date", "Topic", "What we noticed", "What we'll do"])
    rows(
        ws,
        5,
        [
            ["2026-11-09", "Initial pass", "First version of this workbook.", "No action."],
            ["2026-11-09",
             "Unpivot vs sat watermark",
             "maximus_partner (5 sats) and maximus_travel (13 augmented sats) have UNION ALLs inside "
             "their stg2 unpivot. The watermark cannot look through them, so each branch is rebuilt on "
             "every sat run. opus_partner and opus_travel are clean - they use one stg2 per stg1.",
             "Split the unpivot into one stg2 per branch."],
            ["2026-11-09",
             "Satfeed UNION ALL",
             "maximus_partner satfeeds are rename-only, so they are safe. maximus_travel satfeeds "
             "actually UNION ALL many stg2 feeders inside the view, which re-runs on every sat execution. "
             "Scope today: 53 augmented satfeeds + 72 standard satfeeds + 15 hubfeeds.",
             "Push watermark into each satfeed ref() or drop the UNION."],
            ["2026-11-09",
             "Macro inconsistency across LOBs",
             "Same logical sat is being built with different macro / pk / cdk in different projects. "
             "Examples: sat_party_banking uses ma_sat + cdk in maximus_travel but sat_multi_source "
             "no-cdk in partner; sat_lnk_role_agent / sat_lnk_role_customer declare different src_pk "
             "(PARTY_ROLE_HKEY vs PARTY_HKEY). Full list on the Macro consistency tab.",
             "Freeze one grain per shared sat; fork if a project needs its own."],
        ],
        widths=[14, 30, 70, 50],
        row_h=56,
    )
    ws.freeze_panes = "A5"


def main():
    wb = Workbook()
    summary(wb)
    structure(wb)
    incremental(wb)
    macro_consistency(wb)
    slow_models(wb)
    changelog(wb)
    for ws in wb.worksheets:
        ws.sheet_view.showGridLines = False
    OUT.parent.mkdir(parents=True, exist_ok=True)
    wb.save(OUT)
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()
