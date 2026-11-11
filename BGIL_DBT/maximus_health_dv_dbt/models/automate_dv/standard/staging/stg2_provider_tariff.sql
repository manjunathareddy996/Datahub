-- automate_dv.stage() for SAT_PROVIDER_TARIFF, read off central view stitch_v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v02_claim'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PACKAGE_RATE'
      - 'SERVICE_CODE'
      - 'SERVICE_DESCRIPTION'
      - 'TARIFF_RATE'
      - 'SERVICE_CODE_CK'
derived_columns:
  PARTY_NK: "case when coalesce(PROVIDER_TARIFF__PACKAGE_RATE, PROVIDER_TARIFF__SERVICE_CODE, PROVIDER_TARIFF__SERVICE_DESCRIPTION, PROVIDER_TARIFF__TARIFF_RATE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  SERVICE_CODE_CK: 'PROVIDER_TARIFF__SERVICE_CODE_CK'
  PACKAGE_RATE: 'PROVIDER_TARIFF__PACKAGE_RATE'
  SERVICE_CODE: 'PROVIDER_TARIFF__SERVICE_CODE'
  SERVICE_DESCRIPTION: 'PROVIDER_TARIFF__SERVICE_DESCRIPTION'
  TARIFF_RATE: 'PROVIDER_TARIFF__TARIFF_RATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
