{{ config(materialized='view') }}

-- Thin wrapper over stg2_mp__pd_prop_sp_pv: renames this satellite's suffixed hashdiff to the
-- shared HASHDIFF column name so automate_dv.sat writes/reads the same column opus created.

select
    DISTRIBUTION_CHANNEL_HKEY,
    HASHDIFF_CHANNEL_DEFINITION as HASHDIFF,
    SUB_CHANNEL_CODE,
    SUB_CHANNEL_EFFECTIVE_DATE,
    LOAD_DATETIME,
    RECORD_SOURCE
from {{ ref('stg2_mp__pd_prop_sp_pv') }}
