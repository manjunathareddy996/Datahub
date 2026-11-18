{{ config(materialized='view') }}

-- Thin wrapper over stg2_mp__pd_prop_sp_pv: renames this satellite's suffixed hashdiff to the
-- shared HASHDIFF column name so automate_dv.sat writes/reads the same column opus created.

select
    PARTY_HKEY,
    HASHDIFF_PROVIDER_TARIFF as HASHDIFF,
    DISCOUNT_PERCENTAGE,
    EFFECTIVE_DATE,
    EXPIRY_DATE,
    NEGOTIATEDINDICATOR,
    PACKAGE_RATE,
    ROOMCATEGORY,
    SERVICE_DESCRIPTION,
    TARIFF_RATE,
    TARIFFTIER,
    LOAD_DATETIME,
    RECORD_SOURCE
from {{ ref('stg2_mp__pd_prop_sp_pv') }}
