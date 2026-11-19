-- Test copies of the 93 OPUS Motor source tables, year-to-date, for source motor_test_raw.
-- Plain SQL: run it in a Snowflake worksheet with a role that can read BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE
-- and create tables in BAGIC_PREPROD_CURATED_DB.UTILS.
--
-- YTD = rows with INC_JOB_UPDATED_AT on or after 1 January of the current year.
-- Transient tables: no Fail-safe storage, which suits throw-away test data.
-- Re-running the script replaces the copies with a fresh YTD extract.

-- 0a) Must return 0 rows: none of the 93 names may already exist in UTILS
--     (create or replace would overwrite it). Partner and travel test tables use other names.
with expected as (
    select column1 as table_name from values
        ('BA_PART_QUOTE_MOT_PREM'),
        ('BA_QUOTE_MOT_COVERS'),
        ('BA_QUOTE_MOT_DTLS'),
        ('BA_QUOTE_MOT_PREM'),
        ('BGIL_MOTOR_WEBSERVICE_INFO_EQM'),
        ('BGIL_MOTOR_WS_DETARIFF_EQM'),
        ('BGIL_MOTOR_WS_PLAN_DETAILS_EQM'),
        ('BGIL_MOTOR_WS_PREMIUM_DTLS_EQM'),
        ('BGIL_MOTOR_WS_PREMIUM_SUMMARY_EQM'),
        ('BGIL_MOTWS_OTHER_DTLS_EQM'),
        ('BJAZ_AGENCY_MOT_WAR_DTLS'),
        ('BJAZ_CLM_BASE_MOT_EXT'),
        ('BJAZ_CLM_MOTOR_INTIM_DETAILS'),
        ('BJAZ_CLM_MOT_TAX_DTLS'),
        ('BJAZ_CLM_SUBFILE_MOT_EXT'),
        ('BJAZ_CVTP_WS_DATA'),
        ('BJAZ_CVTP_WS_DATA_EXTN'),
        ('BJAZ_IIB_INSURER_MASTER'),
        ('BJAZ_IIB_SUDARS_POLICY_DTL_HST_QM'),
        ('BJAZ_MOTORTHEFT_CASE_DTLS'),
        ('BJAZ_MOTOR_INVOICE_OCR_DTLS'),
        ('BJAZ_MOTOR_WEBSERVICE_INFO'),
        ('BJAZ_MOTOR_WS_DETARIFF'),
        ('BJAZ_MOTOR_WS_EXTRA_COVERS'),
        ('BJAZ_MOTOR_WS_PLAN_DETAILS'),
        ('BJAZ_MOTOR_WS_PREMIUM_DTLS'),
        ('BJAZ_MOTOR_WS_PREMIUM_SUMMARY'),
        ('BJAZ_MOT_ADD_QSTN_DTLS'),
        ('BJAZ_MOT_CLM_CDC_DTLS'),
        ('BJAZ_MOT_CLM_CDC_REVIEWER_DTLS'),
        ('BJAZ_MOT_CLM_COMPARABLE_DTLS'),
        ('BJAZ_MOT_CLM_IP_DMG_EXTN'),
        ('BJAZ_MOT_CLM_TRANS_EXTN'),
        ('BJAZ_MOT_COMM_CAPPPING_MASTER'),
        ('BJAZ_MOT_COVER_EXTN'),
        ('BJAZ_MOT_GEN_RATE_MASTER'),
        ('BJAZ_MOT_INS_HST_EXTN'),
        ('BJAZ_MOT_NAMED_DRIVER_EXTN'),
        ('BJAZ_MOT_OD_TP_DTLS'),
        ('BJAZ_MOT_ONLINE_POL_DTLS'),
        ('BJAZ_MOT_ONLINE_POL_DTLS_EXTN'),
        ('BJAZ_MOT_PAYC_DTLS'),
        ('BJAZ_MOT_PKG_COVER_MST'),
        ('BJAZ_MOT_PKG_MAPPED_COVERS'),
        ('BJAZ_MOT_PKG_MST'),
        ('BJAZ_MOT_PREM_SUMM_EXTN'),
        ('BJAZ_MOT_PREM_SUMM_EXTN_ADJ'),
        ('BJAZ_MOT_PROD_UIN_MAPPING'),
        ('BJAZ_MOT_RENEWAL'),
        ('BJAZ_MOT_RENEWAL_EXTN'),
        ('BJAZ_MOT_RENEWAL_HIST'),
        ('BJAZ_MOT_REN_PREM'),
        ('BJAZ_MOT_REN_SUM_DTLS_A'),
        ('BJAZ_MOT_RNW_LOADER_DATA'),
        ('BJAZ_MOT_RNW_VALIDATE_VEH_DTLS'),
        ('BJAZ_MOT_RN_CLS_VEH_DTLS_HIST'),
        ('BJAZ_MOT_SPECIAL_POLICY'),
        ('BJAZ_MOT_STP_PREM_SUMM_EXTN'),
        ('BJAZ_MOT_TAC_DTLS'),
        ('BJAZ_MOT_TP_GST_APPLICABLE_PRD'),
        ('BJAZ_MOT_TRADE_DTLS_EXTN'),
        ('BJAZ_MOT_UW_BRANCH_GROUP_MST'),
        ('BJAZ_MOT_UW_BUDGET_MST'),
        ('BJAZ_MOT_WAR_CHILD_DTLS'),
        ('BJAZ_MOT_WAR_MAST_CHILD'),
        ('BJAZ_MOT_WAR_MAST_DTLS'),
        ('BJAZ_MOT_WAR_PLANS_EXTN'),
        ('BJAZ_MOT_WINBACK_DTLS'),
        ('BJAZ_MOT_WS_POL_DTLS'),
        ('BJAZ_PAYMOTORTHEFT_DTLS'),
        ('BJAZ_RTA_STATE_MASTER'),
        ('BJAZ_RTA_STATUS_MASTER'),
        ('BJAZ_SCR_MOT_VEH_DTLS'),
        ('BJAZ_VAHAN_AUTO_ENDT_LOG'),
        ('BJAZ_VAHAN_MOTOR_DTLS'),
        ('BJAZ_VEHICLE_PRICE_MASTER'),
        ('BJAZ_VEHICLE_TYPE_MASTER_ACT'),
        ('BJAZ_WAP_MOTOR_IW_ASSIST'),
        ('BJAZ_WAP_MOT_ADDONPKG'),
        ('BJAZ_WAP_MOT_ADD_QSTN_DTLS'),
        ('BJAZ_WAP_MOT_GS_ACT_DTLS'),
        ('BJAZ_WAP_MOT_STP_RATE_SUMM'),
        ('BJAZ_WB_CLM_BASE_MOT_EXT'),
        ('BJAZ_WB_CLM_IP_MOT_EXT'),
        ('BJAZ_WS_MOTCLM_DETAILS'),
        ('BJAZ_WS_MOTCLM_SURVEY_DTLS'),
        ('BJAZ_WS_MOT_STP_RATE_SUMM'),
        ('CVTP_GUIDELINES'),
        ('RTA_CLUSTER_PREFERRED_DECLINE'),
        ('RTO_MASTER'),
        ('VEHICLE_BLOCK_MASTER'),
        ('WEO_BJAZ_MOT_DISPATCH_DTLS'),
        ('WRN_BJAZ_MOT_RENEWAL')
)
select t.table_name, t.created, t.row_count
from BAGIC_PREPROD_CURATED_DB.INFORMATION_SCHEMA.TABLES t
join expected e on e.table_name = t.table_name
where t.table_schema = 'UTILS';

-- 0b) Must return 0 rows: every source table must exist and have INC_JOB_UPDATED_AT.
with expected as (
    select column1 as table_name from values
        ('BA_PART_QUOTE_MOT_PREM'),
        ('BA_QUOTE_MOT_COVERS'),
        ('BA_QUOTE_MOT_DTLS'),
        ('BA_QUOTE_MOT_PREM'),
        ('BGIL_MOTOR_WEBSERVICE_INFO_EQM'),
        ('BGIL_MOTOR_WS_DETARIFF_EQM'),
        ('BGIL_MOTOR_WS_PLAN_DETAILS_EQM'),
        ('BGIL_MOTOR_WS_PREMIUM_DTLS_EQM'),
        ('BGIL_MOTOR_WS_PREMIUM_SUMMARY_EQM'),
        ('BGIL_MOTWS_OTHER_DTLS_EQM'),
        ('BJAZ_AGENCY_MOT_WAR_DTLS'),
        ('BJAZ_CLM_BASE_MOT_EXT'),
        ('BJAZ_CLM_MOTOR_INTIM_DETAILS'),
        ('BJAZ_CLM_MOT_TAX_DTLS'),
        ('BJAZ_CLM_SUBFILE_MOT_EXT'),
        ('BJAZ_CVTP_WS_DATA'),
        ('BJAZ_CVTP_WS_DATA_EXTN'),
        ('BJAZ_IIB_INSURER_MASTER'),
        ('BJAZ_IIB_SUDARS_POLICY_DTL_HST_QM'),
        ('BJAZ_MOTORTHEFT_CASE_DTLS'),
        ('BJAZ_MOTOR_INVOICE_OCR_DTLS'),
        ('BJAZ_MOTOR_WEBSERVICE_INFO'),
        ('BJAZ_MOTOR_WS_DETARIFF'),
        ('BJAZ_MOTOR_WS_EXTRA_COVERS'),
        ('BJAZ_MOTOR_WS_PLAN_DETAILS'),
        ('BJAZ_MOTOR_WS_PREMIUM_DTLS'),
        ('BJAZ_MOTOR_WS_PREMIUM_SUMMARY'),
        ('BJAZ_MOT_ADD_QSTN_DTLS'),
        ('BJAZ_MOT_CLM_CDC_DTLS'),
        ('BJAZ_MOT_CLM_CDC_REVIEWER_DTLS'),
        ('BJAZ_MOT_CLM_COMPARABLE_DTLS'),
        ('BJAZ_MOT_CLM_IP_DMG_EXTN'),
        ('BJAZ_MOT_CLM_TRANS_EXTN'),
        ('BJAZ_MOT_COMM_CAPPPING_MASTER'),
        ('BJAZ_MOT_COVER_EXTN'),
        ('BJAZ_MOT_GEN_RATE_MASTER'),
        ('BJAZ_MOT_INS_HST_EXTN'),
        ('BJAZ_MOT_NAMED_DRIVER_EXTN'),
        ('BJAZ_MOT_OD_TP_DTLS'),
        ('BJAZ_MOT_ONLINE_POL_DTLS'),
        ('BJAZ_MOT_ONLINE_POL_DTLS_EXTN'),
        ('BJAZ_MOT_PAYC_DTLS'),
        ('BJAZ_MOT_PKG_COVER_MST'),
        ('BJAZ_MOT_PKG_MAPPED_COVERS'),
        ('BJAZ_MOT_PKG_MST'),
        ('BJAZ_MOT_PREM_SUMM_EXTN'),
        ('BJAZ_MOT_PREM_SUMM_EXTN_ADJ'),
        ('BJAZ_MOT_PROD_UIN_MAPPING'),
        ('BJAZ_MOT_RENEWAL'),
        ('BJAZ_MOT_RENEWAL_EXTN'),
        ('BJAZ_MOT_RENEWAL_HIST'),
        ('BJAZ_MOT_REN_PREM'),
        ('BJAZ_MOT_REN_SUM_DTLS_A'),
        ('BJAZ_MOT_RNW_LOADER_DATA'),
        ('BJAZ_MOT_RNW_VALIDATE_VEH_DTLS'),
        ('BJAZ_MOT_RN_CLS_VEH_DTLS_HIST'),
        ('BJAZ_MOT_SPECIAL_POLICY'),
        ('BJAZ_MOT_STP_PREM_SUMM_EXTN'),
        ('BJAZ_MOT_TAC_DTLS'),
        ('BJAZ_MOT_TP_GST_APPLICABLE_PRD'),
        ('BJAZ_MOT_TRADE_DTLS_EXTN'),
        ('BJAZ_MOT_UW_BRANCH_GROUP_MST'),
        ('BJAZ_MOT_UW_BUDGET_MST'),
        ('BJAZ_MOT_WAR_CHILD_DTLS'),
        ('BJAZ_MOT_WAR_MAST_CHILD'),
        ('BJAZ_MOT_WAR_MAST_DTLS'),
        ('BJAZ_MOT_WAR_PLANS_EXTN'),
        ('BJAZ_MOT_WINBACK_DTLS'),
        ('BJAZ_MOT_WS_POL_DTLS'),
        ('BJAZ_PAYMOTORTHEFT_DTLS'),
        ('BJAZ_RTA_STATE_MASTER'),
        ('BJAZ_RTA_STATUS_MASTER'),
        ('BJAZ_SCR_MOT_VEH_DTLS'),
        ('BJAZ_VAHAN_AUTO_ENDT_LOG'),
        ('BJAZ_VAHAN_MOTOR_DTLS'),
        ('BJAZ_VEHICLE_PRICE_MASTER'),
        ('BJAZ_VEHICLE_TYPE_MASTER_ACT'),
        ('BJAZ_WAP_MOTOR_IW_ASSIST'),
        ('BJAZ_WAP_MOT_ADDONPKG'),
        ('BJAZ_WAP_MOT_ADD_QSTN_DTLS'),
        ('BJAZ_WAP_MOT_GS_ACT_DTLS'),
        ('BJAZ_WAP_MOT_STP_RATE_SUMM'),
        ('BJAZ_WB_CLM_BASE_MOT_EXT'),
        ('BJAZ_WB_CLM_IP_MOT_EXT'),
        ('BJAZ_WS_MOTCLM_DETAILS'),
        ('BJAZ_WS_MOTCLM_SURVEY_DTLS'),
        ('BJAZ_WS_MOT_STP_RATE_SUMM'),
        ('CVTP_GUIDELINES'),
        ('RTA_CLUSTER_PREFERRED_DECLINE'),
        ('RTO_MASTER'),
        ('VEHICLE_BLOCK_MASTER'),
        ('WEO_BJAZ_MOT_DISPATCH_DTLS'),
        ('WRN_BJAZ_MOT_RENEWAL')
)
select e.table_name,
       count(c.column_name) > 0                                              as table_found,
       max(iff(c.column_name = 'INC_JOB_UPDATED_AT', c.data_type, null))     as inc_job_updated_at_type
from expected e
left join BAGIC_PROD_MIRROR_DB.INFORMATION_SCHEMA.COLUMNS c
    on c.table_schema = 'OPUS_GG_DWHSTAGE' and c.table_name = e.table_name
group by e.table_name
having not (table_found and inc_job_updated_at_type is not null);

-- 1) Copy the year-to-date rows.
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BA_PART_QUOTE_MOT_PREM as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BA_PART_QUOTE_MOT_PREM
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BA_QUOTE_MOT_COVERS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BA_QUOTE_MOT_COVERS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BA_QUOTE_MOT_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BA_QUOTE_MOT_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BA_QUOTE_MOT_PREM as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BA_QUOTE_MOT_PREM
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BGIL_MOTOR_WEBSERVICE_INFO_EQM as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BGIL_MOTOR_WEBSERVICE_INFO_EQM
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BGIL_MOTOR_WS_DETARIFF_EQM as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BGIL_MOTOR_WS_DETARIFF_EQM
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BGIL_MOTOR_WS_PLAN_DETAILS_EQM as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BGIL_MOTOR_WS_PLAN_DETAILS_EQM
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BGIL_MOTOR_WS_PREMIUM_DTLS_EQM as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BGIL_MOTOR_WS_PREMIUM_DTLS_EQM
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BGIL_MOTOR_WS_PREMIUM_SUMMARY_EQM as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BGIL_MOTOR_WS_PREMIUM_SUMMARY_EQM
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BGIL_MOTWS_OTHER_DTLS_EQM as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BGIL_MOTWS_OTHER_DTLS_EQM
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_AGENCY_MOT_WAR_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_AGENCY_MOT_WAR_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CLM_BASE_MOT_EXT as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_CLM_BASE_MOT_EXT
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CLM_MOTOR_INTIM_DETAILS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_CLM_MOTOR_INTIM_DETAILS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CLM_MOT_TAX_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_CLM_MOT_TAX_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CLM_SUBFILE_MOT_EXT as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_CLM_SUBFILE_MOT_EXT
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CVTP_WS_DATA as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_CVTP_WS_DATA
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CVTP_WS_DATA_EXTN as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_CVTP_WS_DATA_EXTN
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_IIB_INSURER_MASTER as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_IIB_INSURER_MASTER
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_IIB_SUDARS_POLICY_DTL_HST_QM as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_IIB_SUDARS_POLICY_DTL_HST_QM
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOTORTHEFT_CASE_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOTORTHEFT_CASE_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOTOR_INVOICE_OCR_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOTOR_INVOICE_OCR_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOTOR_WEBSERVICE_INFO as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOTOR_WEBSERVICE_INFO
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOTOR_WS_DETARIFF as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOTOR_WS_DETARIFF
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOTOR_WS_EXTRA_COVERS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOTOR_WS_EXTRA_COVERS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOTOR_WS_PLAN_DETAILS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOTOR_WS_PLAN_DETAILS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOTOR_WS_PREMIUM_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOTOR_WS_PREMIUM_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOTOR_WS_PREMIUM_SUMMARY as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOTOR_WS_PREMIUM_SUMMARY
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_ADD_QSTN_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_ADD_QSTN_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_CLM_CDC_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_CLM_CDC_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_CLM_CDC_REVIEWER_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_CLM_CDC_REVIEWER_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_CLM_COMPARABLE_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_CLM_COMPARABLE_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_CLM_IP_DMG_EXTN as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_CLM_IP_DMG_EXTN
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_CLM_TRANS_EXTN as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_CLM_TRANS_EXTN
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_COMM_CAPPPING_MASTER as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_COMM_CAPPPING_MASTER
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_COVER_EXTN as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_COVER_EXTN
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_GEN_RATE_MASTER as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_GEN_RATE_MASTER
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_INS_HST_EXTN as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_INS_HST_EXTN
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_NAMED_DRIVER_EXTN as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_NAMED_DRIVER_EXTN
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_OD_TP_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_OD_TP_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_ONLINE_POL_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_ONLINE_POL_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_ONLINE_POL_DTLS_EXTN as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_ONLINE_POL_DTLS_EXTN
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_PAYC_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_PAYC_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_PKG_COVER_MST as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_PKG_COVER_MST
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_PKG_MAPPED_COVERS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_PKG_MAPPED_COVERS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_PKG_MST as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_PKG_MST
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_PREM_SUMM_EXTN as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_PREM_SUMM_EXTN
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_PREM_SUMM_EXTN_ADJ as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_PREM_SUMM_EXTN_ADJ
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_PROD_UIN_MAPPING as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_PROD_UIN_MAPPING
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_RENEWAL as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_RENEWAL
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_RENEWAL_EXTN as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_RENEWAL_EXTN
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_RENEWAL_HIST as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_RENEWAL_HIST
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_REN_PREM as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_REN_PREM
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_REN_SUM_DTLS_A as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_REN_SUM_DTLS_A
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_RNW_LOADER_DATA as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_RNW_LOADER_DATA
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_RNW_VALIDATE_VEH_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_RNW_VALIDATE_VEH_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_RN_CLS_VEH_DTLS_HIST as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_RN_CLS_VEH_DTLS_HIST
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_SPECIAL_POLICY as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_SPECIAL_POLICY
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_STP_PREM_SUMM_EXTN as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_STP_PREM_SUMM_EXTN
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_TAC_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_TAC_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_TP_GST_APPLICABLE_PRD as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_TP_GST_APPLICABLE_PRD
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_TRADE_DTLS_EXTN as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_TRADE_DTLS_EXTN
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_UW_BRANCH_GROUP_MST as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_UW_BRANCH_GROUP_MST
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_UW_BUDGET_MST as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_UW_BUDGET_MST
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_WAR_CHILD_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_WAR_CHILD_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_WAR_MAST_CHILD as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_WAR_MAST_CHILD
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_WAR_MAST_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_WAR_MAST_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_WAR_PLANS_EXTN as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_WAR_PLANS_EXTN
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_WINBACK_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_WINBACK_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_WS_POL_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_WS_POL_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_PAYMOTORTHEFT_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_PAYMOTORTHEFT_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_RTA_STATE_MASTER as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_RTA_STATE_MASTER
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_RTA_STATUS_MASTER as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_RTA_STATUS_MASTER
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_SCR_MOT_VEH_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_SCR_MOT_VEH_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_VAHAN_AUTO_ENDT_LOG as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_VAHAN_AUTO_ENDT_LOG
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_VAHAN_MOTOR_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_VAHAN_MOTOR_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_VEHICLE_PRICE_MASTER as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_VEHICLE_PRICE_MASTER
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_VEHICLE_TYPE_MASTER_ACT as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_VEHICLE_TYPE_MASTER_ACT
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_WAP_MOTOR_IW_ASSIST as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_WAP_MOTOR_IW_ASSIST
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_WAP_MOT_ADDONPKG as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_WAP_MOT_ADDONPKG
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_WAP_MOT_ADD_QSTN_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_WAP_MOT_ADD_QSTN_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_WAP_MOT_GS_ACT_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_WAP_MOT_GS_ACT_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_WAP_MOT_STP_RATE_SUMM as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_WAP_MOT_STP_RATE_SUMM
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_WB_CLM_BASE_MOT_EXT as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_BASE_MOT_EXT
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_WB_CLM_IP_MOT_EXT as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_IP_MOT_EXT
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_WS_MOTCLM_DETAILS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_WS_MOTCLM_DETAILS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_WS_MOTCLM_SURVEY_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_WS_MOTCLM_SURVEY_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_WS_MOT_STP_RATE_SUMM as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_WS_MOT_STP_RATE_SUMM
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.CVTP_GUIDELINES as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.CVTP_GUIDELINES
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.RTA_CLUSTER_PREFERRED_DECLINE as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.RTA_CLUSTER_PREFERRED_DECLINE
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.RTO_MASTER as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.RTO_MASTER
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.VEHICLE_BLOCK_MASTER as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.VEHICLE_BLOCK_MASTER
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.WEO_BJAZ_MOT_DISPATCH_DTLS as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.WEO_BJAZ_MOT_DISPATCH_DTLS
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());
create or replace transient table BAGIC_PREPROD_CURATED_DB.UTILS.WRN_BJAZ_MOT_RENEWAL as
    select * from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.WRN_BJAZ_MOT_RENEWAL
    where INC_JOB_UPDATED_AT >= date_trunc('year', current_date());

-- 2) Check: source_ytd_rows = copied_rows on every row. Run straight after step 1
--    (new source rows arriving in between would make the source count higher).
select 'BA_PART_QUOTE_MOT_PREM' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BA_PART_QUOTE_MOT_PREM where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BA_PART_QUOTE_MOT_PREM) as copied_rows
union all
select 'BA_QUOTE_MOT_COVERS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BA_QUOTE_MOT_COVERS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BA_QUOTE_MOT_COVERS) as copied_rows
union all
select 'BA_QUOTE_MOT_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BA_QUOTE_MOT_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BA_QUOTE_MOT_DTLS) as copied_rows
union all
select 'BA_QUOTE_MOT_PREM' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BA_QUOTE_MOT_PREM where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BA_QUOTE_MOT_PREM) as copied_rows
union all
select 'BGIL_MOTOR_WEBSERVICE_INFO_EQM' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BGIL_MOTOR_WEBSERVICE_INFO_EQM where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BGIL_MOTOR_WEBSERVICE_INFO_EQM) as copied_rows
union all
select 'BGIL_MOTOR_WS_DETARIFF_EQM' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BGIL_MOTOR_WS_DETARIFF_EQM where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BGIL_MOTOR_WS_DETARIFF_EQM) as copied_rows
union all
select 'BGIL_MOTOR_WS_PLAN_DETAILS_EQM' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BGIL_MOTOR_WS_PLAN_DETAILS_EQM where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BGIL_MOTOR_WS_PLAN_DETAILS_EQM) as copied_rows
union all
select 'BGIL_MOTOR_WS_PREMIUM_DTLS_EQM' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BGIL_MOTOR_WS_PREMIUM_DTLS_EQM where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BGIL_MOTOR_WS_PREMIUM_DTLS_EQM) as copied_rows
union all
select 'BGIL_MOTOR_WS_PREMIUM_SUMMARY_EQM' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BGIL_MOTOR_WS_PREMIUM_SUMMARY_EQM where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BGIL_MOTOR_WS_PREMIUM_SUMMARY_EQM) as copied_rows
union all
select 'BGIL_MOTWS_OTHER_DTLS_EQM' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BGIL_MOTWS_OTHER_DTLS_EQM where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BGIL_MOTWS_OTHER_DTLS_EQM) as copied_rows
union all
select 'BJAZ_AGENCY_MOT_WAR_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_AGENCY_MOT_WAR_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_AGENCY_MOT_WAR_DTLS) as copied_rows
union all
select 'BJAZ_CLM_BASE_MOT_EXT' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_CLM_BASE_MOT_EXT where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CLM_BASE_MOT_EXT) as copied_rows
union all
select 'BJAZ_CLM_MOTOR_INTIM_DETAILS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_CLM_MOTOR_INTIM_DETAILS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CLM_MOTOR_INTIM_DETAILS) as copied_rows
union all
select 'BJAZ_CLM_MOT_TAX_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_CLM_MOT_TAX_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CLM_MOT_TAX_DTLS) as copied_rows
union all
select 'BJAZ_CLM_SUBFILE_MOT_EXT' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_CLM_SUBFILE_MOT_EXT where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CLM_SUBFILE_MOT_EXT) as copied_rows
union all
select 'BJAZ_CVTP_WS_DATA' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_CVTP_WS_DATA where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CVTP_WS_DATA) as copied_rows
union all
select 'BJAZ_CVTP_WS_DATA_EXTN' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_CVTP_WS_DATA_EXTN where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CVTP_WS_DATA_EXTN) as copied_rows
union all
select 'BJAZ_IIB_INSURER_MASTER' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_IIB_INSURER_MASTER where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_IIB_INSURER_MASTER) as copied_rows
union all
select 'BJAZ_IIB_SUDARS_POLICY_DTL_HST_QM' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_IIB_SUDARS_POLICY_DTL_HST_QM where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_IIB_SUDARS_POLICY_DTL_HST_QM) as copied_rows
union all
select 'BJAZ_MOTORTHEFT_CASE_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOTORTHEFT_CASE_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOTORTHEFT_CASE_DTLS) as copied_rows
union all
select 'BJAZ_MOTOR_INVOICE_OCR_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOTOR_INVOICE_OCR_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOTOR_INVOICE_OCR_DTLS) as copied_rows
union all
select 'BJAZ_MOTOR_WEBSERVICE_INFO' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOTOR_WEBSERVICE_INFO where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOTOR_WEBSERVICE_INFO) as copied_rows
union all
select 'BJAZ_MOTOR_WS_DETARIFF' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOTOR_WS_DETARIFF where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOTOR_WS_DETARIFF) as copied_rows
union all
select 'BJAZ_MOTOR_WS_EXTRA_COVERS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOTOR_WS_EXTRA_COVERS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOTOR_WS_EXTRA_COVERS) as copied_rows
union all
select 'BJAZ_MOTOR_WS_PLAN_DETAILS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOTOR_WS_PLAN_DETAILS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOTOR_WS_PLAN_DETAILS) as copied_rows
union all
select 'BJAZ_MOTOR_WS_PREMIUM_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOTOR_WS_PREMIUM_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOTOR_WS_PREMIUM_DTLS) as copied_rows
union all
select 'BJAZ_MOTOR_WS_PREMIUM_SUMMARY' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOTOR_WS_PREMIUM_SUMMARY where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOTOR_WS_PREMIUM_SUMMARY) as copied_rows
union all
select 'BJAZ_MOT_ADD_QSTN_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_ADD_QSTN_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_ADD_QSTN_DTLS) as copied_rows
union all
select 'BJAZ_MOT_CLM_CDC_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_CLM_CDC_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_CLM_CDC_DTLS) as copied_rows
union all
select 'BJAZ_MOT_CLM_CDC_REVIEWER_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_CLM_CDC_REVIEWER_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_CLM_CDC_REVIEWER_DTLS) as copied_rows
union all
select 'BJAZ_MOT_CLM_COMPARABLE_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_CLM_COMPARABLE_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_CLM_COMPARABLE_DTLS) as copied_rows
union all
select 'BJAZ_MOT_CLM_IP_DMG_EXTN' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_CLM_IP_DMG_EXTN where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_CLM_IP_DMG_EXTN) as copied_rows
union all
select 'BJAZ_MOT_CLM_TRANS_EXTN' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_CLM_TRANS_EXTN where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_CLM_TRANS_EXTN) as copied_rows
union all
select 'BJAZ_MOT_COMM_CAPPPING_MASTER' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_COMM_CAPPPING_MASTER where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_COMM_CAPPPING_MASTER) as copied_rows
union all
select 'BJAZ_MOT_COVER_EXTN' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_COVER_EXTN where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_COVER_EXTN) as copied_rows
union all
select 'BJAZ_MOT_GEN_RATE_MASTER' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_GEN_RATE_MASTER where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_GEN_RATE_MASTER) as copied_rows
union all
select 'BJAZ_MOT_INS_HST_EXTN' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_INS_HST_EXTN where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_INS_HST_EXTN) as copied_rows
union all
select 'BJAZ_MOT_NAMED_DRIVER_EXTN' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_NAMED_DRIVER_EXTN where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_NAMED_DRIVER_EXTN) as copied_rows
union all
select 'BJAZ_MOT_OD_TP_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_OD_TP_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_OD_TP_DTLS) as copied_rows
union all
select 'BJAZ_MOT_ONLINE_POL_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_ONLINE_POL_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_ONLINE_POL_DTLS) as copied_rows
union all
select 'BJAZ_MOT_ONLINE_POL_DTLS_EXTN' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_ONLINE_POL_DTLS_EXTN where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_ONLINE_POL_DTLS_EXTN) as copied_rows
union all
select 'BJAZ_MOT_PAYC_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_PAYC_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_PAYC_DTLS) as copied_rows
union all
select 'BJAZ_MOT_PKG_COVER_MST' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_PKG_COVER_MST where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_PKG_COVER_MST) as copied_rows
union all
select 'BJAZ_MOT_PKG_MAPPED_COVERS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_PKG_MAPPED_COVERS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_PKG_MAPPED_COVERS) as copied_rows
union all
select 'BJAZ_MOT_PKG_MST' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_PKG_MST where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_PKG_MST) as copied_rows
union all
select 'BJAZ_MOT_PREM_SUMM_EXTN' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_PREM_SUMM_EXTN where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_PREM_SUMM_EXTN) as copied_rows
union all
select 'BJAZ_MOT_PREM_SUMM_EXTN_ADJ' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_PREM_SUMM_EXTN_ADJ where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_PREM_SUMM_EXTN_ADJ) as copied_rows
union all
select 'BJAZ_MOT_PROD_UIN_MAPPING' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_PROD_UIN_MAPPING where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_PROD_UIN_MAPPING) as copied_rows
union all
select 'BJAZ_MOT_RENEWAL' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_RENEWAL where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_RENEWAL) as copied_rows
union all
select 'BJAZ_MOT_RENEWAL_EXTN' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_RENEWAL_EXTN where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_RENEWAL_EXTN) as copied_rows
union all
select 'BJAZ_MOT_RENEWAL_HIST' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_RENEWAL_HIST where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_RENEWAL_HIST) as copied_rows
union all
select 'BJAZ_MOT_REN_PREM' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_REN_PREM where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_REN_PREM) as copied_rows
union all
select 'BJAZ_MOT_REN_SUM_DTLS_A' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_REN_SUM_DTLS_A where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_REN_SUM_DTLS_A) as copied_rows
union all
select 'BJAZ_MOT_RNW_LOADER_DATA' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_RNW_LOADER_DATA where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_RNW_LOADER_DATA) as copied_rows
union all
select 'BJAZ_MOT_RNW_VALIDATE_VEH_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_RNW_VALIDATE_VEH_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_RNW_VALIDATE_VEH_DTLS) as copied_rows
union all
select 'BJAZ_MOT_RN_CLS_VEH_DTLS_HIST' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_RN_CLS_VEH_DTLS_HIST where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_RN_CLS_VEH_DTLS_HIST) as copied_rows
union all
select 'BJAZ_MOT_SPECIAL_POLICY' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_SPECIAL_POLICY where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_SPECIAL_POLICY) as copied_rows
union all
select 'BJAZ_MOT_STP_PREM_SUMM_EXTN' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_STP_PREM_SUMM_EXTN where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_STP_PREM_SUMM_EXTN) as copied_rows
union all
select 'BJAZ_MOT_TAC_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_TAC_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_TAC_DTLS) as copied_rows
union all
select 'BJAZ_MOT_TP_GST_APPLICABLE_PRD' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_TP_GST_APPLICABLE_PRD where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_TP_GST_APPLICABLE_PRD) as copied_rows
union all
select 'BJAZ_MOT_TRADE_DTLS_EXTN' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_TRADE_DTLS_EXTN where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_TRADE_DTLS_EXTN) as copied_rows
union all
select 'BJAZ_MOT_UW_BRANCH_GROUP_MST' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_UW_BRANCH_GROUP_MST where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_UW_BRANCH_GROUP_MST) as copied_rows
union all
select 'BJAZ_MOT_UW_BUDGET_MST' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_UW_BUDGET_MST where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_UW_BUDGET_MST) as copied_rows
union all
select 'BJAZ_MOT_WAR_CHILD_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_WAR_CHILD_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_WAR_CHILD_DTLS) as copied_rows
union all
select 'BJAZ_MOT_WAR_MAST_CHILD' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_WAR_MAST_CHILD where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_WAR_MAST_CHILD) as copied_rows
union all
select 'BJAZ_MOT_WAR_MAST_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_WAR_MAST_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_WAR_MAST_DTLS) as copied_rows
union all
select 'BJAZ_MOT_WAR_PLANS_EXTN' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_WAR_PLANS_EXTN where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_WAR_PLANS_EXTN) as copied_rows
union all
select 'BJAZ_MOT_WINBACK_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_WINBACK_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_WINBACK_DTLS) as copied_rows
union all
select 'BJAZ_MOT_WS_POL_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_MOT_WS_POL_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_MOT_WS_POL_DTLS) as copied_rows
union all
select 'BJAZ_PAYMOTORTHEFT_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_PAYMOTORTHEFT_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_PAYMOTORTHEFT_DTLS) as copied_rows
union all
select 'BJAZ_RTA_STATE_MASTER' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_RTA_STATE_MASTER where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_RTA_STATE_MASTER) as copied_rows
union all
select 'BJAZ_RTA_STATUS_MASTER' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_RTA_STATUS_MASTER where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_RTA_STATUS_MASTER) as copied_rows
union all
select 'BJAZ_SCR_MOT_VEH_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_SCR_MOT_VEH_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_SCR_MOT_VEH_DTLS) as copied_rows
union all
select 'BJAZ_VAHAN_AUTO_ENDT_LOG' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_VAHAN_AUTO_ENDT_LOG where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_VAHAN_AUTO_ENDT_LOG) as copied_rows
union all
select 'BJAZ_VAHAN_MOTOR_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_VAHAN_MOTOR_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_VAHAN_MOTOR_DTLS) as copied_rows
union all
select 'BJAZ_VEHICLE_PRICE_MASTER' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_VEHICLE_PRICE_MASTER where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_VEHICLE_PRICE_MASTER) as copied_rows
union all
select 'BJAZ_VEHICLE_TYPE_MASTER_ACT' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_VEHICLE_TYPE_MASTER_ACT where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_VEHICLE_TYPE_MASTER_ACT) as copied_rows
union all
select 'BJAZ_WAP_MOTOR_IW_ASSIST' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_WAP_MOTOR_IW_ASSIST where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_WAP_MOTOR_IW_ASSIST) as copied_rows
union all
select 'BJAZ_WAP_MOT_ADDONPKG' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_WAP_MOT_ADDONPKG where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_WAP_MOT_ADDONPKG) as copied_rows
union all
select 'BJAZ_WAP_MOT_ADD_QSTN_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_WAP_MOT_ADD_QSTN_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_WAP_MOT_ADD_QSTN_DTLS) as copied_rows
union all
select 'BJAZ_WAP_MOT_GS_ACT_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_WAP_MOT_GS_ACT_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_WAP_MOT_GS_ACT_DTLS) as copied_rows
union all
select 'BJAZ_WAP_MOT_STP_RATE_SUMM' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_WAP_MOT_STP_RATE_SUMM where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_WAP_MOT_STP_RATE_SUMM) as copied_rows
union all
select 'BJAZ_WB_CLM_BASE_MOT_EXT' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_BASE_MOT_EXT where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_WB_CLM_BASE_MOT_EXT) as copied_rows
union all
select 'BJAZ_WB_CLM_IP_MOT_EXT' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_IP_MOT_EXT where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_WB_CLM_IP_MOT_EXT) as copied_rows
union all
select 'BJAZ_WS_MOTCLM_DETAILS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_WS_MOTCLM_DETAILS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_WS_MOTCLM_DETAILS) as copied_rows
union all
select 'BJAZ_WS_MOTCLM_SURVEY_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_WS_MOTCLM_SURVEY_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_WS_MOTCLM_SURVEY_DTLS) as copied_rows
union all
select 'BJAZ_WS_MOT_STP_RATE_SUMM' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_WS_MOT_STP_RATE_SUMM where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_WS_MOT_STP_RATE_SUMM) as copied_rows
union all
select 'CVTP_GUIDELINES' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.CVTP_GUIDELINES where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.CVTP_GUIDELINES) as copied_rows
union all
select 'RTA_CLUSTER_PREFERRED_DECLINE' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.RTA_CLUSTER_PREFERRED_DECLINE where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.RTA_CLUSTER_PREFERRED_DECLINE) as copied_rows
union all
select 'RTO_MASTER' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.RTO_MASTER where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.RTO_MASTER) as copied_rows
union all
select 'VEHICLE_BLOCK_MASTER' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.VEHICLE_BLOCK_MASTER where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.VEHICLE_BLOCK_MASTER) as copied_rows
union all
select 'WEO_BJAZ_MOT_DISPATCH_DTLS' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.WEO_BJAZ_MOT_DISPATCH_DTLS where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.WEO_BJAZ_MOT_DISPATCH_DTLS) as copied_rows
union all
select 'WRN_BJAZ_MOT_RENEWAL' as table_name,
       (select count(*) from BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.WRN_BJAZ_MOT_RENEWAL where INC_JOB_UPDATED_AT >= date_trunc('year', current_date())) as source_ytd_rows,
       (select count(*) from BAGIC_PREPROD_CURATED_DB.UTILS.WRN_BJAZ_MOT_RENEWAL) as copied_rows
order by table_name;
