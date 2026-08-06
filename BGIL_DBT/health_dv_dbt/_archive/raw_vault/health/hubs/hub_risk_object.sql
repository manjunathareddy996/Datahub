{{
    config(
        materialized='incremental',
        unique_key='risk_object_hkey'
    )
}}

-- Hub: HUB_RISK_OBJECT (Risk Object)
-- Business key: Risk Object Identifier (insured object / interest key)
-- Source: {{ ref('int_health__hub_risk_object') }} (unions 5 contributing tables).
-- Hash key is namespaced with the hub code, so this hub's hkey can never collide with another
-- hub's hkey even where both are sourced from literally the same raw column value (e.g.
-- HUB_QUOTE and HUB_PROPOSAL both keyed by QUOTE_REF_NO on some Health tables).
-- This load does no joins.

with source_data as (

    select * from {{ ref('int_health__hub_risk_object') }}

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_RISK_OBJECT'", 'business_key']) }} as risk_object_hkey,
        business_key as risk_object_bk,
        record_source,
        current_timestamp() as load_dts
    from source_data

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by risk_object_hkey order by record_source) = 1

)

select risk_object_hkey, risk_object_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where risk_object_hkey not in (select risk_object_hkey from {{ this }})
{% endif %}
