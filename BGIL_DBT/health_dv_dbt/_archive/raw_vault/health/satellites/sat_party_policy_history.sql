{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_PARTY_POLICY_HISTORY
-- Parent: HUB_PARTY
-- Multi-active grain key: none (single-active)
-- Single contributing source table: no intermediate view created (collapsed). No joins in THIS load.

with source_data as (

    select parent_bk, continuous_years_insured, record_source
    from (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(hlth_ins_pol_yrs)), '') as continuous_years_insured,
            'BJAZ_EC_MEM_DTLS_EXTN' as record_source
        from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
        where member_no is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'parent_bk']) }} as party_hkey,
        parent_bk,
        continuous_years_insured,
        record_source
    from source_data

),

hashed as (

    select
        party_hkey,
        continuous_years_insured,
        {{ dbt_utils.generate_surrogate_key(['continuous_years_insured']) }} as hashdiff,
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
    continuous_years_insured,
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
