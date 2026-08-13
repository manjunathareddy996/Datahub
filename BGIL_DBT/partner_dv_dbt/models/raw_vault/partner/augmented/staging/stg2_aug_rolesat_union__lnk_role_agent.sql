{{ config(materialized='view') }}

SELECT PARTY_HKEY, HASHDIFF, INTERMEDIARY_LICENCE_NUMBER, LOAD_DATETIME, RECORD_SOURCE
FROM {{ ref('stg2_aug_rolesat_bjaz_intermediary__lnk_role_agent') }}
UNION ALL
SELECT PARTY_HKEY, HASHDIFF, INTERMEDIARY_LICENCE_NUMBER, LOAD_DATETIME, RECORD_SOURCE
FROM {{ ref('stg2_aug_rolesat_bjaz_intermediary_hist__lnk_role_agent') }}
