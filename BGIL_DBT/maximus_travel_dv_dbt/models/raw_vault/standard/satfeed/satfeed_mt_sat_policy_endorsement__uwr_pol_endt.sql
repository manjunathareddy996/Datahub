{{ config(materialized='view') }}

-- FEED for SAT_POLICY_ENDORSEMENT from stg2_mt__uwr_pol_endt.
-- One satfeed per stage (no UNION) so the sat's per-source watermark and change detection stay intact.
-- Columns and filter are copied unchanged from the former unioned satfeed_mt_sat_policy_endorsement.

    select
        POLICY_HKEY as POLICY_HKEY,
        ENDORSEMENT_NUMBER as ENDORSEMENT_NUMBER,
        EFFECTIVE_DATE as EFFECTIVE_DATE,
        ENDORSEMENT_REASON as ENDORSEMENT_REASON,
        ENDORSEMENT_TYPE as ENDORSEMENT_TYPE,
        PREMIUM_IMPACT_AMOUNT as PREMIUM_IMPACT_AMOUNT,
        SUM_INSURED_IMPACT_AMOUNT as SUM_INSURED_IMPACT_AMOUNT,
        ENDORSEMENT_APPROVAL_DATE as ENDORSEMENT_APPROVAL_DATE,
        ENDORSEMENT_INVOICE_REFERENCE as ENDORSEMENT_INVOICE_REFERENCE,
        ENDORSEMENT_REMARKS as ENDORSEMENT_REMARKS,
        ENDORSEMENT_UNIQUE_IDENTIFICATION_CODE as ENDORSEMENT_UNIQUE_IDENTIFICATION_CODE,
        REVISED_SUM_INSURED_AMOUNT as REVISED_SUM_INSURED_AMOUNT,
        HASHDIFF_POLICY_ENDORSEMENT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_endt') }}
    where POLICY_HKEY is not null
