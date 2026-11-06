{{ config(materialized='view') }}

-- RESOLVER: NAME_MATCH_ID -> part_id, one row per NAME_MATCH_ID.
-- BJAZ_T_KYC_NAME_MATCH.NAME_MATCH_ID can be referenced from any of the four name-match
-- columns on a BJAZ_T_KYC_DETAILS partner row (CKYC_, POI_, POA_, EKYC_NAME_MATCH_ID), so
-- the four are stacked before grouping. part_id_n counts distinct partners per key: when
-- it is > 1 the key maps to several partners and max(part_id) is taken (counted, not hidden).

with ids as (
    select ckyc_name_match_id as name_match_id, part_id from {{ ref('res_kyc__partner_rows') }}
    union all
    select poi_name_match_id,  part_id from {{ ref('res_kyc__partner_rows') }}
    union all
    select poa_name_match_id,  part_id from {{ ref('res_kyc__partner_rows') }}
    union all
    select ekyc_name_match_id, part_id from {{ ref('res_kyc__partner_rows') }}
)

select
    name_match_id,
    max(part_id)            as part_id,
    count(distinct part_id) as part_id_n
from ids
where name_match_id is not null
group by name_match_id
