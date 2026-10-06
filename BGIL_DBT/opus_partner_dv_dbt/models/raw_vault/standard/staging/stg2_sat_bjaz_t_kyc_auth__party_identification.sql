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
--   BJAZ_T_KYC_AUTH|SAT_PARTY_IDENTIFICATION
--       anchor HUB_PARTY; hist Multi-Active SCD2; childkey 'Identification Type Code'
--       waiting to carry 3 mapped attribute(s) over 2 distinct model attribute
--       name(s): Identification Number, Identification Type Code
--       TWO WRITERS FOR ONE ATTRIBUTE ON THIS UNIT:
--         SAT_PARTY_IDENTIFICATION . 'Identification Number' written by AUTH_NUMBER and INPUT, discriminator(s) ['Identification Type Code = <CATEGORY>', 'Identification Type Code = <CATEGORY>_AUTHENTICATED'], grain Multi-Active SCD2
--
-- ======================================================================================
-- REASON: CHILD_KEY_VALUE_VARIES_PER_ATTRIBUTE   (family: child key)
-- ======================================================================================
-- the child-key leg carries a DIFFERENT value per mapped attribute on this unit: a
-- column-as-instance family, not a child key with one value.
--
-- THE PARTY KEY RESOLVES ON THIS TABLE. This unit is refused because the declared
-- CHILD-KEY LEG CARRIES A DIFFERENT VALUE FOR EACH MAPPED ATTRIBUTE.
--
-- That is a COLUMN-AS-INSTANCE family: several identification types living in
-- several columns of ONE source row, which belong in SEVERAL satellite rows
-- discriminated by the child key. The per-attribute values are listed in the unit
-- block above and in blocked/BLOCKED_UNITS.json.
--
-- WHY IT IS NOT BUILT: emitting one row would carry ONE of those values and silently
-- drop the rest -- the satellite would look populated and be missing most of its
-- content. Emitting one row per column needs an UNPIVOT, and this build has an
-- unpivot layer for HUB_LOCATION's column-as-instance family and NONE for
-- satellites. Inventing one here would be building a grain nobody declared.
--
-- WHAT WOULD UNBLOCK IT: one child-key value per unit, or a DECLARED
-- column-as-instance family for this satellite -- the same declaration the
-- HUB_LOCATION family already has, which is what lets that one be built.

{%- set PKYC_UNFILLED_PARTY_KEY = 'PKYC_UNFILLED_PARTY_KEY_SENTINEL' -%}
{%- set party_business_key = PKYC_UNFILLED_PARTY_KEY -%}
{%- set PKYC_REFUSED_SUBJECT_TOKENS = ['PARTNER_ID'] -%}

{%- if execute and party_business_key == PKYC_UNFILLED_PARTY_KEY -%}
{{ exceptions.raise_compiler_error("PARTNER+KYC PLACEHOLDER stg2_sat_bjaz_t_kyc_auth__party_identification IS ENABLED BUT UNFILLED. Its party business key slot still holds the sentinel PKYC_UNFILLED_PARTY_KEY_SENTINEL, so it would load no key at all. Populate Key Derivations . Resolved Key Expression for the KYC subject on BJAZ_T_KYC_AUTH, set party_business_key to that expression, and re-run generators/run_pkyc_all.py. Reason token: CHILD_KEY_VALUE_VARIES_PER_ATTRIBUTE. See PLACEHOLDERS_AND_REWORK.md and blocked/BLOCKED_UNITS.json.") }}
{%- endif -%}
{%- for pkyc_token in PKYC_REFUSED_SUBJECT_TOKENS -%}
{%- if execute and pkyc_token in (party_business_key | upper) -%}
{{ exceptions.raise_compiler_error("PARTNER+KYC PLACEHOLDER stg2_sat_bjaz_t_kyc_auth__party_identification HAS BEEN FILLED WITH AN EXPRESSION THAT REFERENCES A COLUMN THE PACK ITSELF RULES OUT AS THE KYC SUBJECT KEY. The pack declares that expression as the distribution partner, a different party instance on the same view, so using it here would collapse the distributor and the KYC subject onto one hub row. If the SOURCE OWNER has ruled otherwise, remove this guard: it is PDEC-03 in generators/pkyc_placeholders.py and one line to overrule.") }}
{%- endif -%}
{%- endfor -%}

with pkyc_placeholder as (

    select cast(null as varchar) as pkyc_party_key_not_declared_in_the_bundle

)

select * from pkyc_placeholder where 1 = 0
