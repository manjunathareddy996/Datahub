{{ config(materialized='incremental') }}

-- PARTNER AUGMENTED (unconfirmed) sat() for SAT_AUG_LNK_ROLE_SURVEYOR
-- (HUB_PARTY grain, role-special: 'surveyor'). NOT part of the canonical data_5a.js
-- model as such -- SAT_LNK_ROLE_SURVEYOR itself IS canonical (parent LNK_PARTY_ROLE),
-- but these are extra attributes the mapper's Augmentation sheet flagged, built here
-- using the same role-special HUB_PARTY pattern as the standard-model satellite.
-- LICENSE_NO and SURVEYOR_LICENSE_NO NOT included: both look like duplicates of the
-- IRDAI Surveyor Licence Number already carried on the standard-model satellite
-- (same 'IRDA/IND/SLA-nnnnn' format; SURVEYOR_LICENSE_NO has far higher population
-- and is the one now used there). Flagged for the mapper rather than double-counted.
-- HAS_IRDA_LICENCE_INDICATOR added per docs/PARTNER_BUILD_STATE.md section 3.

{%- set yaml_metadata -%}
source_model: 'stg2_aug_rolesat_bjaz_clm_supp_extn__lnk_role_surveyor'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'HAS_IRDA_LICENCE_INDICATOR'
  - 'IIISLA_MEM_NO'
  - 'IIISLA_MEM_STATUS'
  - 'SUR_LICENSE_EXP_DATE'
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
