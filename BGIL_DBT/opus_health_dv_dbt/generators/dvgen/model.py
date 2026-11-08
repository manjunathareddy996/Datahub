"""Data model shared by the adapters, the planner, the renderers and the README.

Every type is a frozen dataclass. ``build_artifacts/health_spec.json`` is the
JSON form of an ``IntermediateSpec`` with sorted keys; ``dump_spec`` and
``load_spec`` round-trip it exactly.

Determinism (Requirement 10.2):

- ``dumps`` writes sorted keys, two-space indent, ``\\n`` line endings and a
  single trailing newline. Nothing in the output depends on dict or
  file-system iteration order.
- ``IntermediateSpec.canonical()`` sorts the top-level collections, so two
  adapters that read the same inputs in a different order produce the same
  bytes. Ordered sequences inside a record (key-slot ``source_columns``,
  precedence table order, walk hops, gap ``row_ids``) keep their order,
  because that order carries meaning.
- ``Plan`` sorts its lists on construction: artifacts by (kind, path), gaps by
  (track, source_table, source_column, target, reason).

This module is project-agnostic and is copied byte-for-byte into the sibling
Health_Project (Requirement 10.3).

Requirements 4.1, 10.2.
"""
from __future__ import annotations

import dataclasses
import json
import types
import typing
from collections.abc import Iterator, Mapping
from dataclasses import dataclass, field
from pathlib import Path, PurePosixPath
from typing import Any, Union

SPEC_SCHEMA = "health_spec/v1"

# Closed value sets from the design's "Data Models" section.
COLUMN_KINDS = frozenset({"text", "number", "timestamp"})
TYPE_ORIGINS = frozenset({"index", "legacy", "untyped"})
WATERMARK_EVIDENCE = frozenset({"catalogue_yes", "catalogue_no", "unknown"})
KEY_SLOT_ORIGINS = frozenset({"map.KEY", "spec.key_slot", "spec.resolved_key"})
SATELLITE_TRACKS = frozenset({"standard", "augmented", "reference"})
PARENT_ORIGINS = frozenset({"own_spec", "sibling_model", "none"})
ROW_OUTCOMES = frozenset({"mapped", "augmentation_needed"})
TARGET_KINDS = frozenset(
    {"hub_key", "link_key", "satellite_attribute", "augmentation"}
)
GAP_REASONS = (
    "unresolved_mapping",
    "missing_grain_key",
    "missing_parent",
    "missing_childkey_field",
    "no_verified_augmentation_key",
)


class ModelError(ValueError):
    """A model value is outside its declared domain, or JSON does not fit."""


def _check(value: Any, allowed, what: str) -> None:
    if value not in allowed:
        raise ModelError(f"{what}={value!r} not in {sorted(allowed)}")


def _none_last_str(value: str | None) -> tuple[bool, str]:
    """Sort key that orders None before every string, deterministically."""
    return (value is not None, value or "")


# --------------------------------------------------------------------------
# Immutable mapping for free-form renderer data
# --------------------------------------------------------------------------

class FrozenDict(Mapping):
    """Read-only, hashable mapping with string keys.

    Values are frozen recursively: dicts become ``FrozenDict`` and lists
    become tuples. Used for ``Artifact.data`` so artifacts stay immutable.
    """

    __slots__ = ("_data", "_hash")

    def __init__(self, data: Mapping[str, Any] | None = None, **kwargs: Any):
        merged = dict(data or {}, **kwargs)
        for key in merged:
            if not isinstance(key, str):
                raise ModelError(f"FrozenDict keys must be str, got {key!r}")
        self._data = {k: freeze(merged[k]) for k in sorted(merged)}
        self._hash: int | None = None

    def __getitem__(self, key: str) -> Any:
        return self._data[key]

    def __iter__(self) -> Iterator[str]:
        return iter(self._data)

    def __len__(self) -> int:
        return len(self._data)

    def __hash__(self) -> int:
        if self._hash is None:
            self._hash = hash(dumps(self))
        return self._hash

    def __repr__(self) -> str:
        return f"FrozenDict({self._data!r})"


def freeze(value: Any) -> Any:
    """Return an immutable copy of a JSON-like value."""
    if isinstance(value, FrozenDict):
        return value
    if isinstance(value, Mapping):
        return FrozenDict(value)
    if isinstance(value, (list, tuple)):
        return tuple(freeze(v) for v in value)
    if value is None or isinstance(value, (str, int, float, bool)):
        return value
    if dataclasses.is_dataclass(value) and not isinstance(value, type):
        return value
    raise ModelError(f"cannot freeze value of type {type(value).__name__}")


# --------------------------------------------------------------------------
# Intermediate spec
# --------------------------------------------------------------------------

@dataclass(frozen=True)
class Column:
    name: str            # upper physical name, e.g. "CLAIM_ID"
    kind: str            # "text" | "number" | "timestamp"
    type_origin: str     # "index" | "legacy" | "untyped"
    is_key: bool         # any hub/link key component -> cast to trimmed varchar

    def __post_init__(self) -> None:
        _check(self.kind, COLUMN_KINDS, "Column.kind")
        _check(self.type_origin, TYPE_ORIGINS, "Column.type_origin")


@dataclass(frozen=True)
class Table:
    name: str            # physical name, e.g. "BJAZ_HM_GPA_BILL_DTLS"
    stem: str            # lower table name (OPUS) | legacy stem (MAXIMUS)
    columns: tuple[Column, ...]
    has_watermark_evidence: str   # "catalogue_yes" | "catalogue_no" | "unknown"

    def __post_init__(self) -> None:
        _check(self.has_watermark_evidence, WATERMARK_EVIDENCE,
               "Table.has_watermark_evidence")
        names = [c.name for c in self.columns]
        if len(names) != len(set(names)):
            raise ModelError(f"Table {self.name}: duplicate column names")

    def column(self, name: str) -> Column | None:
        upper = name.upper()
        for col in self.columns:
            if col.name.upper() == upper:
                return col
        return None


@dataclass(frozen=True)
class KeySlot:
    table: str
    vault_code: str      # HUB_* or LNK_*
    instance: str | None
    expression: str      # spec expression, before column rewriting
    source_columns: tuple[str, ...]   # ordered key components
    origin: str          # "map.KEY" | "spec.key_slot" | "spec.resolved_key"

    def __post_init__(self) -> None:
        _check(self.origin, KEY_SLOT_ORIGINS, "KeySlot.origin")

    def sort_key(self) -> tuple:
        return (self.table, self.vault_code, _none_last_str(self.instance),
                self.origin, self.expression, self.source_columns)


@dataclass(frozen=True)
class SatelliteFact:
    code: str
    track: str           # "standard" | "augmented" | "reference"
    parent: str | None
    childkey: str | None # None = field absent; "" = single-active
    parent_origin: str   # "own_spec" | "sibling_model" | "none"

    def __post_init__(self) -> None:
        _check(self.track, SATELLITE_TRACKS, "SatelliteFact.track")
        _check(self.parent_origin, PARENT_ORIGINS, "SatelliteFact.parent_origin")

    @property
    def is_multi_active(self) -> bool:
        return bool(self.childkey)


@dataclass(frozen=True)
class MappingRow:
    row_id: str          # "<file>#<index>" or "blocks#<i>"
    row_order: int
    table: str
    column: str
    outcome: str         # "mapped" | "augmentation_needed"
    target_kind: str     # "hub_key" | "link_key" | "satellite_attribute" | "augmentation"
    vault_code: str | None
    attribute: str | None
    instance: str | None
    redundant_of: str | None
    child_key_expr: str | None
    spec_unresolved: str | None   # prior unresolved kind, if any

    def __post_init__(self) -> None:
        _check(self.outcome, ROW_OUTCOMES, "MappingRow.outcome")
        _check(self.target_kind, TARGET_KINDS, "MappingRow.target_kind")


@dataclass(frozen=True)
class Walk:
    """A MAXIMUS spine walk from ``spans[]``.

    The walk starts on ``from_table`` at ``start_column`` (for example
    ``PARENT_KEY_HASH``), climbs through ``climb`` (each hop joins
    ``PARENT_KEY_HASH`` to the next view's ``KEY_HASH``), then descends
    through ``descend`` to ``terminal_table``.``terminal_column``.
    """
    walk_id: str                 # "spans#<ordinal>"
    from_table: str
    start_column: str
    climb: tuple[str, ...]       # ordered real climb hops
    descend: tuple[str, ...]     # ordered real descent hops
    terminal_table: str
    terminal_column: str
    raw: str                     # spec text, kept for header comments

    @property
    def tables(self) -> tuple[str, ...]:
        """Every table the walk touches, in walk order, without repeats."""
        seen: list[str] = []
        for t in (self.from_table, *self.climb, *self.descend,
                  self.terminal_table):
            if t not in seen:
                seen.append(t)
        return tuple(seen)


@dataclass(frozen=True)
class IntermediateSpec:
    project: str
    tables: tuple[Table, ...]
    hubs: tuple[str, ...]
    links: tuple[str, ...]
    satellites: tuple[SatelliteFact, ...]
    key_slots: tuple[KeySlot, ...]
    rows: tuple[MappingRow, ...]
    precedence: tuple[tuple[str, str, tuple[str, ...]], ...]  # (sat, attribute, ordered tables)
    walks: tuple[Walk, ...]       # MAXIMUS spine walks
    input_digests: tuple[tuple[str, str], ...]   # (relative input path, sha256)

    def canonical(self) -> IntermediateSpec:
        """Return a copy with every top-level collection in a fixed order.

        Inner ordered sequences (column order of a key, precedence table
        order, walk hops) are left as they are.
        """
        tables = tuple(
            dataclasses.replace(
                t, columns=tuple(sorted(t.columns, key=lambda c: c.name)))
            for t in sorted(self.tables, key=lambda t: t.name)
        )
        return dataclasses.replace(
            self,
            tables=tables,
            hubs=tuple(sorted(set(self.hubs))),
            links=tuple(sorted(set(self.links))),
            satellites=tuple(sorted(self.satellites,
                                    key=lambda s: (s.code, s.track))),
            key_slots=tuple(sorted(self.key_slots, key=KeySlot.sort_key)),
            rows=tuple(sorted(self.rows,
                              key=lambda r: (r.row_order, r.row_id))),
            precedence=tuple(sorted(self.precedence)),
            walks=tuple(sorted(self.walks, key=lambda w: w.walk_id)),
            input_digests=tuple(sorted(self.input_digests)),
        )

    def table(self, name: str) -> Table | None:
        for t in self.tables:
            if t.name == name:
                return t
        return None


# --------------------------------------------------------------------------
# Plan
# --------------------------------------------------------------------------

@dataclass(frozen=True)
class Gap:
    track: str
    source_table: str
    source_column: str | None     # None for table- or satellite-level gaps
    target: str                   # e.g. "SAT_CLAIM_NOTE.Note Text"
    reason: str                   # one of GAP_REASONS
    detail: str                   # candidates checked, spec reason text
    row_ids: tuple[str, ...]

    def __post_init__(self) -> None:
        _check(self.reason, GAP_REASONS, "Gap.reason")

    def sort_key(self) -> tuple:
        return (self.track, self.source_table,
                _none_last_str(self.source_column), self.target, self.reason,
                self.detail, self.row_ids)


@dataclass(frozen=True)
class DerivedFact:
    """A fact recovered from a Spec_JSON or legacy SQL (Requirement 4.4).

    ``category`` examples: "hub", "link", "satellite_parent",
    "satellite_childkey", "column_type", "untyped_column", "legacy_stem",
    "source_location". ``subject`` names the thing (vault code, or
    ``TABLE.COLUMN``); ``value`` is the recovered value; ``origin`` says where
    it came from (for example "own_spec", "sibling_model", "index").
    """
    category: str
    subject: str
    value: str | None
    origin: str
    source: str = ""              # input file or spec path, relative

    def sort_key(self) -> tuple:
        return (self.category, self.subject, _none_last_str(self.value),
                self.origin, self.source)


@dataclass(frozen=True)
class WatermarkRisk:
    table: str
    evidence: str                 # "catalogue_no" | "unknown"
    source: str                   # input that gave the evidence, relative

    def __post_init__(self) -> None:
        _check(self.evidence, WATERMARK_EVIDENCE, "WatermarkRisk.evidence")

    def sort_key(self) -> tuple:
        return (self.table, self.evidence, self.source)


@dataclass(frozen=True)
class Artifact:
    """One file the emitter will write.

    ``kind`` selects the renderer (for example "stg1", "sources_yml",
    "stage", "bridge", "hub", "link", "sat", "stitch", "stitch_stage", "ref").
    ``path`` is relative to the project root, in POSIX form. ``data`` holds the
    renderer's inputs as an immutable JSON-like mapping.
    """
    kind: str
    path: str
    name: str                     # dbt model name (file stem)
    data: FrozenDict = field(default_factory=FrozenDict)

    def __post_init__(self) -> None:
        if not self.kind:
            raise ModelError("Artifact.kind is empty")
        p = PurePosixPath(self.path)
        if (not self.path or "\\" in self.path or p.is_absolute()
                or ".." in p.parts or str(p) != self.path):
            raise ModelError(
                f"Artifact.path must be a normalized relative POSIX path: "
                f"{self.path!r}")
        if not isinstance(self.data, FrozenDict):
            object.__setattr__(self, "data", FrozenDict(self.data))

    def sort_key(self) -> tuple:
        return (self.kind, self.path)


@dataclass(frozen=True)
class Plan:
    """Planner output. Every list is sorted on construction."""
    artifacts: tuple[Artifact, ...]
    gaps: tuple[Gap, ...]
    derived_facts: tuple[DerivedFact, ...]
    watermark_risks: tuple[WatermarkRisk, ...]
    hist_skips: tuple[tuple[str, str], ...] = ()   # (_HIST table, current twin)
    not_fed: tuple[str, ...] = ()                  # model objects with no feed

    def __post_init__(self) -> None:
        arts = tuple(sorted(self.artifacts, key=Artifact.sort_key))
        paths = [a.path for a in arts]
        dupes = sorted({p for p in paths if paths.count(p) > 1})
        if dupes:
            raise ModelError(f"Plan has duplicate artifact paths: {dupes}")
        object.__setattr__(self, "artifacts", arts)
        object.__setattr__(self, "gaps",
                           tuple(sorted(self.gaps, key=Gap.sort_key)))
        object.__setattr__(self, "derived_facts",
                           tuple(sorted(set(self.derived_facts),
                                        key=DerivedFact.sort_key)))
        object.__setattr__(self, "watermark_risks",
                           tuple(sorted(set(self.watermark_risks),
                                        key=WatermarkRisk.sort_key)))
        object.__setattr__(self, "hist_skips",
                           tuple(sorted(set(self.hist_skips))))
        object.__setattr__(self, "not_fed", tuple(sorted(set(self.not_fed))))


# --------------------------------------------------------------------------
# JSON encoding and decoding
# --------------------------------------------------------------------------

def to_jsonable(obj: Any) -> Any:
    """Convert a model value to plain JSON types (dict, list, str, ...)."""
    if dataclasses.is_dataclass(obj) and not isinstance(obj, type):
        return {f.name: to_jsonable(getattr(obj, f.name))
                for f in dataclasses.fields(obj)}
    if isinstance(obj, Mapping):
        return {str(k): to_jsonable(v) for k, v in obj.items()}
    if isinstance(obj, (list, tuple)):
        return [to_jsonable(v) for v in obj]
    if obj is None or isinstance(obj, (str, int, float, bool)):
        return obj
    raise ModelError(f"not JSON-serializable: {type(obj).__name__}")


def dumps(obj: Any) -> str:
    """Deterministic JSON text: sorted keys, indent 2, one trailing newline."""
    return json.dumps(to_jsonable(obj), sort_keys=True, indent=2,
                      ensure_ascii=False, allow_nan=False) + "\n"


_HINTS: dict[type, dict[str, Any]] = {}


def _hints(cls: type) -> dict[str, Any]:
    if cls not in _HINTS:
        _HINTS[cls] = typing.get_type_hints(cls)
    return _HINTS[cls]


def from_jsonable(tp: Any, value: Any, where: str = "$") -> Any:
    """Build a value of type ``tp`` from plain JSON data, checking shape."""
    if tp is Any:
        return freeze(value)
    if tp is FrozenDict:
        if not isinstance(value, dict):
            raise ModelError(f"{where}: expected object")
        return FrozenDict(value)
    origin = typing.get_origin(tp)
    args = typing.get_args(tp)
    if origin is Union or origin is types.UnionType:
        if value is None and type(None) in args:
            return None
        options = [a for a in args if a is not type(None)]
        if len(options) != 1:
            raise ModelError(f"{where}: unsupported union {tp!r}")
        return from_jsonable(options[0], value, where)
    if origin is tuple:
        if not isinstance(value, list):
            raise ModelError(f"{where}: expected array")
        if len(args) == 2 and args[1] is Ellipsis:
            return tuple(from_jsonable(args[0], v, f"{where}[{i}]")
                         for i, v in enumerate(value))
        if len(value) != len(args):
            raise ModelError(
                f"{where}: expected {len(args)} items, got {len(value)}")
        return tuple(from_jsonable(a, v, f"{where}[{i}]")
                     for i, (a, v) in enumerate(zip(args, value)))
    if isinstance(tp, type) and dataclasses.is_dataclass(tp):
        if not isinstance(value, dict):
            raise ModelError(f"{where}: expected object for {tp.__name__}")
        hints = _hints(tp)
        fields = {f.name: f for f in dataclasses.fields(tp)}
        unknown = sorted(set(value) - set(fields))
        if unknown:
            raise ModelError(f"{where}: unknown {tp.__name__} keys {unknown}")
        kwargs = {}
        for name, f in fields.items():
            if name not in value:
                if (f.default is dataclasses.MISSING
                        and f.default_factory is dataclasses.MISSING):
                    raise ModelError(
                        f"{where}: missing {tp.__name__}.{name}")
                continue
            kwargs[name] = from_jsonable(hints[name], value[name],
                                         f"{where}.{name}")
        try:
            return tp(**kwargs)
        except ModelError as exc:
            raise ModelError(f"{where}: {exc}") from None
    if tp is bool:
        if not isinstance(value, bool):
            raise ModelError(f"{where}: expected boolean")
        return value
    if tp is int:
        if isinstance(value, bool) or not isinstance(value, int):
            raise ModelError(f"{where}: expected integer")
        return value
    if tp is str:
        if not isinstance(value, str):
            raise ModelError(f"{where}: expected string")
        return value
    raise ModelError(f"{where}: unsupported type {tp!r}")


# --------------------------------------------------------------------------
# build_artifacts/health_spec.json
# --------------------------------------------------------------------------

def dump_spec(spec: IntermediateSpec) -> str:
    """Return the canonical ``health_spec.json`` text for ``spec``.

    The caller writes it (through the emitter's write guard).
    """
    body = to_jsonable(spec.canonical())
    body["schema"] = SPEC_SCHEMA
    return json.dumps(body, sort_keys=True, indent=2, ensure_ascii=False,
                      allow_nan=False) + "\n"


def parse_spec(text: str) -> IntermediateSpec:
    """Parse ``health_spec.json`` text back into an ``IntermediateSpec``."""
    try:
        body = json.loads(text)
    except json.JSONDecodeError as exc:
        raise ModelError(f"health_spec.json is not valid JSON: {exc}") from None
    if not isinstance(body, dict):
        raise ModelError("health_spec.json: top level must be an object")
    schema = body.pop("schema", None)
    if schema != SPEC_SCHEMA:
        raise ModelError(
            f"health_spec.json: schema {schema!r}, expected {SPEC_SCHEMA!r}")
    return from_jsonable(IntermediateSpec, body)


def load_spec(path: Path) -> IntermediateSpec:
    """Read ``build_artifacts/health_spec.json``."""
    return parse_spec(Path(path).read_text(encoding="utf-8"))
