{{ config(materialized='view') }}
-- KYC STAGE: BJAZ_T_KYC_POA_DOCUMENT + resolved part_id (POA_DOC_ID -> BJAZ_T_KYC_DETAILS partner row).
-- Same shape as the other stage_kyc__ models; needed so KYC document links can carry the party leg.
-- Written by generators/gen_partner_links_extra.py.
with src as (select * from {{ ref('stg_partner__bjaz_t_kyc_poa_document') }})
, res as (select * from {{ ref('res_kyc__part_by_poa_doc_id') }})
select
    src.*,
    res.part_id,
    res.part_id_n,
    (res.part_id is not null) as hub_party_emit
from src
left join res on src.poa_doc_id = res.poa_doc_id
