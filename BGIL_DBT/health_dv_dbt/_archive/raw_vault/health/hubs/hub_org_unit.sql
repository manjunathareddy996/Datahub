{{
    config(
        materialized='incremental',
        unique_key='org_unit_hkey'
    )
}}

-- Hub: HUB_ORG_UNIT (Organisation Unit)
-- Business key: Organisation Unit Code (internal hierarchy node)
-- Source: {{ ref('int_health__hub_org_unit') }} (unions 21 contributing tables).
-- Hash key is namespaced with the hub code, so this hub's hkey can never collide with another
-- hub's hkey even where both are sourced from literally the same raw column value (e.g.
-- HUB_QUOTE and HUB_PROPOSAL both keyed by QUOTE_REF_NO on some Health tables).
-- This load does no joins.

with source_data as (

    select * from {{ ref('int_health__hub_org_unit') }}

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_ORG_UNIT'", 'business_key']) }} as org_unit_hkey,
        business_key as org_unit_bk,
        record_source,
        current_timestamp() as load_dts
    from source_data

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by org_unit_hkey order by record_source) = 1

)

select org_unit_hkey, org_unit_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where org_unit_hkey not in (select org_unit_hkey from {{ this }})
{% endif %}
