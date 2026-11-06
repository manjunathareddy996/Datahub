{{ config(materialized='view') }}

-- RESOLVER: AUTH_ID -> part_id, one row per AUTH_ID.
-- Used by BJAZ_M_KYC_PAN / PASSPORT / VOTER / DRIVING_LICENCE / GSTN and BJAZ_T_KYC_AUTH.
-- part_id_n counts distinct partners per key: when it is > 1 the key maps to several
-- partners and max(part_id) is taken (counted, not hidden).

select
    auth_id,
    max(part_id)            as part_id,
    count(distinct part_id) as part_id_n
from {{ ref('res_kyc__partner_rows') }}
where auth_id is not null
group by auth_id
