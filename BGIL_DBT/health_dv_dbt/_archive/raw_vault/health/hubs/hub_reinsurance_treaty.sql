{{
    config(
        materialized='incremental',
        unique_key='reinsurance_treaty_hkey'
    )
}}

-- Hub: HUB_REINSURANCE_TREATY (Reinsurance Treaty)
-- Business key: Treaty Identifier (enterprise reinsurance arrangement key)
-- Single contributing source table: no intermediate view created (collapsed).
-- Hash key is namespaced with the hub code, so this hub's hkey can never collide with another
-- hub's hkey even where both are sourced from literally the same raw column value (e.g.
-- HUB_QUOTE and HUB_PROPOSAL both keyed by QUOTE_REF_NO on some Health tables).
-- This load does no joins.

with source_data as (

    select distinct business_key, record_source
    from (
    select distinct
        re_insu as business_key,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where re_insu is not null
    )

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_REINSURANCE_TREATY'", 'business_key']) }} as reinsurance_treaty_hkey,
        business_key as reinsurance_treaty_bk,
        record_source,
        current_timestamp() as load_dts
    from source_data

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by reinsurance_treaty_hkey order by record_source) = 1

)

select reinsurance_treaty_hkey, reinsurance_treaty_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where reinsurance_treaty_hkey not in (select reinsurance_treaty_hkey from {{ this }})
{% endif %}
