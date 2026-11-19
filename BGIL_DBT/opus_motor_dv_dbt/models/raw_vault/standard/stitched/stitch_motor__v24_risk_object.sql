-- CENTRAL VIEW v24_risk_object -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BA_QUOTE_MOT_DTLS
--   BGIL_MOTOR_WEBSERVICE_INFO_EQM
--   BGIL_MOTOR_WS_PLAN_DETAILS_EQM
--   BJAZ_AGENCY_MOT_WAR_DTLS
--   BJAZ_CVTP_WS_DATA
--   BJAZ_MOTORTHEFT_CASE_DTLS
--   BJAZ_MOTOR_WEBSERVICE_INFO
--   BJAZ_MOTOR_WS_PLAN_DETAILS
--   BJAZ_MOT_ONLINE_POL_DTLS
--   BJAZ_MOT_RENEWAL_EXTN
--   BJAZ_MOT_RENEWAL_HIST
--   BJAZ_MOT_RNW_LOADER_DATA
--   BJAZ_MOT_WINBACK_DTLS
--   BJAZ_MOT_WS_POL_DTLS
--   BJAZ_SCR_MOT_VEH_DTLS
--   BJAZ_WAP_MOT_ADD_QSTN_DTLS
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_MOTOR_AUG_PROPOSAL_DECLARATIONS
--   SAT_MOTOR_AUG_PROPOSAL_HEADER
--   SAT_MOTOR_AUG_RISK_OBJECT_VALUATION
--   SAT_RISK_MOTOR_IDV
--   SAT_RISK_OBJECT_INSURABLE_INTEREST
--   SAT_RISK_OBJECT_VALUATION
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_PROPOSAL_RISK_OBJECT
-- OVER the table limit by rule 3: one satellite on this view needs every feeding table.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BA_QUOTE_MOT_DTLS
    select
        cast(null as varchar) as PROPOSAL_BK,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.vehicle_reg_no), '')), '') as RISK_OBJECT_BK,
        cast(null as number) as __LNK_PROPOSAL_RISK_OBJECT,
        cast(null as varchar) as AUG_PROPOSAL_DECLARATIONS__EXISTING_MOTOR_POLICY_NUMBER,
        cast(null as varchar) as AUG_PROPOSAL_DECLARATIONS__EXISTING_NON_MOTOR_POLICY_INDICATOR,
        cast(null as varchar) as AUG_PROPOSAL_DECLARATIONS__EXISTING_NON_MOTOR_POLICY_NUMBER,
        cast(null as varchar) as AUG_PROPOSAL_DECLARATIONS__PREVIOUS_OWN_DAMAGE_CLAIM_AMOUNT,
        cast(null as varchar) as AUG_PROPOSAL_DECLARATIONS__PREVIOUS_OWN_DAMAGE_CLAIM_COUNT,
        cast(null as varchar) as AUG_PROPOSAL_DECLARATIONS__PREVIOUS_THEFT_CLAIM_INDICATOR,
        cast(null as varchar) as AUG_PROPOSAL_DECLARATIONS__PREVIOUS_THIRD_PARTY_CLAIM_AMOUNT,
        cast(null as varchar) as AUG_PROPOSAL_DECLARATIONS__PREVIOUS_THIRD_PARTY_CLAIM_COUNT,
        cast(null as varchar) as AUG_PROPOSAL_DECLARATIONS__PREVIOUS_TOTAL_LOSS_CLAIM_INDICATOR,
        cast(null as varchar) as AUG_PROPOSAL_HEADER__COVER_PACKAGE_CODE,
        cast(null as varchar) as AUG_PROPOSAL_HEADER__COVER_PACKAGE_DESCRIPTION,
        cast(null as varchar) as AUG_PROPOSAL_HEADER__EXTERNAL_PARTNER_REQUEST_REFERENCE,
        cast(null as varchar) as AUG_PROPOSAL_HEADER__LEAD_REFERENCE_NUMBER,
        cast(null as varchar) as AUG_PROPOSAL_HEADER__MOTOR_WEB_SERVICE_TRANSACTION_REFERENCE,
        cast(null as varchar) as AUG_PROPOSAL_HEADER__SALES_ORDER_FORM_REFERENCE_NUMBER,
        cast(null as varchar) as AUG_PROPOSAL_HEADER__SOURCE_SYSTEM_REFERENCE_NUMBER,
        cast(null as varchar) as AUG_RISK_OBJECT_VALUATION__CUBIC_METRE_DECLARED_VALUE,
        cast(null as varchar) as AUG_RISK_OBJECT_VALUATION__EXPECTED_RESALE_VALUE_FROM,
        cast(null as varchar) as AUG_RISK_OBJECT_VALUATION__EXPECTED_RESALE_VALUE_TO,
        t0.vehicle_iev as RISK_MOTOR_IDV__AGREED_IDV,
        cast(null as varchar) as RISK_MOTOR_IDV__CNG_KIT_IDV,
        cast(null as varchar) as RISK_MOTOR_IDV__COMPUTED_IDV,
        cast(null as varchar) as RISK_MOTOR_IDV__DEPRECIATION_PERCENTAGE,
        cast(null as varchar) as RISK_MOTOR_IDV__EX_SHOWROOM_PRICE,
        cast(null as varchar) as RISK_MOTOR_IDV__IDV_BASIS,
        cast(null as varchar) as RISK_MOTOR_IDV__IDV_BASIS_INDICATOR,
        cast(null as varchar) as RISK_MOTOR_IDV__TOTAL_IDV,
        cast(null as varchar) as RISK_MOTOR_IDV__VEHICLE_AGE,
        cast(null as varchar) as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
        cast(null as varchar) as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK,
        cast(null as varchar) as RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_NAME,
        cast(null as varchar) as RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_INDICATOR,
        cast(null as varchar) as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE,
        cast(null as varchar) as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE,
        cast(null as varchar) as RISK_OBJECT_VALUATION__DECLARED_VALUE,
        cast(null as varchar) as RISK_OBJECT_VALUATION__DEPRECIATION_PERCENTAGE,
        cast(null as varchar) as RISK_OBJECT_VALUATION__MARKET_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.vehicle_reg_no), '')), '')) is not null

    union all

    -- branch 1: BGIL_MOTOR_WEBSERVICE_INFO_EQM
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_iev as RISK_MOTOR_IDV__AGREED_IDV,
        null,
        t0.sys_vehicle_idv as RISK_MOTOR_IDV__COMPUTED_IDV,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_webservice_info_eqm') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 2: BGIL_MOTOR_WS_PLAN_DETAILS_EQM
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_idv as RISK_MOTOR_IDV__AGREED_IDV,
        null, null, null, null, null, null, null, null,
        t0.tp_fin_type as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
        null, null,
        t0.hypo as RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_INDICATOR,
        null,
        t0.tp_fin_type as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_plan_details_eqm') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 3: BJAZ_AGENCY_MOT_WAR_DTLS
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.veh_reg_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.veh_invoice_price as RISK_MOTOR_IDV__EX_SHOWROOM_PRICE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_agency_mot_war_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.veh_reg_no), '')), '')) is not null

    union all

    -- branch 4: BJAZ_CVTP_WS_DATA
    select
        nullif(nullif(trim(t0.insproposalno), ''), '') as PROPOSAL_BK,
        nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.visofnumber as AUG_PROPOSAL_HEADER__SALES_ORDER_FORM_REFERENCE_NUMBER,
        t0.transactionid as AUG_PROPOSAL_HEADER__SOURCE_SYSTEM_REFERENCE_NUMBER,
        null, null, null, null,
        t0.bifuelkitidv as RISK_MOTOR_IDV__CNG_KIT_IDV,
        t0.vehicleidv as RISK_MOTOR_IDV__COMPUTED_IDV,
        null,
        t0.exshowroomprice as RISK_MOTOR_IDV__EX_SHOWROOM_PRICE,
        null, null,
        t0.totalidv as RISK_MOTOR_IDV__TOTAL_IDV,
        null,
        t0.aggrementtype as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
        t0.financercode as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK,
        null, null,
        t0.financercode as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE,
        t0.aggrementtype as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), ''), nullif(nullif(trim(t0.insproposalno), ''), ''))) is not null

    union all

    -- branch 5: BJAZ_MOTORTHEFT_CASE_DTLS
    select
        null,
        nullif(nullif(trim(t0.engine_no), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.resale_range_from as AUG_RISK_OBJECT_VALUATION__EXPECTED_RESALE_VALUE_FROM,
        t0.resale_range_to as AUG_RISK_OBJECT_VALUATION__EXPECTED_RESALE_VALUE_TO,
        null, null, null, null,
        t0.ex_showroom_price as RISK_MOTOR_IDV__EX_SHOWROOM_PRICE,
        null, null, null,
        t0.vehicle_age as RISK_MOTOR_IDV__VEHICLE_AGE,
        null, null, null, null, null, null, null,
        t0.vehicle_depreciation_cons as RISK_OBJECT_VALUATION__DEPRECIATION_PERCENTAGE,
        t0.vehicle_value as RISK_OBJECT_VALUATION__MARKET_VALUE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.engine_no), ''), '')) is not null

    union all

    -- branch 6: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): RISK_OBJECT_INSURABLE_INTEREST.Interest Type=HYPOTHECATION
    select
        null,
        nullif(nullif(trim(t0.engine_no), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'HYPOTHECATION' as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
        null, null,
        t0.hypothecated as RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_INDICATOR,
        null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(t0.engine_no), ''), '')) is not null

    union all

    -- branch 7: BJAZ_MOTOR_WEBSERVICE_INFO
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_iev as RISK_MOTOR_IDV__AGREED_IDV,
        null,
        t0.sys_vehicle_idv as RISK_MOTOR_IDV__COMPUTED_IDV,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_webservice_info') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 8: BJAZ_MOTOR_WS_PLAN_DETAILS
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_idv as RISK_MOTOR_IDV__AGREED_IDV,
        null, null, null, null, null, null, null, null,
        t0.tp_fin_type as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
        null, null,
        t0.hypo as RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_INDICATOR,
        null,
        t0.tp_fin_type as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_plan_details') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 9: BJAZ_MOT_ONLINE_POL_DTLS
    select
        nullif(nullif(trim(to_char(t0.reference_id)), ''), '') as PROPOSAL_BK,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.bafl_request_id as AUG_PROPOSAL_HEADER__EXTERNAL_PARTNER_REQUEST_REFERENCE,
        null, null, null, null, null, null, null,
        t0.your_idv_value as RISK_MOTOR_IDV__AGREED_IDV,
        null,
        t0.system_iev as RISK_MOTOR_IDV__COMPUTED_IDV,
        null, null, null, null,
        t0.vehicle_iev as RISK_MOTOR_IDV__TOTAL_IDV,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), ''), nullif(nullif(trim(to_char(t0.reference_id)), ''), ''))) is not null

    union all

    -- branch 10: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): RISK_OBJECT_INSURABLE_INTEREST.Interest Type=HYPOTHECATION
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'HYPOTHECATION' as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
        null,
        t0.financier_name as RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_NAME,
        null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 11: BJAZ_MOT_ONLINE_POL_DTLS
    select
        null,
        nullif(nullif('APPLIANCE:' || nullif(trim(to_char(t0.serial_no)), ''), 'APPLIANCE:'), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.invoice_amount as RISK_OBJECT_VALUATION__DECLARED_VALUE,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif('APPLIANCE:' || nullif(trim(to_char(t0.serial_no)), ''), 'APPLIANCE:'), '')) is not null

    union all

    -- branch 12: BJAZ_MOT_RENEWAL_EXTN
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.vehicle_age as RISK_MOTOR_IDV__VEHICLE_AGE,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 13: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): RISK_OBJECT_INSURABLE_INTEREST.Interest Type=HYPOTHECATION
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'HYPOTHECATION' as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
        null,
        t0.financier_name as RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_NAME,
        null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 14: BJAZ_MOT_RENEWAL_HIST
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.veh_idv as RISK_MOTOR_IDV__AGREED_IDV,
        null,
        t0.sys_calc_idv as RISK_MOTOR_IDV__COMPUTED_IDV,
        t0.depricate_rate as RISK_MOTOR_IDV__DEPRECIATION_PERCENTAGE,
        t0.ex_showroom_price as RISK_MOTOR_IDV__EX_SHOWROOM_PRICE,
        t0.flag_for_idv as RISK_MOTOR_IDV__IDV_BASIS,
        t0.idv_flag as RISK_MOTOR_IDV__IDV_BASIS_INDICATOR,
        null,
        t0.vehicle_age as RISK_MOTOR_IDV__VEHICLE_AGE,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 15: BJAZ_MOT_RNW_LOADER_DATA
    select
        null,
        nullif(nullif(trim(t0.reg_no), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.veh_idv as RISK_MOTOR_IDV__TOTAL_IDV,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_rnw_loader_data') }} t0
    where (nullif(nullif(trim(t0.reg_no), ''), '')) is not null

    union all

    -- branch 16: BJAZ_MOT_WINBACK_DTLS
    select
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as PROPOSAL_BK,
        nullif(nullif(trim(t0.registration_no), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.ref_id as AUG_PROPOSAL_HEADER__LEAD_REFERENCE_NUMBER,
        null, null, null, null, null, null, null, null,
        t0.veh_idv as RISK_MOTOR_IDV__COMPUTED_IDV,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_winback_dtls') }} t0
    where (coalesce(nullif(nullif(trim(t0.registration_no), ''), ''), nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), ''))) is not null

    union all

    -- branch 17: BJAZ_MOT_WS_POL_DTLS
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cbm_val as AUG_RISK_OBJECT_VALUATION__CUBIC_METRE_DECLARED_VALUE,
        null, null,
        t0.vehicle_iev as RISK_MOTOR_IDV__AGREED_IDV,
        null,
        t0.system_iev as RISK_MOTOR_IDV__COMPUTED_IDV,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 18: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): RISK_OBJECT_INSURABLE_INTEREST.Interest Type=HYPOTHECATION
    select
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'HYPOTHECATION' as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
        null,
        t0.financier_name as RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_NAME,
        null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 19: BJAZ_SCR_MOT_VEH_DTLS
    select
        null,
        nullif(coalesce(nullif(trim(t0.chasis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cng_si as RISK_MOTOR_IDV__CNG_KIT_IDV,
        t0.vehicle_idv as RISK_MOTOR_IDV__COMPUTED_IDV,
        t0.further_dep_rate as RISK_MOTOR_IDV__DEPRECIATION_PERCENTAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        14 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_scr_mot_veh_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chasis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 20: BJAZ_WAP_MOT_ADD_QSTN_DTLS
    select
        nullif(nullif('WAP:' || nullif(trim(to_char(t0.trans_id)), ''), 'WAP:'), '') as PROPOSAL_BK,
        nullif(nullif(trim(coalesce(t0.reg_no_part1, '') || coalesce(t0.reg_no_part2, '') || coalesce(t0.reg_no_part3, '') || coalesce(t0.reg_no_part4, '')), ''), '') as RISK_OBJECT_BK,
        1 as __LNK_PROPOSAL_RISK_OBJECT,
        t0.bagic_mot_pol as AUG_PROPOSAL_DECLARATIONS__EXISTING_MOTOR_POLICY_NUMBER,
        t0.bagic_nonmot_pol_yn as AUG_PROPOSAL_DECLARATIONS__EXISTING_NON_MOTOR_POLICY_INDICATOR,
        t0.bagic_nonmot_pol as AUG_PROPOSAL_DECLARATIONS__EXISTING_NON_MOTOR_POLICY_NUMBER,
        t0.od_claim_amt as AUG_PROPOSAL_DECLARATIONS__PREVIOUS_OWN_DAMAGE_CLAIM_AMOUNT,
        t0.od_claim as AUG_PROPOSAL_DECLARATIONS__PREVIOUS_OWN_DAMAGE_CLAIM_COUNT,
        t0.theft_indicator as AUG_PROPOSAL_DECLARATIONS__PREVIOUS_THEFT_CLAIM_INDICATOR,
        t0.tp_claim_amt as AUG_PROPOSAL_DECLARATIONS__PREVIOUS_THIRD_PARTY_CLAIM_AMOUNT,
        t0.tp_claim as AUG_PROPOSAL_DECLARATIONS__PREVIOUS_THIRD_PARTY_CLAIM_COUNT,
        t0.total_claim_indicator as AUG_PROPOSAL_DECLARATIONS__PREVIOUS_TOTAL_LOSS_CLAIM_INDICATOR,
        t0.package_id as AUG_PROPOSAL_HEADER__COVER_PACKAGE_CODE,
        t0.package_desc as AUG_PROPOSAL_HEADER__COVER_PACKAGE_DESCRIPTION,
        null, null,
        t0.motor_ws_trans_id as AUG_PROPOSAL_HEADER__MOTOR_WEB_SERVICE_TRANSACTION_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.veh_age as RISK_MOTOR_IDV__VEHICLE_AGE,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        15 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wap_mot_add_qstn_dtls') }} t0
    where (coalesce(nullif(nullif('WAP:' || nullif(trim(to_char(t0.trans_id)), ''), 'WAP:'), ''), nullif(nullif(trim(coalesce(t0.reg_no_part1, '') || coalesce(t0.reg_no_part2, '') || coalesce(t0.reg_no_part3, '') || coalesce(t0.reg_no_part4, '')), ''), ''))) is not null

)

select
    PROPOSAL_BK,
    RISK_OBJECT_BK,
    __LNK_PROPOSAL_RISK_OBJECT,
    first_value(AUG_PROPOSAL_DECLARATIONS__EXISTING_MOTOR_POLICY_NUMBER) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_DECLARATIONS__EXISTING_MOTOR_POLICY_NUMBER,
    first_value(AUG_PROPOSAL_DECLARATIONS__EXISTING_NON_MOTOR_POLICY_INDICATOR) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_DECLARATIONS__EXISTING_NON_MOTOR_POLICY_INDICATOR,
    first_value(AUG_PROPOSAL_DECLARATIONS__EXISTING_NON_MOTOR_POLICY_NUMBER) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_DECLARATIONS__EXISTING_NON_MOTOR_POLICY_NUMBER,
    first_value(AUG_PROPOSAL_DECLARATIONS__PREVIOUS_OWN_DAMAGE_CLAIM_AMOUNT) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_DECLARATIONS__PREVIOUS_OWN_DAMAGE_CLAIM_AMOUNT,
    first_value(AUG_PROPOSAL_DECLARATIONS__PREVIOUS_OWN_DAMAGE_CLAIM_COUNT) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_DECLARATIONS__PREVIOUS_OWN_DAMAGE_CLAIM_COUNT,
    first_value(AUG_PROPOSAL_DECLARATIONS__PREVIOUS_THEFT_CLAIM_INDICATOR) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_DECLARATIONS__PREVIOUS_THEFT_CLAIM_INDICATOR,
    first_value(AUG_PROPOSAL_DECLARATIONS__PREVIOUS_THIRD_PARTY_CLAIM_AMOUNT) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_DECLARATIONS__PREVIOUS_THIRD_PARTY_CLAIM_AMOUNT,
    first_value(AUG_PROPOSAL_DECLARATIONS__PREVIOUS_THIRD_PARTY_CLAIM_COUNT) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_DECLARATIONS__PREVIOUS_THIRD_PARTY_CLAIM_COUNT,
    first_value(AUG_PROPOSAL_DECLARATIONS__PREVIOUS_TOTAL_LOSS_CLAIM_INDICATOR) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_DECLARATIONS__PREVIOUS_TOTAL_LOSS_CLAIM_INDICATOR,
    first_value(AUG_PROPOSAL_HEADER__COVER_PACKAGE_CODE) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_HEADER__COVER_PACKAGE_CODE,
    first_value(AUG_PROPOSAL_HEADER__COVER_PACKAGE_DESCRIPTION) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_HEADER__COVER_PACKAGE_DESCRIPTION,
    first_value(AUG_PROPOSAL_HEADER__EXTERNAL_PARTNER_REQUEST_REFERENCE) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_HEADER__EXTERNAL_PARTNER_REQUEST_REFERENCE,
    first_value(AUG_PROPOSAL_HEADER__LEAD_REFERENCE_NUMBER) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_HEADER__LEAD_REFERENCE_NUMBER,
    first_value(AUG_PROPOSAL_HEADER__MOTOR_WEB_SERVICE_TRANSACTION_REFERENCE) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_HEADER__MOTOR_WEB_SERVICE_TRANSACTION_REFERENCE,
    first_value(AUG_PROPOSAL_HEADER__SALES_ORDER_FORM_REFERENCE_NUMBER) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_HEADER__SALES_ORDER_FORM_REFERENCE_NUMBER,
    first_value(AUG_PROPOSAL_HEADER__SOURCE_SYSTEM_REFERENCE_NUMBER) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_HEADER__SOURCE_SYSTEM_REFERENCE_NUMBER,
    first_value(AUG_RISK_OBJECT_VALUATION__CUBIC_METRE_DECLARED_VALUE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_OBJECT_VALUATION__CUBIC_METRE_DECLARED_VALUE,
    first_value(AUG_RISK_OBJECT_VALUATION__EXPECTED_RESALE_VALUE_FROM) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_OBJECT_VALUATION__EXPECTED_RESALE_VALUE_FROM,
    first_value(AUG_RISK_OBJECT_VALUATION__EXPECTED_RESALE_VALUE_TO) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_OBJECT_VALUATION__EXPECTED_RESALE_VALUE_TO,
    first_value(RISK_MOTOR_IDV__AGREED_IDV) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_IDV__AGREED_IDV,
    first_value(RISK_MOTOR_IDV__CNG_KIT_IDV) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_IDV__CNG_KIT_IDV,
    first_value(RISK_MOTOR_IDV__COMPUTED_IDV) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_IDV__COMPUTED_IDV,
    first_value(RISK_MOTOR_IDV__DEPRECIATION_PERCENTAGE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_IDV__DEPRECIATION_PERCENTAGE,
    first_value(RISK_MOTOR_IDV__EX_SHOWROOM_PRICE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_IDV__EX_SHOWROOM_PRICE,
    first_value(RISK_MOTOR_IDV__IDV_BASIS) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_IDV__IDV_BASIS,
    first_value(RISK_MOTOR_IDV__IDV_BASIS_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_IDV__IDV_BASIS_INDICATOR,
    first_value(RISK_MOTOR_IDV__TOTAL_IDV) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_IDV__TOTAL_IDV,
    first_value(RISK_MOTOR_IDV__VEHICLE_AGE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_IDV__VEHICLE_AGE,
    RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
    RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK,
    first_value(RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_NAME) ignore nulls over (partition by RISK_OBJECT_BK, RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK, RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_NAME,
    first_value(RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK, RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK, RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_INDICATOR,
    first_value(RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE) ignore nulls over (partition by RISK_OBJECT_BK, RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK, RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE,
    first_value(RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE) ignore nulls over (partition by RISK_OBJECT_BK, RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK, RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE,
    first_value(RISK_OBJECT_VALUATION__DECLARED_VALUE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_VALUATION__DECLARED_VALUE,
    first_value(RISK_OBJECT_VALUATION__DEPRECIATION_PERCENTAGE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_VALUATION__DEPRECIATION_PERCENTAGE,
    first_value(RISK_OBJECT_VALUATION__MARKET_VALUE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_VALUATION__MARKET_VALUE,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.INC_JOB_UPDATED_AT,
    -- multi-active satellites on RISK_OBJECT_BK (SAT_RISK_OBJECT_INSURABLE_INTEREST):
    -- one load time per RISK_OBJECT_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_NAME, m.RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_INDICATOR, m.RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE, m.RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.RISK_OBJECT_BK) as RISK_OBJECT_BK__MA_LOAD_DATETIME
from merged m
