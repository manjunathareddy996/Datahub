"""MAXIMUS adapter: ``mxh3_spec.json`` -> ``dvgen.model.IntermediateSpec``.

Public API::

    load_mxh3(project_root)         -> IntermediateSpec
    load_mxh3_report(project_root)  -> (IntermediateSpec, report: dict)

``project_root`` is the MAXIMUS_Project directory (``maximus_health_dv_dbt``).
The adapter reads, relative to it:

- ``build_artifacts/mxh3_spec.json`` (the Spec_JSON),
- ``legacy_v3/models/staging/*.sql`` and ``legacy_v3/models/hopviews/*.sql``
  (typed casts, parsed through ``dvgen.types``; there is no tables index),

and records the sha256 of every file read in ``input_digests``.

Mapping (requirements 3.2, 3.7, 4.1, 4.5, 6.8, 8.3)
---------------------------------------------------
Tables
    One ``Table`` per ``views.staging`` view and per ``views.hopviews`` view
    (walk-only). ``Table.stem`` is the legacy model name: for staging the
    name without ``stg_`` (``stg_clm_authr`` -> ``clm_authr``); for hopviews
    the full model name (``hop_clm``), so a hopview can never share a stem
    with a staging view. Two tables with the same (case-insensitive) stem
    stop the build (``AdapterError``). Columns come from the view's
    ``columns`` list, typed by ``dvgen.types.legacy_types`` +
    ``resolve_type`` (``COL::number`` etc.; a column the legacy SQL does not
    cast is ``text`` / ``untyped``). ``has_watermark_evidence`` is
    ``unknown`` for every table. ``Column.is_key`` is set for every column of
    a key slot and for the spine join columns (``KEY_HASH``,
    ``PARENT_KEY_HASH`` and the walk start column) of every table on a walk,
    so both sides of a bridge join are cast the same way.

Satellites
    One ``standard`` ``SatelliteFact`` per ``model.sat_parent`` entry, with
    ``model.sat_childkey`` (``""`` = single-active; ``None`` only when the
    code is missing from ``sat_childkey``). Augmentation rows whose
    ``new_satellite`` is not in the model get an ``augmented`` fact: parent =
    the rows' anchor, child key = their ``declared_child_key``; if the rows
    disagree the parent is ``None`` / ``parent_origin='none'`` so the planner
    reports ``missing_parent`` instead of guessing. A row targeting a
    ``REF_*`` code would get a ``reference`` fact (``mxh3_spec.json`` has
    none: all 2,948 blocks target ``SAT_*``).

Rows
    One ``MappingRow`` per ``blocks[]`` entry: ``row_id='blocks#<n>'`` and
    ``row_order=n``, where ``n`` is the list index (the blocks' own ``i``
    field is not unique, so it is not used).
    ``vault_code`` is the satellite (``satellite``, else ``home``, else
    ``new_satellite``) or, for ``hub_key`` / ``link_key``, the ``anchor``.
    ``child_key_expr`` follows the plan.py "Branches" format: legs joined by
    `` | ``, each ``<part> = <value>``; ``{sql}`` for data-driven legs (the
    spec's ``rendered_child_key`` SQL), a quoted literal for literal legs,
    and a deliberately unresolvable ``{unresolved:<raw>}`` for any leg whose
    ``leg_status`` is not ``ok`` (so the planner reports it and never builds
    it).

Prior unresolved (``spec_unresolved``; all kinds are in
``dvgen.gaps.PRIOR_KIND_REASONS``). First match wins:

1. ``refuse_row`` (block ``refuse_row`` true; 3 rows)
2. ``do_not_build`` (any ``legs[].do_not_build``; 5 legs on 4 rows, which
   with the 3 ``refuse_row`` rows are the spec's 8 do-not-build items)
3. ``anchor_does_not_resolve_uniquely`` / ``anchor_has_no_declared_expression_on_this_view``
   (block ``anchor_state`` ``REFUSED_ambiguous`` / ``REFUSED_no_declared_expression``;
   these are the 147 + 43 ``unresolved[]`` entries of the same names)
4. ``anchor_does_not_resolve_uniquely`` for satellite / augmentation rows
   that contribute to a (table, vault code, instance) with more than one
   distinct key expression and no explicit ``hub_key`` / ``link_key`` row.
   ``choose_business_key`` would otherwise pick one silently, which the spec
   itself calls a silent mis-key. Link slots are not checked (the planner
   builds link keys from per-hub slots).

The other ``unresolved[]`` kinds (``spine_display_rung_with_no_declared_walk``,
``child_key_leg_does_not_resolve_on_its_own_view``,
``s54_payload_attribute_is_also_a_child_key_leg``) are found by the planner
from the legs and payload names. Every ``unresolved[]`` kind is checked
against ``PRIOR_KIND_REASONS`` (an unknown kind stops the build).

Key slots (origin ``spec.resolved_key``)
    From ``blocks[].resolved_key`` and ``anchor_expression``:

    - a plain expression -> a slot on the block's view;
    - an expression with exactly one distinct ``spine[...]`` reference that
      is also a top-level ``spans`` entry of the view, and no other column of
      the view -> a slot on the walk's ``terminal_table`` with the spine
      reference replaced by ``terminal_column``; the planner reaches it from
      the view through the matching ``Walk`` (a bridge);
    - ``LNK(...)`` -> a slot for the link plus one slot per named
      ``resolved_key.legs`` hub whose expression is a plain expression (the
      planner builds link stages from per-hub keys on the same table and
      does not bridge them).

    Anything else (several spine references, spine mixed with view columns,
    positional link components, ``tier=unresolved``) gets no slot, and the
    planner records the missing key as a gap.

Walks
    One ``Walk`` per top-level ``spans`` entry: ``from_table=from_view``,
    ``start_column=start``, ``climb=climb_real``, ``descend=descend_real``,
    ``terminal_table=terminal_view``, ``terminal_column``,
    ``walk_id='spans#<ordinal>'``, ``raw`` = the spec text. The join
    semantics match ``legacy_v3/models/resolvers``: ``start`` equals the
    first hop's ``KEY_HASH``; each further climb hop joins
    ``PARENT_KEY_HASH`` to the next ``KEY_HASH``; a descent hop joins its
    ``PARENT_KEY_HASH`` to the previous ``KEY_HASH``. ``views.resolvers`` is
    cross-checked (every listed span ordinal exists, starts on the resolver's
    view; ``join_key`` is ``KEY_HASH``).

Hubs and links
    ``mxh3_spec.json`` carries counts only (20 hubs, 71 links), no names. The
    names are collected from satellite parents, block anchors and resolved
    keys.

This module must import ``dvgen`` normally. ``dvgen`` is copied into
``generators/`` by ``sync_dvgen.py``.
"""
from __future__ import annotations

import hashlib
import json
import re
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any

from dvgen.gaps import PRIOR_KIND_REASONS, reason_for_prior_kind
from dvgen.model import (
    Column,
    IntermediateSpec,
    KeySlot,
    MappingRow,
    SatelliteFact,
    Table,
    Walk,
)
from dvgen.types import legacy_types, resolve_type

__all__ = ["AdapterError", "load_mxh3", "load_mxh3_report", "SPEC_REL",
           "LEGACY_STAGING_REL", "LEGACY_HOPVIEWS_REL", "PROJECT_NAME"]

PROJECT_NAME = "maximus_health_dv_dbt"
SPEC_REL = "build_artifacts/mxh3_spec.json"
LEGACY_STAGING_REL = "legacy_v3/models/staging"
LEGACY_HOPVIEWS_REL = "legacy_v3/models/hopviews"

_STAGING_PREFIX = "stg_"
_SPINE_REF = re.compile(
    r"spine\[[^\]]*\](?:\s*>>\s*[A-Za-z0-9_]+)?\.[A-Za-z0-9_]+")
_STRING = re.compile(r"'(?:[^']|'')*'")
_IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_$]*")
_SPINE_COLUMNS = ("KEY_HASH", "PARENT_KEY_HASH")

_ANCHOR_STATE_KIND = {
    "REFUSED_ambiguous": "anchor_does_not_resolve_uniquely",
    "REFUSED_no_declared_expression":
        "anchor_has_no_declared_expression_on_this_view",
}
_SAT_ROW_KINDS = ("satellite_attribute", "augmentation")
_KEY_ROW_KINDS = ("hub_key", "link_key")


class AdapterError(ValueError):
    """The Spec_JSON or a legacy file is inconsistent; the build stops."""


# --------------------------------------------------------------------------
# helpers
# --------------------------------------------------------------------------

def _sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _norm(text: str) -> str:
    return " ".join(str(text).split())


def _idents(expr: str) -> list[str]:
    """Bare identifiers of ``expr`` outside string literals, in order."""
    return _IDENT.findall(_STRING.sub(" ", expr))


def _blank(value: Any) -> bool:
    return value is None or (isinstance(value, str) and not value.strip())


def _text(value: Any) -> str | None:
    return None if _blank(value) else str(value)


# --------------------------------------------------------------------------
# tables and stems
# --------------------------------------------------------------------------

def _stems(spec: dict) -> dict[str, str]:
    """``{TABLE: stem}`` for staging and hopviews; stops on a collision."""
    stems: dict[str, str] = {}
    for table, info in spec["views"]["staging"].items():
        model = info["model"]
        stems[table] = (model[len(_STAGING_PREFIX):]
                        if model.startswith(_STAGING_PREFIX) else model)
    for table, info in spec["views"]["hopviews"].items():
        if table in stems:
            raise AdapterError(
                f"{table} is in both views.staging and views.hopviews")
        stems[table] = info["model"]
    seen: dict[str, str] = {}
    for table in sorted(stems):
        key = stems[table].lower()
        if key in seen:
            raise AdapterError(
                f"stem collision: {seen[key]} and {table} both map to "
                f"stem {stems[table]!r}")
        seen[key] = table
    return stems


# --------------------------------------------------------------------------
# walks
# --------------------------------------------------------------------------

def _walks(spec: dict, known_tables: set[str]) -> tuple[Walk, ...]:
    walks: list[Walk] = []
    seen: set[int] = set()
    for pos, s in enumerate(spec["spans"]):
        ordinal = s["ordinal"]
        if ordinal in seen:
            raise AdapterError(f"spans[{pos}]: duplicate ordinal {ordinal}")
        seen.add(ordinal)
        w = Walk(walk_id=f"spans#{ordinal}", from_table=s["from_view"],
                 start_column=s["start"], climb=tuple(s["climb_real"]),
                 descend=tuple(s["descend_real"]),
                 terminal_table=s["terminal_view"],
                 terminal_column=s["terminal_column"], raw=s["raw"])
        missing = [t for t in w.tables if t not in known_tables]
        if missing:
            raise AdapterError(f"{w.walk_id}: unknown tables {missing}")
        walks.append(w)
    by_ordinal = {w.walk_id: w for w in walks}
    for view, r in sorted(spec["views"]["resolvers"].items()):
        if r.get("join_key") != "KEY_HASH":
            raise AdapterError(f"resolver {view}: join_key {r.get('join_key')!r}")
        for ordinal in r["spans"]:
            w = by_ordinal.get(f"spans#{ordinal}")
            if w is None:
                raise AdapterError(
                    f"resolver {view}: span ordinal {ordinal} not in spans[]")
            if w.from_table != view:
                raise AdapterError(
                    f"resolver {view}: span {ordinal} starts on {w.from_table}")
    return tuple(sorted(walks, key=lambda w: int(w.walk_id.split("#")[1])))


# --------------------------------------------------------------------------
# key slots
# --------------------------------------------------------------------------

class _Slots:
    """Collects key slots and who contributed them (conflict detection)."""

    def __init__(self) -> None:
        # (table, code, instance) -> {normalised expr: (KeySlot, {block i})}
        self.groups: dict[tuple, dict[str, tuple[KeySlot, set[int]]]] = {}

    def add(self, block_i: int, table: str, code: str, instance: str | None,
            expression: str, columns: list[str]) -> None:
        group = self.groups.setdefault((table, code, instance), {})
        key = _norm(expression)
        if key in group:
            group[key][1].add(block_i)
            return
        group[key] = (KeySlot(table=table, vault_code=code, instance=instance,
                              expression=expression,
                              source_columns=tuple(columns),
                              origin="spec.resolved_key"), {block_i})


def _view_columns_in(expr: str, colset: set[str]) -> list[str]:
    out: list[str] = []
    for ident in _idents(expr):
        up = ident.upper()
        if up in colset and up not in out:
            out.append(up)
    return out


def _spine_split(expr: str, view: str, colset: set[str],
                 walks: dict[tuple[str, str], Walk]
                 ) -> tuple[str, str, str] | None | str:
    """Classify an expression that contains ``spine[...]`` references.

    Returns ``(terminal_table, terminal_column, expression_on_terminal)`` for
    exactly one distinct reference known as a walk of ``view`` and no other
    column of the view; ``"no_walk"`` when a reference is not a known walk;
    ``None`` for anything else (several references, mixed with view columns).
    """
    refs = sorted(set(_SPINE_REF.findall(expr)))
    if len(refs) != 1:
        return None
    ref = refs[0]
    walk = walks.get((view, _norm(ref)))
    if walk is None:
        return "no_walk"
    others = [i for i in _idents(expr.replace(ref, " __spine__ "))
              if i != "__spine__" and i.upper() in colset]
    if others:
        return None
    return (walk.terminal_table, walk.terminal_column,
            expr.replace(ref, walk.terminal_column))


def _collect_slots(spec: dict, blocks: list[dict], view_cols: dict[str, set[str]],
                   walks: tuple[Walk, ...], report: Counter) -> _Slots:
    # A walk's ``raw`` is the whole ``spine[...]...COL`` reference as written
    # in expressions; (from_view, raw) is unique across ``spans``.
    wmap = {(w.from_table, _norm(w.raw)): w for w in walks}
    slots = _Slots()
    for i, b in enumerate(blocks):
        view = b["view"]
        colset = view_cols[view]
        rk = b["resolved_key"]
        instance = _text(b.get("instance"))
        if rk.get("expression") and rk.get("hub"):
            code, expr = rk["hub"], rk["expression"]
            cols = [c for c in rk.get("source_columns") or []]
            origin = "resolved_key"
        elif b.get("anchor_expression") and b.get("anchor_state") == "resolved_uniquely":
            code, expr = b["anchor"], b["anchor_expression"]
            cols = []
            origin = "anchor_expression"
        else:
            if rk.get("tier") == "unresolved":
                report["slot_skipped_tier_unresolved"] += 1
            continue
        report[f"slot_source_{origin}"] += 1
        if code.startswith("LNK_"):
            link_expr = expr
            if _SPINE_REF.search(link_expr):
                report["link_slot_with_spine_expression"] += 1
            slots.add(i, view, code, instance, link_expr,
                      cols or _view_columns_in(link_expr, colset))
            for hub, hexpr in sorted((rk.get("legs") or {}).items()):
                if not hub.startswith("HUB_") or _blank(hexpr):
                    continue
                if "spine[" in hexpr:
                    report["link_component_spine_no_slot"] += 1
                    continue
                slots.add(i, view, hub, instance, hexpr,
                          _view_columns_in(hexpr, colset))
                report["link_component_slot"] += 1
            continue
        if "spine[" in expr:
            res = _spine_split(expr, view, colset, wmap)
            if res == "no_walk":
                report["spine_ref_without_walk_no_slot"] += 1
            elif res is None:
                report["spine_expression_not_single_no_slot"] += 1
            else:
                t_table, t_col, t_expr = res
                slots.add(i, t_table, code, instance, t_expr, [t_col])
                report["spine_slot_on_terminal"] += 1
            continue
        slots.add(i, view, code, instance, expr,
                  cols or _view_columns_in(expr, colset))
    return slots


# --------------------------------------------------------------------------
# rows
# --------------------------------------------------------------------------

def _leg_text(leg: dict, state: str | None, rendered: str | None,
              part: str | None) -> str:
    value = leg.get("value")
    if state == "ok":
        backing = leg.get("backing")
        if backing in ("literal", None):
            if rendered and rendered.startswith("'") and rendered.endswith("'"):
                body = rendered
            else:
                body = "'" + str(value).replace("'", "''") + "'"
        else:
            body = "{" + (rendered if rendered is not None else str(value)) + "}"
    else:
        body = "" if _blank(value) else "{unresolved:" + str(value) + "}"
    return f"{part} = {body}" if part else body


def _child_key_expr(b: dict) -> str | None:
    legs = b.get("legs") or []
    if not legs:
        return None
    parts = [p.strip() for p in (b.get("declared_child_key") or "").split("+")
             if p.strip()]
    states = {s.get("leg"): s.get("state") for s in b.get("leg_status") or []}
    rendered = b.get("rendered_child_key") or {}
    out = []
    for leg in legs:
        name = leg.get("leg")
        part = name if name else (parts[0] if len(parts) == 1 else None)
        out.append(_leg_text(leg, states.get(name), rendered.get(name), part))
    return " | ".join(out)


def _vault_code(b: dict) -> str | None:
    if b["kind"] in _KEY_ROW_KINDS:
        return _text(b.get("anchor"))
    return (_text(b.get("satellite")) or _text(b.get("home"))
            or _text(b.get("new_satellite")))


def _prior_kind(b: dict) -> str | None:
    if b.get("refuse_row"):
        return "refuse_row"
    if any(l.get("do_not_build") for l in b.get("legs") or []):
        return "do_not_build"
    return _ANCHOR_STATE_KIND.get(b.get("anchor_state"))


def _rows(blocks: list[dict], conflict_blocks: set[int]) -> tuple[MappingRow, ...]:
    rows = []
    for order, b in enumerate(blocks):
        prior = _prior_kind(b)
        if prior is None and order in conflict_blocks and b["kind"] in _SAT_ROW_KINDS:
            prior = "anchor_does_not_resolve_uniquely"
        if prior is not None:
            reason_for_prior_kind(prior)   # must be a known kind
        rows.append(MappingRow(
            row_id=f"blocks#{order}", row_order=order, table=b["view"],
            column=b["column"], outcome=b["outcome"], target_kind=b["kind"],
            vault_code=_vault_code(b), attribute=_text(b.get("attribute")),
            instance=_text(b.get("instance")), redundant_of=None,
            child_key_expr=_child_key_expr(b), spec_unresolved=prior))
    return tuple(rows)


# --------------------------------------------------------------------------
# satellites, hubs, links
# --------------------------------------------------------------------------

def _satellites(spec: dict, blocks: list[dict]) -> tuple[SatelliteFact, ...]:
    model = spec["model"]
    parents, childkeys = model["sat_parent"], model["sat_childkey"]
    facts: dict[tuple[str, str], SatelliteFact] = {}
    for code in sorted(parents):
        parent = _text(parents[code])
        facts[(code, "standard")] = SatelliteFact(
            code=code, track="standard", parent=parent,
            childkey=(childkeys[code] if code in childkeys else None),
            parent_origin="own_spec" if parent else "none")
    new: dict[str, list[dict]] = defaultdict(list)
    refs: set[str] = set()
    for pos, b in enumerate(blocks):
        code = _vault_code(b)
        if code is None or b["kind"] in _KEY_ROW_KINDS:
            continue
        if code.startswith("REF_"):
            refs.add(code)
        elif code not in parents and b.get("new_satellite") == code:
            new[code].append(b)
        elif code not in parents:
            raise AdapterError(
                f"blocks#{pos}: satellite {code} is not in model.sat_parent "
                f"and is not a new_satellite")
    for code in sorted(new):
        rows = new[code]
        anchors = {r["anchor"] for r in rows}
        cks = {(r.get("declared_child_key") or "") for r in rows}
        parent = next(iter(anchors)) if len(anchors) == 1 else None
        facts[(code, "augmented")] = SatelliteFact(
            code=code, track="augmented", parent=parent,
            childkey=next(iter(cks)) if len(cks) == 1 else None,
            parent_origin="own_spec" if parent else "none")
    for code in sorted(refs):
        facts[(code, "reference")] = SatelliteFact(
            code=code, track="reference", parent=None, childkey="",
            parent_origin="none")
    return tuple(facts[k] for k in sorted(facts))


def _hubs_links(spec: dict, blocks: list[dict]) -> tuple[tuple[str, ...], tuple[str, ...]]:
    codes: set[str] = set(_text(v) or "" for v in spec["model"]["sat_parent"].values())
    for b in blocks:
        codes.add(b.get("anchor") or "")
        rk = b["resolved_key"]
        codes.add(rk.get("hub") or "")
        codes.add(rk.get("link") or "")
        codes.update((rk.get("legs") or {}))
    hubs = tuple(sorted(c for c in codes if c.startswith("HUB_")))
    links = tuple(sorted(c for c in codes if c.startswith("LNK_")))
    return hubs, links


# --------------------------------------------------------------------------
# entry points
# --------------------------------------------------------------------------

def load_mxh3_report(project_root) -> tuple[IntermediateSpec, dict]:
    """Load ``mxh3_spec.json`` and return ``(IntermediateSpec, report)``.

    ``report`` holds counts for the smoke script and the README; it is not
    part of the spec.
    """
    root = Path(project_root)
    spec_path = root / SPEC_REL
    spec = json.loads(spec_path.read_text(encoding="utf-8"))
    digests: list[tuple[str, str]] = [(SPEC_REL, _sha256(spec_path))]

    # unresolved[]: every kind must be known (UnknownPriorKind otherwise).
    for u in spec["unresolved"]:
        reason_for_prior_kind(u["kind"])

    stems = _stems(spec)
    views = {**spec["views"]["staging"], **spec["views"]["hopviews"]}
    legacy: dict[str, dict[str, str]] = {}
    for rel in (LEGACY_STAGING_REL, LEGACY_HOPVIEWS_REL):
        directory = root / rel
        for f in sorted(directory.glob("*.sql"), key=lambda p: p.name):
            digests.append((f"{rel}/{f.name}", _sha256(f)))
        for table, cols in legacy_types(directory).items():
            merged = legacy.setdefault(table, {})
            for c, k in cols.items():
                if merged.setdefault(c, k) != k:
                    raise AdapterError(f"{table}.{c}: conflicting legacy types")

    blocks: list[dict] = spec["blocks"]
    view_cols = {t: {c.upper() for c in v["columns"]} for t, v in views.items()}
    for pos, b in enumerate(blocks):
        if b["view"] not in spec["views"]["staging"]:
            raise AdapterError(f"blocks#{pos}: view {b['view']} not in views.staging")
        if b["column"].upper() not in view_cols[b["view"]]:
            raise AdapterError(
                f"blocks#{pos}: column {b['column']} not on {b['view']}")

    walks = _walks(spec, set(views))
    report: Counter = Counter()
    slots = _collect_slots(spec, blocks, view_cols, walks, report)

    # Governed groups: an explicit hub_key / link_key row decides (Req. 4.5).
    governed = {(b["view"].upper(), (b["anchor"] or "").upper(), _text(b.get("instance")))
                for b in blocks if b["kind"] in _KEY_ROW_KINDS
                and b["outcome"] == "mapped"}
    conflict_blocks: set[int] = set()
    conflict_groups: list[str] = []
    key_slots: list[KeySlot] = []
    for (table, code, instance), group in sorted(
            slots.groups.items(), key=lambda kv: (kv[0][0], kv[0][1], kv[0][2] or "")):
        for _, (slot, _) in sorted(group.items()):
            key_slots.append(slot)
        if code.startswith("LNK_"):
            # The planner builds link keys from per-hub keys; the link slot's
            # own expression is never chosen between, so it cannot mis-key.
            continue
        if len(group) > 1 and (table.upper(), code.upper(), instance) not in governed:
            report["slot_groups_conflicting"] += 1
            conflict_groups.append(
                f"{table}|{code}|{instance}|{sorted(group)}")
            for _, contributors in group.values():
                conflict_blocks.update(contributors)
        elif len(group) > 1:
            report["slot_groups_multi_but_governed_by_key_row"] += 1

    rows = _rows(blocks, conflict_blocks)

    key_columns: dict[str, set[str]] = defaultdict(set)
    for s in key_slots:
        key_columns[s.table].update(c.upper() for c in s.source_columns)
    for r in rows:
        if r.target_kind in _KEY_ROW_KINDS:
            key_columns[r.table].add(r.column.upper())
    for w in walks:
        for t in w.tables:
            key_columns[t].update(c for c in _SPINE_COLUMNS if c in view_cols[t])
        key_columns[w.from_table].add(w.start_column.upper())

    tables = []
    for name in sorted(views):
        cols = []
        for c in sorted(set(views[name]["columns"])):
            kind, origin = resolve_type(name, c, {}, legacy)
            cols.append(Column(name=c.upper(), kind=kind, type_origin=origin,
                               is_key=c.upper() in key_columns.get(name, ())))
        tables.append(Table(name=name, stem=stems[name], columns=tuple(cols),
                            has_watermark_evidence="unknown"))

    hubs, links = _hubs_links(spec, blocks)
    sats = _satellites(spec, blocks)

    result = IntermediateSpec(
        project=PROJECT_NAME, tables=tuple(tables), hubs=hubs, links=links,
        satellites=sats, key_slots=tuple(key_slots), rows=rows, precedence=(),
        walks=walks, input_digests=tuple(sorted(digests))).canonical()

    report.update({
        "blocks": len(blocks),
        "rows": len(rows),
        "tables": len(tables),
        "satellites": len(sats),
        "hubs": len(hubs),
        "links": len(links),
        "key_slots": len(key_slots),
        "walks": len(walks),
        "input_digests": len(digests),
        "unresolved_entries": len(spec["unresolved"]),
        "conflict_rows": sum(1 for r in rows if r.spec_unresolved
                             == "anchor_does_not_resolve_uniquely"
                             and blocks[r.row_order].get("anchor_state") is None),
    })
    for r in rows:
        report[f"outcome:{r.outcome}"] += 1
        report[f"kind:{r.target_kind}"] += 1
        if r.spec_unresolved:
            report[f"spec_unresolved:{r.spec_unresolved}"] += 1
    out = dict(report)
    out["conflict_group_list"] = conflict_groups
    return result, out


def load_mxh3(project_root) -> IntermediateSpec:
    """Load the MAXIMUS Spec_JSON into an ``IntermediateSpec`` (see module doc)."""
    return load_mxh3_report(project_root)[0]
