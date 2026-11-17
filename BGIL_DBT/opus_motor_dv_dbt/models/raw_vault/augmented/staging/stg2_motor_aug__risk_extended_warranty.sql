-- automate_dv.stage() for SAT_AUG_RISK_EXTENDED_WARRANTY, read off central view stitch_motor__v08_org_unit.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v08_org_unit'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MANUFACTURER_WARRANTY_PERIOD'
      - 'MANUFACTURER_WARRANTY_TERM_MONTHS'
      - 'WARRANTY_INVOICE_DATE'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(AUG_RISK_EXTENDED_WARRANTY__MANUFACTURER_WARRANTY_PERIOD, AUG_RISK_EXTENDED_WARRANTY__MANUFACTURER_WARRANTY_TERM_MONTHS, AUG_RISK_EXTENDED_WARRANTY__WARRANTY_INVOICE_DATE) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  MANUFACTURER_WARRANTY_PERIOD: 'AUG_RISK_EXTENDED_WARRANTY__MANUFACTURER_WARRANTY_PERIOD'
  MANUFACTURER_WARRANTY_TERM_MONTHS: 'AUG_RISK_EXTENDED_WARRANTY__MANUFACTURER_WARRANTY_TERM_MONTHS'
  WARRANTY_INVOICE_DATE: 'AUG_RISK_EXTENDED_WARRANTY__WARRANTY_INVOICE_DATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v08_org_unit'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
