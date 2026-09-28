#!/usr/bin/env python3
"""One-shot migration: rewrite every MULTI-SOURCE satellite in maximus_partner_dv_dbt to
call the custom sat_multi_source / ma_sat_multi_source macros instead of automate_dv.sat()/ma_sat().

Single-source satellites (source_model is a scalar string) are left untouched: the skill keeps
those on automate_dv.sat()/ma_sat().

The per-source src_column_map is derived from each source stg2 model's own
`HASHDIFF_<SAT>` hashed-columns block (the generator's record of what that source contributes to
that satellite), intersected with the satellite payload. This is what keeps the fan-in /
dropped-column reconciliation honest (skill 2b / defect classes #9/#10).

RECORD_SOURCE prefix / source-system group for this project is MAXIMUS (from the `!MAXIMUS_...`
RECORD_SOURCE literals in the stg2 models).
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODELS = os.path.join(ROOT, "models", "raw_vault")
SAT_DIRS = [
    os.path.join(MODELS, "standard", "satellites"),
    os.path.join(MODELS, "augmented", "satellites"),
]
STG_DIRS = [
    os.path.join(MODELS, "standard", "staging"),
    os.path.join(MODELS, "augmented", "staging"),
]
GROUP = "MAXIMUS"


def read(path):
    with open(path, "r") as f:
        return f.read()


def find_yaml_block(text):
    """Return the raw yaml_metadata block text."""
    m = re.search(r"{%-?\s*set yaml_metadata\s*-?%}(.*?){%-?\s*endset\s*-?%}", text, re.S)
    return m.group(1) if m else None


def parse_scalar_or_list(block, key):
    """Return ('scalar', value) or ('list', [values]) or (None, None) for a yaml key."""
    # scalar: key: 'value'
    m = re.search(r"^" + re.escape(key) + r":\s*'([^']*)'\s*$", block, re.M)
    if m:
        return "scalar", m.group(1)
    # list: key:\n  - 'a'\n  - 'b'
    m = re.search(r"^" + re.escape(key) + r":\s*\n((?:\s*-\s*'[^']*'\s*\n?)+)", block, re.M)
    if m:
        items = re.findall(r"-\s*'([^']*)'", m.group(1))
        return "list", items
    return None, None


def stg_path(model_name):
    for d in STG_DIRS:
        p = os.path.join(d, model_name + ".sql")
        if os.path.isfile(p):
            return p
    return None


def hashdiff_columns(stg_text, hashdiff_name):
    """Extract the column list under a HASHDIFF_<SAT> hashed_columns entry."""
    # match:  HASHDIFF_X:\n    is_hashdiff: true\n    columns:\n      - 'A'\n      - 'B'
    pat = (
        r"^\s*" + re.escape(hashdiff_name) + r":\s*\n"
        r"\s*is_hashdiff:\s*true\s*\n"
        r"\s*columns:\s*\n"
        r"((?:\s*-\s*'[^']*'\s*\n?)+)"
    )
    m = re.search(pat, stg_text, re.M)
    if not m:
        return None
    return re.findall(r"-\s*'([^']*)'", m.group(1))


def null_derived_columns(stg_text):
    """Return the set of derived_columns whose expression is a bare cast(null as ...) —
    i.e. columns the source does NOT genuinely populate."""
    m = re.search(r"^derived_columns:\s*\n(.*?)(?:^{%-?\s*endset|\Z)", stg_text, re.S | re.M)
    body = m.group(1) if m else stg_text
    nulls = set()
    for cm in re.finditer(r"^\s*([A-Z0-9_]+):\s*\"([^\"]*)\"\s*$", body, re.M):
        name, expr = cm.group(1), cm.group(2).strip().lower()
        if re.fullmatch(r"cast\(\s*null\s+as\s+\w+\s*\)", expr):
            nulls.add(name)
    return nulls


def build_column_map(source_models, payload, hashdiff_name):
    col_map = {}
    for sm in source_models:
        sp = stg_path(sm)
        if sp is None:
            print(f"  !! source stg2 not found: {sm}", file=sys.stderr)
            col_map[sm] = []
            continue
        stg_text = read(sp)
        cols = hashdiff_columns(stg_text, hashdiff_name)
        if cols is None:
            print(f"  !! {sm} has no {hashdiff_name} block", file=sys.stderr)
            col_map[sm] = []
            continue
        nulls = null_derived_columns(stg_text)
        # keep only payload columns this source genuinely populates (in payload,
        # in the source's hashdiff block, and NOT a bare cast(null as ...) derived expr).
        # preserve satellite payload order for deterministic output.
        keep = [c for c in payload if c in cols and c not in nulls]
        col_map[sm] = keep
    return col_map


def yaml_list(items, indent):
    return "\n".join(f"{indent}- '{c}'" for c in items)


def render_column_map(col_map):
    lines = []
    for sm, cols in col_map.items():
        inner = ", ".join(f"'{c}'" for c in cols)
        lines.append(f"                        '{sm}': [{inner}]")
    return ",\n".join(lines)


def render_record_source_map(source_models):
    return "\n".join(f"  {sm}: '{GROUP}'" for sm in source_models)


def convert(path):
    text = read(path)
    block = find_yaml_block(text)
    if block is None:
        return None
    kind, source_models = parse_scalar_or_list(block, "source_model")
    if kind != "list" or len(source_models) < 2:
        return None  # single-source, leave untouched

    is_ma = "automate_dv.ma_sat(" in text or "ma_sat_multi_source(" in text or "src_cdk:" in block
    _, src_pk = parse_scalar_or_list(block, "src_pk")
    _, src_hashdiff = parse_scalar_or_list(block, "src_hashdiff")
    _, src_ldts = parse_scalar_or_list(block, "src_ldts")
    _, src_source = parse_scalar_or_list(block, "src_source")
    pk_kind, payload = parse_scalar_or_list(block, "src_payload")
    cdk_kind, src_cdk = parse_scalar_or_list(block, "src_cdk")

    col_map = build_column_map(source_models, payload, src_hashdiff)

    # preserve the leading comment lines (everything between config and the set block)
    header_m = re.search(r"(--.*?)\n\n{%-?\s*set yaml_metadata", text, re.S)
    header = header_m.group(1) if header_m else ""

    sm_yaml = yaml_list(source_models, "  ")
    payload_yaml = yaml_list(payload, "  ")

    if is_ma:
        # multi-active -> ma_sat_multi_source
        cdk_list = src_cdk if cdk_kind == "list" else [src_cdk]
        cdk_yaml = yaml_list(cdk_list, "  ")
        uk = "[" + ", ".join(f"'{c}'" for c in ([src_pk] + cdk_list + [src_hashdiff, src_source])) + "]"
        out = f"""{{{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key={uk}
    )
}}}}

{header}

{{%- set yaml_metadata -%}}
source_model:
{sm_yaml}
src_pk: '{src_pk}'
src_cdk:
{cdk_yaml}
src_payload:
{payload_yaml}
src_hashdiff: '{src_hashdiff}'
src_ldts: '{src_ldts}'
src_source: '{src_source}'
{{%- endset -%}}

{{% set metadata_dict = fromyaml(yaml_metadata) %}}

{{{{ ma_sat_multi_source(src_pk=metadata_dict['src_pk'],
                       src_cdk=metadata_dict['src_cdk'],
                       src_payload=metadata_dict['src_payload'],
                       src_hashdiff=metadata_dict['src_hashdiff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       source_model=metadata_dict['source_model'],
                       src_column_map={{
{render_column_map(col_map)}
                       }}) }}}}
"""
    else:
        # single-active -> sat_multi_source
        uk = "[" + ", ".join(f"'{c}'" for c in [src_pk, src_hashdiff, src_source]) + "]"
        rsm_yaml = render_record_source_map(source_models)
        out = f"""{{{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        on_schema_change='append_new_columns',
        unique_key={uk}
    )
}}}}

{header}

{{%- set yaml_metadata -%}}
source_model:
{sm_yaml}
src_pk: '{src_pk}'
src_payload:
{payload_yaml}
src_hashdiff: '{src_hashdiff}'
src_ldts: '{src_ldts}'
src_source: '{src_source}'
src_record_source_map:
{rsm_yaml}
{{%- endset -%}}

{{% set metadata_dict = fromyaml(yaml_metadata) %}}

{{{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_column_map={{
{render_column_map(col_map)}
                    }}) }}}}
"""
    with open(path, "w") as f:
        f.write(out)
    return (is_ma, source_models, col_map)


def main():
    converted = []
    for d in SAT_DIRS:
        for fn in sorted(os.listdir(d)):
            if not fn.endswith(".sql"):
                continue
            p = os.path.join(d, fn)
            res = convert(p)
            if res is not None:
                is_ma, sms, cm = res
                kind = "ma_sat_multi_source" if is_ma else "sat_multi_source"
                converted.append(fn)
                print(f"[{kind}] {fn}  ({len(sms)} sources)")
                for sm, cols in cm.items():
                    if not cols:
                        print(f"    WARNING empty column list for {sm}")
    print(f"\nConverted {len(converted)} multi-source satellites.")


if __name__ == "__main__":
    main()
