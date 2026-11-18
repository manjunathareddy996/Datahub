{{ config(materialized='view') }}

-- Thin wrapper over stg2_mp__pd_prop_sp_pv: renames this satellite's suffixed hashdiff to the
-- shared HASHDIFF column name so ma_sat_multi_source writes/reads the same column the other projects use.
-- One satfeed per stage (no UNION) so the sat's per-source watermark and change detection stay intact.

select
    PARTY_HKEY,
    HASHDIFF_PARTY_BANKING as HASHDIFF,
    ACCOUNT_HOLDER_NAME,
    ACCOUNT_NUMBER_MASKED,
    ACCOUNT_TYPE,
    BANK_NAME,
    BRANCH_NAME,
    IFSC_CODE,
    MICR_CODE,
    PENNYDROPVERIFIEDINDICATOR,
    PRIMARYACCOUNTINDICATOR,
    LOAD_DATETIME,
    RECORD_SOURCE
from {{ ref('stg2_mp__pd_prop_sp_pv') }}
