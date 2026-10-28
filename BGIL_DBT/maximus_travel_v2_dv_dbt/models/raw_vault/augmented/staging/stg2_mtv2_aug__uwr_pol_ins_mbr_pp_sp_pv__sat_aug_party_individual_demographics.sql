{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 18 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_ins_mbr_pp_sp_pv'
hashed_columns:
  PARTY_HKEY__INSURED_MEMBER: 'PARTY_NK__INSURED_MEMBER'
  HASHDIFF_PARTY_INDIVIDUAL_DEMOGRAPHICS:
    is_hashdiff: true
    columns:
      - 'AGE_BAND'
      - 'BASIC_QUALIFICATION_BOARD_NAME'
      - 'BASIC_QUALIFICATION_DETAILS'
      - 'BASIC_QUALIFICATION_ROLL_NUMBER'
      - 'DATE_OF_MARRIAGE'
      - 'EDUCATIONAL_INSTITUTE_NAME'
      - 'MOTHER_MAIDEN_NAME'
      - 'NOMINEE_DETAILS_DESCRIPTION'
      - 'NUMBER_OF_DAUGHTERS'
      - 'NUMBER_OF_SONS'
      - 'OTHER_QUALIFICATION_DESCRIPTION'
      - 'OTHER_RELATIONSHIP_DESCRIPTION'
      - 'PERSONAL_DETAILS_DESCRIPTION'
      - 'PROFESSIONAL_QUALIFICATION'
      - 'QUALIFICATION_DETAILS'
      - 'QUALIFICATION_MONTH_OF_PASSING'
      - 'RELATIONSHIP_TO_PRIMARY_INSURED'
      - 'YEAR_OF_PASSING_QUALIFICATION'
derived_columns:
  PARTY_BK__INSURED_MEMBER: "nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'')"
  PARTY_NK__INSURED_MEMBER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),''))"
  AGE_BAND: 'cast(null as varchar)'
  BASIC_QUALIFICATION_BOARD_NAME: 'cast(null as varchar)'
  BASIC_QUALIFICATION_DETAILS: 'cast(null as varchar)'
  BASIC_QUALIFICATION_ROLL_NUMBER: 'cast(null as varchar)'
  DATE_OF_MARRIAGE: 'date_of_marriage'
  EDUCATIONAL_INSTITUTE_NAME: 'cast(null as varchar)'
  MOTHER_MAIDEN_NAME: 'coalesce(mothers_maiden_name, mother_maiden_name)'
  NOMINEE_DETAILS_DESCRIPTION: 'cast(null as varchar)'
  NUMBER_OF_DAUGHTERS: 'number_of_daughters'
  NUMBER_OF_SONS: 'number_of_son'
  OTHER_QUALIFICATION_DESCRIPTION: 'cast(null as varchar)'
  OTHER_RELATIONSHIP_DESCRIPTION: 'other_relationship'
  PERSONAL_DETAILS_DESCRIPTION: 'personal_details'
  PROFESSIONAL_QUALIFICATION: 'cast(null as varchar)'
  QUALIFICATION_DETAILS: 'cast(null as varchar)'
  QUALIFICATION_MONTH_OF_PASSING: 'cast(null as varchar)'
  RELATIONSHIP_TO_PRIMARY_INSURED: 'relationship'
  YEAR_OF_PASSING_QUALIFICATION: 'cast(null as varchar)'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
