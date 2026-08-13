{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_POLICY_CLASSIFICATION
-- Parent: HUB_POLICY
-- Multi-active grain key: Classification Type
-- Source: {{ ref('int_health__sat_policy_classification') }}. No joins in THIS load.

with source_data as (

    select parent_bk, classification_type_ck, classification_value, record_source
    from {{ ref('int_health__sat_policy_classification') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'parent_bk']) }} as policy_hkey,
        parent_bk, classification_type_ck,
        classification_value,
        record_source
    from source_data

),

hashed as (

    select
        policy_hkey,
        classification_type_ck,
        classification_value,
        {{ dbt_utils.generate_surrogate_key(['classification_value']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by policy_hkey, classification_type_ck, hashdiff
        order by record_source
    ) = 1

)

select
    policy_hkey,
    classification_type_ck,
        classification_value,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.policy_hkey = d.policy_hkey and t.classification_type_ck = d.classification_type_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
