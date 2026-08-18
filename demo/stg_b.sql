{{ config(materialized='view') }}

-- STG_B: trim + null cleaning for TABLE_B
-- Convention: nullif(trim(to_varchar(col)), '') -> stable hashing downstream

select
    nullif(trim(to_varchar(id)), '')            as id,
    nullif(trim(to_varchar(phone_1)), '')       as phone_1,
    nullif(trim(to_varchar(phone_2)), '')       as phone_2,
    updated_at                                   as updated_at
from {{ source('demo_raw', 'TABLE_B') }}
