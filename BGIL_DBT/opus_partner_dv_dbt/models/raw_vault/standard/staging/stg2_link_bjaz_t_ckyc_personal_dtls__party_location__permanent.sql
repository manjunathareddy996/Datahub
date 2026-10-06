{{ config(materialized='view') }}

-- PARTNER+KYC per-table stage() for LNK_PARTY_LOCATION, table 'BJAZ_T_CKYC_PERSONAL_DTLS', instance 'permanent'.
-- Three hash keys, in the baseline's own shape: one per leg plus the link itself.
--
-- KYC-SUBJECT PARTY KEY: BUILDER ASSUMPTION A1 (KEY_FORM_BUILDER_ASSUMED).
-- NOT RATIFIED BY ANYONE. This is the caller's decision to complete the build on a
-- documented assumption, and it is a DIFFERENT STANDING from the ten tables whose
-- form the mapping counterparty ratified (KEY_FORM_RATIFIED_SEMANTICS_UNVERIFIED).
--
-- WHAT: key HUB_PARTY on the centrally-issued CKYC number
-- EXPRESSION: nullif('CKYC:' || upper(trim(coalesce(ckyc_no,''))), 'CKYC:')
--
-- WHY: The CKYC number is a centrally-issued canonical KYC identifier and is the ONLY
-- party identifier either of these two tables declares; they carry no CATEGORY/INPUT, no
-- SEARCH_* and no FIELD_* pair.
--
-- RISK 1: A BLANK CKYC_NO is REJECTED by the nullif guard rather than keyed, so those
-- rows produce a NULL business key and AutomateDV will hash one bogus hub row per source
-- rather than silently merging them. Visible, not silent.
--
-- RISK 2: IF CKYC_NO IS NOT UNIQUE PER PARTY the hub OVER-MERGES: two different people
-- sharing a CKYC number become one party, and no check in this build can see it because
-- uniqueness is a property of the data, not of the schema.
--
-- RISK 3: These are the ONLY TWO TABLES IN THE PACK DECLARING NO PRIMARY KEY AT ALL
-- (build_profile.json ddl_profile.tables_with_no_resolvable_pk), so there is no row key
-- either: the satellite grain rests on the child key alone, and where no child key
-- resolves the unit stays refused rather than collapsing onto one row.
--
-- CONFIRM WITH: the source owner, on CKYC_NO's uniqueness per party.
-- ONE LINE TO OVERRULE: pkyc_party_key.ASSUMPTIONS_ENABLED['A1'] = False
--
-- ONE HUB, THREE KEY-SPACE PRODUCERS. HUB_PARTY is now keyed by the ratified
-- CATEGORY:INPUT form on 10 tables, by 'CKYC:<number>' under A1 on 2, and by
-- '<TYPE>:<number>' under A2 on 5. Whether a person reached through two of those routes
-- lands on ONE hub row depends entirely on whether CATEGORY's value vocabulary spells
-- the document type the same way A1 and A2 do -- which is the undetermined
-- identifier-versus-search-term question. If it does, the spaces coincide by design. If
-- it does not, the same person is two parties and nothing in this build can see it.
--
-- A3: THE PARTY LEG IS BYTE-IDENTICAL TO THE HUB_PARTY KEY ON THIS VIEW.
-- The map declared this leg as a PAN-first coalesce resolving into a 'PAN:'/'CKYC:'
-- key space that NO HUB DECLARES. A leg in a key space its hub does not produce is
-- an orphan foreign key that COMPILES: dbt does not fail, AutomateDV does not fail,
-- no gate fails, and the join returns nothing for ever. The leg is therefore taken
-- FROM the hub's expression on this same view and asserted equal to it at build time.
-- The mapped leg form is recorded in blocked/BLOCKED_UNITS.json and is NOT used.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_t_ckyc_personal_dtls'
hashed_columns:
  PARTY_HKEY: 'PARTY_HKEY_NK'
  LOCATION_HKEY: 'LOCATION_HKEY_NK'
  PARTY_LOCATION_HKEY: 'PARTY_LOCATION_HKEY_NK'
derived_columns:
  PARTY_HKEY_NK: "'HUB_PARTY|' || (nullif('CKYC:' || upper(trim(coalesce(ckyc_no,''))), 'CKYC:'))"
  LOCATION_HKEY_NK: "'HUB_LOCATION|' || (coalesce(nullif(upper(trim(to_varchar(perm_line1))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(perm_line2))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(perm_line3))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(perm_city))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(perm_dist))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(perm_state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(perm_pin))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(perm_country))), ''), ''))"
  PARTY_LOCATION_HKEY_NK: "'LNK_PARTY_LOCATION|' || (nullif('CKYC:' || upper(trim(coalesce(ckyc_no,''))), 'CKYC:') || '|' || coalesce(nullif(upper(trim(to_varchar(perm_line1))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(perm_line2))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(perm_line3))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(perm_city))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(perm_dist))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(perm_state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(perm_pin))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(perm_country))), ''), ''))"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BJAZ_T_CKYC_PERSONAL_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
