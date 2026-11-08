"""Per-project constants for the MAXIMUS Health_Project Builder.

The OPUS and MAXIMUS copies of this file differ only in the project-specific
constants. Relative paths are resolved against the project root (the parent
of ``generators/``).
"""
from __future__ import annotations

from pathlib import Path
from typing import Dict, Mapping, Optional, Tuple

PROJECT_ROOT = Path(__file__).resolve().parent.parent

PROJECT = "maximus_health_dv_dbt"
PROFILE = "maximus_health_dbt"

# --- Accepted known risks (values are settled; do not change) -------------
# R3 (accepted): record-source prefix/group shared with other MAXIMUS projects.
RECORD_SOURCE_PREFIX = "MAXIMUS_"     # Requirement 5.5; risk R3
RECORD_SOURCE_GROUP = "MAXIMUS"       # Requirement 5.7; risk R3

# R1 (accepted): default watermark for every table. Tables that lack the
# column may fail at `dbt run`; see WATERMARK_OVERRIDES.
WATERMARK_COLUMN = "inc_job_updated_at"   # risk R1

# R1: {UPPER_TABLE: column}. Empty by default; add an entry only for a table
# proven to lack WATERMARK_COLUMN (for example "rec_refresh_at"). Resolve with
# WATERMARK_OVERRIDES.get(TABLE, WATERMARK_COLUMN).
WATERMARK_OVERRIDES: Dict[str, str] = {}  # risk R1

# --- Sources and vars (design Q5; values taken from maximus_travel_dv_dbt) --
STG1_SOURCE = "maximus_health_raw"
VARS: Dict[str, str] = {
    "maximus_health_raw_database": "BAGIC_PROD_MIRROR_DB",
    "maximus_health_raw_schema": "MAXI_RAW",
}
# {source_name: (database_var, schema_var)} for render_stg1.render_sources_yml
SOURCES: Mapping[str, Tuple[str, str]] = {
    "maximus_health_raw": ("maximus_health_raw_database",
                           "maximus_health_raw_schema"),
}

# Model-name stem rule (design Q7): "lower_table" or "legacy_stem".
STEM_RULE = "legacy_stem"

# --- Inputs and neighbouring projects ---------------------------------------
SPEC_SOURCE = PROJECT_ROOT / "build_artifacts/mxh3_spec.json"
COLUMN_CATALOGUE = ""   # no column catalogue for MAXIMUS
SIBLING_HEALTH_PROJECT = (PROJECT_ROOT / "../opus_health_dv_dbt").resolve()
TEMPLATE_PROJECT = (PROJECT_ROOT / "../opus_partner_dv_dbt").resolve()  # read-only

# README note about the RECORD_SOURCE prefix overlap: none for MAXIMUS.
RECORD_SOURCE_OVERLAP: Optional[str] = None


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
