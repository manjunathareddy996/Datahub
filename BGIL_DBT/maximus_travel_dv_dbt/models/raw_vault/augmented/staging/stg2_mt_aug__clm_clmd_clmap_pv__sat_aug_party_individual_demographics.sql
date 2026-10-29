{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 18 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mt__clm_clmd_clmap_pv'
hashed_columns:
  PARTY_HKEY__CLAIMANT_CUSTOMER: 'PARTY_NK__CLAIMANT_CUSTOMER'
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
  PARTY_BK__CLAIMANT_CUSTOMER: "nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),'')"
  PARTY_NK__CLAIMANT_CUSTOMER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),''))"
  AGE_BAND: 'customer_age_slab'
  BASIC_QUALIFICATION_BOARD_NAME: 'cast(null as varchar)'
  BASIC_QUALIFICATION_DETAILS: 'cast(null as varchar)'
  BASIC_QUALIFICATION_ROLL_NUMBER: 'cast(null as varchar)'
  DATE_OF_MARRIAGE: 'cast(null as varchar)'
  EDUCATIONAL_INSTITUTE_NAME: 'cast(null as varchar)'
  MOTHER_MAIDEN_NAME: 'cast(null as varchar)'
  NOMINEE_DETAILS_DESCRIPTION: 'cast(null as varchar)'
  NUMBER_OF_DAUGHTERS: 'cast(null as varchar)'
  NUMBER_OF_SONS: 'cast(null as varchar)'
  OTHER_QUALIFICATION_DESCRIPTION: 'cast(null as varchar)'
  OTHER_RELATIONSHIP_DESCRIPTION: 'cast(null as varchar)'
  PERSONAL_DETAILS_DESCRIPTION: 'cast(null as varchar)'
  PROFESSIONAL_QUALIFICATION: 'cast(null as varchar)'
  QUALIFICATION_DETAILS: 'cast(null as varchar)'
  QUALIFICATION_MONTH_OF_PASSING: 'cast(null as varchar)'
  RELATIONSHIP_TO_PRIMARY_INSURED: 'cast(null as varchar)'
  YEAR_OF_PASSING_QUALIFICATION: 'cast(null as varchar)'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
