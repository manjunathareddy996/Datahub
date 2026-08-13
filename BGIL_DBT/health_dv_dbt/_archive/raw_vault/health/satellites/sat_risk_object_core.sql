{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_RISK_OBJECT_CORE
-- Parent: HUB_RISK_OBJECT
-- Multi-active grain key: none (single-active)
-- Single contributing source table: no intermediate view created (collapsed). No joins in THIS load.

with source_data as (

    select parent_bk, risk_class_code, risk_object_description, record_source
    from (
        select distinct
            pol_serial_no || '|' || md_seq_no as parent_bk,
            nullif(trim(to_varchar(mlc_risk_class)), '') as risk_class_code,
            cast(null as varchar) as risk_object_description,
            'BA_HCP_PROD_8428_GPG_LOADER' as record_source
        from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
        where pol_serial_no is not null and md_seq_no is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_RISK_OBJECT'", 'parent_bk']) }} as risk_object_hkey,
        parent_bk,
        risk_class_code, risk_object_description,
        record_source
    from source_data

),

hashed as (

    select
        risk_object_hkey,
        risk_class_code, risk_object_description,
        {{ dbt_utils.generate_surrogate_key(['risk_class_code', 'risk_object_description']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by risk_object_hkey, hashdiff
        order by record_source
    ) = 1

)

select
    risk_object_hkey,
    risk_class_code, risk_object_description,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.risk_object_hkey = d.risk_object_hkey
      and t.hashdiff = d.hashdiff
)
{% endif %}
