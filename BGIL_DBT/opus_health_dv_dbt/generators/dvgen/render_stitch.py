"""Render Stitch_Models and the stage over each stitch (design "Stitch").

Two pure renderers, each taking one ``Artifact`` and returning file text with
``\\n`` endings and exactly one trailing newline. No timestamps, run ids or
absolute paths are written, so equal input gives byte-identical output.

``render_stitch(artifact)``        -> ``stitch_<sat>.sql``
``render_stitch_stage(artifact)``  -> ``stg2_sat_stitch__<sat>.sql``

The shapes mirror the Template_Project's ``models/raw_vault/standard/stitched``
files and their ``stg2_*`` stages, and the call matches the copied macro
``stitch_incremental(sources, output_columns, coalesce_rules,
unique_key='parent_bk', target_sat=none)``.

Artifact.data contract, kind "stitch"
-------------------------------------
JSON-like mapping (``FrozenDict`` once inside an ``Artifact``)::

    {
      "sat": "SAT_POLICY_BONUS_TRACKING",     # satellite vault code
      "parent_code": "HUB_POLICY",            # grain hub, header only
      "target_sat": "sat_policy_bonus_tracking",
      "unique_key": "parent_bk",              # must be 'parent_bk'
      "record_source_prefix": "OPUS_",        # optional; checked when given
      "sources": [                            # order = alias order t0, t1, ...
        {"model": "stg_health__bjaz_hm_member_dtls",
         "source_tag": "OPUS_BJAZ_HM_MEMBER_DTLS",   # prefix + TABLE
         "ldts_column": "inc_job_updated_at",        # naming.watermark_for
         "key_column": "contract_id",
         "columns": [{"src": "bonus_si", "tgt": "bonusamount"}]}
      ],
      "output_columns": ["bonusamount"],      # stitch output order
      "coalesce_rules": {                     # column -> source models,
        "bonusamount": ["stg_health__bjaz_hm_member_dtls"]   # first wins
      },
      "notes": ["..."]                        # optional header lines
    }

Rules the renderer enforces (``StitchRenderError`` otherwise):

- ``artifact.name == naming.stitch_model(sat)``; ``unique_key == 'parent_bk'``.
- ``sources`` is non-empty; source models are unique. Aliases are assigned by
  position (``t0``, ``t1``, ...), so ``coalesce_rules`` names models, not
  aliases.
- Every ``source_tag`` contains ``_`` and all tags share the text before the
  first ``_`` (``OPUS`` or ``MAXIMUS``). ``stitch_incremental`` raises a
  compile error otherwise. When ``record_source_prefix`` is given, every tag
  starts with it and the prefix's group equals the tags' group.
- ``ldts_column``, ``tgt`` and ``output_columns`` are plain identifiers.
  ``key_column`` and ``src`` may be expressions (the macro wraps ``src`` in
  ``NULLIF(TRIM(TO_VARCHAR(...)), '')``). No value may contain ``'``, ``\\``
  or a newline, because each one is written as a Jinja string literal.
- Each ``tgt`` is in ``output_columns`` and appears once per source. For every
  output column, the set of models in its rule equals the set of sources that
  provide it; the rule order is kept as declared (the precedence ladder).

Rendered ``coalesce_rules`` keys follow ``output_columns`` order. The final
``{% set coalesce_rules = ... %}`` closes with plain ``%}`` so dbt keeps the
newline between ``CREATE VIEW ... AS`` and the macro's leading ``WITH``, and the
call is emitted at the top level, never inside another ``WITH``. Each source
model also gets a ``-- depends_on: {{ ref(...) }}`` line: the macro reads
``<db>.<schema>.<model>`` directly, so without those lines dbt would not know
the stitch runs after its Stg1_Models.

Artifact.data contract, kind "stitch_stage"
-------------------------------------------
The same fields as a satellite stage, fixed to what a stitch exposes::

    {
      "sat": "SAT_POLICY_BONUS_TRACKING",
      "source_model": "stitch_policy_bonus_tracking",   # the stitch
      "parent_code": "HUB_POLICY",
      "hkey": "POLICY_HKEY",                # optional; must equal naming.hkey
      "parent_bk": "PARENT_BK",             # optional; default PARENT_BK
      "payload": ["BONUSAMOUNT", "CUMULATIVEBONUSPERCENTAGE"],
      "source_tags": ["OPUS_BJAZ_HM_MEMBER_DTLS", ...],  # the stitch's tags
      "load_datetime": "INC_JOB_UPDATED_AT",  # optional; must equal this
      "notes": ["..."]                        # optional header lines
    }

- ``artifact.name == stitch_stage_model(sat)`` and
  ``source_model == naming.stitch_model(sat)``.
- ``hashed_columns``: ``<hkey>: 'PARENT_NK'`` and ``HASHDIFF`` over the sorted
  upper-case payload. ``derived_columns``: ``PARENT_NK`` built by
  ``keys.parent_nk(parent_code, parent_bk)`` and ``LOAD_DATETIME``.
- PARENT_BK handling: the stitch outputs ``parent_bk``, which passes through
  ``include_source_columns=true``; the stage does not re-derive it.
- RECORD_SOURCE handling: as in the template, the stage sets no
  ``RECORD_SOURCE`` derived column. The column passes through from the
  stitch's ``record_source`` output, which the macro builds as a comma list of
  the contributing ``source_tag`` values (``'OPUS_A, OPUS_B'``). Every tag is
  ``prefix + TABLE``, so every stored value starts with the prefix, and the
  ``STARTSWITH``/``LIKE '<GROUP>_%'`` filters of ``sat_multi_source`` and
  ``stitch_incremental`` still match. For the Verifier this means the prefix
  rule (gate G6) is checked on the stitch's ``'source_tag':`` literals; the
  stitch stage has no ``RECORD_SOURCE:`` literal. ``source_tags`` must share
  one group, as in the stitch.
- LOAD_DATETIME handling: the macro always outputs the stitch watermark as
  ``inc_job_updated_at`` (``GREATEST_IGNORE_NULLS`` of the per-source
  ``ldts_column`` values), whatever each source's ``ldts_column`` is. So the
  stage's ``LOAD_DATETIME`` is the column reference ``'INC_JOB_UPDATED_AT'``
  (no ``!``), and gate G7 should expect that for a stage whose source is a
  stitch.
- ``DBT_RUN_TS`` is appended to ``automate_dv.stage()`` output exactly as the
  template stages do (replace of ``SELECT * FROM columns_to_select``).

This module is project-agnostic and is copied byte-for-byte into the sibling
Health_Project.
"""
from __future__ import annotations

import re
from collections.abc import Mapping, Sequence
from typing import Any

from . import emit, keys, naming

__all__ = [
    "StitchRenderError",
    "STITCH_LDTS_OUTPUT",
    "stitch_stage_model",
    "render_stitch",
    "render_stitch_stage",
]

RENDERER = "render_stitch"
UNIQUE_KEY = "parent_bk"
# Column name stitch_incremental gives its combined watermark output.
STITCH_LDTS_OUTPUT = "inc_job_updated_at"
_STAGE_PREFIX = "stg2_sat_stitch__"

_IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_$]*\Z")
_BAD_CHARS = ("'", "\\", "\n", "\r")


class StitchRenderError(ValueError):
    """Artifact data does not fit the stitch or stitch-stage contract."""


# --------------------------------------------------------------------------
# helpers
# --------------------------------------------------------------------------

def stitch_stage_model(sat: str) -> str:
    """``SAT_POLICY_HEADER`` -> ``stg2_sat_stitch__policy_header``."""
    return _STAGE_PREFIX + naming.stitch_model(sat)[len("stitch_"):]


def _data(artifact: Any, kind: str) -> Mapping[str, Any]:
    if getattr(artifact, "kind", None) != kind:
        raise StitchRenderError(
            f"expected an artifact of kind {kind!r}, got "
            f"{getattr(artifact, 'kind', None)!r}")
    data = artifact.data
    if not isinstance(data, Mapping):
        raise StitchRenderError(f"{artifact.name}: data is not a mapping")
    return data


def _text(value: Any, what: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise StitchRenderError(f"{what} is empty or not a string: {value!r}")
    if any(c in value for c in _BAD_CHARS):
        raise StitchRenderError(
            f"{what} {value!r} contains a quote, backslash or newline")
    return value.strip()


def _ident(value: Any, what: str) -> str:
    text = _text(value, what)
    if not _IDENT.match(text):
        raise StitchRenderError(f"{what} {text!r} is not a plain identifier")
    return text


def _seq(value: Any, what: str) -> Sequence[Any]:
    if isinstance(value, (str, bytes)) or not isinstance(value, Sequence):
        raise StitchRenderError(f"{what} must be a list, got {value!r}")
    return value


def _notes(data: Mapping[str, Any]) -> list[str]:
    out = []
    for note in _seq(data.get("notes", ()), "notes"):
        if not isinstance(note, str) or "\n" in note or "\r" in note:
            raise StitchRenderError(f"note {note!r} must be a one-line string")
        out.append(f"-- {note}".rstrip())
    return out


def _group(tags: Sequence[str], prefix: str | None, where: str) -> str:
    """Shared text before the first ``_`` of every tag (stitch_incremental rule)."""
    if not tags:
        raise StitchRenderError(f"{where}: no source_tag given")
    groups = set()
    for tag in tags:
        if "_" not in tag or tag.startswith("_"):
            raise StitchRenderError(
                f"{where}: source_tag {tag!r} is not '<SYSTEM>_<TABLE>'")
        groups.add(tag.split("_", 1)[0])
        if prefix is not None and not tag.startswith(prefix):
            raise StitchRenderError(
                f"{where}: source_tag {tag!r} does not start with prefix {prefix!r}")
    if len(groups) != 1:
        raise StitchRenderError(
            f"{where}: mixed source-system groups {sorted(groups)}; "
            "a stitch must be single-system")
    group = groups.pop()
    if prefix is not None and prefix.split("_", 1)[0] != group:
        raise StitchRenderError(
            f"{where}: prefix {prefix!r} does not match group {group!r}")
    return group


def _q(value: str) -> str:
    return f"'{value}'"


# --------------------------------------------------------------------------
# stitch
# --------------------------------------------------------------------------

def render_stitch(artifact: Any) -> str:
    """Render ``stitch_<sat>.sql``: one top-level ``stitch_incremental`` call."""
    data = _data(artifact, "stitch")
    sat = _text(data.get("sat"), "sat")
    expected_name = naming.stitch_model(sat)
    if artifact.name != expected_name:
        raise StitchRenderError(
            f"artifact name {artifact.name!r} != {expected_name!r} for {sat}")
    where = artifact.name
    parent = _text(data.get("parent_code"), f"{where}: parent_code")
    target_sat = _ident(data.get("target_sat"), f"{where}: target_sat")
    unique_key = data.get("unique_key", UNIQUE_KEY)
    if unique_key != UNIQUE_KEY:
        raise StitchRenderError(
            f"{where}: unique_key must be {UNIQUE_KEY!r}, got {unique_key!r}")
    prefix = data.get("record_source_prefix")
    if prefix is not None:
        prefix = _text(prefix, f"{where}: record_source_prefix")

    output_columns = [
        _ident(c, f"{where}: output column")
        for c in _seq(data.get("output_columns"), f"{where}: output_columns")
    ]
    if not output_columns:
        raise StitchRenderError(f"{where}: output_columns is empty")
    if len(set(output_columns)) != len(output_columns):
        raise StitchRenderError(f"{where}: duplicate output_columns")

    raw_sources = _seq(data.get("sources"), f"{where}: sources")
    if not raw_sources:
        raise StitchRenderError(f"{where}: sources is empty")
    sources = []
    alias_of: dict[str, str] = {}
    providers: dict[str, set[str]] = {c: set() for c in output_columns}
    for i, src in enumerate(raw_sources):
        if not isinstance(src, Mapping):
            raise StitchRenderError(f"{where}: source #{i} is not a mapping")
        model = _ident(src.get("model"), f"{where}: source #{i} model")
        if model in alias_of:
            raise StitchRenderError(f"{where}: source model {model!r} listed twice")
        alias = f"t{i}"
        alias_of[model] = alias
        cols = []
        seen_tgt: set[str] = set()
        for col in _seq(src.get("columns"), f"{where}: {model} columns"):
            if not isinstance(col, Mapping):
                raise StitchRenderError(f"{where}: {model} column is not a mapping")
            col_src = _text(col.get("src"), f"{where}: {model} column src")
            tgt = _ident(col.get("tgt"), f"{where}: {model} column tgt")
            if tgt not in providers:
                raise StitchRenderError(
                    f"{where}: {model} maps to {tgt!r}, not in output_columns")
            if tgt in seen_tgt:
                raise StitchRenderError(
                    f"{where}: {model} maps two columns to {tgt!r}; "
                    "use one coalesce expression")
            seen_tgt.add(tgt)
            providers[tgt].add(model)
            cols.append((col_src, tgt))
        if not cols:
            raise StitchRenderError(f"{where}: {model} has no columns")
        sources.append({
            "model": model,
            "alias": alias,
            "key_column": _text(src.get("key_column"), f"{where}: {model} key_column"),
            "ldts_column": _ident(src.get("ldts_column"), f"{where}: {model} ldts_column"),
            "columns": cols,
            "source_tag": _text(src.get("source_tag"), f"{where}: {model} source_tag"),
        })
    group = _group([s["source_tag"] for s in sources], prefix, where)

    raw_rules = data.get("coalesce_rules")
    if not isinstance(raw_rules, Mapping):
        raise StitchRenderError(f"{where}: coalesce_rules must be a mapping")
    extra = sorted(set(raw_rules) - set(output_columns))
    if extra:
        raise StitchRenderError(
            f"{where}: coalesce_rules for unknown columns {extra}")
    rules: list[tuple[str, list[str]]] = []
    for col in output_columns:
        if col not in raw_rules:
            raise StitchRenderError(f"{where}: no coalesce rule for {col!r}")
        ladder = [_ident(m, f"{where}: rule {col}") for m in
                  _seq(raw_rules[col], f"{where}: rule {col}")]
        if len(set(ladder)) != len(ladder):
            raise StitchRenderError(f"{where}: rule {col!r} lists a model twice")
        if set(ladder) != providers[col]:
            raise StitchRenderError(
                f"{where}: rule {col!r} lists {sorted(ladder)} but the sources "
                f"providing it are {sorted(providers[col])}")
        rules.append((col, [alias_of[m] for m in ladder]))

    lines = [
        "{{ config(materialized='view') }}",
        emit.generated_header(RENDERER),
        f"-- HEALTH STANDARD-MODEL stitch for {sat} ({parent} grain), "
        f"read by {target_sat}.",
        f"-- {len(sources)} source table(s) in one stitch_incremental call "
        "(one affected-keys set, one pass).",
        f"-- source_tag group: {group}. record_source is the comma list of "
        "contributing source_tag values.",
        "-- Precedence per column (first wins):",
    ]
    for col, ladder in rules:
        names = " > ".join(
            next(s["model"] for s in sources if s["alias"] == a) for a in ladder)
        lines.append(f"--   {col}: {names}")
    lines.append("-- Watermark (ldts_column) per source:")
    for s in sources:
        lines.append(f"--   {s['alias']} {s['model']}: {s['ldts_column']}")
    lines.extend(_notes(data))
    for model in sorted(alias_of):
        lines.append(f"-- depends_on: {{{{ ref('{model}') }}}}")
    lines.append("")

    lines.append("{%- set sources = [")
    for n, s in enumerate(sources):
        lines.append("    {")
        lines.append(f"        'model': {_q(s['model'])},")
        lines.append(f"        'alias': {_q(s['alias'])},")
        lines.append(f"        'key_column': {_q(s['key_column'])},")
        lines.append(f"        'ldts_column': {_q(s['ldts_column'])},")
        lines.append("        'columns': [")
        for m, (col_src, tgt) in enumerate(s["columns"]):
            comma = "," if m < len(s["columns"]) - 1 else ""
            lines.append(f"            {{'src': {_q(col_src)}, 'tgt': {_q(tgt)}}}{comma}")
        lines.append("        ],")
        lines.append(f"        'source_tag': {_q(s['source_tag'])}")
        lines.append("    }," if n < len(sources) - 1 else "    }")
    lines.append("] -%}")
    lines.append("")
    lines.append("{%- set output_columns = ["
                 + ", ".join(_q(c) for c in output_columns) + "] -%}")
    lines.append("")
    lines.append("{%- set coalesce_rules = {")
    for n, (col, ladder) in enumerate(rules):
        comma = "," if n < len(rules) - 1 else ""
        lines.append(f"    {_q(col)}: [" + ", ".join(_q(a) for a in ladder) + f"]{comma}")
    # Plain %} (no '-'): keeps the newline dbt needs before the macro's WITH.
    lines.append("} %}")
    lines.append("")
    lines.extend([
        "{{ stitch_incremental(",
        "    sources=sources,",
        "    output_columns=output_columns,",
        "    coalesce_rules=coalesce_rules,",
        f"    unique_key={_q(UNIQUE_KEY)},",
        f"    target_sat={_q(target_sat)}",
        ") }}",
    ])
    return "\n".join(lines) + "\n"


# --------------------------------------------------------------------------
# stage over the stitch
# --------------------------------------------------------------------------

_DBT_RUN_TS_BLOCK = """\
{#-- Stamp DBT_RUN_TS = run timestamp in IST (frozen run_started_at, UTC->Asia/Kolkata). var('to_date') overrides. --#}
{%- set run_ts_utc = run_started_at.strftime('%Y-%m-%d %H:%M:%S') -%}
{%- if var('to_date', none) is not none -%}
    {%- set dbt_run_ts_expr = "CAST('" ~ var('to_date') ~ "' AS TIMESTAMP_NTZ)" -%}
{%- else -%}
    {%- set dbt_run_ts_expr = "CAST(CONVERT_TIMEZONE('UTC','Asia/Kolkata', '" ~ run_ts_utc ~ "'::timestamp_ntz) AS TIMESTAMP_NTZ)" -%}
{%- endif -%}

{#-- Capture stage() output and replace its final SELECT to append DBT_RUN_TS --#}
{%- set stage_sql -%}
{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
{%- endset -%}

{{ stage_sql | replace("SELECT * FROM columns_to_select", "SELECT *, " ~ dbt_run_ts_expr ~ " AS DBT_RUN_TS FROM columns_to_select") }}"""


def render_stitch_stage(artifact: Any) -> str:
    """Render ``stg2_sat_stitch__<sat>.sql``: ``automate_dv.stage()`` over the stitch."""
    data = _data(artifact, "stitch_stage")
    sat = _text(data.get("sat"), "sat")
    expected_name = stitch_stage_model(sat)
    if artifact.name != expected_name:
        raise StitchRenderError(
            f"artifact name {artifact.name!r} != {expected_name!r} for {sat}")
    where = artifact.name
    source_model = _ident(data.get("source_model"), f"{where}: source_model")
    if source_model != naming.stitch_model(sat):
        raise StitchRenderError(
            f"{where}: source_model {source_model!r} != {naming.stitch_model(sat)!r}")
    parent = _text(data.get("parent_code"), f"{where}: parent_code")
    try:
        hkey = naming.hkey(parent)
    except naming.NamingError as exc:
        raise StitchRenderError(f"{where}: {exc}") from None
    if data.get("hkey", hkey) != hkey:
        raise StitchRenderError(
            f"{where}: hkey {data.get('hkey')!r} != {hkey!r} for {parent}")
    parent_bk = _ident(data.get("parent_bk", UNIQUE_KEY.upper()), f"{where}: parent_bk")
    ldts = data.get("load_datetime", STITCH_LDTS_OUTPUT.upper())
    if ldts != STITCH_LDTS_OUTPUT.upper():
        raise StitchRenderError(
            f"{where}: load_datetime must be {STITCH_LDTS_OUTPUT.upper()!r} "
            f"(the stitch's watermark output), got {ldts!r}")

    payload = [_ident(p, f"{where}: payload column").upper()
               for p in _seq(data.get("payload"), f"{where}: payload")]
    if not payload:
        raise StitchRenderError(f"{where}: payload is empty")
    if len(set(payload)) != len(payload):
        raise StitchRenderError(f"{where}: duplicate payload columns")
    tags = [_text(t, f"{where}: source_tag")
            for t in _seq(data.get("source_tags"), f"{where}: source_tags")]
    group = _group(tags, None, where)
    nk = keys.parent_nk(parent, parent_bk)

    lines = [
        "{{ config(materialized='view') }}",
        emit.generated_header(RENDERER),
        f"-- HEALTH STANDARD-MODEL stage() pass over {source_model} -- serves {sat}.",
        f"-- {hkey} hashed once here (namespaced: {nk}).",
        f"-- {parent_bk} and record_source pass through from the stitch "
        "(include_source_columns=true).",
        "-- record_source is the stitch's comma list of source_tag values, "
        f"each starting {group}_:",
        f"--   {', '.join(tags)}",
        f"-- LOAD_DATETIME reads the stitch's {STITCH_LDTS_OUTPUT} "
        "(greatest of the per-source watermarks).",
    ]
    lines.extend(_notes(data))
    lines.append("")
    lines.append("{%- set yaml_metadata -%}")
    lines.append(f"source_model: {_q(source_model)}")
    lines.append("hashed_columns:")
    lines.append(f"  {hkey}: 'PARENT_NK'")
    lines.append("  HASHDIFF:")
    lines.append("    is_hashdiff: true")
    lines.append("    columns:")
    for col in sorted(payload):
        lines.append(f"      - {_q(col)}")
    lines.append("derived_columns:")
    lines.append(f'  PARENT_NK: "{nk}"')
    lines.append(f"  LOAD_DATETIME: {_q(STITCH_LDTS_OUTPUT.upper())}")
    lines.append("{%- endset -%}")
    lines.append("")
    lines.append("{% set metadata_dict = fromyaml(yaml_metadata) %}")
    lines.append("")
    lines.append(_DBT_RUN_TS_BLOCK)
    return "\n".join(lines) + "\n"
