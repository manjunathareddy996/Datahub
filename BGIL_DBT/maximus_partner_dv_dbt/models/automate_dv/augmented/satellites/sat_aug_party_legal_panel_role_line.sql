{{ config(materialized='incremental') }}

-- MAXIMUS PARTNER AUGMENTED (unconfirmed) ma_sat() for SAT_AUG_PARTY_LEGAL_PANEL_ROLE_LINE, at HUB_PARTY grain.
-- partner_dv_dbt does not build sat_aug_party_legal_panel_role_line; Maximus-only augmented table.
-- Payload columns are the mapper's PROPOSED ATTRIBUTE names in partner_dv_dbt's own rendering
-- (squashed), not raw Maximus column names -- a shared table must not gain a second column for a
-- fact that already has one. NOT part of the canonical model.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_mp_up__pd_prop_sp_pv__party_legal_panel_role_line'
src_pk: 'PARTY_HKEY'
src_cdk:
  - 'PANELROLECODE'
src_payload:
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
src_hashdiff: 'HASHDIFF_AUG_PARTY_LEGAL_PANEL_ROLE_LINE'
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
