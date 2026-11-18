{{ config(materialized='view') }}

-- Thin wrapper over stg2_mp__pd_prop_sp_pv: renames this satellite's suffixed hashdiff to the
-- shared HASHDIFF column name so automate_dv.sat writes/reads the same column opus created.

select
    PARTY_HKEY,
    HASHDIFF_COMMON_COMMUNICATION_PREFERENCE as HASHDIFF,
    CORRESPONDENCE_LANGUAGE,
    GO_GREEN_OPT_IN_INDICATOR,
    PREFERRED_CHANNEL_CODE,
    PREFERRED_LANGUAGE_CODE,
    LOAD_DATETIME,
    RECORD_SOURCE
from {{ ref('stg2_mp__pd_prop_sp_pv') }}
