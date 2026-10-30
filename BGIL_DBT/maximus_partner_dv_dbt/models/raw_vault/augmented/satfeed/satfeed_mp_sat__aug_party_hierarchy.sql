{{ config(materialized='view') }}

-- Thin wrapper over stg2_aug_mp__pd_prop_sp_pv__party: renames the suffixed hashdiff
-- to the shared HASHDIFF column.

select
    PARTY_HKEY,
    HASHDIFF_AUG_PARTY_HIERARCHY as HASHDIFF,
    BRANCHMANAGERUSERIDENTIFIER,
    DISTRIBUTIONCLASSIFICATION,
    DISTRIBUTORCODE,
    RELATIONSHIPASSOCIATEEMPLOYEECODE,
    SELLINGDEALERREFERENCE,
    SERVICINGAGENTREFERENCE,
    TECHNICALSECTIONCODE,
    TRANSFERCASEINDICATOR,
    TRANSFERINDICATOR,
    ZONECODE,
    LOAD_DATETIME,
    RECORD_SOURCE
from {{ ref('stg2_aug_mp__pd_prop_sp_pv__party') }}
