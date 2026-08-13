{{ config(materialized='view') }}

SELECT POLICY_HKEY, HASHDIFF, NULL AS ENROLMENTDATE, MEMBERSTATUS, LOAD_DATETIME, RECORD_SOURCE
FROM {{ ref('stg2_sat_ba_hcp_dt_mem__policy_certificate') }}
UNION ALL
SELECT POLICY_HKEY, HASHDIFF, ENROLMENTDATE, NULL AS MEMBERSTATUS, LOAD_DATETIME, RECORD_SOURCE
FROM {{ ref('stg2_sat_bjaz_ctngy_pa_mem_dtls__policy_certificate') }}
UNION ALL
SELECT POLICY_HKEY, HASHDIFF, NULL AS ENROLMENTDATE, MEMBERSTATUS, LOAD_DATETIME, RECORD_SOURCE
FROM {{ ref('stg2_sat_bjaz_hm_member_dtls__policy_certificate') }}
