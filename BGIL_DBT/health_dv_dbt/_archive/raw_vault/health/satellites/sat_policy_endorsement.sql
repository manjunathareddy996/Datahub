{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_POLICY_ENDORSEMENT
-- Parent: HUB_POLICY
-- Multi-active grain key: Endorsement Number
-- Source: {{ ref('int_health__sat_policy_endorsement') }}. No joins in THIS load.

with source_data as (

    select parent_bk, endorsement_number_ck, effective_date, endorsement_date, endorsement_number, endorsement_type, record_source
    from {{ ref('int_health__sat_policy_endorsement') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'parent_bk']) }} as policy_hkey,
        parent_bk, endorsement_number_ck,
        effective_date, endorsement_date, endorsement_number, endorsement_type,
        record_source
    from source_data

),

hashed as (

    select
        policy_hkey,
        endorsement_number_ck,
        effective_date, endorsement_date, endorsement_number, endorsement_type,
        {{ dbt_utils.generate_surrogate_key(['effective_date', 'endorsement_date', 'endorsement_number', 'endorsement_type']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by policy_hkey, endorsement_number_ck, hashdiff
        order by record_source
    ) = 1

)

select
    policy_hkey,
    endorsement_number_ck,
        effective_date, endorsement_date, endorsement_number, endorsement_type,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.policy_hkey = d.policy_hkey and t.endorsement_number_ck = d.endorsement_number_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
