-- CENTRAL VIEW v07_location -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BA_QUOTE_MOT_DTLS
--   BGIL_MOTOR_WEBSERVICE_INFO_EQM
--   BJAZ_AGENCY_MOT_WAR_DTLS
--   BJAZ_CLM_BASE_MOT_EXT
--   BJAZ_CLM_MOTOR_INTIM_DETAILS
--   BJAZ_CVTP_WS_DATA
--   BJAZ_MOTORTHEFT_CASE_DTLS
--   BJAZ_MOTOR_WEBSERVICE_INFO
--   BJAZ_MOT_ADD_QSTN_DTLS
--   BJAZ_MOT_ONLINE_POL_DTLS
--   BJAZ_MOT_ONLINE_POL_DTLS_EXTN
--   BJAZ_MOT_RENEWAL_EXTN
--   BJAZ_MOT_RENEWAL_HIST
--   BJAZ_MOT_WAR_CHILD_DTLS
--   BJAZ_MOT_WS_POL_DTLS
--   BJAZ_VEHICLE_PRICE_MASTER
--   RTA_CLUSTER_PREFERRED_DECLINE
--   RTO_MASTER
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_MOTOR_AUG_COMMON_ADMIN_GEOGRAPHY
--   SAT_COMMON_ADDRESS
--   SAT_LNK_ROLE_NOMINEE_BENEFICIARY
--   SAT_LOCATION_PROFILE
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every feeding table.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BA_QUOTE_MOT_DTLS
    select
        nullif(nullif(trim(to_char(t0.pincode)), ''), '') as LOCATION_BK,
        cast(null as varchar) as PARTY_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as varchar) as AUG_COMMON_ADMIN_GEOGRAPHY__COMMERCIAL_REGISTRATION_ZONE,
        cast(null as varchar) as AUG_COMMON_ADMIN_GEOGRAPHY__EFFECTIVE_DATE,
        cast(null as varchar) as AUG_COMMON_ADMIN_GEOGRAPHY__EXPIRY_DATE,
        cast(null as varchar) as AUG_COMMON_ADMIN_GEOGRAPHY__REGISTRATION_ZONE,
        cast(null as varchar) as AUG_COMMON_ADMIN_GEOGRAPHY__RTO_CLUSTER_CODE,
        cast(null as varchar) as COMMON_ADDRESS__ADDRESS_LINE_1,
        cast(null as varchar) as COMMON_ADDRESS__ADDRESS_LINE_2,
        cast(null as varchar) as COMMON_ADDRESS__ADDRESS_LINE_3,
        cast(null as varchar) as COMMON_ADDRESS__CARE_OF_NAME,
        cast(null as varchar) as COMMON_ADDRESS__CITY,
        cast(null as varchar) as COMMON_ADDRESS__COUNTRY_CODE,
        cast(null as varchar) as COMMON_ADDRESS__COUNTRY_NAME,
        cast(null as varchar) as COMMON_ADDRESS__LANDMARK,
        cast(null as varchar) as COMMON_ADDRESS__LOCALITY,
        t0.pincode as COMMON_ADDRESS__POSTAL_CODE,
        cast(null as varchar) as COMMON_ADDRESS__POST_OFFICE_NAME,
        cast(null as varchar) as COMMON_ADDRESS__STATE_CODE,
        cast(null as varchar) as COMMON_ADDRESS__STATE_NAME,
        cast(null as varchar) as COMMON_ADDRESS__STREET_NAME,
        cast(null as varchar) as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_NOMINEE_BENEFICIARY__APPOINTEE_NAME,
        cast(null as varchar) as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED,
        cast(null as varchar) as LOCATION_PROFILE__CONNECTIVITY_GRADE,
        cast(null as varchar) as LOCATION_PROFILE__LOCATION_NAME,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.pincode)), ''), '')) is not null

    union all

    -- branch 1: BA_QUOTE_MOT_DTLS
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.tp_prev_ins_address, ''), '')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null,
        t0.tp_prev_ins_address as COMMON_ADDRESS__ADDRESS_LINE_1,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.tp_prev_ins_address, ''), '')))), '')) is not null

    union all

    -- branch 2: BA_QUOTE_MOT_DTLS | child-key literal(s): LNK_ROLE_NOMINEE_BENEFICIARY.Role Type=NOMINEE_BENEFICIARY
    select
        null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.nominee_name, ''), '')))), '') as PARTY_BK,
        'NOMINEE_BENEFICIARY' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NOMINEE_BENEFICIARY' as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        null,
        t0.nominee_relation as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.nominee_name, ''), '')))), '')) is not null

    union all

    -- branch 3: BGIL_MOTOR_WEBSERVICE_INFO_EQM
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.city, '') || '|' || coalesce(to_char(t0.postal_code), ''), '|')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.city as COMMON_ADDRESS__CITY,
        null, null, null, null,
        t0.postal_code as COMMON_ADDRESS__POSTAL_CODE,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_webservice_info_eqm') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.city, '') || '|' || coalesce(to_char(t0.postal_code), ''), '|')))), '')) is not null

    union all

    -- branch 4: BJAZ_AGENCY_MOT_WAR_DTLS
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.customer_address, '') || '|' || coalesce(t0.area, '') || '|' || coalesce(t0.city, '') || '|' || coalesce(t0.state, '') || '|' || coalesce(to_char(t0.pincode), ''), '||||')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null,
        t0.customer_address as COMMON_ADDRESS__ADDRESS_LINE_1,
        null, null, null,
        t0.city as COMMON_ADDRESS__CITY,
        null, null, null,
        t0.area as COMMON_ADDRESS__LOCALITY,
        t0.pincode as COMMON_ADDRESS__POSTAL_CODE,
        null, null,
        t0.state as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_agency_mot_war_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.customer_address, '') || '|' || coalesce(t0.area, '') || '|' || coalesce(t0.city, '') || '|' || coalesce(t0.state, '') || '|' || coalesce(to_char(t0.pincode), ''), '||||')))), '')) is not null

    union all

    -- branch 5: BJAZ_CLM_BASE_MOT_EXT
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.address_line1, '') || '|' || coalesce(t0.address_line2, '') || '|' || coalesce(t0.landmark, '') || '|' || coalesce(t0.area, '') || '|' || coalesce(t0.city, '') || '|' || coalesce(t0.state, '') || '|' || coalesce(to_char(t0.pincode), ''), '||||||')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null,
        t0.address_line1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.address_line2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        null, null,
        t0.city as COMMON_ADDRESS__CITY,
        null, null,
        t0.landmark as COMMON_ADDRESS__LANDMARK,
        t0.area as COMMON_ADDRESS__LOCALITY,
        t0.pincode as COMMON_ADDRESS__POSTAL_CODE,
        null, null,
        t0.state as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_base_mot_ext') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.address_line1, '') || '|' || coalesce(t0.address_line2, '') || '|' || coalesce(t0.landmark, '') || '|' || coalesce(t0.area, '') || '|' || coalesce(t0.city, '') || '|' || coalesce(t0.state, '') || '|' || coalesce(to_char(t0.pincode), ''), '||||||')))), '')) is not null

    union all

    -- branch 6: BJAZ_CLM_MOTOR_INTIM_DETAILS
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.cp_address, '') || '|' || coalesce(t0.cp_street, '') || '|' || coalesce(t0.cp_area, '') || '|' || coalesce(t0.cp_city, '') || '|' || coalesce(t0.cp_state, '') || '|' || coalesce(to_char(t0.cp_pincode), ''), '|||||')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null,
        t0.cp_address as COMMON_ADDRESS__ADDRESS_LINE_1,
        null, null, null,
        t0.cp_city as COMMON_ADDRESS__CITY,
        null, null,
        t0.cp_landmark as COMMON_ADDRESS__LANDMARK,
        t0.cp_area as COMMON_ADDRESS__LOCALITY,
        t0.cp_pincode as COMMON_ADDRESS__POSTAL_CODE,
        null, null,
        t0.cp_state as COMMON_ADDRESS__STATE_NAME,
        t0.cp_street as COMMON_ADDRESS__STREET_NAME,
        null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_motor_intim_details') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.cp_address, '') || '|' || coalesce(t0.cp_street, '') || '|' || coalesce(t0.cp_area, '') || '|' || coalesce(t0.cp_city, '') || '|' || coalesce(t0.cp_state, '') || '|' || coalesce(to_char(t0.cp_pincode), ''), '|||||')))), '')) is not null

    union all

    -- branch 7: BJAZ_CVTP_WS_DATA
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.address1, '') || '|' || coalesce(t0.address2, '') || '|' || coalesce(t0.address3, '') || '|' || coalesce(to_char(t0.pincode), ''), '|||')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null,
        t0.address1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.address2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.address3 as COMMON_ADDRESS__ADDRESS_LINE_3,
        null,
        t0.citycode as COMMON_ADDRESS__CITY,
        null, null, null, null,
        t0.pincode as COMMON_ADDRESS__POSTAL_CODE,
        null,
        t0.statecode as COMMON_ADDRESS__STATE_CODE,
        null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.address1, '') || '|' || coalesce(t0.address2, '') || '|' || coalesce(t0.address3, '') || '|' || coalesce(to_char(t0.pincode), ''), '|||')))), '')) is not null

    union all

    -- branch 8: BJAZ_CVTP_WS_DATA | child-key literal(s): LNK_ROLE_NOMINEE_BENEFICIARY.Role Type=NOMINEE_BENEFICIARY
    select
        null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.bjazpolicyno, '') || '|' || coalesce(t0.paowndrivernomname, ''), '|')))), '') as PARTY_BK,
        'NOMINEE_BENEFICIARY' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NOMINEE_BENEFICIARY' as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        t0.paowndriverappointeename as LNK_ROLE_NOMINEE_BENEFICIARY__APPOINTEE_NAME,
        t0.paowndrivernomreleation as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.bjazpolicyno, '') || '|' || coalesce(t0.paowndrivernomname, ''), '|')))), '')) is not null

    union all

    -- branch 9: BJAZ_MOTORTHEFT_CASE_DTLS
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.highest_bidder_address, ''), '')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null,
        t0.highest_bidder_address as COMMON_ADDRESS__ADDRESS_LINE_1,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.highest_bidder_address, ''), '')))), '')) is not null

    union all

    -- branch 10: BJAZ_MOTORTHEFT_CASE_DTLS
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.buyer_address, ''), '')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null,
        t0.buyer_address as COMMON_ADDRESS__ADDRESS_LINE_1,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.buyer_address, ''), '')))), '')) is not null

    union all

    -- branch 11: BJAZ_MOTORTHEFT_CASE_DTLS
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.so_map_state, '') || '|' || coalesce(t0.so_map_city, ''), '|')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.so_map_city as COMMON_ADDRESS__CITY,
        null, null, null, null, null, null, null,
        t0.so_map_state as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.so_map_state, '') || '|' || coalesce(t0.so_map_city, ''), '|')))), '')) is not null

    union all

    -- branch 12: BJAZ_MOTORTHEFT_CASE_DTLS
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.court_location, ''), '')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.court_location as LOCATION_PROFILE__LOCATION_NAME,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.court_location, ''), '')))), '')) is not null

    union all

    -- branch 13: BJAZ_MOTORTHEFT_CASE_DTLS
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.court_order_location, ''), '')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.court_order_location as LOCATION_PROFILE__LOCATION_NAME,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.court_order_location, ''), '')))), '')) is not null

    union all

    -- branch 14: BJAZ_MOTORTHEFT_CASE_DTLS
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.bid_court_location, ''), '')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.bid_court_location as LOCATION_PROFILE__LOCATION_NAME,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.bid_court_location, ''), '')))), '')) is not null

    union all

    -- branch 15: BJAZ_MOTORTHEFT_CASE_DTLS
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.vehicle_cur_loc, ''), '')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.vehicle_cur_loc as LOCATION_PROFILE__LOCATION_NAME,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.vehicle_cur_loc, ''), '')))), '')) is not null

    union all

    -- branch 16: BJAZ_MOTOR_WEBSERVICE_INFO
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.city, '') || '|' || coalesce(to_char(t0.postal_code), ''), '|')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.city as COMMON_ADDRESS__CITY,
        null, null, null, null,
        t0.postal_code as COMMON_ADDRESS__POSTAL_CODE,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_webservice_info') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.city, '') || '|' || coalesce(to_char(t0.postal_code), ''), '|')))), '')) is not null

    union all

    -- branch 17: BJAZ_MOT_ADD_QSTN_DTLS
    select
        nullif(nullif('PIN:' || nullif(trim(t0.stp_pin), ''), 'PIN:'), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.stp_pin as COMMON_ADDRESS__POSTAL_CODE,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_add_qstn_dtls') }} t0
    where (nullif(nullif('PIN:' || nullif(trim(t0.stp_pin), ''), 'PIN:'), '')) is not null

    union all

    -- branch 18: BJAZ_MOT_ONLINE_POL_DTLS
    select
        nullif(md5(normalise(upper(nullif(trim(t0.family_doc_add), '')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null,
        t0.family_doc_add as COMMON_ADDRESS__ADDRESS_LINE_1,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(trim(t0.family_doc_add), '')))), '')) is not null

    union all

    -- branch 19: BJAZ_MOT_ONLINE_POL_DTLS
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.disp_address_line1, '') || '|' || coalesce(t0.disp_address_line2, '') || '|' || coalesce(t0.disp_area, '') || '|' || coalesce(t0.disp_city, '') || '|' || coalesce(t0.disp_state, '') || '|' || coalesce(t0.disppostcode, ''), '|||||')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null,
        t0.disp_address_line1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.disp_address_line2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.disp_address_line4 as COMMON_ADDRESS__ADDRESS_LINE_3,
        t0.addressee as COMMON_ADDRESS__CARE_OF_NAME,
        t0.disp_city as COMMON_ADDRESS__CITY,
        t0.dispcountrycode as COMMON_ADDRESS__COUNTRY_CODE,
        null, null,
        t0.disp_area as COMMON_ADDRESS__LOCALITY,
        t0.disppostcode as COMMON_ADDRESS__POSTAL_CODE,
        null, null,
        t0.disp_state as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.disp_address_line1, '') || '|' || coalesce(t0.disp_address_line2, '') || '|' || coalesce(t0.disp_area, '') || '|' || coalesce(t0.disp_city, '') || '|' || coalesce(t0.disp_state, '') || '|' || coalesce(t0.disppostcode, ''), '|||||')))), '')) is not null

    union all

    -- branch 20: BJAZ_MOT_ONLINE_POL_DTLS
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.address_line1, '') || '|' || coalesce(t0.address_line2, '') || '|' || coalesce(t0.area, '') || '|' || coalesce(t0.city, '') || '|' || coalesce(t0.state, '') || '|' || coalesce(t0.postcode, ''), '|||||')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null,
        t0.address_line1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.address_line2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.address_line4 as COMMON_ADDRESS__ADDRESS_LINE_3,
        null,
        t0.city as COMMON_ADDRESS__CITY,
        t0.country_code as COMMON_ADDRESS__COUNTRY_CODE,
        null, null,
        t0.area as COMMON_ADDRESS__LOCALITY,
        t0.postcode as COMMON_ADDRESS__POSTAL_CODE,
        null, null,
        t0.state as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.address_line1, '') || '|' || coalesce(t0.address_line2, '') || '|' || coalesce(t0.area, '') || '|' || coalesce(t0.city, '') || '|' || coalesce(t0.state, '') || '|' || coalesce(t0.postcode, ''), '|||||')))), '')) is not null

    union all

    -- branch 21: BJAZ_MOT_ONLINE_POL_DTLS_EXTN
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.loc_address_line1, '') || '|' || coalesce(t0.loc_address_line2, '') || '|' || coalesce(t0.loc_city, '') || '|' || coalesce(t0.loc_state, '') || '|' || coalesce(t0.loc_pincode, '') || '|' || coalesce(t0.loc_country, ''), '|||||')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null,
        t0.loc_address_line1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.loc_address_line2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        null, null,
        t0.loc_city as COMMON_ADDRESS__CITY,
        null,
        t0.loc_country as COMMON_ADDRESS__COUNTRY_NAME,
        null,
        t0.loc_area as COMMON_ADDRESS__LOCALITY,
        t0.loc_pincode as COMMON_ADDRESS__POSTAL_CODE,
        t0.loc_po_area as COMMON_ADDRESS__POST_OFFICE_NAME,
        null,
        t0.loc_state as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls_extn') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.loc_address_line1, '') || '|' || coalesce(t0.loc_address_line2, '') || '|' || coalesce(t0.loc_city, '') || '|' || coalesce(t0.loc_state, '') || '|' || coalesce(t0.loc_pincode, '') || '|' || coalesce(t0.loc_country, ''), '|||||')))), '')) is not null

    union all

    -- branch 22: BJAZ_MOT_ONLINE_POL_DTLS_EXTN | child-key literal(s): LNK_ROLE_NOMINEE_BENEFICIARY.Role Type=NOMINEE_BENEFICIARY
    select
        null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.nom_full_name, '') || '|' || coalesce(to_char(t0.nom_dob), ''), '|')))), '') as PARTY_BK,
        'NOMINEE_BENEFICIARY' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NOMINEE_BENEFICIARY' as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        null,
        t0.nom_relation as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls_extn') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.nom_full_name, '') || '|' || coalesce(to_char(t0.nom_dob), ''), '|')))), '')) is not null

    union all

    -- branch 23: BJAZ_MOT_ONLINE_POL_DTLS_EXTN | child-key literal(s): LNK_ROLE_NOMINEE_BENEFICIARY.Role Type=NOMINEE_BENEFICIARY
    select
        null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.ass_full_name, '') || '|' || coalesce(to_char(t0.ass_dob), ''), '|')))), '') as PARTY_BK,
        'NOMINEE_BENEFICIARY' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NOMINEE_BENEFICIARY' as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        null,
        t0.ass_relationn as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls_extn') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.ass_full_name, '') || '|' || coalesce(to_char(t0.ass_dob), ''), '|')))), '')) is not null

    union all

    -- branch 24: BJAZ_MOT_ONLINE_POL_DTLS_EXTN | child-key literal(s): LNK_ROLE_NOMINEE_BENEFICIARY.Role Type=NOMINEE_BENEFICIARY
    select
        null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.od_nom_full_name, '') || '|' || coalesce(t0.od_nom_surname, ''), '|')))), '') as PARTY_BK,
        'NOMINEE_BENEFICIARY' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NOMINEE_BENEFICIARY' as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        null,
        t0.od_nom_relation as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls_extn') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.od_nom_full_name, '') || '|' || coalesce(t0.od_nom_surname, ''), '|')))), '')) is not null

    union all

    -- branch 25: BJAZ_MOT_RENEWAL_EXTN
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.cust_add1, '') || '|' || coalesce(t0.cust_add2, '') || '|' || coalesce(t0.cust_add3, '') || '|' || coalesce(t0.cust_add4, '') || '|' || coalesce(t0.cust_add5, '') || '|' || coalesce(to_char(t0.postcode), ''), '|||||')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null,
        t0.cust_add1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.cust_add2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.cust_add3 as COMMON_ADDRESS__ADDRESS_LINE_3,
        null, null, null, null, null, null,
        t0.postcode as COMMON_ADDRESS__POSTAL_CODE,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.cust_add1, '') || '|' || coalesce(t0.cust_add2, '') || '|' || coalesce(t0.cust_add3, '') || '|' || coalesce(t0.cust_add4, '') || '|' || coalesce(t0.cust_add5, '') || '|' || coalesce(to_char(t0.postcode), ''), '|||||')))), '')) is not null

    union all

    -- branch 26: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): LNK_ROLE_NOMINEE_BENEFICIARY.Role Type=NOMINEE_BENEFICIARY
    select
        null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.pa_nominee_name, '') || '|' || coalesce(t0.pa_nominee_relation, ''), '|')))), '') as PARTY_BK,
        'NOMINEE_BENEFICIARY' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NOMINEE_BENEFICIARY' as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        null,
        t0.pa_nominee_relation as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.pa_nominee_name, '') || '|' || coalesce(t0.pa_nominee_relation, ''), '|')))), '')) is not null

    union all

    -- branch 27: BJAZ_MOT_RENEWAL_HIST
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.price_master_city, ''), '')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.price_master_city as COMMON_ADDRESS__CITY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.price_master_city, ''), '')))), '')) is not null

    union all

    -- branch 28: BJAZ_MOT_WAR_CHILD_DTLS
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.state, '') || '|' || coalesce(t0.city, ''), '|')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.city as COMMON_ADDRESS__CITY,
        null, null, null, null, null, null, null,
        t0.state as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_war_child_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.state, '') || '|' || coalesce(t0.city, ''), '|')))), '')) is not null

    union all

    -- branch 29: BJAZ_MOT_WS_POL_DTLS
    select
        nullif(md5(normalise(upper(nullif(trim(t0.family_doc_add), '')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null,
        t0.family_doc_add as COMMON_ADDRESS__ADDRESS_LINE_1,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        14 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(trim(t0.family_doc_add), '')))), '')) is not null

    union all

    -- branch 30: BJAZ_MOT_WS_POL_DTLS
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.address_line1, '') || '|' || coalesce(t0.address_line2, '') || '|' || coalesce(t0.city, '') || '|' || coalesce(t0.state, '') || '|' || coalesce(t0.postcode, ''), '||||')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null,
        t0.address_line1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.address_line2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.address_line4 as COMMON_ADDRESS__ADDRESS_LINE_3,
        t0.addressee as COMMON_ADDRESS__CARE_OF_NAME,
        t0.city as COMMON_ADDRESS__CITY,
        t0.country_code as COMMON_ADDRESS__COUNTRY_CODE,
        null, null,
        t0.area as COMMON_ADDRESS__LOCALITY,
        t0.postcode as COMMON_ADDRESS__POSTAL_CODE,
        null, null,
        t0.state as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        14 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.address_line1, '') || '|' || coalesce(t0.address_line2, '') || '|' || coalesce(t0.city, '') || '|' || coalesce(t0.state, '') || '|' || coalesce(t0.postcode, ''), '||||')))), '')) is not null

    union all

    -- branch 31: BJAZ_MOT_WS_POL_DTLS
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.disp_address_line1, '') || '|' || coalesce(t0.disp_address_line2, '') || '|' || coalesce(t0.disp_city, '') || '|' || coalesce(t0.disp_state, '') || '|' || coalesce(t0.disppostcode, ''), '||||')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null,
        t0.disp_address_line1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.disp_address_line2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.disp_address_line4 as COMMON_ADDRESS__ADDRESS_LINE_3,
        null,
        t0.disp_city as COMMON_ADDRESS__CITY,
        t0.dispcountrycode as COMMON_ADDRESS__COUNTRY_CODE,
        null, null,
        t0.disp_area as COMMON_ADDRESS__LOCALITY,
        t0.disppostcode as COMMON_ADDRESS__POSTAL_CODE,
        null, null,
        t0.disp_state as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        14 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.disp_address_line1, '') || '|' || coalesce(t0.disp_address_line2, '') || '|' || coalesce(t0.disp_city, '') || '|' || coalesce(t0.disp_state, '') || '|' || coalesce(t0.disppostcode, ''), '||||')))), '')) is not null

    union all

    -- branch 32: BJAZ_MOT_WS_POL_DTLS
    select
        nullif(nullif(trim(to_char(t0.mailing_pincode)), ''), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.mailing_pincode as COMMON_ADDRESS__POSTAL_CODE,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        14 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.mailing_pincode)), ''), '')) is not null

    union all

    -- branch 33: BJAZ_VEHICLE_PRICE_MASTER
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.city, '') || '|' || coalesce(t0.state, ''), '|')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.city as COMMON_ADDRESS__CITY,
        null, null, null, null, null, null, null,
        t0.state as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        15 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_vehicle_price_master') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.city, '') || '|' || coalesce(t0.state, ''), '|')))), '')) is not null

    union all

    -- branch 34: RTA_CLUSTER_PREFERRED_DECLINE
    select
        nullif(nullif('RTO:' || nullif(trim(t0.rta_code), ''), 'RTO:'), '') as LOCATION_BK,
        null, null, null, null, null, null,
        t0.rta_cluster as AUG_COMMON_ADMIN_GEOGRAPHY__RTO_CLUSTER_CODE,
        null, null, null, null,
        t0.rta_city as COMMON_ADDRESS__CITY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        16 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__rta_cluster_preferred_decline') }} t0
    where (nullif(nullif('RTO:' || nullif(trim(t0.rta_code), ''), 'RTO:'), '')) is not null

    union all

    -- branch 35: RTO_MASTER
    select
        nullif(nullif('RTO:' || nullif(trim(t0.rta_code), ''), 'RTO:'), '') as LOCATION_BK,
        null, null,
        t0.comm_registration_zone as AUG_COMMON_ADMIN_GEOGRAPHY__COMMERCIAL_REGISTRATION_ZONE,
        t0.start_date as AUG_COMMON_ADMIN_GEOGRAPHY__EFFECTIVE_DATE,
        t0.end_date as AUG_COMMON_ADMIN_GEOGRAPHY__EXPIRY_DATE,
        t0.registration_zone as AUG_COMMON_ADMIN_GEOGRAPHY__REGISTRATION_ZONE,
        null,
        t0.address_line_1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.address_line_2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.address_line_3 as COMMON_ADDRESS__ADDRESS_LINE_3,
        null,
        t0.rta_city as COMMON_ADDRESS__CITY,
        null, null, null,
        t0.area as COMMON_ADDRESS__LOCALITY,
        null, null, null, null, null, null, null, null,
        t0.area_infrastructure as LOCATION_PROFILE__CONNECTIVITY_GRADE,
        null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        17 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__rto_master') }} t0
    where (nullif(nullif('RTO:' || nullif(trim(t0.rta_code), ''), 'RTO:'), '')) is not null

)

select
    LOCATION_BK,
    PARTY_BK,
    ROLE_TYPE_CODE,
    first_value(AUG_COMMON_ADMIN_GEOGRAPHY__COMMERCIAL_REGISTRATION_ZONE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_ADMIN_GEOGRAPHY__COMMERCIAL_REGISTRATION_ZONE,
    first_value(AUG_COMMON_ADMIN_GEOGRAPHY__EFFECTIVE_DATE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_ADMIN_GEOGRAPHY__EFFECTIVE_DATE,
    first_value(AUG_COMMON_ADMIN_GEOGRAPHY__EXPIRY_DATE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_ADMIN_GEOGRAPHY__EXPIRY_DATE,
    first_value(AUG_COMMON_ADMIN_GEOGRAPHY__REGISTRATION_ZONE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_ADMIN_GEOGRAPHY__REGISTRATION_ZONE,
    first_value(AUG_COMMON_ADMIN_GEOGRAPHY__RTO_CLUSTER_CODE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_ADMIN_GEOGRAPHY__RTO_CLUSTER_CODE,
    first_value(COMMON_ADDRESS__ADDRESS_LINE_1) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__ADDRESS_LINE_1,
    first_value(COMMON_ADDRESS__ADDRESS_LINE_2) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__ADDRESS_LINE_2,
    first_value(COMMON_ADDRESS__ADDRESS_LINE_3) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__ADDRESS_LINE_3,
    first_value(COMMON_ADDRESS__CARE_OF_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__CARE_OF_NAME,
    first_value(COMMON_ADDRESS__CITY) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__CITY,
    first_value(COMMON_ADDRESS__COUNTRY_CODE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__COUNTRY_CODE,
    first_value(COMMON_ADDRESS__COUNTRY_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__COUNTRY_NAME,
    first_value(COMMON_ADDRESS__LANDMARK) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__LANDMARK,
    first_value(COMMON_ADDRESS__LOCALITY) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__LOCALITY,
    first_value(COMMON_ADDRESS__POSTAL_CODE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__POSTAL_CODE,
    first_value(COMMON_ADDRESS__POST_OFFICE_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__POST_OFFICE_NAME,
    first_value(COMMON_ADDRESS__STATE_CODE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__STATE_CODE,
    first_value(COMMON_ADDRESS__STATE_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__STATE_NAME,
    first_value(COMMON_ADDRESS__STREET_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__STREET_NAME,
    LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
    first_value(LNK_ROLE_NOMINEE_BENEFICIARY__APPOINTEE_NAME) ignore nulls over (partition by PARTY_BK, LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_NOMINEE_BENEFICIARY__APPOINTEE_NAME,
    first_value(LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED) ignore nulls over (partition by PARTY_BK, LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED,
    first_value(LOCATION_PROFILE__CONNECTIVITY_GRADE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOCATION_PROFILE__CONNECTIVITY_GRADE,
    first_value(LOCATION_PROFILE__LOCATION_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOCATION_PROFILE__LOCATION_NAME,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.INC_JOB_UPDATED_AT,
    -- multi-active satellites on PARTY_BK (SAT_LNK_ROLE_NOMINEE_BENEFICIARY):
    -- one load time per PARTY_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.LNK_ROLE_NOMINEE_BENEFICIARY__APPOINTEE_NAME, m.LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.PARTY_BK) as PARTY_BK__MA_LOAD_DATETIME
from merged m
