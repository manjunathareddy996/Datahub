{{
    config(
        materialized='incremental',
        unique_key='proposal_hkey'
    )
}}

-- Hub: HUB_PROPOSAL (Proposal)
-- Business key: Proposal Identifier
-- Source: {{ ref('int_health__hub_proposal') }} (unions 19 contributing tables).
-- Hash key is namespaced with the hub code, so this hub's hkey can never collide with another
-- hub's hkey even where both are sourced from literally the same raw column value (e.g.
-- HUB_QUOTE and HUB_PROPOSAL both keyed by QUOTE_REF_NO on some Health tables).
-- This load does no joins.

with source_data as (

    select * from {{ ref('int_health__hub_proposal') }}

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PROPOSAL'", 'business_key']) }} as proposal_hkey,
        business_key as proposal_bk,
        record_source,
        current_timestamp() as load_dts
    from source_data

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by proposal_hkey order by record_source) = 1

)

select proposal_hkey, proposal_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where proposal_hkey not in (select proposal_hkey from {{ this }})
{% endif %}
