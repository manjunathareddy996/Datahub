{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_PARTY, table 'BJAZ_HM_HOSP_MASTER_EXTN1'.
-- 9 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_HM_HOSP_MASTER_EXTN1 carries a verified HUB_PARTY key
-- (HOSID), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_hosp_master_extn1'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TPANAME'
      - 'HOSSTATUSREMARK'
      - 'REACTIDATE'
      - 'DTOPRATIO'
      - 'MEDICALDIRECT'
      - 'MEDSUPERNAME'
      - 'MKTHEAD'
      - 'CEO'
      - 'BEDOCCUPRATE'
derived_columns:
  PARENT_BK: 'hosid'
  PARENT_NK: "'HUB_PARTY|' || (hosid)"
  TPANAME: 'tpaname'
  HOSSTATUSREMARK: 'hosstatusremark'
  REACTIDATE: 'reactidate'
  DTOPRATIO: 'dtopratio'
  MEDICALDIRECT: 'medicaldirect'
  MEDSUPERNAME: 'medsupername'
  MKTHEAD: 'mkthead'
  CEO: 'ceo'
  BEDOCCUPRATE: 'bedoccuprate'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HOSP_MASTER_EXTN1'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
