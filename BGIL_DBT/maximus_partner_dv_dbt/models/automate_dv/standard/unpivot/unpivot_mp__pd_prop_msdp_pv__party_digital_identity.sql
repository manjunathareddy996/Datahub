{{ config(materialized='view') }}

-- UNPIVOT for SAT_PARTY_DIGITAL_IDENTITY from BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW_2_1
-- 1 row(s), ONE PER INSTANCE of ACTIVESEQUENCENUMBER.
-- The instance label is the mapper's own child_key_value, which keeps this in the
-- vocabulary partner_dv_dbt already writes.

    select
        foreign_key as parent_bk,
        '{USER_ID}' as activesequencenumber,
        user_id as loginidentifier,
        'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW_2_1' as record_source
    from {{ ref('stg_maximus__pd_prop_msdp_pv') }}
    where nullif(trim(to_varchar(user_id)), '') is not null
