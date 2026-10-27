{{ config(materialized='view') }}

-- UNPIVOT for SAT_COMMON_CONTACT from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS
-- one row PER INSTANCE: 7 branch(es).
--
-- Each branch below is ONE instance of the satellite, carrying all of its own
-- attributes on a single row and discriminated by CONTACT_POINT_TYPE, CONTACT_PRIORITY_ORDER.
-- The hash is taken once, downstream, by stg2_mtv2_up__uwr_pol_prp_pa__sat_common_contact.
--
-- Payload is null-padded to the SATELLITE's full payload (9 column(s)), not to this
-- feeder's columns, so every feeder of SAT_COMMON_CONTACT is union-compatible (BUILD_RULES 6).
--
-- Instances on this view:
--   email_1                                  1 attribute(s)
--   email_alternate_1                        1 attribute(s)
--   fax_1                                    1 attribute(s)
--   landline_1                               2 attribute(s)
--   landline_phone_1                         1 attribute(s)
--   landline_work_1                          1 attribute(s)
--   mobile_1                                 1 attribute(s)

    select
        nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__PROPOSER,
        'EMAIL' as CONTACT_POINT_TYPE,
        '1' as CONTACT_PRIORITY_ORDER,
        cast(null as varchar) as ALTERNATE_EMAIL_ADDRESS,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as CONTACT_POINT_USAGE,
        email_id as EMAIL_ADDRESS,
        cast(null as varchar) as FAX_NUMBER,
        cast(null as varchar) as LANDLINE_NUMBER,
        cast(null as varchar) as MOBILE_NUMBER,
        cast(null as varchar) as SOCIAL_MEDIA_HANDLE,
        cast(null as varchar) as STD_CODE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_prp_pa') }}
    where email_id is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__PROPOSER,
        'EMAIL_ALTERNATE' as CONTACT_POINT_TYPE,
        '1' as CONTACT_PRIORITY_ORDER,
        alternate_email_id as ALTERNATE_EMAIL_ADDRESS,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as CONTACT_POINT_USAGE,
        cast(null as varchar) as EMAIL_ADDRESS,
        cast(null as varchar) as FAX_NUMBER,
        cast(null as varchar) as LANDLINE_NUMBER,
        cast(null as varchar) as MOBILE_NUMBER,
        cast(null as varchar) as SOCIAL_MEDIA_HANDLE,
        cast(null as varchar) as STD_CODE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_prp_pa') }}
    where alternate_email_id is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__PROPOSER,
        'FAX' as CONTACT_POINT_TYPE,
        '1' as CONTACT_PRIORITY_ORDER,
        cast(null as varchar) as ALTERNATE_EMAIL_ADDRESS,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as CONTACT_POINT_USAGE,
        cast(null as varchar) as EMAIL_ADDRESS,
        fax as FAX_NUMBER,
        cast(null as varchar) as LANDLINE_NUMBER,
        cast(null as varchar) as MOBILE_NUMBER,
        cast(null as varchar) as SOCIAL_MEDIA_HANDLE,
        cast(null as varchar) as STD_CODE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_prp_pa') }}
    where fax is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__PROPOSER,
        'LANDLINE' as CONTACT_POINT_TYPE,
        '1' as CONTACT_PRIORITY_ORDER,
        cast(null as varchar) as ALTERNATE_EMAIL_ADDRESS,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as CONTACT_POINT_USAGE,
        cast(null as varchar) as EMAIL_ADDRESS,
        cast(null as varchar) as FAX_NUMBER,
        landline_no as LANDLINE_NUMBER,
        cast(null as varchar) as MOBILE_NUMBER,
        cast(null as varchar) as SOCIAL_MEDIA_HANDLE,
        std_code as STD_CODE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_prp_pa') }}
    where landline_no is not null or std_code is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__PROPOSER,
        'LANDLINE_PHONE' as CONTACT_POINT_TYPE,
        '1' as CONTACT_PRIORITY_ORDER,
        cast(null as varchar) as ALTERNATE_EMAIL_ADDRESS,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as CONTACT_POINT_USAGE,
        cast(null as varchar) as EMAIL_ADDRESS,
        cast(null as varchar) as FAX_NUMBER,
        phone_no as LANDLINE_NUMBER,
        cast(null as varchar) as MOBILE_NUMBER,
        cast(null as varchar) as SOCIAL_MEDIA_HANDLE,
        cast(null as varchar) as STD_CODE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_prp_pa') }}
    where phone_no is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__PROPOSER,
        'LANDLINE_WORK' as CONTACT_POINT_TYPE,
        '1' as CONTACT_PRIORITY_ORDER,
        cast(null as varchar) as ALTERNATE_EMAIL_ADDRESS,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as CONTACT_POINT_USAGE,
        cast(null as varchar) as EMAIL_ADDRESS,
        cast(null as varchar) as FAX_NUMBER,
        work_no as LANDLINE_NUMBER,
        cast(null as varchar) as MOBILE_NUMBER,
        cast(null as varchar) as SOCIAL_MEDIA_HANDLE,
        cast(null as varchar) as STD_CODE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_prp_pa') }}
    where work_no is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__PROPOSER,
        'MOBILE' as CONTACT_POINT_TYPE,
        '1' as CONTACT_PRIORITY_ORDER,
        cast(null as varchar) as ALTERNATE_EMAIL_ADDRESS,
        cast(null as varchar) as ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as CONTACT_POINT_USAGE,
        cast(null as varchar) as EMAIL_ADDRESS,
        cast(null as varchar) as FAX_NUMBER,
        cast(null as varchar) as LANDLINE_NUMBER,
        mobile_no as MOBILE_NUMBER,
        cast(null as varchar) as SOCIAL_MEDIA_HANDLE,
        cast(null as varchar) as STD_CODE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_prp_pa') }}
    where mobile_no is not null
