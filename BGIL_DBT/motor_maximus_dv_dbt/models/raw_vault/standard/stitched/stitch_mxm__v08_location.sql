-- CENTRAL VIEW v08_location -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_DISPATCH_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS_ADDRESS_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS_ADDRESS_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_MOTOR_AUG_COMMON_ADDRESS
--   SAT_MOTOR_AUG_COMMON_GEO
--   SAT_MOTOR_AUG_ORG_UNIT_CONTACT
--   SAT_COMMON_ADDRESS
--   SAT_COMMON_CONTACT
--   SAT_COMMON_GEO
--   SAT_LOCATION_PROFILE
--   SAT_PARTY_CONTACT_ADDRESS_LINK
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_PARTY_LOCATION
-- OVER the table limit by rule 3: one satellite on this view needs every feeding table.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim( coalesce(t0.city,'') || '|' || coalesce(t0.state,'') || '|' || coalesce(t0.pin_code,'') ), '||')))), '') as LOCATION_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        cast(null as number) as __LNK_PARTY_LOCATION,
        cast(null as varchar) as AUG_COMMON_ADDRESS__CITY_CODE,
        cast(null as varchar) as AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT,
        cast(null as varchar) as AUG_COMMON_GEO__ALTITUDE,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__CONTACT_POINT_TYPE_CK,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__FAX_NUMBER,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__MOBILE_NUMBER,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__SOCIAL_MEDIA_HANDLE,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__STD_CODE,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__WHATSAPP_NUMBER,
        cast(null as varchar) as COMMON_ADDRESS__ADDRESS_LINE_1,
        cast(null as varchar) as COMMON_ADDRESS__ADDRESS_LINE_2,
        cast(null as varchar) as COMMON_ADDRESS__ADDRESS_LINE_3,
        cast(null as varchar) as COMMON_ADDRESS__ADDRESS_SOURCE_INDICATOR,
        cast(null as varchar) as COMMON_ADDRESS__ADDRESS_TYPE_CODE,
        cast(null as varchar) as COMMON_ADDRESS__CARE_OF_NAME,
        t0.city as COMMON_ADDRESS__CITY,
        cast(null as varchar) as COMMON_ADDRESS__COUNTRY_CODE,
        cast(null as varchar) as COMMON_ADDRESS__COUNTRY_NAME,
        cast(null as varchar) as COMMON_ADDRESS__DISTRICT,
        cast(null as varchar) as COMMON_ADDRESS__LANDMARK,
        cast(null as varchar) as COMMON_ADDRESS__LOCALITY,
        t0.pin_code as COMMON_ADDRESS__POSTAL_CODE,
        cast(null as varchar) as COMMON_ADDRESS__POST_OFFICE_NAME,
        cast(null as varchar) as COMMON_ADDRESS__STATE_CODE,
        t0.state as COMMON_ADDRESS__STATE_NAME,
        cast(null as varchar) as COMMON_ADDRESS__STREET_NAME,
        cast(null as varchar) as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        cast(null as varchar) as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        cast(null as varchar) as COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS,
        cast(null as varchar) as COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as COMMON_CONTACT__CONTACT_POINT_USAGE,
        cast(null as varchar) as COMMON_CONTACT__EMAIL_ADDRESS,
        cast(null as varchar) as COMMON_CONTACT__FAX_NUMBER,
        cast(null as varchar) as COMMON_CONTACT__LANDLINE_NUMBER,
        cast(null as varchar) as COMMON_CONTACT__MOBILE_NUMBER,
        cast(null as varchar) as COMMON_CONTACT__SOCIAL_MEDIA_HANDLE,
        cast(null as varchar) as COMMON_CONTACT__STD_CODE,
        cast(null as varchar) as COMMON_GEO__LATITUDE,
        cast(null as varchar) as COMMON_GEO__LONGITUDE,
        cast(null as varchar) as COMMON_GEO__ZONE_CODE,
        cast(null as varchar) as LOCATION_PROFILE__LOCATION_NAME,
        cast(null as varchar) as LOCATION_PROFILE__LOCATION_TYPE,
        cast(null as varchar) as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
        cast(null as varchar) as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_PROOF_TYPE,
        cast(null as varchar) as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_msp_msd_prop_pv') }} t0
    where (nullif(md5(normalise(upper(nullif(trim( coalesce(t0.city,'') || '|' || coalesce(t0.state,'') || '|' || coalesce(t0.pin_code,'') ), '||')))), '')) is not null

    union all

    -- branch 1: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim(t0.address_for_reference),'')))), '') as LOCATION_BK,
        null,
        nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.address_for_reference as COMMON_ADDRESS__ADDRESS_LINE_1,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'MOBILE_ALTERNATE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null,
        t0.alternate_mobile_numberclaims as COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER,
        t0.alternate_mobile_number_belongs_to as COMMON_CONTACT__CONTACT_POINT_USAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    where (coalesce(nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), ''), nullif(md5(normalise(upper(nullif(trim(t0.address_for_reference),'')))), ''))) is not null

    union all

    -- branch 2: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim(coalesce(t0.street,'') || '|' || coalesce(t0.areaclaim,'') || '|' || coalesce(t0.landmark,'') || '|' || coalesce(t0.city,'') || '|' || coalesce(t0.state,'') || '|' || coalesce(t0.stateclaim,'') || '|' || coalesce(t0.pin_code,'')),'||||||')))), '') as LOCATION_BK,
        null,
        nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.city as COMMON_ADDRESS__CITY,
        null, null, null,
        t0.landmark as COMMON_ADDRESS__LANDMARK,
        t0.areaclaim as COMMON_ADDRESS__LOCALITY,
        t0.pin_code as COMMON_ADDRESS__POSTAL_CODE,
        null, null,
        t0.state as COMMON_ADDRESS__STATE_NAME,
        t0.street as COMMON_ADDRESS__STREET_NAME,
        'EMAIL_CALLER' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null,
        t0.caller_email_id as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    where (coalesce(nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), ''), nullif(md5(normalise(upper(nullif(trim(coalesce(t0.street,'') || '|' || coalesce(t0.areaclaim,'') || '|' || coalesce(t0.landmark,'') || '|' || coalesce(t0.city,'') || '|' || coalesce(t0.state,'') || '|' || coalesce(t0.stateclaim,'') || '|' || coalesce(t0.pin_code,'')),'||||||')))), ''))) is not null

    union all

    -- branch 3: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim(coalesce(t0.street_attribute,'') || '|' || coalesce(t0.area_attribute,'') || '|' || coalesce(t0.landmark_attribute,'') || '|' || coalesce(t0.city_attribute,'') || '|' || coalesce(t0.state_attribute,'') || '|' || coalesce(t0.pin_code_attribute,'') || '|' || coalesce(t0.correspondence_address_attribute,'')),'||||||')))), '') as LOCATION_BK,
        null,
        nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.correspondence_address_attribute as COMMON_ADDRESS__ADDRESS_LINE_1,
        null, null, null, null, null,
        t0.city_attribute as COMMON_ADDRESS__CITY,
        null, null, null,
        t0.landmark_attribute as COMMON_ADDRESS__LANDMARK,
        t0.area_attribute as COMMON_ADDRESS__LOCALITY,
        t0.pin_code_attribute as COMMON_ADDRESS__POSTAL_CODE,
        null, null,
        t0.state_attribute as COMMON_ADDRESS__STATE_NAME,
        t0.street_attribute as COMMON_ADDRESS__STREET_NAME,
        'MOBILE_COMMUNICATION' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null, null, null,
        t0.communication_contact_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    where (coalesce(nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), ''), nullif(md5(normalise(upper(nullif(trim(coalesce(t0.street_attribute,'') || '|' || coalesce(t0.area_attribute,'') || '|' || coalesce(t0.landmark_attribute,'') || '|' || coalesce(t0.city_attribute,'') || '|' || coalesce(t0.state_attribute,'') || '|' || coalesce(t0.pin_code_attribute,'') || '|' || coalesce(t0.correspondence_address_attribute,'')),'||||||')))), ''))) is not null

    union all

    -- branch 4: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim(t0.correspondence_address),'')))), '') as LOCATION_BK,
        null,
        nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.correspondence_address as COMMON_ADDRESS__ADDRESS_LINE_1,
        null, null,
        t0.is_the_correspondence_address_is_same_as_mentioned_on_policy as COMMON_ADDRESS__ADDRESS_SOURCE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EMAIL_COMMUNICATION' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null,
        t0.communication_email_id as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    where (coalesce(nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), ''), nullif(md5(normalise(upper(nullif(trim(t0.correspondence_address),'')))), ''))) is not null

    union all

    -- branch 5: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim(coalesce(t0.country_of_loss,'') || '|' || coalesce(t0.latitude,'') || '|' || coalesce(t0.longitude,'')),'||')))), '') as LOCATION_BK,
        null,
        nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.country_of_loss as COMMON_ADDRESS__COUNTRY_NAME,
        null, null, null, null, null, null, null, null,
        'LANDLINE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null, null,
        t0.insured_contact_number as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null,
        t0.latitude as COMMON_GEO__LATITUDE,
        t0.longitude as COMMON_GEO__LONGITUDE,
        null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    where (coalesce(nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), ''), nullif(md5(normalise(upper(nullif(trim(coalesce(t0.country_of_loss,'') || '|' || coalesce(t0.latitude,'') || '|' || coalesce(t0.longitude,'')),'||')))), ''))) is not null

    union all

    -- branch 6: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim(coalesce(t0.workshop_address,'') || '|' || coalesce(t0.workshop_location,'') || '|' || coalesce(t0.workshop_city,'') || '|' || coalesce(t0.workshop_state,'') || '|' || coalesce(t0.state_workshop,'') || '|' || coalesce(t0.workshop_zone,'')),'|||||')))), '') as LOCATION_BK,
        null,
        nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.workshop_address as COMMON_ADDRESS__ADDRESS_LINE_1,
        null, null, null, null, null,
        t0.workshop_city as COMMON_ADDRESS__CITY,
        null, null, null, null,
        t0.workshop_location as COMMON_ADDRESS__LOCALITY,
        null, null, null,
        t0.workshop_state as COMMON_ADDRESS__STATE_NAME,
        null,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null,
        t0.insured_email_id as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null, null,
        t0.workshop_zone as COMMON_GEO__ZONE_CODE,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    where (coalesce(nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), ''), nullif(md5(normalise(upper(nullif(trim(coalesce(t0.workshop_address,'') || '|' || coalesce(t0.workshop_location,'') || '|' || coalesce(t0.workshop_city,'') || '|' || coalesce(t0.workshop_state,'') || '|' || coalesce(t0.state_workshop,'') || '|' || coalesce(t0.workshop_zone,'')),'|||||')))), ''))) is not null

    union all

    -- branch 7: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        null, null,
        nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null, null, null,
        t0.insured_mobile_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    where (nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '')) is not null

    union all

    -- branch 8: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        null, null,
        nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'MOBILE_KEY_CONTACT' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null, null, null,
        t0.key_contact_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    where (nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '')) is not null

    union all

    -- branch 9: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        null, null,
        nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'EMAIL_KEY_CONTACT' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null,
        t0.key_email_id as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    where (nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '')) is not null

    union all

    -- branch 10: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim(coalesce(t0.city,'') || '|' || coalesce(t0.state,'') || '|' || coalesce(t0.pin_code,'')), '||')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.city as COMMON_ADDRESS__CITY,
        null, null, null, null, null,
        t0.pin_code as COMMON_ADDRESS__POSTAL_CODE,
        null, null,
        t0.state as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_cover_msd_prop_pv') }} t0
    where (nullif(md5(normalise(upper(nullif(trim(coalesce(t0.city,'') || '|' || coalesce(t0.state,'') || '|' || coalesce(t0.pin_code,'')), '||')))), '')) is not null

    union all

    -- branch 11: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim(t0.address), '')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.address as COMMON_ADDRESS__ADDRESS_LINE_1,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    where (nullif(md5(normalise(upper(nullif(trim(t0.address), '')))), '')) is not null

    union all

    -- branch 12: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim(t0.correspondence_address), '')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.correspondence_address as COMMON_ADDRESS__ADDRESS_LINE_1,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    where (nullif(md5(normalise(upper(nullif(trim(t0.correspondence_address), '')))), '')) is not null

    union all

    -- branch 13: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim( coalesce(t0.hospital_address,'') || '|' || coalesce(t0.hospital_country,'') ),'|')))), '') as LOCATION_BK,
        null,
        nullif(nullif(trim(t0.hospital_id),''), '') as PARTY_BK,
        null, null,
        t0.hospital_address as AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.hospital_country as COMMON_ADDRESS__COUNTRY_NAME,
        null, null, null, null, null, null, null, null,
        'LANDLINE_HOSPITAL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null, null,
        t0.hospital_contact_no as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_properties_pv') }} t0
    where (coalesce(nullif(md5(normalise(upper(nullif(trim( coalesce(t0.hospital_address,'') || '|' || coalesce(t0.hospital_country,'') ),'|')))), ''), nullif(nullif(trim(t0.hospital_id),''), ''))) is not null

    union all

    -- branch 14: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim(t0.city_name),'')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.city_name as COMMON_ADDRESS__CITY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_properties_pv') }} t0
    where (nullif(md5(normalise(upper(nullif(trim(t0.city_name),'')))), '')) is not null

    union all

    -- branch 15: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_DISPATCH_DETAILS
    select
        nullif(md5(normalise(upper(nullif(trim(coalesce(t0.address,'') || '|' || coalesce(t0.city,'') || '|' || coalesce(t0.district,'') || '|' || coalesce(t0.state,'') || '|' || coalesce(t0.pin_code,'')), '||||')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.address as COMMON_ADDRESS__ADDRESS_LINE_1,
        null, null, null, null, null,
        t0.city as COMMON_ADDRESS__CITY,
        null, null,
        t0.district as COMMON_ADDRESS__DISTRICT,
        null, null,
        t0.pin_code as COMMON_ADDRESS__POSTAL_CODE,
        null, null,
        t0.state as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_dispatch_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(trim(coalesce(t0.address,'') || '|' || coalesce(t0.city,'') || '|' || coalesce(t0.district,'') || '|' || coalesce(t0.state,'') || '|' || coalesce(t0.pin_code,'')), '||||')))), '')) is not null

    union all

    -- branch 16: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS
    select
        nullif(md5(normalise(upper(nullif(trim(coalesce(t0.address1,'') || '|' || coalesce(t0.address2,'') || '|' || coalesce(t0.address3,'') || '|' || coalesce(t0.city,'') || '|' || coalesce(t0.district,'') || '|' || coalesce(t0.state,'') || '|' || coalesce(t0.country,'') || '|' || coalesce(t0.pincode,'')), '|||||||')))), '') as LOCATION_BK,
        nullif(nullif(trim(j1.office_code),''), '') as ORG_UNIT_BK,
        null, null, null, null, null, null, null,
        coalesce(t0.alternate_email_id, t0.email_id) as AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS,
        t0.fax as AUG_ORG_UNIT_CONTACT__FAX_NUMBER,
        coalesce(t0.landline_no, t0.phone_no, t0.work_no) as AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER,
        t0.mobile_no as AUG_ORG_UNIT_CONTACT__MOBILE_NUMBER,
        null,
        t0.std_code as AUG_ORG_UNIT_CONTACT__STD_CODE,
        null,
        t0.address1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.address2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.address3 as COMMON_ADDRESS__ADDRESS_LINE_3,
        null,
        t0.address_type as COMMON_ADDRESS__ADDRESS_TYPE_CODE,
        null,
        t0.city as COMMON_ADDRESS__CITY,
        null,
        t0.country as COMMON_ADDRESS__COUNTRY_NAME,
        t0.district as COMMON_ADDRESS__DISTRICT,
        null, null,
        t0.pincode as COMMON_ADDRESS__POSTAL_CODE,
        null, null,
        t0.state as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_office_dtls_office_address') }} t0
    left join {{ ref('stg_mxm__uwr_pd_office_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(upper(nullif(trim(coalesce(t0.address1,'') || '|' || coalesce(t0.address2,'') || '|' || coalesce(t0.address3,'') || '|' || coalesce(t0.city,'') || '|' || coalesce(t0.district,'') || '|' || coalesce(t0.state,'') || '|' || coalesce(t0.country,'') || '|' || coalesce(t0.pincode,'')), '|||||||')))), ''), nullif(nullif(trim(j1.office_code),''), ''))) is not null

    union all

    -- branch 17: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim(coalesce(j2.address1, '') || '|' || coalesce(j2.address2, '') || '|' || coalesce(j2.address3, '') || '|' || coalesce(j2.city, '') || '|' || coalesce(j2.district, '') || '|' || coalesce(j2.state, '') || '|' || coalesce(j2.pincode, '') || '|' || coalesce(j2.country, '')), '|||||||')))), '') as LOCATION_BK,
        nullif(nullif(trim(j3.office_code), ''), '') as ORG_UNIT_BK,
        null, null, null, null,
        t0.geo_coordinate_altitude as AUG_COMMON_GEO__ALTITUDE,
        null,
        t0.alternate_mob_numberlandline_number as AUG_ORG_UNIT_CONTACT__ALTERNATE_MOBILE_NUMBER,
        null, null, null, null,
        coalesce(t0.facebook_id, t0.instagram_id, t0.linked_in_id, t0.twitter_id) as AUG_ORG_UNIT_CONTACT__SOCIAL_MEDIA_HANDLE,
        null,
        t0.whatsapp_no as AUG_ORG_UNIT_CONTACT__WHATSAPP_NUMBER,
        null, null, null, null, null, null, null, null, null, null,
        t0.land_mark as COMMON_ADDRESS__LANDMARK,
        t0.area as COMMON_ADDRESS__LOCALITY,
        null,
        t0.post_office as COMMON_ADDRESS__POST_OFFICE_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.geo_coordinate_latitude as COMMON_GEO__LATITUDE,
        t0.geo_coordinate_longitude as COMMON_GEO__LONGITUDE,
        null, null,
        t0.location_type as LOCATION_PROFILE__LOCATION_TYPE,
        null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_office_dtls_office_address_address_prop_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_office_dtls_office_address_address_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_office_dtls_office_address') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_office_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(upper(nullif(trim(coalesce(j2.address1, '') || '|' || coalesce(j2.address2, '') || '|' || coalesce(j2.address3, '') || '|' || coalesce(j2.city, '') || '|' || coalesce(j2.district, '') || '|' || coalesce(j2.state, '') || '|' || coalesce(j2.pincode, '') || '|' || coalesce(j2.country, '')), '|||||||')))), ''), nullif(nullif(trim(j3.office_code), ''), ''))) is not null

    union all

    -- branch 18: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim(t0.address_for_reference), '')))), '') as LOCATION_BK,
        null,
        nullif(nullif(trim(j3.policy_holder_code), ''), '') as PARTY_BK,
        null, null,
        t0.address_for_reference as AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'MOBILE_ALTERNATE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null,
        t0.alternate_mobile_numberclaims as COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(upper(nullif(trim(t0.address_for_reference), '')))), ''), nullif(nullif(trim(j3.policy_holder_code), ''), ''))) is not null

    union all

    -- branch 19: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim(coalesce(t0.city,'') || '|' || coalesce(t0.country,'') || '|' || coalesce(t0.pin_code,'')), '||')))), '') as LOCATION_BK,
        null,
        nullif(nullif(trim(j3.policy_holder_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.city as COMMON_ADDRESS__CITY,
        null,
        t0.country as COMMON_ADDRESS__COUNTRY_NAME,
        null, null, null, null, null, null, null, null,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null, null, null,
        t0.contact_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(upper(nullif(trim(coalesce(t0.city,'') || '|' || coalesce(t0.country,'') || '|' || coalesce(t0.pin_code,'')), '||')))), ''), nullif(nullif(trim(j3.policy_holder_code), ''), ''))) is not null

    union all

    -- branch 20: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim( coalesce(t0.landmark,'') || '|' || coalesce(t0.pin_code,'') || '|' || coalesce(t0.latitude,'') || '|' || coalesce(t0.longitude,'') ), '|||')))), '') as LOCATION_BK,
        null,
        nullif(nullif(trim(j3.policy_holder_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.landmark as COMMON_ADDRESS__LANDMARK,
        null,
        t0.pin_code as COMMON_ADDRESS__POSTAL_CODE,
        null, null, null, null,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null, null, null,
        t0.insured_contact_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null,
        t0.latitude as COMMON_GEO__LATITUDE,
        t0.longitude as COMMON_GEO__LONGITUDE,
        null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(upper(nullif(trim( coalesce(t0.landmark,'') || '|' || coalesce(t0.pin_code,'') || '|' || coalesce(t0.latitude,'') || '|' || coalesce(t0.longitude,'') ), '|||')))), ''), nullif(nullif(trim(j3.policy_holder_code), ''), ''))) is not null

    union all

    -- branch 21: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(t0.rta_code), ''), '') as LOCATION_BK,
        null,
        nullif(nullif(trim(j3.policy_holder_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rta_city as COMMON_ADDRESS__CITY,
        null, null, null, null, null, null, null, null, null, null,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null,
        t0.insured_email_id as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null,
        t0.rta_location as LOCATION_PROFILE__LOCATION_NAME,
        null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j3.policy_holder_code), ''), ''), nullif(nullif(trim(t0.rta_code), ''), ''))) is not null

    union all

    -- branch 22: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim( coalesce(t0.street,'') || '|' || coalesce(t0.landmark,'') || '|' || coalesce(t0.city,'') || '|' || coalesce(t0.state,'') || '|' || coalesce(t0.pin_code,'') ), '||||')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.state as COMMON_ADDRESS__STATE_NAME,
        t0.street as COMMON_ADDRESS__STREET_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    where (nullif(md5(normalise(upper(nullif(trim( coalesce(t0.street,'') || '|' || coalesce(t0.landmark,'') || '|' || coalesce(t0.city,'') || '|' || coalesce(t0.state,'') || '|' || coalesce(t0.pin_code,'') ), '||||')))), '')) is not null

    union all

    -- branch 23: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS
    select
        nullif(md5(normalise(upper(nullif(trim(coalesce(t0.address1,'') || '|' || coalesce(t0.address2,'') || '|' || coalesce(t0.address3,'') || '|' || coalesce(t0.city,'') || '|' || coalesce(t0.district,'') || '|' || coalesce(t0.state,'') || '|' || coalesce(t0.country,'') || '|' || coalesce(t0.pincode,'')), '|||||||')))), '') as LOCATION_BK,
        null,
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        1 as __LNK_PARTY_LOCATION,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.address1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.address2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.address3 as COMMON_ADDRESS__ADDRESS_LINE_3,
        null, null, null,
        t0.city as COMMON_ADDRESS__CITY,
        null,
        t0.country as COMMON_ADDRESS__COUNTRY_NAME,
        t0.district as COMMON_ADDRESS__DISTRICT,
        null, null,
        t0.pincode as COMMON_ADDRESS__POSTAL_CODE,
        null, null,
        t0.state as COMMON_ADDRESS__STATE_NAME,
        null,
        'EMAIL_ALTERNATE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null,
        t0.alternate_email_id as COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim(t0.address_type),'') as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
        null,
        t0.address_type as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(upper(nullif(trim(coalesce(t0.address1,'') || '|' || coalesce(t0.address2,'') || '|' || coalesce(t0.address3,'') || '|' || coalesce(t0.city,'') || '|' || coalesce(t0.district,'') || '|' || coalesce(t0.state,'') || '|' || coalesce(t0.country,'') || '|' || coalesce(t0.pincode,'')), '|||||||')))), ''), nullif(nullif(trim(j1.party_code),''), ''))) is not null

    union all

    -- branch 24: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS
    select
        null, null,
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null,
        t0.email_id as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 25: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS
    select
        null, null,
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'FAX' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null,
        t0.fax as COMMON_CONTACT__FAX_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 26: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS
    select
        null, null,
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'LANDLINE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null, null,
        t0.landline_no as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null,
        t0.std_code as COMMON_CONTACT__STD_CODE,
        null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 27: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS
    select
        null, null,
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null, null, null,
        t0.mobile_no as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 28: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS
    select
        null, null,
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'LANDLINE_PHONE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null, null,
        t0.phone_no as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 29: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS
    select
        null, null,
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'LANDLINE_WORK' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null, null,
        t0.work_no as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code),''), '')) is not null

    union all

    -- branch 30: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim(coalesce(j2.address1, '') || '|' || coalesce(j2.address2, '') || '|' || coalesce(j2.address3, '') || '|' || coalesce(j2.city, '') || '|' || coalesce(j2.district, '') || '|' || coalesce(j2.state, '') || '|' || coalesce(j2.pincode, '') || '|' || coalesce(j2.country, '')), '|||||||')))), '') as LOCATION_BK,
        null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        1 as __LNK_PARTY_LOCATION,
        null, null,
        t0.geo_coordinate_altitude as AUG_COMMON_GEO__ALTITUDE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.land_mark as COMMON_ADDRESS__LANDMARK,
        t0.area as COMMON_ADDRESS__LOCALITY,
        null,
        t0.post_office as COMMON_ADDRESS__POST_OFFICE_NAME,
        null, null, null,
        'MOBILE_ALTERNATE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null,
        t0.alternate_mob_numberlandline_number as COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER,
        null, null, null, null, null, null, null,
        t0.geo_coordinate_latitude as COMMON_GEO__LATITUDE,
        t0.geo_coordinate_longitude as COMMON_GEO__LONGITUDE,
        null, null,
        t0.location_type as LOCATION_PROFILE__LOCATION_TYPE,
        null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address_address_prop_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address_address_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(upper(nullif(trim(coalesce(j2.address1, '') || '|' || coalesce(j2.address2, '') || '|' || coalesce(j2.address3, '') || '|' || coalesce(j2.city, '') || '|' || coalesce(j2.district, '') || '|' || coalesce(j2.state, '') || '|' || coalesce(j2.pincode, '') || '|' || coalesce(j2.country, '')), '|||||||')))), ''), nullif(nullif(trim(j3.party_code), ''), ''))) is not null

    union all

    -- branch 31: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'SOCIAL_FACEBOOK' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null, null, null, null,
        t0.facebook_id as COMMON_CONTACT__SOCIAL_MEDIA_HANDLE,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address_address_prop_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address_address_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 32: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'SOCIAL_INSTAGRAM' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null, null, null, null,
        t0.instagram_id as COMMON_CONTACT__SOCIAL_MEDIA_HANDLE,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address_address_prop_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address_address_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 33: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'SOCIAL_LINKEDIN' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null, null, null, null,
        t0.linked_in_id as COMMON_CONTACT__SOCIAL_MEDIA_HANDLE,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address_address_prop_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address_address_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 34: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'SOCIAL_TWITTER' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null, null, null, null,
        t0.twitter_id as COMMON_CONTACT__SOCIAL_MEDIA_HANDLE,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address_address_prop_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address_address_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 35: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'MOBILE_WHATSAPP' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null, null, null,
        t0.whatsapp_no as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address_address_prop_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address_address_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_address') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 36: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim(coalesce(t0.address_of_the_coordinating_office,'')), '')))), '') as LOCATION_BK,
        null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null,
        t0.address_of_the_coordinating_office as AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'MOBILE_ALTERNATE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null,
        t0.alternate_mob_numberlandline_number as COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(upper(nullif(trim(coalesce(t0.address_of_the_coordinating_office,'')), '')))), ''), nullif(nullif(trim(j3.party_code), ''), ''))) is not null

    union all

    -- branch 37: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim(coalesce(t0.current_permanent_overseas_address_line_1,'') || ' ' || coalesce(t0.current_permanent_overseas_address_line_2,'') || ' ' || coalesce(t0.current_permanent_overseas_address_line_3,'') || ' ' || coalesce(t0.current_permanent_overseas_address_city_town_village,'') || ' ' || coalesce(t0.current_permanent_overseas_address_state_ut,'') || ' ' || coalesce(t0.current_permanent_overseas_address_country,'') || ' ' || coalesce(t0.current_permanent_overseas_address_pin_code,'')), '')))), '') as LOCATION_BK,
        null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        1 as __LNK_PARTY_LOCATION,
        null,
        t0.current_permanent_overseas_address as AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT,
        null, null, null, null, null, null, null, null, null, null,
        t0.current_permanent_overseas_address_line_1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.current_permanent_overseas_address_line_2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.current_permanent_overseas_address_line_3 as COMMON_ADDRESS__ADDRESS_LINE_3,
        null,
        t0.current_permanent_overseas_address_type as COMMON_ADDRESS__ADDRESS_TYPE_CODE,
        null,
        t0.current_permanent_overseas_address_city_town_village as COMMON_ADDRESS__CITY,
        null,
        t0.current_permanent_overseas_address_country as COMMON_ADDRESS__COUNTRY_NAME,
        null, null, null,
        t0.current_permanent_overseas_address_pin_code as COMMON_ADDRESS__POSTAL_CODE,
        null, null,
        t0.current_permanent_overseas_address_state_ut as COMMON_ADDRESS__STATE_NAME,
        null,
        'MOBILE_KYC' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null, null, null,
        t0.kyc_mobile_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null, null, null, null, null,
        'PERMANENT' as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
        t0.proof_of_address_submitted_for_current_permanent_overseas_address as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_PROOF_TYPE,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(upper(nullif(trim(coalesce(t0.current_permanent_overseas_address_line_1,'') || ' ' || coalesce(t0.current_permanent_overseas_address_line_2,'') || ' ' || coalesce(t0.current_permanent_overseas_address_line_3,'') || ' ' || coalesce(t0.current_permanent_overseas_address_city_town_village,'') || ' ' || coalesce(t0.current_permanent_overseas_address_state_ut,'') || ' ' || coalesce(t0.current_permanent_overseas_address_country,'') || ' ' || coalesce(t0.current_permanent_overseas_address_pin_code,'')), '')))), ''), nullif(nullif(trim(j3.party_code), ''), ''))) is not null

    union all

    -- branch 38: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim(coalesce(t0.correspondence_local_address_line_1,'') || ' ' || coalesce(t0.correspondence_local_address_line_2,'') || ' ' || coalesce(t0.correspondence_local_address_line_3,'') || ' ' || coalesce(t0.correspondence_local_address_city_town_village,'') || ' ' || coalesce(t0.correspondence_local_address_district,'') || ' ' || coalesce(t0.correspondence_local_address_state,'') || ' ' || coalesce(t0.correspondence_local_address_country,'') || ' ' || coalesce(t0.local_address_pin_code,'')), '')))), '') as LOCATION_BK,
        null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        1 as __LNK_PARTY_LOCATION,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.correspondence_local_address_line_1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.correspondence_local_address_line_2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.correspondence_local_address_line_3 as COMMON_ADDRESS__ADDRESS_LINE_3,
        null, null,
        t0.addressee as COMMON_ADDRESS__CARE_OF_NAME,
        t0.correspondence_local_address_city_town_village as COMMON_ADDRESS__CITY,
        null,
        t0.correspondence_local_address_country as COMMON_ADDRESS__COUNTRY_NAME,
        t0.correspondence_local_address_district as COMMON_ADDRESS__DISTRICT,
        null, null,
        t0.local_address_pin_code as COMMON_ADDRESS__POSTAL_CODE,
        null, null,
        t0.correspondence_local_address_state as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.address_proof as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_PROOF_TYPE,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(upper(nullif(trim(coalesce(t0.correspondence_local_address_line_1,'') || ' ' || coalesce(t0.correspondence_local_address_line_2,'') || ' ' || coalesce(t0.correspondence_local_address_line_3,'') || ' ' || coalesce(t0.correspondence_local_address_city_town_village,'') || ' ' || coalesce(t0.correspondence_local_address_district,'') || ' ' || coalesce(t0.correspondence_local_address_state,'') || ' ' || coalesce(t0.correspondence_local_address_country,'') || ' ' || coalesce(t0.local_address_pin_code,'')), '')))), ''), nullif(nullif(trim(j3.party_code), ''), ''))) is not null

    union all

    -- branch 39: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim(t0.address_for_reference), '')))), '') as LOCATION_BK,
        null,
        nullif(nullif(trim(j3.policy_holder_code), ''), '') as PARTY_BK,
        null, null,
        t0.address_for_reference as AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'MOBILE_ALTERNATE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null,
        t0.alternate_mobile_numberclaims as COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(upper(nullif(trim(t0.address_for_reference), '')))), ''), nullif(nullif(trim(j3.policy_holder_code), ''), ''))) is not null

    union all

    -- branch 40: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim(coalesce(t0.city,'') || '|' || coalesce(t0.country,'') || '|' || coalesce(t0.pin_code,'')), '||')))), '') as LOCATION_BK,
        null,
        nullif(nullif(trim(j3.policy_holder_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.city as COMMON_ADDRESS__CITY,
        null,
        t0.country as COMMON_ADDRESS__COUNTRY_NAME,
        null, null, null, null, null, null, null, null,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null, null, null,
        t0.contact_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(upper(nullif(trim(coalesce(t0.city,'') || '|' || coalesce(t0.country,'') || '|' || coalesce(t0.pin_code,'')), '||')))), ''), nullif(nullif(trim(j3.policy_holder_code), ''), ''))) is not null

    union all

    -- branch 41: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim( coalesce(t0.landmark,'') || '|' || coalesce(t0.pin_code,'') || '|' || coalesce(t0.latitude,'') || '|' || coalesce(t0.longitude,'') ), '|||')))), '') as LOCATION_BK,
        null,
        nullif(nullif(trim(j3.policy_holder_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.landmark as COMMON_ADDRESS__LANDMARK,
        null,
        t0.pin_code as COMMON_ADDRESS__POSTAL_CODE,
        null, null, null, null,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null, null, null,
        t0.insured_contact_number as COMMON_CONTACT__MOBILE_NUMBER,
        null, null,
        t0.latitude as COMMON_GEO__LATITUDE,
        t0.longitude as COMMON_GEO__LONGITUDE,
        null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(upper(nullif(trim( coalesce(t0.landmark,'') || '|' || coalesce(t0.pin_code,'') || '|' || coalesce(t0.latitude,'') || '|' || coalesce(t0.longitude,'') ), '|||')))), ''), nullif(nullif(trim(j3.policy_holder_code), ''), ''))) is not null

    union all

    -- branch 42: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        nullif(nullif(trim(t0.rta_code), ''), '') as LOCATION_BK,
        null,
        nullif(nullif(trim(j3.policy_holder_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rta_city as COMMON_ADDRESS__CITY,
        null, null, null, null, null, null, null, null, null, null,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null,
        t0.insured_email_id as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null,
        t0.rta_location as LOCATION_PROFILE__LOCATION_NAME,
        null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j3.policy_holder_code), ''), ''), nullif(nullif(trim(t0.rta_code), ''), ''))) is not null

    union all

    -- branch 43: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        nullif(md5(normalise(upper(nullif(trim( coalesce(t0.street,'') || '|' || coalesce(t0.landmark,'') || '|' || coalesce(t0.city,'') || '|' || coalesce(t0.state,'') || '|' || coalesce(t0.pin_code,'') ), '||||')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.state as COMMON_ADDRESS__STATE_NAME,
        t0.street as COMMON_ADDRESS__STREET_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    where (nullif(md5(normalise(upper(nullif(trim( coalesce(t0.street,'') || '|' || coalesce(t0.landmark,'') || '|' || coalesce(t0.city,'') || '|' || coalesce(t0.state,'') || '|' || coalesce(t0.pin_code,'') ), '||||')))), '')) is not null

    union all

    -- branch 44: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST
    select
        nullif(md5(normalise(upper(nullif(trim(coalesce(t0.addr1,'') || '|' || coalesce(t0.addr2,'') || '|' || coalesce(t0.addr3,'') || '|' || coalesce(t0.city_code,'') || '|' || coalesce(t0.state_code,'') || '|' || coalesce(t0.postal_code,'') || '|' || coalesce(t0.country_code,'')), '||||||')))), '') as LOCATION_BK,
        null, null, null,
        t0.city_code as AUG_COMMON_ADDRESS__CITY_CODE,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.addr1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.addr2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.addr3 as COMMON_ADDRESS__ADDRESS_LINE_3,
        null, null, null, null,
        t0.country_code as COMMON_ADDRESS__COUNTRY_CODE,
        null, null, null, null,
        t0.postal_code as COMMON_ADDRESS__POSTAL_CODE,
        null,
        t0.state_code as COMMON_ADDRESS__STATE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} t0
    where (nullif(md5(normalise(upper(nullif(trim(coalesce(t0.addr1,'') || '|' || coalesce(t0.addr2,'') || '|' || coalesce(t0.addr3,'') || '|' || coalesce(t0.city_code,'') || '|' || coalesce(t0.state_code,'') || '|' || coalesce(t0.postal_code,'') || '|' || coalesce(t0.country_code,'')), '||||||')))), '')) is not null

)

select
    LOCATION_BK,
    ORG_UNIT_BK,
    PARTY_BK,
    __LNK_PARTY_LOCATION,
    first_value(AUG_COMMON_ADDRESS__CITY_CODE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_ADDRESS__CITY_CODE,
    first_value(AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT,
    first_value(AUG_COMMON_GEO__ALTITUDE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_GEO__ALTITUDE,
    AUG_ORG_UNIT_CONTACT__CONTACT_POINT_TYPE_CK,
    first_value(AUG_ORG_UNIT_CONTACT__ALTERNATE_MOBILE_NUMBER) ignore nulls over (partition by ORG_UNIT_BK, AUG_ORG_UNIT_CONTACT__CONTACT_POINT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_CONTACT__ALTERNATE_MOBILE_NUMBER,
    first_value(AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS) ignore nulls over (partition by ORG_UNIT_BK, AUG_ORG_UNIT_CONTACT__CONTACT_POINT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS,
    first_value(AUG_ORG_UNIT_CONTACT__FAX_NUMBER) ignore nulls over (partition by ORG_UNIT_BK, AUG_ORG_UNIT_CONTACT__CONTACT_POINT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_CONTACT__FAX_NUMBER,
    first_value(AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER) ignore nulls over (partition by ORG_UNIT_BK, AUG_ORG_UNIT_CONTACT__CONTACT_POINT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER,
    first_value(AUG_ORG_UNIT_CONTACT__MOBILE_NUMBER) ignore nulls over (partition by ORG_UNIT_BK, AUG_ORG_UNIT_CONTACT__CONTACT_POINT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_CONTACT__MOBILE_NUMBER,
    first_value(AUG_ORG_UNIT_CONTACT__SOCIAL_MEDIA_HANDLE) ignore nulls over (partition by ORG_UNIT_BK, AUG_ORG_UNIT_CONTACT__CONTACT_POINT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_CONTACT__SOCIAL_MEDIA_HANDLE,
    first_value(AUG_ORG_UNIT_CONTACT__STD_CODE) ignore nulls over (partition by ORG_UNIT_BK, AUG_ORG_UNIT_CONTACT__CONTACT_POINT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_CONTACT__STD_CODE,
    first_value(AUG_ORG_UNIT_CONTACT__WHATSAPP_NUMBER) ignore nulls over (partition by ORG_UNIT_BK, AUG_ORG_UNIT_CONTACT__CONTACT_POINT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_CONTACT__WHATSAPP_NUMBER,
    first_value(COMMON_ADDRESS__ADDRESS_LINE_1) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__ADDRESS_LINE_1,
    first_value(COMMON_ADDRESS__ADDRESS_LINE_2) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__ADDRESS_LINE_2,
    first_value(COMMON_ADDRESS__ADDRESS_LINE_3) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__ADDRESS_LINE_3,
    first_value(COMMON_ADDRESS__ADDRESS_SOURCE_INDICATOR) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__ADDRESS_SOURCE_INDICATOR,
    first_value(COMMON_ADDRESS__ADDRESS_TYPE_CODE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__ADDRESS_TYPE_CODE,
    first_value(COMMON_ADDRESS__CARE_OF_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__CARE_OF_NAME,
    first_value(COMMON_ADDRESS__CITY) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__CITY,
    first_value(COMMON_ADDRESS__COUNTRY_CODE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__COUNTRY_CODE,
    first_value(COMMON_ADDRESS__COUNTRY_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__COUNTRY_NAME,
    first_value(COMMON_ADDRESS__DISTRICT) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__DISTRICT,
    first_value(COMMON_ADDRESS__LANDMARK) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__LANDMARK,
    first_value(COMMON_ADDRESS__LOCALITY) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__LOCALITY,
    first_value(COMMON_ADDRESS__POSTAL_CODE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__POSTAL_CODE,
    first_value(COMMON_ADDRESS__POST_OFFICE_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__POST_OFFICE_NAME,
    first_value(COMMON_ADDRESS__STATE_CODE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__STATE_CODE,
    first_value(COMMON_ADDRESS__STATE_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__STATE_NAME,
    first_value(COMMON_ADDRESS__STREET_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__STREET_NAME,
    COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
    COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
    first_value(COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS,
    first_value(COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER,
    first_value(COMMON_CONTACT__CONTACT_POINT_USAGE) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__CONTACT_POINT_USAGE,
    first_value(COMMON_CONTACT__EMAIL_ADDRESS) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__EMAIL_ADDRESS,
    first_value(COMMON_CONTACT__FAX_NUMBER) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__FAX_NUMBER,
    first_value(COMMON_CONTACT__LANDLINE_NUMBER) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__LANDLINE_NUMBER,
    first_value(COMMON_CONTACT__MOBILE_NUMBER) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__MOBILE_NUMBER,
    first_value(COMMON_CONTACT__SOCIAL_MEDIA_HANDLE) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__SOCIAL_MEDIA_HANDLE,
    first_value(COMMON_CONTACT__STD_CODE) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__STD_CODE,
    first_value(COMMON_GEO__LATITUDE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_GEO__LATITUDE,
    first_value(COMMON_GEO__LONGITUDE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_GEO__LONGITUDE,
    first_value(COMMON_GEO__ZONE_CODE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_GEO__ZONE_CODE,
    first_value(LOCATION_PROFILE__LOCATION_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOCATION_PROFILE__LOCATION_NAME,
    first_value(LOCATION_PROFILE__LOCATION_TYPE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOCATION_PROFILE__LOCATION_TYPE,
    PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
    first_value(PARTY_CONTACT_ADDRESS_LINK__ADDRESS_PROOF_TYPE) ignore nulls over (partition by LOCATION_BK, PARTY_BK, PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_PROOF_TYPE,
    first_value(PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE) ignore nulls over (partition by LOCATION_BK, PARTY_BK, PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.REC_REFRESH_AT,
    -- multi-active satellites on LOCATION_BK (SAT_PARTY_CONTACT_ADDRESS_LINK):
    -- one load time per LOCATION_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.PARTY_CONTACT_ADDRESS_LINK__ADDRESS_PROOF_TYPE, m.PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.LOCATION_BK) as LOCATION_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on ORG_UNIT_BK (SAT_MOTOR_AUG_ORG_UNIT_CONTACT):
    -- one load time per ORG_UNIT_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_ORG_UNIT_CONTACT__ALTERNATE_MOBILE_NUMBER, m.AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS, m.AUG_ORG_UNIT_CONTACT__FAX_NUMBER, m.AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER, m.AUG_ORG_UNIT_CONTACT__MOBILE_NUMBER, m.AUG_ORG_UNIT_CONTACT__SOCIAL_MEDIA_HANDLE, m.AUG_ORG_UNIT_CONTACT__STD_CODE, m.AUG_ORG_UNIT_CONTACT__WHATSAPP_NUMBER) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.ORG_UNIT_BK) as ORG_UNIT_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on PARTY_BK (SAT_COMMON_CONTACT):
    -- one load time per PARTY_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS, m.COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER, m.COMMON_CONTACT__CONTACT_POINT_USAGE, m.COMMON_CONTACT__EMAIL_ADDRESS, m.COMMON_CONTACT__FAX_NUMBER, m.COMMON_CONTACT__LANDLINE_NUMBER, m.COMMON_CONTACT__MOBILE_NUMBER, m.COMMON_CONTACT__SOCIAL_MEDIA_HANDLE, m.COMMON_CONTACT__STD_CODE) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.PARTY_BK) as PARTY_BK__MA_LOAD_DATETIME
from merged m
