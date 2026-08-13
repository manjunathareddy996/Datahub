{{
    config(
        materialized='incremental',
        unique_key='policy_risk_object_hkey'
    )
}}

-- Link: LNK_POLICY_RISK_OBJECT (Policy Risk Object) -- Associative
-- Associates each insured object/interest covered by a policy.
-- Source: {{ ref('int_health__lnk_policy_risk_object') }} (unions 5 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_policy_risk_object') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'policy_bk']) }} as policy_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_RISK_OBJECT'", 'risk_object_bk']) }} as risk_object_hkey,
        policy_bk, risk_object_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_POLICY_RISK_OBJECT'", 'policy_hkey', 'risk_object_hkey']) }} as policy_risk_object_hkey,
        policy_hkey, policy_bk, risk_object_hkey, risk_object_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by policy_risk_object_hkey order by record_source) = 1

)

select policy_risk_object_hkey, policy_hkey, policy_bk, risk_object_hkey, risk_object_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where policy_risk_object_hkey not in (select policy_risk_object_hkey from {{ this }})
{% endif %}
