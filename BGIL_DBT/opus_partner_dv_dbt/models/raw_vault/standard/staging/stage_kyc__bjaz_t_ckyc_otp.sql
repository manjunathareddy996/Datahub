{{ config(materialized='view') }}

-- KYC STAGE: BJAZ_T_CKYC_OTP + resolved part_id
-- (FIELD_TYPE, FIELD_VALUE -> BJAZ_T_KYC_DETAILS FIELD_TYPE, FIELD_VALUE).
-- HUB_PARTY_EMIT is false when no part_id resolves; such rows get a NULL PARTY_HKEY in
-- the sat stage and are dropped by sat_multi_source (WHERE src_pk IS NOT NULL).

with src as (select * from {{ ref('stg_partner__bjaz_t_ckyc_otp') }})
, res as (select * from {{ ref('res_kyc__part_by_field') }})

select
    src.*,
    res.part_id,
    res.part_id_n,
    (res.part_id is not null) as hub_party_emit
from src
left join res
  on  upper(trim(src.field_type))  = res.field_type
  and upper(trim(src.field_value)) = res.field_value
