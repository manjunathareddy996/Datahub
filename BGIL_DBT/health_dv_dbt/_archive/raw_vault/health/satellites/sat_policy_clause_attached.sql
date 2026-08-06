{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_POLICY_CLAUSE_ATTACHED
-- Parent: HUB_POLICY
-- Multi-active grain key: Clause Code
-- Source: {{ ref('int_health__sat_policy_clause_attached') }}. No joins in THIS load.

with source_data as (

    select parent_bk, clause_code_ck, clause_title, record_source
    from {{ ref('int_health__sat_policy_clause_attached') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'parent_bk']) }} as policy_hkey,
        parent_bk, clause_code_ck,
        clause_title,
        record_source
    from source_data

),

hashed as (

    select
        policy_hkey,
        clause_code_ck,
        clause_title,
        {{ dbt_utils.generate_surrogate_key(['clause_title']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by policy_hkey, clause_code_ck, hashdiff
        order by record_source
    ) = 1

)

select
    policy_hkey,
    clause_code_ck,
        clause_title,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.policy_hkey = d.policy_hkey and t.clause_code_ck = d.clause_code_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
