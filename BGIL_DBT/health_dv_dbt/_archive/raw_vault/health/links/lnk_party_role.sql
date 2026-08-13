{{
    config(
        materialized='incremental',
        unique_key='party_role_hkey'
    )
}}

-- Link: LNK_PARTY_ROLE (Party Plays Role) -- Associative
-- Associates a party with a business role it plays (customer, agent, broker, POSP, surveyor, TPA, provider, reinsurer, beneficiary, nominee, employee). Role detail held in satellite.
-- Source: {{ ref('int_health__lnk_party_role') }} (unions 2 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_party_role') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'party_bk']) }} as party_hkey,
        {{ dbt_utils.generate_surrogate_key(["'LNK_PARTY_ROLE'", 'link_instance_bk']) }} as link_instance_hkey,
        party_bk, link_instance_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_PARTY_ROLE'", 'party_hkey', 'link_instance_hkey']) }} as party_role_hkey,
        party_hkey, party_bk, link_instance_hkey, link_instance_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by party_role_hkey order by record_source) = 1

)

select party_role_hkey, party_hkey, party_bk, link_instance_hkey, link_instance_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where party_role_hkey not in (select party_role_hkey from {{ this }})
{% endif %}
