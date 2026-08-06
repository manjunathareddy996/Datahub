{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_RISK_HEALTH_MEMBER_MEDICAL
-- Parent: HUB_RISK_OBJECT
-- Multi-active grain key: Member Reference
-- Source: {{ ref('int_health__sat_risk_health_member_medical') }}. No joins in THIS load.

with source_data as (

    select parent_bk, member_reference_ck, condition_name, date_of_marriage, disclosed_indicator, last_treatment_date, number_of_daughters, underwriting_loading_percentage, record_source
    from {{ ref('int_health__sat_risk_health_member_medical') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_RISK_OBJECT'", 'parent_bk']) }} as risk_object_hkey,
        parent_bk, member_reference_ck,
        condition_name, date_of_marriage, disclosed_indicator, last_treatment_date, number_of_daughters, underwriting_loading_percentage,
        record_source
    from source_data

),

hashed as (

    select
        risk_object_hkey,
        member_reference_ck,
        condition_name, date_of_marriage, disclosed_indicator, last_treatment_date, number_of_daughters, underwriting_loading_percentage,
        {{ dbt_utils.generate_surrogate_key(['condition_name', 'date_of_marriage', 'disclosed_indicator', 'last_treatment_date', 'number_of_daughters', 'underwriting_loading_percentage']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by risk_object_hkey, member_reference_ck, hashdiff
        order by record_source
    ) = 1

)

select
    risk_object_hkey,
    member_reference_ck,
        condition_name, date_of_marriage, disclosed_indicator, last_treatment_date, number_of_daughters, underwriting_loading_percentage,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.risk_object_hkey = d.risk_object_hkey and t.member_reference_ck = d.member_reference_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
