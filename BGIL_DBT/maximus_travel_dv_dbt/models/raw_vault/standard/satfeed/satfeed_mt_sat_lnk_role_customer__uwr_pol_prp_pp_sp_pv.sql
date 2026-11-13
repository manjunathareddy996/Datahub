{{ config(materialized='view') }}

-- FEED for SAT_LNK_ROLE_CUSTOMER from stg2_mt__uwr_pol_prp_pp_sp_pv: one satfeed per stage (no UNION) so the
-- sat's per-source watermark and change detection stay intact.
-- Keyed on PARTY_HKEY (same as the partner projects). Hashdiff renamed from the wide stage's
-- HASHDIFF_LNK_ROLE_CUSTOMER to the bare HASHDIFF.

select
    PARTY_HKEY__PROPOSER as PARTY_HKEY,
    CONSENT_FOR_DATA_SHARING_INDICATOR,
    PREFERRED_CUSTOMER_INDICATOR,
    VIP_INDICATOR,
    HASHDIFF_LNK_ROLE_CUSTOMER as HASHDIFF,
    LOAD_DATETIME,
    RECORD_SOURCE
from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
where PARTY_HKEY__PROPOSER is not null
