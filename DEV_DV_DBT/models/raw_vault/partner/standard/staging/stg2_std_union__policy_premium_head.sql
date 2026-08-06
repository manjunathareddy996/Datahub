{{ config(materialized='view') }}

{% set cols = 'POLICY_HKEY, HASHDIFF, BASEAMOUNT, LOAD_DATETIME, RECORD_SOURCE' %}

SELECT {{ cols }} FROM {{ ref('stg2_sat_bjaz_hcf_member_dtls__policy_premium_head') }}
UNION ALL
SELECT {{ cols }} FROM {{ ref('stg2_sat_bjaz_starpkg_ff_dtls__policy_premium_head') }}
