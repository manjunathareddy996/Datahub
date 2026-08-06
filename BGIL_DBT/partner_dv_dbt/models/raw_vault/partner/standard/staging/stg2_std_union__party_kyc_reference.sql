{{ config(materialized='view') }}

{% set cols = 'PARTY_HKEY, HASHDIFF, KYCREFERENCETYPE, LOAD_DATETIME, RECORD_SOURCE' %}

SELECT {{ cols }} FROM {{ ref('stg2_sat_bjaz_cp_part_hist__party_kyc_reference') }}
UNION ALL
SELECT {{ cols }} FROM {{ ref('stg2_sat_cp_partners__party_kyc_reference') }}
