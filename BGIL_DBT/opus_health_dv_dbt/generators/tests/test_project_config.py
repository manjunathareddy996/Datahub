"""Unit tests for generators/project_config.py (project-agnostic).

Validates: Requirements 2.2, 3.6, 5.5, 5.7, 5.8
"""
from __future__ import annotations

import project_config as pc

SHARED_ATTRS = (
    "PROJECT", "PROFILE", "RECORD_SOURCE_PREFIX", "RECORD_SOURCE_GROUP",
    "WATERMARK_COLUMN", "WATERMARK_OVERRIDES", "STG1_SOURCE", "VARS",
    "SOURCES", "STEM_RULE", "SPEC_SOURCE", "COLUMN_CATALOGUE",
    "SIBLING_HEALTH_PROJECT", "TEMPLATE_PROJECT", "RECORD_SOURCE_OVERLAP",
    "TEMPLATE_LINK_HUB_ORDER",
)


def test_shared_attributes_exist():
    for name in SHARED_ATTRS:
        assert hasattr(pc, name), name


def test_watermark_constants():
    assert pc.WATERMARK_OVERRIDES == {}
    assert pc.WATERMARK_COLUMN == "inc_job_updated_at"


def test_record_source_prefix_and_group():
    assert pc.RECORD_SOURCE_PREFIX.endswith("_")
    assert pc.RECORD_SOURCE_GROUP == pc.RECORD_SOURCE_PREFIX[:-1]


def test_sources_and_stg1_source_use_declared_vars():
    assert pc.STG1_SOURCE in pc.SOURCES
    for db_var, schema_var in pc.SOURCES.values():
        assert db_var in pc.VARS and schema_var in pc.VARS


def test_stem_rule_and_template_link_order_types():
    assert pc.STEM_RULE in ("lower_table", "legacy_stem")
    assert isinstance(pc.TEMPLATE_LINK_HUB_ORDER, dict)
