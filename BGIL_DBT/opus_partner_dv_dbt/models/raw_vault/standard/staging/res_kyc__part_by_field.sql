{{ config(materialized='view') }}

-- RESOLVER: (FIELD_TYPE, FIELD_VALUE) -> part_id, one row per pair.
-- Route (per mapping): <table>.FIELD_TYPE, FIELD_VALUE = BJAZ_T_KYC_DETAILS.FIELD_TYPE, FIELD_VALUE.
-- The KYC_DETAILS row's part_id is taken from stage_kyc__bjaz_t_kyc_details, so it is the
-- partner value itself on partner rows and the POI_DOC_ID-resolved partner otherwise.
-- Used by BJAZ_T_CKYC_OTP. Both operands are normalised upper(trim()) on both sides.
-- part_id_n counts distinct partners per pair: when it is > 1 the pair maps to several
-- partners and max(part_id) is taken (counted, not hidden).

select
    upper(trim(field_type))   as field_type,
    upper(trim(field_value))  as field_value,
    max(part_id)              as part_id,
    count(distinct part_id)   as part_id_n
from {{ ref('stage_kyc__bjaz_t_kyc_details') }}
where field_type is not null
  and field_value is not null
  and part_id is not null
group by upper(trim(field_type)), upper(trim(field_value))
