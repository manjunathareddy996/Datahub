{{ config(materialized='view') }}

-- stage() over the SAT_AUG_PARTY_LEGAL_PANEL_ROLE_LINE augmented unpivot for 'pd_prop_sp_pv'.

{%- set yaml_metadata -%}
source_model: 'unpivot_aug_mp__pd_prop_sp_pv__party_legal_panel_role_line'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF_AUG_PARTY_LEGAL_PANEL_ROLE_LINE:
    is_hashdiff: true
    columns:
      - 'ACADEMICQUALIFICATION'
      - 'BARASSOCIATIONNAME'
      - 'BARENROLMENTNUMBER'
      - 'COVEREDCOURTLOC'
      - 'LAWYERTYPE'
      - 'MARRIAGEANNIVERSARYDATE'
      - 'MOUSTATUS'
      - 'NOOFBRIEFS'
      - 'NOOFCOMPANIES'
      - 'NOOFCONSUMER'
      - 'NOOFJUNIOR'
      - 'NOOFMACT'
      - 'NOOFWC'
      - 'SERVICINGINSUREROFFICEADDRESS'
      - 'YEARSOFPRACTICE'
derived_columns:
  PARTY_BK: "parent_bk"
  PARTY_NK: "'HUB_PARTY|' || (parent_bk)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
