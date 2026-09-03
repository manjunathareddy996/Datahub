{{ config(materialized='view') }}

-- MAXIMUS PARTNER AUGMENTED (unconfirmed) WIDE stage() for HUB_PARTY, view 'pd'.
-- Serves 1 augmented satellite(s), one HASHDIFF each, from 2
-- column(s) with no faithful home in data_7. The KEY is the standard track's own
-- expression for HUB_PARTY on this view; the ATTRIBUTE GROUPING is the mapper's
-- proposal and is NOT canonical.

{%- set yaml_metadata -%}
source_model: 'stg_maximus__pd'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF_AUG_PARTY_IDENTITY:
    is_hashdiff: true
    columns:
      - 'BENEFICIARYNAMELIST'
      - 'BLOCKUNBLOCKSTATUS'
      - 'CLAIMAPPLICANTDATEOFBIRTH'
      - 'CLAIMAPPLICANTNAME'
      - 'CLAIMAPPLICANTSALUTATION'
      - 'COUNTRYOFCITIZENSHIP'
      - 'PARTYENDDATE'
      - 'PARTYREMARKS'
      - 'RECORDEFFECTIVEDATE'
      - 'RECORDENDDATE'
      - 'SOURCELASTMODIFIEDDATE'
      - 'STATUSREASONOTHERDETAIL'
derived_columns:
  PARTY_BK: "party_code"
  PARTY_NK: "'HUB_PARTY|' || (party_code)"
  BENEFICIARYNAMELIST: "cast(null as varchar)"
  BLOCKUNBLOCKSTATUS: "cast(null as varchar)"
  CLAIMAPPLICANTDATEOFBIRTH: "cast(null as varchar)"
  CLAIMAPPLICANTNAME: "cast(null as varchar)"
  CLAIMAPPLICANTSALUTATION: "cast(null as varchar)"
  COUNTRYOFCITIZENSHIP: "cast(null as varchar)"
  PARTYENDDATE: "party_end_date"
  PARTYREMARKS: "cast(null as varchar)"
  RECORDEFFECTIVEDATE: "cast(null as varchar)"
  RECORDENDDATE: "cast(null as varchar)"
  SOURCELASTMODIFIEDDATE: "party_last_modification_date"
  STATUSREASONOTHERDETAIL: "cast(null as varchar)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!pd'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
