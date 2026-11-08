"""Unit tests for dvgen.keys, checked against Template_Project stage shapes
and real Spec_JSON key expressions (hcon key_slots[], mxh3 resolved_key)."""
from __future__ import annotations

import pytest

from dvgen.keys import (
    KeyRuleError, choose_business_key, link_nk, parent_nk, raw_key,
    rewrite_columns,
)
from dvgen.model import KeySlot, MappingRow


def slot(expression, cols, origin="spec.key_slot", table="T", code="HUB_X",
         instance=None):
    return KeySlot(table=table, vault_code=code, instance=instance,
                   expression=expression, source_columns=tuple(cols),
                   origin=origin)


def row(column, order, *, table="T", code="HUB_X", kind="hub_key",
        instance=None, outcome="mapped", redundant_of=None):
    return MappingRow(row_id=f"m.json#{order}", row_order=order, table=table,
                      column=column, outcome=outcome, target_kind=kind,
                      vault_code=code, attribute=None, instance=instance,
                      redundant_of=redundant_of, child_key_expr=None,
                      spec_unresolved=None)


# ---------------------------------------------------------------- rewrite

def test_rewrite_guarded_and_namespaced_forms():
    cols = {"CLAIM_ID", "SCHEME_CODE"}
    assert rewrite_columns("nullif(trim(CLAIM_ID),'')", cols) == "nullif(trim(claim_id),'')"
    assert (rewrite_columns("nullif('SCHEME:' || nullif(trim(SCHEME_CODE),''), 'SCHEME:')", cols)
            == "nullif('SCHEME:' || nullif(trim(scheme_code),''), 'SCHEME:')")


def test_rewrite_leaves_literals_functions_and_other_names():
    cols = {"CITY", "TRIM", "PIN"}
    # The 'CITY' literal and the non-column OTHER_COL are kept. TRIM is a
    # column here, so it is lower-cased too, which keeps its SQL meaning.
    expr = "upper(coalesce(CITY,'CITY') || '|' || coalesce(TRIM(PIN),'') || OTHER_COL)"
    assert (rewrite_columns(expr, cols)
            == "upper(coalesce(city,'CITY') || '|' || coalesce(trim(pin),'') || OTHER_COL)")


def test_rewrite_is_word_bounded_and_case_insensitive():
    cols = {"ID"}
    assert rewrite_columns("Id || PART_ID || ID_2 || id", cols) == "id || PART_ID || ID_2 || id"


def test_rewrite_quoted_identifier_escaped_literal_and_brackets():
    cols = {"POLICY_NUMBER", "FROM", "PARENT_KEY_HASH"}
    assert rewrite_columns('"POLICY_NUMBER"', cols) == "policy_number"
    assert rewrite_columns("'it''s FROM' || FROM", cols) == "'it''s FROM' || from"
    spine = "nullif(trim(spine[PARENT_KEY_HASH -> A_VW -> B_VW].POLICY_NUMBER),'')"
    assert (rewrite_columns(spine, cols)
            == "nullif(trim(spine[PARENT_KEY_HASH -> A_VW -> B_VW].policy_number),'')")
    assert rewrite_columns("-- CLAIM\n1E5 + x", {"CLAIM", "E5"}) == "-- CLAIM\n1E5 + x"


def test_rewrite_rejects_string_column_set():
    with pytest.raises(KeyRuleError):
        rewrite_columns("A", "A")


# ---------------------------------------------------------------- raw_key

def test_raw_key_spec_expression_is_one_component():
    s = slot("md5(normalise(upper(nullif(trim( coalesce(ADDRESS_LINE1,'') || '|' "
             "|| coalesce(CORP_PIN,'') ), '|'))))", ["ADDRESS_LINE1", "CORP_PIN"])
    assert raw_key(s) == ("md5(normalise(upper(nullif(trim( coalesce(address_line1,'') "
                          "|| '|' || coalesce(corp_pin,'') ), '|'))))")


def test_raw_key_uses_table_columns_beyond_source_columns():
    # mxh3: source_columns lists only the first operand.
    s = slot("'MEMBER:' || coalesce( nullif(trim(INSURED_MEMBER_CODE),'') , "
             "nullif(trim(HEALTH_CARD_NUMBER),'') )", ["INSURED_MEMBER_CODE"],
             origin="spec.resolved_key")
    assert "HEALTH_CARD_NUMBER" in raw_key(s)
    assert raw_key(s, {"HEALTH_CARD_NUMBER"}) == (
        "'MEMBER:' || coalesce( nullif(trim(insured_member_code),'') , "
        "nullif(trim(health_card_number),'') )")


def test_raw_key_map_key_single_and_composite_in_slot_order():
    assert raw_key(slot("", ["MAIL_ADD_ID"], origin="map.KEY")) == "mail_add_id"
    s = slot("", ["POLICY_NO", "EMP_CODE", "policy_no"], origin="map.KEY")
    assert raw_key(s) == ("case when coalesce(policy_no, emp_code) is null then null "
                          "else coalesce(policy_no,'') || '|' || coalesce(emp_code,'') end")
    s2 = slot("", ["EMP_CODE", "POLICY_NO"], origin="map.KEY")
    assert raw_key(s2).startswith("case when coalesce(emp_code, policy_no)")


def test_raw_key_blank_expression_uses_columns_and_empty_slot_fails():
    assert raw_key(slot("  ", ["A", "B"])).startswith("case when coalesce(a, b) is null")
    with pytest.raises(KeyRuleError):
        raw_key(slot("", []))


# ---------------------------------------------------------------- NK strings

def test_parent_nk_matches_template():
    assert parent_nk("HUB_LOCATION", "mail_add_id") == "'HUB_LOCATION|' || (mail_add_id)"
    assert (parent_nk("HUB_ORG_UNIT", "upper(trim(business_unit))")
            == "'HUB_ORG_UNIT|' || (upper(trim(business_unit)))")


@pytest.mark.parametrize("code,raw", [("", "a"), ("HUB'X", "a"), ("HUB_X", " ")])
def test_parent_nk_rejects_bad_input(code, raw):
    with pytest.raises(KeyRuleError):
        parent_nk(code, raw)


def test_link_nk_template_shape_in_hub_code_order():
    # Same string as stg2_link_ba_hcp_dt_mem__policy_party.sql.
    assert (link_nk("LNK_POLICY_PARTY", {"HUB_POLICY": "contract_id", "HUB_PARTY": "part_id"})
            == "'LNK_POLICY_PARTY|' || part_id || '|' || contract_id")
    # Dict order does not matter.
    a = link_nk("LNK_CLAIM_PARTY", {"HUB_PARTY": "part_id", "HUB_CLAIM": "claim_id"})
    b = link_nk("LNK_CLAIM_PARTY", {"HUB_CLAIM": "claim_id", "HUB_PARTY": "part_id"})
    assert a == b == "'LNK_CLAIM_PARTY|' || claim_id || '|' || part_id"


def test_link_nk_explicit_order_and_wrapped_expressions():
    assert (link_nk("LNK_CLAIM_PARTY", {"HUB_CLAIM": "claim_id", "HUB_PARTY": "part_id"},
                    hub_order=["HUB_PARTY", "HUB_CLAIM"])
            == "'LNK_CLAIM_PARTY|' || part_id || '|' || claim_id")
    assert (link_nk("LNK_PARTY_ROLE", {"HUB_PARTY": "'EMP:' || nullif(trim(emp),'')"})
            == "'LNK_PARTY_ROLE|' || ('EMP:' || nullif(trim(emp),''))")


@pytest.mark.parametrize("code,hubs,order", [
    ("HUB_X", {"HUB_A": "a"}, None),
    ("LNK_X", {}, None),
    ("LNK_X", {"HUB_A": ""}, None),
    ("LNK_X", {"HUB_A": "a", "HUB_B": "b"}, ["HUB_A"]),
    ("LNK_X", {"HUB_A": "a", "HUB_B": "b"}, ["HUB_A", "HUB_A", "HUB_B"]),
])
def test_link_nk_rejects_bad_input(code, hubs, order):
    with pytest.raises(KeyRuleError):
        link_nk(code, hubs, hub_order=order)


# ---------------------------------------------------------------- choose

def test_choose_prefers_explicit_key_rows_in_row_order():
    rows = [row("EMP_CODE", 7), row("POLICY_NO", 3),
            row("OTHER", 1, code="HUB_Y"), row("ATTR", 2, kind="satellite_attribute")]
    spec = [slot("nullif(trim(X),'')", ["X"])]
    got = choose_business_key(rows, spec, "t", "hub_x")
    assert got == KeySlot(table="T", vault_code="hub_x", instance=None, expression="",
                          source_columns=("POLICY_NO", "EMP_CODE"), origin="map.KEY")


def test_choose_skips_redundant_rows_when_a_primary_exists():
    rows = [row("A", 1), row("B", 2, redundant_of="m.json#1")]
    assert choose_business_key(rows, [], "T", "HUB_X").source_columns == ("A",)
    only = [row("B", 2, redundant_of="m.json#1")]
    assert choose_business_key(only, [], "T", "HUB_X").source_columns == ("B",)


def test_choose_falls_back_to_spec_slot_by_origin_then_sort_key():
    spec = [slot("Z", ["Z"], origin="spec.resolved_key"),
            slot("B", ["B"]), slot("A", ["A"]),
            slot("I", ["I"], instance="intermediary"),
            slot("O", ["O"], table="OTHER")]
    assert choose_business_key([row("Q", 1, outcome="augmentation_needed")], spec,
                               "T", "HUB_X").expression == "A"
    assert choose_business_key([], list(reversed(spec)), "T", "HUB_X").expression == "A"
    assert choose_business_key([], spec, "T", "HUB_X", "intermediary").expression == "I"


def test_choose_returns_none_when_no_key():
    assert choose_business_key([], [slot("A", ["A"])], "T", "HUB_Y") is None
    assert choose_business_key([], [slot("A", ["A"])], "T", "HUB_X", "other") is None
