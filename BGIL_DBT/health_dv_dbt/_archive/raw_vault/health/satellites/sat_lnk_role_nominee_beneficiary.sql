{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_LNK_ROLE_NOMINEE_BENEFICIARY
-- MODELLING DEVIATION: canonical parent is LNK_PARTY_ROLE, but no Health source table
-- carries a role-instance/sequence column. Built directly off HUB_PARTY with a literal
-- role-type discriminator ('NOMINEE_BENEFICIARY'), NOT tied to lnk_party_role.party_role_hkey.
-- Parent: HUB_PARTY
-- Multi-active grain key: literal role type (NOMINEE_BENEFICIARY)
-- Source: {{ ref('int_health__sat_lnk_role_nominee_beneficiary') }}. No joins in THIS load.

with source_data as (

    select parent_bk, role_type_ck, relationship_to_insured, record_source
    from {{ ref('int_health__sat_lnk_role_nominee_beneficiary') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'parent_bk']) }} as party_hkey,
        parent_bk, role_type_ck,
        relationship_to_insured,
        record_source
    from source_data

),

hashed as (

    select
        party_hkey,
        role_type_ck,
        relationship_to_insured,
        {{ dbt_utils.generate_surrogate_key(['relationship_to_insured']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by party_hkey, role_type_ck, hashdiff
        order by record_source
    ) = 1

)

select
    party_hkey,
    role_type_ck,
        relationship_to_insured,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.party_hkey = d.party_hkey and t.role_type_ck = d.role_type_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
