{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_CLAIM_PA_DETAIL from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 6 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmap_pv'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF_CLAIM_PA_DETAIL:
    is_hashdiff: true
    columns:
      - 'DATE_OF_DEATH'
      - 'DEATH_INDICATOR'
      - 'DEATH_OR_HOSPITALISATION_INDICATOR'
      - 'DEATH_OR_PERMANENT_TOTAL_DISABLEMENT_INDICATOR'
      - 'DECEASED_INSURED_WITH_INSURER_INDICATOR'
      - 'PERSONAL_ACCIDENT_CLAIMANT_REFERENCE'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  DATE_OF_DEATH: 'date_of_death'
  DEATH_INDICATOR: 'cast(null as varchar)'
  DEATH_OR_HOSPITALISATION_INDICATOR: 'cast(null as varchar)'
  DEATH_OR_PERMANENT_TOTAL_DISABLEMENT_INDICATOR: 'cast(null as varchar)'
  DECEASED_INSURED_WITH_INSURER_INDICATOR: 'cast(null as varchar)'
  PERSONAL_ACCIDENT_CLAIMANT_REFERENCE: 'personal_accident_claim_for'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
