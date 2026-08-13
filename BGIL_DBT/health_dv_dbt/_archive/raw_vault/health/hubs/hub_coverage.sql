{{
    config(
        materialized='incremental',
        unique_key='coverage_hkey'
    )
}}

-- Hub: HUB_COVERAGE (Coverage)
-- Business key: Coverage Identifier (canonical coverage / benefit key)
-- Source: {{ ref('int_health__hub_coverage') }} (unions 8 contributing tables).
-- Hash key is namespaced with the hub code, so this hub's hkey can never collide with another
-- hub's hkey even where both are sourced from literally the same raw column value (e.g.
-- HUB_QUOTE and HUB_PROPOSAL both keyed by QUOTE_REF_NO on some Health tables).
-- This load does no joins.

with source_data as (

    select * from {{ ref('int_health__hub_coverage') }}

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_COVERAGE'", 'business_key']) }} as coverage_hkey,
        business_key as coverage_bk,
        record_source,
        current_timestamp() as load_dts
    from source_data

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by coverage_hkey order by record_source) = 1

)

select coverage_hkey, coverage_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where coverage_hkey not in (select coverage_hkey from {{ this }})
{% endif %}
