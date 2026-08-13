{{ config(materialized='view') }}

{% set cols = 'PARTY_HKEY, HASHDIFF, AGENT_CODE, IRDAI_AGENT_LICENCE_NUMBER, LICENCE_CATEGORY, LICENCE_EXPIRY_DATE, LICENCE_ISSUE_DATE, LOAD_DATETIME, RECORD_SOURCE' %}

SELECT {{ cols }} FROM {{ ref('stg2_rolesat_bjaz_intermediary__lnk_role_agent') }}
UNION ALL
SELECT {{ cols }} FROM {{ ref('stg2_rolesat_bjaz_intermediary_hist__lnk_role_agent') }}
