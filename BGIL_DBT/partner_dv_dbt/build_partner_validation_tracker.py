"""Generate partner_dv_validation_tracker.xlsx for partner_dv_dbt (OPUS source only).

One sheet 'Standard' (+ 'Augmented'). Rows are grouped by validation PHASE,
ordered easy -> tough, using section-header rows (not a column).

Difficulty model (OPUS-only, so no cross-system collisions):
  Phase 1  EASY    single-source sat()          - one stg2, no stitch
  Phase 2  MEDIUM  sat_multi_source()           - many stg2 fan-in, no stitch
  Phase 3  TOUGH   stitch-backed sat()          - stg2 + stitch layer to validate
  Phase 4  MULTI-ACTIVE ma_sat()/ma_sat_multi   - multi-active grain (+/- stitch)

Columns:
  # | Satellite | Grain | Macro | Stage_2 (stg2) | Stitch | Stage_1 (stg) | Validation remarks

Stage_1, Stitch and Validation remarks are left for the developer to fill where
they cannot be derived automatically. Stage_2 is the stg2 source_model(s).
"""
import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side

HEADERS = ["#", "Model", "Source", "Grain", "Stage_2 (stg2 source)",
           "Stitch", "Stage_1 (stg source)", "Status", "Validation remarks"]
NCOLS = len(HEADERS)

# (satellite, grain, macro, stage2, stitch, stage1, status)
# stage2 = the stg2 source_model feeding the sat; stitch = stitch model or '-'
standard_rows = {
    "PHASE 0 - STRUCTURAL (hubs & links)": [
        ("hub_agreement", "HUB_AGREEMENT", "hub()", "-", "-", "", "pending"),
        ("hub_claim", "HUB_CLAIM", "hub()", "-", "-", "", "pending"),
        ("hub_distribution_channel", "HUB_DISTRIBUTION_CHANNEL", "hub()", "-", "-", "", "pending"),
        ("hub_location", "HUB_LOCATION", "hub()", "-", "-", "", "pending"),
        ("hub_party", "HUB_PARTY", "hub()", "-", "-", "", "pending"),
        ("hub_policy", "HUB_POLICY", "hub()", "-", "-", "", "pending"),
        ("hub_product", "HUB_PRODUCT", "hub()", "-", "-", "", "pending"),
        ("hub_risk_object", "HUB_RISK_OBJECT", "hub()", "-", "-", "", "pending"),
        ("lnk_claim_party", "LNK_CLAIM_PARTY", "link()", "-", "-", "", "pending"),
        ("lnk_party_location", "LNK_PARTY_LOCATION", "link()", "-", "-", "", "pending"),
        ("lnk_policy_party", "LNK_POLICY_PARTY", "link()", "-", "-", "", "pending"),
    ],
    "PHASE 1 - EASY (single-source sat, no stitch)": [
        ("sat_partner_agreement_commercial_terms", "HUB_AGREEMENT", "sat()", "stg2_sat_bjaz_intermediary__agreement_commercial_terms", "-", "", "pending"),
        ("sat_partner_agreement_definition", "HUB_AGREEMENT", "sat()", "stg2_sat_bjaz_intermediary__agreement_definition", "-", "", "pending"),
        ("sat_partner_party_group_household", "HUB_PARTY", "sat()", "stg2_sat_azbj_partner_extn__party_group_household", "-", "", "pending"),
        ("sat_partner_party_kyc_reference", "HUB_PARTY", "sat()", "stg2_sat_cp_partners__party_kyc_reference", "-", "", "pending"),
        ("sat_partner_policy_coverage_schedule", "HUB_POLICY", "sat()", "stg2_sat_ba_hcp_dt_mem__policy_coverage_schedule", "-", "", "pending"),
        ("sat_partner_policy_endorsement", "HUB_POLICY", "sat()", "stg2_sat_bjaz_hm_member_dtls__policy_endorsement", "-", "", "pending"),
        ("sat_partner_provider_tariff", "HUB_PARTY", "sat()", "stg2_sat_bjaz_hm_hospital_master__provider_tariff", "-", "", "pending"),
        ("sat_partner_lnk_role_agent", "HUB_PARTY (role:agent)", "sat()", "stg2_rolesat_bjaz_intermediary__lnk_role_agent", "-", "", "pending"),
        ("sat_partner_lnk_role_customer", "HUB_PARTY (role:customer)", "sat()", "stg2_rolesat_clm_interested_parties__lnk_role_customer", "-", "", "pending"),
        ("sat_partner_lnk_role_surveyor", "HUB_PARTY (role:surveyor)", "sat()", "stg2_rolesat_bjaz_clm_supp_extn__lnk_role_surveyor", "-", "", "pending"),
    ],
    "PHASE 2 - MEDIUM (multi-source fan-in, no stitch)": [
        ("sat_partner_common_contact", "HUB_PARTY", "sat_multi_source()", "9x stg2_sat_*__common_contact", "-", "", "pending"),
        ("sat_partner_party_banking", "HUB_PARTY", "sat_multi_source()", "4x stg2_sat_*__party_banking", "-", "", "pending"),
        ("sat_partner_party_group_census", "HUB_PARTY", "sat_multi_source()", "10x stg2_sat_*__party_group_census", "-", "", "pending"),
        ("sat_partner_party_identification", "HUB_PARTY", "sat_multi_source()", "11x stg2_sat_*__party_identification", "-", "", "pending"),
        ("sat_partner_party_vehicle_prior_insurance", "HUB_PARTY", "sat_multi_source()", "8x stg2_sat_*__party_vehicle_prior_insurance", "-", "", "pending"),
        ("sat_partner_policy_certificate", "HUB_POLICY", "sat_multi_source()", "3x stg2_sat_*__policy_certificate", "-", "", "pending"),
        ("sat_partner_policy_premium_head", "HUB_POLICY", "sat_multi_source()", "2x stg2_sat_*__policy_premium_head", "-", "", "pending"),
        ("sat_partner_lnk_role_nominee_beneficiary", "HUB_PARTY (role:nominee_beneficiary)", "sat_multi_source()", "many stg2_rolesat_*__lnk_role_nominee_beneficiary", "-", "", "pending"),
        ("sat_partner_lnk_role_provider", "HUB_PARTY (role:provider)", "sat_multi_source()", "stg2_rolesat_*__lnk_role_provider", "-", "", "pending"),
    ],
    "PHASE 3 - TOUGH (stitch-backed sat)": [
        ("sat_partner_common_address", "HUB_LOCATION", "sat()", "stg2_common_address", "stitch_common_address", "", "pending"),
        ("sat_partner_common_admin_geography", "HUB_LOCATION", "sat()", "stg2_shared__common_admin_geography_common_geo", "stitch_shared__common_admin_geography_common_geo", "", "pending"),
        ("sat_partner_common_geo", "HUB_LOCATION", "sat()", "stg2_shared__common_admin_geography_common_geo", "stitch_shared__common_admin_geography_common_geo", "", "pending"),
        ("sat_partner_common_classification", "HUB_PARTY", "sat()", "stg2_common_classification", "stitch_common_classification", "", "pending"),
        ("sat_partner_common_communication_preference", "HUB_PARTY", "sat()", "stg2_shared__common_communication_preference_party_employment", "stitch_shared__common_communication_preference_party_employment", "", "pending"),
        ("sat_partner_party_employment", "HUB_PARTY", "sat()", "stg2_shared__common_communication_preference_party_employment", "stitch_shared__common_communication_preference_party_employment", "", "pending"),
        ("sat_partner_party_claim_history", "HUB_PARTY", "sat()", "stg2_party_claim_history", "stitch_party_claim_history", "", "pending"),
        ("sat_partner_party_health_profile", "HUB_PARTY", "sat()", "stg2_party_health_profile", "stitch_party_health_profile", "", "pending"),
        ("sat_partner_party_identity", "HUB_PARTY", "sat()", "stg2_party_identity", "stitch_party_identity", "", "pending"),
        ("sat_partner_party_individual_demographics", "HUB_PARTY", "sat()", "stg2_party_individual_demographics", "stitch_party_individual_demographics", "", "pending"),
        ("sat_partner_party_organisation_profile", "HUB_PARTY", "sat()", "stg2_party_organisation_profile", "stitch_party_organisation_profile", "", "pending"),
        ("sat_partner_policy_bonus_tracking", "HUB_POLICY", "sat()", "stg2_policy_bonus_tracking", "stitch_policy_bonus_tracking", "", "pending"),
        ("sat_partner_policy_header", "HUB_POLICY", "sat()", "stg2_policy_header", "stitch_policy_header", "", "pending"),
        ("sat_partner_product_definition", "HUB_PRODUCT", "sat()", "stg2_product_definition", "stitch_product_definition", "", "pending"),
        ("sat_partner_provider_banking", "HUB_PARTY", "sat()", "stg2_provider_banking", "stitch_provider_banking", "", "pending"),
    ],
    "PHASE 4 - MULTI-ACTIVE (ma_sat, per-key grain)": [
        ("sat_partner_lnk_claim_party_role", "LNK_CLAIM_PARTY", "ma_sat()", "stg2_clmparty_clm_interested_parties", "-", "", "pending"),
        ("sat_partner_lnk_policy_party_role", "LNK_POLICY_PARTY", "ma_sat()", "stg2_pprole_ocp_interested_parties", "-", "", "pending"),
        ("sat_partner_party_contact_address_link", "HUB_PARTY", "ma_sat()", "stg2_pcal_bjaz_cp_address_link", "-", "", "pending"),
    ],
}

# ---- AUGMENTED sheet (OPUS augmented sats, "unconfirmed") --------------------
augmented_rows = {
    "PHASE 1 - EASY (single-source aug sat)": [
        ("sat_partner_aug_affinity_membership", "HUB_PARTY", "sat()", "(per model)", "-", "", "pending"),
        ("sat_partner_aug_agreement", "HUB_AGREEMENT", "sat()", "(per model)", "-", "", "pending"),
        ("sat_partner_aug_lnk_role_agent", "HUB_PARTY (role:agent)", "sat()", "(per model)", "-", "", "pending"),
        ("sat_partner_aug_lnk_role_customer", "HUB_PARTY (role:customer)", "sat()", "(per model)", "-", "", "pending"),
        ("sat_partner_aug_lnk_role_surveyor", "HUB_PARTY (role:surveyor)", "sat()", "(per model)", "-", "", "pending"),
        ("sat_partner_aug_lawyer_advocate_role", "HUB_PARTY", "sat()", "(per model)", "-", "", "pending"),
    ],
    "PHASE 2 - MEDIUM (multi-source aug sat)": [
        ("sat_partner_aug_channel", "HUB_DISTRIBUTION_CHANNEL", "sat_multi_source()", "(per model)", "-", "", "pending"),
        ("sat_partner_aug_lnk_role_provider", "HUB_PARTY (role:provider)", "sat_multi_source()", "(per model)", "-", "", "pending"),
        ("sat_partner_aug_location", "HUB_LOCATION", "sat_multi_source()", "(per model)", "-", "", "pending"),
        ("sat_partner_aug_party", "HUB_PARTY", "sat_multi_source()", "(per model)", "-", "", "pending"),
    ],
    "PHASE 4 - MULTI-ACTIVE (ma_sat aug)": [
        ("sat_partner_aug_policy", "HUB_POLICY", "ma_sat_multi_source()", "(per model)", "-", "", "pending"),
    ],
}

# ---- write workbook ----------------------------------------------------------
wb = openpyxl.Workbook()

hdr_fill = PatternFill("solid", fgColor="305496")
hdr_font = Font(bold=True, color="FFFFFF")
sec_fill = PatternFill("solid", fgColor="1F3864")
sec_font = Font(bold=True, color="FFFFFF", size=11)
green = PatternFill("solid", fgColor="C6EFCE")
yellow = PatternFill("solid", fgColor="FFEB9C")
thin = Side(style="thin", color="D9D9D9")
border = Border(left=thin, right=thin, top=thin, bottom=thin)


WIDTHS = [5, 44, 8, 34, 60, 44, 26, 10, 40]


def _row_height(row_values):
    """Estimate row height so wrapped text is fully visible (no hidden values)."""
    max_lines = 1
    for val, width in zip(row_values, WIDTHS):
        text = str(val) if val is not None else ""
        # count explicit lines plus wrapping across the column width
        for segment in text.split("\n"):
            # ~1.1 chars per width unit fits before wrapping
            lines = max(1, -(-len(segment) // max(1, int(width * 1.1))))
            max_lines = max(max_lines, lines)
    return 15 * max_lines + 3


def style_sheet(ws, sections, source="OPUS"):
    ws.append(HEADERS)
    for c in ws[1]:
        c.fill = hdr_fill
        c.font = hdr_font
        c.alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)
        c.border = border
    n = 0
    for title, rows in sections.items():
        r = ws.max_row + 1
        ws.append([title] + [""] * (NCOLS - 1))
        ws.merge_cells(start_row=r, start_column=1, end_row=r, end_column=NCOLS)
        sc = ws.cell(row=r, column=1)
        sc.fill = sec_fill
        sc.font = sec_font
        sc.alignment = Alignment(horizontal="left", vertical="center")
        for model, grain, macro, stage2, stitch, stage1, status in rows:
            n += 1
            # Validation remarks intentionally left EMPTY for the developer
            values = [n, model, source, grain, stage2, stitch, stage1, status, ""]
            ws.append(values)
            row_cells = ws[ws.max_row]
            for c in row_cells:
                c.border = border
                c.alignment = Alignment(vertical="top", wrap_text=True)
            status_cell = row_cells[7]
            status_cell.fill = green if str(status_cell.value).lower() == "done" else yellow
            ws.row_dimensions[ws.max_row].height = _row_height(values)
    for i, w in enumerate(WIDTHS, start=1):
        ws.column_dimensions[openpyxl.utils.get_column_letter(i)].width = w
    ws.freeze_panes = "A2"


# ---- MAXIMUS models (parsed from the maximus_partner_dv_dbt project) --------
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
MAX_ROOT = os.path.join(HERE, "..", "maximus_partner_dv_dbt", "models", "automate_dv")

PK_TO_GRAIN = {
    "PARTY_HKEY": "HUB_PARTY", "LOCATION_HKEY": "HUB_LOCATION",
    "POLICY_HKEY": "HUB_POLICY", "PRODUCT_HKEY": "HUB_PRODUCT",
    "DOCUMENT_HKEY": "HUB_DOCUMENT", "ORG_UNIT_HKEY": "HUB_ORG_UNIT",
    "DISTRIBUTION_CHANNEL_HKEY": "HUB_DISTRIBUTION_CHANNEL",
    "PAYMENT_INSTRUMENT_HKEY": "HUB_PAYMENT_INSTRUMENT",
    "FINANCIAL_ACCOUNT_HKEY": "HUB_FINANCIAL_ACCOUNT",
    "PARTY_ROLE_HKEY": "LNK_PARTY_ROLE",
    "PARTY_LOCATION_HKEY": "LNK_PARTY_LOCATION",
    "PARTY_RELATIONSHIP_HKEY": "LNK_PARTY_RELATIONSHIP",
    "CLAIM_PARTY_HKEY": "LNK_CLAIM_PARTY",
    "POLICY_PARTY_HKEY": "LNK_POLICY_PARTY",
}


def _source_models(path):
    """Return the list of source_model entries declared in a dbt model file."""
    txt = open(path, encoding="utf-8").read()
    # single: source_model: 'x'   OR list: source_model:\n  - 'a'\n  - 'b'
    m = re.search(r"source_model:\s*'([^']+)'", txt)
    if m:
        return [m.group(1)]
    block = re.search(r"source_model:\s*\n((?:\s*-\s*'[^']+'\s*\n?)+)", txt)
    if block:
        return re.findall(r"-\s*'([^']+)'", block.group(1))
    return []


def _build_lineage(staging_dir, stitched_dir=None):
    """Map stg2_model -> {'stitch': name|None, 'stg1': [stg_ models]}.

    stg2 source_model may point at a stitch_* model; in that case the real
    stg_* sources come from the 'model': 'stg_...' entries inside the stitch file.
    """
    stitch_stg1 = {}
    if stitched_dir and os.path.isdir(stitched_dir):
        for fn in os.listdir(stitched_dir):
            if not fn.endswith(".sql"):
                continue
            txt = open(os.path.join(stitched_dir, fn), encoding="utf-8").read()
            stg1 = re.findall(r"'model':\s*'(stg_[^']+)'", txt)
            stitch_stg1[fn[:-4]] = sorted(set(stg1))
    lineage = {}
    if os.path.isdir(staging_dir):
        for fn in os.listdir(staging_dir):
            if not fn.endswith(".sql") or not fn.startswith("stg2"):
                continue
            srcs = _source_models(os.path.join(staging_dir, fn))
            stitch = None
            stg1 = []
            for s in srcs:
                if s.startswith("stitch"):
                    stitch = s
                    stg1.extend(stitch_stg1.get(s, []))
                elif s.startswith("stg_"):
                    stg1.append(s)
            lineage[fn[:-4]] = {"stitch": stitch, "stg1": sorted(set(stg1))}
    return lineage


def _resolve_stitch_stage1(stage2_csv, lineage):
    """Given comma-separated stg2 names, return (stitch_csv, stg1_csv)."""
    stitches, stg1s = [], []
    for s in [x.strip() for x in stage2_csv.split(",") if x.strip().startswith("stg2")]:
        info = lineage.get(s)
        if not info:
            continue
        if info["stitch"]:
            stitches.append(info["stitch"])
        stg1s.extend(info["stg1"])
    stitch_csv = ", ".join(sorted(set(stitches))) if stitches else "-"
    stg1_csv = ", ".join(sorted(set(stg1s))) if stg1s else ""
    return stitch_csv, stg1_csv


def _parse_sat(path):
    """Return (grain, macro, stage2_summary) for a maximus sat file."""
    txt = open(path, encoding="utf-8").read()
    if "ma_sat_multi_source" in txt:
        macro = "ma_sat_multi_source()"
    elif "ma_sat(" in txt:
        macro = "ma_sat()"
    elif "sat_multi_source" in txt:
        macro = "sat_multi_source()"
    else:
        macro = "sat()"
    pk = re.search(r"src_pk:\s*'([^']+)'", txt)
    grain = PK_TO_GRAIN.get(pk.group(1), pk.group(1) if pk else "-")
    srcs = re.findall(r"-\s*'(stg2_[^']+)'", txt)
    # only source_model entries -> those starting with stg2
    srcs = [s for s in srcs if s.startswith("stg2")]
    stage2 = ", ".join(srcs) if srcs else "(per model)"
    return grain, macro, stage2


def _build_max_sections(sat_dir, hub_dir=None, link_dir=None, lineage=None):
    lineage = lineage or {}
    easy, medium, multi = [], [], []
    for fn in sorted(os.listdir(sat_dir)):
        if not fn.endswith(".sql"):
            continue
        grain, macro, stage2 = _parse_sat(os.path.join(sat_dir, fn))
        stitch, stage1 = _resolve_stitch_stage1(stage2, lineage)
        row = (fn[:-4], grain, macro, stage2, stitch, stage1, "pending")
        if macro.startswith("ma_sat"):
            multi.append(row)
        elif "multi_source" in macro:
            medium.append(row)
        else:
            easy.append(row)
    sections = {}
    if hub_dir or link_dir:
        struct = []
        for d, m in ((hub_dir, "hub()"), (link_dir, "link()")):
            if not d:
                continue
            for fn in sorted(os.listdir(d)):
                if fn.endswith(".sql"):
                    name = fn[:-4]
                    grain = name.upper()
                    struct.append((name, grain, m, "-", "-", "", "pending"))
        sections["PHASE 0 - STRUCTURAL (hubs & links)"] = struct
    sections["PHASE 1 - EASY (single-source sat, no stitch)"] = easy
    sections["PHASE 2 - MEDIUM (multi-source fan-in)"] = medium
    sections["PHASE 4 - MULTI-ACTIVE (ma_sat)"] = multi
    return {k: v for k, v in sections.items() if v}


max_std_lineage = _build_lineage(
    os.path.join(MAX_ROOT, "standard", "staging"),
    None,  # MAXIMUS has no stitch layer
)
max_aug_lineage = _build_lineage(
    os.path.join(MAX_ROOT, "augmented", "staging"),
    None,
)
max_std_sections = _build_max_sections(
    os.path.join(MAX_ROOT, "standard", "satellites"),
    os.path.join(MAX_ROOT, "standard", "hubs"),
    os.path.join(MAX_ROOT, "standard", "links"),
    lineage=max_std_lineage,
)
max_aug_sections = _build_max_sections(
    os.path.join(MAX_ROOT, "augmented", "satellites"),
    lineage=max_aug_lineage,
)

# ---- expand OPUS Stage_2 to full comma-separated source_model names ---------
OPUS_SAT_DIRS = [
    os.path.join(HERE, "models", "raw_vault", "partner", "standard", "satellites"),
    os.path.join(HERE, "models", "raw_vault", "partner", "augmented", "satellites"),
]


def _opus_full_stage2(model):
    for d in OPUS_SAT_DIRS:
        p = os.path.join(d, model + ".sql")
        if os.path.exists(p):
            txt = open(p, encoding="utf-8").read()
            srcs = re.findall(r"-\s*'(stg2_[^']+)'", txt)
            srcs = [s for s in srcs if s.startswith("stg2")]
            if srcs:
                return ", ".join(srcs)
    return None


OPUS_STD_ROOT = os.path.join(HERE, "models", "raw_vault", "partner", "standard")
OPUS_AUG_ROOT = os.path.join(HERE, "models", "raw_vault", "partner", "augmented")
opus_std_lineage = _build_lineage(
    os.path.join(OPUS_STD_ROOT, "staging"),
    os.path.join(OPUS_STD_ROOT, "stitched"),
)
opus_aug_lineage = _build_lineage(
    os.path.join(OPUS_AUG_ROOT, "staging"),
    os.path.join(OPUS_STD_ROOT, "stitched"),  # aug stg2 may reference std stitches
)


def _expand_opus(sections, lineage):
    for title, rows in sections.items():
        new = []
        for model, grain, macro, stage2, stitch, stage1, status in rows:
            if model.startswith("sat_"):
                full = _opus_full_stage2(model)
                if full:
                    stage2 = full
                st, s1 = _resolve_stitch_stage1(stage2, lineage)
                if st != "-":
                    stitch = st
                if s1:
                    stage1 = s1
            new.append((model, grain, macro, stage2, stitch, stage1, status))
        sections[title] = new
    return sections


standard_rows = _expand_opus(standard_rows, opus_std_lineage)
augmented_rows = _expand_opus(augmented_rows, opus_aug_lineage)

ws1 = wb.active
ws1.title = "Standard (OPUS)"
style_sheet(ws1, standard_rows, source="OPUS")

ws2 = wb.create_sheet("Augmented (OPUS)")
style_sheet(ws2, augmented_rows, source="OPUS")

ws3 = wb.create_sheet("Standard (MAXIMUS)")
style_sheet(ws3, max_std_sections, source="MAXIMUS")

ws4 = wb.create_sheet("Augmented (MAXIMUS)")
style_sheet(ws4, max_aug_sections, source="MAXIMUS")


# ---- DASHBOARD (first sheet): live progress metrics -------------------------
def build_dashboard(wb, sheet_sections):
    """sheet_sections: list of (sheet_name, sections dict). Uses live formulas
    so metrics recompute when a Status cell is edited in the data sheets."""
    ws = wb.create_sheet("Dashboard")
    # move Dashboard to the front
    wb._sheets.insert(0, wb._sheets.pop(wb._sheets.index(ws)))

    title_font = Font(bold=True, color="FFFFFF", size=14)
    ws["A1"] = "PARTNER DV - VALIDATION PROGRESS"
    ws["A1"].font = Font(bold=True, size=14, color="1F3864")
    ws.append([])

    # Per-sheet summary table
    hdr = ["Sheet", "Total models", "Done", "Pending", "% Complete"]
    ws.append(hdr)
    hrow = ws.max_row
    for c in ws[hrow]:
        c.fill = hdr_fill
        c.font = hdr_font
        c.alignment = Alignment(horizontal="center", vertical="center")
        c.border = border

    first_data = ws.max_row + 1
    for name, _sections in sheet_sections:
        q = f"'{name}'"
        # Column H = Status ("done"/"pending") exists only on data rows,
        # so total = done + pending (headers/phase rows have no status).
        done = f"=COUNTIF({q}!H:H,\"done\")"
        pending = f"=COUNTIF({q}!H:H,\"pending\")"
        r = ws.max_row + 1
        total = f"=C{r}+D{r}"
        pct = f"=IF(B{r}=0,0,C{r}/B{r})"
        ws.append([name, total, done, pending, pct])
        rc = ws[ws.max_row]
        for c in rc:
            c.border = border
            c.alignment = Alignment(horizontal="center", vertical="center")
        rc[0].alignment = Alignment(horizontal="left", vertical="center")
        rc[4].number_format = "0.0%"
    last_data = ws.max_row

    # Grand total row
    r = ws.max_row + 1
    ws.append([
        "GRAND TOTAL",
        f"=SUM(B{first_data}:B{last_data})",
        f"=SUM(C{first_data}:C{last_data})",
        f"=SUM(D{first_data}:D{last_data})",
        f"=IF(B{r}=0,0,C{r}/B{r})",
    ])
    tot = ws[ws.max_row]
    for c in tot:
        c.font = Font(bold=True)
        c.fill = PatternFill("solid", fgColor="DDEBF7")
        c.border = border
        c.alignment = Alignment(horizontal="center", vertical="center")
    tot[0].alignment = Alignment(horizontal="left", vertical="center")
    tot[4].number_format = "0.0%"

    # Per-phase breakdown table (static counts from build-time data)
    ws.append([])
    ws.append([])
    ws.append(["Phase breakdown (by sheet)"])
    ws[ws.max_row][0].font = Font(bold=True, size=12, color="1F3864")
    ws.append(["Sheet", "Phase", "Total", "Done", "Pending", "% Complete"])
    ph = ws.max_row
    for c in ws[ph]:
        c.fill = hdr_fill
        c.font = hdr_font
        c.alignment = Alignment(horizontal="center", vertical="center")
        c.border = border
    for name, sections in sheet_sections:
        for phase, rows in sections.items():
            total = len(rows)
            done = sum(1 for r in rows if str(r[6]).lower() == "done")
            pend = total - done
            pct = (done / total) if total else 0
            ws.append([name, phase, total, done, pend, pct])
            rc = ws[ws.max_row]
            for c in rc:
                c.border = border
                c.alignment = Alignment(vertical="center", wrap_text=True)
            rc[5].number_format = "0.0%"
            rc[5].alignment = Alignment(horizontal="center", vertical="center")

    for col, w in zip("ABCDEF", [22, 46, 12, 8, 10, 12]):
        ws.column_dimensions[col].width = w
    ws.freeze_panes = "A4"
    return ws


build_dashboard(wb, [
    ("Standard (OPUS)", standard_rows),
    ("Augmented (OPUS)", augmented_rows),
    ("Standard (MAXIMUS)", max_std_sections),
    ("Augmented (MAXIMUS)", max_aug_sections),
])

out = os.path.join(HERE, "partner_dv_validation_tracker.xlsx")
wb.save(out)


def _count(secs):
    return sum(len(r) for r in secs.values())


print("wrote", out)
print("OPUS    -> Standard:", _count(standard_rows), "| Augmented:", _count(augmented_rows))
print("MAXIMUS -> Standard:", _count(max_std_sections), "| Augmented:", _count(max_aug_sections))
