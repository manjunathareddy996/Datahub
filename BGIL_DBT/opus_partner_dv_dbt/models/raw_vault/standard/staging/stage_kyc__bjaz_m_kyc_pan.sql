{{ config(materialized='view') }}

-- KYC STAGE: BJAZ_M_KYC_PAN + resolved part_id (AUTH_ID -> BJAZ_T_KYC_DETAILS partner row).
-- HUB_PARTY_EMIT is false when no part_id resolves; such rows get a NULL PARTY_HKEY in
-- the sat stage and are dropped by sat_multi_source (WHERE src_pk IS NOT NULL).

with src as (select * from {{ ref('stg_partner__bjaz_m_kyc_pan') }})
, res as (select * from {{ ref('res_kyc__part_by_auth_id') }})

select
    src.*,
    res.part_id,
    res.part_id_n,
    (res.part_id is not null) as hub_party_emit
from src
left join res on src.auth_id = res.auth_id
