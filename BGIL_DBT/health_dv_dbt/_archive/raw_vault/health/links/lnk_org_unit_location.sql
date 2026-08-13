{{
    config(
        materialized='incremental',
        unique_key='org_unit_location_hkey'
    )
}}

-- Link: LNK_ORG_UNIT_LOCATION (Org Unit Location) -- Associative
-- Associates an organisation unit with its physical location.
-- Single contributing source table: no intermediate view created (collapsed).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select location_bk, org_unit_bk, record_source
    from (
    select distinct
        risk_location as location_bk,
        company_org_unit as org_unit_bk,
        'BJAZ_EHH_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ehh_pol_dtls') }}
    where risk_location is not null and company_org_unit is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_LOCATION'", 'location_bk']) }} as location_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_ORG_UNIT'", 'org_unit_bk']) }} as org_unit_hkey,
        location_bk, org_unit_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_ORG_UNIT_LOCATION'", 'location_hkey', 'org_unit_hkey']) }} as org_unit_location_hkey,
        location_hkey, location_bk, org_unit_hkey, org_unit_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by org_unit_location_hkey order by record_source) = 1

)

select org_unit_location_hkey, location_hkey, location_bk, org_unit_hkey, org_unit_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where org_unit_location_hkey not in (select org_unit_location_hkey from {{ this }})
{% endif %}
