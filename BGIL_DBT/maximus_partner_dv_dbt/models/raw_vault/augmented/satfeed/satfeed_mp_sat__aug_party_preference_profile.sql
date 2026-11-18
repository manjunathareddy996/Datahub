{{ config(materialized='view') }}

-- Thin wrapper over stg2_aug_mp__pd_prop_sp_pv__party: renames the suffixed hashdiff
-- to the shared HASHDIFF column.

select
    PARTY_HKEY,
    HASHDIFF_AUG_PARTY_PREFERENCE_PROFILE as HASHDIFF,
    ELECTRONIC_POLICY_ISSUANCE_PREFERENCE_INDICATOR,
    PREFERREDLOCATION,
    PROPAGATE_CONTACT_UPDATE_TO_ALL_POLICIES_INDICATOR,
    LOAD_DATETIME,
    RECORD_SOURCE
from {{ ref('stg2_aug_mp__pd_prop_sp_pv__party') }}
