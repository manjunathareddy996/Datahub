{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_PARTY_IDENTITY
-- SUBJECT-ATTRIBUTION REANCHOR: 13 contributing branch(es) hold a DIFFERENT person's data than the table's default
-- anchor party (nominee/RM/intermediary/hospital/provider) -- keyed via their own
-- companion column, not the table's main HUB_PARTY key. Branches: BA_HCP_PROD_8432_ECP_LOADER::imd-relationship-manager, BA_HCP_PROD_8432_ECP_LOADER::insurer-relationship-manager, BA_HCP_PROD_8433_FHC_LOADER::imd-relationship-manager, BA_HCP_PROD_8433_FHC_LOADER::insurer-relationship-manager, BJAZ_GPG_POL_DTLS::intermediary, BJAZ_GPG_POL_DTLS::relationship-manager, BJAZ_GPG_POL_DTLS::sub-intermediary, BJAZ_GRP_HLT_IMD_DTLS::intermediary, BJAZ_GRP_HLT_IMD_DTLS::relationship-manager, BJAZ_GRP_HLT_IMD_DTLS::sub-intermediary, BJAZ_HM_HCM_EXTRACT::hospital, BJAZ_REMEDINET_CLAIM_DETAILS::provider, BJAZ_TPA_CLAIM_DETAILS_WS::provider. See docs/appendix_9_subject_attribution.csv.
-- Parent: HUB_PARTY
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_party_identity') }}. No joins in THIS load.

with source_data as (

    select parent_bk, age, date_of_birth, first_name, gender_code, last_name, middle_name, party_display_name, party_full_name, party_legal_name, party_status, party_status_reason, party_sub_type_code, party_type_code, salutation, record_source
    from {{ ref('int_health__sat_party_identity') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'parent_bk']) }} as party_hkey,
        parent_bk,
        age, date_of_birth, first_name, gender_code, last_name, middle_name, party_display_name, party_full_name, party_legal_name, party_status, party_status_reason, party_sub_type_code, party_type_code, salutation,
        record_source
    from source_data

),

hashed as (

    select
        party_hkey,
        age, date_of_birth, first_name, gender_code, last_name, middle_name, party_display_name, party_full_name, party_legal_name, party_status, party_status_reason, party_sub_type_code, party_type_code, salutation,
        {{ dbt_utils.generate_surrogate_key(['age', 'date_of_birth', 'first_name', 'gender_code', 'last_name', 'middle_name', 'party_display_name', 'party_full_name', 'party_legal_name', 'party_status', 'party_status_reason', 'party_sub_type_code', 'party_type_code', 'salutation']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by party_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    party_hkey,
    age, date_of_birth, first_name, gender_code, last_name, middle_name, party_display_name, party_full_name, party_legal_name, party_status, party_status_reason, party_sub_type_code, party_type_code, salutation,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.party_hkey = d.party_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
