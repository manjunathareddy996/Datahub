{{ config(materialized='view') }}

-- KEY REJECTIONS, per hub PER FEEDER.
--
-- Directive D-REJECT asks for a per-hub rejected-row count. This is that count, and it
-- is the ONLY thing that makes a zero meaningful: every key expression in this map
-- evaluates to NULL on an all-blank row under Snowflake semantics, so a predicate of the
-- form key = 'RISK:' could never fire while looking exactly like a working guard.
-- Rejection is by SHAPE -- the CASE guard in render_key() -- and this model measures it.
--
-- Expect zeroes here on clean data. A zero is a MEASURED zero, not evidence the
-- mechanism works; a non-zero names the feeder and the instance that produced it.

    select 'HUB_CLAIM' as hub, 'clm_clmd' as feeder, '-' as instance,
           count(*) as rows_in,
           count(CLAIM_BK) as rows_keyed,
           count(*) - count(CLAIM_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd') }}
union all
    select 'HUB_POLICY' as hub, 'clm_clmd' as feeder, '-' as instance,
           count(*) as rows_in,
           count(POLICY_BK) as rows_keyed,
           count(*) - count(POLICY_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_clma_msp_msd_prop_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(CLAIM_BK) as rows_keyed,
           count(*) - count(CLAIM_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clma_msp_msd_prop_pv') }}
union all
    select 'HUB_DOCUMENT' as hub, 'clm_clmd_clma_msp_msd_prop_pv' as feeder, 'claim-inward-document-set' as instance,
           count(*) as rows_in,
           count(DOCUMENT_BK__CLAIM_INWARD_DOCUMENT_SET) as rows_keyed,
           count(*) - count(DOCUMENT_BK__CLAIM_INWARD_DOCUMENT_SET) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clma_msp_msd_prop_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'clm_clmd_clma_msp_msd_prop_pv' as feeder, 'document-inward-origin-address' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__DOCUMENT_INWARD_ORIGIN_ADDRESS) as rows_keyed,
           count(*) - count(LOCATION_BK__DOCUMENT_INWARD_ORIGIN_ADDRESS) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clma_msp_msd_prop_pv') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_clmap_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(CLAIM_BK) as rows_keyed,
           count(*) - count(CLAIM_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_clmap_pv' as feeder, 'claim-court-counterparty' as instance,
           count(*) as rows_in,
           count(CLAIM_BK__CLAIM_COURT_COUNTERPARTY) as rows_keyed,
           count(*) - count(CLAIM_BK__CLAIM_COURT_COUNTERPARTY) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_clmap_pv' as feeder, 'linked-claim' as instance,
           count(*) as rows_in,
           count(CLAIM_BK__LINKED_CLAIM) as rows_keyed,
           count(*) - count(CLAIM_BK__LINKED_CLAIM) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_DISTRIBUTION_CHANNEL' as hub, 'clm_clmd_clmap_pv' as feeder, 'dealer' as instance,
           count(*) as rows_in,
           count(DISTRIBUTION_CHANNEL_BK__DEALER) as rows_keyed,
           count(*) - count(DISTRIBUTION_CHANNEL_BK__DEALER) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_DISTRIBUTION_CHANNEL' as hub, 'clm_clmd_clmap_pv' as feeder, 'intermediary' as instance,
           count(*) as rows_in,
           count(DISTRIBUTION_CHANNEL_BK__INTERMEDIARY) as rows_keyed,
           count(*) - count(DISTRIBUTION_CHANNEL_BK__INTERMEDIARY) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_DOCUMENT' as hub, 'clm_clmd_clmap_pv' as feeder, 'claim-inward' as instance,
           count(*) as rows_in,
           count(DOCUMENT_BK__CLAIM_INWARD) as rows_keyed,
           count(*) - count(DOCUMENT_BK__CLAIM_INWARD) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_DOCUMENT' as hub, 'clm_clmd_clmap_pv' as feeder, 'claim-inward-document-set' as instance,
           count(*) as rows_in,
           count(DOCUMENT_BK__CLAIM_INWARD_DOCUMENT_SET) as rows_keyed,
           count(*) - count(DOCUMENT_BK__CLAIM_INWARD_DOCUMENT_SET) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'clm_clmd_clmap_pv' as feeder, 'claim-correspondence-address' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__CLAIM_CORRESPONDENCE_ADDRESS) as rows_keyed,
           count(*) - count(LOCATION_BK__CLAIM_CORRESPONDENCE_ADDRESS) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'clm_clmd_clmap_pv' as feeder, 'claim-loss-location' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__CLAIM_LOSS_LOCATION) as rows_keyed,
           count(*) - count(LOCATION_BK__CLAIM_LOSS_LOCATION) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'clm_clmd_clmap_pv' as feeder, 'claim-reference-address' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__CLAIM_REFERENCE_ADDRESS) as rows_keyed,
           count(*) - count(LOCATION_BK__CLAIM_REFERENCE_ADDRESS) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'clm_clmd_clmap_pv' as feeder, 'claimant-correspondence-address' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__CLAIMANT_CORRESPONDENCE_ADDRESS) as rows_keyed,
           count(*) - count(LOCATION_BK__CLAIMANT_CORRESPONDENCE_ADDRESS) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'clm_clmd_clmap_pv' as feeder, 'customer-analytics-location' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__CUSTOMER_ANALYTICS_LOCATION) as rows_keyed,
           count(*) - count(LOCATION_BK__CUSTOMER_ANALYTICS_LOCATION) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'clm_clmd_clmap_pv' as feeder, 'inspection-address' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__INSPECTION_ADDRESS) as rows_keyed,
           count(*) - count(LOCATION_BK__INSPECTION_ADDRESS) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'clm_clmd_clmap_pv' as feeder, 'stored-country' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__STORED_COUNTRY) as rows_keyed,
           count(*) - count(LOCATION_BK__STORED_COUNTRY) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'clm_clmd_clmap_pv' as feeder, 'stored-state' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__STORED_STATE) as rows_keyed,
           count(*) - count(LOCATION_BK__STORED_STATE) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_LOSS_EVENT' as hub, 'clm_clmd_clmap_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(LOSS_EVENT_BK) as rows_keyed,
           count(*) - count(LOSS_EVENT_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_LOSS_EVENT' as hub, 'clm_clmd_clmap_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(LOSS_EVENT_BK__V2) as rows_keyed,
           count(*) - count(LOSS_EVENT_BK__V2) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_ORG_UNIT' as hub, 'clm_clmd_clmap_pv' as feeder, 'company' as instance,
           count(*) as rows_in,
           count(ORG_UNIT_BK__COMPANY) as rows_keyed,
           count(*) - count(ORG_UNIT_BK__COMPANY) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_ORG_UNIT' as hub, 'clm_clmd_clmap_pv' as feeder, 'operating-hub' as instance,
           count(*) as rows_in,
           count(ORG_UNIT_BK__OPERATING_HUB) as rows_keyed,
           count(*) - count(ORG_UNIT_BK__OPERATING_HUB) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_PARTY' as hub, 'clm_clmd_clmap_pv' as feeder, 'claim-court-counterparty' as instance,
           count(*) as rows_in,
           count(PARTY_BK__CLAIM_COURT_COUNTERPARTY) as rows_keyed,
           count(*) - count(PARTY_BK__CLAIM_COURT_COUNTERPARTY) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_PARTY' as hub, 'clm_clmd_clmap_pv' as feeder, 'claimant-correspondence-address' as instance,
           count(*) as rows_in,
           count(PARTY_BK__CLAIMANT_CORRESPONDENCE_ADDRESS) as rows_keyed,
           count(*) - count(PARTY_BK__CLAIMANT_CORRESPONDENCE_ADDRESS) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_PARTY' as hub, 'clm_clmd_clmap_pv' as feeder, 'claimant-customer' as instance,
           count(*) as rows_in,
           count(PARTY_BK__CLAIMANT_CUSTOMER) as rows_keyed,
           count(*) - count(PARTY_BK__CLAIMANT_CUSTOMER) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_PARTY' as hub, 'clm_clmd_clmap_pv' as feeder, 'insured-customer' as instance,
           count(*) as rows_in,
           count(PARTY_BK__INSURED_CUSTOMER) as rows_keyed,
           count(*) - count(PARTY_BK__INSURED_CUSTOMER) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_PARTY' as hub, 'clm_clmd_clmap_pv' as feeder, 'insured-member' as instance,
           count(*) as rows_in,
           count(PARTY_BK__INSURED_MEMBER) as rows_keyed,
           count(*) - count(PARTY_BK__INSURED_MEMBER) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_PARTY' as hub, 'clm_clmd_clmap_pv' as feeder, 'service-partner' as instance,
           count(*) as rows_in,
           count(PARTY_BK__SERVICE_PARTNER) as rows_keyed,
           count(*) - count(PARTY_BK__SERVICE_PARTNER) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_PARTY' as hub, 'clm_clmd_clmap_pv' as feeder, 'sub-intermediary' as instance,
           count(*) as rows_in,
           count(PARTY_BK__SUB_INTERMEDIARY) as rows_keyed,
           count(*) - count(PARTY_BK__SUB_INTERMEDIARY) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_POLICY' as hub, 'clm_clmd_clmap_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(POLICY_BK) as rows_keyed,
           count(*) - count(POLICY_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_POLICY' as hub, 'clm_clmd_clmap_pv' as feeder, 'master-policy' as instance,
           count(*) as rows_in,
           count(POLICY_BK__MASTER_POLICY) as rows_keyed,
           count(*) - count(POLICY_BK__MASTER_POLICY) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_PRODUCT' as hub, 'clm_clmd_clmap_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(PRODUCT_BK) as rows_keyed,
           count(*) - count(PRODUCT_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_RISK_OBJECT' as hub, 'clm_clmd_clmap_pv' as feeder, 'claimed-risk-item' as instance,
           count(*) as rows_in,
           count(RISK_OBJECT_BK__CLAIMED_RISK_ITEM) as rows_keyed,
           count(*) - count(RISK_OBJECT_BK__CLAIMED_RISK_ITEM) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_clmcov_msd_prop_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(CLAIM_BK) as rows_keyed,
           count(*) - count(CLAIM_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmcov_msd_prop_pv') }}
union all
    select 'HUB_DOCUMENT' as hub, 'clm_clmd_clmcov_msd_prop_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(DOCUMENT_BK) as rows_keyed,
           count(*) - count(DOCUMENT_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmcov_msd_prop_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'clm_clmd_clmcov_msd_prop_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(LOCATION_BK) as rows_keyed,
           count(*) - count(LOCATION_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmcov_msd_prop_pv') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_claim_event_followup' as feeder, '-' as instance,
           count(*) as rows_in,
           count(CLAIM_BK) as rows_keyed,
           count(*) - count(CLAIM_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_claim_event_followup') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_claim_history' as feeder, '-' as instance,
           count(*) as rows_in,
           count(CLAIM_BK) as rows_keyed,
           count(*) - count(CLAIM_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_claim_history') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_clmpty' as feeder, '-' as instance,
           count(*) as rows_in,
           count(CLAIM_BK) as rows_keyed,
           count(*) - count(CLAIM_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmpty') }}
union all
    select 'HUB_PARTY' as hub, 'clm_clmd_clmpty' as feeder, '-' as instance,
           count(*) as rows_in,
           count(PARTY_BK) as rows_keyed,
           count(*) - count(PARTY_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmpty') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_clmpay' as feeder, '-' as instance,
           count(*) as rows_in,
           count(CLAIM_BK) as rows_keyed,
           count(*) - count(CLAIM_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmpay') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_clmpay' as feeder, 'claim-payee' as instance,
           count(*) as rows_in,
           count(CLAIM_BK__CLAIM_PAYEE) as rows_keyed,
           count(*) - count(CLAIM_BK__CLAIM_PAYEE) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmpay') }}
union all
    select 'HUB_PARTY' as hub, 'clm_clmd_clmpay' as feeder, 'claim-payee' as instance,
           count(*) as rows_in,
           count(PARTY_BK__CLAIM_PAYEE) as rows_keyed,
           count(*) - count(PARTY_BK__CLAIM_PAYEE) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmpay') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_clmpay_payp_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(CLAIM_BK) as rows_keyed,
           count(*) - count(CLAIM_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmpay_payp_pv') }}
union all
    select 'HUB_FINANCIAL_TRANSACTION' as hub, 'clm_clmd_clmpay_payp_pv' as feeder, 'claim-payment' as instance,
           count(*) as rows_in,
           count(FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT) as rows_keyed,
           count(*) - count(FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmpay_payp_pv') }}
union all
    select 'HUB_PAYMENT_INSTRUMENT' as hub, 'clm_clmd_clmpay_payp_pv' as feeder, 'payee-bank-account' as instance,
           count(*) as rows_in,
           count(PAYMENT_INSTRUMENT_BK__PAYEE_BANK_ACCOUNT) as rows_keyed,
           count(*) - count(PAYMENT_INSTRUMENT_BK__PAYEE_BANK_ACCOUNT) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmpay_payp_pv') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_claim_reserve' as feeder, '-' as instance,
           count(*) as rows_in,
           count(CLAIM_BK) as rows_keyed,
           count(*) - count(CLAIM_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_claim_reserve') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_claim_reserve' as feeder, '-' as instance,
           count(*) as rows_in,
           count(CLAIM_BK__V2) as rows_keyed,
           count(*) - count(CLAIM_BK__V2) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_claim_reserve') }}
union all
    select 'HUB_PARTY' as hub, 'clm_clmd_claim_reserve' as feeder, '-' as instance,
           count(*) as rows_in,
           count(PARTY_BK) as rows_keyed,
           count(*) - count(PARTY_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_claim_reserve') }}
union all
    select 'HUB_RISK_OBJECT' as hub, 'clm_clmd_clmrsk' as feeder, 'claimed-risk-item' as instance,
           count(*) as rows_in,
           count(RISK_OBJECT_BK__CLAIMED_RISK_ITEM) as rows_keyed,
           count(*) - count(RISK_OBJECT_BK__CLAIMED_RISK_ITEM) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_clmrsk_party' as feeder, '-' as instance,
           count(*) as rows_in,
           count(CLAIM_BK) as rows_keyed,
           count(*) - count(CLAIM_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_party') }}
union all
    select 'HUB_PARTY' as hub, 'clm_clmd_clmrsk_party' as feeder, '-' as instance,
           count(*) as rows_in,
           count(PARTY_BK) as rows_keyed,
           count(*) - count(PARTY_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_party') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(CLAIM_BK) as rows_keyed,
           count(*) - count(CLAIM_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder, 'claimant' as instance,
           count(*) as rows_in,
           count(CLAIM_BK__CLAIMANT) as rows_keyed,
           count(*) - count(CLAIM_BK__CLAIMANT) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder, 'expense-line-party' as instance,
           count(*) as rows_in,
           count(CLAIM_BK__EXPENSE_LINE_PARTY) as rows_keyed,
           count(*) - count(CLAIM_BK__EXPENSE_LINE_PARTY) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder, 'expense-payee' as instance,
           count(*) as rows_in,
           count(CLAIM_BK__EXPENSE_PAYEE) as rows_keyed,
           count(*) - count(CLAIM_BK__EXPENSE_PAYEE) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder, 'payee' as instance,
           count(*) as rows_in,
           count(CLAIM_BK__PAYEE) as rows_keyed,
           count(*) - count(CLAIM_BK__PAYEE) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder, 'tds-deductee' as instance,
           count(*) as rows_in,
           count(CLAIM_BK__TDS_DEDUCTEE) as rows_keyed,
           count(*) - count(CLAIM_BK__TDS_DEDUCTEE) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
union all
    select 'HUB_FINANCIAL_TRANSACTION' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder, 'claim-bill-invoice' as instance,
           count(*) as rows_in,
           count(FINANCIAL_TRANSACTION_BK__CLAIM_BILL_INVOICE) as rows_keyed,
           count(*) - count(FINANCIAL_TRANSACTION_BK__CLAIM_BILL_INVOICE) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
union all
    select 'HUB_FINANCIAL_TRANSACTION' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder, 'claim-payment' as instance,
           count(*) as rows_in,
           count(FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT) as rows_keyed,
           count(*) - count(FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder, 'claim-expense-party-address' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__CLAIM_EXPENSE_PARTY_ADDRESS) as rows_keyed,
           count(*) - count(LOCATION_BK__CLAIM_EXPENSE_PARTY_ADDRESS) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
union all
    select 'HUB_PARTY' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder, 'claimant' as instance,
           count(*) as rows_in,
           count(PARTY_BK__CLAIMANT) as rows_keyed,
           count(*) - count(PARTY_BK__CLAIMANT) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
union all
    select 'HUB_PARTY' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder, 'expense-line-party' as instance,
           count(*) as rows_in,
           count(PARTY_BK__EXPENSE_LINE_PARTY) as rows_keyed,
           count(*) - count(PARTY_BK__EXPENSE_LINE_PARTY) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
union all
    select 'HUB_PARTY' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder, 'expense-payee' as instance,
           count(*) as rows_in,
           count(PARTY_BK__EXPENSE_PAYEE) as rows_keyed,
           count(*) - count(PARTY_BK__EXPENSE_PAYEE) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
union all
    select 'HUB_PARTY' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder, 'payee' as instance,
           count(*) as rows_in,
           count(PARTY_BK__PAYEE) as rows_keyed,
           count(*) - count(PARTY_BK__PAYEE) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
union all
    select 'HUB_PARTY' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder, 'tds-deductee' as instance,
           count(*) as rows_in,
           count(PARTY_BK__TDS_DEDUCTEE) as rows_keyed,
           count(*) - count(PARTY_BK__TDS_DEDUCTEE) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
union all
    select 'HUB_POLICY' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(POLICY_BK) as rows_keyed,
           count(*) - count(POLICY_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_clmrsk_rska_properties_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(CLAIM_BK) as rows_keyed,
           count(*) - count(CLAIM_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_properties_pv') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_clmrsk_rska_properties_pv' as feeder, 'linked-baggage-delay-claim' as instance,
           count(*) as rows_in,
           count(CLAIM_BK__LINKED_BAGGAGE_DELAY_CLAIM) as rows_keyed,
           count(*) - count(CLAIM_BK__LINKED_BAGGAGE_DELAY_CLAIM) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_properties_pv') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_clmrsk_rska_properties_pv' as feeder, 'linked-health-claim' as instance,
           count(*) as rows_in,
           count(CLAIM_BK__LINKED_HEALTH_CLAIM) as rows_keyed,
           count(*) - count(CLAIM_BK__LINKED_HEALTH_CLAIM) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_properties_pv') }}
union all
    select 'HUB_CLAIM' as hub, 'clm_clmd_clmrsk_rska_properties_pv' as feeder, 'linked-trip-delay-claim' as instance,
           count(*) as rows_in,
           count(CLAIM_BK__LINKED_TRIP_DELAY_CLAIM) as rows_keyed,
           count(*) - count(CLAIM_BK__LINKED_TRIP_DELAY_CLAIM) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_properties_pv') }}
union all
    select 'HUB_COVERAGE' as hub, 'clm_clmd_clmrsk_rska_properties_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(COVERAGE_BK) as rows_keyed,
           count(*) - count(COVERAGE_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_properties_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'clm_clmd_clmrsk_rska_properties_pv' as feeder, 'claim-loss-location' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__CLAIM_LOSS_LOCATION) as rows_keyed,
           count(*) - count(LOCATION_BK__CLAIM_LOSS_LOCATION) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_properties_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'clm_clmd_clmrsk_rska_properties_pv' as feeder, 'treating-hospital-address' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__TREATING_HOSPITAL_ADDRESS) as rows_keyed,
           count(*) - count(LOCATION_BK__TREATING_HOSPITAL_ADDRESS) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_properties_pv') }}
union all
    select 'HUB_PARTY' as hub, 'clm_clmd_clmrsk_rska_properties_pv' as feeder, 'treating-hospital-provider' as instance,
           count(*) as rows_in,
           count(PARTY_BK__TREATING_HOSPITAL_PROVIDER) as rows_keyed,
           count(*) - count(PARTY_BK__TREATING_HOSPITAL_PROVIDER) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_properties_pv') }}
union all
    select 'HUB_DOCUMENT' as hub, 'clm_clmd_doc' as feeder, '-' as instance,
           count(*) as rows_in,
           count(DOCUMENT_BK) as rows_keyed,
           count(*) - count(DOCUMENT_BK) as rows_rejected
    from {{ ref('stg2_mt__clm_clmd_doc') }}
union all
    select 'HUB_ORG_UNIT' as hub, 'uwr_pol' as feeder, '-' as instance,
           count(*) as rows_in,
           count(ORG_UNIT_BK) as rows_keyed,
           count(*) - count(ORG_UNIT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol' as feeder, 'agent' as instance,
           count(*) as rows_in,
           count(PARTY_BK__AGENT) as rows_keyed,
           count(*) - count(PARTY_BK__AGENT) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol' as feeder, 'policyholder' as instance,
           count(*) as rows_in,
           count(PARTY_BK__POLICYHOLDER) as rows_keyed,
           count(*) - count(PARTY_BK__POLICYHOLDER) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol') }}
union all
    select 'HUB_POLICY' as hub, 'uwr_pol' as feeder, '-' as instance,
           count(*) as rows_in,
           count(POLICY_BK) as rows_keyed,
           count(*) - count(POLICY_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol') }}
union all
    select 'HUB_PRODUCT' as hub, 'uwr_pol' as feeder, '-' as instance,
           count(*) as rows_in,
           count(PRODUCT_BK) as rows_keyed,
           count(*) - count(PRODUCT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol') }}
union all
    select 'HUB_QUOTE' as hub, 'uwr_pol' as feeder, '-' as instance,
           count(*) as rows_in,
           count(QUOTE_BK) as rows_keyed,
           count(*) - count(QUOTE_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol') }}
union all
    select 'HUB_LOCATION' as hub, 'uwr_pol_disp' as feeder, '-' as instance,
           count(*) as rows_in,
           count(LOCATION_BK) as rows_keyed,
           count(*) - count(LOCATION_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_disp') }}
union all
    select 'HUB_POLICY' as hub, 'uwr_pol_disp' as feeder, '-' as instance,
           count(*) as rows_in,
           count(POLICY_BK) as rows_keyed,
           count(*) - count(POLICY_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_disp') }}
union all
    select 'HUB_DOCUMENT' as hub, 'uwr_pol_doc' as feeder, '-' as instance,
           count(*) as rows_in,
           count(DOCUMENT_BK) as rows_keyed,
           count(*) - count(DOCUMENT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_doc') }}
union all
    select 'HUB_POLICY' as hub, 'uwr_pol_endt' as feeder, '-' as instance,
           count(*) as rows_in,
           count(POLICY_BK) as rows_keyed,
           count(*) - count(POLICY_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_endt') }}
union all
    select 'HUB_RISK_OBJECT' as hub, 'uwr_pol_ins' as feeder, '-' as instance,
           count(*) as rows_in,
           count(RISK_OBJECT_BK) as rows_keyed,
           count(*) - count(RISK_OBJECT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins') }}
union all
    select 'HUB_RISK_OBJECT' as hub, 'uwr_pol_ins' as feeder, 'insured-risk-line' as instance,
           count(*) as rows_in,
           count(RISK_OBJECT_BK__INSURED_RISK_LINE) as rows_keyed,
           count(*) - count(RISK_OBJECT_BK__INSURED_RISK_LINE) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins') }}
union all
    select 'HUB_COVERAGE' as hub, 'uwr_pol_ins_cov' as feeder, '-' as instance,
           count(*) as rows_in,
           count(COVERAGE_BK) as rows_keyed,
           count(*) - count(COVERAGE_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_cov') }}
union all
    select 'HUB_POLICY' as hub, 'uwr_pol_ins_cov' as feeder, '-' as instance,
           count(*) as rows_in,
           count(POLICY_BK) as rows_keyed,
           count(*) - count(POLICY_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_cov') }}
union all
    select 'HUB_COVERAGE' as hub, 'uwr_pol_ins_cov_covp_msp_msd_prop_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(COVERAGE_BK) as rows_keyed,
           count(*) - count(COVERAGE_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_cov_covp_msp_msd_prop_pv') }}
union all
    select 'HUB_COVERAGE' as hub, 'uwr_pol_ins_cov_covp_sp_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(COVERAGE_BK) as rows_keyed,
           count(*) - count(COVERAGE_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_cov_covp_sp_pv') }}
union all
    select 'HUB_POLICY' as hub, 'uwr_pol_ins_cov_covp_sp_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(POLICY_BK) as rows_keyed,
           count(*) - count(POLICY_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_cov_covp_sp_pv') }}
union all
    select 'HUB_RISK_OBJECT' as hub, 'uwr_pol_ins_cov_covp_sp_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(RISK_OBJECT_BK) as rows_keyed,
           count(*) - count(RISK_OBJECT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_cov_covp_sp_pv') }}
union all
    select 'HUB_DOCUMENT' as hub, 'uwr_pol_ins_doc' as feeder, '-' as instance,
           count(*) as rows_in,
           count(DOCUMENT_BK) as rows_keyed,
           count(*) - count(DOCUMENT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_doc') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_ins_mbr' as feeder, 'insured-member' as instance,
           count(*) as rows_in,
           count(PARTY_BK__INSURED_MEMBER) as rows_keyed,
           count(*) - count(PARTY_BK__INSURED_MEMBER) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_ins_mbr' as feeder, 'parent-party' as instance,
           count(*) as rows_in,
           count(PARTY_BK__PARENT_PARTY) as rows_keyed,
           count(*) - count(PARTY_BK__PARENT_PARTY) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr') }}
union all
    select 'HUB_POLICY' as hub, 'uwr_pol_ins_mbr' as feeder, 'insured-member' as instance,
           count(*) as rows_in,
           count(POLICY_BK__INSURED_MEMBER) as rows_keyed,
           count(*) - count(POLICY_BK__INSURED_MEMBER) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr') }}
union all
    select 'HUB_DOCUMENT' as hub, 'uwr_pol_ins_mbr_document_detail' as feeder, '-' as instance,
           count(*) as rows_in,
           count(DOCUMENT_BK) as rows_keyed,
           count(*) - count(DOCUMENT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_document_detail') }}
union all
    select 'HUB_LOCATION' as hub, 'uwr_pol_ins_mbr_pa' as feeder, 'insured-member-address' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__INSURED_MEMBER_ADDRESS) as rows_keyed,
           count(*) - count(LOCATION_BK__INSURED_MEMBER_ADDRESS) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pa') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_ins_mbr_pa' as feeder, 'insured-member' as instance,
           count(*) as rows_in,
           count(PARTY_BK__INSURED_MEMBER) as rows_keyed,
           count(*) - count(PARTY_BK__INSURED_MEMBER) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pa') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_ins_mbr_pa' as feeder, 'insured-member-address' as instance,
           count(*) as rows_in,
           count(PARTY_BK__INSURED_MEMBER_ADDRESS) as rows_keyed,
           count(*) - count(PARTY_BK__INSURED_MEMBER_ADDRESS) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pa') }}
union all
    select 'HUB_LOCATION' as hub, 'uwr_pol_ins_mbr_pa_address_prop_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(LOCATION_BK) as rows_keyed,
           count(*) - count(LOCATION_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pa_address_prop_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'uwr_pol_ins_mbr_pa_address_prop_pv' as feeder, 'insured-member' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__INSURED_MEMBER) as rows_keyed,
           count(*) - count(LOCATION_BK__INSURED_MEMBER) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pa_address_prop_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_ins_mbr_pa_address_prop_pv' as feeder, 'insured-member' as instance,
           count(*) as rows_in,
           count(PARTY_BK__INSURED_MEMBER) as rows_keyed,
           count(*) - count(PARTY_BK__INSURED_MEMBER) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pa_address_prop_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_ins_mbr_pp_msp_msd_prop_pv' as feeder, 'insured-member' as instance,
           count(*) as rows_in,
           count(PARTY_BK__INSURED_MEMBER) as rows_keyed,
           count(*) - count(PARTY_BK__INSURED_MEMBER) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pp_msp_msd_prop_pv') }}
union all
    select 'HUB_DISTRIBUTION_CHANNEL' as hub, 'uwr_pol_ins_mbr_pp_sp_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(DISTRIBUTION_CHANNEL_BK) as rows_keyed,
           count(*) - count(DISTRIBUTION_CHANNEL_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'uwr_pol_ins_mbr_pp_sp_pv' as feeder, 'correspondence-local' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__CORRESPONDENCE_LOCAL) as rows_keyed,
           count(*) - count(LOCATION_BK__CORRESPONDENCE_LOCAL) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'uwr_pol_ins_mbr_pp_sp_pv' as feeder, 'insured-member@correspondence-local' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__INSURED_MEMBER_CORRESPONDENCE_LOCAL) as rows_keyed,
           count(*) - count(LOCATION_BK__INSURED_MEMBER_CORRESPONDENCE_LOCAL) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'uwr_pol_ins_mbr_pp_sp_pv' as feeder, 'insured-member@permanent-overseas' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__INSURED_MEMBER_PERMANENT_OVERSEAS) as rows_keyed,
           count(*) - count(LOCATION_BK__INSURED_MEMBER_PERMANENT_OVERSEAS) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'uwr_pol_ins_mbr_pp_sp_pv' as feeder, 'permanent-overseas' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__PERMANENT_OVERSEAS) as rows_keyed,
           count(*) - count(LOCATION_BK__PERMANENT_OVERSEAS) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_ins_mbr_pp_sp_pv' as feeder, 'insured-member' as instance,
           count(*) as rows_in,
           count(PARTY_BK__INSURED_MEMBER) as rows_keyed,
           count(*) - count(PARTY_BK__INSURED_MEMBER) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_ins_mbr_pp_sp_pv' as feeder, 'insured-member@correspondence-local' as instance,
           count(*) as rows_in,
           count(PARTY_BK__INSURED_MEMBER_CORRESPONDENCE_LOCAL) as rows_keyed,
           count(*) - count(PARTY_BK__INSURED_MEMBER_CORRESPONDENCE_LOCAL) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_ins_mbr_pp_sp_pv' as feeder, 'insured-member@permanent-overseas' as instance,
           count(*) as rows_in,
           count(PARTY_BK__INSURED_MEMBER_PERMANENT_OVERSEAS) as rows_keyed,
           count(*) - count(PARTY_BK__INSURED_MEMBER_PERMANENT_OVERSEAS) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_ins_mbr_pp_sp_pv' as feeder, 'parent-party' as instance,
           count(*) as rows_in,
           count(PARTY_BK__PARENT_PARTY) as rows_keyed,
           count(*) - count(PARTY_BK__PARENT_PARTY) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
union all
    select 'HUB_QUOTE' as hub, 'uwr_pol_ins_mbr_pp_sp_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(QUOTE_BK) as rows_keyed,
           count(*) - count(QUOTE_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_ins_mbr_party_relation' as feeder, 'insured-member' as instance,
           count(*) as rows_in,
           count(PARTY_BK__INSURED_MEMBER) as rows_keyed,
           count(*) - count(PARTY_BK__INSURED_MEMBER) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_party_relation') }}
union all
    select 'HUB_POLICY' as hub, 'uwr_pol_ins_mbr_party_relation' as feeder, 'insured-member' as instance,
           count(*) as rows_in,
           count(POLICY_BK__INSURED_MEMBER) as rows_keyed,
           count(*) - count(POLICY_BK__INSURED_MEMBER) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_party_relation') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_ins_rskp_msp_msd_prop_pv' as feeder, 'nominee' as instance,
           count(*) as rows_in,
           count(PARTY_BK__NOMINEE) as rows_keyed,
           count(*) - count(PARTY_BK__NOMINEE) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
union all
    select 'HUB_RISK_OBJECT' as hub, 'uwr_pol_ins_rskp_msp_msd_prop_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(RISK_OBJECT_BK) as rows_keyed,
           count(*) - count(RISK_OBJECT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
union all
    select 'HUB_COVERAGE' as hub, 'uwr_pol_ins_rskp_sp_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(COVERAGE_BK) as rows_keyed,
           count(*) - count(COVERAGE_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_rskp_sp_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_ins_rskp_sp_pv' as feeder, 'policyholder' as instance,
           count(*) as rows_in,
           count(PARTY_BK__POLICYHOLDER) as rows_keyed,
           count(*) - count(PARTY_BK__POLICYHOLDER) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_rskp_sp_pv') }}
union all
    select 'HUB_POLICY' as hub, 'uwr_pol_ins_rskp_sp_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(POLICY_BK) as rows_keyed,
           count(*) - count(POLICY_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_rskp_sp_pv') }}
union all
    select 'HUB_PRODUCT' as hub, 'uwr_pol_ins_rskp_sp_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(PRODUCT_BK) as rows_keyed,
           count(*) - count(PRODUCT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_rskp_sp_pv') }}
union all
    select 'HUB_RISK_OBJECT' as hub, 'uwr_pol_ins_rskp_sp_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(RISK_OBJECT_BK) as rows_keyed,
           count(*) - count(RISK_OBJECT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_rskp_sp_pv') }}
union all
    select 'HUB_RISK_OBJECT' as hub, 'uwr_pol_ins_rskp_sp_pv' as feeder, 'insured-traveller-risk' as instance,
           count(*) as rows_in,
           count(RISK_OBJECT_BK__INSURED_TRAVELLER_RISK) as rows_keyed,
           count(*) - count(RISK_OBJECT_BK__INSURED_TRAVELLER_RISK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_ins_rskp_sp_pv') }}
union all
    select 'HUB_ORG_UNIT' as hub, 'uwr_pol_off' as feeder, '-' as instance,
           count(*) as rows_in,
           count(ORG_UNIT_BK) as rows_keyed,
           count(*) - count(ORG_UNIT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_off') }}
union all
    select 'HUB_LOCATION' as hub, 'uwr_pol_off_oa' as feeder, 'office-address' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__OFFICE_ADDRESS) as rows_keyed,
           count(*) - count(LOCATION_BK__OFFICE_ADDRESS) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_off_oa') }}
union all
    select 'HUB_ORG_UNIT' as hub, 'uwr_pol_off_oa' as feeder, 'office-address' as instance,
           count(*) as rows_in,
           count(ORG_UNIT_BK__OFFICE_ADDRESS) as rows_keyed,
           count(*) - count(ORG_UNIT_BK__OFFICE_ADDRESS) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_off_oa') }}
union all
    select 'HUB_LOCATION' as hub, 'uwr_pol_off_oa_address_prop_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(LOCATION_BK) as rows_keyed,
           count(*) - count(LOCATION_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_off_oa_address_prop_pv') }}
union all
    select 'HUB_ORG_UNIT' as hub, 'uwr_pol_off_oa_address_prop_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(ORG_UNIT_BK) as rows_keyed,
           count(*) - count(ORG_UNIT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_off_oa_address_prop_pv') }}
union all
    select 'HUB_FINANCIAL_TRANSACTION' as hub, 'uwr_pol_policy_payment_information' as feeder, '-' as instance,
           count(*) as rows_in,
           count(FINANCIAL_TRANSACTION_BK) as rows_keyed,
           count(*) - count(FINANCIAL_TRANSACTION_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_policy_payment_information') }}
union all
    select 'HUB_PAYMENT_INSTRUMENT' as hub, 'uwr_pol_policy_payment_information' as feeder, '-' as instance,
           count(*) as rows_in,
           count(PAYMENT_INSTRUMENT_BK) as rows_keyed,
           count(*) - count(PAYMENT_INSTRUMENT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_policy_payment_information') }}
union all
    select 'HUB_POLICY' as hub, 'uwr_pol_polp_msp_msd_prop_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(POLICY_BK) as rows_keyed,
           count(*) - count(POLICY_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_polp_msp_msd_prop_pv') }}
union all
    select 'HUB_RISK_OBJECT' as hub, 'uwr_pol_polp_msp_msd_prop_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(RISK_OBJECT_BK) as rows_keyed,
           count(*) - count(RISK_OBJECT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_polp_msp_msd_prop_pv') }}
union all
    select 'HUB_ASSESSMENT' as hub, 'uwr_pol_polp_sp_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(ASSESSMENT_BK) as rows_keyed,
           count(*) - count(ASSESSMENT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
union all
    select 'HUB_DISTRIBUTION_CHANNEL' as hub, 'uwr_pol_polp_sp_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(DISTRIBUTION_CHANNEL_BK) as rows_keyed,
           count(*) - count(DISTRIBUTION_CHANNEL_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
union all
    select 'HUB_DOCUMENT' as hub, 'uwr_pol_polp_sp_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(DOCUMENT_BK) as rows_keyed,
           count(*) - count(DOCUMENT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
union all
    select 'HUB_DOCUMENT' as hub, 'uwr_pol_polp_sp_pv' as feeder, 'previous-certificate' as instance,
           count(*) as rows_in,
           count(DOCUMENT_BK__PREVIOUS_CERTIFICATE) as rows_keyed,
           count(*) - count(DOCUMENT_BK__PREVIOUS_CERTIFICATE) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
union all
    select 'HUB_FINANCIAL_TRANSACTION' as hub, 'uwr_pol_polp_sp_pv' as feeder, 'policy-premium' as instance,
           count(*) as rows_in,
           count(FINANCIAL_TRANSACTION_BK__POLICY_PREMIUM) as rows_keyed,
           count(*) - count(FINANCIAL_TRANSACTION_BK__POLICY_PREMIUM) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
union all
    select 'HUB_ORG_UNIT' as hub, 'uwr_pol_polp_sp_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(ORG_UNIT_BK) as rows_keyed,
           count(*) - count(ORG_UNIT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_polp_sp_pv' as feeder, 'policyholder' as instance,
           count(*) as rows_in,
           count(PARTY_BK__POLICYHOLDER) as rows_keyed,
           count(*) - count(PARTY_BK__POLICYHOLDER) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_polp_sp_pv' as feeder, 'relationship-manager' as instance,
           count(*) as rows_in,
           count(PARTY_BK__RELATIONSHIP_MANAGER) as rows_keyed,
           count(*) - count(PARTY_BK__RELATIONSHIP_MANAGER) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
union all
    select 'HUB_POLICY' as hub, 'uwr_pol_polp_sp_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(POLICY_BK) as rows_keyed,
           count(*) - count(POLICY_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
union all
    select 'HUB_POLICY' as hub, 'uwr_pol_polp_sp_pv' as feeder, 'master-policy' as instance,
           count(*) as rows_in,
           count(POLICY_BK__MASTER_POLICY) as rows_keyed,
           count(*) - count(POLICY_BK__MASTER_POLICY) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
union all
    select 'HUB_POLICY' as hub, 'uwr_pol_polp_sp_pv' as feeder, 'previous-policy' as instance,
           count(*) as rows_in,
           count(POLICY_BK__PREVIOUS_POLICY) as rows_keyed,
           count(*) - count(POLICY_BK__PREVIOUS_POLICY) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
union all
    select 'HUB_PRODUCT' as hub, 'uwr_pol_polp_sp_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(PRODUCT_BK) as rows_keyed,
           count(*) - count(PRODUCT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_policy_relation' as feeder, '-' as instance,
           count(*) as rows_in,
           count(PARTY_BK) as rows_keyed,
           count(*) - count(PARTY_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_policy_relation') }}
union all
    select 'HUB_POLICY' as hub, 'uwr_pol_policy_relation' as feeder, '-' as instance,
           count(*) as rows_in,
           count(POLICY_BK) as rows_keyed,
           count(*) - count(POLICY_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_policy_relation') }}
union all
    select 'HUB_POLICY' as hub, 'uwr_pol_prevpol' as feeder, 'previous-policy' as instance,
           count(*) as rows_in,
           count(POLICY_BK__PREVIOUS_POLICY) as rows_keyed,
           count(*) - count(POLICY_BK__PREVIOUS_POLICY) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prevpol') }}
union all
    select 'HUB_PRODUCT' as hub, 'uwr_pol_prevpol' as feeder, '-' as instance,
           count(*) as rows_in,
           count(PRODUCT_BK) as rows_keyed,
           count(*) - count(PRODUCT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prevpol') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_prp' as feeder, 'parent-party' as instance,
           count(*) as rows_in,
           count(PARTY_BK__PARENT_PARTY) as rows_keyed,
           count(*) - count(PARTY_BK__PARENT_PARTY) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_prp' as feeder, 'proposer' as instance,
           count(*) as rows_in,
           count(PARTY_BK__PROPOSER) as rows_keyed,
           count(*) - count(PARTY_BK__PROPOSER) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp') }}
union all
    select 'HUB_POLICY' as hub, 'uwr_pol_prp' as feeder, 'proposer' as instance,
           count(*) as rows_in,
           count(POLICY_BK__PROPOSER) as rows_keyed,
           count(*) - count(POLICY_BK__PROPOSER) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp') }}
union all
    select 'HUB_DOCUMENT' as hub, 'uwr_pol_prp_document_detail' as feeder, '-' as instance,
           count(*) as rows_in,
           count(DOCUMENT_BK) as rows_keyed,
           count(*) - count(DOCUMENT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp_document_detail') }}
union all
    select 'HUB_LOCATION' as hub, 'uwr_pol_prp_pa' as feeder, 'proposer-address' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__PROPOSER_ADDRESS) as rows_keyed,
           count(*) - count(LOCATION_BK__PROPOSER_ADDRESS) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp_pa') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_prp_pa' as feeder, 'proposer' as instance,
           count(*) as rows_in,
           count(PARTY_BK__PROPOSER) as rows_keyed,
           count(*) - count(PARTY_BK__PROPOSER) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp_pa') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_prp_pa' as feeder, 'proposer-address' as instance,
           count(*) as rows_in,
           count(PARTY_BK__PROPOSER_ADDRESS) as rows_keyed,
           count(*) - count(PARTY_BK__PROPOSER_ADDRESS) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp_pa') }}
union all
    select 'HUB_LOCATION' as hub, 'uwr_pol_prp_pa_address_prop_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(LOCATION_BK) as rows_keyed,
           count(*) - count(LOCATION_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp_pa_address_prop_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'uwr_pol_prp_pa_address_prop_pv' as feeder, 'proposer' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__PROPOSER) as rows_keyed,
           count(*) - count(LOCATION_BK__PROPOSER) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp_pa_address_prop_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_prp_pa_address_prop_pv' as feeder, 'proposer' as instance,
           count(*) as rows_in,
           count(PARTY_BK__PROPOSER) as rows_keyed,
           count(*) - count(PARTY_BK__PROPOSER) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp_pa_address_prop_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_prp_pp_msp_msd_prop_pv' as feeder, 'proposer' as instance,
           count(*) as rows_in,
           count(PARTY_BK__PROPOSER) as rows_keyed,
           count(*) - count(PARTY_BK__PROPOSER) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp_pp_msp_msd_prop_pv') }}
union all
    select 'HUB_DISTRIBUTION_CHANNEL' as hub, 'uwr_pol_prp_pp_sp_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(DISTRIBUTION_CHANNEL_BK) as rows_keyed,
           count(*) - count(DISTRIBUTION_CHANNEL_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
union all
    select 'HUB_DISTRIBUTION_CHANNEL' as hub, 'uwr_pol_prp_pp_sp_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(DISTRIBUTION_CHANNEL_BK__V2) as rows_keyed,
           count(*) - count(DISTRIBUTION_CHANNEL_BK__V2) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'uwr_pol_prp_pp_sp_pv' as feeder, 'correspondence-local' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__CORRESPONDENCE_LOCAL) as rows_keyed,
           count(*) - count(LOCATION_BK__CORRESPONDENCE_LOCAL) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'uwr_pol_prp_pp_sp_pv' as feeder, 'permanent-overseas' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__PERMANENT_OVERSEAS) as rows_keyed,
           count(*) - count(LOCATION_BK__PERMANENT_OVERSEAS) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'uwr_pol_prp_pp_sp_pv' as feeder, 'proposer@correspondence-local' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__PROPOSER_CORRESPONDENCE_LOCAL) as rows_keyed,
           count(*) - count(LOCATION_BK__PROPOSER_CORRESPONDENCE_LOCAL) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
union all
    select 'HUB_LOCATION' as hub, 'uwr_pol_prp_pp_sp_pv' as feeder, 'proposer@permanent-overseas' as instance,
           count(*) as rows_in,
           count(LOCATION_BK__PROPOSER_PERMANENT_OVERSEAS) as rows_keyed,
           count(*) - count(LOCATION_BK__PROPOSER_PERMANENT_OVERSEAS) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
union all
    select 'HUB_ORG_UNIT' as hub, 'uwr_pol_prp_pp_sp_pv' as feeder, 'servicing-branch' as instance,
           count(*) as rows_in,
           count(ORG_UNIT_BK__SERVICING_BRANCH) as rows_keyed,
           count(*) - count(ORG_UNIT_BK__SERVICING_BRANCH) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_prp_pp_sp_pv' as feeder, 'bagic-employee' as instance,
           count(*) as rows_in,
           count(PARTY_BK__BAGIC_EMPLOYEE) as rows_keyed,
           count(*) - count(PARTY_BK__BAGIC_EMPLOYEE) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_prp_pp_sp_pv' as feeder, 'parent-party' as instance,
           count(*) as rows_in,
           count(PARTY_BK__PARENT_PARTY) as rows_keyed,
           count(*) - count(PARTY_BK__PARENT_PARTY) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_prp_pp_sp_pv' as feeder, 'proposer' as instance,
           count(*) as rows_in,
           count(PARTY_BK__PROPOSER) as rows_keyed,
           count(*) - count(PARTY_BK__PROPOSER) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_prp_pp_sp_pv' as feeder, 'proposer@correspondence-local' as instance,
           count(*) as rows_in,
           count(PARTY_BK__PROPOSER_CORRESPONDENCE_LOCAL) as rows_keyed,
           count(*) - count(PARTY_BK__PROPOSER_CORRESPONDENCE_LOCAL) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_prp_pp_sp_pv' as feeder, 'proposer@permanent-overseas' as instance,
           count(*) as rows_in,
           count(PARTY_BK__PROPOSER_PERMANENT_OVERSEAS) as rows_keyed,
           count(*) - count(PARTY_BK__PROPOSER_PERMANENT_OVERSEAS) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_pol_prp_party_relation' as feeder, 'proposer' as instance,
           count(*) as rows_in,
           count(PARTY_BK__PROPOSER) as rows_keyed,
           count(*) - count(PARTY_BK__PROPOSER) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp_party_relation') }}
union all
    select 'HUB_POLICY' as hub, 'uwr_pol_prp_party_relation' as feeder, 'proposer' as instance,
           count(*) as rows_in,
           count(POLICY_BK__PROPOSER) as rows_keyed,
           count(*) - count(POLICY_BK__PROPOSER) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_prp_party_relation') }}
union all
    select 'HUB_ASSESSMENT' as hub, 'uwr_pol_tele' as feeder, 'tele-verification' as instance,
           count(*) as rows_in,
           count(ASSESSMENT_BK__TELE_VERIFICATION) as rows_keyed,
           count(*) - count(ASSESSMENT_BK__TELE_VERIFICATION) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_tele') }}
union all
    select 'HUB_POLICY' as hub, 'uwr_pol_wrk' as feeder, '-' as instance,
           count(*) as rows_in,
           count(POLICY_BK) as rows_keyed,
           count(*) - count(POLICY_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_pol_wrk') }}
union all
    select 'HUB_POLICY' as hub, 'uwr_prem' as feeder, '-' as instance,
           count(*) as rows_in,
           count(POLICY_BK) as rows_keyed,
           count(*) - count(POLICY_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_prem') }}
union all
    select 'HUB_DISTRIBUTION_CHANNEL' as hub, 'uwr_qpd' as feeder, '-' as instance,
           count(*) as rows_in,
           count(DISTRIBUTION_CHANNEL_BK) as rows_keyed,
           count(*) - count(DISTRIBUTION_CHANNEL_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd') }}
union all
    select 'HUB_DOCUMENT' as hub, 'uwr_qpd' as feeder, '-' as instance,
           count(*) as rows_in,
           count(DOCUMENT_BK) as rows_keyed,
           count(*) - count(DOCUMENT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd') }}
union all
    select 'HUB_FINANCIAL_TRANSACTION' as hub, 'uwr_qpd' as feeder, 'quote-premium' as instance,
           count(*) as rows_in,
           count(FINANCIAL_TRANSACTION_BK__QUOTE_PREMIUM) as rows_keyed,
           count(*) - count(FINANCIAL_TRANSACTION_BK__QUOTE_PREMIUM) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd') }}
union all
    select 'HUB_ORG_UNIT' as hub, 'uwr_qpd' as feeder, 'policy-issuing-branch' as instance,
           count(*) as rows_in,
           count(ORG_UNIT_BK__POLICY_ISSUING_BRANCH) as rows_keyed,
           count(*) - count(ORG_UNIT_BK__POLICY_ISSUING_BRANCH) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_qpd' as feeder, 'policyholder' as instance,
           count(*) as rows_in,
           count(PARTY_BK__POLICYHOLDER) as rows_keyed,
           count(*) - count(PARTY_BK__POLICYHOLDER) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd') }}
union all
    select 'HUB_PRODUCT' as hub, 'uwr_qpd' as feeder, '-' as instance,
           count(*) as rows_in,
           count(PRODUCT_BK) as rows_keyed,
           count(*) - count(PRODUCT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd') }}
union all
    select 'HUB_QUOTE' as hub, 'uwr_qpd' as feeder, '-' as instance,
           count(*) as rows_in,
           count(QUOTE_BK) as rows_keyed,
           count(*) - count(QUOTE_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd') }}
union all
    select 'HUB_QUOTE' as hub, 'uwr_qpd_polp' as feeder, '-' as instance,
           count(*) as rows_in,
           count(QUOTE_BK) as rows_keyed,
           count(*) - count(QUOTE_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_polp') }}
union all
    select 'HUB_QUOTE' as hub, 'uwr_qpd_polp_msp_imsd_inp_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(QUOTE_BK) as rows_keyed,
           count(*) - count(QUOTE_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_polp_msp_imsd_inp_pv') }}
union all
    select 'HUB_ASSESSMENT' as hub, 'uwr_qpd_polp_rl_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(ASSESSMENT_BK) as rows_keyed,
           count(*) - count(ASSESSMENT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
union all
    select 'HUB_DISTRIBUTION_CHANNEL' as hub, 'uwr_qpd_polp_rl_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(DISTRIBUTION_CHANNEL_BK) as rows_keyed,
           count(*) - count(DISTRIBUTION_CHANNEL_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
union all
    select 'HUB_DOCUMENT' as hub, 'uwr_qpd_polp_rl_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(DOCUMENT_BK) as rows_keyed,
           count(*) - count(DOCUMENT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
union all
    select 'HUB_DOCUMENT' as hub, 'uwr_qpd_polp_rl_pv' as feeder, 'previous-certificate' as instance,
           count(*) as rows_in,
           count(DOCUMENT_BK__PREVIOUS_CERTIFICATE) as rows_keyed,
           count(*) - count(DOCUMENT_BK__PREVIOUS_CERTIFICATE) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
union all
    select 'HUB_FINANCIAL_TRANSACTION' as hub, 'uwr_qpd_polp_rl_pv' as feeder, 'quote-premium' as instance,
           count(*) as rows_in,
           count(FINANCIAL_TRANSACTION_BK__QUOTE_PREMIUM) as rows_keyed,
           count(*) - count(FINANCIAL_TRANSACTION_BK__QUOTE_PREMIUM) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
union all
    select 'HUB_ORG_UNIT' as hub, 'uwr_qpd_polp_rl_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(ORG_UNIT_BK) as rows_keyed,
           count(*) - count(ORG_UNIT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_qpd_polp_rl_pv' as feeder, 'policyholder' as instance,
           count(*) as rows_in,
           count(PARTY_BK__POLICYHOLDER) as rows_keyed,
           count(*) - count(PARTY_BK__POLICYHOLDER) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_qpd_polp_rl_pv' as feeder, 'relationship-manager' as instance,
           count(*) as rows_in,
           count(PARTY_BK__RELATIONSHIP_MANAGER) as rows_keyed,
           count(*) - count(PARTY_BK__RELATIONSHIP_MANAGER) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_qpd_polp_rl_pv' as feeder, 'sub-intermediary' as instance,
           count(*) as rows_in,
           count(PARTY_BK__SUB_INTERMEDIARY) as rows_keyed,
           count(*) - count(PARTY_BK__SUB_INTERMEDIARY) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
union all
    select 'HUB_POLICY' as hub, 'uwr_qpd_polp_rl_pv' as feeder, 'master-policy' as instance,
           count(*) as rows_in,
           count(POLICY_BK__MASTER_POLICY) as rows_keyed,
           count(*) - count(POLICY_BK__MASTER_POLICY) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
union all
    select 'HUB_POLICY' as hub, 'uwr_qpd_polp_rl_pv' as feeder, 'previous-policy' as instance,
           count(*) as rows_in,
           count(POLICY_BK__PREVIOUS_POLICY) as rows_keyed,
           count(*) - count(POLICY_BK__PREVIOUS_POLICY) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
union all
    select 'HUB_POLICY' as hub, 'uwr_qpd_polp_rl_pv' as feeder, 'previous-policy-portability' as instance,
           count(*) as rows_in,
           count(POLICY_BK__PREVIOUS_POLICY_PORTABILITY) as rows_keyed,
           count(*) - count(POLICY_BK__PREVIOUS_POLICY_PORTABILITY) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
union all
    select 'HUB_PRODUCT' as hub, 'uwr_qpd_polp_rl_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(PRODUCT_BK) as rows_keyed,
           count(*) - count(PRODUCT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
union all
    select 'HUB_QUOTE' as hub, 'uwr_qpd_polp_rl_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(QUOTE_BK) as rows_keyed,
           count(*) - count(QUOTE_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
union all
    select 'HUB_DOCUMENT' as hub, 'uwr_qpd_rskl' as feeder, '-' as instance,
           count(*) as rows_in,
           count(DOCUMENT_BK) as rows_keyed,
           count(*) - count(DOCUMENT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl') }}
union all
    select 'HUB_FINANCIAL_TRANSACTION' as hub, 'uwr_qpd_rskl' as feeder, 'quote-risk-premium' as instance,
           count(*) as rows_in,
           count(FINANCIAL_TRANSACTION_BK__QUOTE_RISK_PREMIUM) as rows_keyed,
           count(*) - count(FINANCIAL_TRANSACTION_BK__QUOTE_RISK_PREMIUM) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl') }}
union all
    select 'HUB_LOCATION' as hub, 'uwr_qpd_rskl' as feeder, '-' as instance,
           count(*) as rows_in,
           count(LOCATION_BK) as rows_keyed,
           count(*) - count(LOCATION_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_qpd_rskl' as feeder, '-' as instance,
           count(*) as rows_in,
           count(PARTY_BK) as rows_keyed,
           count(*) - count(PARTY_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_qpd_rskl' as feeder, 'additional-party' as instance,
           count(*) as rows_in,
           count(PARTY_BK__ADDITIONAL_PARTY) as rows_keyed,
           count(*) - count(PARTY_BK__ADDITIONAL_PARTY) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl') }}
union all
    select 'HUB_QUOTE' as hub, 'uwr_qpd_rskl' as feeder, '-' as instance,
           count(*) as rows_in,
           count(QUOTE_BK) as rows_keyed,
           count(*) - count(QUOTE_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl') }}
union all
    select 'HUB_RISK_OBJECT' as hub, 'uwr_qpd_rskl' as feeder, '-' as instance,
           count(*) as rows_in,
           count(RISK_OBJECT_BK) as rows_keyed,
           count(*) - count(RISK_OBJECT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_qpd_rskl_msp_imsd_inp_pv' as feeder, 'nominee' as instance,
           count(*) as rows_in,
           count(PARTY_BK__NOMINEE) as rows_keyed,
           count(*) - count(PARTY_BK__NOMINEE) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl_msp_imsd_inp_pv') }}
union all
    select 'HUB_QUOTE' as hub, 'uwr_qpd_rskl_msp_imsd_inp_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(QUOTE_BK) as rows_keyed,
           count(*) - count(QUOTE_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl_msp_imsd_inp_pv') }}
union all
    select 'HUB_RISK_OBJECT' as hub, 'uwr_qpd_rskl_msp_imsd_inp_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(RISK_OBJECT_BK) as rows_keyed,
           count(*) - count(RISK_OBJECT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl_msp_imsd_inp_pv') }}
union all
    select 'HUB_COVERAGE' as hub, 'uwr_qpd_rskl_rskc' as feeder, '-' as instance,
           count(*) as rows_in,
           count(COVERAGE_BK) as rows_keyed,
           count(*) - count(COVERAGE_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskc') }}
union all
    select 'HUB_QUOTE' as hub, 'uwr_qpd_rskl_rskc' as feeder, '-' as instance,
           count(*) as rows_in,
           count(QUOTE_BK) as rows_keyed,
           count(*) - count(QUOTE_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskc') }}
union all
    select 'HUB_RISK_OBJECT' as hub, 'uwr_qpd_rskl_rskc' as feeder, '-' as instance,
           count(*) as rows_in,
           count(RISK_OBJECT_BK) as rows_keyed,
           count(*) - count(RISK_OBJECT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskc') }}
union all
    select 'HUB_QUOTE' as hub, 'uwr_qpd_rskl_rskc_rskc_prop' as feeder, '-' as instance,
           count(*) as rows_in,
           count(QUOTE_BK) as rows_keyed,
           count(*) - count(QUOTE_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskc_rskc_prop') }}
union all
    select 'HUB_COVERAGE' as hub, 'uwr_qpd_rskl_rskc_rskc_prop_rl_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(COVERAGE_BK) as rows_keyed,
           count(*) - count(COVERAGE_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskc_rskc_prop_rl_pv') }}
union all
    select 'HUB_QUOTE' as hub, 'uwr_qpd_rskl_rskc_rskc_prop_rl_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(QUOTE_BK) as rows_keyed,
           count(*) - count(QUOTE_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskc_rskc_prop_rl_pv') }}
union all
    select 'HUB_RISK_OBJECT' as hub, 'uwr_qpd_rskl_rskc_rskc_prop_rl_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(RISK_OBJECT_BK) as rows_keyed,
           count(*) - count(RISK_OBJECT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskc_rskc_prop_rl_pv') }}
union all
    select 'HUB_QUOTE' as hub, 'uwr_qpd_rskl_rskp' as feeder, '-' as instance,
           count(*) as rows_in,
           count(QUOTE_BK) as rows_keyed,
           count(*) - count(QUOTE_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskp') }}
union all
    select 'HUB_COVERAGE' as hub, 'uwr_qpd_rskl_rskp_rl_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(COVERAGE_BK) as rows_keyed,
           count(*) - count(COVERAGE_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskp_rl_pv') }}
union all
    select 'HUB_PARTY' as hub, 'uwr_qpd_rskl_rskp_rl_pv' as feeder, 'policyholder' as instance,
           count(*) as rows_in,
           count(PARTY_BK__POLICYHOLDER) as rows_keyed,
           count(*) - count(PARTY_BK__POLICYHOLDER) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskp_rl_pv') }}
union all
    select 'HUB_PRODUCT' as hub, 'uwr_qpd_rskl_rskp_rl_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(PRODUCT_BK) as rows_keyed,
           count(*) - count(PRODUCT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskp_rl_pv') }}
union all
    select 'HUB_QUOTE' as hub, 'uwr_qpd_rskl_rskp_rl_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(QUOTE_BK) as rows_keyed,
           count(*) - count(QUOTE_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskp_rl_pv') }}
union all
    select 'HUB_RISK_OBJECT' as hub, 'uwr_qpd_rskl_rskp_rl_pv' as feeder, '-' as instance,
           count(*) as rows_in,
           count(RISK_OBJECT_BK) as rows_keyed,
           count(*) - count(RISK_OBJECT_BK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskp_rl_pv') }}
union all
    select 'HUB_RISK_OBJECT' as hub, 'uwr_qpd_rskl_rskp_rl_pv' as feeder, 'quoted-traveller-risk' as instance,
           count(*) as rows_in,
           count(RISK_OBJECT_BK__QUOTED_TRAVELLER_RISK) as rows_keyed,
           count(*) - count(RISK_OBJECT_BK__QUOTED_TRAVELLER_RISK) as rows_rejected
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskp_rl_pv') }}
