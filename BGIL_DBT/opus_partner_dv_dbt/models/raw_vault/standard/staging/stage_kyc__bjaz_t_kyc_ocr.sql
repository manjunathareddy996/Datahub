{{ config(materialized='view') }}

-- KYC STAGE: BJAZ_T_KYC_OCR + resolved part_id
-- (OCR_ID -> BJAZ_T_KYC_POI_DOCUMENT / BJAZ_T_KYC_POA_DOCUMENT -> POI_DOC_ID / POA_DOC_ID
--  -> BJAZ_T_KYC_DETAILS partner row).
-- HUB_PARTY_EMIT is false when no part_id resolves; such rows get a NULL PARTY_HKEY in
-- the sat stage and are dropped by sat_multi_source (WHERE src_pk IS NOT NULL).

with src as (select * from {{ ref('stg_partner__bjaz_t_kyc_ocr') }})
, res as (select * from {{ ref('res_kyc__part_by_ocr_id') }})

select
    src.*,
    res.part_id,
    res.part_id_n,
    (res.part_id is not null) as hub_party_emit
from src
left join res on src.ocr_id = res.ocr_id
