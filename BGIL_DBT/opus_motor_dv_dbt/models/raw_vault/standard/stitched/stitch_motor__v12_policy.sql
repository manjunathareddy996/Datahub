-- CENTRAL VIEW v12_policy -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BJAZ_AGENCY_MOT_WAR_DTLS
--   BJAZ_MOT_WAR_CHILD_DTLS
--   BJAZ_MOT_WAR_MAST_CHILD
--   WEO_BJAZ_MOT_DISPATCH_DTLS
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AGREEMENT_DEFINITION
--   SAT_AUG_AGREEMENT_DEFINITION
--   SAT_AUG_POLICY_DELIVERY
--   SAT_COMMON_CONSENT
--   SAT_POLICY_CERTIFICATE
--   SAT_POLICY_DELIVERY
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_AGREEMENT_CHANNEL
--   LNK_CHANNEL_ORG_UNIT
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_LOCATION
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_RISK_OBJECT
--   LNK_RISK_OBJECT_LOCATION
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BJAZ_AGENCY_MOT_WAR_DTLS
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as AGREEMENT_BK,
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        nullif(md5(normalise(upper(nullif(coalesce(t0.customer_address, '') || '|' || coalesce(t0.area, '') || '|' || coalesce(t0.city, '') || '|' || coalesce(t0.state, '') || '|' || coalesce(to_char(t0.pincode), ''), '||||')))), '') as LOCATION_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.veh_reg_no), '')), '') as RISK_OBJECT_BK,
        cast(null as number) as __LNK_AGREEMENT_CHANNEL,
        cast(null as number) as __LNK_CHANNEL_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_CHANNEL,
        1 as __LNK_POLICY_LOCATION,
        cast(null as number) as __LNK_POLICY_ORG_UNIT,
        1 as __LNK_POLICY_RISK_OBJECT,
        1 as __LNK_RISK_OBJECT_LOCATION,
        t0.reference_id as AGREEMENT_DEFINITION__AGREEMENT_REFERENCE_NUMBER,
        t0.cert_sale_date as AGREEMENT_DEFINITION__EXECUTION_DATE,
        cast(null as varchar) as AGREEMENT_DEFINITION__MASTER_AGREEMENT_REFERENCE,
        cast(null as varchar) as AUG_AGREEMENT_DEFINITION__AGREEMENT_LINE_SEQUENCE_NUMBER,
        cast(null as varchar) as AUG_POLICY_DELIVERY__COURIER_VENDOR_NAME,
        cast(null as varchar) as AUG_POLICY_DELIVERY__DISPATCH_TIME,
        cast(null as varchar) as AUG_POLICY_DELIVERY__DISPATCH_TRANSACTION_DATE,
        cast(null as varchar) as COMMON_CONSENT__CONSENT_GIVEN_INDICATOR,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_ISSUE_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_DELIVERY__DELIVERY_STATUS,
        cast(null as varchar) as POLICY_DELIVERY__DISPATCH_DATE,
        cast(null as varchar) as POLICY_DELIVERY__TRACKING_REFERENCE,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_agency_mot_war_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.veh_reg_no), '')), ''), nullif(md5(normalise(upper(nullif(coalesce(t0.customer_address, '') || '|' || coalesce(t0.area, '') || '|' || coalesce(t0.city, '') || '|' || coalesce(t0.state, '') || '|' || coalesce(to_char(t0.pincode), ''), '||||')))), ''), nullif(nullif(trim(t0.policy_ref), ''), ''), nullif(nullif(trim(to_char(t0.contract_id)), ''), ''))) is not null

    union all

    -- branch 1: BJAZ_MOT_WAR_CHILD_DTLS
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as AGREEMENT_BK,
        nullif(nullif('DEALER:' || nullif(trim(t0.dealer_code), ''), 'DEALER:'), '') as DISTRIBUTION_CHANNEL_BK,
        null,
        nullif(nullif(trim(t0.outlet_code), ''), '') as ORG_UNIT_BK,
        nullif(coalesce(nullif(trim(t0.pan_no), ''), nullif(trim(t0.gst_no), ''), md5(normalise(upper(nullif(coalesce(t0.customer_name, '') || '|' || coalesce(to_char(t0.mobile_no), '') || '|' || coalesce(t0.email_id, ''), '||'))))), '') as PARTY_BK,
        nullif(nullif(trim(t0.motor_policy_no), ''), '') as POLICY_BK,
        nullif(coalesce(nullif(trim(t0.vehicle_reg_no), ''), nullif(trim(t0.equipment_serial_no), '')), '') as RISK_OBJECT_BK,
        1 as __LNK_AGREEMENT_CHANNEL,
        1 as __LNK_CHANNEL_ORG_UNIT,
        1 as __LNK_POLICY_CHANNEL,
        null,
        1 as __LNK_POLICY_ORG_UNIT,
        1 as __LNK_POLICY_RISK_OBJECT,
        null,
        t0.itl_ew_reference as AGREEMENT_DEFINITION__AGREEMENT_REFERENCE_NUMBER,
        null, null,
        t0.seqid as AUG_AGREEMENT_DEFINITION__AGREEMENT_LINE_SEQUENCE_NUMBER,
        null, null, null,
        t0.customer_consent as COMMON_CONSENT__CONSENT_GIVEN_INDICATOR,
        t0.ext_warranty_cert_no as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        t0.cert_sale_date as POLICY_CERTIFICATE__CERTIFICATE_ISSUE_DATE,
        t0.ext_warranty_cert_no as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_war_child_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.pan_no), ''), nullif(trim(t0.gst_no), ''), md5(normalise(upper(nullif(coalesce(t0.customer_name, '') || '|' || coalesce(to_char(t0.mobile_no), '') || '|' || coalesce(t0.email_id, ''), '||'))))), ''), nullif(coalesce(nullif(trim(t0.vehicle_reg_no), ''), nullif(trim(t0.equipment_serial_no), '')), ''), nullif(nullif('DEALER:' || nullif(trim(t0.dealer_code), ''), 'DEALER:'), ''), nullif(nullif(trim(t0.motor_policy_no), ''), ''), nullif(nullif(trim(t0.outlet_code), ''), ''), nullif(nullif(trim(to_char(t0.contract_id)), ''), ''))) is not null

    union all

    -- branch 2: BJAZ_MOT_WAR_MAST_CHILD
    select
        nullif(nullif(trim(to_char(t0.child_contract_id)), ''), '') as AGREEMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.master_contract_id as AGREEMENT_DEFINITION__MASTER_AGREEMENT_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_war_mast_child') }} t0
    where (nullif(nullif(trim(to_char(t0.child_contract_id)), ''), '')) is not null

    union all

    -- branch 3: WEO_BJAZ_MOT_DISPATCH_DTLS
    select
        null, null, null, null, null,
        nullif(nullif(trim(t0.policy_no), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.courier_name as AUG_POLICY_DELIVERY__COURIER_VENDOR_NAME,
        t0.dispatch_time as AUG_POLICY_DELIVERY__DISPATCH_TIME,
        t0.trans_date as AUG_POLICY_DELIVERY__DISPATCH_TRANSACTION_DATE,
        null, null, null, null,
        t0.disp_status as POLICY_DELIVERY__DELIVERY_STATUS,
        t0.dispatch_date as POLICY_DELIVERY__DISPATCH_DATE,
        t0.air_way_bill_no as POLICY_DELIVERY__TRACKING_REFERENCE,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__weo_bjaz_mot_dispatch_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_no), ''), '')) is not null

)

select
    AGREEMENT_BK,
    DISTRIBUTION_CHANNEL_BK,
    LOCATION_BK,
    ORG_UNIT_BK,
    PARTY_BK,
    POLICY_BK,
    RISK_OBJECT_BK,
    __LNK_AGREEMENT_CHANNEL,
    __LNK_CHANNEL_ORG_UNIT,
    __LNK_POLICY_CHANNEL,
    __LNK_POLICY_LOCATION,
    __LNK_POLICY_ORG_UNIT,
    __LNK_POLICY_RISK_OBJECT,
    __LNK_RISK_OBJECT_LOCATION,
    first_value(AGREEMENT_DEFINITION__AGREEMENT_REFERENCE_NUMBER) ignore nulls over (partition by AGREEMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AGREEMENT_DEFINITION__AGREEMENT_REFERENCE_NUMBER,
    first_value(AGREEMENT_DEFINITION__EXECUTION_DATE) ignore nulls over (partition by AGREEMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AGREEMENT_DEFINITION__EXECUTION_DATE,
    first_value(AGREEMENT_DEFINITION__MASTER_AGREEMENT_REFERENCE) ignore nulls over (partition by AGREEMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AGREEMENT_DEFINITION__MASTER_AGREEMENT_REFERENCE,
    first_value(AUG_AGREEMENT_DEFINITION__AGREEMENT_LINE_SEQUENCE_NUMBER) ignore nulls over (partition by AGREEMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_AGREEMENT_DEFINITION__AGREEMENT_LINE_SEQUENCE_NUMBER,
    first_value(AUG_POLICY_DELIVERY__COURIER_VENDOR_NAME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DELIVERY__COURIER_VENDOR_NAME,
    first_value(AUG_POLICY_DELIVERY__DISPATCH_TIME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DELIVERY__DISPATCH_TIME,
    first_value(AUG_POLICY_DELIVERY__DISPATCH_TRANSACTION_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DELIVERY__DISPATCH_TRANSACTION_DATE,
    first_value(COMMON_CONSENT__CONSENT_GIVEN_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONSENT__CONSENT_GIVEN_INDICATOR,
    POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
    first_value(POLICY_CERTIFICATE__CERTIFICATE_ISSUE_DATE) ignore nulls over (partition by POLICY_BK, POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CERTIFICATE__CERTIFICATE_ISSUE_DATE,
    first_value(POLICY_CERTIFICATE__CERTIFICATE_NUMBER) ignore nulls over (partition by POLICY_BK, POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
    first_value(POLICY_DELIVERY__DELIVERY_STATUS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DELIVERY__DELIVERY_STATUS,
    first_value(POLICY_DELIVERY__DISPATCH_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DELIVERY__DISPATCH_DATE,
    first_value(POLICY_DELIVERY__TRACKING_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DELIVERY__TRACKING_REFERENCE
from merged
