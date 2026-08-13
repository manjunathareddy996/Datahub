{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_POLICY_TAX_HEAD
-- Parent: HUB_POLICY
-- Multi-active grain key: Tax Head Code
-- Source: {{ ref('int_health__sat_policy_tax_head') }}. No joins in THIS load.

with source_data as (

    select parent_bk, tax_head_code_ck, tax_amount, record_source
    from {{ ref('int_health__sat_policy_tax_head') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'parent_bk']) }} as policy_hkey,
        parent_bk, tax_head_code_ck,
        tax_amount,
        record_source
    from source_data

),

hashed as (

    select
        policy_hkey,
        tax_head_code_ck,
        tax_amount,
        {{ dbt_utils.generate_surrogate_key(['tax_amount']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by policy_hkey, tax_head_code_ck, hashdiff
        order by record_source
    ) = 1

)

select
    policy_hkey,
    tax_head_code_ck,
        tax_amount,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.policy_hkey = d.policy_hkey and t.tax_head_code_ck = d.tax_head_code_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
