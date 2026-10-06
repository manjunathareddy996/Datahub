{{ config(enabled=false, materialized='view') }}

-- PARTNER + KYC PLACEHOLDER -- SHIPPED DISABLED, AND IT IS NOT A LOADER.
--
-- This file exists so that a refusal is VISIBLE AND IN VERSION CONTROL rather than being
-- an absence in a directory listing. It is written by
-- generators/gen_pkyc_placeholders.py and regenerated from empty on every run. Edit the
-- generator, never this file: models are generated, never hand-edited.
--
-- THREE STATES, every one of them asserted mechanically over every placeholder by
-- generators/check_pkyc_placeholders.py:
--     config(enabled=false)             dbt excludes it. It cannot run and cannot load.
--     enabled, slot still the sentinel  a dbt COMPILER ERROR naming the field to fill.
--     enabled, slot filled              compiles.
-- The guard is gated on `execute` deliberately. dbt renders a model body while PARSING,
-- before enabled=false has been honoured, so an ungated raise would break the whole
-- project instead of sitting inert.
--
-- NO KEY EXPRESSION IS INVENTED, DEFAULTED OR HARVESTED HERE. The business-key slot
-- below holds the sentinel PKYC_UNFILLED_PARTY_KEY_SENTINEL and nothing else.
-- PARTNER_ID is NOT used as a stand-in for the KYC subject: a second guard refuses a
-- fill that reaches for it, because the pack's own rationale calls PARTNER_ID the
-- distribution partner and a DIFFERENT party instance from the KYC subject (PDEC-03).
--
-- WHAT UNBLOCKS IT -- ONE FIELD:  Key Derivations . Resolved Key Expression
-- on the HUB_PARTY-anchored Key-Derivation rows that carry none. The counts are in
-- build_artifacts/BUILD_STATUS.json and blocked/BLOCKED_UNITS.json; none is typed here.
--
-- HOW TO REWORK IT (full procedure: PLACEHOLDERS_AND_REWORK.md):
--   1  put the per-table Resolved Key Expression for the KYC SUBJECT in the bundle;
--   2  re-run  python3 generators/run_pkyc_all.py  ;
--   3  the chain writes the REAL model over this file, at this same path, with no
--      sentinel and no enabled=false, and reprints the refusals that remain.
-- A hand-fill of the slot compiles and does NOT load. That is PDEC-02, stated with its
-- cost: a satellite feed needs the payload union, the null-padding to the satellite and
-- the child-key legs as well as the key, and a builder assembling those for a refused
-- unit is building the refused unit.
--
-- REFUSED UNIT(S) PARKED AT THIS PATH: 1  (grouping key: the model path)
--   BJAZ_T_KYC_DETAILS|SAT_PARTY_IDENTIFICATION
--       anchor HUB_PARTY; hist Multi-Active SCD2; childkey 'Identification Type Code'
--       waiting to carry 4 mapped attribute(s) over 2 distinct model attribute
--       name(s): Identification Number, Identification Type Code
--       TWO WRITERS FOR ONE ATTRIBUTE ON THIS UNIT:
--         SAT_PARTY_IDENTIFICATION . 'Identification Number' written by INPUT and POI_INPUT, discriminator(s) ['Identification Type Code = <CATEGORY>', 'Identification Type Code = <POI_CATEGORY>'], grain Multi-Active SCD2
--       TWO WRITERS FOR ONE ATTRIBUTE ON THIS UNIT:
--         SAT_PARTY_IDENTIFICATION . 'Identification Type Code' written by CATEGORY and POI_CATEGORY, discriminator(s) ['Identification Type Code = <CATEGORY>', 'Identification Type Code = <POI_CATEGORY>'], grain Multi-Active SCD2
--
-- ======================================================================================
-- REASON: CHILD_KEY_LEG_TWO_SOURCE_COLUMNS   (family: child key)
-- ======================================================================================
-- one child-key leg is mapped from more than one source column on this unit.
--
-- THE PARTY KEY RESOLVES ON THIS TABLE. This unit is refused because ONE CHILD-KEY
-- LEG IS MAPPED FROM MORE THAN ONE SOURCE COLUMN on this one unit.
--
-- The builder does not pick one. A child-key leg is part of the satellite's key, so
-- choosing between two candidate columns changes which rows are the same row -- that
-- IS the mapping decision (BUILD_RULES.md 5.7), and getting it wrong silently merges
-- or silently splits history.
--
-- WHAT WOULD UNBLOCK IT: one source column per child-key leg, or a declared
-- precedence between them.

{%- set PKYC_UNFILLED_PARTY_KEY = 'PKYC_UNFILLED_PARTY_KEY_SENTINEL' -%}
{%- set party_business_key = PKYC_UNFILLED_PARTY_KEY -%}
{%- set PKYC_REFUSED_SUBJECT_TOKENS = ['PARTNER_ID'] -%}

{%- if execute and party_business_key == PKYC_UNFILLED_PARTY_KEY -%}
{{ exceptions.raise_compiler_error("PARTNER+KYC PLACEHOLDER stg2_sat_bjaz_t_kyc_details__party_identification IS ENABLED BUT UNFILLED. Its party business key slot still holds the sentinel PKYC_UNFILLED_PARTY_KEY_SENTINEL, so it would load no key at all. Populate Key Derivations . Resolved Key Expression for the KYC subject on BJAZ_T_KYC_DETAILS, set party_business_key to that expression, and re-run generators/run_pkyc_all.py. Reason token: CHILD_KEY_LEG_TWO_SOURCE_COLUMNS. See PLACEHOLDERS_AND_REWORK.md and blocked/BLOCKED_UNITS.json.") }}
{%- endif -%}
{%- for pkyc_token in PKYC_REFUSED_SUBJECT_TOKENS -%}
{%- if execute and pkyc_token in (party_business_key | upper) -%}
{{ exceptions.raise_compiler_error("PARTNER+KYC PLACEHOLDER stg2_sat_bjaz_t_kyc_details__party_identification HAS BEEN FILLED WITH AN EXPRESSION THAT REFERENCES A COLUMN THE PACK ITSELF RULES OUT AS THE KYC SUBJECT KEY. The pack declares that expression as the distribution partner, a different party instance on the same view, so using it here would collapse the distributor and the KYC subject onto one hub row. If the SOURCE OWNER has ruled otherwise, remove this guard: it is PDEC-03 in generators/pkyc_placeholders.py and one line to overrule.") }}
{%- endif -%}
{%- endfor -%}

with pkyc_placeholder as (

    select cast(null as varchar) as pkyc_party_key_not_declared_in_the_bundle

)

select * from pkyc_placeholder where 1 = 0
