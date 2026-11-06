{{ config(materialized='view') }}

-- RESOLVER: POI_DOC_ID -> part_id, one row per POI_DOC_ID.
-- Used by BJAZ_T_KYC_DETAILS (rows that are not themselves partner rows) and, later,
-- BJAZ_T_KYC_POI_DOCUMENT. part_id_n counts distinct partners per key: when it is > 1
-- the key maps to several partners and max(part_id) is taken (counted, not hidden).

select
    poi_doc_id,
    max(part_id)            as part_id,
    count(distinct part_id) as part_id_n
from {{ ref('res_kyc__partner_rows') }}
where poi_doc_id is not null
group by poi_doc_id
