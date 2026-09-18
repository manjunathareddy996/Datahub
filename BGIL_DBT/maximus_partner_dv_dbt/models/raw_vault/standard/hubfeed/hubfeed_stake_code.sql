{{ config(materialized='view') }}

-- Feed for HUB_STAKE_CODE: distinct, non-null STAKE_CODE business keys from the
-- related-party source. Filters out rows where STAKE_CODE is null so the hub only
-- receives real business keys.

    select STAKE_CODE_HKEY, STAKE_CODE_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__stake_code') }}
    where STAKE_CODE_BK is not null
