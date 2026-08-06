{{
    config(
        materialized='incremental',
        unique_key='assessment_hkey'
    )
}}

-- Hub: HUB_ASSESSMENT (Assessment)
-- Business key: Assessment Identifier
-- Source: {{ ref('int_health__hub_assessment') }} (unions 25 contributing tables).
-- Hash key is namespaced with the hub code, so this hub's hkey can never collide with another
-- hub's hkey even where both are sourced from literally the same raw column value (e.g.
-- HUB_QUOTE and HUB_PROPOSAL both keyed by QUOTE_REF_NO on some Health tables).
-- This load does no joins.

with source_data as (

    select * from {{ ref('int_health__hub_assessment') }}

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_ASSESSMENT'", 'business_key']) }} as assessment_hkey,
        business_key as assessment_bk,
        record_source,
        current_timestamp() as load_dts
    from source_data

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by assessment_hkey order by record_source) = 1

)

select assessment_hkey, assessment_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where assessment_hkey not in (select assessment_hkey from {{ this }})
{% endif %}
