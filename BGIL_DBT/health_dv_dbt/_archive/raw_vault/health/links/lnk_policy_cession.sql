{{
    config(
        materialized='incremental',
        unique_key='policy_cession_hkey'
    )
}}

-- Link: LNK_POLICY_CESSION (Policy Cession) -- Transactional
-- Cedes a policy's risk to a treaty / facultative placement.
-- Single contributing source table: no intermediate view created (collapsed).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select policy_bk, reinsurance_treaty_bk, record_source
    from (
    select distinct
        reference_id as policy_bk,
        re_insu as reinsurance_treaty_bk,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where reference_id is not null and re_insu is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'policy_bk']) }} as policy_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_REINSURANCE_TREATY'", 'reinsurance_treaty_bk']) }} as reinsurance_treaty_hkey,
        policy_bk, reinsurance_treaty_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_POLICY_CESSION'", 'policy_hkey', 'reinsurance_treaty_hkey']) }} as policy_cession_hkey,
        policy_hkey, policy_bk, reinsurance_treaty_hkey, reinsurance_treaty_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by policy_cession_hkey order by record_source) = 1

)

select policy_cession_hkey, policy_hkey, policy_bk, reinsurance_treaty_hkey, reinsurance_treaty_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where policy_cession_hkey not in (select policy_cession_hkey from {{ this }})
{% endif %}
