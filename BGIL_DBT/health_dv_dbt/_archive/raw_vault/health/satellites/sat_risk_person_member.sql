{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_RISK_PERSON_MEMBER
-- Parent: HUB_RISK_OBJECT
-- Multi-active grain key: Member Sequence
-- Source: {{ ref('int_health__sat_risk_person_member') }}. No joins in THIS load.

with source_data as (

    select parent_bk, member_sequence_ck, age, date_of_birth, gender, member_addition_indicator, member_name, member_type, passport_number, pre_existing_disease_description, relationship_to_proposer, record_source
    from {{ ref('int_health__sat_risk_person_member') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_RISK_OBJECT'", 'parent_bk']) }} as risk_object_hkey,
        parent_bk, member_sequence_ck,
        age, date_of_birth, gender, member_addition_indicator, member_name, member_type, passport_number, pre_existing_disease_description, relationship_to_proposer,
        record_source
    from source_data

),

hashed as (

    select
        risk_object_hkey,
        member_sequence_ck,
        age, date_of_birth, gender, member_addition_indicator, member_name, member_type, passport_number, pre_existing_disease_description, relationship_to_proposer,
        {{ dbt_utils.generate_surrogate_key(['age', 'date_of_birth', 'gender', 'member_addition_indicator', 'member_name', 'member_type', 'passport_number', 'pre_existing_disease_description', 'relationship_to_proposer']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by risk_object_hkey, member_sequence_ck, hashdiff
        order by record_source
    ) = 1

)

select
    risk_object_hkey,
    member_sequence_ck,
        age, date_of_birth, gender, member_addition_indicator, member_name, member_type, passport_number, pre_existing_disease_description, relationship_to_proposer,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.risk_object_hkey = d.risk_object_hkey and t.member_sequence_ck = d.member_sequence_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
