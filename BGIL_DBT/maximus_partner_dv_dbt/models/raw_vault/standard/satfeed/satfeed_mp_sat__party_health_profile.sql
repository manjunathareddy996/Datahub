{{ config(materialized='view') }}

-- Thin wrapper over stg2_mp__pd_prop_sp_pv: renames this satellite's suffixed hashdiff to the
-- shared HASHDIFF column name so automate_dv.sat writes/reads the same column opus created.

select
    PARTY_HKEY,
    HASHDIFF_PARTY_HEALTH_PROFILE as HASHDIFF,
    DISABILITY_INDICATOR,
    DISABILITY_PERCENTAGE,
    HEIGHT,
    PRE_EXISTING_DISEASE_DESCRIPTION,
    WEIGHT,
    LOAD_DATETIME,
    RECORD_SOURCE
from {{ ref('stg2_mp__pd_prop_sp_pv') }}
