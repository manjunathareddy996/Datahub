{{ config(materialized='view') }}

-- AUGMENTED instance fan-out for SAT_AUG_ORG_UNIT_CONTACT from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
-- 6 branch(es): a column-as-instance family on the unratified track.
--
-- Payload null-padded to the SATELLITE, not to a branch (BUILD_RULES 6).

    select
        nullif(trim(case when coalesce(nullif(trim(w6_office_code),'')) is not null then 'ORGUNIT:' || nullif(trim(w6_office_code), '') end),'') as ORG_UNIT_BK,
        'LANDLINE' as CONTACT_POINT_TYPE,
        alternate_mob_numberlandline_number as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as MOBILE_NUMBER,
        cast(null as varchar) as SOCIAL_MEDIA_HANDLE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_off_oa_address_prop_pv') }}
    where alternate_mob_numberlandline_number is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w6_office_code),'')) is not null then 'ORGUNIT:' || nullif(trim(w6_office_code), '') end),'') as ORG_UNIT_BK,
        'MOBILE_WHATSAPP' as CONTACT_POINT_TYPE,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        whatsapp_no as MOBILE_NUMBER,
        cast(null as varchar) as SOCIAL_MEDIA_HANDLE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_off_oa_address_prop_pv') }}
    where whatsapp_no is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w6_office_code),'')) is not null then 'ORGUNIT:' || nullif(trim(w6_office_code), '') end),'') as ORG_UNIT_BK,
        'SOCIAL_FACEBOOK' as CONTACT_POINT_TYPE,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as MOBILE_NUMBER,
        facebook_id as SOCIAL_MEDIA_HANDLE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_off_oa_address_prop_pv') }}
    where facebook_id is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w6_office_code),'')) is not null then 'ORGUNIT:' || nullif(trim(w6_office_code), '') end),'') as ORG_UNIT_BK,
        'SOCIAL_INSTAGRAM' as CONTACT_POINT_TYPE,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as MOBILE_NUMBER,
        instagram_id as SOCIAL_MEDIA_HANDLE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_off_oa_address_prop_pv') }}
    where instagram_id is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w6_office_code),'')) is not null then 'ORGUNIT:' || nullif(trim(w6_office_code), '') end),'') as ORG_UNIT_BK,
        'SOCIAL_LINKEDIN' as CONTACT_POINT_TYPE,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as MOBILE_NUMBER,
        linked_in_id as SOCIAL_MEDIA_HANDLE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_off_oa_address_prop_pv') }}
    where linked_in_id is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w6_office_code),'')) is not null then 'ORGUNIT:' || nullif(trim(w6_office_code), '') end),'') as ORG_UNIT_BK,
        'SOCIAL_TWITTER' as CONTACT_POINT_TYPE,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as MOBILE_NUMBER,
        twitter_id as SOCIAL_MEDIA_HANDLE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_off_oa_address_prop_pv') }}
    where twitter_id is not null
