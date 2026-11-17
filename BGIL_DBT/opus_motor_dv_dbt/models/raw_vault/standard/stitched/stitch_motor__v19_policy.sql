-- CENTRAL VIEW v19_policy -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BJAZ_CVTP_WS_DATA
--   BJAZ_MOT_COVER_EXTN
--   BJAZ_MOT_OD_TP_DTLS
--   BJAZ_MOT_ONLINE_POL_DTLS
--   BJAZ_MOT_PREM_SUMM_EXTN
--   BJAZ_MOT_PREM_SUMM_EXTN_ADJ
--   BJAZ_MOT_RENEWAL_EXTN
--   BJAZ_MOT_RENEWAL_HIST
--   BJAZ_MOT_REN_PREM
--   BJAZ_MOT_REN_SUM_DTLS_A
--   BJAZ_MOT_TRADE_DTLS_EXTN
--   BJAZ_MOT_WAR_PLANS_EXTN
--   BJAZ_MOT_WINBACK_DTLS
--   BJAZ_MOT_WS_POL_DTLS
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_POLICY_EXCESS_STRUCTURE
--   SAT_POLICY_FLEET
--   SAT_POLICY_PREMIUM_HEAD
--   SAT_POLICY_SUM_INSURED_BREAKUP
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every feeding table.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BJAZ_CVTP_WS_DATA
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        cast(null as varchar) as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        coalesce(t0.compdeductibles, t0.voluntarydeductible) as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        cast(null as varchar) as POLICY_EXCESS_STRUCTURE__EXCESS_PERCENTAGE,
        cast(null as varchar) as POLICY_FLEET__NAMED_DRIVER_POLICY_INDICATOR,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__SECTION_CK,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__LOADING_AMOUNT,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__PREMIUM_COMPONENT,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_NAME,
        cast(null as varchar) as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        cast(null as varchar) as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 1: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BASIC_TP, POLICY_PREMIUM_HEAD.Section=TP
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'BASIC_TP' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.basictpl as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 2: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=EXT_TPPD, POLICY_PREMIUM_HEAD.Section=TP
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'EXT_TPPD' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.exttppd as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 3: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=IMT34, POLICY_PREMIUM_HEAD.Section=TP
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'IMT34' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.imt34tp as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 4: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=TRAILER, POLICY_PREMIUM_HEAD.Section=TP
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'TRAILER' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.trailertp as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 5: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=NET_TP, POLICY_PREMIUM_HEAD.Section=TP
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'NET_TP' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.totaltp as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 6: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=TOTAL_PA, POLICY_PREMIUM_HEAD.Section=PA
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'TOTAL_PA' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.patotalpremium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 7: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=TOTAL_LEGAL_LIABILITY, POLICY_PREMIUM_HEAD.Section=TP
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'TOTAL_LEGAL_LIABILITY' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.totallegalliability as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 8: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=NET_LIABILITY, POLICY_PREMIUM_HEAD.Section=TP
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'NET_LIABILITY' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.netliabilitypremiumb as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 9: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=GEOGRAPHICAL_EXTENSION, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'GEOGRAPHICAL_EXTENSION' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.geographicextnpremium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 10: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=GEOGRAPHICAL_EXTENSION, POLICY_PREMIUM_HEAD.Section=TP
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'GEOGRAPHICAL_EXTENSION' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.geographicextntppremium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 11: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=VEHICLE_OD, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'VEHICLE_OD' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.vehiclepremium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 12: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=TRAILER, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'TRAILER' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.trailerpremium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 13: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=NON_ELECTRICAL_ACCESSORY, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'NON_ELECTRICAL_ACCESSORY' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.nonelectricaccpremium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 14: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=ELECTRICAL_ACCESSORY, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'ELECTRICAL_ACCESSORY' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.electricaccpremium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 15: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BIFUEL_KIT, POLICY_PREMIUM_HEAD.Section=TP
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'BIFUEL_KIT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.bifueltppremium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 16: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BIFUEL_KIT, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'BIFUEL_KIT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.bifuelkitpremium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 17: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=IMT23, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'IMT23' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.imt23premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 18: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=IMT34, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'IMT34' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.imt34premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 19: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=OVERTURNING_COVER, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'OVERTURNING_COVER' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.overturncover as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 20: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=IMT33, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'IMT33' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.imt33premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 21: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BASIC_OD, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'BASIC_OD' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.basicodp as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 22: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=NET_OD, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'NET_OD' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.netodpremium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 23: BJAZ_MOT_COVER_EXTN
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null,
        t0.voluntary_excess as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_cover_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 24: BJAZ_MOT_COVER_EXTN | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=COVER_DISCOUNT
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        'COVER_DISCOUNT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        t0.cover_code as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.cover_disc as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_cover_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 25: BJAZ_MOT_COVER_EXTN | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=COVER_LOADING
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        'COVER_LOADING' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        t0.cover_code as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null,
        t0.cover_load as POLICY_PREMIUM_HEAD__LOADING_AMOUNT,
        null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_cover_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 26: BJAZ_MOT_OD_TP_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=NET_OD, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        'NET_OD' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.total_od_prem as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_od_tp_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 27: BJAZ_MOT_OD_TP_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=NET_TP, POLICY_PREMIUM_HEAD.Section=TP
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        'NET_TP' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.total_tp_prem as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_od_tp_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 28: BJAZ_MOT_OD_TP_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BASIC_OD, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        'BASIC_OD' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.comm_od_prem as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_od_tp_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 29: BJAZ_MOT_OD_TP_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=ADJUSTED_OD, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        'ADJUSTED_OD' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.adj_od_prem as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_od_tp_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 30: BJAZ_MOT_OD_TP_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=ADJUSTED_TP, POLICY_PREMIUM_HEAD.Section=TP
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        'ADJUSTED_TP' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.adj_tp_prem as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_od_tp_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 31: BJAZ_MOT_OD_TP_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=TERRORISM_SURCHARGE, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        'TERRORISM_SURCHARGE' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.terr_surcharge as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_od_tp_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 32: BJAZ_MOT_ONLINE_POL_DTLS
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null,
        t0.voluntary_excess_val as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        t0.voluntary_deductible_rate as POLICY_EXCESS_STRUCTURE__EXCESS_PERCENTAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 33: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=FULL_TERM, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'FULL_TERM' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.full_term_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 34: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=COMPOSITE_PRODUCT, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'COMPOSITE_PRODUCT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.comp_prod_prem as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 35: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BASE_PRODUCT_CONTRIBUTION, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'BASE_PRODUCT_CONTRIBUTION' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.prem_base_prod as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 36: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=MINIMUM_COMPOSITE_PRODUCT, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'MINIMUM_COMPOSITE_PRODUCT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.min_comp_prod_prem as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 37: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BASE_PRODUCT, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'BASE_PRODUCT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.base_prod_prem as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 38: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BASIC_OD, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'BASIC_OD' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.basic_od_premium as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 39: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=CIBIL_OFFER_GROSS, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'CIBIL_OFFER_GROSS' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.cibil_wd_gross_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 40: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=CIBIL_OFFER_FULL_TERM, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'CIBIL_OFFER_FULL_TERM' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.cibil_wd_full_term_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 41: BJAZ_MOT_PREM_SUMM_EXTN
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        t0.param_ref as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null, null, null, null, null, null, null, null,
        t0.param_type as POLICY_PREMIUM_HEAD__PREMIUM_COMPONENT,
        t0.param_ref as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE,
        null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_prem_summ_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 42: BJAZ_MOT_PREM_SUMM_EXTN | child-key literal(s): POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        t0.param_ref as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.od as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_prem_summ_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 43: BJAZ_MOT_PREM_SUMM_EXTN | child-key literal(s): POLICY_PREMIUM_HEAD.Section=ACT
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        t0.param_ref as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'ACT' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.act as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_prem_summ_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 44: BJAZ_MOT_PREM_SUMM_EXTN | child-key literal(s): POLICY_PREMIUM_HEAD.Section=NET
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        t0.param_ref as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'NET' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.net as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_prem_summ_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 45: BJAZ_MOT_PREM_SUMM_EXTN_ADJ
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        t0.param_ref as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null, null,
        t0.diff_yn as POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
        t0.diff_yn as POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR,
        null, null, null, null,
        t0.param_type as POLICY_PREMIUM_HEAD__PREMIUM_COMPONENT,
        t0.param_ref as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE,
        null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_prem_summ_extn_adj') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 46: BJAZ_MOT_PREM_SUMM_EXTN_ADJ | child-key literal(s): POLICY_PREMIUM_HEAD.Section=NET
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        t0.param_ref as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'NET' as POLICY_PREMIUM_HEAD__SECTION_CK,
        t0.diff_yn as POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
        null, null, null, null,
        t0.net as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_prem_summ_extn_adj') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 47: BJAZ_MOT_PREM_SUMM_EXTN_ADJ | child-key literal(s): POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        t0.param_ref as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        t0.diff_yn as POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
        null, null, null, null,
        t0.od as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_prem_summ_extn_adj') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 48: BJAZ_MOT_PREM_SUMM_EXTN_ADJ | child-key literal(s): POLICY_PREMIUM_HEAD.Section=ACT
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        t0.param_ref as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'ACT' as POLICY_PREMIUM_HEAD__SECTION_CK,
        t0.diff_yn as POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
        null, null, null, null,
        t0.act as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_prem_summ_extn_adj') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 49: BJAZ_MOT_RENEWAL_EXTN
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null,
        coalesce(t0.add_excess, t0.additional_deductible, t0.deductible, t0.vol_excess) as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 50: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BASIC_OD_PLAN_1801, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'BASIC_OD_PLAN_1801' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.basic_od_prem_1801 as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 51: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BASIC_OD_PLAN_1818, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'BASIC_OD_PLAN_1818' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.basic_od_prem_1818 as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 52: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BASIC_OD, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'BASIC_OD' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.od_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 53: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BASIC_OD_FIRST_YEAR, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'BASIC_OD_FIRST_YEAR' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.od_premium_1st as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 54: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=OD_LOADING, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'OD_LOADING' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null,
        t0.od_loading as POLICY_PREMIUM_HEAD__LOADING_AMOUNT,
        null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 55: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=OD_LOADING_FIRST_YEAR, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'OD_LOADING_FIRST_YEAR' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null,
        t0.od_loading_1st as POLICY_PREMIUM_HEAD__LOADING_AMOUNT,
        null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 56: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=COMMERCIAL_DISCOUNT, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'COMMERCIAL_DISCOUNT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.comm_disc_amt_1st as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 57: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=MPMP_DISCOUNT, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'MPMP_DISCOUNT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.mpmp_disc_amt as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 58: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=NET_PREMIUM_FIRST_YEAR, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'NET_PREMIUM_FIRST_YEAR' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.net_premium_1st as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 59: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=NET_PREMIUM_FULL_YEAR, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'NET_PREMIUM_FULL_YEAR' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.full_yr_net_prem as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 60: BJAZ_MOT_RENEWAL_HIST
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null,
        coalesce(t0.add_excess, t0.vol_excess) as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 61: BJAZ_MOT_RENEWAL_HIST | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=NET_PREMIUM, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        'NET_PREMIUM' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.net_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 62: BJAZ_MOT_RENEWAL_HIST | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=GROSS_PREMIUM, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        'GROSS_PREMIUM' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.gross_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 63: BJAZ_MOT_RENEWAL_HIST | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=NEW_NET_PREMIUM, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        'NEW_NET_PREMIUM' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.new_net_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 64: BJAZ_MOT_RENEWAL_HIST | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=NEW_GROSS_PREMIUM, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        'NEW_GROSS_PREMIUM' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.new_gross_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 65: BJAZ_MOT_RENEWAL_HIST | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=UW_STANDARD_PREMIUM, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        'UW_STANDARD_PREMIUM' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.uw_stds_prem as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 66: BJAZ_MOT_RENEWAL_HIST | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BASIC_OD_PLAN_1801, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        'BASIC_OD_PLAN_1801' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.basic_od_prem_1801 as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 67: BJAZ_MOT_RENEWAL_HIST | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BASIC_OD_PLAN_1818, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        'BASIC_OD_PLAN_1818' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.basic_od_prem_1818 as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 68: BJAZ_MOT_RENEWAL_HIST | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BASIC_OD_FIRST_YEAR, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        'BASIC_OD_FIRST_YEAR' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.od_premium_1st as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 69: BJAZ_MOT_RENEWAL_HIST | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=GROSS_PREMIUM_DEVIATION, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        'GROSS_PREMIUM_DEVIATION' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.gross_prem_dev as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 70: BJAZ_MOT_REN_PREM
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        t0.param_ref as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null, null, null, null, null,
        t0.cover_disc as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        t0.cover_load as POLICY_PREMIUM_HEAD__LOADING_AMOUNT,
        null,
        t0.param_type as POLICY_PREMIUM_HEAD__PREMIUM_COMPONENT,
        t0.param_ref as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE,
        null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ren_prem') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 71: BJAZ_MOT_REN_PREM | child-key literal(s): POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        t0.param_ref as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.od as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ren_prem') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 72: BJAZ_MOT_REN_PREM | child-key literal(s): POLICY_PREMIUM_HEAD.Section=ACT
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        t0.param_ref as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'ACT' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.act as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ren_prem') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 73: BJAZ_MOT_REN_PREM | child-key literal(s): POLICY_PREMIUM_HEAD.Section=NET
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        t0.param_ref as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'NET' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.net as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ren_prem') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 74: BJAZ_MOT_REN_SUM_DTLS_A | child-key literal(s): POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        t0.param_no as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.od_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null,
        t0.od_desc as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_NAME,
        null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ren_sum_dtls_a') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 75: BJAZ_MOT_REN_SUM_DTLS_A | child-key literal(s): POLICY_PREMIUM_HEAD.Section=ACT
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        t0.param_no as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'ACT' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.act_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null,
        t0.act_desc as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_NAME,
        null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ren_sum_dtls_a') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 76: BJAZ_MOT_REN_SUM_DTLS_A
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        t0.param_no as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null, null, null, null, null, null, null, null, null,
        t0.param_no as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE,
        null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ren_sum_dtls_a') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 77: BJAZ_MOT_REN_SUM_DTLS_A | child-key literal(s): POLICY_SUM_INSURED_BREAKUP.Sum Insured Head=OD_SUMINSURED
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'OD_SUMINSURED' as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        t0.od_suminsured as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ren_sum_dtls_a') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 78: BJAZ_MOT_REN_SUM_DTLS_A | child-key literal(s): POLICY_SUM_INSURED_BREAKUP.Sum Insured Head=ACT_SUMINSURED
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ACT_SUMINSURED' as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        t0.act_suminsured as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ren_sum_dtls_a') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 79: BJAZ_MOT_TRADE_DTLS_EXTN
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null,
        t0.namedriver_flag as POLICY_FLEET__NAMED_DRIVER_POLICY_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_trade_dtls_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 80: BJAZ_MOT_TRADE_DTLS_EXTN | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BASIC_TP_ADDITIONAL, POLICY_PREMIUM_HEAD.Section=TP
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        'BASIC_TP_ADDITIONAL' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.basic_add_act_premium as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_trade_dtls_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 81: BJAZ_MOT_TRADE_DTLS_EXTN | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BASIC_OD_FIRST, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        'BASIC_OD_FIRST' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.basic_first_od_prem as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_trade_dtls_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 82: BJAZ_MOT_TRADE_DTLS_EXTN | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BASIC_OD_ADDITIONAL, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        'BASIC_OD_ADDITIONAL' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.basic_add_od_prem as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_trade_dtls_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 83: BJAZ_MOT_TRADE_DTLS_EXTN | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BASIC_TP_FIRST_YEAR, POLICY_PREMIUM_HEAD.Section=TP
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        'BASIC_TP_FIRST_YEAR' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.basic_first_act_prem as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_trade_dtls_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 84: BJAZ_MOT_TRADE_DTLS_EXTN | child-key literal(s): POLICY_SUM_INSURED_BREAKUP.Sum Insured Head=TRADECERTI_IDV
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TRADECERTI_IDV' as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        t0.tradecerti_idv as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_trade_dtls_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 85: BJAZ_MOT_TRADE_DTLS_EXTN | child-key literal(s): POLICY_SUM_INSURED_BREAKUP.Sum Insured Head=NAMEDRIVER_IDV
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NAMEDRIVER_IDV' as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        t0.namedriver_idv as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_trade_dtls_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 86: BJAZ_MOT_WAR_PLANS_EXTN | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=NET_PREMIUM, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null,
        'NET_PREMIUM' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_war_plans_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 87: BJAZ_MOT_WINBACK_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BASIC_OD, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'BASIC_OD' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.od_prem as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_winback_dtls') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 88: BJAZ_MOT_WINBACK_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BASIC_TP, POLICY_PREMIUM_HEAD.Section=TP
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null,
        'BASIC_TP' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.tp_prem as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_winback_dtls') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 89: BJAZ_MOT_WS_POL_DTLS
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null,
        t0.voluntary_excess_val as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        t0.voluntary_deductible_rate as POLICY_EXCESS_STRUCTURE__EXCESS_PERCENTAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 90: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=FULL_TERM, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'FULL_TERM' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.full_term_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 91: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=COMPOSITE_PRODUCT, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'COMPOSITE_PRODUCT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.comp_prod_prem as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 92: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BASE_PRODUCT_CONTRIBUTION, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'BASE_PRODUCT_CONTRIBUTION' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.prem_base_prod as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 93: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=MINIMUM_COMPOSITE_PRODUCT, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'MINIMUM_COMPOSITE_PRODUCT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.min_comp_prod_prem as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 94: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BASE_PRODUCT, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'BASE_PRODUCT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.base_prod_prem as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 95: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=BASIC_OD, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'BASIC_OD' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.basic_od_premium as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 96: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=RENEWAL_PREMIUM, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'RENEWAL_PREMIUM' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.renewal_premium as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 97: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=GROSS_PREMIUM_A, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'GROSS_PREMIUM_A' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.gross_premium_a as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 98: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=GROSS_PREMIUM_B, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'GROSS_PREMIUM_B' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.gross_premium_b as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 99: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): POLICY_PREMIUM_HEAD.Premium Head Code=GROSS_PREMIUM_C, POLICY_PREMIUM_HEAD.Section=OD
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        'GROSS_PREMIUM_C' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.gross_premium_c as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

)

select
    POLICY_BK,
    POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
    first_value(POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
    first_value(POLICY_EXCESS_STRUCTURE__EXCESS_PERCENTAGE) ignore nulls over (partition by POLICY_BK, POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_EXCESS_STRUCTURE__EXCESS_PERCENTAGE,
    first_value(POLICY_FLEET__NAMED_DRIVER_POLICY_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_FLEET__NAMED_DRIVER_POLICY_INDICATOR,
    POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
    POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
    POLICY_PREMIUM_HEAD__SECTION_CK,
    POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
    first_value(POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR) ignore nulls over (partition by POLICY_BK, POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, POLICY_PREMIUM_HEAD__SECTION_CK, POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR,
    first_value(POLICY_PREMIUM_HEAD__BASE_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, POLICY_PREMIUM_HEAD__SECTION_CK, POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
    first_value(POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, POLICY_PREMIUM_HEAD__SECTION_CK, POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
    first_value(POLICY_PREMIUM_HEAD__LOADING_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, POLICY_PREMIUM_HEAD__SECTION_CK, POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_HEAD__LOADING_AMOUNT,
    first_value(POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM) ignore nulls over (partition by POLICY_BK, POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, POLICY_PREMIUM_HEAD__SECTION_CK, POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
    first_value(POLICY_PREMIUM_HEAD__PREMIUM_COMPONENT) ignore nulls over (partition by POLICY_BK, POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, POLICY_PREMIUM_HEAD__SECTION_CK, POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_HEAD__PREMIUM_COMPONENT,
    first_value(POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE) ignore nulls over (partition by POLICY_BK, POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, POLICY_PREMIUM_HEAD__SECTION_CK, POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE,
    first_value(POLICY_PREMIUM_HEAD__PREMIUM_HEAD_NAME) ignore nulls over (partition by POLICY_BK, POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, POLICY_PREMIUM_HEAD__SECTION_CK, POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_NAME,
    POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
    first_value(POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT
from merged
