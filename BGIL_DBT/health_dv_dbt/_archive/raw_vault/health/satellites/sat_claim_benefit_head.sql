{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_CLAIM_BENEFIT_HEAD
-- Parent: HUB_CLAIM
-- Multi-active grain key: Benefit Head Code
-- Source: {{ ref('int_health__sat_claim_benefit_head') }}. No joins in THIS load.

with source_data as (

    select parent_bk, benefit_head_code_ck, claimed_amount, record_source
    from {{ ref('int_health__sat_claim_benefit_head') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CLAIM'", 'parent_bk']) }} as claim_hkey,
        parent_bk, benefit_head_code_ck,
        claimed_amount,
        record_source
    from source_data

),

hashed as (

    select
        claim_hkey,
        benefit_head_code_ck,
        claimed_amount,
        {{ dbt_utils.generate_surrogate_key(['claimed_amount']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by claim_hkey, benefit_head_code_ck, hashdiff
        order by record_source
    ) = 1

)

select
    claim_hkey,
    benefit_head_code_ck,
        claimed_amount,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.claim_hkey = d.claim_hkey and t.benefit_head_code_ck = d.benefit_head_code_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
