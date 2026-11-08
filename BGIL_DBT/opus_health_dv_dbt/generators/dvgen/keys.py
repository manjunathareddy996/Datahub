"""Business-key expressions for stage models (design "keys.py", Q10).

All functions are pure and deterministic.

- ``rewrite_columns`` turns a Spec_JSON key expression, written against the
  physical source columns, into one that reads the stg1 model: every
  identifier that is a column of the table becomes its lower-case stg1 alias.
- ``raw_key`` gives the raw (un-namespaced) business-key expression of a key
  slot.
- ``parent_nk`` and ``link_nk`` add the vault-code namespace that is hashed
  into the hub or link hash key (Requirement 5.3), in the Template_Project
  shapes::

      PARENT_NK: "'HUB_LOCATION|' || (mail_add_id)"
      POLICY_PARTY_HKEY_NK: "'LNK_POLICY_PARTY|' || part_id || '|' || contract_id"

- ``choose_business_key`` applies Requirement 4.5: an explicit ``KEY:``
  (``hub_key``/``link_key``) mapping row first, then the Spec_JSON key slot.

This module is project-agnostic and is copied byte-for-byte into the sibling
Health_Project.
"""
from __future__ import annotations

import re
from collections.abc import Iterable, Mapping, Sequence

from .model import KeySlot, MappingRow

__all__ = [
    "KeyRuleError",
    "rewrite_columns",
    "raw_key",
    "parent_nk",
    "link_nk",
    "choose_business_key",
]


class KeyRuleError(ValueError):
    """A key slot, vault code or key expression cannot be rendered."""


# SQL lexer for rewrite_columns. Alternatives are tried in order; anything a
# token does not cover is copied unchanged one character at a time.
_TOKEN = re.compile(
    r"""
      (?P<string>'(?:[^']|'')*'?)              # string literal, '' escapes
    | (?P<quoted>"(?:[^"]|"")*"?)              # quoted identifier
    | (?P<comment>--[^\n]*|/\*.*?(?:\*/|\Z))   # line or block comment
    | (?P<bracket>\[[^\]]*\]?)                 # [ ... ] segment (spine walks,
                                               # element access): not columns
    | (?P<number>\d[A-Za-z0-9_.$]*)            # numeric literal
    | (?P<ident>[A-Za-z_][A-Za-z0-9_$]*)       # bare identifier
    | (?P<other>.)
    """,
    re.VERBOSE | re.DOTALL,
)

_PLAIN_IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_$]*\Z")
_VAULT_CODE = re.compile(r"[A-Za-z][A-Za-z0-9_]*\Z")

# choose_business_key: slot origins in order of preference.
_ORIGIN_RANK = {"map.KEY": 0, "spec.key_slot": 1, "spec.resolved_key": 2}
_KEY_TARGET_KINDS = ("hub_key", "link_key")


def _column_set(columns: Iterable[str] | None) -> frozenset[str]:
    if columns is None:
        return frozenset()
    if isinstance(columns, str):
        raise KeyRuleError("table_columns must be a collection of names, not a string")
    return frozenset(c.upper() for c in columns)


def rewrite_columns(expr: str, table_columns: Iterable[str]) -> str:
    """Replace each identifier that is a column of the table with its stg1 alias.

    Matching is case-insensitive and word-bounded. The stg1 alias is the
    lower-case column name. A double-quoted identifier that names a column is
    replaced by the bare alias too. String literals, comments, numbers and
    ``[ ... ]`` segments are copied unchanged, as is every identifier that is
    not a column (functions, keywords, other names).
    """
    if not isinstance(expr, str):
        raise KeyRuleError(f"key expression must be a string, got {expr!r}")
    cols = _column_set(table_columns)
    out: list[str] = []
    for m in _TOKEN.finditer(expr):
        kind = m.lastgroup
        text = m.group()
        if kind == "ident":
            if text.upper() in cols:
                text = text.lower()
        elif kind == "quoted" and len(text) >= 2 and text.endswith('"'):
            inner = text[1:-1].replace('""', '"')
            if _PLAIN_IDENT.match(inner) and inner.upper() in cols:
                text = inner.lower()
        out.append(text)
    return "".join(out)


def _components(slot: KeySlot) -> list[str]:
    seen: list[str] = []
    for col in slot.source_columns:
        name = col.strip()
        if not name:
            raise KeyRuleError(f"key slot {slot.table}/{slot.vault_code} has a blank column")
        if name.upper() not in (s.upper() for s in seen):
            seen.append(name)
    return seen


def raw_key(slot: KeySlot, table_columns: Iterable[str] | None = None) -> str:
    """The raw business-key expression of a key slot, over stg1 aliases.

    A slot with a Spec_JSON expression (origin ``spec.*``) has one component:
    the expression, rewritten with ``rewrite_columns``. A ``map.KEY`` slot, or
    a slot with a blank expression, has one component per source column, in
    slot order. One component gives the bare alias. Several give the
    null-safe composite::

        case when coalesce(c1, c2) is null then null
        else coalesce(c1,'') || '|' || coalesce(c2,'') end

    (on one line). ``table_columns`` are the source table's columns; the
    slot's own ``source_columns`` are always treated as columns.
    """
    cols = _column_set(table_columns) | _column_set(slot.source_columns)
    expression = (slot.expression or "").strip()
    if expression and slot.origin != "map.KEY":
        return rewrite_columns(expression, cols)
    parts = [rewrite_columns(c, cols) for c in _components(slot)]
    if not parts:
        raise KeyRuleError(
            f"key slot {slot.table}/{slot.vault_code}/{slot.instance} has no "
            f"expression and no source columns")
    if len(parts) == 1:
        return parts[0]
    return (f"case when coalesce({', '.join(parts)}) is null then null else "
            + " || '|' || ".join(f"coalesce({p},'')" for p in parts)
            + " end")


def _code(code: str, what: str) -> str:
    if not isinstance(code, str) or not _VAULT_CODE.match(code):
        raise KeyRuleError(f"{what} {code!r} is not a vault code")
    return code


def _raw(raw: str, what: str) -> str:
    if not isinstance(raw, str) or not raw.strip():
        raise KeyRuleError(f"{what} raw key is empty")
    return raw


def parent_nk(code: str, raw: str) -> str:
    """Namespaced key of a hub (or satellite parent): ``'CODE|' || (raw)``."""
    _code(code, "parent_nk() code")
    return f"'{code}|' || ({_raw(raw, code)})"


def _link_component(raw: str) -> str:
    # The template writes bare columns unwrapped ("|| part_id ||"); any other
    # expression is parenthesised so operator precedence cannot change it.
    stripped = raw.strip()
    return stripped if _PLAIN_IDENT.match(stripped) else f"({stripped})"


def link_nk(link_code: str, hub_raw: Mapping[str, str],
            hub_order: Sequence[str] | None = None) -> str:
    """Namespaced link key: ``'LNK_X|' || r1 || '|' || r2``.

    ``hub_raw`` maps each hub code of the link to its raw key on this table.
    Components are joined in hub-code order (sorted hub codes), so the result
    does not depend on dict order. ``hub_order`` overrides that order; it
    must list each hub of ``hub_raw`` exactly once.
    """
    _code(link_code, "link_nk() link code")
    if not link_code.upper().startswith("LNK_"):
        raise KeyRuleError(f"link_nk() needs an LNK_ code, got {link_code!r}")
    if not hub_raw:
        raise KeyRuleError(f"link_nk({link_code}) has no hub keys")
    for hub in hub_raw:
        _code(hub, f"link_nk({link_code}) hub code")
    if hub_order is None:
        order = sorted(hub_raw)
    else:
        order = list(hub_order)
        if len(order) != len(set(order)) or set(order) != set(hub_raw):
            raise KeyRuleError(
                f"link_nk({link_code}) hub_order {order} does not list the "
                f"hubs {sorted(hub_raw)} exactly once")
    parts = [_link_component(_raw(hub_raw[h], f"{link_code}.{h}")) for h in order]
    return f"'{link_code}|' || " + " || '|' || ".join(parts)


def _same(a: str | None, b: str | None) -> bool:
    return (a or "").upper() == (b or "").upper() and (a is None) == (b is None)


def choose_business_key(rows: Iterable[MappingRow], spec_slots: Iterable[KeySlot],
                        table: str, vault_code: str,
                        instance: str | None = None) -> KeySlot | None:
    """The business key of ``vault_code`` on ``table`` for ``instance`` (Req. 4.5).

    1. Explicit ``KEY:`` mapping rows: mapped ``hub_key``/``link_key`` rows
       for (table, vault code, instance). Their columns, in ``row_order``,
       become a ``map.KEY`` slot. Rows marked ``redundant_of`` (declared
       fallbacks) are used only when every matching row is one.
    2. Otherwise the Spec_JSON key slot for (table, vault code, instance),
       preferring origin ``map.KEY``, then ``spec.key_slot``, then
       ``spec.resolved_key``; ties break on ``KeySlot.sort_key``.
    3. ``None`` when neither exists.

    Table and vault code match case-insensitively; ``instance`` matches
    exactly (``None`` only matches ``None``).
    """
    matching = sorted(
        (r for r in rows
         if r.outcome == "mapped"
         and r.target_kind in _KEY_TARGET_KINDS
         and _same(r.table, table)
         and _same(r.vault_code, vault_code)
         and r.instance == instance),
        key=lambda r: (r.row_order, r.row_id),
    )
    primary = [r for r in matching if r.redundant_of is None]
    chosen = primary or matching
    if chosen:
        columns: list[str] = []
        for r in chosen:
            if r.column.upper() not in (c.upper() for c in columns):
                columns.append(r.column)
        return KeySlot(table=chosen[0].table, vault_code=vault_code,
                       instance=instance, expression="",
                       source_columns=tuple(columns), origin="map.KEY")
    slots = sorted(
        (s for s in spec_slots
         if _same(s.table, table)
         and _same(s.vault_code, vault_code)
         and s.instance == instance),
        key=lambda s: (_ORIGIN_RANK.get(s.origin, len(_ORIGIN_RANK)), s.sort_key()),
    )
    return slots[0] if slots else None
