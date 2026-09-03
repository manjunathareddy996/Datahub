{{ config(materialized='view') }}

-- UNPIVOT for SAT_PARTY_CONTACT_ADDRESS_LINK from BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1
-- 2 row(s), ONE PER INSTANCE of ADDRESS_USAGE_TYPE.
-- The instance label is the mapper's own child_key_value, which keeps this in the
-- vocabulary partner_dv_dbt already writes.

    select
        foreign_key as parent_bk,
        'COMMUNICATION' as address_usage_type,
        cast(null as varchar) as addressusagetype,
        is_the_mailingcommunication_address_same_as_the_primary_address as primaryaddressindicator,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(is_the_mailingcommunication_address_same_as_the_primary_address)), '') is not null
    union all
    select
        foreign_key as parent_bk,
        '{CURRENT_PERMANENT_OVERSEAS_ADDRESS_TYPE}' as address_usage_type,
        current_permanent_overseas_address_type as addressusagetype,
        cast(null as varchar) as primaryaddressindicator,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(current_permanent_overseas_address_type)), '') is not null
