"""Render raw-vault hubs, links and satellites (Requirements 4.2, 5.4, 5.9,
6.3, 6.4, 7.1).

Each function turns one planned ``Artifact`` (or its ``data`` mapping) into
the text of one model file. The shapes copy the Template_Project models
``hub_agent.sql``, ``lnk_claim_party.sql``, ``sat_agreement_commercial_terms.sql``,
``sat_lnk_policy_party_role.sql``, ``sat_party_banking.sql`` and
``sat_party_contact_address_link.sql``: the same config block, the same
``yaml_metadata`` block and the same macro call layout. The only additions
are the GENERATED header on the first line (so ``emit.has_generated_header``
recognises the file even when a multi-line ``config`` block follows) and a
short description comment.

Artifact.data contract
----------------------

Every kind accepts ``header`` (optional list of comment lines, written
without the ``--`` marker, kept in the given order). Column and model names
must be plain identifiers (``[A-Za-z_][A-Za-z0-9_]*``); anything else raises
``RenderVaultError``. Defaults are shown after ``=``.

``kind="hub"``
    ``hub`` (vault code, for example ``HUB_CLAIM``), ``src_pk``,
    ``src_nk='PARENT_BK'``, ``src_ldts='LOAD_DATETIME'``,
    ``src_source='RECORD_SOURCE'``, ``source_model`` (non-empty list of hub
    stage names; rendered sorted and de-duplicated).

``kind="link"``
    ``link`` (vault code, for example ``LNK_CLAIM_PARTY``), ``src_pk``,
    ``src_fk`` (list of two or more hub hash keys, rendered in the given order
    and never re-sorted: the planner supplies the Template_Project order for
    links the template has, for example ``PARTY_HKEY`` then ``CLAIM_HKEY`` for
    ``LNK_CLAIM_PARTY``, and sorted order otherwise), ``src_ldts``,
    ``src_source``, ``source_model`` (non-empty list of link stage names;
    rendered sorted and de-duplicated).

``kind="sat"``
    ``satellite`` (vault code), ``parent`` (optional hub or link code, used
    in the description comment), ``macro`` (one of ``sat``, ``ma_sat``,
    ``sat_multi_source``, ``ma_sat_multi_source``), ``src_pk``,
    ``src_cdk`` (list; empty for ``sat`` and ``sat_multi_source``, non-empty
    for the ``ma_`` macros; rendered in the given order), ``src_payload``
    (non-empty list; rendered sorted and de-duplicated),
    ``src_hashdiff='HASHDIFF'``, ``src_eff`` (optional; not accepted by
    ``ma_sat_multi_source``, whose macro has no such parameter),
    ``src_ldts='LOAD_DATETIME'``, ``src_source='RECORD_SOURCE'``,
    ``src_extra_columns`` (optional list), ``source_model``, and for the
    multi-source macros also ``src_column_map``, ``src_record_source_map``
    and ``unique_key``.

    - ``sat`` / ``ma_sat``: ``source_model`` is one stage name (a string or a
      one-element list); it renders as a string, as in the template. The
      config is the template's ``incremental`` / ``append`` block. These
      macros take no maps and no ``unique_key``.
    - ``sat_multi_source`` / ``ma_sat_multi_source``: ``source_model`` is an
      ordered list of two or more stage names (rendered sorted, so the output
      does not depend on planner order). ``src_column_map`` maps every stage
      to the payload columns it provides (each column must be in
      ``src_payload``, and every payload column must come from at least one
      stage). ``src_record_source_map`` maps every stage to its non-empty
      source-system group. Both maps must have exactly the ``source_model``
      keys. ``unique_key`` (list) must contain ``src_pk``, ``src_source`` and
      every ``src_cdk`` column; when omitted it defaults to
      ``[src_pk, *src_cdk, src_hashdiff, src_source]``. The config is the
      skill §4d block: ``materialized='incremental'``,
      ``incremental_strategy='merge'``,
      ``on_schema_change='append_new_columns'`` and that ``unique_key``.

Multi-source parameter check
----------------------------

Checked against the copied ``macros/sat_multi_source.sql`` and
``macros/ma_sat_multi_source.sql``:

- ``sat_multi_source(src_pk, src_hashdiff, src_payload, src_ldts, src_source,
  source_model, src_extra_columns, src_eff, src_column_map, src_run_ts,
  src_record_source_map, src_object_columns, src_hashdiff_alias)``
- ``ma_sat_multi_source(src_pk, src_cdk, src_hashdiff, src_payload, src_ldts,
  src_source, source_model, src_extra_columns, src_column_map,
  src_record_source_map, src_run_ts)``; no ``src_eff``.
- ``DBT_RUN_TS`` is not passed in ``src_extra_columns`` to either
  multi-source macro. Both stamp it themselves from ``src_run_ts`` (default
  ``'DBT_RUN_TS'``) and drop it from the payload superset, so passing it does
  nothing. The renderer removes it from ``src_extra_columns`` for these two
  macros and omits the parameter when nothing is left. For ``automate_dv.sat``
  and ``automate_dv.ma_sat`` over a stage that carries ``DBT_RUN_TS`` (the
  stitch stage), ``src_extra_columns: ['DBT_RUN_TS']`` is kept, as in the
  template ``sat_common_geo.sql``.

All functions are pure and deterministic. Output uses ``\\n`` line endings and
ends with one newline. This module is project-agnostic and is copied
byte-for-byte into the sibling Health_Project (Requirement 10.3).
"""
from __future__ import annotations

import re
from collections.abc import Mapping
from typing import Any

from .emit import generated_header

__all__ = [
    "RenderVaultError",
    "SAT_MACROS",
    "MULTI_SOURCE_MACROS",
    "RUN_TS_COLUMN",
    "render_hub",
    "render_link",
    "render_sat",
    "render_vault",
]

RENDERER = "render_vault"

SAT_MACROS = ("sat", "ma_sat", "sat_multi_source", "ma_sat_multi_source")
MULTI_SOURCE_MACROS = frozenset({"sat_multi_source", "ma_sat_multi_source"})
MULTI_ACTIVE_MACROS = frozenset({"ma_sat", "ma_sat_multi_source"})
RUN_TS_COLUMN = "DBT_RUN_TS"

# Macro call prefix and continuation indent, copied from the template models.
_CALLS = {
    "hub": ("{{ automate_dv.hub(", 20),
    "link": ("{{ automate_dv.link(", 21),
    "sat": ("{{ automate_dv.sat(", 20),
    "ma_sat": ("{{ automate_dv.ma_sat(", 23),
    "sat_multi_source": ("{{ sat_multi_source(", 20),
    "ma_sat_multi_source": ("{{ ma_sat_multi_source(", 23),
}

_HUB_CONFIG = ["{{ config(materialized='incremental') }}"]
_SAT_CONFIG = [
    "{{",
    "    config(",
    "        materialized='incremental',",
    "        incremental_strategy='append',",
    "    )",
    "}}",
]

_IDENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


class RenderVaultError(ValueError):
    """A hub, link or sat artifact is malformed."""


# --------------------------------------------------------------------------
# Input helpers
# --------------------------------------------------------------------------

def _data(artifact: Any, kind: str) -> Mapping[str, Any]:
    data = getattr(artifact, "data", artifact)
    if not isinstance(data, Mapping):
        raise RenderVaultError(f"{kind} artifact data must be a mapping")
    got = getattr(artifact, "kind", kind)
    if got != kind:
        raise RenderVaultError(f"render_{kind} got artifact kind {got!r}")
    return data


def _ident(value: Any, what: str) -> str:
    if not isinstance(value, str) or not _IDENT.match(value):
        raise RenderVaultError(f"{what} must be a plain identifier, got {value!r}")
    return value


def _get(data: Mapping[str, Any], key: str, what: str,
         default: str | None = None) -> str:
    value = data.get(key, default)
    if value is None:
        raise RenderVaultError(f"{what}: data lacks {key!r}")
    return _ident(value, f"{what} {key}")


def _names(value: Any, what: str, *, allow_empty: bool = False) -> list[str]:
    """Validated list of identifiers, in the given order."""
    if value is None:
        value = ()
    if isinstance(value, str) or not isinstance(value, (list, tuple)):
        raise RenderVaultError(f"{what} must be a list, got {value!r}")
    out = [_ident(v, what) for v in value]
    if not out and not allow_empty:
        raise RenderVaultError(f"{what} is empty")
    return out


def _sorted_unique(values: list[str]) -> list[str]:
    return sorted(set(values))


def _no_dupes(values: list[str], what: str) -> list[str]:
    seen: set[str] = set()
    for v in values:
        if v.upper() in seen:
            raise RenderVaultError(f"{what} lists {v!r} twice")
        seen.add(v.upper())
    return values


def _header_lines(data: Mapping[str, Any], what: str) -> list[str]:
    raw = data.get("header", ())
    if isinstance(raw, str) or not isinstance(raw, (list, tuple)):
        raise RenderVaultError(f"{what}: header must be a list of strings")
    out = []
    for line in raw:
        if not isinstance(line, str) or "\n" in line or "\r" in line:
            raise RenderVaultError(f"{what}: header line {line!r} is invalid")
        out.append(f"-- {line}".rstrip())
    return out


def _plural(n: int, word: str) -> str:
    return f"{n} {word}" if n == 1 else f"{n} {word}s"


# --------------------------------------------------------------------------
# Text helpers
# --------------------------------------------------------------------------

def _q(name: str) -> str:
    return f"'{name}'"


def _yaml_list(key: str, values: list[str]) -> list[str]:
    return [f"{key}:"] + [f"  - {_q(v)}" for v in values]


def _yaml_map(key: str, mapping: Mapping[str, str], order: list[str]) -> list[str]:
    return [f"{key}:"] + [f"  {k}: {_q(mapping[k])}" for k in order]


def _call(macro: str, params: list[str], tail: list[str] | None = None) -> list[str]:
    """Macro call with ``name=metadata_dict['name']`` arguments.

    ``tail`` holds the already-formatted lines of a final literal argument
    (``src_column_map={...}``); without it the call closes after the last
    metadata argument.
    """
    prefix, indent = _CALLS[macro]
    pad = " " * indent
    args = [f"{p}=metadata_dict['{p}']" for p in params]
    lines = []
    for i, arg in enumerate(args):
        lead = prefix if i == 0 else pad
        last = i == len(args) - 1 and not tail
        lines.append(f"{lead}{arg}{') }}' if last else ','}")
    if tail:
        lines.extend(tail)
    return lines


def _assemble(header: list[str], config: list[str], yaml_lines: list[str],
              call_lines: list[str]) -> str:
    lines = [generated_header(RENDERER)]
    lines += config
    lines += [""]
    lines += header
    lines += ["", "{%- set yaml_metadata -%}"]
    lines += yaml_lines
    lines += ["{%- endset -%}", "",
              "{% set metadata_dict = fromyaml(yaml_metadata) %}", ""]
    lines += call_lines
    return "\n".join(lines) + "\n"


# --------------------------------------------------------------------------
# Hub and link
# --------------------------------------------------------------------------

def render_hub(artifact: Any) -> str:
    """Render ``hub_<name>.sql`` (``automate_dv.hub``, sorted source_model)."""
    data = _data(artifact, "hub")
    code = _get(data, "hub", "hub")
    src_pk = _get(data, "src_pk", code)
    src_nk = _get(data, "src_nk", code, "PARENT_BK")
    src_ldts = _get(data, "src_ldts", code, "LOAD_DATETIME")
    src_source = _get(data, "src_source", code, "RECORD_SOURCE")
    models = _sorted_unique(_names(data.get("source_model"),
                                   f"{code} source_model"))
    header = [f"-- hub() for {code}, "
              f"{_plural(len(models), 'source model')}."]
    header += _header_lines(data, code)
    yaml_lines = _yaml_list("source_model", models) + [
        f"src_pk: {_q(src_pk)}",
        f"src_nk: {_q(src_nk)}",
        f"src_ldts: {_q(src_ldts)}",
        f"src_source: {_q(src_source)}",
    ]
    call = _call("hub", ["src_pk", "src_nk", "src_ldts", "src_source",
                         "source_model"])
    return _assemble(header, _HUB_CONFIG, yaml_lines, call)


def render_link(artifact: Any) -> str:
    """Render ``lnk_<name>.sql`` (``automate_dv.link``, src_fk as planned)."""
    data = _data(artifact, "link")
    code = _get(data, "link", "link")
    src_pk = _get(data, "src_pk", code)
    src_fk = _no_dupes(_names(data.get("src_fk"), f"{code} src_fk"),
                       f"{code} src_fk")
    if len(src_fk) < 2:
        raise RenderVaultError(f"{code}: src_fk needs two or more hub keys")
    if src_pk.upper() in {f.upper() for f in src_fk}:
        raise RenderVaultError(f"{code}: src_pk {src_pk} is also in src_fk")
    src_ldts = _get(data, "src_ldts", code, "LOAD_DATETIME")
    src_source = _get(data, "src_source", code, "RECORD_SOURCE")
    models = _sorted_unique(_names(data.get("source_model"),
                                   f"{code} source_model"))
    header = [f"-- link() for {code}, "
              f"{_plural(len(models), 'source model')}."]
    header += _header_lines(data, code)
    yaml_lines = (_yaml_list("source_model", models)
                  + [f"src_pk: {_q(src_pk)}"]
                  + _yaml_list("src_fk", src_fk)
                  + [f"src_ldts: {_q(src_ldts)}",
                     f"src_source: {_q(src_source)}"])
    call = _call("link", ["src_pk", "src_fk", "src_ldts", "src_source",
                          "source_model"])
    return _assemble(header, _HUB_CONFIG, yaml_lines, call)


# --------------------------------------------------------------------------
# Satellites
# --------------------------------------------------------------------------

def _sat_models(data: Mapping[str, Any], macro: str, code: str) -> list[str]:
    raw = data.get("source_model")
    if isinstance(raw, str):
        raw = [raw]
    models = _sorted_unique(_names(raw, f"{code} source_model"))
    if macro in MULTI_SOURCE_MACROS:
        if len(models) < 2:
            raise RenderVaultError(
                f"{code}: {macro} needs two or more source models; use "
                f"{'automate_dv.ma_sat' if macro.startswith('ma_') else 'automate_dv.sat'}")
    elif len(models) != 1:
        raise RenderVaultError(
            f"{code}: automate_dv.{macro} takes exactly one source model, "
            f"got {len(models)}")
    return models


def _source_map(data: Mapping[str, Any], key: str, models: list[str],
                code: str) -> Mapping[str, Any]:
    raw = data.get(key)
    if not isinstance(raw, Mapping):
        raise RenderVaultError(f"{code}: {key} must be a mapping")
    if set(raw) != set(models):
        missing = sorted(set(models) - set(raw))
        extra = sorted(set(raw) - set(models))
        raise RenderVaultError(
            f"{code}: {key} keys must equal source_model "
            f"(missing {missing}, extra {extra})")
    return raw


def _column_map(data: Mapping[str, Any], models: list[str], payload: list[str],
                code: str) -> dict[str, list[str]]:
    raw = _source_map(data, "src_column_map", models, code)
    allowed = set(payload)
    out: dict[str, list[str]] = {}
    covered: set[str] = set()
    for model in models:
        cols = _sorted_unique(_names(raw[model], f"{code} src_column_map[{model}]",
                                     allow_empty=True))
        stray = sorted(set(cols) - allowed)
        if stray:
            raise RenderVaultError(
                f"{code}: src_column_map[{model}] lists {stray}, "
                f"not in src_payload")
        covered.update(cols)
        out[model] = cols
    orphan = sorted(allowed - covered)
    if orphan:
        raise RenderVaultError(
            f"{code}: payload column(s) {orphan} come from no source model")
    return out


def _record_source_map(data: Mapping[str, Any], models: list[str],
                       code: str) -> dict[str, str]:
    raw = _source_map(data, "src_record_source_map", models, code)
    return {m: _ident(raw[m], f"{code} src_record_source_map[{m}]")
            for m in models}


def _unique_key(data: Mapping[str, Any], src_pk: str, cdk: list[str],
                src_hashdiff: str, src_source: str, code: str) -> list[str]:
    raw = data.get("unique_key")
    if raw is None:
        return [src_pk, *cdk, src_hashdiff, src_source]
    keys = _no_dupes(_names(raw, f"{code} unique_key"), f"{code} unique_key")
    have = {k.upper() for k in keys}
    need = [src_pk, src_source, *cdk]
    missing = [k for k in need if k.upper() not in have]
    if missing:
        raise RenderVaultError(
            f"{code}: unique_key {keys} lacks {missing}")
    return keys


def _multi_config(unique_key: list[str]) -> list[str]:
    keys = ", ".join(_q(k) for k in unique_key)
    return [
        "{{",
        "    config(materialized='incremental', incremental_strategy='merge',",
        "           on_schema_change='append_new_columns',",
        f"           unique_key=[{keys}])",
        "}}",
    ]


def render_sat(artifact: Any) -> str:
    """Render ``sat_<name>.sql`` with the planned satellite macro."""
    data = _data(artifact, "sat")
    code = _get(data, "satellite", "sat")
    macro = data.get("macro")
    if macro not in SAT_MACROS:
        raise RenderVaultError(
            f"{code}: macro {macro!r} not in {list(SAT_MACROS)}")
    multi = macro in MULTI_SOURCE_MACROS
    src_pk = _get(data, "src_pk", code)
    cdk = _no_dupes(_names(data.get("src_cdk"), f"{code} src_cdk",
                           allow_empty=True), f"{code} src_cdk")
    if macro in MULTI_ACTIVE_MACROS and not cdk:
        raise RenderVaultError(f"{code}: {macro} needs a non-empty src_cdk")
    if macro not in MULTI_ACTIVE_MACROS and cdk:
        raise RenderVaultError(
            f"{code}: {macro} takes no src_cdk; use the ma_ macro")
    payload = _sorted_unique(_names(data.get("src_payload"),
                                    f"{code} src_payload"))
    src_hashdiff = _get(data, "src_hashdiff", code, "HASHDIFF")
    src_ldts = _get(data, "src_ldts", code, "LOAD_DATETIME")
    src_source = _get(data, "src_source", code, "RECORD_SOURCE")
    src_eff = data.get("src_eff")
    if src_eff is not None:
        src_eff = _ident(src_eff, f"{code} src_eff")
        if macro == "ma_sat_multi_source":
            raise RenderVaultError(
                f"{code}: ma_sat_multi_source has no src_eff parameter")
    extra = _no_dupes(_names(data.get("src_extra_columns"),
                             f"{code} src_extra_columns", allow_empty=True),
                      f"{code} src_extra_columns")
    if multi:
        extra = [c for c in extra if c.upper() != RUN_TS_COLUMN]
    models = _sat_models(data, macro, code)

    if not multi:
        for key in ("src_column_map", "src_record_source_map", "unique_key"):
            if data.get(key) is not None:
                raise RenderVaultError(
                    f"{code}: automate_dv.{macro} takes no {key}")

    parent = data.get("parent")
    grain = f" ({_ident(parent, f'{code} parent')} grain)" if parent else ""
    header = [f"-- {macro}() for {code}{grain}, "
              f"{_plural(len(models), 'source model')}."]
    header += _header_lines(data, code)

    yaml_lines: list[str] = []
    if multi:
        yaml_lines += _yaml_list("source_model", models)
    else:
        yaml_lines.append(f"source_model: {_q(models[0])}")
    yaml_lines.append(f"src_pk: {_q(src_pk)}")
    if cdk:
        yaml_lines += _yaml_list("src_cdk", cdk)
    yaml_lines += _yaml_list("src_payload", payload)
    yaml_lines.append(f"src_hashdiff: {_q(src_hashdiff)}")
    if src_eff is not None:
        yaml_lines.append(f"src_eff: {_q(src_eff)}")
    yaml_lines += [f"src_ldts: {_q(src_ldts)}", f"src_source: {_q(src_source)}"]
    if extra:
        yaml_lines += _yaml_list("src_extra_columns", extra)

    params = ["src_pk"]
    if cdk:
        params.append("src_cdk")
    params.append("src_payload")
    if extra:
        params.append("src_extra_columns")
    params.append("src_hashdiff")
    if src_eff is not None:
        params.append("src_eff")
    params += ["src_ldts", "src_source", "source_model"]

    if not multi:
        config = _SAT_CONFIG
        call = _call(macro, params)
    else:
        column_map = _column_map(data, models, payload, code)
        rs_map = _record_source_map(data, models, code)
        unique_key = _unique_key(data, src_pk, cdk, src_hashdiff, src_source,
                                 code)
        yaml_lines += _yaml_map("src_record_source_map", rs_map, models)
        params.append("src_record_source_map")
        indent = _CALLS[macro][1]
        pad = " " * indent
        entries = [
            f"{pad}    {_q(m)}: [{', '.join(_q(c) for c in column_map[m])}]"
            + ("," if i < len(models) - 1 else "")
            for i, m in enumerate(models)
        ]
        tail = [f"{pad}src_column_map={{"] + entries + [f"{pad}}}) }}}}"]
        config = _multi_config(unique_key)
        call = _call(macro, params, tail)

    return _assemble(header, config, yaml_lines, call)


def render_vault(artifact: Any) -> str:
    """Dispatch on ``artifact.kind`` (``hub``, ``link`` or ``sat``)."""
    kind = getattr(artifact, "kind", None)
    renderers = {"hub": render_hub, "link": render_link, "sat": render_sat}
    if kind not in renderers:
        raise RenderVaultError(f"render_vault cannot render kind {kind!r}")
    return renderers[kind](artifact)
