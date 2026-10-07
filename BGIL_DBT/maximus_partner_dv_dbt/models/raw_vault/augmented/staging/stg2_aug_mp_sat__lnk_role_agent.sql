{{ config(materialized='view') }}

-- Thin wrapper over stg2_aug_mp__pd_prop_sp_pv__party: renames this satellite's suffixed hashdiff
-- to the shared HASHDIFF column name so automate_dv.sat matches the column opus created.

select
    PARTY_HKEY,
    HASHDIFF_AUG_LNK_ROLE_AGENT as HASHDIFF,
    AFFINITYPARTNEREMPLOYEEINDICATOR,
    AUTHORISEDPERSONNUMBER,
    DSAINDICATOR,
    INTERMEDIARYLICENCENUMBER,
    IRDAICATEGORY,
    IRDAIPRIMARYPROFESSION,
    IRDAIUNIQUEIDENTIFIER,
    LICENCEDETAIL,
    LOAD_DATETIME,
    RECORD_SOURCE
from {{ ref('stg2_aug_mp__pd_prop_sp_pv__party') }}
