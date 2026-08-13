{{
    config(
        materialized='incremental',
        unique_key='case_hkey'
    )
}}

-- Hub: HUB_CASE (Case)
-- Business key: Case Identifier
-- Source: {{ ref('int_health__hub_case') }} (unions 6 contributing tables).
-- Hash key is namespaced with the hub code, so this hub's hkey can never collide with another
-- hub's hkey even where both are sourced from literally the same raw column value (e.g.
-- HUB_QUOTE and HUB_PROPOSAL both keyed by QUOTE_REF_NO on some Health tables).
-- This load does no joins.

with source_data as (

    select * from {{ ref('int_health__hub_case') }}

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CASE'", 'business_key']) }} as case_hkey,
        business_key as case_bk,
        record_source,
        current_timestamp() as load_dts
    from source_data

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by case_hkey order by record_source) = 1

)

select case_hkey, case_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where case_hkey not in (select case_hkey from {{ this }})
{% endif %}
