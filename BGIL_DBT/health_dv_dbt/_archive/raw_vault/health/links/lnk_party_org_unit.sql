{{
    config(
        materialized='incremental',
        unique_key='party_org_unit_hkey'
    )
}}

-- Link: LNK_PARTY_ORG_UNIT (Party Serviced By Org Unit) -- Associative
-- Associates a party with the servicing/owning internal organisation unit.
-- Source: {{ ref('int_health__lnk_party_org_unit') }} (unions 9 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_party_org_unit') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_ORG_UNIT'", 'org_unit_bk']) }} as org_unit_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'party_bk']) }} as party_hkey,
        org_unit_bk, party_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_PARTY_ORG_UNIT'", 'org_unit_hkey', 'party_hkey']) }} as party_org_unit_hkey,
        org_unit_hkey, org_unit_bk, party_hkey, party_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by party_org_unit_hkey order by record_source) = 1

)

select party_org_unit_hkey, org_unit_hkey, org_unit_bk, party_hkey, party_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where party_org_unit_hkey not in (select party_org_unit_hkey from {{ this }})
{% endif %}
