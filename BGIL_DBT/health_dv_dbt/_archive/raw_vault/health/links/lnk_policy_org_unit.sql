{{
    config(
        materialized='incremental',
        unique_key='policy_org_unit_hkey'
    )
}}

-- Link: LNK_POLICY_ORG_UNIT (Policy Org Unit) -- Associative
-- Associates issuing and servicing organisation units with a policy.
-- Source: {{ ref('int_health__lnk_policy_org_unit') }} (unions 13 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_policy_org_unit') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_ORG_UNIT'", 'org_unit_bk']) }} as org_unit_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'policy_bk']) }} as policy_hkey,
        org_unit_bk, policy_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_POLICY_ORG_UNIT'", 'org_unit_hkey', 'policy_hkey']) }} as policy_org_unit_hkey,
        org_unit_hkey, org_unit_bk, policy_hkey, policy_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by policy_org_unit_hkey order by record_source) = 1

)

select policy_org_unit_hkey, org_unit_hkey, org_unit_bk, policy_hkey, policy_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where policy_org_unit_hkey not in (select policy_org_unit_hkey from {{ this }})
{% endif %}
