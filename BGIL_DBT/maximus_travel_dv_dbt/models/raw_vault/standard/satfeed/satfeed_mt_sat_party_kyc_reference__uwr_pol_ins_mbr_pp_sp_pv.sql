{{ config(materialized='view') }}

-- FEED for SAT_PARTY_KYC_REFERENCE from stg2_mt_up__uwr_pol_ins_mbr_pp_sp_pv__sat_party_kyc_reference.
-- One satfeed per stage (no UNION) so the sat's per-source watermark and change detection stay intact.
-- Columns are unchanged from the former unioned satfeed_mt_sat_party_kyc_reference; only the
-- stage's HASHDIFF_PARTY_KYC_REFERENCE is renamed to the bare HASHDIFF.

select
    PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY,
    KYC_REFERENCE_TYPE as KYC_REFERENCE_TYPE,
    VERIFICATION_STATUS,
    HASHDIFF_PARTY_KYC_REFERENCE as HASHDIFF,
    LOAD_DATETIME,
    RECORD_SOURCE
from {{ ref('stg2_mt_up__uwr_pol_ins_mbr_pp_sp_pv__sat_party_kyc_reference') }}
where PARTY_HKEY__INSURED_MEMBER is not null
