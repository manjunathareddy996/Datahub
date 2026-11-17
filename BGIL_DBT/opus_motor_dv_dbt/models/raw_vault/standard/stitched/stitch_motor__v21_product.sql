-- CENTRAL VIEW v21_product -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BGIL_MOTOR_WEBSERVICE_INFO_EQM
--   BJAZ_MOTOR_WEBSERVICE_INFO
--   BJAZ_MOT_PROD_UIN_MAPPING
--   BJAZ_MOT_STP_PREM_SUMM_EXTN
--   BJAZ_RTA_STATUS_MASTER
--   BJAZ_VEHICLE_TYPE_MASTER_ACT
--   BJAZ_WAP_MOT_STP_RATE_SUMM
--   BJAZ_WS_MOT_STP_RATE_SUMM
--   CVTP_GUIDELINES
--   RTA_CLUSTER_PREFERRED_DECLINE
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_PRODUCT_DEFINITION
--   SAT_AUG_PRODUCT_DISCOUNT_LOADING
--   SAT_AUG_PRODUCT_UW_RULE
--   SAT_PRODUCT_UW_RULE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_PRODUCT
--   LNK_PRODUCT_COVERAGE
--   LNK_PROPOSAL_POLICY
--   LNK_PROPOSAL_PRODUCT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BGIL_MOTOR_WEBSERVICE_INFO_EQM
    select
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as POLICY_BK,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        cast(null as varchar) as PROPOSAL_BK,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_PRODUCT_COVERAGE,
        cast(null as number) as __LNK_PROPOSAL_POLICY,
        cast(null as number) as __LNK_PROPOSAL_PRODUCT,
        cast(null as varchar) as AUG_PRODUCT_DEFINITION__APPLICABLE_VEHICLE_TYPE_CODE,
        t0.pack_name as AUG_PRODUCT_DEFINITION__PRODUCT_PACKAGE_NAME,
        cast(null as varchar) as AUG_PRODUCT_DEFINITION__PRODUCT_TENURE_YEARS,
        cast(null as varchar) as AUG_PRODUCT_DISCOUNT_LOADING__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_CLAIM_PATTERN_CODE,
        cast(null as varchar) as AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_COVER_PACKAGE_CODE,
        cast(null as varchar) as AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_VEHICLE_TYPE_CODE,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__APPLICABILITY_BUSINESS_TYPE,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__APPLICABILITY_DUMPER_OR_TIPPER_INDICATOR,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__APPLICABILITY_ENGINE_CAPACITY_FROM,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__APPLICABILITY_ENGINE_CAPACITY_TO,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__APPLICABILITY_ENGINE_CAPACITY_TYPE,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__APPLICABILITY_FUEL_TYPE,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__APPLICABILITY_ISSUANCE_SOURCE,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__APPLICABILITY_POLICY_PLAN,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__APPLICABILITY_POLICY_TERM,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__APPLICABILITY_RTA_CLUSTER,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__APPLICABILITY_VEHICLE_AGE_FROM,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__APPLICABILITY_VEHICLE_AGE_TO,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__APPLICABILITY_VEHICLE_MAKE,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__APPLICABILITY_VEHICLE_MODEL,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__APPLICABILITY_VEHICLE_TYPE,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__APPLICABLE_BUSINESS_TYPE,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__APPLICABLE_POLICY_PLAN_CODE,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__APPLICABLE_VEHICLE_CODE,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__APPLICABLE_VEHICLE_TYPE_CODE,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__CONFIGURATION_ROW_REFERENCE,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__EXPIRY_DATE,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__MINIMUM_RID_VALUE,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__RULE_ACTIVE_INDICATOR,
        cast(null as varchar) as AUG_PRODUCT_UW_RULE__RULE_STATUS,
        cast(null as varchar) as PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as PRODUCT_UW_RULE__ACTION,
        cast(null as varchar) as PRODUCT_UW_RULE__AUTHORITY_LEVEL_REQUIRED,
        cast(null as varchar) as PRODUCT_UW_RULE__EFFECTIVE_DATE,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_webservice_info_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 1: BJAZ_MOTOR_WEBSERVICE_INFO
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null,
        t0.pack_name as AUG_PRODUCT_DEFINITION__PRODUCT_PACKAGE_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_webservice_info') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 2: BJAZ_MOT_PROD_UIN_MAPPING
    select
        null, null,
        nullif(nullif(trim(to_char(t0.prod_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null,
        t0.veh_type_code as AUG_PRODUCT_DEFINITION__APPLICABLE_VEHICLE_TYPE_CODE,
        null,
        t0.tenure as AUG_PRODUCT_DEFINITION__PRODUCT_TENURE_YEARS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_prod_uin_mapping') }} t0
    where (nullif(nullif(trim(to_char(t0.prod_code)), ''), '')) is not null

    union all

    -- branch 3: BJAZ_MOT_STP_PREM_SUMM_EXTN
    select
        null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        nullif(nullif(trim(to_char(t0.prod_code)), ''), '') as PRODUCT_BK,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as PROPOSAL_BK,
        1 as __LNK_POLICY_PRODUCT,
        null,
        1 as __LNK_PROPOSAL_POLICY,
        1 as __LNK_PROPOSAL_PRODUCT,
        null, null, null, null, null,
        t0.package_id as AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_COVER_PACKAGE_CODE,
        t0.veh_type_code as AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_VEHICLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_stp_prem_summ_extn') }} t0
    where (coalesce(nullif(nullif(trim(to_char(t0.contract_id)), ''), ''), nullif(nullif(trim(to_char(t0.prod_code)), ''), ''), nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), ''))) is not null

    union all

    -- branch 4: BJAZ_RTA_STATUS_MASTER | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=STATUS
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'STATUS' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.status as AUG_PRODUCT_UW_RULE__RULE_STATUS,
        null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_rta_status_master') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 5: BJAZ_RTA_STATUS_MASTER | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=BUSINESS_TYPE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BUSINESS_TYPE' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.business_type as AUG_PRODUCT_UW_RULE__APPLICABLE_BUSINESS_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_rta_status_master') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 6: BJAZ_RTA_STATUS_MASTER | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=VEHICLE_CODE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VEHICLE_CODE' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_code as AUG_PRODUCT_UW_RULE__APPLICABLE_VEHICLE_CODE,
        null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_rta_status_master') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 7: BJAZ_RTA_STATUS_MASTER | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=RTASTS_ID
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RTASTS_ID' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rtasts_id as AUG_PRODUCT_UW_RULE__CONFIGURATION_ROW_REFERENCE,
        null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_rta_status_master') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 8: BJAZ_RTA_STATUS_MASTER | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=VEHICLE_TYPE_CODE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VEHICLE_TYPE_CODE' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_type_code as AUG_PRODUCT_UW_RULE__APPLICABLE_VEHICLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_rta_status_master') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 9: BJAZ_VEHICLE_TYPE_MASTER_ACT | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=VEHICLE_TYPE_CODE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VEHICLE_TYPE_CODE' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_type_code as AUG_PRODUCT_UW_RULE__APPLICABLE_VEHICLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_vehicle_type_master_act') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 10: BJAZ_VEHICLE_TYPE_MASTER_ACT | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=MIN_RID
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'MIN_RID' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.min_rid as AUG_PRODUCT_UW_RULE__MINIMUM_RID_VALUE,
        null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_vehicle_type_master_act') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 11: BJAZ_VEHICLE_TYPE_MASTER_ACT | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=ACTIVE_YN
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ACTIVE_YN' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.active_yn as AUG_PRODUCT_UW_RULE__RULE_ACTIVE_INDICATOR,
        null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_vehicle_type_master_act') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 12: BJAZ_VEHICLE_TYPE_MASTER_ACT
    select
        nullif(nullif(trim(t0.cover_type), ''), '') as COVERAGE_BK,
        null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null,
        1 as __LNK_PRODUCT_COVERAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.effective_date as PRODUCT_UW_RULE__EFFECTIVE_DATE,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_vehicle_type_master_act') }} t0
    where (coalesce(nullif(nullif(trim(t0.cover_type), ''), ''), nullif(nullif(trim(to_char(t0.product_code)), ''), ''))) is not null

    union all

    -- branch 13: BJAZ_WAP_MOT_STP_RATE_SUMM
    select
        null, null,
        nullif(nullif(trim(to_char(t0.prod_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null,
        t0.claim_pattern as AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_CLAIM_PATTERN_CODE,
        t0.package_id as AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_COVER_PACKAGE_CODE,
        t0.veh_type_code as AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_VEHICLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wap_mot_stp_rate_summ') }} t0
    where (nullif(nullif(trim(to_char(t0.prod_code)), ''), '')) is not null

    union all

    -- branch 14: BJAZ_WS_MOT_STP_RATE_SUMM
    select
        null, null,
        nullif(nullif(trim(to_char(t0.prod_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null,
        t0.claim_pattern as AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_CLAIM_PATTERN_CODE,
        t0.package_id as AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_COVER_PACKAGE_CODE,
        t0.veh_type_code as AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_VEHICLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_ws_mot_stp_rate_summ') }} t0
    where (nullif(nullif(trim(to_char(t0.prod_code)), ''), '')) is not null

    union all

    -- branch 15: CVTP_GUIDELINES | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=END_DATE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'END_DATE' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.end_date as AUG_PRODUCT_UW_RULE__EXPIRY_DATE,
        null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__cvtp_guidelines') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 16: CVTP_GUIDELINES | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=VEHICLE_MODEL
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VEHICLE_MODEL' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_model as AUG_PRODUCT_UW_RULE__APPLICABILITY_VEHICLE_MODEL,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__cvtp_guidelines') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 17: CVTP_GUIDELINES | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=ENGINE_CAPACITY_TYPE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ENGINE_CAPACITY_TYPE' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null,
        t0.engine_capacity_type as AUG_PRODUCT_UW_RULE__APPLICABILITY_ENGINE_CAPACITY_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__cvtp_guidelines') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 18: CVTP_GUIDELINES | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=ENGINE_CAPACITY_VALUE_FROM
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ENGINE_CAPACITY_VALUE_FROM' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null,
        t0.engine_capacity_value_from as AUG_PRODUCT_UW_RULE__APPLICABILITY_ENGINE_CAPACITY_FROM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__cvtp_guidelines') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 19: CVTP_GUIDELINES | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=ENGINE_CAPACITY_VALUE_TO
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ENGINE_CAPACITY_VALUE_TO' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null,
        t0.engine_capacity_value_to as AUG_PRODUCT_UW_RULE__APPLICABILITY_ENGINE_CAPACITY_TO,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__cvtp_guidelines') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 20: CVTP_GUIDELINES | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=FUEL_TYPE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FUEL_TYPE' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null,
        t0.fuel_type as AUG_PRODUCT_UW_RULE__APPLICABILITY_FUEL_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__cvtp_guidelines') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 21: CVTP_GUIDELINES | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=BUSINESS_TYPE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BUSINESS_TYPE' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        t0.business_type as AUG_PRODUCT_UW_RULE__APPLICABILITY_BUSINESS_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__cvtp_guidelines') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 22: CVTP_GUIDELINES | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=VEHICLE_AGE_FROM
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VEHICLE_AGE_FROM' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_age_from as AUG_PRODUCT_UW_RULE__APPLICABILITY_VEHICLE_AGE_FROM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__cvtp_guidelines') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 23: CVTP_GUIDELINES | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=VEHICLE_AGE_TO
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VEHICLE_AGE_TO' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_age_to as AUG_PRODUCT_UW_RULE__APPLICABILITY_VEHICLE_AGE_TO,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__cvtp_guidelines') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 24: CVTP_GUIDELINES | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=POLICY_TERM
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'POLICY_TERM' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null, null, null, null,
        t0.policy_term as AUG_PRODUCT_UW_RULE__APPLICABILITY_POLICY_TERM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__cvtp_guidelines') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 25: CVTP_GUIDELINES | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=DUMPER_OR_TIPPER_FLAG
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DUMPER_OR_TIPPER_FLAG' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null,
        t0.dumper_or_tipper_flag as AUG_PRODUCT_UW_RULE__APPLICABILITY_DUMPER_OR_TIPPER_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__cvtp_guidelines') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 26: CVTP_GUIDELINES | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=RTA_CLUSTER
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RTA_CLUSTER' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null, null, null, null, null,
        t0.rta_cluster as AUG_PRODUCT_UW_RULE__APPLICABILITY_RTA_CLUSTER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__cvtp_guidelines') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 27: CVTP_GUIDELINES | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=POLICY_PLAN
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'POLICY_PLAN' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null, null, null,
        t0.policy_plan as AUG_PRODUCT_UW_RULE__APPLICABILITY_POLICY_PLAN,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__cvtp_guidelines') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 28: CVTP_GUIDELINES | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=VEHICLE_TYPE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VEHICLE_TYPE' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_type as AUG_PRODUCT_UW_RULE__APPLICABILITY_VEHICLE_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__cvtp_guidelines') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 29: CVTP_GUIDELINES | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=VEHICLE_MAKE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VEHICLE_MAKE' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_make as AUG_PRODUCT_UW_RULE__APPLICABILITY_VEHICLE_MAKE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__cvtp_guidelines') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 30: CVTP_GUIDELINES | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=ISSUANCE_SOURCE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ISSUANCE_SOURCE' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null, null,
        t0.issuance_source as AUG_PRODUCT_UW_RULE__APPLICABILITY_ISSUANCE_SOURCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__cvtp_guidelines') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 31: CVTP_GUIDELINES
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.referral_to as PRODUCT_UW_RULE__AUTHORITY_LEVEL_REQUIRED,
        t0.start_date as PRODUCT_UW_RULE__EFFECTIVE_DATE,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__cvtp_guidelines') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 32: RTA_CLUSTER_PREFERRED_DECLINE | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=END_DATE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'END_DATE' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.end_date as AUG_PRODUCT_UW_RULE__EXPIRY_DATE,
        null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__rta_cluster_preferred_decline') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 33: RTA_CLUSTER_PREFERRED_DECLINE | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=VEHICLE_TYPE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VEHICLE_TYPE' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_type as AUG_PRODUCT_UW_RULE__APPLICABLE_VEHICLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__rta_cluster_preferred_decline') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 34: RTA_CLUSTER_PREFERRED_DECLINE | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=POLICY_PLAN
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'POLICY_PLAN' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.policy_plan as AUG_PRODUCT_UW_RULE__APPLICABLE_POLICY_PLAN_CODE,
        null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__rta_cluster_preferred_decline') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 35: RTA_CLUSTER_PREFERRED_DECLINE | child-key literal(s): AUG_PRODUCT_UW_RULE.Rule Code=STATUS
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'STATUS' as AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.status as AUG_PRODUCT_UW_RULE__RULE_STATUS,
        null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__rta_cluster_preferred_decline') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

    union all

    -- branch 36: RTA_CLUSTER_PREFERRED_DECLINE
    select
        null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.config as PRODUCT_UW_RULE__ACTION,
        null,
        t0.start_date as PRODUCT_UW_RULE__EFFECTIVE_DATE,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__rta_cluster_preferred_decline') }} t0
    where (nullif(nullif(trim(to_char(t0.product_code)), ''), '')) is not null

)

select
    COVERAGE_BK,
    POLICY_BK,
    PRODUCT_BK,
    PROPOSAL_BK,
    __LNK_POLICY_PRODUCT,
    __LNK_PRODUCT_COVERAGE,
    __LNK_PROPOSAL_POLICY,
    __LNK_PROPOSAL_PRODUCT,
    first_value(AUG_PRODUCT_DEFINITION__APPLICABLE_VEHICLE_TYPE_CODE) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_DEFINITION__APPLICABLE_VEHICLE_TYPE_CODE,
    first_value(AUG_PRODUCT_DEFINITION__PRODUCT_PACKAGE_NAME) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_DEFINITION__PRODUCT_PACKAGE_NAME,
    first_value(AUG_PRODUCT_DEFINITION__PRODUCT_TENURE_YEARS) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_DEFINITION__PRODUCT_TENURE_YEARS,
    AUG_PRODUCT_DISCOUNT_LOADING__ACTIVE_SEQUENCE_NUMBER_CK,
    first_value(AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_CLAIM_PATTERN_CODE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_DISCOUNT_LOADING__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_CLAIM_PATTERN_CODE,
    first_value(AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_COVER_PACKAGE_CODE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_DISCOUNT_LOADING__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_COVER_PACKAGE_CODE,
    first_value(AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_VEHICLE_TYPE_CODE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_DISCOUNT_LOADING__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_VEHICLE_TYPE_CODE,
    AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK,
    AUG_PRODUCT_UW_RULE__RULE_CODE_CK,
    first_value(AUG_PRODUCT_UW_RULE__APPLICABILITY_BUSINESS_TYPE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__APPLICABILITY_BUSINESS_TYPE,
    first_value(AUG_PRODUCT_UW_RULE__APPLICABILITY_DUMPER_OR_TIPPER_INDICATOR) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__APPLICABILITY_DUMPER_OR_TIPPER_INDICATOR,
    first_value(AUG_PRODUCT_UW_RULE__APPLICABILITY_ENGINE_CAPACITY_FROM) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__APPLICABILITY_ENGINE_CAPACITY_FROM,
    first_value(AUG_PRODUCT_UW_RULE__APPLICABILITY_ENGINE_CAPACITY_TO) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__APPLICABILITY_ENGINE_CAPACITY_TO,
    first_value(AUG_PRODUCT_UW_RULE__APPLICABILITY_ENGINE_CAPACITY_TYPE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__APPLICABILITY_ENGINE_CAPACITY_TYPE,
    first_value(AUG_PRODUCT_UW_RULE__APPLICABILITY_FUEL_TYPE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__APPLICABILITY_FUEL_TYPE,
    first_value(AUG_PRODUCT_UW_RULE__APPLICABILITY_ISSUANCE_SOURCE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__APPLICABILITY_ISSUANCE_SOURCE,
    first_value(AUG_PRODUCT_UW_RULE__APPLICABILITY_POLICY_PLAN) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__APPLICABILITY_POLICY_PLAN,
    first_value(AUG_PRODUCT_UW_RULE__APPLICABILITY_POLICY_TERM) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__APPLICABILITY_POLICY_TERM,
    first_value(AUG_PRODUCT_UW_RULE__APPLICABILITY_RTA_CLUSTER) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__APPLICABILITY_RTA_CLUSTER,
    first_value(AUG_PRODUCT_UW_RULE__APPLICABILITY_VEHICLE_AGE_FROM) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__APPLICABILITY_VEHICLE_AGE_FROM,
    first_value(AUG_PRODUCT_UW_RULE__APPLICABILITY_VEHICLE_AGE_TO) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__APPLICABILITY_VEHICLE_AGE_TO,
    first_value(AUG_PRODUCT_UW_RULE__APPLICABILITY_VEHICLE_MAKE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__APPLICABILITY_VEHICLE_MAKE,
    first_value(AUG_PRODUCT_UW_RULE__APPLICABILITY_VEHICLE_MODEL) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__APPLICABILITY_VEHICLE_MODEL,
    first_value(AUG_PRODUCT_UW_RULE__APPLICABILITY_VEHICLE_TYPE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__APPLICABILITY_VEHICLE_TYPE,
    first_value(AUG_PRODUCT_UW_RULE__APPLICABLE_BUSINESS_TYPE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__APPLICABLE_BUSINESS_TYPE,
    first_value(AUG_PRODUCT_UW_RULE__APPLICABLE_POLICY_PLAN_CODE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__APPLICABLE_POLICY_PLAN_CODE,
    first_value(AUG_PRODUCT_UW_RULE__APPLICABLE_VEHICLE_CODE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__APPLICABLE_VEHICLE_CODE,
    first_value(AUG_PRODUCT_UW_RULE__APPLICABLE_VEHICLE_TYPE_CODE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__APPLICABLE_VEHICLE_TYPE_CODE,
    first_value(AUG_PRODUCT_UW_RULE__CONFIGURATION_ROW_REFERENCE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__CONFIGURATION_ROW_REFERENCE,
    first_value(AUG_PRODUCT_UW_RULE__EXPIRY_DATE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__EXPIRY_DATE,
    first_value(AUG_PRODUCT_UW_RULE__MINIMUM_RID_VALUE) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__MINIMUM_RID_VALUE,
    first_value(AUG_PRODUCT_UW_RULE__RULE_ACTIVE_INDICATOR) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__RULE_ACTIVE_INDICATOR,
    first_value(AUG_PRODUCT_UW_RULE__RULE_STATUS) ignore nulls over (partition by PRODUCT_BK, AUG_PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PRODUCT_UW_RULE__RULE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_UW_RULE__RULE_STATUS,
    PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK,
    first_value(PRODUCT_UW_RULE__ACTION) ignore nulls over (partition by PRODUCT_BK, PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_UW_RULE__ACTION,
    first_value(PRODUCT_UW_RULE__AUTHORITY_LEVEL_REQUIRED) ignore nulls over (partition by PRODUCT_BK, PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_UW_RULE__AUTHORITY_LEVEL_REQUIRED,
    first_value(PRODUCT_UW_RULE__EFFECTIVE_DATE) ignore nulls over (partition by PRODUCT_BK, PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_UW_RULE__EFFECTIVE_DATE
from merged
