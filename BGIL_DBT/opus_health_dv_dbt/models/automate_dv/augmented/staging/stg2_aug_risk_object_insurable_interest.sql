-- automate_dv.stage() for SAT_AUG_RISK_OBJECT_INSURABLE_INTEREST, read off central view stitch_v31_product.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v31_product'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LOAN_TENOR'
      - 'OTHER_LOAN_TYPE_DESCRIPTION'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(AUG_RISK_OBJECT_INSURABLE_INTEREST__LOAN_TENOR, AUG_RISK_OBJECT_INSURABLE_INTEREST__OTHER_LOAN_TYPE_DESCRIPTION) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  LOAN_TENOR: 'AUG_RISK_OBJECT_INSURABLE_INTEREST__LOAN_TENOR'
  OTHER_LOAN_TYPE_DESCRIPTION: 'AUG_RISK_OBJECT_INSURABLE_INTEREST__OTHER_LOAN_TYPE_DESCRIPTION'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v31_product'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
