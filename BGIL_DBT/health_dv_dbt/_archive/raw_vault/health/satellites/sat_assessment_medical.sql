{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_ASSESSMENT_MEDICAL
-- Parent: HUB_ASSESSMENT
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_assessment_medical') }}. No joins in THIS load.

with source_data as (

    select parent_bk, abnormality_indicator, medical_management_date, medical_management_type, medical_test_type, recommended_exclusion, record_source
    from {{ ref('int_health__sat_assessment_medical') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_ASSESSMENT'", 'parent_bk']) }} as assessment_hkey,
        parent_bk,
        abnormality_indicator, medical_management_date, medical_management_type, medical_test_type, recommended_exclusion,
        record_source
    from source_data

),

hashed as (

    select
        assessment_hkey,
        abnormality_indicator, medical_management_date, medical_management_type, medical_test_type, recommended_exclusion,
        {{ dbt_utils.generate_surrogate_key(['abnormality_indicator', 'medical_management_date', 'medical_management_type', 'medical_test_type', 'recommended_exclusion']) }} as hashdiff,
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
    abnormality_indicator, medical_management_date, medical_management_type, medical_test_type, recommended_exclusion,
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
