{{
    config(
        materialized='incremental',
        unique_key='risk_object_assessment_hkey'
    )
}}

-- Link: LNK_RISK_OBJECT_ASSESSMENT (Risk Object Assessment) -- Transactional
-- Links valuations, surveys and inspections of a risk object.
-- Source: {{ ref('int_health__lnk_risk_object_assessment') }} (unions 2 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_risk_object_assessment') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_ASSESSMENT'", 'assessment_bk']) }} as assessment_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_RISK_OBJECT'", 'risk_object_bk']) }} as risk_object_hkey,
        assessment_bk, risk_object_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_RISK_OBJECT_ASSESSMENT'", 'assessment_hkey', 'risk_object_hkey']) }} as risk_object_assessment_hkey,
        assessment_hkey, assessment_bk, risk_object_hkey, risk_object_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by risk_object_assessment_hkey order by record_source) = 1

)

select risk_object_assessment_hkey, assessment_hkey, assessment_bk, risk_object_hkey, risk_object_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where risk_object_assessment_hkey not in (select risk_object_assessment_hkey from {{ this }})
{% endif %}
