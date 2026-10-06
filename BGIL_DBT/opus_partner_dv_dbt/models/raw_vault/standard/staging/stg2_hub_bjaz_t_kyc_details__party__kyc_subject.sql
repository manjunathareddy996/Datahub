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
--   BJAZ_T_KYC_DETAILS|HUB_PARTY
--       anchor HUB_PARTY; instance 'kyc-subject'
--
-- ======================================================================================
-- REASON: PARTY_INSTANCE_IS_NOT_THE_KYC_SUBJECT   (family: party key)
-- ======================================================================================
-- the distribution-partner instance on a view that also carries the KYC subject. Not
-- merged with it.
--
-- BJAZ_T_KYC_DETAILS CARRIES TWO PARTY INSTANCES ON ONE VIEW:
--     distribution-partner   key declared in the pack as upper(trim(PARTNER_ID))
--     KYC subject            key ABSENT  <-- this placeholder, and only this one
--
-- THEY MUST NOT BE MERGED. One key serving both collapses the distributor and the
-- customer onto one hub row. The pack's own rationale for the declared expression says
-- it is 'a DIFFERENT party instance from the KYC subject on the same view', which is why
-- it is not reused here and why the second guard refuses a PARTNER_ID fill.
--
-- THE DISTRIBUTION-PARTNER INSTANCE IS NOT DISTURBED BY THIS FILE. Its state, measured
-- from the build's own artifacts rather than relayed: it is declared and rendered in
-- build_artifacts/pkyc_spec.json, it is counted among the refusals, and NO MODEL FILE
-- IN EITHER SCOPE FEEDS HUB_PARTY FROM A KYC TABLE -- so it is recorded, not emitted.
-- If it is ever emitted it takes its own instance-suffixed name; this path is the
-- un-suffixed KYC-subject feed.

{%- set PKYC_UNFILLED_PARTY_KEY = 'PKYC_UNFILLED_PARTY_KEY_SENTINEL' -%}
{%- set party_business_key = PKYC_UNFILLED_PARTY_KEY -%}
{%- set PKYC_REFUSED_SUBJECT_TOKENS = ['PARTNER_ID'] -%}

{%- if execute and party_business_key == PKYC_UNFILLED_PARTY_KEY -%}
{{ exceptions.raise_compiler_error("PARTNER+KYC PLACEHOLDER stg2_hub_bjaz_t_kyc_details__party__kyc_subject IS ENABLED BUT UNFILLED. Its party business key slot still holds the sentinel PKYC_UNFILLED_PARTY_KEY_SENTINEL, so it would load no key at all. Populate Key Derivations . Resolved Key Expression for the KYC subject on BJAZ_T_KYC_DETAILS, set party_business_key to that expression, and re-run generators/run_pkyc_all.py. Reason token: PARTY_INSTANCE_IS_NOT_THE_KYC_SUBJECT. See PLACEHOLDERS_AND_REWORK.md and blocked/BLOCKED_UNITS.json.") }}
{%- endif -%}
{%- for pkyc_token in PKYC_REFUSED_SUBJECT_TOKENS -%}
{%- if execute and pkyc_token in (party_business_key | upper) -%}
{{ exceptions.raise_compiler_error("PARTNER+KYC PLACEHOLDER stg2_hub_bjaz_t_kyc_details__party__kyc_subject HAS BEEN FILLED WITH AN EXPRESSION THAT REFERENCES A COLUMN THE PACK ITSELF RULES OUT AS THE KYC SUBJECT KEY. The pack declares that expression as the distribution partner, a different party instance on the same view, so using it here would collapse the distributor and the KYC subject onto one hub row. If the SOURCE OWNER has ruled otherwise, remove this guard: it is PDEC-03 in generators/pkyc_placeholders.py and one line to overrule.") }}
{%- endif -%}
{%- endfor -%}

with pkyc_placeholder as (

    select cast(null as varchar) as pkyc_party_key_not_declared_in_the_bundle

)

select * from pkyc_placeholder where 1 = 0
