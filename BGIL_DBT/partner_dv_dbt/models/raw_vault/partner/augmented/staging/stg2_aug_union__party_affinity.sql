{{ config(materialized='view') }}

SELECT PARTY_HKEY, HASHDIFF, AA_MEMBERSHIP_NUMBER, AA_MEMBERSHIP_EXPIRY_DATE, LOAD_DATETIME, RECORD_SOURCE
FROM {{ ref('stg2_aug_azbj_partner_extn__party_affinity') }}
UNION ALL
SELECT PARTY_HKEY, HASHDIFF, AA_MEMBERSHIP_NUMBER, AA_MEMBERSHIP_EXPIRY_DATE, LOAD_DATETIME, RECORD_SOURCE
FROM {{ ref('stg2_aug_bjaz_azbj_part_ext_hist__party_affinity') }}
