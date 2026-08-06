{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_PROPOSAL_UNDERWRITING
-- Parent: HUB_PROPOSAL
-- Multi-active grain key: none (single-active)
-- Single contributing source table: no intermediate view created (collapsed). No joins in THIS load.

with source_data as (

    select parent_bk, medical_required_indicator, record_source
    from (
        select distinct
            quote_ref_no as parent_bk,
            nullif(trim(to_varchar(nme_waiver)), '') as medical_required_indicator,
            'BJAZ_GRP_HLT_DTLS' as record_source
        from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
        where quote_ref_no is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PROPOSAL'", 'parent_bk']) }} as proposal_hkey,
        parent_bk,
        medical_required_indicator,
        record_source
    from source_data

),

hashed as (

    select
        proposal_hkey,
        medical_required_indicator,
        {{ dbt_utils.generate_surrogate_key(['medical_required_indicator']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by proposal_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    proposal_hkey,
    medical_required_indicator,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.proposal_hkey = d.proposal_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
