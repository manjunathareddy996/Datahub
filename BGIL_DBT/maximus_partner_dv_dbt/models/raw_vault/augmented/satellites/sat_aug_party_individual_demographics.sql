{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        on_schema_change='append_new_columns',
        unique_key=['PARTY_HKEY', 'HASHDIFF_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS', 'RECORD_SOURCE']
    )
}}

-- MAXIMUS PARTNER AUGMENTED (unconfirmed) sat() for SAT_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS, at HUB_PARTY grain.
-- partner_dv_dbt does not build sat_aug_party_individual_demographics; Maximus-only augmented table.
-- Payload columns are the mapper's PROPOSED ATTRIBUTE names in partner_dv_dbt's own rendering
-- (squashed), not raw Maximus column names -- a shared table must not gain a second column for a
-- fact that already has one. NOT part of the canonical model.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_mp__pd_prop_msdp_pv__party'
  - 'stg2_aug_mp__pd_prop_sp_pv__party'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'BASICQUALIFICATIONDETAILS'
  - 'BASICQUALIFICATIONROLLNUMBER'
  - 'EDUCATIONINSTITUTENAME'
  - 'FATHERORSPOUSENAME'
  - 'INCOMEBANDLOWERBOUND'
  - 'INCOMEBANDUPPERBOUND'
  - 'MARRIAGEANNIVERSARYDATE'
  - 'MATRICULATIONQUALIFICATIONDETAIL'
  - 'MONTHLYGROSSINCOME'
  - 'MOTHERSMAIDENNAME'
  - 'NUMBEROFDAUGHTERS'
  - 'NUMBEROFSONS'
  - 'OCCUPATIONLIST'
  - 'OTHEROCCUPATION'
  - 'OTHERQUALIFICATION'
  - 'PERSONALDETAILSDESCRIPTION'
  - 'POSTGRADUATEQUALIFICATION'
  - 'PROFESSIONALQUALIFICATION'
  - 'QUALIFICATIONBOARDNAME'
  - 'QUALIFICATIONDETAIL'
  - 'QUALIFICATIONPASSINGMONTH'
  - 'UNDERGRADUATEQUALIFICATION'
  - 'YEAROFPASSINGQUALIFICATION'
src_hashdiff: 'HASHDIFF_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_aug_mp__pd_prop_msdp_pv__party: 'MAXIMUS'
  stg2_aug_mp__pd_prop_sp_pv__party: 'MAXIMUS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_column_map={
                        'stg2_aug_mp__pd_prop_msdp_pv__party': ['INCOMEBANDLOWERBOUND', 'INCOMEBANDUPPERBOUND'],
                        'stg2_aug_mp__pd_prop_sp_pv__party': ['BASICQUALIFICATIONDETAILS', 'BASICQUALIFICATIONROLLNUMBER', 'EDUCATIONINSTITUTENAME', 'FATHERORSPOUSENAME', 'MARRIAGEANNIVERSARYDATE', 'MATRICULATIONQUALIFICATIONDETAIL', 'MONTHLYGROSSINCOME', 'MOTHERSMAIDENNAME', 'NUMBEROFDAUGHTERS', 'NUMBEROFSONS', 'OCCUPATIONLIST', 'OTHEROCCUPATION', 'OTHERQUALIFICATION', 'PERSONALDETAILSDESCRIPTION', 'POSTGRADUATEQUALIFICATION', 'PROFESSIONALQUALIFICATION', 'QUALIFICATIONBOARDNAME', 'QUALIFICATIONDETAIL', 'QUALIFICATIONPASSINGMONTH', 'UNDERGRADUATEQUALIFICATION', 'YEAROFPASSINGQUALIFICATION']
                    }) }}
