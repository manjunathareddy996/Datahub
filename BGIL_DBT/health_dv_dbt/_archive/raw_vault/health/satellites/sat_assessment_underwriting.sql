{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_ASSESSMENT_UNDERWRITING
-- Parent: HUB_ASSESSMENT
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_assessment_underwriting') }}. No joins in THIS load.

with source_data as (

    select parent_bk, special_conditions_recommended, underwriting_remarks, record_source
    from {{ ref('int_health__sat_assessment_underwriting') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_ASSESSMENT'", 'parent_bk']) }} as assessment_hkey,
        parent_bk,
        special_conditions_recommended, underwriting_remarks,
        record_source
    from source_data

),

hashed as (

    select
        assessment_hkey,
        special_conditions_recommended, underwriting_remarks,
        {{ dbt_utils.generate_surrogate_key(['special_conditions_recommended', 'underwriting_remarks']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by assessment_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    assessment_hkey,
    special_conditions_recommended, underwriting_remarks,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.assessment_hkey = d.assessment_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
