{{
    config(
        materialized='incremental',
        unique_key='org_unit_hierarchy_hkey'
    )
}}

-- Link: LNK_ORG_UNIT_HIERARCHY (Org Unit Hierarchy) -- Hierarchical
-- Relates an organisation unit to its parent in the internal hierarchy.
-- Source: {{ ref('int_health__lnk_org_unit_hierarchy') }} (unions 7 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_org_unit_hierarchy') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_ORG_UNIT'", 'org_unit_from_bk']) }} as org_unit_from_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_ORG_UNIT'", 'org_unit_to_bk']) }} as org_unit_to_hkey,
        org_unit_from_bk, org_unit_to_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_ORG_UNIT_HIERARCHY'", 'org_unit_from_hkey', 'org_unit_to_hkey']) }} as org_unit_hierarchy_hkey,
        org_unit_from_hkey, org_unit_from_bk, org_unit_to_hkey, org_unit_to_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by org_unit_hierarchy_hkey order by record_source) = 1

)

select org_unit_hierarchy_hkey, org_unit_from_hkey, org_unit_from_bk, org_unit_to_hkey, org_unit_to_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where org_unit_hierarchy_hkey not in (select org_unit_hierarchy_hkey from {{ this }})
{% endif %}
