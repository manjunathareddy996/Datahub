{{ config(materialized='view') }}

-- Thin wrapper over stg2_mp__pd_prop_sp_pv: renames this satellite's suffixed hashdiff to the
-- shared HASHDIFF column name so automate_dv.sat writes/reads the same column opus created.

select
    PARTY_HKEY,
    HASHDIFF_PARTY_ONBOARDING_JOURNEY as HASHDIFF,
    ONBOARDING_START_DATE,
    PREVIOUS_EMPLOYER_NAME,
    PRIOR_WORK_EXPERIENCE_YEARS,
    LOAD_DATETIME,
    RECORD_SOURCE
from {{ ref('stg2_mp__pd_prop_sp_pv') }}
