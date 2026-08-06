{{
    config(
        materialized='incremental',
        unique_key='claim_party_hkey'
    )
}}

-- Link: LNK_CLAIM_PARTY (Claim Party) -- Associative
-- Associates claimant, insured, beneficiary, surveyor, investigator, TPA, garage/hospital and third parties with a claim.
-- Source: {{ ref('int_health__lnk_claim_party') }} (unions 14 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_claim_party') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CLAIM'", 'claim_bk']) }} as claim_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'party_bk']) }} as party_hkey,
        claim_bk, party_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_CLAIM_PARTY'", 'claim_hkey', 'party_hkey']) }} as claim_party_hkey,
        claim_hkey, claim_bk, party_hkey, party_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by claim_party_hkey order by record_source) = 1

)

select claim_party_hkey, claim_hkey, claim_bk, party_hkey, party_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where claim_party_hkey not in (select claim_party_hkey from {{ this }})
{% endif %}
