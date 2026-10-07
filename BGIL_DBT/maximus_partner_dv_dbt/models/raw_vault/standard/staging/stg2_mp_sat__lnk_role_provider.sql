{{ config(materialized='view') }}

-- Thin wrapper over stg2_mp__pd_prop_sp_pv: renames this satellite's suffixed hashdiff to the
-- shared HASHDIFF column name so automate_dv.sat writes/reads the same column opus created.

select
    PARTY_HKEY,
    HASHDIFF_LNK_ROLE_PROVIDER as HASHDIFF,
    DEEMPANELMENTDATE,
    DELISTINGDATE,
    DELISTINGINDICATOR,
    EMPANELMENTDATE,
    EVALUATIONDATE,
    ICUNURSECOUNT,
    MOUREFERENCE,
    MOUSTATUS,
    NABHACCREDITEDINDICATOR,
    NURSETOBEDRATIO,
    NURSETOPATIENTRATIO,
    PROVIDERCATEGORY,
    PROVIDERCODE,
    PROVIDERTYPE,
    SERVICESCOPEDESCRIPTION,
    SPECIALISATION,
    LOAD_DATETIME,
    RECORD_SOURCE
from {{ ref('stg2_mp__pd_prop_sp_pv') }}
