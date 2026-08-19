{{ config(materialized='view') }}

-- STG_A: trim + null cleaning for TABLE_A
-- Convention: nullif(trim(to_varchar(col)), '') -> stable hashing downstream

select
    nullif(trim(to_varchar(id)), '')            as id,
    nullif(trim(to_varchar(phone_1)), '')       as phone_1,
    updated_at                                   as updated_at
from {{ source('demo_raw', 'TABLE_A') }}
{{ get_incremental_filter('BAGIC_PREPROD_CURATED_DB', 'BGIL_DEV_DATA_MODEL', 'SAT_A_B', 'TABLE_A') }}
