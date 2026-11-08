"""Planner: turn an ``IntermediateSpec`` into a ``Plan`` (design "plan.py").

The planner never writes files. ``plan(spec, cfg, sibling_model)`` runs a
fixed list of steps over one mutable ``PlanContext`` and freezes the result
into a ``model.Plan`` (which sorts every list, Requirement 10.2).

Steps, in order (later tasks append to ``STEPS``):

1. ``plan_tables``        one Stg1 artifact per referenced table, ``_HIST``
                          skips, watermark risks (Requirements 3.1, 3.9, 3.10).
2. ``plan_satellites``    parent and child key per satellite with the Q3
                          fallback; omitted satellites become gaps
                          (Requirements 4.1, 4.3).
3. ``record_model_facts`` hubs, links, parents and child keys as
                          Derived_Facts with their origin (Requirement 4.4).
4. ``plan_branches``      satellite branches and fan-in (Requirements 4.2,
                          6.6, 6.7, 8.3); output in ``ctx.branches``.
5. ``plan_grain_keys``   parent key, bridges and hub stages per branch
                          (Requirements 4.5, 6.8, 6.9, 9.6); output in
                          ``ctx.key_resolutions``.
6. ``plan_stitches``      stitch or union (Requirements 7.1, 7.2, 7.3).
7. ``plan_satellite_models`` satellite stages and ``sat`` models, macro
                          choice (Requirements 4.2, 6.3, 6.4, 6.5).
8. ``plan_references``    ``ref`` views for reference-track satellites
                          (Requirement 6.10).
9. ``plan_link_stages``, ``plan_hub_link_models``, ``plan_not_fed``: link
                          stages, ``hub`` and ``link`` models, model objects
                          with no feed (Requirement 4.2).

Later steps read ``ctx.tables`` (planned Stg1 tables by name),
``ctx.hist_skipped`` (skipped ``_HIST`` table -> twin),
``ctx.satellites`` (resolved ``SatelliteFact`` by ``(code, track)``) and
``ctx.branches`` (sorted ``Branch`` list); every gapped row id is listed in
``ctx.gapped_rows``.

Project configuration
---------------------
``cfg`` is any object with the attributes of ``ProjectConfig`` (for example
the ``generators/project_config.py`` module). Optional attributes, read with
``getattr``:

- ``SPEC_SOURCE``: relative path of the Spec_JSON, used as
  ``DerivedFact.source`` for own-spec facts (default ``""``).
- ``COLUMN_CATALOGUE``: relative path of the column catalogue (OPUS
  ``inputs/00_tables_index.DELTA3.json``), used as ``WatermarkRisk.source``
  for ``catalogue_no`` tables (default ``""``).

Stg1 artifact contract (consumed by ``render_stg1.py``)
-------------------------------------------------------
``Artifact(kind="stg1", path="models/staging/health/stg_health__<stem>.sql",
name="stg_health__<stem>", data=...)`` with ``data`` keys:

- ``table``  (str) physical source table name, as in the spec (upper case).
- ``stem``   (str) model-name stem (lowercased table name for OPUS, legacy
  stem for MAXIMUS).
- ``source`` (str) dbt source name for ``{{ source(source, table) }}``
  (``cfg.STG1_SOURCE``).
- ``columns`` (tuple of mappings) every table column except the watermark
  column, sorted by ``name``. Each entry has:
  ``name`` (upper physical column name), ``kind`` (``text`` | ``number`` |
  ``timestamp``), ``type_origin`` (``index`` | ``legacy`` | ``untyped``),
  ``is_key`` (bool; True when the column is a hub/link key component, either
  flagged by the adapter or listed in a key slot of this table). Key columns
  and ``text`` columns are cast to trimmed varchar.
- ``watermark`` (str) the table's watermark column,
  ``naming.watermark_for(table, cfg.WATERMARK_COLUMN,
  cfg.WATERMARK_OVERRIDES)``, exactly as configured (lower case in this
  build). It is never in ``columns``; the renderer selects it last as
  ``"<WATERMARK upper>"::timestamp_ntz as <watermark lower>``.
- ``watermark_evidence`` (str) ``catalogue_yes`` | ``catalogue_no`` |
  ``unknown``: the catalogue evidence for the watermark column. A table with
  a ``WATERMARK_OVERRIDES`` entry reports ``unknown`` (the catalogue evidence
  is about the default column). The renderer writes the ``WATERMARK RISK``
  header line when the value is ``catalogue_no``.

``data`` is a ``FrozenDict``; lists arrive as tuples.

Satellite gaps
--------------
An omitted satellite produces gaps on its mapping rows (rows whose
``vault_code`` is the satellite code and whose track matches), one gap per
(table, column, target) with every row id. ``missing_parent`` takes
precedence on rows, so a row is in exactly one gap. A reason not carried by a
row gap (no rows target the satellite, or the child-key gap of a satellite
that also lacks a parent) is recorded once as a satellite-level gap with
``source_table=""``, ``source_column=None`` and ``row_ids=()``. A row is not
gapped when another fact for the same code and track resolved.

Branches (step 4)
-----------------
``plan_branches`` reads every ``satellite_attribute`` / ``augmentation`` row
that is not already in ``ctx.gapped_rows`` and ends each one in exactly one
``Branch`` or exactly one gap (Property 16). Rows are checked in this order:

1. No vault code, or no attribute with an alphanumeric character:
   ``prose_only_home`` gap.
2. ``spec_unresolved`` set: ``gaps.gap_from_prior`` (an unknown kind stops
   the build; a kind mapped to ``None`` is not a gap and the row goes on).
3. Table skipped as a ``_HIST`` twin: ``unresolved_mapping`` gap (the table
   has no Stg1 model).
4. Satellite lookup. A Mapped_Row uses ``(code, standard)``, else
   ``(code, reference)``; an Augmentation_Row uses ``(code, augmented)``,
   else the ``(code, standard)`` fact (parent and child key of its home).
   No fact: ``missing_parent`` gap ("no satellite record").
5. On a multi-active satellite, an attribute that names a child-key part
   (same text, ignoring case and spacing): ``payload_collides_with_child_key_leg``
   gap.

A branch track is the satellite fact's track for Mapped_Rows (``standard``
or ``reference``) and ``augmented`` for Augmentation_Rows.

Collisions stop the build (``PlanError`` naming both names): inside one
(branch track, satellite), two attribute texts that differ beyond case and
spacing but give the same ``naming.payload_column``, two child-key parts
with the same ``naming.ck_column``, or an attribute and a child-key part with
the same column.

Key instance. A row's ``instance`` is the key instance when the parent has a
business key for (table, parent, instance) by ``keys.choose_business_key``
(a role such as ``insured`` with its own key slot). Otherwise the key
instance is ``None`` and the instance is a child-key literal. Rows are
grouped by (branch track, satellite, table, key instance), then by payload
column. For the rows of one payload column, a row's discriminator is its
child-key literal instance, else its ``child_key_expr`` text:

- One row: one payload entry.
- Several rows, every discriminator present and pairwise distinct
  (coexisting values): on a multi-active satellite one unit per row
  (Requirement 6.7); on a single-active satellite a
  ``distinct_values_single_active`` gap on every row (defect class #1: the
  values are never collapsed).
- Otherwise (fallbacks): one payload entry over every column in
  ``row_order``: the bare alias when there is one distinct column, else a
  list of aliases rendered as ``coalesce`` (Requirement 6.6). The header
  notes name every column with its row id.

A single-active group gives one branch with every payload entry. On a
multi-active satellite each unit's child key is resolved per row (below);
the rows of a fallback unit must agree. Units with the same child-key value
share one branch, so one stage carries every attribute of that value. A unit
whose child key does not resolve gets a ``child_key_leg_unresolved`` gap.

Child key (multi-active only). ``SatelliteFact.childkey`` lists its parts
separated by ``+`` (``"Contact Point Type + Contact Priority Order"``); each
part becomes the column ``naming.ck_column(part)``, in that order. Values:

- A single-part child key takes the row's literal instance when present.
- Otherwise ``child_key_expr`` gives the legs: legs separated by ``|`` (not
  ``||``, and not inside braces, parentheses or quotes), each
  ``<part> = <value>``; a single unnamed value is allowed for a single-part
  child key. On a multi-part child key the literal instance fills the one
  part the legs leave empty, if exactly one is left.
- ``<value>`` is ``{<sql>}`` (data-driven: an expression over the table's
  columns, rewritten to stg1 aliases by ``keys.rewrite_columns``), a quoted
  ``'literal'`` or bare literal text.
- A leg does not resolve when it is empty, names no part of the child key,
  leaves a part without a value, or its ``{<sql>}`` references no column of
  the table, a spine walk (``[...]`` segment or single ``:``) or a lone
  ``|``.

Childkey entries follow the ``render_stage`` contract: ``{"column",
"literal"}`` (rendered ``'!<literal>'``) or ``{"column", "expr"}``.

Grain keys and hub feeds (step 5)
---------------------------------
``plan_grain_keys`` resolves, for every non-reference branch, the parent key
and stores a ``KeyResolution`` in ``ctx.key_resolutions`` under
``Branch.sort_key()`` (task 4.9 builds the sat/aug stages from it).

- Hub parent: ``choose_business_key(table, hub, key instance)``; the raw
  expression is ``keys.raw_key`` over the table's columns, read from the
  table's stg1 model. Link parent: every hub of the link needs a key on the
  table (no bridge); ``hub_keys`` follows ``cfg.TEMPLATE_LINK_HUB_ORDER``
  (``template_links.py``, the Template_Project ``src_fk`` order) when the
  template has the link, else sorted hub codes. Hubs of a link not in the
  template are the known hubs whose names split the link name exactly.
- No key: bridge search. Key-slot graph (any project): a table B keyed on
  the hub that shares a key (same column set) on some other hub G with the
  table; candidates that feed a link between G and the hub come first, then
  lexical order of B, then G. Spine walks (``spec.walks`` starting at the
  table and ending on a table keyed on the hub) are tried after that. Walk
  tables get their own Stg1 models from ``plan_tables``.
- A ``bridge`` artifact (``bridge_<stem>__<hub>``, ``render_stage`` contract)
  is planned under ``models/raw_vault/{standard|augmented}/staging``
  (``standard`` when any standard branch reads it). Its extra columns are
  aliased ``bridge_<col>``, so they never clash with the table's columns.
- Branches with no key and no bridge are dropped from ``ctx.branches``: one
  gap per (table, column, target) with all row ids, reason
  ``missing_grain_key`` (``no_verified_augmentation_key`` on the augmented
  track), detail listing each candidate checked and why it failed. Rows go in
  ``ctx.gapped_rows``.
- Hub stages: one ``stage_hub`` artifact per (table, hub, key instance) used
  by a kept branch, named ``naming.stg2_model("hub", stem, hub)`` plus
  ``__<slug of the instance>`` when the instance is not null (``_2``... on a
  slug clash), at ``models/raw_vault/standard/staging``. It reads the same
  source model and PARENT_BK as the satellite stage on that key (gate G4); a
  differing PARENT_BK stops the build.

Stitch or union, macro choice, augmented track (steps 6 to 9)
-------------------------------------------------------------
Satellite groups are ``(track, satellite)`` over ``ctx.branches`` with a key
resolution; track ``reference`` is handled by ``plan_references``.

- Stitch (standard track only). A satellite gets a ``stitch`` when the spec
  declares ``spec.precedence`` for it (``(sat, attribute, ordered tables)``),
  it has branches on two or more tables, every table has exactly one branch
  with no key instance, the satellite is single-active with a hub parent, and
  every branch has the same ``KeyResolution.parent_bk`` (one key expression).
  Otherwise the stages are unioned by the satellite macro and, when a
  precedence was declared, the reason is written in the ``sat`` header
  (``header`` lines starting ``stitch not used``). With a stitch, the
  per-table stage models of that satellite are not emitted; the ``sat``
  reads the ``stitch_stage`` (macro ``sat``, ``src_extra_columns``
  ``["DBT_RUN_TS"]``). Sources are sorted by table; the ladder of a payload
  column lists the precedence tables first (in declared order, providers
  only), then the other providers sorted by table.
- Macro choice. One stage: ``sat`` (single-active) or ``ma_sat``. Two or more
  stages: ``sat_multi_source`` or ``ma_sat_multi_source`` with
  ``src_column_map`` ``{stage: [payload columns of its branches]}`` and every
  ``src_record_source_map`` value ``cfg.RECORD_SOURCE_GROUP``. ``unique_key``
  is left to the renderer default.
- Augmented track. Augmentation_Rows go through the same steps; the
  satellite model is ``sat_aug_<name>``, stages are ``stage_aug``
  (``stg2_aug_...``) under ``models/raw_vault/augmented``. A branch without a
  key already got its ``no_verified_augmentation_key`` gap in step 5, so no
  second gap is recorded here.

Artifact contracts emitted by steps 6 to 9 (the ``Artifact.data`` shapes are
documented in ``render_stage``, ``render_vault``, ``render_stitch`` and
``render_ref``):

- ``stage_sat`` / ``stage_aug``: ``models/raw_vault/{standard|augmented}/
  staging/stg2_{sat|aug}_<stem>__<sat>[__<branch>].sql``; ``target``,
  ``source_model`` (the branch's key source model), ``table``,
  ``record_source``, ``load_datetime``, ``parent_code``, ``parent_bk`` (hub
  parent) or ``hub_keys`` (link parent), ``payload`` (``{"column", "expr"}``,
  ``expr`` a list for fan-in), ``childkey``, ``header_notes``.
- ``sat``: ``models/raw_vault/standard/satellites/sat_<name>.sql`` or
  ``models/raw_vault/augmented/satellites/sat_aug_<name>.sql``.
- ``stitch`` / ``stitch_stage``: ``models/raw_vault/standard/stitched/
  stitch_<name>.sql`` and ``.../standard/staging/stg2_sat_stitch__<name>.sql``.
- ``ref``: ``models/raw_vault/standard/references/ref_<name>.sql``. One
  source per table (columns of all branches of the table merged); a source
  lacking a column another source has gets ``cast(null as varchar)``.
- ``stage_link``: ``.../standard/staging/stg2_link_<stem>__<link>[__<inst>]``
  for every (table, link, key instance) that a link-parent satellite branch
  uses, and for every table with a link key slot or ``link_key`` row whose
  link hubs all have a key on the table.
- ``hub`` / ``link``: ``.../standard/hubs/hub_<name>.sql`` and
  ``.../standard/links/lnk_<name>.sql``; ``source_model`` lists every
  ``stage_hub`` / ``stage_link`` of the code; ``src_fk`` follows the hub order
  of its stage_link (template order when the template has the link).
- ``ctx.not_fed``: hubs and links of the spec with no ``hub`` / ``link``
  artifact, and satellites of the spec with no ``sat`` / ``ref`` artifact and
  no mapping row at all.

This module is project-agnostic and is copied byte-for-byte into the sibling
Health_Project (Requirement 10.3).

Requirements 3.1, 3.9, 4.1, 4.2, 4.3, 4.4, 4.5, 6.6, 6.7, 6.8, 6.9, 8.3, 9.6.
"""
from __future__ import annotations

import dataclasses
import re
from collections.abc import Callable, Mapping, Sequence
from dataclasses import dataclass, field
from typing import Any, Optional, Protocol

from . import gaps as gapmod
from .keys import _TOKEN, KeyRuleError, choose_business_key, raw_key, rewrite_columns
from .model import (
    Artifact,
    DerivedFact,
    FrozenDict,
    Gap,
    IntermediateSpec,
    MappingRow,
    ModelError,
    Plan,
    SatelliteFact,
    Table,
    WatermarkRisk,
)
from .naming import (
    NamingError,
    bridge_model,
    ck_column,
    payload_column,
    record_source,
    stg1_model,
    stg2_model,
    watermark_for,
)
from .naming import hkey, hub_model, link_model, ref_model, sat_model, source_tag
from .naming import stitch_model
from .render_stg1 import column_alias
from .render_stitch import stitch_stage_model

__all__ = [
    "PlanError",
    "ProjectConfig",
    "SiblingModel",
    "SatelliteResolution",
    "PlanContext",
    "STG1_DIR",
    "STG1_KIND",
    "HIST_SUFFIX",
    "referenced_tables",
    "hist_skips",
    "stg1_artifact",
    "resolve_satellite",
    "row_track",
    "plan_tables",
    "plan_satellites",
    "record_model_facts",
    "Branch",
    "childkey_parts",
    "parse_legs",
    "resolve_leg_value",
    "plan_branches",
    "KeyResolution",
    "link_hubs",
    "plan_grain_keys",
    "plan_stitches",
    "plan_satellite_models",
    "plan_references",
    "plan_link_stages",
    "plan_hub_link_models",
    "plan_not_fed",
    "STAGING_DIR",
    "STEPS",
    "plan",
]

STG1_DIR = "models/staging/health"
STG1_KIND = "stg1"
HIST_SUFFIX = "_HIST"

_SAT_ROW_KINDS = ("satellite_attribute", "augmentation")
_SPINE_COLUMNS = ("PARENT_KEY_HASH", "KEY_HASH")


class PlanError(ModelError):
    """The intermediate spec cannot be planned (the build stops)."""


class ProjectConfig(Protocol):
    """Attributes the planner reads from ``generators/project_config.py``."""
    PROJECT: str
    RECORD_SOURCE_PREFIX: str
    RECORD_SOURCE_GROUP: str
    WATERMARK_COLUMN: str
    WATERMARK_OVERRIDES: Mapping[str, str]
    STG1_SOURCE: str


# --------------------------------------------------------------------------
# Sibling model (the other Health_Project's data_7.js extract)
# --------------------------------------------------------------------------

@dataclass(frozen=True)
class SiblingModel:
    """Satellite parents and child keys from the sibling's ``data_7.js`` extract.

    For OPUS this is ``maximus_health_dv_dbt/build_artifacts/mxh3_spec.json``
    ``model.sat_parent`` / ``model.sat_childkey``. ``source`` is the relative
    path recorded on Derived_Facts taken from it.
    """
    sat_parent: Mapping[str, str]
    sat_childkey: Mapping[str, str] = field(default_factory=FrozenDict)
    source: str = ""

    def __post_init__(self) -> None:
        for name in ("sat_parent", "sat_childkey"):
            value = getattr(self, name)
            if not isinstance(value, FrozenDict):
                object.__setattr__(self, name, FrozenDict(value))

    @classmethod
    def from_mxh3(cls, spec_json: Mapping[str, Any],
                  source: str = "") -> SiblingModel:
        """Build from a parsed ``mxh3_spec.json`` (its ``model`` section)."""
        try:
            model = spec_json["model"]
            parents = model["sat_parent"]
        except (KeyError, TypeError):
            raise PlanError(
                "sibling model: mxh3_spec.json has no model.sat_parent") from None
        childkeys = model.get("sat_childkey", {}) or {}
        return cls(sat_parent={str(k): str(v or "") for k, v in parents.items()},
                   sat_childkey={str(k): str(v or "")
                                 for k, v in childkeys.items()},
                   source=source)

    def parent(self, code: str) -> Optional[str]:
        value = self.sat_parent.get(code)
        return value if value else None


# --------------------------------------------------------------------------
# Context
# --------------------------------------------------------------------------

@dataclass
class PlanContext:
    """Mutable accumulator shared by the steps; ``finish()`` freezes it."""
    spec: IntermediateSpec
    cfg: Any
    sibling: Optional[SiblingModel] = None
    artifacts: list[Artifact] = field(default_factory=list)
    gaps: list[Gap] = field(default_factory=list)
    derived_facts: list[DerivedFact] = field(default_factory=list)
    watermark_risks: list[WatermarkRisk] = field(default_factory=list)
    hist_skips: list[tuple[str, str]] = field(default_factory=list)
    not_fed: list[str] = field(default_factory=list)
    # Step outputs read by later steps.
    tables: dict[str, Table] = field(default_factory=dict)
    hist_skipped: dict[str, str] = field(default_factory=dict)
    satellites: dict[tuple[str, str], SatelliteFact] = field(default_factory=dict)
    gapped_rows: set[str] = field(default_factory=set)
    branches: list[Branch] = field(default_factory=list)
    # Step 5 output: ``Branch.sort_key()`` -> key resolution of that branch.
    key_resolutions: dict[tuple, KeyResolution] = field(default_factory=dict)
    # Step 6 output: ``(track, satellite)`` -> stitch stage model name, or
    # the reason a declared precedence could not be stitched.
    stitched: dict[tuple[str, str], str] = field(default_factory=dict)
    stitch_reasons: dict[tuple[str, str], str] = field(default_factory=dict)

    @property
    def spec_source(self) -> str:
        return str(getattr(self.cfg, "SPEC_SOURCE", "") or "")

    def finish(self) -> Plan:
        return Plan(artifacts=tuple(self.artifacts), gaps=tuple(self.gaps),
                    derived_facts=tuple(self.derived_facts),
                    watermark_risks=tuple(self.watermark_risks),
                    hist_skips=tuple(self.hist_skips),
                    not_fed=tuple(self.not_fed))


# --------------------------------------------------------------------------
# Step 1: tables
# --------------------------------------------------------------------------

def referenced_tables(spec: IntermediateSpec) -> set[str]:
    """Tables referenced by a mapping row, a key slot or a bridge walk."""
    names: set[str] = {r.table for r in spec.rows}
    names.update(s.table for s in spec.key_slots)
    for walk in spec.walks:
        names.update(walk.tables)
    names.discard("")
    return names


def hist_skips(names: set[str]) -> dict[str, str]:
    """``{_HIST table: current twin}`` for names ending in ``_HIST`` whose
    de-suffixed twin is also in ``names`` (Requirement 3.9). Names that only
    contain ``HIST`` elsewhere (``..._HISTORY``) are never skipped."""
    by_upper = {n.upper(): n for n in names}
    skips: dict[str, str] = {}
    for name in sorted(names):
        upper = name.upper()
        if upper.endswith(HIST_SUFFIX) and len(upper) > len(HIST_SUFFIX):
            twin = by_upper.get(upper[:-len(HIST_SUFFIX)])
            if twin is not None:
                skips[name] = twin
    return skips


def _key_columns(spec: IntermediateSpec) -> dict[str, set[str]]:
    keys: dict[str, set[str]] = {}
    for slot in spec.key_slots:
        keys.setdefault(slot.table, set()).update(
            c.upper() for c in slot.source_columns)
    # Spine-walk join columns are hash keys too (step 5 bridges join on them).
    for walk in spec.walks:
        chain = (walk.from_table, *walk.climb, *walk.descend)
        for table in chain:
            keys.setdefault(table, set()).update(_SPINE_COLUMNS)
        keys.setdefault(walk.from_table, set()).add(walk.start_column.upper())
        keys.setdefault(walk.terminal_table, set()).update(
            {walk.terminal_column.upper(), *_SPINE_COLUMNS})
    return keys


def stg1_artifact(table: Table, cfg: Any,
                  key_columns: frozenset[str] | set[str] = frozenset()) -> Artifact:
    """The Stg1 artifact of one table (contract in the module docstring)."""
    overrides = getattr(cfg, "WATERMARK_OVERRIDES", {}) or {}
    watermark = watermark_for(table.name, cfg.WATERMARK_COLUMN, overrides)
    evidence = ("unknown" if table.name.upper() in overrides
                else table.has_watermark_evidence)
    columns = [
        {"name": c.name, "kind": c.kind, "type_origin": c.type_origin,
         "is_key": bool(c.is_key or c.name.upper() in key_columns)}
        for c in sorted(table.columns, key=lambda c: c.name)
        if c.name.upper() != watermark.upper()
    ]
    name = stg1_model(table.stem)
    return Artifact(kind=STG1_KIND, path=f"{STG1_DIR}/{name}.sql", name=name,
                    data={"table": table.name, "stem": table.stem,
                          "source": cfg.STG1_SOURCE, "columns": columns,
                          "watermark": watermark,
                          "watermark_evidence": evidence})


def plan_tables(ctx: PlanContext) -> None:
    """One Stg1 artifact per referenced table, minus ``_HIST`` twins.

    Raises ``PlanError`` when a referenced table is not in ``spec.tables``
    (the adapter must describe it) or when two planned tables share a stem.
    """
    spec, cfg = ctx.spec, ctx.cfg
    names = referenced_tables(spec)
    by_name = {t.name: t for t in spec.tables}
    missing = sorted(names - set(by_name))
    if missing:
        raise PlanError(f"referenced tables missing from spec.tables: {missing}")
    skips = hist_skips(names)
    ctx.hist_skipped.update(skips)
    ctx.hist_skips.extend(sorted(skips.items()))

    keys = _key_columns(spec)
    overrides = getattr(cfg, "WATERMARK_OVERRIDES", {}) or {}
    catalogue = str(getattr(cfg, "COLUMN_CATALOGUE", "") or "")
    stems: dict[str, str] = {}
    for name in sorted(names - set(skips)):
        table = by_name[name]
        stem = table.stem.lower()
        if stem in stems:
            raise PlanError(
                f"table stem collision: {stems[stem]} and {name} both use "
                f"stem {stem!r}")
        stems[stem] = name
        ctx.tables[name] = table
        ctx.artifacts.append(stg1_artifact(table, cfg, keys.get(name, set())))
        if (table.has_watermark_evidence != "catalogue_yes"
                and name.upper() not in overrides):
            evidence = table.has_watermark_evidence
            source = (catalogue if evidence == "catalogue_no"
                      else "no column catalogue entry")
            ctx.watermark_risks.append(
                WatermarkRisk(table=name, evidence=evidence, source=source))


# --------------------------------------------------------------------------
# Step 2: satellite facts
# --------------------------------------------------------------------------

@dataclass(frozen=True)
class SatelliteResolution:
    """Outcome of the Q3 fallback for one satellite record.

    ``fact`` is the resolved satellite, or ``None`` when it is omitted.
    ``situations`` lists the gap situations (``parent_empty`` first, then
    ``childkey_field_absent``) that caused the omission.
    """
    fact: Optional[SatelliteFact]
    situations: tuple[str, ...]
    detail: Mapping[str, str] = field(default_factory=FrozenDict)


def resolve_satellite(sat: SatelliteFact,
                      sibling: Optional[SiblingModel] = None) -> SatelliteResolution:
    """Apply the Q3 fallback: own spec, then sibling model, then a gap.

    The child key is never taken from the sibling: an absent child-key field
    (``childkey is None``) is a ``childkey_field_absent`` situation.
    """
    situations: list[str] = []
    detail: dict[str, str] = {}
    parent, origin = None, "none"
    if sat.parent:
        parent = sat.parent
        origin = sat.parent_origin if sat.parent_origin != "none" else "own_spec"
    elif sibling is not None and sibling.parent(sat.code):
        parent, origin = sibling.parent(sat.code), "sibling_model"
    else:
        situations.append("parent_empty")
        where = ("not in the sibling model extract" if sibling is not None
                 else "no sibling model supplied")
        detail["parent_empty"] = f"parent empty in own spec; {where}"
    if sat.childkey is None:
        situations.append("childkey_field_absent")
        detail["childkey_field_absent"] = (
            "child-key field absent on the satellite record")
    if situations:
        return SatelliteResolution(None, tuple(situations), detail)
    fact = SatelliteFact(code=sat.code, track=sat.track, parent=parent,
                         childkey=sat.childkey, parent_origin=origin)
    return SatelliteResolution(fact, ())


def row_track(row: MappingRow) -> str:
    """``augmented`` for Augmentation_Rows, ``standard`` for Mapped_Rows."""
    return "augmented" if row.outcome == "augmentation_needed" else "standard"


def _row_matches(row: MappingRow, code: str, track: str) -> bool:
    if row.vault_code != code or row.target_kind not in _SAT_ROW_KINDS:
        return False
    rt = row_track(row)
    return rt == track or (track == "reference" and rt == "standard")


def plan_satellites(ctx: PlanContext) -> None:
    """Resolve every satellite; record gaps for omitted ones."""
    omitted: list[tuple[SatelliteFact, SatelliteResolution]] = []
    for sat in ctx.spec.satellites:
        res = resolve_satellite(sat, ctx.sibling)
        if res.fact is None:
            omitted.append((sat, res))
            continue
        key = (sat.code, sat.track)
        prior = ctx.satellites.get(key)
        if prior is not None and prior != res.fact:
            raise PlanError(
                f"satellite {sat.code} ({sat.track}) resolves two ways: "
                f"{prior.parent}/{prior.childkey!r} and "
                f"{res.fact.parent}/{res.fact.childkey!r}")
        ctx.satellites[key] = res.fact

    for sat, res in omitted:
        rows = [r for r in ctx.spec.rows
                if _row_matches(r, sat.code, sat.track)
                and not any(_row_matches(r, code, track)
                            for code, track in ctx.satellites)
                and r.row_id not in ctx.gapped_rows]
        row_situation = res.situations[0]
        sat_level = list(res.situations[1:] if rows else res.situations)
        groups: dict[tuple[str, str, str], list[str]] = {}
        for r in rows:
            target = f"{sat.code}.{r.attribute}" if r.attribute else sat.code
            groups.setdefault((r.table, r.column, target), []).append(r.row_id)
            ctx.gapped_rows.add(r.row_id)
        for (table, column, target), ids in sorted(groups.items()):
            ctx.gaps.append(Gap(
                track=sat.track, source_table=table, source_column=column,
                target=target, reason=gapmod.classify(row_situation),
                detail=res.detail[row_situation], row_ids=tuple(sorted(ids))))
        for situation in sat_level:
            ctx.gaps.append(Gap(
                track=sat.track, source_table="", source_column=None,
                target=sat.code, reason=gapmod.classify(situation),
                detail=res.detail[situation], row_ids=()))


# --------------------------------------------------------------------------
# Step 3: derived facts
# --------------------------------------------------------------------------

def record_model_facts(ctx: PlanContext) -> None:
    """Hubs, links, satellite parents and child keys as Derived_Facts."""
    src = ctx.spec_source
    sib_src = ctx.sibling.source if ctx.sibling is not None else ""
    known = set(ctx.spec.hubs) | set(ctx.spec.links)
    for code in ctx.spec.hubs:
        ctx.derived_facts.append(DerivedFact("hub", code, None, "own_spec", src))
    for code in ctx.spec.links:
        ctx.derived_facts.append(DerivedFact("link", code, None, "own_spec", src))
    for (code, track), fact in sorted(ctx.satellites.items()):
        subject = f"{code} ({track})"
        psrc = sib_src if fact.parent_origin == "sibling_model" else src
        ctx.derived_facts.append(DerivedFact(
            "satellite_parent", subject, fact.parent, fact.parent_origin, psrc))
        ctx.derived_facts.append(DerivedFact(
            "satellite_childkey", subject, fact.childkey, "own_spec", src))
        parent = fact.parent or ""
        if parent not in known:
            category = ("hub" if parent.upper().startswith("HUB_")
                        else "link" if parent.upper().startswith("LNK_")
                        else None)
            if category:
                ctx.derived_facts.append(DerivedFact(
                    category, parent, None, fact.parent_origin, psrc))


# --------------------------------------------------------------------------
# Step 4: branches and fan-in
# --------------------------------------------------------------------------

@dataclass(frozen=True)
class Branch:
    """One planned satellite stage branch (contract in the module docstring).

    ``payload`` entries are ``{"attribute", "column", "expr",
    "source_columns", "row_ids"}``: ``expr`` is an stg1 alias (str) or, for a
    fallback fan-in over several columns, a tuple of aliases in ``row_order``
    (rendered as ``coalesce``). ``source_columns`` are the physical columns
    behind ``expr``, in the same order. Entries are sorted by ``column``.
    ``childkey`` entries are ``{"column", "literal"}`` or ``{"column",
    "expr"}`` in child-key part order; empty on a single-active satellite.
    ``branch`` is the stage-name suffix for ``naming.stg2_model`` (``None``
    for the only branch of a single-active group without a key instance);
    it is unique within (track, satellite, table).
    """
    track: str
    satellite: str
    table: str
    key_instance: Optional[str]
    parent: str
    multi_active: bool
    branch: Optional[str]
    payload: tuple[FrozenDict, ...]
    childkey: tuple[FrozenDict, ...]
    header_notes: tuple[str, ...]
    row_ids: tuple[str, ...]

    def sort_key(self) -> tuple:
        return (self.track, self.satellite, self.table,
                self.key_instance is not None, self.key_instance or "",
                self.branch is not None, self.branch or "")


_WS = re.compile(r"\s+")
_SLUG = re.compile(r"[^a-z0-9]+")
_SINGLE_COLON = re.compile(r"(?<!:):(?!:)")
_SINGLE_PIPE = re.compile(r"(?<!\|)\|(?!\|)")
_IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_$]*")
_STRINGS = re.compile(r"'(?:[^']|'')*'?")
_SLUG_MAX = 40


def _norm_name(text: str) -> str:
    return _WS.sub(" ", text.strip()).casefold()


def childkey_parts(childkey: Optional[str]) -> tuple[str, ...]:
    """Child-key parts in order: ``"A + B"`` -> ``("A", "B")``."""
    if not childkey:
        return ()
    parts = tuple(p.strip() for p in childkey.split("+"))
    if any(not p for p in parts):
        raise PlanError(f"child key {childkey!r} has an empty part")
    return parts


def _split_top(text: str, sep: str) -> list[str]:
    """Split on ``sep`` outside quotes, braces and parentheses.

    For ``|`` a doubled ``||`` (SQL concatenation) is never a separator.
    """
    parts: list[str] = []
    buf: list[str] = []
    depth, quote, i = 0, None, 0
    while i < len(text):
        ch = text[i]
        if quote:
            if ch == quote:
                quote = None
        elif ch in "'\"":
            quote = ch
        elif ch in "{(":
            depth += 1
        elif ch in "})":
            depth = max(0, depth - 1)
        elif ch == sep and depth == 0:
            if sep == "|" and text[i + 1:i + 2] == "|":
                buf.append("||")
                i += 2
                continue
            parts.append("".join(buf))
            buf = []
            i += 1
            continue
        buf.append(ch)
        i += 1
    parts.append("".join(buf))
    return parts


def parse_legs(expr: str, parts: Sequence[str]) -> tuple[dict[str, str], str]:
    """Parse a ``child_key_expr`` into ``{part: raw value}``.

    Returns ``(legs, "")`` or ``({}, reason)`` when the legs do not parse.
    Parts are matched ignoring case and spacing; a single unnamed value is
    allowed for a single-part child key. Missing parts are not an error here.
    """
    by_norm = {_norm_name(p): p for p in parts}
    legs = [leg.strip() for leg in _split_top(expr or "", "|")]
    legs = [leg for leg in legs if leg]
    if not legs:
        return {}, "empty child-key leg expression"
    out: dict[str, str] = {}
    for leg in legs:
        pieces = _split_top(leg, "=")
        if len(pieces) == 1:
            if len(legs) == 1 and len(parts) == 1:
                return {parts[0]: leg}, ""
            return {}, f"unnamed leg {leg!r} on a child key with parts {list(parts)}"
        name, value = pieces[0].strip(), "=".join(pieces[1:]).strip()
        part = by_norm.get(_norm_name(name))
        if part is None:
            return {}, f"leg {name!r} is not a part of the child key {list(parts)}"
        if part in out:
            return {}, f"leg {name!r} given twice"
        out[part] = value
    return out, ""


def resolve_leg_value(raw: str, table_columns: Sequence[str]
                      ) -> tuple[Optional[tuple[str, str]], str]:
    """Resolve one leg value to ``("literal", text)`` or ``("expr", sql)``.

    Returns ``(value, "")`` or ``(None, reason)``.
    """
    v = (raw or "").strip()
    if not v:
        return None, "empty leg value"
    if v.startswith("{"):
        if not v.endswith("}") or not v[1:-1].strip():
            return None, f"malformed data-driven leg {v!r}"
        inner = v[1:-1].strip()
        code = _STRINGS.sub("''", inner)
        if "[" in code or _SINGLE_COLON.search(code):
            return None, f"leg {inner!r} needs a spine walk"
        if _SINGLE_PIPE.search(code):
            return None, f"leg {inner!r} lists alternatives with '|'"
        cols = {c.upper() for c in table_columns}
        if not any(m.group().upper() in cols for m in _IDENT.finditer(code)):
            return None, f"leg {inner!r} references no column of the table"
        return ("expr", rewrite_columns(inner, cols)), ""
    if len(v) >= 2 and v[0] == v[-1] == "'":
        text = v[1:-1].replace("''", "'")
        if not text.strip():
            return None, "empty quoted leg literal"
        return ("literal", text), ""
    return ("literal", v), ""


def _resolve_childkey(row: MappingRow, literal_instance: Optional[str],
                      parts: Sequence[str], table_columns: Sequence[str]
                      ) -> tuple[Optional[tuple[tuple[str, str, str], ...]], str, str]:
    """Child-key value of one row: ``((column, kind, value), ...)``.

    Returns ``(value, origin note, "")`` or ``(None, "", reason)``.
    """
    if len(parts) == 1 and literal_instance:
        return ((ck_column(parts[0]), "literal", literal_instance),), \
            "mapping instance", ""
    expr = (row.child_key_expr or "").strip()
    if not expr:
        return None, "", ("no literal instance and no child-key leg expression"
                          if len(parts) == 1 else
                          f"no child-key leg expression for parts {list(parts)}")
    legs, why = parse_legs(expr, parts)
    if why:
        return None, "", why
    origin = "leg expression"
    missing = [p for p in parts if p not in legs]
    if len(missing) == 1 and literal_instance:
        legs[missing[0]] = "'" + literal_instance.replace("'", "''") + "'"
        origin = "leg expression and mapping instance"
        missing = []
    if missing:
        return None, "", f"no leg for child-key part(s) {missing}"
    value: list[tuple[str, str, str]] = []
    for p in parts:
        resolved, why = resolve_leg_value(legs[p], table_columns)
        if resolved is None:
            return None, "", f"leg {p!r}: {why}"
        value.append((ck_column(p), resolved[0], resolved[1]))
    return tuple(value), origin, ""


def _slug(text: str) -> str:
    return _SLUG.sub("_", text.lower()).strip("_")[:_SLUG_MAX].strip("_")


def _lookup_fact(ctx: PlanContext, row: MappingRow
                 ) -> tuple[Optional[SatelliteFact], str]:
    code = row.vault_code or ""
    if row_track(row) == "augmented":
        fact = (ctx.satellites.get((code, "augmented"))
                or ctx.satellites.get((code, "standard")))
        return fact, "augmented"
    fact = (ctx.satellites.get((code, "standard"))
            or ctx.satellites.get((code, "reference")))
    return fact, (fact.track if fact is not None else "standard")


@dataclass
class _Unit:
    """Rows of one payload column that form one value: a single row, one
    coexisting row, or every fallback row."""
    column: str
    rows: list[MappingRow]


def _payload_entry(attribute: str, column: str, rows: Sequence[MappingRow]
                   ) -> tuple[FrozenDict, Optional[str]]:
    ordered = sorted(rows, key=lambda r: (r.row_order, r.row_id))
    cols: list[str] = []
    for r in ordered:
        if r.column.upper() not in (c.upper() for c in cols):
            cols.append(r.column)
    aliases = [column_alias(c) for c in cols]
    expr: Any = aliases[0] if len(aliases) == 1 else tuple(aliases)
    entry = FrozenDict(attribute=attribute, column=column, expr=expr,
                       source_columns=tuple(cols),
                       row_ids=tuple(r.row_id for r in ordered))
    note = None
    if len(ordered) > 1:
        listed = ", ".join(f"{r.column} ({r.row_id})" for r in ordered)
        how = (f"coalesce({', '.join(aliases)})" if len(aliases) > 1
               else aliases[0])
        note = f"{column}: fallback fan-in {how} in workbook row order from {listed}"
    return entry, note


def plan_branches(ctx: PlanContext) -> None:
    """Plan satellite branches and fan-in; store them in ``ctx.branches``.

    Every satellite row not already gapped ends in exactly one branch or one
    gap. See the module docstring for the rules.
    """
    spec = ctx.spec
    gap_rows: dict[tuple[str, str, Optional[str], str, str, str], list[str]] = {}

    def gap(track: str, row: MappingRow, target: str, situation: str,
            detail: str) -> None:
        key = (track, row.table, row.column, target,
               gapmod.classify(situation), detail)
        gap_rows.setdefault(key, []).append(row.row_id)
        ctx.gapped_rows.add(row.row_id)

    # (track, code) -> list of (row, fact, attribute column)
    candidates: dict[tuple[str, str], list[tuple[MappingRow, SatelliteFact, str]]] = {}
    for row in spec.rows:
        if row.target_kind not in _SAT_ROW_KINDS or row.row_id in ctx.gapped_rows:
            continue
        code = row.vault_code or ""
        target = f"{code}.{row.attribute}" if row.attribute else code
        rtrack = row_track(row)
        if not code:
            gap(rtrack, row, target or row.column, "prose_only_home",
                "row has no target satellite code")
            continue
        try:
            column = payload_column(row.attribute or "")
        except NamingError:
            gap(rtrack, row, target, "prose_only_home",
                f"attribute {row.attribute!r} has no alphanumeric character")
            continue
        fact, track = _lookup_fact(ctx, row)
        gtrack = track if fact is not None else rtrack
        if row.spec_unresolved:
            prior = gapmod.gap_from_prior(
                row.spec_unresolved, track=gtrack, source_table=row.table,
                source_column=row.column, target=target,
                detail="prior unresolved finding on the row in the Spec_JSON",
                row_ids=(row.row_id,))
            if prior is not None:
                key = (prior.track, prior.source_table, prior.source_column,
                       prior.target, prior.reason, prior.detail)
                gap_rows.setdefault(key, []).append(row.row_id)
                ctx.gapped_rows.add(row.row_id)
                continue
        if row.table in ctx.hist_skipped:
            gap(gtrack, row, target, "refused_row",
                f"table is a skipped _HIST twin of "
                f"{ctx.hist_skipped[row.table]} and has no Stg1 model")
            continue
        if fact is None:
            gap(gtrack, row, target, "parent_empty",
                f"no satellite record for {code}; parent unknown")
            continue
        parts = childkey_parts(fact.childkey)
        if parts and _norm_name(row.attribute or "") in {_norm_name(p) for p in parts}:
            gap(track, row, target, "payload_collides_with_child_key_leg",
                f"attribute {row.attribute!r} is also a child-key part of {code}")
            continue
        candidates.setdefault((track, code), []).append((row, fact, column))

    branches: list[Branch] = []
    for (track, code) in sorted(candidates):
        entries = candidates[(track, code)]
        fact = entries[0][1]
        parts = childkey_parts(fact.childkey)
        _check_collisions(code, track, entries, parts)
        # Group by (table, key instance).
        groups: dict[tuple[str, Optional[str]], list[tuple[MappingRow, str]]] = {}
        for row, _, column in entries:
            key_instance = None
            if row.instance and fact.parent and choose_business_key(
                    spec.rows, spec.key_slots, row.table, fact.parent,
                    row.instance) is not None:
                key_instance = row.instance
            groups.setdefault((row.table, key_instance), []).append((row, column))
        sat_branches: list[Branch] = []
        for (table, key_instance) in sorted(
                groups, key=lambda k: (k[0], k[1] is not None, k[1] or "")):
            sat_branches.extend(_group_branches(
                ctx, track, fact, table, key_instance, groups[(table, key_instance)],
                parts, gap))
        branches.extend(_name_branches(sat_branches))

    ctx.branches[:] = sorted(ctx.branches + branches, key=Branch.sort_key)
    for (track, table, column, target, reason, detail), ids in sorted(
            gap_rows.items(),
            key=lambda kv: (kv[0][0], kv[0][1], kv[0][2] or "", *kv[0][3:])):
        ctx.gaps.append(Gap(track=track, source_table=table,
                            source_column=column, target=target, reason=reason,
                            detail=detail, row_ids=tuple(sorted(ids))))


def _check_collisions(code: str, track: str,
                      entries: Sequence[tuple[MappingRow, SatelliteFact, str]],
                      parts: Sequence[str]) -> None:
    """Stop the build on a payload or child-key column-name collision."""
    owner: dict[str, tuple[str, str]] = {}   # column -> (kind, name)
    for p in parts:
        col = _ck(p, code)
        if col in owner:
            raise PlanError(
                f"{code} ({track}): child-key parts {owner[col][1]!r} and {p!r} "
                f"both give child-key column {col}")
        owner[col] = ("child-key part", p)
    for row, _, col in sorted(entries, key=lambda e: (e[0].row_order, e[0].row_id)):
        attr = row.attribute or ""
        if col in owner:
            kind, name = owner[col]
            if kind == "attribute" and _norm_name(name) == _norm_name(attr):
                continue
            raise PlanError(
                f"{code} ({track}): {kind} {name!r} and attribute {attr!r} "
                f"both give column {col}")
        owner[col] = ("attribute", attr)


def _ck(part: str, code: str) -> str:
    try:
        return ck_column(part)
    except NamingError:
        raise PlanError(
            f"{code}: child-key part {part!r} has no alphanumeric character"
        ) from None


def _group_branches(ctx: PlanContext, track: str, fact: SatelliteFact,
                    table: str, key_instance: Optional[str],
                    rows: Sequence[tuple[MappingRow, str]],
                    parts: Sequence[str], gap: Callable[..., None]
                    ) -> list[Branch]:
    """Branches of one (track, satellite, table, key instance) group."""
    code = fact.code
    multi = bool(parts)
    by_column: dict[str, list[MappingRow]] = {}
    for row, column in rows:
        by_column.setdefault(column, []).append(row)

    def literal_instance(r: MappingRow) -> Optional[str]:
        return r.instance.strip() if (key_instance is None and r.instance
                                      and r.instance.strip()) else None

    def discriminator(r: MappingRow) -> Optional[str]:
        return literal_instance(r) or ((r.child_key_expr or "").strip() or None)

    units: list[_Unit] = []
    for column in sorted(by_column):
        crow = sorted(by_column[column], key=lambda r: (r.row_order, r.row_id))
        discs = [discriminator(r) for r in crow]
        coexisting = (len(crow) > 1 and None not in discs
                      and len(set(discs)) == len(discs))
        if coexisting and not multi:
            for r in crow:
                gap(track, r, f"{code}.{r.attribute}", "distinct_values_single_active",
                    f"{len(crow)} columns of {table} carry distinct values "
                    f"{sorted(discs)} for one attribute of a single-active "
                    f"satellite")
            continue
        if coexisting:
            units.extend(_Unit(column, [r]) for r in crow)
        else:
            units.append(_Unit(column, crow))

    if not units:
        return []
    table_obj = ctx.tables.get(table)
    table_columns = [c.name for c in table_obj.columns] if table_obj else []
    base_notes: list[str] = []
    if key_instance is not None:
        base_notes.append(f"key instance {key_instance!r}: parent "
                          f"{fact.parent} keyed for this instance")

    if not multi:
        payload, notes = [], list(base_notes)
        for u in units:
            entry, note = _payload_entry(u.rows[0].attribute or "", u.column, u.rows)
            payload.append(entry)
            if note:
                notes.append(note)
        return [_make_branch(track, fact, table, key_instance, False, payload,
                             (), notes)]

    # Multi-active: resolve each unit's child key, bucket by value.
    buckets: dict[tuple, list[tuple[_Unit, list[str]]]] = {}
    for u in units:
        values, why = [], ""
        origins: list[str] = []
        for r in u.rows:
            value, origin, why = _resolve_childkey(
                r, literal_instance(r), parts, table_columns)
            if value is None:
                break
            values.append(value)
            origins.append(f"{origin} (row {r.row_id})")
        if not why and len(set(values)) > 1:
            why = (f"fallback rows of column {u.column} disagree on the child "
                   f"key: {sorted(set(values))}")
        if why:
            for r in u.rows:
                gap(track, r, f"{code}.{r.attribute}", "child_key_leg_unresolved", why)
            continue
        buckets.setdefault(values[0], []).append((u, origins))

    out: list[Branch] = []
    for value in sorted(buckets):
        notes = list(base_notes)
        childkey = []
        for column, kind, v in value:
            childkey.append(FrozenDict({"column": column, kind: v}))
        origins = sorted({o for _, os_ in buckets[value] for o in os_})
        shown = ", ".join(f"{c} = '!{v}'" if k == "literal" else f"{c} = {v}"
                          for c, k, v in value)
        notes.append(f"child key {shown} from {'; '.join(origins)}")
        by_col: dict[str, list[MappingRow]] = {}
        for u, _ in buckets[value]:
            by_col.setdefault(u.column, []).extend(u.rows)
        payload = []
        for column in sorted(by_col):
            entry, note = _payload_entry(by_col[column][0].attribute or "",
                                         column, by_col[column])
            payload.append(entry)
            if note:
                notes.append(note)
        out.append(_make_branch(track, fact, table, key_instance, True,
                                payload, tuple(childkey), notes))
    return out


def _make_branch(track: str, fact: SatelliteFact, table: str,
                 key_instance: Optional[str], multi: bool,
                 payload: Sequence[FrozenDict], childkey: Sequence[FrozenDict],
                 notes: Sequence[str]) -> Branch:
    row_ids = tuple(sorted(i for e in payload for i in e["row_ids"]))
    return Branch(track=track, satellite=fact.code, table=table,
                  key_instance=key_instance, parent=fact.parent or "",
                  multi_active=multi, branch=None,
                  payload=tuple(sorted(payload, key=lambda e: e["column"])),
                  childkey=tuple(childkey), header_notes=tuple(notes),
                  row_ids=row_ids)


def _branch_slug(b: Branch) -> Optional[str]:
    parts: list[str] = []
    if b.key_instance is not None:
        parts.append(_slug(b.key_instance) or "instance")
    if b.multi_active:
        literals = [e["literal"] for e in b.childkey if "literal" in e]
        text = "_".join(_slug(t) for t in literals if _slug(t))
        if not text:
            text = _slug(b.payload[0]["source_columns"][0]) if b.payload else ""
        parts.append(text[:_SLUG_MAX].strip("_") or "branch")
    return "_".join(parts) if parts else None


def _name_branches(branches: Sequence[Branch]) -> list[Branch]:
    """Give every branch a ``branch`` suffix unique within its table."""
    out: list[Branch] = []
    used: dict[tuple[str, str, str], set[Optional[str]]] = {}
    for b in branches:  # already in deterministic order
        scope = (b.track, b.satellite, b.table)
        taken = used.setdefault(scope, set())
        name = _branch_slug(b)
        if name in taken:
            base, n = name or "branch", 2
            while f"{base}_{n}" in taken:
                n += 1
            name = f"{base}_{n}"
        taken.add(name)
        out.append(dataclasses.replace(b, branch=name))
    return out


# --------------------------------------------------------------------------
# Step 5: grain keys, bridges and hub feeds
# --------------------------------------------------------------------------

STAGING_DIR = "models/raw_vault/{track}/staging"


@dataclass(frozen=True)
class KeyResolution:
    """Parent key of one branch (input of task 4.9).

    ``source_model`` is the branch table's stg1 model, or the ``bridge``
    model when the table does not carry the key. A hub parent has
    ``parent_bk`` (raw key over the source model's columns) and no
    ``hub_keys``. A link parent has ``hub_keys``: ``{"code", "raw"}`` entries
    in link hub order (the Template_Project ``src_fk`` order when the
    template has the link, else sorted hub codes) and ``parent_bk=None``.
    """
    track: str
    satellite: str
    table: str
    key_instance: Optional[str]
    branch: Optional[str]
    parent: str
    source_model: str
    bridge: Optional[str]
    parent_bk: Optional[str]
    hub_keys: tuple[FrozenDict, ...]
    header_notes: tuple[str, ...]


def link_hubs(link: str, known_hubs: Sequence[str],
              template_order: Optional[Mapping[str, Sequence[str]]] = None
              ) -> Optional[tuple[tuple[str, ...], str]]:
    """Ordered hub codes of a link and where the order came from.

    1. ``template_order[link]`` (Template_Project ``src_fk`` order), origin
       ``template``.
    2. Otherwise the hubs whose names split the link name exactly
       (``LNK_CLAIM_PARTY`` -> ``HUB_CLAIM``, ``HUB_PARTY``), sorted by hub
       code, origin ``sorted``. Only an unambiguous split counts.
    ``None`` when neither gives at least one hub.
    """
    if template_order and link in template_order and template_order[link]:
        return tuple(template_order[link]), "template"
    tokens = link[4:].split("_") if link.upper().startswith("LNK_") else []
    bare = {h[4:]: h for h in known_hubs if h.upper().startswith("HUB_")}
    found: set[tuple[str, ...]] = set()

    def walk(i: int, acc: tuple[str, ...]) -> None:
        if i == len(tokens):
            if acc:
                found.add(tuple(sorted(acc)))
            return
        for j in range(i + 1, len(tokens) + 1):
            hub = bare.get("_".join(tokens[i:j]))
            if hub is not None and hub not in acc:
                walk(j, acc + (hub,))

    if tokens:
        walk(0, ())
    if len(found) == 1:
        return next(iter(found)), "sorted"
    return None


@dataclass
class _Bridge:
    joins: list[dict]
    columns: list[dict]
    parent_bk: str
    notes: list[str]


@dataclass
class _Feed:
    """Resolution of the hub key on (table, hub, instance)."""
    table: str
    hub: str
    instance: Optional[str]
    error: str = ""
    source_model: str = ""
    parent_bk: str = ""
    bridge_name: Optional[str] = None
    bridge: Optional[_Bridge] = None
    stage_name: str = ""
    notes: tuple[str, ...] = ()


@dataclass
class _KeyIndex:
    hubs: tuple[str, ...]
    links: tuple[str, ...]
    tables_by_code: dict[str, set[str]]
    template: Mapping[str, Sequence[str]]

    def keyed(self, table: str, code: str) -> bool:
        return table in self.tables_by_code.get(code, ())


def _build_index(ctx: PlanContext) -> _KeyIndex:
    spec = ctx.spec
    by_code: dict[str, set[str]] = {}
    for s in spec.key_slots:
        by_code.setdefault(s.vault_code, set()).add(s.table)
    for r in spec.rows:
        if (r.outcome == "mapped" and r.target_kind in ("hub_key", "link_key")
                and r.vault_code):
            by_code.setdefault(r.vault_code, set()).add(r.table)
    template = getattr(ctx.cfg, "TEMPLATE_LINK_HUB_ORDER", {}) or {}
    codes = set(by_code)
    hubs = sorted({c for c in set(spec.hubs) | codes if c.upper().startswith("HUB_")})
    links = sorted({c for c in set(spec.links) | codes | set(template)
                    if c.upper().startswith("LNK_")})
    return _KeyIndex(tuple(hubs), tuple(links), by_code, template)


def _inst_text(instance: Optional[str]) -> str:
    return f" (instance {instance!r})" if instance else ""


def _slot_for(ctx: PlanContext, table: str, code: str, instance: Optional[str]):
    return choose_business_key(ctx.spec.rows, ctx.spec.key_slots, table, code,
                               instance)


def _slot_or_default(ctx: PlanContext, table: str, code: str,
                     instance: Optional[str]):
    slot = _slot_for(ctx, table, code, instance)
    if slot is None and instance is not None:
        slot = _slot_for(ctx, table, code, None)
    return slot


def _names(table: Table) -> set[str]:
    return {c.name.upper() for c in table.columns}


def _signature(slot, raw: str) -> tuple:
    cols = frozenset(c.strip().upper() for c in slot.source_columns if c.strip())
    return ("cols", cols) if cols else ("expr", raw)


def _rename(expr: str, mapping: Mapping[str, str]) -> str:
    out = []
    for m in _TOKEN.finditer(expr):
        text = m.group()
        if m.lastgroup == "ident":
            text = mapping.get(text.lower(), text)
        out.append(text)
    return "".join(out)


def _bridge_columns(raw: str, owner: Table, alias: str, taken: set[str]
                    ) -> Optional[tuple[list[dict], str]]:
    """Bridge columns for the key columns of ``raw`` on joined table ``owner``.

    Aliases are ``bridge_<col>``, made unique against ``taken`` (the table's
    own stg1 aliases). Returns ``(columns, renamed expression)``.
    """
    own = {column_alias(c.name) for c in owner.columns}
    used: list[str] = []
    for m in _TOKEN.finditer(raw):
        if m.lastgroup == "ident" and m.group().lower() in own \
                and m.group().lower() not in used:
            used.append(m.group().lower())
    if not used:
        return None
    mapping: dict[str, str] = {}
    taken = set(taken)
    for a in used:
        name = f"bridge_{a}"
        while name in taken:
            name += "_b"
        taken.add(name)
        mapping[a] = name
    cols = [{"column": mapping[a], "expr": f"{alias}.{a}"} for a in used]
    return cols, _rename(raw, mapping)


def _bridge_via_slots(ctx: PlanContext, idx: _KeyIndex, table: str, hub: str,
                      inst: Optional[str], fails: list[str]) -> Optional[_Bridge]:
    """OPUS: search the key-slot graph for a table B that keys ``hub`` and
    shares a hub key (same column set) with ``table``."""
    tobj = ctx.tables[table]
    tcols = [c.name for c in tobj.columns]
    taken = {column_alias(c) for c in tcols} | {
        watermark_for(table, ctx.cfg.WATERMARK_COLUMN,
                      getattr(ctx.cfg, "WATERMARK_OVERRIDES", {}) or {}).lower()}
    viable: list[tuple[bool, str, str, list[str], Any]] = []
    for cand in sorted(idx.tables_by_code.get(hub, set()) - {table}):
        label = f"table {cand}"
        if cand not in ctx.tables:
            twin = ctx.hist_skipped.get(cand)
            fails.append(f"{label}: no Stg1 model"
                         + (f" (skipped _HIST twin of {twin})" if twin else ""))
            continue
        bobj = ctx.tables[cand]
        bcols = [c.name for c in bobj.columns]
        hub_slot = _slot_or_default(ctx, cand, hub, inst)
        if hub_slot is None:
            fails.append(f"{label}: keys {hub} only for other instances "
                         f"than {inst!r}")
            continue
        try:
            hub_raw = raw_key(hub_slot, bcols)
        except KeyRuleError as exc:
            fails.append(f"{label}: {hub} key unusable: {exc}")
            continue
        reasons: list[str] = []
        shared = 0
        for g in idx.hubs:
            if g == hub:
                continue
            kt, kb = _slot_for(ctx, table, g, None), _slot_for(ctx, cand, g, None)
            if kt is None or kb is None:
                continue
            shared += 1
            try:
                st = _signature(kt, raw_key(kt, tcols))
                sb = _signature(kb, raw_key(kb, bcols))
            except KeyRuleError as exc:
                reasons.append(f"{g}: key unusable: {exc}")
                continue
            if st != sb:
                reasons.append(f"{g}: key columns differ ({table}: "
                               f"{_sig_text(st)} vs {cand}: {_sig_text(sb)})")
                continue
            if st[0] != "cols":
                reasons.append(f"{g}: shared key is an expression with no "
                               f"column to join on")
                continue
            join_cols = sorted(st[1])
            absent = [c for c in join_cols if c not in _names(tobj)
                      or c not in _names(bobj)]
            if absent:
                reasons.append(f"{g}: join column(s) {absent} not in both Stg1 "
                               f"models")
                continue
            feeds = any(g in lh and hub in lh and idx.keyed(cand, link)
                        for link in idx.links
                        for lh in [_link_hub_codes(idx, link)])
            viable.append((feeds, cand, g, join_cols, (hub_slot, hub_raw, bobj)))
        if shared == 0:
            fails.append(f"{label}: no hub other than {hub} is keyed on both "
                         f"{table} and {cand}")
        elif reasons and not any(v[1] == cand for v in viable):
            fails.append(f"{label}: " + "; ".join(reasons))
    if not viable:
        return None
    viable.sort(key=lambda v: (not v[0], v[1], v[2]))
    feeds, cand, g, join_cols, (hub_slot, hub_raw, bobj) = viable[0]
    built = _bridge_columns(hub_raw, bobj, "b1", taken)
    if built is None:
        fails.append(f"table {cand}: {hub} key {hub_raw!r} uses no column")
        return None
    columns, parent_bk = built
    joins = [{"model": stg1_model(bobj.stem), "alias": "b1",
              "on": [{"left": f"t.{column_alias(c)}",
                      "right": f"b1.{column_alias(c)}"} for c in join_cols]}]
    notes = [f"bridge {hub} key from {cand} ({hub_slot.origin}), joined on shared "
             f"{g} key column(s) {join_cols}"
             + (f"; {cand} feeds a link between {g} and {hub}" if feeds else "")]
    others = [f"{v[1]} via {v[2]}" for v in viable[1:]]
    if others:
        notes.append("other viable candidates not used: " + ", ".join(others))
    return _Bridge(joins, columns, parent_bk, notes)


def _sig_text(sig: tuple) -> str:
    return str(sorted(sig[1])) if sig[0] == "cols" else repr(sig[1])


def _link_hub_codes(idx: _KeyIndex, link: str) -> tuple[str, ...]:
    found = link_hubs(link, idx.hubs, idx.template)
    return found[0] if found else ()


def _bridge_via_walks(ctx: PlanContext, table: str, hub: str,
                      inst: Optional[str], fails: list[str]) -> Optional[_Bridge]:
    """MAXIMUS: follow a ``spans[]`` spine walk that starts on ``table`` and
    ends on a table keyed on ``hub``."""
    tobj = ctx.tables[table]
    taken = {column_alias(c.name) for c in tobj.columns} | {
        watermark_for(table, ctx.cfg.WATERMARK_COLUMN,
                      getattr(ctx.cfg, "WATERMARK_OVERRIDES", {}) or {}).lower()}
    for walk in sorted((w for w in ctx.spec.walks if w.from_table == table),
                       key=lambda w: w.walk_id):
        label = f"walk {walk.walk_id}"
        chain = [(h, "climb") for h in walk.climb]
        chain += [(h, "descend") for h in walk.descend]
        last = chain[-1][0] if chain else walk.from_table
        if walk.terminal_table != last:
            chain.append((walk.terminal_table, "descend"))
        if not chain:
            fails.append(f"{label}: walk does not leave {table}")
            continue
        out_of = [h for h, _ in chain if h not in ctx.tables]
        if out_of:
            fails.append(f"{label}: table(s) {out_of} have no Stg1 model")
            continue
        terminal = ctx.tables[walk.terminal_table]
        slot = _slot_or_default(ctx, walk.terminal_table, hub, inst)
        if slot is None:
            fails.append(f"{label}: terminal table {walk.terminal_table} has no "
                         f"key for {hub}")
            continue
        try:
            hub_raw = raw_key(slot, [c.name for c in terminal.columns])
        except KeyRuleError as exc:
            fails.append(f"{label}: {hub} key unusable: {exc}")
            continue
        joins: list[dict] = []
        prev_name, prev_alias, prev_parent = table, "t", walk.start_column
        missing: list[str] = []

        def need(tname: str, col: str) -> None:
            if col.upper() not in _names(ctx.tables[tname]):
                missing.append(f"{tname}.{col}")

        need(table, walk.start_column)
        for i, (hop, how) in enumerate(chain):
            alias = f"b{i + 1}"
            need(hop, "KEY_HASH")
            need(hop, "PARENT_KEY_HASH")
            if how == "climb":
                left = f"{prev_alias}.{column_alias(prev_parent)}"
                right = f"{alias}.{column_alias('KEY_HASH')}"
            else:
                need(prev_name, "KEY_HASH")
                left = f"{alias}.{column_alias('PARENT_KEY_HASH')}"
                right = f"{prev_alias}.{column_alias('KEY_HASH')}"
            joins.append({"model": stg1_model(ctx.tables[hop].stem),
                          "alias": alias, "on": [{"left": left, "right": right}]})
            prev_name, prev_alias, prev_parent = hop, alias, "PARENT_KEY_HASH"
        if missing:
            fails.append(f"{label}: columns not in Stg1 models: "
                         f"{sorted(set(missing))}")
            continue
        built = _bridge_columns(hub_raw, terminal, prev_alias, taken)
        if built is None:
            fails.append(f"{label}: {hub} key {hub_raw!r} on "
                         f"{walk.terminal_table} uses no column")
            continue
        columns, parent_bk = built
        path = " -> ".join([table, *[h for h, _ in chain]])
        return _Bridge(joins, columns, parent_bk,
                       [f"bridge {hub} key via spine walk {walk.walk_id}: {path} "
                        f"(climb: {list(walk.climb)}, descend: "
                        f"{list(walk.descend)}); spec: {walk.raw}"])
    return None


def _resolve_feed(ctx: PlanContext, idx: _KeyIndex, table: str, hub: str,
                  inst: Optional[str], allow_bridge: bool, suffix: str) -> _Feed:
    tobj = ctx.tables[table]
    feed = _Feed(table, hub, inst)
    stem = tobj.stem.lower()
    feed.stage_name = stg2_model("hub", stem, hub) + suffix
    slot = _slot_for(ctx, table, hub, inst)
    if slot is not None:
        try:
            raw = raw_key(slot, [c.name for c in tobj.columns])
        except KeyRuleError as exc:
            feed.error = f"{hub} key on {table}{_inst_text(inst)} unusable: {exc}"
            return feed
        feed.source_model = stg1_model(tobj.stem)
        feed.parent_bk = raw
        feed.notes = (f"{hub} key{_inst_text(inst)} read from {table} "
                      f"({slot.origin})",)
        return feed
    fails: list[str] = []
    bridge = None
    if allow_bridge:
        bridge = _bridge_via_slots(ctx, idx, table, hub, inst, fails)
        if bridge is None:
            bridge = _bridge_via_walks(ctx, table, hub, inst, fails)
    if bridge is None:
        checked = ("; ".join(fails) if fails else
                   "none (no other table has a key for the hub and no spine "
                   "walk starts at the table)")
        how = "no bridge for a link hub" if not allow_bridge else "no bridge found"
        feed.error = (f"{hub} key absent on {table}{_inst_text(inst)}; {how}. "
                      f"Candidates checked: {checked}")
        return feed
    feed.bridge = bridge
    feed.bridge_name = bridge_model(tobj.stem, hub) + suffix
    feed.source_model = feed.bridge_name
    feed.parent_bk = bridge.parent_bk
    feed.notes = (f"{hub} key{_inst_text(inst)} not on {table}; resolved through "
                  f"{feed.bridge_name}", *bridge.notes)
    return feed


def _suffix_for(registry: dict, stem: str, hub: str,
                inst: Optional[str]) -> str:
    """``""`` without an instance, else the slug of it (callers add ``__``;
    ``_2``, ``_3`` ... when two instances give one slug). Callers must ask
    in sorted order so the result is deterministic."""
    if inst is None:
        return ""
    used = registry.setdefault((stem, hub), {})
    if inst in used:
        return used[inst]
    base = _slug(inst) or "instance"
    name, n = base, 2
    while name in used.values():
        name, n = f"{base}_{n}", n + 1
    used[inst] = name
    return name


def plan_grain_keys(ctx: PlanContext) -> None:
    """Resolve each branch's parent key, plan bridges and hub stages.

    See the module docstring ("Grain keys and hub feeds").
    """
    idx = _build_index(ctx)
    rows_by_id = {r.row_id: r for r in ctx.spec.rows}
    branches = [b for b in ctx.branches if b.track != "reference"]
    needs: dict[tuple, None] = {}
    plans: dict[tuple, tuple[str, list[str], str]] = {}  # kind, hubs, error
    for b in branches:
        parent = b.parent
        if parent.upper().startswith("LNK_"):
            found = link_hubs(parent, idx.hubs, idx.template)
            if found is None:
                plans[b.sort_key()] = ("link", [], (
                    f"hubs of {parent} are not known: not in the template link "
                    f"hub order and the link name does not split into known "
                    f"hub names {list(idx.hubs)}"))
                continue
            hubs = list(found[0])
            plans[b.sort_key()] = ("link", hubs, "")
            for h in hubs:
                needs[(b.table, h, b.key_instance, False)] = None
        elif parent.upper().startswith("HUB_"):
            plans[b.sort_key()] = ("hub", [parent], "")
            needs[(b.table, parent, b.key_instance, True)] = None
        else:
            plans[b.sort_key()] = ("hub", [], (
                f"parent {parent!r} is neither a HUB_ nor an LNK_ code"))

    registry: dict = {}
    feeds: dict[tuple, _Feed] = {}
    for key in sorted(needs, key=lambda k: (k[0], k[1], k[2] is not None,
                                            k[2] or "", k[3])):
        table, hub, inst, allow = key
        stem = ctx.tables[table].stem.lower()
        sfx = _suffix_for(registry, stem, hub, inst)
        feeds[key] = _resolve_feed(ctx, idx, table, hub, inst, allow,
                                   f"__{sfx}" if sfx else "")

    ok: list[Branch] = []
    dropped: dict[tuple, list[str]] = {}
    users: dict[str, set[str]] = {}          # hub stage name -> satellites
    bridge_tracks: dict[str, set[str]] = {}
    used_feeds: dict[str, _Feed] = {}
    for b in sorted(branches, key=Branch.sort_key):
        kind, hubs, error = plans[b.sort_key()]
        errs = [error] if error else []
        chosen: list[_Feed] = []
        for h in hubs:
            feed = feeds[(b.table, h, b.key_instance, kind == "hub")]
            (errs if feed.error else chosen).append(feed.error or feed)
        if errs:
            reason = ("no_verified_augmentation_key" if b.track == "augmented"
                      else "missing_grain_key")
            detail = " | ".join(str(e) for e in errs)
            for rid in b.row_ids:
                r = rows_by_id[rid]
                attr = f"{b.satellite}.{r.attribute}" if r.attribute \
                    else b.satellite
                dropped.setdefault((b.track, r.table, r.column, attr,
                                    reason, detail), []).append(rid)
                ctx.gapped_rows.add(rid)
            continue
        ok.append(b)
        for feed in chosen:
            prior = used_feeds.setdefault(feed.stage_name, feed)
            if prior.parent_bk != feed.parent_bk:
                raise PlanError(
                    f"hub stage {feed.stage_name}: PARENT_BK differs between "
                    f"{prior.parent_bk!r} and {feed.parent_bk!r}")
            users.setdefault(feed.stage_name, set()).add(b.satellite)
            if feed.bridge_name:
                bridge_tracks.setdefault(feed.bridge_name, set()).add(b.track)
        if kind == "hub":
            f = chosen[0]
            ctx.key_resolutions[b.sort_key()] = KeyResolution(
                b.track, b.satellite, b.table, b.key_instance, b.branch,
                b.parent, f.source_model, f.bridge_name, f.parent_bk, (),
                f.notes)
        else:
            notes = tuple(n for f in chosen for n in f.notes)
            ctx.key_resolutions[b.sort_key()] = KeyResolution(
                b.track, b.satellite, b.table, b.key_instance, b.branch,
                b.parent, chosen[0].source_model, chosen[0].bridge_name, None,
                tuple(FrozenDict(code=f.hub, raw=f.parent_bk) for f in chosen),
                notes)

    reference = [b for b in ctx.branches if b.track == "reference"]
    ctx.branches[:] = sorted(ok + reference, key=Branch.sort_key)

    for (track, table, column, target, reason, detail), ids in sorted(
            dropped.items()):
        ctx.gaps.append(Gap(track=track, source_table=table,
                            source_column=column, target=target, reason=reason,
                            detail=detail, row_ids=tuple(sorted(set(ids)))))

    overrides = getattr(ctx.cfg, "WATERMARK_OVERRIDES", {}) or {}
    bridges_done: set[str] = set()
    for name in sorted(used_feeds):
        feed = used_feeds[name]
        tobj = ctx.tables[feed.table]
        if feed.bridge is not None and feed.bridge_name not in bridges_done:
            bridges_done.add(feed.bridge_name)
            track = ("standard" if "standard" in bridge_tracks[feed.bridge_name]
                     else "augmented")
            folder = STAGING_DIR.format(track=track)
            notes = list(feed.bridge.notes)
            ctx.artifacts.append(Artifact(
                kind="bridge", path=f"{folder}/{feed.bridge_name}.sql",
                name=feed.bridge_name,
                data={"hub": feed.hub, "table": tobj.name,
                      "source_model": stg1_model(tobj.stem),
                      "joins": feed.bridge.joins,
                      "columns": feed.bridge.columns,
                      "header_notes": notes}))
        notes = [*feed.notes,
                 "PARENT_BK is identical on every satellite stage of "
                 f"({feed.table}, {feed.hub}, instance {feed.instance!r})",
                 "keys used by: " + ", ".join(sorted(users[name]))]
        ctx.artifacts.append(Artifact(
            kind="stage_hub",
            path=f"{STAGING_DIR.format(track='standard')}/{name}.sql",
            name=name,
            data={"target": feed.hub, "source_model": feed.source_model,
                  "table": tobj.name,
                  "record_source": record_source(ctx.cfg.RECORD_SOURCE_PREFIX,
                                                 tobj.name),
                  "load_datetime": watermark_for(
                      tobj.name, ctx.cfg.WATERMARK_COLUMN, overrides),
                  "parent_code": feed.hub, "parent_bk": feed.parent_bk,
                  "header_notes": notes}))


# --------------------------------------------------------------------------
# Steps 6 to 9: stitch or union, macro choice, references, hubs and links
# --------------------------------------------------------------------------

_JINJA = ("{{", "}}", "{%", "%}", "{#", "#}")
_STITCH_BAD = ("'", "\\", "\n", "\r")
_STITCH_DIR = "models/raw_vault/standard/stitched"
_NULL_EXPR = "cast(null as varchar)"


def _line(text: Any) -> str:
    """One-line header text with Jinja delimiters defused."""
    out = " ".join(str(text).split())
    for token in _JINJA:
        out = out.replace(token, f"{token[0]} {token[1]}")
    return out


def _expr_text(expr: Any) -> str:
    """Payload expression as one SQL string (fan-in lists become coalesce)."""
    if isinstance(expr, str):
        return expr
    parts = list(expr)
    return parts[0] if len(parts) == 1 else f"coalesce({', '.join(parts)})"


def _sat_groups(ctx: PlanContext) -> dict[tuple[str, str], list[Branch]]:
    """Kept standard/augmented branches by ``(track, satellite)``."""
    groups: dict[tuple[str, str], list[Branch]] = {}
    for b in ctx.branches:
        if b.track == "reference" or b.sort_key() not in ctx.key_resolutions:
            continue
        groups.setdefault((b.track, b.satellite), []).append(b)
    return groups


def _overrides(ctx: PlanContext) -> Mapping[str, str]:
    return getattr(ctx.cfg, "WATERMARK_OVERRIDES", {}) or {}


def _stitch_blocker(ctx: PlanContext, branches: Sequence[Branch]) -> str:
    """Why ``branches`` cannot be stitched, or ``""``."""
    tables = sorted({b.table for b in branches})
    if any(b.multi_active for b in branches):
        return "multi-active satellite"
    if any(b.key_instance is not None for b in branches):
        return "a branch reads a key instance"
    if len(branches) != len(tables):
        return "several branches on one table"
    if not branches[0].parent.upper().startswith("HUB_"):
        return f"parent {branches[0].parent} is a link (composite key)"
    exprs: dict[str, list[str]] = {}
    for b in branches:
        res = ctx.key_resolutions[b.sort_key()]
        exprs.setdefault(res.parent_bk or "", []).append(b.table)
    if len(exprs) > 1:
        shown = "; ".join(f"{e!r} on {', '.join(ts)}"
                          for e, ts in sorted(exprs.items()))
        return f"tables do not share one key expression: {shown}"
    key = next(iter(exprs))
    texts = [key] + [_expr_text(e["expr"]) for b in branches for e in b.payload]
    if any(c in t for t in texts for c in _STITCH_BAD):
        return ("the key or a payload expression contains a quote, backslash "
                "or newline, which a stitch source cannot hold")
    return ""


def plan_stitches(ctx: PlanContext) -> None:
    """Plan a Stitch_Model per satellite with declared precedence (step 6)."""
    cfg = ctx.cfg
    by_upper = {n.upper(): n for n in ctx.tables}
    for (track, sat), branches in sorted(_sat_groups(ctx).items()):
        prec = sorted(p for p in ctx.spec.precedence if p[0] == sat)
        tables = sorted({b.table for b in branches})
        if track != "standard" or not prec or len(tables) < 2:
            continue
        reason = _stitch_blocker(ctx, branches)
        if reason:
            ctx.stitch_reasons[(track, sat)] = reason
            continue
        ordered = sorted(branches, key=lambda b: b.table)
        attr_order: dict[str, list[str]] = {}
        for _, attribute, tbls in prec:
            try:
                column = payload_column(attribute)
            except NamingError:
                continue
            attr_order.setdefault(column, list(tbls))
        cols_by_table = {b.table: {e["column"]: e for e in b.payload}
                         for b in ordered}
        model_of = {b.table: ctx.key_resolutions[b.sort_key()].source_model
                    for b in ordered}
        output = sorted({c for d in cols_by_table.values() for c in d})
        rules: dict[str, list[str]] = {}
        for column in output:
            providers = [t for t in tables if column in cols_by_table[t]]
            first: list[str] = []
            for t in attr_order.get(column, ()):
                real = by_upper.get(str(t).upper())
                if real in providers and real not in first:
                    first.append(real)
            ladder = first + [t for t in providers if t not in first]
            rules[column.lower()] = [model_of[t] for t in ladder]
        sources = []
        for b in ordered:
            res = ctx.key_resolutions[b.sort_key()]
            tobj = ctx.tables[b.table]
            sources.append({
                "model": res.source_model,
                "source_tag": source_tag(cfg.RECORD_SOURCE_PREFIX, tobj.name),
                "ldts_column": watermark_for(tobj.name, cfg.WATERMARK_COLUMN,
                                             _overrides(ctx)),
                "key_column": res.parent_bk,
                "columns": [{"src": _expr_text(e["expr"]),
                             "tgt": e["column"].lower()} for e in b.payload],
            })
        notes = [_line(f"precedence from the spec for {attribute}: "
                       + " > ".join(tbls)) for _, attribute, tbls in prec]
        name = stitch_model(sat)
        stage = stitch_stage_model(sat)
        parent = branches[0].parent
        ctx.artifacts.append(Artifact(
            kind="stitch", path=f"{_STITCH_DIR}/{name}.sql", name=name,
            data={"sat": sat, "parent_code": parent,
                  "target_sat": sat_model(sat, track), "unique_key": "parent_bk",
                  "record_source_prefix": cfg.RECORD_SOURCE_PREFIX,
                  "sources": sources,
                  "output_columns": [c.lower() for c in output],
                  "coalesce_rules": rules, "notes": notes}))
        ctx.artifacts.append(Artifact(
            kind="stitch_stage",
            path=f"{STAGING_DIR.format(track='standard')}/{stage}.sql",
            name=stage,
            data={"sat": sat, "source_model": name, "parent_code": parent,
                  "payload": output,
                  "source_tags": [s["source_tag"] for s in sources],
                  "notes": notes}))
        ctx.stitched[(track, sat)] = stage


def plan_satellite_models(ctx: PlanContext) -> None:
    """Satellite stages and ``sat`` models with the macro choice (step 7)."""
    cfg = ctx.cfg
    group = str(cfg.RECORD_SOURCE_GROUP)
    for (track, sat), branches in sorted(_sat_groups(ctx).items()):
        augmented = track == "augmented"
        parent = branches[0].parent
        stitch_stage = ctx.stitched.get((track, sat))
        names: list[str] = []
        column_map: dict[str, list[str]] = {}
        if stitch_stage is None:
            for b in branches:
                res = ctx.key_resolutions[b.sort_key()]
                tobj = ctx.tables[b.table]
                name = stg2_model("aug" if augmented else "sat", tobj.stem, sat,
                                  b.branch)
                data: dict[str, Any] = {
                    "target": sat, "source_model": res.source_model,
                    "table": tobj.name,
                    "record_source": record_source(cfg.RECORD_SOURCE_PREFIX,
                                                   tobj.name),
                    "load_datetime": watermark_for(
                        tobj.name, cfg.WATERMARK_COLUMN, _overrides(ctx)),
                    "parent_code": b.parent,
                    "payload": [
                        {"column": e["column"],
                         "expr": (e["expr"] if isinstance(e["expr"], str)
                                  else list(e["expr"]))}
                        for e in b.payload],
                    "childkey": [dict(e) for e in b.childkey],
                    "header_notes": [*b.header_notes, *res.header_notes],
                }
                if res.parent_bk is not None:
                    data["parent_bk"] = res.parent_bk
                else:
                    data["hub_keys"] = [dict(k) for k in res.hub_keys]
                ctx.artifacts.append(Artifact(
                    kind="stage_aug" if augmented else "stage_sat",
                    path=f"{STAGING_DIR.format(track=track)}/{name}.sql",
                    name=name, data=data))
                names.append(name)
                column_map[name] = sorted(e["column"] for e in b.payload)
        else:
            names.append(stitch_stage)
        multi_active = any(b.multi_active for b in branches)
        cdk = [e["column"] for e in branches[0].childkey]
        payload = sorted({e["column"] for b in branches for e in b.payload})
        several = len(names) >= 2
        macro = (("ma_" if multi_active else "")
                 + ("sat_multi_source" if several else "sat"))
        header = [f"track: {track}; {len(branches)} branch(es) over "
                  f"{len({b.table for b in branches})} table(s)"]
        if stitch_stage is not None:
            header.append(f"reads {stitch_stage} (stitch {stitch_model(sat)})")
        reason = ctx.stitch_reasons.get((track, sat))
        if reason:
            header.append(_line(f"stitch not used (precedence declared): "
                                f"{reason}; stages are unioned by {macro}"))
        sat_data: dict[str, Any] = {
            "satellite": sat, "parent": parent, "macro": macro,
            "src_pk": hkey(parent), "src_cdk": cdk, "src_payload": payload,
            "source_model": names if several else names[0],
            "header": header,
        }
        if stitch_stage is not None:
            sat_data["src_extra_columns"] = ["DBT_RUN_TS"]
        if several:
            sat_data["src_column_map"] = column_map
            sat_data["src_record_source_map"] = {n: group for n in names}
        name = sat_model(sat, track)
        ctx.artifacts.append(Artifact(
            kind="sat", path=f"models/raw_vault/{track}/satellites/{name}.sql",
            name=name, data=sat_data))


def plan_references(ctx: PlanContext) -> None:
    """``ref_<name>`` views for reference-track satellites (step 8)."""
    cfg = ctx.cfg
    groups: dict[str, list[Branch]] = {}
    for b in ctx.branches:
        if b.track == "reference":
            groups.setdefault(b.satellite, []).append(b)
    for code, branches in sorted(groups.items()):
        by_table: dict[str, dict[str, str]] = {}
        for b in branches:
            cols = by_table.setdefault(b.table, {})
            for e in b.payload:
                cols.setdefault(e["column"], _expr_text(e["expr"]))
        all_cols = sorted({c for d in by_table.values() for c in d})
        sources = []
        for table in sorted(by_table):
            tobj = ctx.tables[table]
            sources.append({
                "source_model": stg1_model(tobj.stem), "table": tobj.name,
                "record_source": source_tag(cfg.RECORD_SOURCE_PREFIX, tobj.name),
                "load_datetime": watermark_for(tobj.name, cfg.WATERMARK_COLUMN,
                                               _overrides(ctx)),
                "columns": [{"column": c,
                             "expr": by_table[table].get(c, _NULL_EXPR)}
                            for c in all_cols],
            })
        notes = [_line(n) for b in branches for n in b.header_notes]
        name = ref_model(code)
        ctx.artifacts.append(Artifact(
            kind="ref",
            path=f"models/raw_vault/standard/references/{name}.sql", name=name,
            data={"ref": code,
                  "record_source_prefix": cfg.RECORD_SOURCE_PREFIX,
                  "sources": sources, "notes": notes}))


def plan_link_stages(ctx: PlanContext) -> None:
    """``stage_link`` per (table, link, key instance) that feeds a link."""
    cfg, spec = ctx.cfg, ctx.spec
    idx = _build_index(ctx)
    requests: dict[tuple, dict[str, Any]] = {}
    for key in sorted(ctx.key_resolutions):
        res = ctx.key_resolutions[key]
        if not res.hub_keys:
            continue
        rk = (res.table, res.parent, res.key_instance)
        item = {"source_model": res.source_model,
                "hub_keys": tuple(res.hub_keys),
                "notes": list(res.header_notes), "users": {res.satellite}}
        prior = requests.get(rk)
        if prior is None:
            requests[rk] = item
        elif (prior["hub_keys"], prior["source_model"]) != (
                item["hub_keys"], item["source_model"]):
            raise PlanError(
                f"link stage for {rk}: satellites {sorted(prior['users'])} and "
                f"{res.satellite} resolve the link keys differently")
        else:
            prior["users"].add(res.satellite)

    candidates: set[tuple[str, str, Optional[str]]] = set()
    for s in spec.key_slots:
        if s.vault_code.upper().startswith("LNK_"):
            candidates.add((s.table, s.vault_code, s.instance))
    for r in spec.rows:
        if (r.outcome == "mapped" and r.target_kind == "link_key"
                and r.vault_code):
            candidates.add((r.table, r.vault_code, r.instance))
    for table, link, inst in sorted(
            candidates, key=lambda k: (k[0], k[1], k[2] is not None, k[2] or "")):
        if (table, link, inst) in requests or table not in ctx.tables:
            continue
        found = link_hubs(link, idx.hubs, idx.template)
        if found is None:
            continue
        cols = [c.name for c in ctx.tables[table].columns]
        keys: list[FrozenDict] = []
        for hub in found[0]:
            slot = _slot_or_default(ctx, table, hub, inst)
            if slot is None:
                break
            try:
                keys.append(FrozenDict(code=hub, raw=raw_key(slot, cols)))
            except KeyRuleError:
                break
        else:
            requests[(table, link, inst)] = {
                "source_model": stg1_model(ctx.tables[table].stem),
                "hub_keys": tuple(keys), "users": set(),
                "notes": [f"{link} link key read from {table}: every hub of "
                          f"the link has a key on the table"]}

    registry: dict = {}
    for rk in sorted(requests, key=lambda k: (k[0], k[1], k[2] is not None,
                                              k[2] or "")):
        table, link, inst = rk
        item = requests[rk]
        tobj = ctx.tables[table]
        sfx = _suffix_for(registry, tobj.stem.lower(), link, inst)
        name = stg2_model("link", tobj.stem, link) + (f"__{sfx}" if sfx else "")
        notes = [*item["notes"]]
        if item["users"]:
            notes.append("keys used by: " + ", ".join(sorted(item["users"])))
        ctx.artifacts.append(Artifact(
            kind="stage_link",
            path=f"{STAGING_DIR.format(track='standard')}/{name}.sql",
            name=name,
            data={"target": link, "source_model": item["source_model"],
                  "table": tobj.name,
                  "record_source": record_source(cfg.RECORD_SOURCE_PREFIX,
                                                 tobj.name),
                  "load_datetime": watermark_for(
                      tobj.name, cfg.WATERMARK_COLUMN, _overrides(ctx)),
                  "parent_code": link,
                  "hub_keys": [dict(k) for k in item["hub_keys"]],
                  "header_notes": notes}))


def plan_hub_link_models(ctx: PlanContext) -> None:
    """``hub`` and ``link`` models over their stage models."""
    hubs: dict[str, list[str]] = {}
    links: dict[str, list[Artifact]] = {}
    for a in ctx.artifacts:
        if a.kind == "stage_hub":
            hubs.setdefault(a.data["target"], []).append(a.name)
        elif a.kind == "stage_link":
            links.setdefault(a.data["target"], []).append(a)
    for code in sorted(hubs):
        name = hub_model(code)
        ctx.artifacts.append(Artifact(
            kind="hub", path=f"models/raw_vault/standard/hubs/{name}.sql",
            name=name,
            data={"hub": code, "src_pk": hkey(code),
                  "source_model": sorted(hubs[code]),
                  "header": [f"fed by {len(hubs[code])} hub stage(s)"]}))
    for code in sorted(links):
        stages = sorted(links[code], key=lambda a: a.name)
        orders = {tuple(k["code"] for k in a.data["hub_keys"]) for a in stages}
        if len(orders) > 1:
            raise PlanError(f"{code}: link stages disagree on hub order: "
                            f"{sorted(orders)}")
        order = next(iter(orders))
        if len(order) < 2:
            continue
        name = link_model(code)
        ctx.artifacts.append(Artifact(
            kind="link", path=f"models/raw_vault/standard/links/{name}.sql",
            name=name,
            data={"link": code, "src_pk": hkey(code),
                  "src_fk": [hkey(h) for h in order],
                  "source_model": [a.name for a in stages],
                  "header": ["src_fk order: " + ", ".join(order)]}))


def plan_not_fed(ctx: PlanContext) -> None:
    """Model hubs, links and satellites with no feed (README list)."""
    spec = ctx.spec
    fed_hubs = {a.data["hub"] for a in ctx.artifacts if a.kind == "hub"}
    fed_links = {a.data["link"] for a in ctx.artifacts if a.kind == "link"}
    fed_sats = {a.data["satellite"] for a in ctx.artifacts if a.kind == "sat"}
    fed_sats |= {a.data["ref"] for a in ctx.artifacts if a.kind == "ref"}
    row_codes = {r.vault_code for r in spec.rows if r.vault_code}
    resolved = {code for code, _ in ctx.satellites}
    out: set[str] = set(ctx.not_fed)
    out.update(h for h in spec.hubs if h not in fed_hubs)
    out.update(l for l in spec.links if l not in fed_links)
    out.update(s.code for s in spec.satellites
               if s.code in resolved and s.code not in fed_sats
               and s.code not in row_codes)
    ctx.not_fed[:] = sorted(out)


# --------------------------------------------------------------------------
# Entry point
# --------------------------------------------------------------------------

STEPS: tuple[Callable[[PlanContext], None], ...] = (
    plan_tables,
    plan_satellites,
    record_model_facts,
    plan_branches,
    plan_grain_keys,
    plan_stitches,
    plan_satellite_models,
    plan_references,
    plan_link_stages,
    plan_hub_link_models,
    plan_not_fed,
)


def plan(spec: IntermediateSpec, cfg: Any,
         sibling_model: Optional[SiblingModel] = None) -> Plan:
    """Plan every artifact, gap, Derived_Fact and watermark risk for ``spec``.

    The spec is canonicalized first, so the result does not depend on the
    order of its input lists.
    """
    ctx = PlanContext(spec=spec.canonical(), cfg=cfg, sibling=sibling_model)
    for step in STEPS:
        step(ctx)
    return ctx.finish()
