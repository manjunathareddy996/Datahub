-- automate_dv.stage() for SAT_MOTOR_AUG_LNK_PARTY_ROLE_CORE, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'OTHER_RELATIONSHIP_DESCRIPTION'
      - 'RELATIONSHIP_TO_HIGH_NET_WORTH_CUSTOMER'
      - 'RELATIONSHIP_TO_INSURED'
      - 'RELATIONSHIP_TO_INSURER_EMPLOYEE'
      - 'RELATIONSHIP_TO_PRIVE_CUSTOMER'
      - 'ROLE_CODE_CK'
      - 'ROLE_SEQUENCE_CK'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_LNK_PARTY_ROLE_CORE__OTHER_RELATIONSHIP_DESCRIPTION, AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_HIGH_NET_WORTH_CUSTOMER, AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_INSURED, AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_INSURER_EMPLOYEE, AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_PRIVE_CUSTOMER) is not null then 'HUB_PARTY|' || PARTY_BK end"
  ROLE_CODE_CK: 'AUG_LNK_PARTY_ROLE_CORE__ROLE_CODE_CK'
  ROLE_SEQUENCE_CK: 'AUG_LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK'
  OTHER_RELATIONSHIP_DESCRIPTION: 'AUG_LNK_PARTY_ROLE_CORE__OTHER_RELATIONSHIP_DESCRIPTION'
  RELATIONSHIP_TO_HIGH_NET_WORTH_CUSTOMER: 'AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_HIGH_NET_WORTH_CUSTOMER'
  RELATIONSHIP_TO_INSURED: 'AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_INSURED'
  RELATIONSHIP_TO_INSURER_EMPLOYEE: 'AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_INSURER_EMPLOYEE'
  RELATIONSHIP_TO_PRIVE_CUSTOMER: 'AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_PRIVE_CUSTOMER'
  LOAD_DATETIME: 'PARTY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_mxm__v09_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
