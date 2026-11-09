{{ config(materialized='view') }}

-- RESOLVER: POA_DOC_ID -> part_id, one row per POA_DOC_ID.
-- Used by res_kyc__part_by_ocr_id (BJAZ_T_KYC_POA_DOCUMENT leg). part_id_n counts distinct
-- partners per key: when it is > 1 the key maps to several partners and max(part_id) is
-- taken (counted, not hidden).

select
    poa_doc_id,
    max(part_id)            as part_id,
    count(distinct part_id) as part_id_n
from {{ ref('res_kyc__partner_rows') }}
where poa_doc_id is not null
group by poa_doc_id
