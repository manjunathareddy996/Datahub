-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_PRODUCT_RIDER_CATALOGUE (parent HUB_PRODUCT, history SCD2), fed whole from central view stitch_motor__v20_product.
-- GRAIN_UNRATIFIED (P-2): emitted as the map states. Self-named child-key blocks here write several
-- attributes of ONE entity, shredding it into child rows. Not ratified as a grain change; routed to the modeller.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__product_rider_catalogue'
src_pk: 'PRODUCT_HKEY'
src_cdk:
  - 'ACTIVE_SEQUENCE_NUMBER_CK'
  - 'RIDER_CODE_CK'
src_payload:
  - 'EXPIRY_DATE'
  - 'MAXIMUM_VEHICLE_AGE'
  - 'MULTI_YEAR_ELIGIBLE_INDICATOR'
  - 'NEW_BUSINESS_ELIGIBLE_INDICATOR'
  - 'NO_CLAIM_BONUS_DISCOUNT_APPLICABLE_INDICATOR'
  - 'OWN_RENEWAL_ELIGIBLE_INDICATOR'
  - 'RIDER_STATUS'
  - 'ROLLOVER_RENEWAL_ELIGIBLE_INDICATOR'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                      src_cdk=metadata_dict['src_cdk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
