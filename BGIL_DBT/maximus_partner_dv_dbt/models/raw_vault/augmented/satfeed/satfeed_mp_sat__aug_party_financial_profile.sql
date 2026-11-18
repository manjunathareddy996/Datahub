{{ config(materialized='view') }}

-- Thin wrapper over stg2_aug_mp__pd_prop_sp_pv__party: renames the suffixed hashdiff
-- to the shared HASHDIFF column.

select
    PARTY_HKEY,
    HASHDIFF_AUG_PARTY_FINANCIAL_PROFILE as HASHDIFF,
    CHEQUE_RECEIPTING_BLOCKED_INDICATOR,
    CHEQUE_RECEIPTING_BLOCK_REASON,
    DECLAREDINCOMEAMOUNT,
    INCOME_TAX_RETURN_FILED_LAST_TWO_YEARS_INDICATOR,
    LOAD_DATETIME,
    RECORD_SOURCE
from {{ ref('stg2_aug_mp__pd_prop_sp_pv__party') }}
