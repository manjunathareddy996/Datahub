{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_CLAIM_COMMUNICATION
-- Parent: HUB_CLAIM
-- Multi-active grain key: Communication Date
-- Single contributing source table: no intermediate view created (collapsed). No joins in THIS load.

with source_data as (

    select parent_bk, communication_date_ck, communication_date, subject, record_source
    from (
        select distinct
            bjaz_claim_id as parent_bk,
            nullif(trim(to_varchar(insured_disc_date)), '') as communication_date_ck,
            nullif(trim(to_varchar(insured_disc_date)), '') as communication_date,
            nullif(trim(to_varchar(disc_datails)), '') as subject,
            'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
        from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
        where bjaz_claim_id is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CLAIM'", 'parent_bk']) }} as claim_hkey,
        parent_bk, communication_date_ck,
        communication_date, subject,
        record_source
    from source_data

),

hashed as (

    select
        claim_hkey,
        communication_date_ck,
        communication_date, subject,
        {{ dbt_utils.generate_surrogate_key(['communication_date', 'subject']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by claim_hkey, communication_date_ck, hashdiff
        order by record_source
    ) = 1

)

select
    claim_hkey,
    communication_date_ck,
        communication_date, subject,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.claim_hkey = d.claim_hkey and t.communication_date_ck = d.communication_date_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
