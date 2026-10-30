{{ config(materialized='view') }}

-- Thin wrapper over stg2_aug_mp__pd_prop_sp_pv__location: renames the suffixed
-- hashdiff to the shared HASHDIFF column name so this project writes to the same
-- column the sibling writes on the shared physical satellite.

select
    LOCATION_HKEY,
    HASHDIFF_AUG_COMMON_ADDRESS as HASHDIFF,
    FULLADDRESSTEXT,
    LOAD_DATETIME,
    RECORD_SOURCE
from {{ ref('stg2_aug_mp__pd_prop_sp_pv__location') }}
