-- One-off cleanup after RECORD_SOURCE changed from '!stitch_motor__vNN_*' to '!OPUS_stitch_motor__vNN_*'.
-- The condition below matches only the OLD value (the new one starts with OPUS_).
-- Hubs and links only insert keys they do not have, so keys loaded before the change keep the old value.
-- 'stitch_motor__v%' is written ONLY by opus_motor_dv_dbt, so these statements touch no other project's rows.
-- Run in a worksheet. Run a block only for the layers you have already loaded; a table that was never built
-- gives "does not exist", which is harmless. After deleting, re-run that layer: the keys come back with the new value.

-- ================= HUBS: 18 tables =================
-- 1) count motor's old rows
select 'HUB_AGREEMENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_AGREEMENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'HUB_ASSESSMENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_ASSESSMENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'HUB_CASE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_CASE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'HUB_CLAIM' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_CLAIM where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'HUB_COVERAGE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_COVERAGE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'HUB_DISTRIBUTION_CHANNEL' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DISTRIBUTION_CHANNEL where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'HUB_DOCUMENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DOCUMENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'HUB_FINANCIAL_TRANSACTION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_FINANCIAL_TRANSACTION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'HUB_LOCATION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOCATION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'HUB_LOSS_EVENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOSS_EVENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'HUB_ORG_UNIT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_ORG_UNIT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'HUB_PARTY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'HUB_PAYMENT_INSTRUMENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PAYMENT_INSTRUMENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'HUB_POLICY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'HUB_PRODUCT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PRODUCT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'HUB_PROPOSAL' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PROPOSAL where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'HUB_QUOTE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_QUOTE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'HUB_RISK_OBJECT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_RISK_OBJECT where RECORD_SOURCE like 'stitch_motor__v%';

-- 2) delete them
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_AGREEMENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_ASSESSMENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_CASE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_CLAIM where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_COVERAGE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DISTRIBUTION_CHANNEL where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DOCUMENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_FINANCIAL_TRANSACTION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOCATION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOSS_EVENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_ORG_UNIT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PAYMENT_INSTRUMENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PRODUCT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PROPOSAL where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_QUOTE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_RISK_OBJECT where RECORD_SOURCE like 'stitch_motor__v%';

-- ================= LINKS: 36 tables =================
-- 1) count motor's old rows
select 'LNK_AGREEMENT_CHANNEL' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_AGREEMENT_CHANNEL where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_CASE_POLICY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_CASE_POLICY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_CHANNEL_ORG_UNIT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_CHANNEL_ORG_UNIT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_CLAIM_ASSESSMENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_CLAIM_ASSESSMENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_CLAIM_CASE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_CLAIM_CASE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_CLAIM_DOCUMENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_CLAIM_DOCUMENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_CLAIM_LOSS_EVENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_CLAIM_LOSS_EVENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_CLAIM_POLICY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_CLAIM_POLICY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_CLAIM_RISK_OBJECT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_CLAIM_RISK_OBJECT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_FINTXN_CLAIM' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_FINTXN_CLAIM where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_FINTXN_INSTRUMENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_FINTXN_INSTRUMENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_FINTXN_POLICY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_FINTXN_POLICY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_LOSS_EVENT_RISK_OBJECT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_LOSS_EVENT_RISK_OBJECT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_ORG_UNIT_LOCATION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_ORG_UNIT_LOCATION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_PARTY_LOCATION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_PARTY_LOCATION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_PARTY_ROLE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_PARTY_ROLE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_POLICY_CHANNEL' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_CHANNEL where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_POLICY_COVERAGE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_COVERAGE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_POLICY_COVERAGE_RISK' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_COVERAGE_RISK where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_POLICY_LOCATION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_LOCATION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_POLICY_ORG_UNIT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_ORG_UNIT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_POLICY_PARTY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_PARTY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_POLICY_PAYMENT_INSTRUMENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_PAYMENT_INSTRUMENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_POLICY_PRODUCT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_PRODUCT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_POLICY_RISK_OBJECT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_RISK_OBJECT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_PRODUCT_COVERAGE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_PRODUCT_COVERAGE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_PROPOSAL_ASSESSMENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_PROPOSAL_ASSESSMENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_PROPOSAL_PARTY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_PROPOSAL_PARTY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_PROPOSAL_POLICY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_PROPOSAL_POLICY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_PROPOSAL_PRODUCT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_PROPOSAL_PRODUCT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_PROPOSAL_RISK_OBJECT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_PROPOSAL_RISK_OBJECT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_QUOTE_PRODUCT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_QUOTE_PRODUCT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_QUOTE_PROPOSAL' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_QUOTE_PROPOSAL where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_QUOTE_RISK_OBJECT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_QUOTE_RISK_OBJECT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_RISK_OBJECT_ASSESSMENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_RISK_OBJECT_ASSESSMENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'LNK_RISK_OBJECT_LOCATION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_RISK_OBJECT_LOCATION where RECORD_SOURCE like 'stitch_motor__v%';

-- 2) delete them
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_AGREEMENT_CHANNEL where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_CASE_POLICY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_CHANNEL_ORG_UNIT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_CLAIM_ASSESSMENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_CLAIM_CASE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_CLAIM_DOCUMENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_CLAIM_LOSS_EVENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_CLAIM_POLICY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_CLAIM_RISK_OBJECT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_FINTXN_CLAIM where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_FINTXN_INSTRUMENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_FINTXN_POLICY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_LOSS_EVENT_RISK_OBJECT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_ORG_UNIT_LOCATION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_PARTY_LOCATION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_PARTY_ROLE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_CHANNEL where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_COVERAGE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_COVERAGE_RISK where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_LOCATION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_ORG_UNIT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_PARTY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_PAYMENT_INSTRUMENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_PRODUCT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_RISK_OBJECT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_PRODUCT_COVERAGE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_PROPOSAL_ASSESSMENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_PROPOSAL_PARTY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_PROPOSAL_POLICY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_PROPOSAL_PRODUCT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_PROPOSAL_RISK_OBJECT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_QUOTE_PRODUCT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_QUOTE_PROPOSAL where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_QUOTE_RISK_OBJECT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_RISK_OBJECT_ASSESSMENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_RISK_OBJECT_LOCATION where RECORD_SOURCE like 'stitch_motor__v%';

-- ================= SATELLITES (only if already loaded): 246 tables =================
-- 1) count motor's old rows
select 'SAT_MOTOR_AUG_AGREEMENT_DEFINITION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_AGREEMENT_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_ASSESSMENT_HEADER' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_ASSESSMENT_HEADER where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CASE_DOCUMENT_CHECKLIST' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CASE_DOCUMENT_CHECKLIST where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CASE_HEADER' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CASE_HEADER where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CASE_LITIGATION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CASE_LITIGATION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CASE_SERVICE_REQUEST' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CASE_SERVICE_REQUEST where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CASE_WORKFLOW_TASK' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CASE_WORKFLOW_TASK where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CHANNEL_DEFINITION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CHANNEL_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CHANNEL_DIGITAL_INTEGRATION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CHANNEL_DIGITAL_INTEGRATION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CHANNEL_FIELD_ACTIVITY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CHANNEL_FIELD_ACTIVITY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CHANNEL_SALES_TARGET' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CHANNEL_SALES_TARGET where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CLAIM_ASSESSMENT_SUMMARY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_ASSESSMENT_SUMMARY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CLAIM_CO_RI_SHARE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_CO_RI_SHARE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CLAIM_COMPARABLE_CLAIM' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_COMPARABLE_CLAIM where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CLAIM_DOC_CHECKLIST' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_DOC_CHECKLIST where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CLAIM_FNOL' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_FNOL where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CLAIM_FRAUD' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_FRAUD where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CLAIM_HEADER' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_HEADER where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CLAIM_LITIGATION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_LITIGATION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CLAIM_MOTOR_DETAIL' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_MOTOR_DETAIL where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CLAIM_PA_DETAIL' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_PA_DETAIL where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CLAIM_RECOVERY_EXPENSE_LINE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_RECOVERY_EXPENSE_LINE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CLAIM_RECOVERY_SALVAGE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_RECOVERY_SALVAGE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CLAIM_SALVAGE_BIDDER' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_SALVAGE_BIDDER where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CLAIM_SETTLEMENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_SETTLEMENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CLAIM_SLA_TRACKING' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_SLA_TRACKING where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CLAIM_SUB_FILE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_SUB_FILE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CLAIM_SURVEY_APPOINTMENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_SURVEY_APPOINTMENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CLAIM_THIRD_PARTY_LINE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_THIRD_PARTY_LINE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CLAIM_THIRD_PARTY_MACT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_THIRD_PARTY_MACT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_CLAIM_TP_FORENSIC' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_TP_FORENSIC where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_COMMON_ADDRESS' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_COMMON_ADDRESS where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_COMMON_ADMIN_GEOGRAPHY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_COMMON_ADMIN_GEOGRAPHY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_COMMON_BUSINESS_AUDIT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_COMMON_BUSINESS_AUDIT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_COMMON_CONTACT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_COMMON_CONTACT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_COMMON_GEO' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_COMMON_GEO where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_COVERAGE_CONDITIONS' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_COVERAGE_CONDITIONS where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_COVERAGE_MOTOR_ADDON_PARAMS' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_COVERAGE_MOTOR_ADDON_PARAMS where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_COVERAGE_MOTOR_LAID_UP' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_COVERAGE_MOTOR_LAID_UP where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_COVERAGE_PACKAGE_RATING' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_COVERAGE_PACKAGE_RATING where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_DOCUMENT_DEFINITION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_DOCUMENT_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_FIN_RECEIPT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_FIN_RECEIPT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_FINTXN_CHANNEL_AUTHORISATION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_FINTXN_CHANNEL_AUTHORISATION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_FINTXN_CLAIM_PAYMENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_FINTXN_CLAIM_PAYMENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_FINTXN_HEADER' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_FINTXN_HEADER where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_FINTXN_PREMIUM' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_FINTXN_PREMIUM where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_LOCATION_PROFILE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_LOCATION_PROFILE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_LOSS_EVENT_DETAIL' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_LOSS_EVENT_DETAIL where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_LOSS_LOCATION_ADDRESS' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_LOSS_LOCATION_ADDRESS where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_ORG_UNIT_DEFINITION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_ORG_UNIT_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PARTY_CONTACT_ADDRESS_LINK' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_CONTACT_ADDRESS_LINK where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PARTY_CORRESPONDENCE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_CORRESPONDENCE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PARTY_DIGITAL_IDENTITY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_DIGITAL_IDENTITY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PARTY_DIGITAL_JOURNEY_STAGE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_DIGITAL_JOURNEY_STAGE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PARTY_EMPLOYMENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_EMPLOYMENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PARTY_IDENTIFICATION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_IDENTIFICATION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PARTY_IDENTITY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_IDENTITY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PARTY_INTERACTION_EVENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_INTERACTION_EVENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PARTY_MARKETING' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_MARKETING where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PARTY_ONBOARDING_JOURNEY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_ONBOARDING_JOURNEY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PARTY_ORGANISATION_PROFILE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_ORGANISATION_PROFILE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PARTY_PREFERENCE_PROFILE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_PREFERENCE_PROFILE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PARTY_VEHICLE_OWNER' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_VEHICLE_OWNER where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_POLICY_BONUS_TRACKING' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_BONUS_TRACKING where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_POLICY_COVERAGE_SCHEDULE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_COVERAGE_SCHEDULE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_POLICY_DELIVERY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_DELIVERY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_POLICY_DISCOUNT_LOADING_APPLIED' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_DISCOUNT_LOADING_APPLIED where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_POLICY_ENDORSEMENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_ENDORSEMENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_POLICY_EXTENDED_WARRANTY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_EXTENDED_WARRANTY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_POLICY_EXTERNAL_TP_LINK' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_EXTERNAL_TP_LINK where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_POLICY_HEADER' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_HEADER where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_POLICY_INTERMEDIARY_SPLIT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_INTERMEDIARY_SPLIT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_POLICY_PORTABILITY_MIGRATION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_PORTABILITY_MIGRATION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_POLICY_PREMIUM_HEAD' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_PREMIUM_HEAD where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_POLICY_PREMIUM_SETTLEMENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_PREMIUM_SETTLEMENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_POLICY_PREMIUM_SUMMARY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_PREMIUM_SUMMARY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_POLICY_RENEWAL' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_RENEWAL where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_POLICY_TAX_BREAKUP' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_TAX_BREAKUP where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_POLICY_TAX_HEAD' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_TAX_HEAD where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_POLICY_TERMS' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_TERMS where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PRODUCT_COMMISSION_GRID' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PRODUCT_COMMISSION_GRID where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PRODUCT_DEFINITION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PRODUCT_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PRODUCT_DISCOUNT_LOADING' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PRODUCT_DISCOUNT_LOADING where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PRODUCT_DISTRIBUTION_RULES' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PRODUCT_DISTRIBUTION_RULES where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PRODUCT_RATING_FACTOR' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PRODUCT_RATING_FACTOR where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PRODUCT_RIDER_CATALOGUE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PRODUCT_RIDER_CATALOGUE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PRODUCT_TAX_APPLICABILITY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PRODUCT_TAX_APPLICABILITY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PRODUCT_TERMS' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PRODUCT_TERMS where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PRODUCT_UW_RULE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PRODUCT_UW_RULE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PROPOSAL_DECLARATIONS' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PROPOSAL_DECLARATIONS where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PROPOSAL_HEADER' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PROPOSAL_HEADER where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_PROPOSAL_UNDERWRITING' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PROPOSAL_UNDERWRITING where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_QUOTE_COVERAGE_LINE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_QUOTE_COVERAGE_LINE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_QUOTE_HEADER' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_QUOTE_HEADER where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_QUOTE_PREMIUM_HEAD' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_QUOTE_PREMIUM_HEAD where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_QUOTE_PRIOR_INSURANCE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_QUOTE_PRIOR_INSURANCE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_QUOTE_RATING' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_QUOTE_RATING where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_QUOTE_VEHICLE_SPEC' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_QUOTE_VEHICLE_SPEC where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_RISK_EXTENDED_WARRANTY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_EXTENDED_WARRANTY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_RISK_MOTOR_ADDON' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_ADDON where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_RISK_MOTOR_CPA' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_CPA where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_RISK_MOTOR_DRIVER' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_DRIVER where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_RISK_MOTOR_FITMENTS' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_FITMENTS where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_RISK_MOTOR_IDV' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_IDV where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_RISK_MOTOR_LIABILITY_ADDON' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_LIABILITY_ADDON where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_RISK_MOTOR_NCB_HISTORY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_NCB_HISTORY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_RISK_MOTOR_TELEMATICS' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_TELEMATICS where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_RISK_MOTOR_USAGE_PLAN' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_USAGE_PLAN where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_RISK_MOTOR_VEHICLE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_VEHICLE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_RISK_MOTOR_VERIFICATION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_VERIFICATION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_RISK_OBJECT_CORE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_OBJECT_CORE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_RISK_OBJECT_INSURABLE_INTEREST' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_OBJECT_INSURABLE_INTEREST where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_RISK_OBJECT_VALUATION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_OBJECT_VALUATION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_MOTOR_AUG_RISK_PERSON_STUDENT_PA' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_PERSON_STUDENT_PA where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_AGREEMENT_DEFINITION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AGREEMENT_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_ASSESSMENT_HEADER' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_ASSESSMENT_HEADER where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_ASSESSMENT_PRE_INSPECTION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_ASSESSMENT_PRE_INSPECTION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CASE_EXTERNAL_REF' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CASE_EXTERNAL_REF where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CASE_HEADER' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CASE_HEADER where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CASE_INVESTIGATION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CASE_INVESTIGATION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CASE_LITIGATION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CASE_LITIGATION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CASE_SERVICE_REQUEST' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CASE_SERVICE_REQUEST where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CASE_WORKFLOW_TASK' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CASE_WORKFLOW_TASK where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CHANNEL_DEFINITION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CHANNEL_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CHANNEL_FIELD_ACTIVITY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CHANNEL_FIELD_ACTIVITY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CHANNEL_SALES_TARGET' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CHANNEL_SALES_TARGET where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CLAIM_ASSESSMENT_SUMMARY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_ASSESSMENT_SUMMARY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CLAIM_EVIDENCE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_EVIDENCE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CLAIM_FNOL' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_FNOL where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CLAIM_FRAUD' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_FRAUD where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CLAIM_HEADER' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_HEADER where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CLAIM_LITIGATION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_LITIGATION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CLAIM_MOTOR_DETAIL' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_MOTOR_DETAIL where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CLAIM_NOTE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_NOTE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CLAIM_QUALITY_AUDIT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_QUALITY_AUDIT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CLAIM_RECOVERY_SALVAGE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_RECOVERY_SALVAGE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CLAIM_RESERVE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_RESERVE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CLAIM_SALVAGE_BIDDER' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_SALVAGE_BIDDER where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CLAIM_SETTLEMENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_SETTLEMENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CLAIM_SLA_TRACKING' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_SLA_TRACKING where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_CLAIM_TP_FORENSIC' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_TP_FORENSIC where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_COMMON_ADDRESS' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_ADDRESS where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_COMMON_ADMIN_GEOGRAPHY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_ADMIN_GEOGRAPHY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_COMMON_BUSINESS_AUDIT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_BUSINESS_AUDIT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_COMMON_COMMUNICATION_PREFERENCE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_COMMUNICATION_PREFERENCE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_COMMON_CONSENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_CONSENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_COMMON_CONTACT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_CONTACT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_COMMON_GEO' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_GEO where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_COMMON_LIFECYCLE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_LIFECYCLE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_COMMON_MONETARY_CONTEXT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_MONETARY_CONTEXT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_COMMON_STATUS' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_STATUS where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_COVERAGE_DEFINITION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COVERAGE_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_COVERAGE_MOTOR_PA_OCCUPANT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COVERAGE_MOTOR_PA_OCCUPANT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_COVERAGE_SUBLIMIT_SCHEDULE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COVERAGE_SUBLIMIT_SCHEDULE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_DOCUMENT_DEFINITION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_DOCUMENT_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_FIN_CHARGE_RATE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FIN_CHARGE_RATE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_FIN_RECEIPT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FIN_RECEIPT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_FINTXN_CLAIM_PAYMENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_CLAIM_PAYMENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_FINTXN_HEADER' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_HEADER where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_FINTXN_PREMIUM' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_PREMIUM where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_FINTXN_RECON_INSTRUMENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_RECON_INSTRUMENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_FINTXN_TAX' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_TAX where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_INSTRUMENT_DEFINITION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_INSTRUMENT_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_LEAD_ATTRIBUTION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LEAD_ATTRIBUTION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_LNK_PARTY_ROLE_CORE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_PARTY_ROLE_CORE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_LNK_ROLE_AGENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_AGENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_LNK_ROLE_CUSTOMER' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_CUSTOMER where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_LNK_ROLE_EMPLOYEE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_EMPLOYEE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_LNK_ROLE_NOMINEE_BENEFICIARY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_NOMINEE_BENEFICIARY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_LNK_ROLE_POSP' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_POSP where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_LOCATION_PROFILE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LOCATION_PROFILE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_LOSS_EVENT_DETAIL' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LOSS_EVENT_DETAIL where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_LOSS_LOCATION_ADDRESS' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LOSS_LOCATION_ADDRESS where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_ORG_UNIT_DEFINITION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_ORG_UNIT_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PARTY_BANKING' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_BANKING where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PARTY_CORRESPONDENCE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_CORRESPONDENCE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PARTY_DIGITAL_IDENTITY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_DIGITAL_IDENTITY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PARTY_EMPLOYMENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_EMPLOYMENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PARTY_FINANCIAL_PROFILE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_FINANCIAL_PROFILE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PARTY_IDENTIFICATION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PARTY_IDENTITY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTITY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PARTY_INTERACTION_EVENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_INTERACTION_EVENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PARTY_KYC_REFERENCE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_KYC_REFERENCE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PARTY_MARKETING' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_MARKETING where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_BONUS_TRACKING' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_BONUS_TRACKING where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_CANCELLATION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_CANCELLATION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_CERTIFICATE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_CERTIFICATE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_CLASSIFICATION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_CLASSIFICATION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_CLAUSE_ATTACHED' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_CLAUSE_ATTACHED where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_COVERAGE_SCHEDULE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_COVERAGE_SCHEDULE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_DELIVERY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_DELIVERY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_DISCOUNT_LOADING_APPLIED' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_DISCOUNT_LOADING_APPLIED where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_DOC_CHECKLIST' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_DOC_CHECKLIST where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_ENDORSEMENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_ENDORSEMENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_EXCESS_STRUCTURE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_EXCESS_STRUCTURE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_EXTERNAL_TP_LINK' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_EXTERNAL_TP_LINK where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_FLEET' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_FLEET where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_HEADER' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_HEADER where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_INTERMEDIARY_SPLIT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_INTERMEDIARY_SPLIT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_LIFECYCLE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_LIFECYCLE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_PORTABILITY_MIGRATION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_PORTABILITY_MIGRATION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_PREMIUM_HEAD' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_PREMIUM_HEAD where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_PREMIUM_SUMMARY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_PREMIUM_SUMMARY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_RENEWAL' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_RENEWAL where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_SUM_INSURED_BREAKUP' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_SUM_INSURED_BREAKUP where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_TAX_BREAKUP' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_TAX_BREAKUP where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_TAX_HEAD' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_TAX_HEAD where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_TERMS' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_TERMS where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_POLICY_TP_PRIOR_PERIOD' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_TP_PRIOR_PERIOD where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PRODUCT_COMMISSION_GRID' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_COMMISSION_GRID where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PRODUCT_DEFINITION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PRODUCT_DISCOUNT_LOADING' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_DISCOUNT_LOADING where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PRODUCT_RATING_FACTOR' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_RATING_FACTOR where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PRODUCT_RIDER_CATALOGUE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_RIDER_CATALOGUE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PRODUCT_UW_RULE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_UW_RULE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PROPOSAL_DECLARATIONS' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PROPOSAL_DECLARATIONS where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PROPOSAL_HEADER' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PROPOSAL_HEADER where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PROPOSAL_PAYMENT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PROPOSAL_PAYMENT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PROPOSAL_QUESTIONNAIRE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PROPOSAL_QUESTIONNAIRE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PROPOSAL_SCRUTINY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PROPOSAL_SCRUTINY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_PROPOSAL_UNDERWRITING' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PROPOSAL_UNDERWRITING where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_QUOTE_COMPARISON' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_QUOTE_COMPARISON where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_QUOTE_HEADER' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_QUOTE_HEADER where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_QUOTE_RATING' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_QUOTE_RATING where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_QUOTE_RATING_INPUT' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_QUOTE_RATING_INPUT where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_RISK_EXTENDED_WARRANTY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_EXTENDED_WARRANTY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_RISK_MOTOR_ADDON' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_ADDON where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_RISK_MOTOR_CPA' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_CPA where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_RISK_MOTOR_DRIVER' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_DRIVER where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_RISK_MOTOR_FITMENTS' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_FITMENTS where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_RISK_MOTOR_IDV' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_IDV where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_RISK_MOTOR_LIABILITY_ADDON' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_LIABILITY_ADDON where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_RISK_MOTOR_NCB_HISTORY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_NCB_HISTORY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_RISK_MOTOR_TELEMATICS' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_TELEMATICS where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_RISK_MOTOR_VEHICLE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_VEHICLE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_RISK_MOTOR_VERIFICATION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_VERIFICATION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_RISK_OBJECT_CORE' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_OBJECT_CORE where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_RISK_OBJECT_INSURABLE_INTEREST' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_OBJECT_INSURABLE_INTEREST where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_RISK_OBJECT_OWNERSHIP_HISTORY' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_OBJECT_OWNERSHIP_HISTORY where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_RISK_OBJECT_VALUATION' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_OBJECT_VALUATION where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_RISK_PERSON_STUDENT_PA' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_PERSON_STUDENT_PA where RECORD_SOURCE like 'stitch_motor__v%'
union all
select 'SAT_RISK_TRAILER' as table_name, count(*) as old_rows from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_TRAILER where RECORD_SOURCE like 'stitch_motor__v%';

-- 2) delete them
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_AGREEMENT_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_ASSESSMENT_HEADER where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CASE_DOCUMENT_CHECKLIST where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CASE_HEADER where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CASE_LITIGATION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CASE_SERVICE_REQUEST where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CASE_WORKFLOW_TASK where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CHANNEL_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CHANNEL_DIGITAL_INTEGRATION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CHANNEL_FIELD_ACTIVITY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CHANNEL_SALES_TARGET where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_ASSESSMENT_SUMMARY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_CO_RI_SHARE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_COMPARABLE_CLAIM where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_DOC_CHECKLIST where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_FNOL where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_FRAUD where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_HEADER where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_LITIGATION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_MOTOR_DETAIL where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_PA_DETAIL where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_RECOVERY_EXPENSE_LINE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_RECOVERY_SALVAGE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_SALVAGE_BIDDER where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_SETTLEMENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_SLA_TRACKING where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_SUB_FILE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_SURVEY_APPOINTMENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_THIRD_PARTY_LINE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_THIRD_PARTY_MACT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_CLAIM_TP_FORENSIC where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_COMMON_ADDRESS where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_COMMON_ADMIN_GEOGRAPHY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_COMMON_BUSINESS_AUDIT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_COMMON_CONTACT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_COMMON_GEO where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_COVERAGE_CONDITIONS where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_COVERAGE_MOTOR_ADDON_PARAMS where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_COVERAGE_MOTOR_LAID_UP where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_COVERAGE_PACKAGE_RATING where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_DOCUMENT_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_FIN_RECEIPT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_FINTXN_CHANNEL_AUTHORISATION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_FINTXN_CLAIM_PAYMENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_FINTXN_HEADER where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_FINTXN_PREMIUM where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_LOCATION_PROFILE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_LOSS_EVENT_DETAIL where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_LOSS_LOCATION_ADDRESS where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_ORG_UNIT_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_CONTACT_ADDRESS_LINK where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_CORRESPONDENCE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_DIGITAL_IDENTITY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_DIGITAL_JOURNEY_STAGE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_EMPLOYMENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_IDENTIFICATION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_IDENTITY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_INTERACTION_EVENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_MARKETING where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_ONBOARDING_JOURNEY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_ORGANISATION_PROFILE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_PREFERENCE_PROFILE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PARTY_VEHICLE_OWNER where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_BONUS_TRACKING where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_COVERAGE_SCHEDULE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_DELIVERY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_DISCOUNT_LOADING_APPLIED where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_ENDORSEMENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_EXTENDED_WARRANTY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_EXTERNAL_TP_LINK where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_HEADER where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_INTERMEDIARY_SPLIT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_PORTABILITY_MIGRATION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_PREMIUM_HEAD where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_PREMIUM_SETTLEMENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_PREMIUM_SUMMARY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_RENEWAL where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_TAX_BREAKUP where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_TAX_HEAD where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_POLICY_TERMS where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PRODUCT_COMMISSION_GRID where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PRODUCT_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PRODUCT_DISCOUNT_LOADING where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PRODUCT_DISTRIBUTION_RULES where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PRODUCT_RATING_FACTOR where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PRODUCT_RIDER_CATALOGUE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PRODUCT_TAX_APPLICABILITY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PRODUCT_TERMS where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PRODUCT_UW_RULE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PROPOSAL_DECLARATIONS where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PROPOSAL_HEADER where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_PROPOSAL_UNDERWRITING where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_QUOTE_COVERAGE_LINE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_QUOTE_HEADER where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_QUOTE_PREMIUM_HEAD where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_QUOTE_PRIOR_INSURANCE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_QUOTE_RATING where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_QUOTE_VEHICLE_SPEC where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_EXTENDED_WARRANTY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_ADDON where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_CPA where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_DRIVER where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_FITMENTS where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_IDV where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_LIABILITY_ADDON where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_NCB_HISTORY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_TELEMATICS where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_USAGE_PLAN where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_VEHICLE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_MOTOR_VERIFICATION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_OBJECT_CORE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_OBJECT_INSURABLE_INTEREST where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_OBJECT_VALUATION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_MOTOR_AUG_RISK_PERSON_STUDENT_PA where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AGREEMENT_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_ASSESSMENT_HEADER where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_ASSESSMENT_PRE_INSPECTION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CASE_EXTERNAL_REF where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CASE_HEADER where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CASE_INVESTIGATION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CASE_LITIGATION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CASE_SERVICE_REQUEST where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CASE_WORKFLOW_TASK where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CHANNEL_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CHANNEL_FIELD_ACTIVITY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CHANNEL_SALES_TARGET where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_ASSESSMENT_SUMMARY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_EVIDENCE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_FNOL where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_FRAUD where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_HEADER where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_LITIGATION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_MOTOR_DETAIL where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_NOTE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_QUALITY_AUDIT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_RECOVERY_SALVAGE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_RESERVE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_SALVAGE_BIDDER where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_SETTLEMENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_SLA_TRACKING where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_TP_FORENSIC where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_ADDRESS where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_ADMIN_GEOGRAPHY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_BUSINESS_AUDIT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_COMMUNICATION_PREFERENCE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_CONSENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_CONTACT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_GEO where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_LIFECYCLE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_MONETARY_CONTEXT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_STATUS where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COVERAGE_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COVERAGE_MOTOR_PA_OCCUPANT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COVERAGE_SUBLIMIT_SCHEDULE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_DOCUMENT_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FIN_CHARGE_RATE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FIN_RECEIPT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_CLAIM_PAYMENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_HEADER where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_PREMIUM where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_RECON_INSTRUMENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_TAX where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_INSTRUMENT_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LEAD_ATTRIBUTION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_PARTY_ROLE_CORE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_AGENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_CUSTOMER where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_EMPLOYEE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_NOMINEE_BENEFICIARY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_POSP where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LOCATION_PROFILE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LOSS_EVENT_DETAIL where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LOSS_LOCATION_ADDRESS where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_ORG_UNIT_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_BANKING where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_CORRESPONDENCE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_DIGITAL_IDENTITY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_EMPLOYMENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_FINANCIAL_PROFILE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTITY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_INTERACTION_EVENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_KYC_REFERENCE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_MARKETING where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_BONUS_TRACKING where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_CANCELLATION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_CERTIFICATE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_CLASSIFICATION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_CLAUSE_ATTACHED where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_COVERAGE_SCHEDULE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_DELIVERY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_DISCOUNT_LOADING_APPLIED where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_DOC_CHECKLIST where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_ENDORSEMENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_EXCESS_STRUCTURE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_EXTERNAL_TP_LINK where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_FLEET where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_HEADER where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_INTERMEDIARY_SPLIT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_LIFECYCLE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_PORTABILITY_MIGRATION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_PREMIUM_HEAD where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_PREMIUM_SUMMARY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_RENEWAL where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_SUM_INSURED_BREAKUP where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_TAX_BREAKUP where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_TAX_HEAD where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_TERMS where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_TP_PRIOR_PERIOD where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_COMMISSION_GRID where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_DEFINITION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_DISCOUNT_LOADING where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_RATING_FACTOR where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_RIDER_CATALOGUE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_UW_RULE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PROPOSAL_DECLARATIONS where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PROPOSAL_HEADER where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PROPOSAL_PAYMENT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PROPOSAL_QUESTIONNAIRE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PROPOSAL_SCRUTINY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PROPOSAL_UNDERWRITING where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_QUOTE_COMPARISON where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_QUOTE_HEADER where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_QUOTE_RATING where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_QUOTE_RATING_INPUT where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_EXTENDED_WARRANTY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_ADDON where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_CPA where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_DRIVER where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_FITMENTS where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_IDV where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_LIABILITY_ADDON where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_NCB_HISTORY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_TELEMATICS where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_VEHICLE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_VERIFICATION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_OBJECT_CORE where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_OBJECT_INSURABLE_INTEREST where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_OBJECT_OWNERSHIP_HISTORY where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_OBJECT_VALUATION where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_PERSON_STUDENT_PA where RECORD_SOURCE like 'stitch_motor__v%';
delete from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_TRAILER where RECORD_SOURCE like 'stitch_motor__v%';
