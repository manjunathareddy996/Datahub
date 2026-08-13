{{ config(materialized='incremental') }}

-- PARTNER AUGMENTED (unconfirmed) sat() for SAT_AUG_PARTY (HUB_PARTY grain).
-- 13 contributing table(s), union. NOT part of the canonical
-- data_5a.js model -- needs mapper review before being treated as equivalent to a
-- standard-model satellite.

{%- set yaml_metadata -%}
source_model: 'stg2_aug_union__party'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'ADHAAR_PAN_LINK_FLAG'
  - 'BMI'
  - 'BMI_FLAG'
  - 'CAUSE_OF_DEATH'
  - 'DATE_OF_BIRTH_M'
  - 'ECS_MANDATE_STATUS'
  - 'EXISTING_CUSTOMER_INDICATOR'
  - 'HEIGHT_FEET'
  - 'HEIGHT_INCHES'
  - 'HNI_FLAG'
  - 'IMPS_ACTIVE_DATE'
  - 'IMPS_END_DATE'
  - 'IT_RETURN_2YR'
  - 'IT_STATUS'
  - 'MARRIAGE_ANNIVERSARY_DATE'
  - 'MONTHLY_SALARY'
  - 'NUMBER_OF_DAUGHTERS'
  - 'NUMBER_OF_SONS'
  - 'OTHER_OCC'
  - 'PAN_AADHAR_LINKED'
  - 'PAN_ACK_DT'
  - 'PAN_APP_NO'
  - 'PAN_STATUS'
  - 'PARENT_ENTITY_REFERENCE'
  - 'PAYMENT_MODE'
  - 'PREGNANT_MONTHS'
  - 'PRIOR_CLAIM_REASON'
  - 'PROOF_OF_DEATH_TYPE'
  - 'SMOKE_CONSUMP'
  - 'TWO_YR_ITR_FLAG'
  - 'WEBSITE_URL'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
