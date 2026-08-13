{{ config(materialized='view') }}

{% set cols = 'PARTY_HKEY, HASHDIFF, APPOINTEE_NAME, RELATIONSHIP_TO_INSURED, LOAD_DATETIME, RECORD_SOURCE' %}

SELECT {{ cols }} FROM {{ ref('stg2_rolesat_bjaz_ctngy_ff_dtls_extn__lnk_role_nominee_beneficiary') }}
UNION ALL
SELECT PARTY_HKEY, HASHDIFF, NULL AS APPOINTEE_NAME, RELATIONSHIP_TO_INSURED, LOAD_DATETIME, RECORD_SOURCE FROM {{ ref('stg2_rolesat_bjaz_ctngy_gc_mem_data__lnk_role_nominee_beneficiary') }}
UNION ALL
SELECT {{ cols }} FROM {{ ref('stg2_rolesat_bjaz_ctngy_pa_mem_dtls__lnk_role_nominee_beneficiary') }}
UNION ALL
SELECT {{ cols }} FROM {{ ref('stg2_rolesat_bjaz_ec_mem_dtls_extn__lnk_role_nominee_beneficiary') }}
UNION ALL
SELECT {{ cols }} FROM {{ ref('stg2_rolesat_bjaz_hcf_member_dtls__lnk_role_nominee_beneficiary') }}
UNION ALL
SELECT {{ cols }} FROM {{ ref('stg2_rolesat_bjaz_hc_part_extn__lnk_role_nominee_beneficiary') }}
UNION ALL
SELECT {{ cols }} FROM {{ ref('stg2_rolesat_bjaz_hlt_ensure_mem_dtls__lnk_role_nominee_beneficiary') }}
UNION ALL
SELECT {{ cols }} FROM {{ ref('stg2_rolesat_bjaz_hm_member_dtls__lnk_role_nominee_beneficiary') }}
UNION ALL
SELECT {{ cols }} FROM {{ ref('stg2_rolesat_bjaz_pa_detl_extn__lnk_role_nominee_beneficiary') }}
UNION ALL
SELECT {{ cols }} FROM {{ ref('stg2_rolesat_bjaz_sh_mem_dtls_extn__lnk_role_nominee_beneficiary') }}
UNION ALL
SELECT {{ cols }} FROM {{ ref('stg2_rolesat_bjaz_spp_member_dtls__lnk_role_nominee_beneficiary') }}
UNION ALL
SELECT {{ cols }} FROM {{ ref('stg2_rolesat_bjaz_starpkg_ff_dtls__lnk_role_nominee_beneficiary') }}
