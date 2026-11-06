{{ config(materialized='view') }}

-- RESOLVER: INCOMING_ID -> part_id, one row per INCOMING_ID.
-- Used by BJAZ_T_KYC_INCOMING. part_id_n counts distinct partners per key: when it is > 1
-- the key maps to several partners and max(part_id) is taken (counted, not hidden).

select
    incoming_id,
    max(part_id)            as part_id,
    count(distinct part_id) as part_id_n
from {{ ref('res_kyc__partner_rows') }}
where incoming_id is not null
group by incoming_id
