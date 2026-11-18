{{ config(materialized='view') }}

-- Thin wrapper over stg2_mp__pd_prop_sp_pv: renames this satellite's suffixed hashdiff to the
-- shared HASHDIFF column name so automate_dv.sat writes/reads the same column opus created.

select
    PARTY_HKEY,
    HASHDIFF_LNK_ROLE_PROVIDER as HASHDIFF,
    DEEMPANELMENTDATE,
    DELISTINGDATE,
    DELISTINGINDICATOR,
    EMPANELMENT_DATE,
    EVALUATIONDATE,
    ICUNURSECOUNT,
    MOUREFERENCE,
    MOU_STATUS,
    NABHACCREDITEDINDICATOR,
    NURSETOBEDRATIO,
    NURSE_TO_PATIENT_RATIO,
    PROVIDERCATEGORY,
    PROVIDER_CODE,
    PROVIDER_TYPE,
    SERVICESCOPEDESCRIPTION,
    SPECIALISATION,
    LOAD_DATETIME,
    RECORD_SOURCE
from {{ ref('stg2_mp__pd_prop_sp_pv') }}
