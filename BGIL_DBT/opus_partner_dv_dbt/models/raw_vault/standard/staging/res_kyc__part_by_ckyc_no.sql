{{ config(materialized='view') }}

-- RESOLVER: CKYC number -> part_id, one row per CKYC number.
-- Route: BJAZ_T_CKYC_SEARCH.CKYC_NUMBER -> BJAZ_T_CKYC_SEARCH.SEARCH_ID -> BJAZ_T_KYC_DETAILS
-- partner row (res_kyc__partner_rows). Used by BJAZ_T_CKYC_PERSONAL_DTLS and
-- BJAZ_T_CKYC_REL_PERSION_DTLS, which carry only CKYC_NO.
-- ckyc_no is normalised upper(trim()) on both sides of the join.
-- part_id_n counts distinct partners per CKYC number: when it is > 1 the number maps to
-- several partners and max(part_id) is taken (counted, not hidden).

select
    upper(trim(s.ckyc_number))  as ckyc_no,
    max(r.part_id)              as part_id,
    count(distinct r.part_id)   as part_id_n
from {{ ref('stg_partner__bjaz_t_ckyc_search') }} s
join {{ ref('res_kyc__partner_rows') }} r
  on r.search_id = s.search_id
where s.ckyc_number is not null
group by upper(trim(s.ckyc_number))
