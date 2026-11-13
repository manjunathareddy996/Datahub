{{ config(materialized='view') }}

-- Thin wrapper over stg2_mp__pd_prop_sp_pv: renames this satellite's suffixed hashdiff to the
-- shared HASHDIFF column name so automate_dv.sat writes/reads the same column opus created.

select
    PARTY_HKEY,
    HASHDIFF_LNK_ROLE_CUSTOMER as HASHDIFF,
    CONSENTFORDATASHARINGINDICATOR as CONSENT_FOR_DATA_SHARING_INDICATOR,
    PREFERREDCUSTOMERINDICATOR as PREFERRED_CUSTOMER_INDICATOR,
    LOAD_DATETIME,
    RECORD_SOURCE
from {{ ref('stg2_mp__pd_prop_sp_pv') }}
