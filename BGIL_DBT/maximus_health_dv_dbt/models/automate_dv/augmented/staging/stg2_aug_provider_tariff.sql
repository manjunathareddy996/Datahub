-- automate_dv.stage() for SAT_AUG_PROVIDER_TARIFF, read off central view stitch_v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v02_claim'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'I3_TARIFF_PRICE'
      - 'I3_TARIFF_REMARKS'
      - 'SERVICE_TYPE_CODE'
      - 'SERVICE_TYPE_DESCRIPTION'
      - 'SERVICE_CODE_CK'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PROVIDER_TARIFF__I3_TARIFF_PRICE, AUG_PROVIDER_TARIFF__I3_TARIFF_REMARKS, AUG_PROVIDER_TARIFF__SERVICE_TYPE_CODE, AUG_PROVIDER_TARIFF__SERVICE_TYPE_DESCRIPTION) is not null then 'HUB_PARTY|' || PARTY_BK end"
  SERVICE_CODE_CK: 'AUG_PROVIDER_TARIFF__SERVICE_CODE_CK'
  I3_TARIFF_PRICE: 'AUG_PROVIDER_TARIFF__I3_TARIFF_PRICE'
  I3_TARIFF_REMARKS: 'AUG_PROVIDER_TARIFF__I3_TARIFF_REMARKS'
  SERVICE_TYPE_CODE: 'AUG_PROVIDER_TARIFF__SERVICE_TYPE_CODE'
  SERVICE_TYPE_DESCRIPTION: 'AUG_PROVIDER_TARIFF__SERVICE_TYPE_DESCRIPTION'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
