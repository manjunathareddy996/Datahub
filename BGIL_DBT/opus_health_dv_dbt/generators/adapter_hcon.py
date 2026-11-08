"""OPUS adapter: ``hcon_spec.json`` + the settled and DELTA3 column maps
-> ``dvgen.model.IntermediateSpec``.

Public API
----------
``load_hcon(project_root, sibling_spec=None)`` returns the pair
``(IntermediateSpec, SiblingModel | None)``. The design sketch passes the
sibling model in; here the adapter builds it, because it already reads the
inputs and records their digests. Hand the pair to the planner::

    spec, sibling = load_hcon(root)
    plan(spec, project_config, sibling)

``sibling`` is ``None`` when the sibling Spec_JSON is not on disk, and the
planner then has no fallback (design Q3, step 2). ``load_hcon_full`` returns
an ``HconLoad`` with the same two values plus row counts and the accounting of
the Spec_JSON ``unresolved[]`` list. Paths are explicit parameters, so the
adapter does not import ``project_config``.

Input checks (stop with ``InputCheckError``, naming both values)
----------------------------------------------------------------
1. sha256 of ``inputs/04_column_map.SETTLED_post_stage6_65b.json`` equals
   ``hcon_spec.json`` ``meta.input.sha256``. The DELTA3 map is checked against
   ``meta.input.delta3.sha256`` the same way when the Spec_JSON records one.
2. settled rows + DELTA3 rows equal ``meta.map_rows`` (4,184).
3. ``inputs/OPUS_Health_Consolidated_Mapping.xlsx``, sheet
   ``Consolidated Mapping``, is read with ``openpyxl`` (loaded through
   ``dvgen.prereqs.require``). The workbook renders the settled map only (its
   Summary says 3,677 rows; the 507 DELTA3 rows are not in it), so its row
   count and its ``mapped`` count are compared with the settled JSON counts
   (3,677 and 2,572).

Mapping rows (Requirements 4.1, 4.5, 8.3)
-----------------------------------------
Rows are read in file order, settled first, then DELTA3. ``row_id`` is
``<file name>#<index in file>``; ``row_order`` is the index in the settled
file, and ``len(settled) + index`` for DELTA3 (so "workbook order" is one
total order). Table and column names are upper-cased (DELTA3 has 57
lower-case column names; the index and ``views[]`` use upper case).

- ``mapped`` -> standard track. ``target.kind`` is ``hub_key``, ``link_key``
  (``vault_code`` = ``target.anchor``) or ``satellite_attribute``
  (``vault_code`` = ``target.satellite``, ``attribute`` = ``target.attribute``,
  ``child_key_expr`` = ``target.child_key_value`` verbatim, which is already
  in the planner's ``<part> = <value> | <part> = <value>`` leg format).
  ``instance`` and ``redundant_of`` come from ``target``.
- ``augmentation_needed`` -> augmented track, ``target_kind`` =
  ``augmentation``. The record is ``row.augmentation`` (16 settled rows keep
  it in ``row.target`` instead). ``attribute`` = ``proposed_attribute`` (or the
  ``proposed`` spelling of 4 rows); ``vault_code`` = ``best_home_satellite``,
  else the leading ``SAT_*`` / ``REF_*`` code of ``new_satellite`` (the text
  after the code is prose and is dropped); ``instance``, ``redundant_of`` and
  ``child_key_value`` are read from the same record. A row with no code (51
  rows carry only a ``reason`` text, 1 has a purely prose ``new_satellite``)
  gets ``vault_code=None`` and the planner records ``prose_only_home``. The
  code is never pulled out of free text. (Cross-check: for the 1,135 rows with
  a code, ``hcon_spec`` ``satellites[].payload`` has a writer for the same
  satellite on the same table and column.)
- ``unmapped`` rows (85 settled) are not Mapped_Rows: they are skipped and
  counted in ``HconLoad.counts["unmapped_skipped"]``.

Satellites (Requirements 4.1, 6.5, 6.10)
----------------------------------------
``satellites[]`` has one record per (code, ``track``). The hcon track maps to
the planner's track like this:

=============  ===========  ==================================================
hcon track     planner      why
=============  ===========  ==================================================
ratified       standard     the writers of these records are all ``mapped`` rows
unratified     augmented    all but 16 writers are ``augmentation_needed`` rows,
                            and the planner looks up an Augmentation_Row on
                            ``(code, augmented)`` first
reference      reference    ``REF_*`` tables (``plan_references``)
=============  ===========  ==================================================

The mapping is injective per code, so ``(code, track)`` stays unique.
``parent`` = ``anchor`` (``None`` when empty; the 22 empty ones are all
``unratified`` and become ``missing_parent`` gaps), ``parent_origin`` =
``own_spec`` or ``none``, ``childkey`` = ``model_childkey`` (``""`` is
single-active, ``None`` only if the field is absent from a record).

Hubs, links, key slots, tables
------------------------------
- ``hubs`` / ``links``: ``loaders[]`` entries with ``kind`` ``hub`` / ``link``
  (every loader, including the 78 with ``buildable=false``; the planner lists
  those without a feed as "model object, not fed").
- ``key_slots[]`` -> ``KeySlot(table=view, vault_code=vault_table, ...)``.
  Origin ``map.resolved_key`` -> ``spec.resolved_key``; ``legacy_emitted_sql``
  -> ``spec.key_slot``. Link slots keep their ``LNK(...)`` expression text; the
  planner builds link keys from the hub slots of the same table. 22
  (view, vault code, instance) triples have several slots ("multiple
  registries"); all are kept, and ``choose_business_key`` picks one
  deterministically.
- ``tables``: every ``views[]`` table (134, the same set as the map tables).
  ``columns`` = ``views[].columns`` + every mapped column + every key-slot
  source column (26 slot columns are missing from ``views[]``), upper case.
  ``kind`` / ``type_origin`` come from ``dvgen.types.resolve_type`` (index =
  ``inputs/00_tables_index.DELTA3.json``, legacy = ``legacy_v3/models/staging``).
  ``is_key`` marks key-slot source columns and hub/link key row columns.
  ``stem`` = lower-case table name (``STEM_RULE`` ``lower_table``).
  ``has_watermark_evidence``: ``catalogue_yes`` if the index lists the table
  with ``INC_JOB_UPDATED_AT``, ``catalogue_no`` if it lists the table without
  it, ``unknown`` if the table is not in the index.

Precedence (Requirement 6.5)
----------------------------
``r8[]`` records give run order (``precedence``: runs). The planner wants
tables, so each run is replaced by the sorted tables that write the attribute
in that run (from ``satellites[].payload[].writers``). Only ``ratified`` r8
records are used (they feed standard-track stitches; the 18 ``unratified``
ones belong to the augmented track, which the planner does not stitch).

Prior unresolved records (Requirements 8.3)
-------------------------------------------
Every ``unresolved[]`` kind goes through ``gaps.reason_for_prior_kind``, so an
unknown kind stops the build with ``UnknownPriorKind``. One kind is stamped on
rows as ``MappingRow.spec_unresolved``, because it is a mapper decision that
the planner cannot rediscover: ``child_key_leg_refused`` marks every
satellite row (any track) on the (satellite, view) of the record. Every other
kind concerns a fact the planner derives itself and gives the same gap
reason: missing key on a view (``anchor_not_keyed_...``,
``legacy_key_not_recoverable``, ``view_has_no_recoverable_key_at_all`` ->
``missing_grain_key`` with its bridge search and candidate list),
``satellite_has_no_anchor`` -> ``missing_parent``, prose home ->
``prose_only_home``, ``payload_collides_with_child_key_leg`` -> the planner's
collision check, ``multiple_registries_key_this_view_hub`` (the mapper
already says the first key is used; informational) and
``loader_has_no_feed_in_the_map`` (not a gap). ``HconLoad.unresolved`` lists,
per kind, how many records exist, how they are treated and how many rows were
stamped.

Determinism (Requirement 10.2): inputs are read in file order, no clocks, and
the returned spec is ``canonical()``.
"""
from __future__ import annotations

import dataclasses
import hashlib
import json
import os
import re
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Mapping, Optional

from dvgen import gaps as gapmod
from dvgen import types as typesmod
from dvgen.model import (
    Column,
    IntermediateSpec,
    KeySlot,
    MappingRow,
    ModelError,
    SatelliteFact,
    Table,
)
from dvgen.plan import SiblingModel
from dvgen.prereqs import require

__all__ = [
    "AdapterError",
    "InputCheckError",
    "HconLoad",
    "SETTLED_MAP",
    "DELTA3_MAP",
    "HCON_SPEC",
    "TABLES_INDEX",
    "WORKBOOK",
    "LEGACY_STAGING",
    "SIBLING_SPEC",
    "WORKBOOK_SHEET",
    "TRACK_MAP",
    "ROW_STAMPED_KINDS",
    "load_hcon",
    "load_hcon_full",
    "check_inputs",
    "workbook_counts",
]

# Input paths, relative to the project root.
SETTLED_MAP = "inputs/04_column_map.SETTLED_post_stage6_65b.json"
DELTA3_MAP = "inputs/04_column_map.DELTA3.json"
HCON_SPEC = "build_artifacts/hcon_spec.json"
TABLES_INDEX = "inputs/00_tables_index.DELTA3.json"
WORKBOOK = "inputs/OPUS_Health_Consolidated_Mapping.xlsx"
LEGACY_STAGING = "legacy_v3/models/staging"
SIBLING_SPEC = "../maximus_health_dv_dbt/build_artifacts/mxh3_spec.json"

WORKBOOK_SHEET = "Consolidated Mapping"
WATERMARK_CATALOGUE_COLUMN = "INC_JOB_UPDATED_AT"

# hcon satellite track -> planner track (see the module docstring).
TRACK_MAP = {
    "ratified": "standard",
    "unratified": "augmented",
    "reference": "reference",
}
# Prior unresolved kinds stamped on mapping rows (all others: planner-derived).
ROW_STAMPED_KINDS = frozenset({"child_key_leg_refused"})

_CODE_AT_START = re.compile(r"((?:SAT|REF)_[A-Z0-9_]+)(?=\s|\(|$)")
_SAT_ROW_KINDS = ("satellite_attribute", "augmentation")


class AdapterError(ModelError):
    """An input has a shape the adapter does not understand."""


class InputCheckError(AdapterError):
    """An input check failed; ``expected`` and ``actual`` are both shown."""

    def __init__(self, what: str, expected: Any, actual: Any):
        self.what, self.expected, self.actual = what, expected, actual
        super().__init__(f"{what}: expected {expected!r}, actual {actual!r}")


@dataclass(frozen=True)
class HconLoad:
    """Everything ``load_hcon_full`` produces."""
    spec: IntermediateSpec
    sibling_model: Optional[SiblingModel]
    counts: Mapping[str, int] = field(default_factory=dict)
    # (kind, records, treatment, records_with_rows, rows_stamped)
    unresolved: tuple[tuple[str, int, str, int, int], ...] = ()
    # Slot columns that views[] does not list, as (TABLE, COLUMN).
    slot_columns_added: tuple[tuple[str, str], ...] = ()


# --------------------------------------------------------------------------
# File helpers
# --------------------------------------------------------------------------

def _sha256(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def _json(path: Path) -> Any:
    try:
        return json.loads(Path(path).read_text(encoding="utf-8"))
    except FileNotFoundError:
        raise AdapterError(f"input not found: {path}") from None
    except json.JSONDecodeError as exc:
        raise AdapterError(f"{Path(path).name}: not valid JSON: {exc}") from None


def _rel(path: Path, root: Path) -> str:
    return Path(os.path.relpath(path, root)).as_posix()


def _s(value: Any) -> Optional[str]:
    """Stripped non-empty string, else ``None``."""
    if isinstance(value, str) and value.strip():
        return value.strip()
    return None


# --------------------------------------------------------------------------
# Input checks
# --------------------------------------------------------------------------

def workbook_counts(workbook: Path) -> dict[str, int]:
    """Row counts of the workbook's ``Consolidated Mapping`` sheet.

    Returns ``{"rows": n, "<outcome>": n, ...}``. ``openpyxl`` is loaded
    through ``dvgen.prereqs.require`` (a missing module stops with the
    install message).
    """
    openpyxl = require("openpyxl")["openpyxl"]
    wb = openpyxl.load_workbook(workbook, read_only=True, data_only=True)
    try:
        if WORKBOOK_SHEET not in wb.sheetnames:
            raise AdapterError(
                f"{Path(workbook).name}: no sheet {WORKBOOK_SHEET!r}; "
                f"sheets are {wb.sheetnames}")
        rows = wb[WORKBOOK_SHEET].iter_rows(values_only=True)
        header = next(rows, None)
        if not header or "Outcome" not in header:
            raise AdapterError(
                f"{Path(workbook).name}/{WORKBOOK_SHEET}: no 'Outcome' column")
        col = list(header).index("Outcome")
        counts: Counter = Counter()
        for row in rows:
            if row is None or all(v is None for v in row):
                continue
            counts["rows"] += 1
            counts[str(row[col]).strip() if col < len(row) and row[col] is not None
                   else ""] += 1
        return dict(counts)
    finally:
        wb.close()


def check_inputs(root: Path, hcon: Mapping[str, Any], settled: list,
                 delta3: list) -> dict[str, int]:
    """Run the three input checks; raise ``InputCheckError`` on a mismatch.

    Returns the workbook counts for the caller's report.
    """
    root = Path(root)
    meta_input = (hcon.get("meta") or {}).get("input") or {}
    expected = meta_input.get("sha256")
    actual = _sha256(root / SETTLED_MAP)
    if expected != actual:
        raise InputCheckError(
            f"sha256 of {SETTLED_MAP} vs hcon_spec.json meta.input.sha256",
            expected, actual)
    d3 = (meta_input.get("delta3") or {}).get("sha256")
    if d3 is not None:
        d3_actual = _sha256(root / DELTA3_MAP)
        if d3 != d3_actual:
            raise InputCheckError(
                f"sha256 of {DELTA3_MAP} vs hcon_spec.json "
                f"meta.input.delta3.sha256", d3, d3_actual)

    map_rows = (hcon.get("meta") or {}).get("map_rows")
    total = len(settled) + len(delta3)
    if map_rows != total:
        raise InputCheckError(
            f"settled rows ({len(settled)}) + DELTA3 rows ({len(delta3)}) "
            f"vs hcon_spec.json meta.map_rows", map_rows, total)

    wb = workbook_counts(root / WORKBOOK)
    json_rows = len(settled)
    json_mapped = sum(1 for c in settled if c.get("outcome") == "mapped")
    if wb.get("rows", 0) != json_rows:
        raise InputCheckError(
            f"row count of {WORKBOOK} sheet {WORKBOOK_SHEET!r} vs settled "
            f"JSON rows", json_rows, wb.get("rows", 0))
    if wb.get("mapped", 0) != json_mapped:
        raise InputCheckError(
            f"mapped-row count of {WORKBOOK} sheet {WORKBOOK_SHEET!r} vs "
            f"settled JSON mapped rows", json_mapped, wb.get("mapped", 0))
    return wb


# --------------------------------------------------------------------------
# Mapping rows
# --------------------------------------------------------------------------

def _augmentation_record(row: Mapping[str, Any]) -> Mapping[str, Any]:
    aug = row.get("augmentation")
    if isinstance(aug, dict):
        return aug
    target = row.get("target")
    if isinstance(target, dict) and ("proposed_attribute" in target
                                     or "proposed" in target):
        return target
    return {}


def _augmentation_code(aug: Mapping[str, Any]) -> Optional[str]:
    home = _s(aug.get("best_home_satellite"))
    if home:
        return home
    match = _CODE_AT_START.match(_s(aug.get("new_satellite")) or "")
    return match.group(1) if match else None


def _row_from(file_name: str, index: int, order: int,
              raw: Mapping[str, Any]) -> Optional[MappingRow]:
    """One MappingRow, or ``None`` for an ``unmapped`` row."""
    outcome = raw.get("outcome")
    if outcome == "unmapped":
        return None
    if outcome not in ("mapped", "augmentation_needed"):
        raise AdapterError(f"{file_name}#{index}: unknown outcome {outcome!r}")
    table = _s(raw.get("table_name"))
    column = _s(raw.get("column_name"))
    if not table or not column:
        raise AdapterError(f"{file_name}#{index}: missing table or column name")
    common = dict(row_id=f"{file_name}#{index}", row_order=order,
                  table=table.upper(), column=column.upper(), outcome=outcome)

    if outcome == "augmentation_needed":
        aug = _augmentation_record(raw)
        return MappingRow(
            target_kind="augmentation",
            vault_code=_augmentation_code(aug),
            attribute=_s(aug.get("proposed_attribute")) or _s(aug.get("proposed")),
            instance=_s(aug.get("instance")),
            redundant_of=_s(aug.get("redundant_of")),
            child_key_expr=_s(aug.get("child_key_value")),
            spec_unresolved=None, **common)

    target = raw.get("target") or {}
    kind = target.get("kind")
    if kind in ("hub_key", "link_key"):
        return MappingRow(
            target_kind=kind, vault_code=_s(target.get("anchor")),
            attribute=None, instance=_s(target.get("instance")),
            redundant_of=_s(target.get("redundant_of")), child_key_expr=None,
            spec_unresolved=None, **common)
    if kind == "satellite_attribute":
        return MappingRow(
            target_kind=kind, vault_code=_s(target.get("satellite")),
            attribute=_s(target.get("attribute")),
            instance=_s(target.get("instance")),
            redundant_of=_s(target.get("redundant_of")),
            child_key_expr=_s(target.get("child_key_value")),
            spec_unresolved=None, **common)
    raise AdapterError(
        f"{file_name}#{index}: mapped row with target.kind {kind!r}")


def _load_rows(settled: list, delta3: list) -> tuple[list[MappingRow], int]:
    rows: list[MappingRow] = []
    skipped = 0
    for file_name, data, offset in (
            (Path(SETTLED_MAP).name, settled, 0),
            (Path(DELTA3_MAP).name, delta3, len(settled))):
        for i, raw in enumerate(data):
            row = _row_from(file_name, i, offset + i, raw)
            if row is None:
                skipped += 1
            else:
                rows.append(row)
    return rows, skipped


# --------------------------------------------------------------------------
# Satellites, hubs, links, key slots, precedence
# --------------------------------------------------------------------------

def _satellites(hcon: Mapping[str, Any]) -> tuple[SatelliteFact, ...]:
    out: list[SatelliteFact] = []
    for rec in hcon.get("satellites") or []:
        code = _s(rec.get("code"))
        track = TRACK_MAP.get(rec.get("track"))
        if not code or track is None:
            raise AdapterError(
                f"satellites[]: bad record code={rec.get('code')!r} "
                f"track={rec.get('track')!r}")
        parent = _s(rec.get("anchor"))
        childkey = rec.get("model_childkey")
        out.append(SatelliteFact(
            code=code, track=track, parent=parent,
            childkey=None if "model_childkey" not in rec else (childkey or ""),
            parent_origin="own_spec" if parent else "none"))
    keys = Counter((s.code, s.track) for s in out)
    dupes = sorted(k for k, n in keys.items() if n > 1)
    if dupes:
        raise AdapterError(f"satellites[]: duplicate (code, track): {dupes}")
    return tuple(out)


def _loader_codes(hcon: Mapping[str, Any], kind: str) -> tuple[str, ...]:
    return tuple(sorted({l["code"] for l in hcon.get("loaders") or []
                         if l.get("kind") == kind}))


_SLOT_ORIGIN = {"map.resolved_key": "spec.resolved_key",
                "legacy_emitted_sql": "spec.key_slot"}


def _key_slots(hcon: Mapping[str, Any]) -> tuple[KeySlot, ...]:
    out: list[KeySlot] = []
    for rec in hcon.get("key_slots") or []:
        origin = _SLOT_ORIGIN.get(rec.get("origin"))
        if origin is None:
            raise AdapterError(
                f"key_slots[] {rec.get('id')!r}: unknown origin "
                f"{rec.get('origin')!r}")
        out.append(KeySlot(
            table=rec["view"].upper(), vault_code=rec["vault_table"],
            instance=_s(rec.get("instance")),
            expression=rec.get("expression") or "",
            source_columns=tuple(rec.get("source_columns") or ()),
            origin=origin))
    return tuple(out)


def _precedence(hcon: Mapping[str, Any]) -> tuple[tuple[str, str, tuple[str, ...]], ...]:
    """``(satellite, attribute, ordered tables)`` from the ratified r8 records."""
    payload: dict[tuple[str, str], dict[str, list]] = {}
    for sat in hcon.get("satellites") or []:
        if sat.get("track") != "ratified":
            continue
        for entry in sat.get("payload") or []:
            payload[(sat["code"], entry["attribute"])] = entry
    out: set = set()
    for rec in hcon.get("r8") or []:
        if rec.get("track") != "ratified":
            continue
        entry = payload.get((rec["satellite"], rec["attribute"]))
        if entry is None:
            raise AdapterError(
                f"r8[]: {rec['satellite']}.{rec['attribute']} has no payload "
                f"entry on the ratified satellite")
        by_run: dict[str, set] = defaultdict(set)
        for w in entry.get("writers") or []:
            by_run[w["run"]].add(w["view"].upper())
        tables: list[str] = []
        for run in rec["precedence"]:
            for t in sorted(by_run.get(run, ())):
                if t not in tables:
                    tables.append(t)
        if tables:
            out.add((rec["satellite"], rec["attribute"], tuple(tables)))
    return tuple(sorted(out))


# --------------------------------------------------------------------------
# Tables
# --------------------------------------------------------------------------

def _tables(hcon: Mapping[str, Any], rows: list[MappingRow],
            slots: tuple[KeySlot, ...], index: Mapping[str, Mapping[str, str]],
            legacy: Mapping[str, Mapping[str, str]]
            ) -> tuple[tuple[Table, ...], tuple[tuple[str, str], ...]]:
    columns: dict[str, set[str]] = {}
    for view in hcon.get("views") or []:
        columns.setdefault(view["table"].upper(), set()).update(
            c.upper() for c in view.get("columns") or [])
    listed = {t: set(c) for t, c in columns.items()}
    key_cols: dict[str, set[str]] = defaultdict(set)
    for row in rows:
        columns.setdefault(row.table, set()).add(row.column)
        if row.target_kind in ("hub_key", "link_key"):
            key_cols[row.table].add(row.column)
    added: list[tuple[str, str]] = []
    for slot in slots:
        for col in slot.source_columns:
            upper = col.strip().upper()
            key_cols[slot.table].add(upper)
            if upper not in columns.setdefault(slot.table, set()):
                columns[slot.table].add(upper)
            if slot.table in listed and upper not in listed[slot.table]:
                added.append((slot.table, upper))

    tables: list[Table] = []
    for name in sorted(columns):
        indexed = index.get(name)
        if indexed is None:
            evidence = "unknown"
        elif WATERMARK_CATALOGUE_COLUMN in indexed:
            evidence = "catalogue_yes"
        else:
            evidence = "catalogue_no"
        cols = []
        for col in sorted(columns[name]):
            kind, origin = typesmod.resolve_type(name, col, index, legacy)
            cols.append(Column(name=col, kind=kind, type_origin=origin,
                               is_key=col in key_cols.get(name, ())))
        tables.append(Table(name=name, stem=name.lower(), columns=tuple(cols),
                            has_watermark_evidence=evidence))
    return tuple(tables), tuple(sorted(set(added)))


# --------------------------------------------------------------------------
# Prior unresolved records
# --------------------------------------------------------------------------

def _stamp_unresolved(hcon: Mapping[str, Any], rows: list[MappingRow]
                      ) -> tuple[list[MappingRow], tuple]:
    """Stamp ``spec_unresolved`` on rows; return rows and the accounting."""
    by_pair: dict[tuple[str, str], list[int]] = defaultdict(list)
    for i, row in enumerate(rows):
        if row.target_kind in _SAT_ROW_KINDS and row.vault_code:
            by_pair[(row.vault_code, row.table)].append(i)

    totals: Counter = Counter()
    with_rows: Counter = Counter()
    stamped: dict[int, str] = {}
    for rec in hcon.get("unresolved") or []:
        kind = rec.get("kind")
        gapmod.reason_for_prior_kind(kind)  # unknown kinds raise here
        totals[kind] += 1
        if kind not in ROW_STAMPED_KINDS:
            continue
        sat, view = _s(rec.get("satellite")), _s(rec.get("view"))
        hits = by_pair.get((sat, view.upper()), []) if sat and view else []
        if hits:
            with_rows[kind] += 1
        for i in hits:
            stamped.setdefault(i, kind)

    stamped_by_kind = Counter(stamped.values())
    report = []
    for kind in sorted(totals):
        if kind in ROW_STAMPED_KINDS:
            treatment = "stamped on rows"
        elif gapmod.reason_for_prior_kind(kind) is None:
            treatment = "not a gap"
        else:
            treatment = "planner derives the gap"
        report.append((kind, totals[kind], treatment, with_rows[kind],
                       stamped_by_kind[kind]))
    out = [dataclasses.replace(r, spec_unresolved=stamped[i]) if i in stamped
           else r for i, r in enumerate(rows)]
    return out, tuple(report)


# --------------------------------------------------------------------------
# Entry points
# --------------------------------------------------------------------------

def load_hcon_full(project_root: Path,
                   sibling_spec: Optional[Path] = None) -> HconLoad:
    """Check the inputs and build the intermediate spec.

    ``project_root`` is ``opus_health_dv_dbt``. ``sibling_spec`` defaults to
    ``../maximus_health_dv_dbt/build_artifacts/mxh3_spec.json`` under the
    project root; if that file does not exist the sibling model is ``None``.
    """
    root = Path(project_root).resolve()
    hcon = _json(root / HCON_SPEC)
    settled = _json(root / SETTLED_MAP).get("columns")
    delta3 = _json(root / DELTA3_MAP).get("columns")
    if not isinstance(settled, list) or not isinstance(delta3, list):
        raise AdapterError("column maps must have a 'columns' list")

    wb = check_inputs(root, hcon, settled, delta3)

    rows, skipped = _load_rows(settled, delta3)
    rows, unresolved = _stamp_unresolved(hcon, rows)
    slots = _key_slots(hcon)
    index = typesmod.index_types(root / TABLES_INDEX)
    legacy = typesmod.legacy_types(root / LEGACY_STAGING)
    tables, slot_added = _tables(hcon, rows, slots, index, legacy)

    digests = [(SETTLED_MAP, _sha256(root / SETTLED_MAP)),
               (DELTA3_MAP, _sha256(root / DELTA3_MAP)),
               (HCON_SPEC, _sha256(root / HCON_SPEC)),
               (TABLES_INDEX, _sha256(root / TABLES_INDEX)),
               (WORKBOOK, _sha256(root / WORKBOOK))]
    for sql in sorted((root / LEGACY_STAGING).glob("*.sql")):
        digests.append((_rel(sql, root), _sha256(sql)))

    sibling: Optional[SiblingModel] = None
    sibling_path = (Path(sibling_spec) if sibling_spec is not None
                    else (root / SIBLING_SPEC).resolve())
    if sibling_path.is_file():
        rel = _rel(sibling_path, root)
        sibling = SiblingModel.from_mxh3(_json(sibling_path), source=rel)
        digests.append((rel, _sha256(sibling_path)))

    spec = IntermediateSpec(
        project="opus_health_dv_dbt",
        tables=tables,
        hubs=_loader_codes(hcon, "hub"),
        links=_loader_codes(hcon, "link"),
        satellites=_satellites(hcon),
        key_slots=slots,
        rows=tuple(rows),
        precedence=_precedence(hcon),
        walks=(),
        input_digests=tuple(digests),
    ).canonical()

    by_outcome = Counter(r.outcome for r in rows)
    counts = {
        "settled_rows": len(settled),
        "delta3_rows": len(delta3),
        "map_rows": len(settled) + len(delta3),
        "mapped": by_outcome["mapped"],
        "augmentation_needed": by_outcome["augmentation_needed"],
        "unmapped_skipped": skipped,
        "workbook_rows": wb.get("rows", 0),
        "workbook_mapped": wb.get("mapped", 0),
    }
    return HconLoad(spec=spec, sibling_model=sibling, counts=counts,
                    unresolved=unresolved, slot_columns_added=slot_added)


def load_hcon(project_root: Path, sibling_spec: Optional[Path] = None
              ) -> tuple[IntermediateSpec, Optional[SiblingModel]]:
    """``(IntermediateSpec, SiblingModel | None)`` for ``project_root``."""
    loaded = load_hcon_full(project_root, sibling_spec)
    return loaded.spec, loaded.sibling_model
