{{ config(materialized='view') }}

-- Thin wrapper over stg2_mp__pd_prop_msdp_pv: renames this satellite's suffixed hashdiff to the
-- shared HASHDIFF column name so automate_dv.sat writes/reads the same column opus created.

select
    PAYMENT_INSTRUMENT_HKEY,
    HASHDIFF_INSTRUMENT_DEFINITION as HASHDIFF,
    CARDNUMBERMASKED,
    CARDTYPE,
    LOAD_DATETIME,
    RECORD_SOURCE
from {{ ref('stg2_mp__pd_prop_msdp_pv') }}
