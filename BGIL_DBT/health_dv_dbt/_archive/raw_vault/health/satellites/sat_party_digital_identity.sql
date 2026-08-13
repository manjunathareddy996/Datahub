{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_PARTY_DIGITAL_IDENTITY
-- Parent: HUB_PARTY
-- Multi-active grain key: none (single-active)
-- Single contributing source table: no intermediate view created (collapsed). No joins in THIS load.

with source_data as (

    select parent_bk, login_identifier, record_source
    from (
        select distinct
            loginname as parent_bk,
            nullif(trim(to_varchar(loginname)), '') as login_identifier,
            'BJAZ_HM_POLICY_USERMAPPING' as record_source
        from {{ ref('stg_health__bjaz_hm_policy_usermapping') }}
        where loginname is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'parent_bk']) }} as party_hkey,
        parent_bk,
        login_identifier,
        record_source
    from source_data

),

hashed as (

    select
        party_hkey,
        login_identifier,
        {{ dbt_utils.generate_surrogate_key(['login_identifier']) }} as hashdiff,
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
    login_identifier,
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
