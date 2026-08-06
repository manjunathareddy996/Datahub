{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_LNK_PARTY_ROLE_CORE
-- Parent: HUB_PARTY
-- Multi-active grain key: Role Code, Role Sequence
-- Source: {{ ref('int_health__sat_lnk_party_role_core') }}. No joins in THIS load.

with source_data as (

    select parent_bk, role_code_ck, role_sequence_ck, role_category, role_type, record_source
    from {{ ref('int_health__sat_lnk_party_role_core') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'parent_bk']) }} as party_hkey,
        parent_bk, role_code_ck, role_sequence_ck,
        role_category, role_type,
        record_source
    from source_data

),

hashed as (

    select
        party_hkey,
        role_code_ck, role_sequence_ck,
        role_category, role_type,
        {{ dbt_utils.generate_surrogate_key(['role_category', 'role_type']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by party_hkey, role_code_ck, role_sequence_ck, hashdiff
        order by record_source
    ) = 1

)

select
    party_hkey,
    role_code_ck, role_sequence_ck,
        role_category, role_type,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.party_hkey = d.party_hkey and t.role_code_ck = d.role_code_ck and t.role_sequence_ck = d.role_sequence_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
