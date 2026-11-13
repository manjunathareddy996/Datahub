{{ config(materialized='view') }}

-- Thin wrapper over stg2_mp__pd_prop_msdp_pv: renames this satellite's suffixed hashdiff to the
-- shared HASHDIFF column name so ma_sat_multi_source writes/reads the same column the other projects use.
-- One satfeed per stage (no UNION) so the sat's per-source watermark and change detection stay intact.

select
    PARTY_HKEY,
    HASHDIFF_PARTY_BANKING as HASHDIFF,
    ACCOUNTHOLDERNAME,
    ACCOUNTNUMBERMASKED,
    ACCOUNTTYPE,
    BANKNAME,
    BRANCHNAME,
    IFSCCODE,
    MICRCODE,
    PENNYDROPVERIFIEDINDICATOR,
    PRIMARYACCOUNTINDICATOR,
    LOAD_DATETIME,
    RECORD_SOURCE
from {{ ref('stg2_mp__pd_prop_msdp_pv') }}
