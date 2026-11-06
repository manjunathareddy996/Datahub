{{ config(materialized='view') }}

-- KYC STAGE: BJAZ_T_KYC_DETAILS + resolved part_id.
-- A partner row (FIELD_TYPE = partner field type) carries part_id in its own FIELD_VALUE.
-- Any other row takes part_id from the partner row sharing its POI_DOC_ID.
-- HUB_PARTY_EMIT is false when no part_id resolves; such rows get a NULL PARTY_HKEY in
-- the sat stage and are dropped by sat_multi_source (WHERE src_pk IS NOT NULL).

with src as (select * from {{ ref('stg_partner__bjaz_t_kyc_details') }})
, res as (select * from {{ ref('res_kyc__part_by_poi_doc_id') }})

select
    src.*,
    coalesce(
        case when upper(trim(src.field_type)) = upper('{{ var("kyc_partner_field_type", "PARTNER_ID") }}')
             then src.field_value end,
        res.part_id
    ) as part_id,
    case when upper(trim(src.field_type)) = upper('{{ var("kyc_partner_field_type", "PARTNER_ID") }}')
              and src.field_value is not null
         then 1 else res.part_id_n end as part_id_n,
    (coalesce(
        case when upper(trim(src.field_type)) = upper('{{ var("kyc_partner_field_type", "PARTNER_ID") }}')
             then src.field_value end,
        res.part_id
    ) is not null) as hub_party_emit
from src
left join res on src.poi_doc_id = res.poi_doc_id
