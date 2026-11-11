-- automate_dv.stage() for SAT_PROVIDER_TARIFF, read off central view stitch_v01_agreement.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v01_agreement'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DISCOUNT_PERCENTAGE'
      - 'EFFECTIVE_DATE'
      - 'EXPIRY_DATE'
      - 'PACKAGE_RATE'
      - 'ROOM_RENT_CAP'
      - 'SERVICE_DESCRIPTION'
      - 'SERVICE_CODE_CK'
derived_columns:
  PARTY_NK: "case when coalesce(PROVIDER_TARIFF__DISCOUNT_PERCENTAGE, PROVIDER_TARIFF__EFFECTIVE_DATE, PROVIDER_TARIFF__EXPIRY_DATE, PROVIDER_TARIFF__PACKAGE_RATE, PROVIDER_TARIFF__ROOM_RENT_CAP, PROVIDER_TARIFF__SERVICE_DESCRIPTION) is not null then 'HUB_PARTY|' || PARTY_BK end"
  SERVICE_CODE_CK: 'PROVIDER_TARIFF__SERVICE_CODE_CK'
  DISCOUNT_PERCENTAGE: 'PROVIDER_TARIFF__DISCOUNT_PERCENTAGE'
  EFFECTIVE_DATE: 'PROVIDER_TARIFF__EFFECTIVE_DATE'
  EXPIRY_DATE: 'PROVIDER_TARIFF__EXPIRY_DATE'
  PACKAGE_RATE: 'PROVIDER_TARIFF__PACKAGE_RATE'
  ROOM_RENT_CAP: 'PROVIDER_TARIFF__ROOM_RENT_CAP'
  SERVICE_DESCRIPTION: 'PROVIDER_TARIFF__SERVICE_DESCRIPTION'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v01_agreement'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
