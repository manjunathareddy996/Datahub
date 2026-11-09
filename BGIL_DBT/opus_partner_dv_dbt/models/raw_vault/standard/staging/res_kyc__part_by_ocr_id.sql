{{ config(materialized='view') }}

-- RESOLVER: OCR_ID -> part_id, one row per OCR_ID.
-- Route (per mapping): BJAZ_T_KYC_OCR.OCR_ID = BJAZ_T_KYC_POI_DOCUMENT.OCR_ID and
-- BJAZ_T_KYC_POA_DOCUMENT.OCR_ID; each document then reaches the BJAZ_T_KYC_DETAILS partner
-- row on POI_DOC_ID / POA_DOC_ID. Both legs are stacked before grouping.
-- part_id_n counts distinct partners per OCR_ID: when it is > 1 the OCR record maps to
-- several partners and max(part_id) is taken (counted, not hidden).

with legs as (
    select d.ocr_id, r.part_id
    from {{ ref('stg_partner__bjaz_t_kyc_poi_document') }} d
    join {{ ref('res_kyc__part_by_poi_doc_id') }} r on r.poi_doc_id = d.poi_doc_id
    where d.ocr_id is not null

    union all

    select d.ocr_id, r.part_id
    from {{ ref('stg_partner__bjaz_t_kyc_poa_document') }} d
    join {{ ref('res_kyc__part_by_poa_doc_id') }} r on r.poa_doc_id = d.poa_doc_id
    where d.ocr_id is not null
)

select
    ocr_id,
    max(part_id)            as part_id,
    count(distinct part_id) as part_id_n
from legs
group by ocr_id
