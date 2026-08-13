{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_RISK_PERSON_INSURED
-- Parent: HUB_RISK_OBJECT
-- Multi-active grain key: none (single-active)
-- Source: {{ ref('int_health__sat_risk_person_insured') }}. No joins in THIS load.

with source_data as (

    select parent_bk, age_at_entry, body_mass_index, critical_illness_cover_indicator, cumulative_bonus_applicable_indicator, floater_indicator, health_card_number, height, insured_member_name, insured_member_reference, member_risk_loading_percentage, member_type, occupation_risk_class, policy_holder_relationship, pre_existing_disease_description, relationship_to_proposer, smoker_indicator, weight, record_source
    from {{ ref('int_health__sat_risk_person_insured') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_RISK_OBJECT'", 'parent_bk']) }} as risk_object_hkey,
        parent_bk,
        age_at_entry, body_mass_index, critical_illness_cover_indicator, cumulative_bonus_applicable_indicator, floater_indicator, health_card_number, height, insured_member_name, insured_member_reference, member_risk_loading_percentage, member_type, occupation_risk_class, policy_holder_relationship, pre_existing_disease_description, relationship_to_proposer, smoker_indicator, weight,
        record_source
    from source_data

),

hashed as (

    select
        risk_object_hkey,
        age_at_entry, body_mass_index, critical_illness_cover_indicator, cumulative_bonus_applicable_indicator, floater_indicator, health_card_number, height, insured_member_name, insured_member_reference, member_risk_loading_percentage, member_type, occupation_risk_class, policy_holder_relationship, pre_existing_disease_description, relationship_to_proposer, smoker_indicator, weight,
        {{ dbt_utils.generate_surrogate_key(['age_at_entry', 'body_mass_index', 'critical_illness_cover_indicator', 'cumulative_bonus_applicable_indicator', 'floater_indicator', 'health_card_number', 'height', 'insured_member_name', 'insured_member_reference', 'member_risk_loading_percentage', 'member_type', 'occupation_risk_class', 'policy_holder_relationship', 'pre_existing_disease_description', 'relationship_to_proposer', 'smoker_indicator', 'weight']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by risk_object_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    risk_object_hkey,
    age_at_entry, body_mass_index, critical_illness_cover_indicator, cumulative_bonus_applicable_indicator, floater_indicator, health_card_number, height, insured_member_name, insured_member_reference, member_risk_loading_percentage, member_type, occupation_risk_class, policy_holder_relationship, pre_existing_disease_description, relationship_to_proposer, smoker_indicator, weight,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.risk_object_hkey = d.risk_object_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
