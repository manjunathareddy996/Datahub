{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_LNK_ROLE_TPA
-- MODELLING DEVIATION: canonical parent is LNK_PARTY_ROLE, but no Health source table
-- carries a role-instance/sequence column. Built directly off HUB_PARTY with a literal
-- role-type discriminator ('TPA'), NOT tied to lnk_party_role.party_role_hkey.
-- Parent: HUB_PARTY
-- Multi-active grain key: literal role type (TPA)
-- Single contributing source table: no intermediate view created (collapsed). No joins in THIS load.

with source_data as (

    select parent_bk, role_type_ck, tpa_code, record_source
    from (
        select distinct
            customer_id as parent_bk,
            'TPA' as role_type_ck,
            nullif(trim(to_varchar(tpa_id)), '') as tpa_code,
            'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
        from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
        where customer_id is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'parent_bk']) }} as party_hkey,
        parent_bk, role_type_ck,
        tpa_code,
        record_source
    from source_data

),

hashed as (

    select
        party_hkey,
        role_type_ck,
        tpa_code,
        {{ dbt_utils.generate_surrogate_key(['tpa_code']) }} as hashdiff,
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
        tpa_code,
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
