{{
    config(
        materialized='incremental',
        unique_key='policy_endorsement_hkey'
    )
}}

-- Link: LNK_POLICY_ENDORSEMENT (Policy Endorsement) -- Transactional
-- Records an endorsement transaction altering a policy (financial or non-financial). Endorsement detail held in satellite; same-hub link captures the event sequence.
-- Single contributing source table: no intermediate view created (collapsed).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select policy_bk, link_instance_bk, record_source
    from (
    select distinct
        policy_ref as policy_bk,
        endt_no as link_instance_bk,
        'BJAZ_PMJAY_PRMBOOK_DTLS' as record_source
    from {{ ref('stg_health__bjaz_pmjay_prmbook_dtls') }}
    where policy_ref is not null and endt_no is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'policy_bk']) }} as policy_hkey,
        {{ dbt_utils.generate_surrogate_key(["'LNK_POLICY_ENDORSEMENT'", 'link_instance_bk']) }} as link_instance_hkey,
        policy_bk, link_instance_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_POLICY_ENDORSEMENT'", 'policy_hkey', 'link_instance_hkey']) }} as policy_endorsement_hkey,
        policy_hkey, policy_bk, link_instance_hkey, link_instance_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by policy_endorsement_hkey order by record_source) = 1

)

select policy_endorsement_hkey, policy_hkey, policy_bk, link_instance_hkey, link_instance_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where policy_endorsement_hkey not in (select policy_endorsement_hkey from {{ this }})
{% endif %}
