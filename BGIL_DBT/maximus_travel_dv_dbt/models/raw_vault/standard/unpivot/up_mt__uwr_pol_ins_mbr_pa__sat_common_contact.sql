{{ config(materialized='view') }}

-- UNPIVOT for SAT_COMMON_CONTACT from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_ADDRESS
-- one row PER INSTANCE: 7 branch(es).
--
-- Each branch below is ONE instance of the satellite, carrying all of its own
-- attributes on a single row and discriminated by CONTACT_POINT_TYPE, CONTACT_PRIORITY_ORDER.
-- The hash is taken once, downstream, by stg2_mt_up__uwr_pol_ins_mbr_pa__sat_common_contact.
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

-- INCREMENTAL VIEW: returns only rows whose REC_REFRESH_AT is after the latest
-- LOAD_DATETIME this feeder already wrote to SAT_COMMON_CONTACT.
--   Incremental (default):  dbt run -s +sat_common_contact
--   Full load:              dbt run -s +sat_common_contact --vars '{full_load: true}'
--   (--full-refresh, or SAT_COMMON_CONTACT not existing yet, also gives full data)

{%- set sat_rel = adapter.get_relation(database=this.database, schema=this.schema, identifier='SAT_COMMON_CONTACT') if execute else none %}
{%- set is_full_load = var('full_load', false) or flags.FULL_REFRESH or sat_rel is none %}

with src as (
    select *
    from {{ ref('resolved_mt__uwr_pol_ins_mbr_pa') }}
    {%- if not is_full_load %}
    where try_to_timestamp_ntz(to_varchar(rec_refresh_at)) > (
        select coalesce(max(try_to_timestamp_ntz(to_varchar(LOAD_DATETIME))), '1900-01-01'::timestamp_ntz)
        from {{ sat_rel }}
        where RECORD_SOURCE = 'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_ADDRESS'
    )
    {%- endif %}
)

    select
        nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__INSURED_MEMBER,
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
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_ADDRESS' as record_source
    from src
    where email_id is not null
union all
    select
        nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__INSURED_MEMBER,
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
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_ADDRESS' as record_source
    from src
    where alternate_email_id is not null
union all
    select
        nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__INSURED_MEMBER,
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
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_ADDRESS' as record_source
    from src
    where fax is not null
union all
    select
        nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__INSURED_MEMBER,
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
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_ADDRESS' as record_source
    from src
    where landline_no is not null or std_code is not null
union all
    select
        nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__INSURED_MEMBER,
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
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_ADDRESS' as record_source
    from src
    where phone_no is not null
union all
    select
        nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__INSURED_MEMBER,
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
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_ADDRESS' as record_source
    from src
    where work_no is not null
union all
    select
        nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__INSURED_MEMBER,
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
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_ADDRESS' as record_source
    from src
    where mobile_no is not null
