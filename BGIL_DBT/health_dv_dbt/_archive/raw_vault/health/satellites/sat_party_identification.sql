{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_PARTY_IDENTIFICATION
-- Parent: HUB_PARTY
-- Multi-active grain key: Identification Type Code
-- Source: {{ ref('int_health__sat_party_identification') }}. No joins in THIS load.

with source_data as (

    select parent_bk, identification_type_code_ck, aadhaar_number, aadhaar_verification_status, age_proof_type, eia_number, gstin, identification_number, pan_number, pan_verification_status, passport_number, tan_number, record_source
    from {{ ref('int_health__sat_party_identification') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'parent_bk']) }} as party_hkey,
        parent_bk, identification_type_code_ck,
        aadhaar_number, aadhaar_verification_status, age_proof_type, eia_number, gstin, identification_number, pan_number, pan_verification_status, passport_number, tan_number,
        record_source
    from source_data

),

hashed as (

    select
        party_hkey,
        identification_type_code_ck,
        aadhaar_number, aadhaar_verification_status, age_proof_type, eia_number, gstin, identification_number, pan_number, pan_verification_status, passport_number, tan_number,
        {{ dbt_utils.generate_surrogate_key(['aadhaar_number', 'aadhaar_verification_status', 'age_proof_type', 'eia_number', 'gstin', 'identification_number', 'pan_number', 'pan_verification_status', 'passport_number', 'tan_number']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by party_hkey, identification_type_code_ck, hashdiff
        order by record_source
    ) = 1

)

select
    party_hkey,
    identification_type_code_ck,
        aadhaar_number, aadhaar_verification_status, age_proof_type, eia_number, gstin, identification_number, pan_number, pan_verification_status, passport_number, tan_number,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.party_hkey = d.party_hkey and t.identification_type_code_ck = d.identification_type_code_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
