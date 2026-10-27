{{ config(materialized='view') }}

-- UNPIVOT for SAT_COMMON_CONTACT from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
-- one row PER INSTANCE: 12 branch(es).
--
-- Each branch below is ONE instance of the satellite, carrying all of its own
-- attributes on a single row and discriminated by CONTACT_POINT_TYPE, CONTACT_PRIORITY_ORDER.
-- The hash is taken once, downstream, by stg2_mtv2_up__clm_clmd_clmap_pv__sat_common_contact.
--
-- Payload is null-padded to the SATELLITE's full payload (9 column(s)), not to this
-- feeder's columns, so every feeder of SAT_COMMON_CONTACT is union-compatible (BUILD_RULES 6).
--
-- Instances on this view:
--   email_1                                  1 attribute(s)
--   email_communication_1                    1 attribute(s)
--   email_insured_1                          1 attribute(s)
--   email_key_contact_1                      1 attribute(s)
--   landline_1                               1 attribute(s)
--   mobile_1                                 1 attribute(s)
--   mobile_alternate_1                       2 attribute(s)
--   mobile_communication_1                   1 attribute(s)
--   mobile_insured_1                         1 attribute(s)
--   mobile_insured_contact_1                 1 attribute(s)
--   mobile_key_contact_1                     1 attribute(s)
--   mobile_registered_1                      1 attribute(s)

    select
        nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),'') as PARTY_BK__CLAIMANT_CUSTOMER,
        'EMAIL' as CONTACT_POINT_TYPE,
        '1' as CONTACT_PRIORITY_ORDER,
        cast(null as varchar) as ALTERNATE_EMAIL_ADDRESS,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as CONTACT_POINT_USAGE,
        email as EMAIL_ADDRESS,
        cast(null as varchar) as FAX_NUMBER,
        cast(null as varchar) as LANDLINE_NUMBER,
        cast(null as varchar) as MOBILE_NUMBER,
        cast(null as varchar) as SOCIAL_MEDIA_HANDLE,
        cast(null as varchar) as STD_CODE,
        'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where email is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),'') as PARTY_BK__CLAIMANT_CUSTOMER,
        'EMAIL_COMMUNICATION' as CONTACT_POINT_TYPE,
        '1' as CONTACT_PRIORITY_ORDER,
        cast(null as varchar) as ALTERNATE_EMAIL_ADDRESS,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as CONTACT_POINT_USAGE,
        communication_email_id as EMAIL_ADDRESS,
        cast(null as varchar) as FAX_NUMBER,
        cast(null as varchar) as LANDLINE_NUMBER,
        cast(null as varchar) as MOBILE_NUMBER,
        cast(null as varchar) as SOCIAL_MEDIA_HANDLE,
        cast(null as varchar) as STD_CODE,
        'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where communication_email_id is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),'') as PARTY_BK__CLAIMANT_CUSTOMER,
        'EMAIL_INSURED' as CONTACT_POINT_TYPE,
        '1' as CONTACT_PRIORITY_ORDER,
        cast(null as varchar) as ALTERNATE_EMAIL_ADDRESS,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as CONTACT_POINT_USAGE,
        insured_email_id as EMAIL_ADDRESS,
        cast(null as varchar) as FAX_NUMBER,
        cast(null as varchar) as LANDLINE_NUMBER,
        cast(null as varchar) as MOBILE_NUMBER,
        cast(null as varchar) as SOCIAL_MEDIA_HANDLE,
        cast(null as varchar) as STD_CODE,
        'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where insured_email_id is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(unique_customer_id),''), nullif(trim(customerid),'')) is not null then coalesce(nullif(trim(unique_customer_id), ''), nullif(trim(customerid), '')) end),'') as PARTY_BK__INSURED_CUSTOMER,
        'EMAIL_KEY_CONTACT' as CONTACT_POINT_TYPE,
        '1' as CONTACT_PRIORITY_ORDER,
        cast(null as varchar) as ALTERNATE_EMAIL_ADDRESS,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as CONTACT_POINT_USAGE,
        key_email_id as EMAIL_ADDRESS,
        cast(null as varchar) as FAX_NUMBER,
        cast(null as varchar) as LANDLINE_NUMBER,
        cast(null as varchar) as MOBILE_NUMBER,
        cast(null as varchar) as SOCIAL_MEDIA_HANDLE,
        cast(null as varchar) as STD_CODE,
        'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where key_email_id is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(unique_customer_id),''), nullif(trim(customerid),'')) is not null then coalesce(nullif(trim(unique_customer_id), ''), nullif(trim(customerid), '')) end),'') as PARTY_BK__INSURED_CUSTOMER,
        'LANDLINE' as CONTACT_POINT_TYPE,
        '1' as CONTACT_PRIORITY_ORDER,
        cast(null as varchar) as ALTERNATE_EMAIL_ADDRESS,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as CONTACT_POINT_USAGE,
        cast(null as varchar) as EMAIL_ADDRESS,
        cast(null as varchar) as FAX_NUMBER,
        telephone_number as LANDLINE_NUMBER,
        cast(null as varchar) as MOBILE_NUMBER,
        cast(null as varchar) as SOCIAL_MEDIA_HANDLE,
        cast(null as varchar) as STD_CODE,
        'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where telephone_number is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(unique_customer_id),''), nullif(trim(customerid),'')) is not null then coalesce(nullif(trim(unique_customer_id), ''), nullif(trim(customerid), '')) end),'') as PARTY_BK__INSURED_CUSTOMER,
        'MOBILE' as CONTACT_POINT_TYPE,
        '1' as CONTACT_PRIORITY_ORDER,
        cast(null as varchar) as ALTERNATE_EMAIL_ADDRESS,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as CONTACT_POINT_USAGE,
        cast(null as varchar) as EMAIL_ADDRESS,
        cast(null as varchar) as FAX_NUMBER,
        cast(null as varchar) as LANDLINE_NUMBER,
        mobile_number as MOBILE_NUMBER,
        cast(null as varchar) as SOCIAL_MEDIA_HANDLE,
        cast(null as varchar) as STD_CODE,
        'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where mobile_number is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),'') as PARTY_BK__CLAIMANT_CUSTOMER,
        'MOBILE_ALTERNATE' as CONTACT_POINT_TYPE,
        '1' as CONTACT_PRIORITY_ORDER,
        cast(null as varchar) as ALTERNATE_EMAIL_ADDRESS,
        alternate_mobile_numberclaims as ALTERNATE_MOBILE_NUMBER,
        alternate_mobile_number_belongs_to as CONTACT_POINT_USAGE,
        cast(null as varchar) as EMAIL_ADDRESS,
        cast(null as varchar) as FAX_NUMBER,
        cast(null as varchar) as LANDLINE_NUMBER,
        cast(null as varchar) as MOBILE_NUMBER,
        cast(null as varchar) as SOCIAL_MEDIA_HANDLE,
        cast(null as varchar) as STD_CODE,
        'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where alternate_mobile_number_belongs_to is not null or alternate_mobile_numberclaims is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),'') as PARTY_BK__CLAIMANT_CUSTOMER,
        'MOBILE_COMMUNICATION' as CONTACT_POINT_TYPE,
        '1' as CONTACT_PRIORITY_ORDER,
        cast(null as varchar) as ALTERNATE_EMAIL_ADDRESS,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as CONTACT_POINT_USAGE,
        cast(null as varchar) as EMAIL_ADDRESS,
        cast(null as varchar) as FAX_NUMBER,
        cast(null as varchar) as LANDLINE_NUMBER,
        communication_contact_number as MOBILE_NUMBER,
        cast(null as varchar) as SOCIAL_MEDIA_HANDLE,
        cast(null as varchar) as STD_CODE,
        'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where communication_contact_number is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),'') as PARTY_BK__CLAIMANT_CUSTOMER,
        'MOBILE_INSURED' as CONTACT_POINT_TYPE,
        '1' as CONTACT_PRIORITY_ORDER,
        cast(null as varchar) as ALTERNATE_EMAIL_ADDRESS,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as CONTACT_POINT_USAGE,
        cast(null as varchar) as EMAIL_ADDRESS,
        cast(null as varchar) as FAX_NUMBER,
        cast(null as varchar) as LANDLINE_NUMBER,
        insured_mobile_number as MOBILE_NUMBER,
        cast(null as varchar) as SOCIAL_MEDIA_HANDLE,
        cast(null as varchar) as STD_CODE,
        'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where insured_mobile_number is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),'') as PARTY_BK__CLAIMANT_CUSTOMER,
        'MOBILE_INSURED_CONTACT' as CONTACT_POINT_TYPE,
        '1' as CONTACT_PRIORITY_ORDER,
        cast(null as varchar) as ALTERNATE_EMAIL_ADDRESS,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as CONTACT_POINT_USAGE,
        cast(null as varchar) as EMAIL_ADDRESS,
        cast(null as varchar) as FAX_NUMBER,
        cast(null as varchar) as LANDLINE_NUMBER,
        insured_contact_number as MOBILE_NUMBER,
        cast(null as varchar) as SOCIAL_MEDIA_HANDLE,
        cast(null as varchar) as STD_CODE,
        'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where insured_contact_number is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),'') as PARTY_BK__CLAIMANT_CUSTOMER,
        'MOBILE_KEY_CONTACT' as CONTACT_POINT_TYPE,
        '1' as CONTACT_PRIORITY_ORDER,
        cast(null as varchar) as ALTERNATE_EMAIL_ADDRESS,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as CONTACT_POINT_USAGE,
        cast(null as varchar) as EMAIL_ADDRESS,
        cast(null as varchar) as FAX_NUMBER,
        cast(null as varchar) as LANDLINE_NUMBER,
        key_contact_number as MOBILE_NUMBER,
        cast(null as varchar) as SOCIAL_MEDIA_HANDLE,
        cast(null as varchar) as STD_CODE,
        'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where key_contact_number is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(unique_customer_id),''), nullif(trim(customerid),'')) is not null then coalesce(nullif(trim(unique_customer_id), ''), nullif(trim(customerid), '')) end),'') as PARTY_BK__INSURED_CUSTOMER,
        'MOBILE_REGISTERED' as CONTACT_POINT_TYPE,
        '1' as CONTACT_PRIORITY_ORDER,
        cast(null as varchar) as ALTERNATE_EMAIL_ADDRESS,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as CONTACT_POINT_USAGE,
        cast(null as varchar) as EMAIL_ADDRESS,
        cast(null as varchar) as FAX_NUMBER,
        cast(null as varchar) as LANDLINE_NUMBER,
        registered_mobile_number as MOBILE_NUMBER,
        cast(null as varchar) as SOCIAL_MEDIA_HANDLE,
        cast(null as varchar) as STD_CODE,
        'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where registered_mobile_number is not null
