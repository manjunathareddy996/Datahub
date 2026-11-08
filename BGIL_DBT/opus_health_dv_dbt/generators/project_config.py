"""Per-project constants for the OPUS Health_Project Builder.

The OPUS and MAXIMUS copies of this file differ only in the project-specific
constants. Relative paths are resolved against the project root (the parent
of ``generators/``).
"""
from __future__ import annotations

from pathlib import Path
from typing import Dict, Mapping, Tuple

PROJECT_ROOT = Path(__file__).resolve().parent.parent

PROJECT = "opus_health_dv_dbt"
PROFILE = "opus_health_dbt"

# --- Accepted known risks (values are settled; do not change) -------------
# R3 (accepted): RECORD_SOURCE LIKE 'OPUS_%' also matches OPUS_PARTNER_ rows.
RECORD_SOURCE_PREFIX = "OPUS_"        # Requirement 5.5; risk R3
RECORD_SOURCE_GROUP = "OPUS"          # Requirement 5.7; risk R3

# R1/R2 (accepted): default watermark for every table. The 7 OPUS tables that
# lack the column may fail at `dbt run` (R2); no substitute column is used.
WATERMARK_COLUMN = "inc_job_updated_at"   # risk R1/R2

# R1: {UPPER_TABLE: column}. Empty by default; add an entry only for a table
# proven to lack WATERMARK_COLUMN. Resolve with
# WATERMARK_OVERRIDES.get(TABLE, WATERMARK_COLUMN).
WATERMARK_OVERRIDES: Dict[str, str] = {}  # risk R1

# --- Sources and vars (design Q5; values taken from opus_partner_dv_dbt) ---
STG1_SOURCE = "health_test_raw"
VARS: Dict[str, str] = {
    "health_raw_database": "BAGIC_PROD_MIRROR_DB",
    "health_raw_schema": "OPUS_GG_DWHSTAGE",
    "health_test_raw_database": "BAGIC_PREPROD_CURATED_DB",
    "health_test_raw_schema": "UTILS",
}
# {source_name: (database_var, schema_var)} for render_stg1.render_sources_yml
SOURCES: Mapping[str, Tuple[str, str]] = {
    "health_raw": ("health_raw_database", "health_raw_schema"),
    "health_test_raw": ("health_test_raw_database", "health_test_raw_schema"),
}

# Model-name stem rule (design Q7): "lower_table" or "legacy_stem".
STEM_RULE = "lower_table"

# --- Inputs and neighbouring projects ---------------------------------------
SPEC_SOURCE = PROJECT_ROOT / "build_artifacts/hcon_spec.json"
COLUMN_CATALOGUE = PROJECT_ROOT / "inputs/00_tables_index.DELTA3.json"
SIBLING_HEALTH_PROJECT = (PROJECT_ROOT / "../maximus_health_dv_dbt").resolve()
TEMPLATE_PROJECT = (PROJECT_ROOT / "../opus_partner_dv_dbt").resolve()  # read-only

# README note about the RECORD_SOURCE prefix overlap (R3).
RECORD_SOURCE_OVERLAP = (
    "RECORD_SOURCE LIKE 'OPUS_%' also matches OPUS_PARTNER_ rows "
    "(risk R3, accepted)."
)


def template_link_hub_order() -> Dict[str, Tuple[str, ...]]:
    """Template link hub order, read-only; ``{}`` if the template is missing."""
    links_dir = TEMPLATE_PROJECT / "models/raw_vault/standard/links"
    if not links_dir.is_dir():
        return {}
    try:
        from dvgen.template_links import template_link_hub_order as _order
    except ImportError:
        return {}
    return dict(_order(links_dir))


def __getattr__(name: str):
    """Compute ``TEMPLATE_LINK_HUB_ORDER`` lazily on first access."""
    if name == "TEMPLATE_LINK_HUB_ORDER":
        value = template_link_hub_order()
        globals()[name] = value
        return value
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")
