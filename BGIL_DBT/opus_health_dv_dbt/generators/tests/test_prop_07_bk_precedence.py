"""Property test for ``dvgen.keys.choose_business_key``.

Feature: health-lob-dv-dbt-build, Property 7: Business-key precedence

For any (table, hub, instance) with an optional explicit key mapping row and
an optional spec key slot, the chosen key is the mapping row when present,
else the spec key slot, else none (which leads to the bridge search).

Details checked (design "keys.py"):

- Explicit key rows are mapped ``hub_key``/``link_key`` rows for the same
  table and vault code (case-insensitive) and the same instance (exact).
  Their columns, in ``row_order``, form a ``map.KEY`` slot with an empty
  expression. ``redundant_of`` rows count only when every match is one.
- Without such rows, the matching Spec_JSON slot is chosen, preferring origin
  ``map.KEY``, then ``spec.key_slot``, then ``spec.resolved_key``, ties broken
  on ``KeySlot.sort_key``.
- With neither, the result is ``None``.

**Validates: Requirements 4.5**
"""
from __future__ import annotations

import string

from hypothesis import given, settings
from hypothesis import strategies as st

from dvgen.keys import choose_business_key
from dvgen.model import KEY_SLOT_ORIGINS, ROW_OUTCOMES, TARGET_KINDS, KeySlot, MappingRow

_ORIGIN_RANK = {"map.KEY": 0, "spec.key_slot": 1, "spec.resolved_key": 2}

_WORD = st.text(alphabet=string.ascii_letters + "_", min_size=1, max_size=6)
_COLUMN = st.text(alphabet=string.ascii_letters + string.digits + "_", min_size=1, max_size=6)


def _recase(draw, text: str) -> str:
    """The same text with random letter case (still a case-insensitive match)."""
    flips = draw(st.lists(st.booleans(), min_size=len(text), max_size=len(text)))
    return "".join(c.swapcase() if f else c for c, f in zip(text, flips))


@st.composite
def _target(draw):
    table = "T_" + draw(_WORD).upper()
    code = draw(st.sampled_from(["HUB_", "LNK_"])) + draw(_WORD).upper()
    instance = draw(st.one_of(st.none(), st.text(alphabet="ab12", min_size=1, max_size=3)))
    return table, code, instance


def _other_instance(draw, instance):
    """An instance that differs from ``instance`` under exact comparison."""
    choices = [None, "x9", "other"]
    if instance is not None:
        choices.append(instance + "z")
        if instance.swapcase() != instance:
            choices.append(instance.swapcase())  # case variant must not match
    return draw(st.sampled_from([c for c in choices if c != instance]))


@st.composite
def _case(draw):
    table, code, instance = draw(_target())

    def table_v():
        return (_recase(draw, table) if draw(st.integers(0, 3))
                else table + "_OTHER")

    def code_v():
        return (_recase(draw, code) if draw(st.integers(0, 3))
                else code + "_OTHER")

    def instance_v():
        return instance if draw(st.integers(0, 3)) else _other_instance(draw, instance)

    rows = []
    for i in range(draw(st.integers(0, 6))):
        rows.append(MappingRow(
            row_id=f"map.json#{i}",
            row_order=draw(st.integers(0, 5)),
            table=table_v(),
            column=draw(_COLUMN),
            outcome=draw(st.sampled_from(sorted(ROW_OUTCOMES))),
            target_kind=draw(st.sampled_from(sorted(TARGET_KINDS))),
            vault_code=draw(st.one_of(st.just(None), st.builds(code_v))),
            attribute=None,
            instance=instance_v(),
            redundant_of=draw(st.one_of(st.none(), st.just("map.json#0"))),
            child_key_expr=None,
            spec_unresolved=None,
        ))

    slots = []
    for _ in range(draw(st.integers(0, 5))):
        slots.append(KeySlot(
            table=table_v(),
            vault_code=code_v(),
            instance=instance_v(),
            expression=draw(st.text(alphabet="abc_ ()|", max_size=8)),
            source_columns=tuple(draw(st.lists(_COLUMN, max_size=3))),
            origin=draw(st.sampled_from(sorted(KEY_SLOT_ORIGINS))),
        ))
    return table, code, instance, rows, slots


def _key_rows(rows, table, code, instance):
    return [r for r in rows
            if r.outcome == "mapped"
            and r.target_kind in ("hub_key", "link_key")
            and r.table.upper() == table.upper()
            and r.vault_code is not None and r.vault_code.upper() == code.upper()
            and r.instance == instance]


def _spec_slots(slots, table, code, instance):
    return [s for s in slots
            if s.table.upper() == table.upper()
            and s.vault_code.upper() == code.upper()
            and s.instance == instance]


@settings(max_examples=300)
@given(case=_case())
def test_business_key_precedence(case):
    table, code, instance, rows, slots = case
    chosen = choose_business_key(rows, slots, table, code, instance)

    key_rows = _key_rows(rows, table, code, instance)
    if key_rows:
        # 1. An explicit KEY: mapping row wins over any spec slot.
        primary = [r for r in key_rows if r.redundant_of is None]
        used = sorted(primary or key_rows, key=lambda r: (r.row_order, r.row_id))
        expected_cols = []
        for r in used:
            if r.column.upper() not in {c.upper() for c in expected_cols}:
                expected_cols.append(r.column)
        assert chosen is not None
        assert chosen.origin == "map.KEY"
        assert chosen.expression == ""
        assert chosen.vault_code == code
        assert chosen.instance == instance
        assert chosen.table.upper() == table.upper()
        assert chosen.source_columns == tuple(expected_cols)
        # Spec slots cannot change the answer while a key row exists.
        assert choose_business_key(rows, [], table, code, instance) == chosen
        return

    candidates = _spec_slots(slots, table, code, instance)
    if candidates:
        # 2. Otherwise the best-ranked matching Spec_JSON slot, unchanged.
        best = min(candidates, key=lambda s: (_ORIGIN_RANK[s.origin], s.sort_key()))
        assert chosen is best or chosen == best
        assert any(chosen is s for s in slots)
        assert all(_ORIGIN_RANK[chosen.origin] <= _ORIGIN_RANK[s.origin]
                   for s in candidates)
        return

    # 3. Neither: no key (the planner then runs the bridge search).
    assert chosen is None


@settings(max_examples=150)
@given(case=_case())
def test_result_does_not_depend_on_input_order(case):
    table, code, instance, rows, slots = case
    forward = choose_business_key(rows, slots, table, code, instance)
    backward = choose_business_key(list(reversed(rows)), list(reversed(slots)),
                                   table, code, instance)
    assert forward == backward
