{{ config(materialized='view') }}

-- Thin wrapper over stg2_mp__pd_prop_sp_pv: renames this satellite's suffixed hashdiff to the
-- shared HASHDIFF column name so automate_dv.sat writes/reads the same column opus created.

select
    PARTY_HKEY,
    HASHDIFF_COMMON_COMMUNICATION_PREFERENCE as HASHDIFF,
    CORRESPONDENCELANGUAGE,
    GOGREENOPTININDICATOR,
    PREFERREDCHANNELCODE,
    PREFERREDLANGUAGECODE,
    LOAD_DATETIME,
    RECORD_SOURCE
from {{ ref('stg2_mp__pd_prop_sp_pv') }}
