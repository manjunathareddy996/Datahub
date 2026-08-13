{{
    config(
        materialized='incremental',
        unique_key='policy_renewal_hkey'
    )
}}

-- Link: LNK_POLICY_RENEWAL (Policy Renewal) -- Transactional
-- Links a renewing policy to its preceding policy term.
-- Single contributing source table: no intermediate view created (collapsed).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select policy_from_bk, policy_to_bk, record_source
    from (
    select distinct
        policy_no as policy_from_bk,
        prev_pol_ref as policy_to_bk,
        'BJAZ_GRP_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where policy_no is not null and prev_pol_ref is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'policy_from_bk']) }} as policy_from_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'policy_to_bk']) }} as policy_to_hkey,
        policy_from_bk, policy_to_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_POLICY_RENEWAL'", 'policy_from_hkey', 'policy_to_hkey']) }} as policy_renewal_hkey,
        policy_from_hkey, policy_from_bk, policy_to_hkey, policy_to_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by policy_renewal_hkey order by record_source) = 1

)

select policy_renewal_hkey, policy_from_hkey, policy_from_bk, policy_to_hkey, policy_to_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where policy_renewal_hkey not in (select policy_renewal_hkey from {{ this }})
{% endif %}
