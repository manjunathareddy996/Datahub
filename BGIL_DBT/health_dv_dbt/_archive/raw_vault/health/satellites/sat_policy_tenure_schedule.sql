{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_POLICY_TENURE_SCHEDULE
-- Parent: HUB_POLICY
-- Multi-active grain key: Tenure Sequence
-- Source: {{ ref('int_health__sat_policy_tenure_schedule') }}. No joins in THIS load.

with source_data as (

    select parent_bk, tenure_sequence_ck, tenure_premium, record_source
    from {{ ref('int_health__sat_policy_tenure_schedule') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'parent_bk']) }} as policy_hkey,
        parent_bk, tenure_sequence_ck,
        tenure_premium,
        record_source
    from source_data

),

hashed as (

    select
        policy_hkey,
        tenure_sequence_ck,
        tenure_premium,
        {{ dbt_utils.generate_surrogate_key(['tenure_premium']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by policy_hkey, tenure_sequence_ck, hashdiff
        order by record_source
    ) = 1

)

select
    policy_hkey,
    tenure_sequence_ck,
        tenure_premium,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.policy_hkey = d.policy_hkey and t.tenure_sequence_ck = d.tenure_sequence_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
