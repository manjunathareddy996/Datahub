{{ config(materialized='view') }}

-- KYC -> PARTNER RESOLVER BASE.
-- BJAZ_T_KYC_DETAILS is the only KYC table that identifies the partner: rows where
-- FIELD_TYPE = <partner field type> carry the partner's part_id in FIELD_VALUE.
-- Every other KYC table reaches part_id by joining to these rows on its mapped key
-- (see the res_kyc__part_by_* resolvers).
-- The FIELD_TYPE literal is a var so it can be corrected without a code change:
--   dbt run --vars '{kyc_partner_field_type: PARTNER_ID}'

select
    bagic_kyc_id,
    incoming_id,
    search_id,
    auth_id,
    ekyc_id,
    poi_doc_id,
    poa_doc_id,
    ckyc_name_match_id,
    poi_name_match_id,
    poa_name_match_id,
    ekyc_name_match_id,
    field_value as part_id,
    inc_job_updated_at
from {{ ref('stg_partner__bjaz_t_kyc_details') }}
where upper(trim(field_type)) = upper('{{ var("kyc_partner_field_type", "PARTNER_ID") }}')
  and field_value is not null
