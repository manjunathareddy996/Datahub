-- CENTRAL VIEW v08_org_unit -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BGIL_MOTOR_WS_PLAN_DETAILS_EQM
--   BJAZ_CLM_SUBFILE_MOT_EXT
--   BJAZ_MOTOR_WS_PLAN_DETAILS
--   BJAZ_MOT_ONLINE_POL_DTLS
--   BJAZ_MOT_RENEWAL_EXTN
--   BJAZ_MOT_UW_BRANCH_GROUP_MST
--   BJAZ_MOT_WAR_CHILD_DTLS
--   BJAZ_MOT_WS_POL_DTLS
--   BJAZ_WAP_MOT_GS_ACT_DTLS
--   BJAZ_WB_CLM_BASE_MOT_EXT
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_MOTOR_AUG_COMMON_ADDRESS
--   SAT_MOTOR_AUG_ORG_UNIT_DEFINITION
--   SAT_MOTOR_AUG_RISK_EXTENDED_WARRANTY
--   SAT_ORG_UNIT_DEFINITION
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_FINTXN_POLICY
--   LNK_POLICY_PRODUCT
--   LNK_POLICY_RISK_OBJECT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BGIL_MOTOR_WS_PLAN_DETAILS_EQM
    select
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as FINANCIAL_TRANSACTION_BK,
        cast(null as varchar) as LOCATION_BK,
        nullif(nullif('DEPT:' || nullif(trim(to_char(t0.dept_code)), ''), 'DEPT:'), '') as ORG_UNIT_BK,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), '') as PRODUCT_BK,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        1 as __LNK_FINTXN_POLICY,
        1 as __LNK_POLICY_PRODUCT,
        1 as __LNK_POLICY_RISK_OBJECT,
        cast(null as varchar) as AUG_COMMON_ADDRESS__ADDRESS_LINE4,
        cast(null as varchar) as AUG_COMMON_ADDRESS__ADDRESS_LINE_5,
        cast(null as varchar) as AUG_COMMON_ADDRESS__CITY_OTHER_TEXT,
        cast(null as varchar) as AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT,
        cast(null as varchar) as AUG_COMMON_ADDRESS__LOCALITY_OTHER_TEXT,
        cast(null as varchar) as AUG_COMMON_ADDRESS__SAME_AS_RISK_ADDRESS_INDICATOR,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__BRANCH_GROUP_EFFECTIVE_DATE,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__DEPARTMENT_CODE,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__SECONDARY_DEPARTMENT_CODE,
        cast(null as varchar) as AUG_RISK_EXTENDED_WARRANTY__MANUFACTURER_WARRANTY_PERIOD,
        cast(null as varchar) as AUG_RISK_EXTENDED_WARRANTY__MANUFACTURER_WARRANTY_TERM_MONTHS,
        cast(null as varchar) as AUG_RISK_EXTENDED_WARRANTY__WARRANTY_INVOICE_DATE,
        t0.dept_code as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_STATUS,
        cast(null as varchar) as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ZONE_NAME,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_plan_details_eqm') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), ''), nullif(nullif('DEPT:' || nullif(trim(to_char(t0.dept_code)), ''), 'DEPT:'), ''), nullif(nullif(trim(to_char(t0.contract_id)), ''), ''), nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), ''), nullif(nullif(trim(to_char(t0.transactionid)), ''), ''))) is not null

    union all

    -- branch 1: BGIL_MOTOR_WS_PLAN_DETAILS_EQM
    select
        null, null,
        nullif(nullif('BRANCH:' || nullif(trim(to_char(t0.branch_code)), ''), 'BRANCH:'), '') as ORG_UNIT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.branch_code as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
        null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_plan_details_eqm') }} t0
    where (nullif(nullif('BRANCH:' || nullif(trim(to_char(t0.branch_code)), ''), 'BRANCH:'), '')) is not null

    union all

    -- branch 2: BJAZ_CLM_SUBFILE_MOT_EXT
    select
        null,
        nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.police_station_address, ''), '')), '[[:space:]]+', ' ')), ''), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null,
        t0.police_station_address as AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_subfile_mot_ext') }} t0
    where (nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.police_station_address, ''), '')), '[[:space:]]+', ' ')), ''), '')) is not null

    union all

    -- branch 3: BJAZ_MOTOR_WS_PLAN_DETAILS
    select
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as FINANCIAL_TRANSACTION_BK,
        null,
        nullif(nullif('DEPT:' || nullif(trim(to_char(t0.dept_code)), ''), 'DEPT:'), '') as ORG_UNIT_BK,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), '') as PRODUCT_BK,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        1 as __LNK_FINTXN_POLICY,
        1 as __LNK_POLICY_PRODUCT,
        1 as __LNK_POLICY_RISK_OBJECT,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.dept_code as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
        null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_plan_details') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), ''), nullif(nullif('DEPT:' || nullif(trim(to_char(t0.dept_code)), ''), 'DEPT:'), ''), nullif(nullif(trim(to_char(t0.contract_id)), ''), ''), nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), ''), nullif(nullif(trim(to_char(t0.transactionid)), ''), ''))) is not null

    union all

    -- branch 4: BJAZ_MOTOR_WS_PLAN_DETAILS
    select
        null, null,
        nullif(nullif('BRANCH:' || nullif(trim(to_char(t0.branch_code)), ''), 'BRANCH:'), '') as ORG_UNIT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.branch_code as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
        null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_plan_details') }} t0
    where (nullif(nullif('BRANCH:' || nullif(trim(to_char(t0.branch_code)), ''), 'BRANCH:'), '')) is not null

    union all

    -- branch 5: BJAZ_MOT_ONLINE_POL_DTLS
    select
        null,
        nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.address_line1, '') || '|' || coalesce(t0.address_line2, '') || '|' || coalesce(t0.area, '') || '|' || coalesce(t0.city, '') || '|' || coalesce(t0.state, '') || '|' || coalesce(t0.postcode, ''), '|||||')), '[[:space:]]+', ' ')), ''), '') as LOCATION_BK,
        nullif(nullif(trim(to_char(t0.department_code)), ''), '') as ORG_UNIT_BK,
        null, null,
        nullif(nullif('APPLIANCE:' || nullif(trim(to_char(t0.serial_no)), ''), 'APPLIANCE:'), '') as RISK_OBJECT_BK,
        null, null, null,
        t0.address_line6 as AUG_COMMON_ADDRESS__ADDRESS_LINE4,
        null,
        t0.other_city as AUG_COMMON_ADDRESS__CITY_OTHER_TEXT,
        null,
        t0.other_area as AUG_COMMON_ADDRESS__LOCALITY_OTHER_TEXT,
        null, null, null, null, null,
        t0.mnfg_warranty as AUG_RISK_EXTENDED_WARRANTY__MANUFACTURER_WARRANTY_TERM_MONTHS,
        t0.date_of_invoice as AUG_RISK_EXTENDED_WARRANTY__WARRANTY_INVOICE_DATE,
        t0.dept_code as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
        null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (coalesce(nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.address_line1, '') || '|' || coalesce(t0.address_line2, '') || '|' || coalesce(t0.area, '') || '|' || coalesce(t0.city, '') || '|' || coalesce(t0.state, '') || '|' || coalesce(t0.postcode, ''), '|||||')), '[[:space:]]+', ' ')), ''), ''), nullif(nullif('APPLIANCE:' || nullif(trim(to_char(t0.serial_no)), ''), 'APPLIANCE:'), ''), nullif(nullif(trim(to_char(t0.department_code)), ''), ''))) is not null

    union all

    -- branch 6: BJAZ_MOT_ONLINE_POL_DTLS
    select
        null,
        nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.disp_address_line1, '') || '|' || coalesce(t0.disp_address_line2, '') || '|' || coalesce(t0.disp_area, '') || '|' || coalesce(t0.disp_city, '') || '|' || coalesce(t0.disp_state, '') || '|' || coalesce(t0.disppostcode, ''), '|||||')), '[[:space:]]+', ' ')), ''), '') as LOCATION_BK,
        null, null, null, null, null, null, null,
        t0.disp_address_line6 as AUG_COMMON_ADDRESS__ADDRESS_LINE4,
        null, null, null,
        t0.disp_other_area as AUG_COMMON_ADDRESS__LOCALITY_OTHER_TEXT,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.disp_address_line1, '') || '|' || coalesce(t0.disp_address_line2, '') || '|' || coalesce(t0.disp_area, '') || '|' || coalesce(t0.disp_city, '') || '|' || coalesce(t0.disp_state, '') || '|' || coalesce(t0.disppostcode, ''), '|||||')), '[[:space:]]+', ' ')), ''), '')) is not null

    union all

    -- branch 7: BJAZ_MOT_RENEWAL_EXTN
    select
        null,
        nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.cust_add1, '') || '|' || coalesce(t0.cust_add2, '') || '|' || coalesce(t0.cust_add3, '') || '|' || coalesce(t0.cust_add4, '') || '|' || coalesce(t0.cust_add5, '') || '|' || coalesce(to_char(t0.postcode), ''), '|||||')), '[[:space:]]+', ' ')), ''), '') as LOCATION_BK,
        null, null, null, null, null, null, null,
        t0.cust_add4 as AUG_COMMON_ADDRESS__ADDRESS_LINE4,
        t0.cust_add5 as AUG_COMMON_ADDRESS__ADDRESS_LINE_5,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.cust_add1, '') || '|' || coalesce(t0.cust_add2, '') || '|' || coalesce(t0.cust_add3, '') || '|' || coalesce(t0.cust_add4, '') || '|' || coalesce(t0.cust_add5, '') || '|' || coalesce(to_char(t0.postcode), ''), '|||||')), '[[:space:]]+', ' ')), ''), '')) is not null

    union all

    -- branch 8: BJAZ_MOT_UW_BRANCH_GROUP_MST
    select
        null, null,
        nullif(nullif(trim(to_char(t0.branch_code)), ''), '') as ORG_UNIT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.effective_date as AUG_ORG_UNIT_DEFINITION__BRANCH_GROUP_EFFECTIVE_DATE,
        null, null, null, null, null, null, null,
        t0.status as ORG_UNIT_DEFINITION__ORG_UNIT_STATUS,
        t0.group_code as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
        t0.zone as ORG_UNIT_DEFINITION__ZONE_NAME,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_uw_branch_group_mst') }} t0
    where (nullif(nullif(trim(to_char(t0.branch_code)), ''), '')) is not null

    union all

    -- branch 9: BJAZ_MOT_WAR_CHILD_DTLS
    select
        null, null,
        nullif(nullif(trim(t0.outlet_code), ''), '') as ORG_UNIT_BK,
        null, null,
        nullif(coalesce(nullif(trim(t0.vehicle_reg_no), ''), nullif(trim(t0.equipment_serial_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.mfg_warranty_period as AUG_RISK_EXTENDED_WARRANTY__MANUFACTURER_WARRANTY_PERIOD,
        null, null, null,
        t0.vehicle_sold_from as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_war_child_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.vehicle_reg_no), ''), nullif(trim(t0.equipment_serial_no), '')), ''), nullif(nullif(trim(t0.outlet_code), ''), ''))) is not null

    union all

    -- branch 10: BJAZ_MOT_WS_POL_DTLS
    select
        null,
        nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.address_line1, '') || '|' || coalesce(t0.address_line2, '') || '|' || coalesce(t0.city, '') || '|' || coalesce(t0.state, '') || '|' || coalesce(t0.postcode, ''), '||||')), '[[:space:]]+', ' ')), ''), '') as LOCATION_BK,
        nullif(nullif(trim(to_char(t0.company_org_unit)), ''), '') as ORG_UNIT_BK,
        null, null, null, null, null, null,
        t0.address_line6 as AUG_COMMON_ADDRESS__ADDRESS_LINE4,
        null,
        t0.other_city as AUG_COMMON_ADDRESS__CITY_OTHER_TEXT,
        null,
        t0.other_area as AUG_COMMON_ADDRESS__LOCALITY_OTHER_TEXT,
        null, null,
        t0.department_code as AUG_ORG_UNIT_DEFINITION__DEPARTMENT_CODE,
        t0.dept_code as AUG_ORG_UNIT_DEFINITION__SECONDARY_DEPARTMENT_CODE,
        null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (coalesce(nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.address_line1, '') || '|' || coalesce(t0.address_line2, '') || '|' || coalesce(t0.city, '') || '|' || coalesce(t0.state, '') || '|' || coalesce(t0.postcode, ''), '||||')), '[[:space:]]+', ' ')), ''), ''), nullif(nullif(trim(to_char(t0.company_org_unit)), ''), ''))) is not null

    union all

    -- branch 11: BJAZ_MOT_WS_POL_DTLS
    select
        null,
        nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.disp_address_line1, '') || '|' || coalesce(t0.disp_address_line2, '') || '|' || coalesce(t0.disp_city, '') || '|' || coalesce(t0.disp_state, '') || '|' || coalesce(t0.disppostcode, ''), '||||')), '[[:space:]]+', ' ')), ''), '') as LOCATION_BK,
        null, null, null, null, null, null, null,
        t0.disp_address_line6 as AUG_COMMON_ADDRESS__ADDRESS_LINE4,
        null, null, null,
        t0.disp_other_area as AUG_COMMON_ADDRESS__LOCALITY_OTHER_TEXT,
        t0.same_mailing_address as AUG_COMMON_ADDRESS__SAME_AS_RISK_ADDRESS_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.disp_address_line1, '') || '|' || coalesce(t0.disp_address_line2, '') || '|' || coalesce(t0.disp_city, '') || '|' || coalesce(t0.disp_state, '') || '|' || coalesce(t0.disppostcode, ''), '||||')), '[[:space:]]+', ' ')), ''), '')) is not null

    union all

    -- branch 12: BJAZ_WAP_MOT_GS_ACT_DTLS
    select
        null,
        nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.latitude, '') || '|' || coalesce(t0.longitude, '') || '|' || coalesce(t0.google_add, ''), '||')), '[[:space:]]+', ' ')), ''), '') as LOCATION_BK,
        nullif(nullif(trim(to_char(t0.branch_code)), ''), '') as ORG_UNIT_BK,
        null, null, null, null, null, null, null, null, null,
        t0.google_add as AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT,
        null, null, null, null, null, null, null, null, null,
        t0.branch_name as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wap_mot_gs_act_dtls') }} t0
    where (coalesce(nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.latitude, '') || '|' || coalesce(t0.longitude, '') || '|' || coalesce(t0.google_add, ''), '||')), '[[:space:]]+', ' ')), ''), ''), nullif(nullif(trim(to_char(t0.branch_code)), ''), ''))) is not null

    union all

    -- branch 13: BJAZ_WB_CLM_BASE_MOT_EXT
    select
        null,
        nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.vehicle_lying_add, ''), '')), '[[:space:]]+', ' ')), ''), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_lying_add as AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wb_clm_base_mot_ext') }} t0
    where (nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.vehicle_lying_add, ''), '')), '[[:space:]]+', ' ')), ''), '')) is not null

    union all

    -- branch 14: BJAZ_WB_CLM_BASE_MOT_EXT
    select
        null,
        nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.vehicle_inspect_add, ''), '')), '[[:space:]]+', ' ')), ''), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_inspect_add as AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wb_clm_base_mot_ext') }} t0
    where (nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.vehicle_inspect_add, ''), '')), '[[:space:]]+', ' ')), ''), '')) is not null

)

select
    FINANCIAL_TRANSACTION_BK,
    LOCATION_BK,
    ORG_UNIT_BK,
    POLICY_BK,
    PRODUCT_BK,
    RISK_OBJECT_BK,
    __LNK_FINTXN_POLICY,
    __LNK_POLICY_PRODUCT,
    __LNK_POLICY_RISK_OBJECT,
    first_value(AUG_COMMON_ADDRESS__ADDRESS_LINE4) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_ADDRESS__ADDRESS_LINE4,
    first_value(AUG_COMMON_ADDRESS__ADDRESS_LINE_5) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_ADDRESS__ADDRESS_LINE_5,
    first_value(AUG_COMMON_ADDRESS__CITY_OTHER_TEXT) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_ADDRESS__CITY_OTHER_TEXT,
    first_value(AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT,
    first_value(AUG_COMMON_ADDRESS__LOCALITY_OTHER_TEXT) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_ADDRESS__LOCALITY_OTHER_TEXT,
    first_value(AUG_COMMON_ADDRESS__SAME_AS_RISK_ADDRESS_INDICATOR) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_ADDRESS__SAME_AS_RISK_ADDRESS_INDICATOR,
    first_value(AUG_ORG_UNIT_DEFINITION__BRANCH_GROUP_EFFECTIVE_DATE) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_DEFINITION__BRANCH_GROUP_EFFECTIVE_DATE,
    first_value(AUG_ORG_UNIT_DEFINITION__DEPARTMENT_CODE) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_DEFINITION__DEPARTMENT_CODE,
    first_value(AUG_ORG_UNIT_DEFINITION__SECONDARY_DEPARTMENT_CODE) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_DEFINITION__SECONDARY_DEPARTMENT_CODE,
    first_value(AUG_RISK_EXTENDED_WARRANTY__MANUFACTURER_WARRANTY_PERIOD) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_EXTENDED_WARRANTY__MANUFACTURER_WARRANTY_PERIOD,
    first_value(AUG_RISK_EXTENDED_WARRANTY__MANUFACTURER_WARRANTY_TERM_MONTHS) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_EXTENDED_WARRANTY__MANUFACTURER_WARRANTY_TERM_MONTHS,
    first_value(AUG_RISK_EXTENDED_WARRANTY__WARRANTY_INVOICE_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_EXTENDED_WARRANTY__WARRANTY_INVOICE_DATE,
    first_value(ORG_UNIT_DEFINITION__ORG_UNIT_CODE) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
    first_value(ORG_UNIT_DEFINITION__ORG_UNIT_NAME) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
    first_value(ORG_UNIT_DEFINITION__ORG_UNIT_STATUS) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ORG_UNIT_DEFINITION__ORG_UNIT_STATUS,
    first_value(ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
    first_value(ORG_UNIT_DEFINITION__ZONE_NAME) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ORG_UNIT_DEFINITION__ZONE_NAME,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.INC_JOB_UPDATED_AT
from merged m
