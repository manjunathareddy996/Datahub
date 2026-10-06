{{ config(materialized='view') }}

-- PARTNER+KYC per-table stage() for HUB_PARTY, branch 'BJAZ_M_KYC_PAN'.
-- Identifiers localised to the staging aliases.
--
-- KYC-SUBJECT PARTY KEY: BUILDER ASSUMPTION A2 (KEY_FORM_BUILDER_ASSUMED).
-- NOT RATIFIED BY ANYONE. This is the caller's decision to complete the build on a
-- documented assumption, and it is a DIFFERENT STANDING from the ten tables whose
-- form the mapping counterparty ratified (KEY_FORM_RATIFIED_SEMANTICS_UNVERIFIED).
--
-- WHAT: key HUB_PARTY on the CREDENTIAL HOLDER, dropping the AUTH_ID requester walk
-- EXPRESSION: nullif('PAN:' || upper(trim(coalesce(pan_number,''))), 'PAN:')
--
-- WHY: The facts these satellites carry -- Verified Trade Name, Verified Legal Name,
-- verification status -- describe the HOLDER of the credential, not whoever submitted
-- the request; keying them to the requester would attribute a third party's verified
-- identity to the requester, which is the worse of the two errors.
--
-- RISK 1: ON BJAZ_M_KYC_GSTN A GSTIN BELONGS TO AN ORGANISATION, so those rows key an
-- ORGANISATION into HUB_PARTY alongside individuals. That is correct under this
-- assumption and it WIDENS the existing registry-mixing risk on this hub. Said out loud
-- rather than left to pass silently.
--
-- RISK 2: THE TYPE LITERAL IS DERIVED FROM THE COLUMN PREFIX ('LICENCE', not
-- 'DRIVING_LICENCE'). If the enterprise document-type vocabulary spells it differently,
-- these keys live in a DIFFERENT KEY SPACE from any other producer of the same
-- credential and the two never join -- an orphan that compiles.
--
-- RISK 3: The AUTH_ID walk the map declares is DROPPED, so any fact that genuinely
-- belongs to the requester is now attributed to the holder. The conflation is not
-- removed, it is RESOLVED IN ONE DIRECTION.
--
-- CONFIRM WITH: the modeller, on which party the master's key identifies; and the source owner on the document-type vocabulary.
-- ONE LINE TO OVERRULE: pkyc_party_key.ASSUMPTIONS_ENABLED['A2'] = False
--
-- ONE HUB, THREE KEY-SPACE PRODUCERS. HUB_PARTY is now keyed by the ratified
-- CATEGORY:INPUT form on 10 tables, by 'CKYC:<number>' under A1 on 2, and by
-- '<TYPE>:<number>' under A2 on 5. Whether a person reached through two of those routes
-- lands on ONE hub row depends entirely on whether CATEGORY's value vocabulary spells
-- the document type the same way A1 and A2 do -- which is the undetermined
-- identifier-versus-search-term question. If it does, the spaces coincide by design. If
-- it does not, the same person is two parties and nothing in this build can see it.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_m_kyc_pan'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: "nullif('PAN:' || upper(trim(coalesce(pan_number,''))), 'PAN:')"
  PARENT_NK: "'HUB_PARTY|' || (nullif('PAN:' || upper(trim(coalesce(pan_number,''))), 'PAN:'))"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BJAZ_M_KYC_PAN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
