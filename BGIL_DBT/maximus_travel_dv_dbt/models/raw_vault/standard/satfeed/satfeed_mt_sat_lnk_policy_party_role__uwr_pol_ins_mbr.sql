{{ config(materialized='view') }}

-- FEED for SAT_LNK_POLICY_PARTY_ROLE from stg2_mt__uwr_pol_ins_mbr.
-- One satfeed per stage (no UNION) so the sat's per-source watermark and change detection stay intact.
-- Columns are unchanged from the former unioned satfeed_mt_sat_lnk_policy_party_role; only the
-- wide stage's HASHDIFF_LNK_POLICY_PARTY_ROLE is renamed to the bare HASHDIFF.

select
    POLICY_PARTY_HKEY__INSURED_MEMBER as POLICY_PARTY_HKEY,
    PARTY_ROLE_TYPE,
    ROLE_SEQUENCE,
    ATTRIBUTION_PERCENTAGE,
    ROLE_EFFECTIVE_DATE,
    ROLE_END_DATE,
    HASHDIFF_LNK_POLICY_PARTY_ROLE as HASHDIFF,
    LOAD_DATETIME,
    RECORD_SOURCE
from {{ ref('stg2_mt__uwr_pol_ins_mbr') }}
where POLICY_PARTY_HKEY__INSURED_MEMBER is not null
