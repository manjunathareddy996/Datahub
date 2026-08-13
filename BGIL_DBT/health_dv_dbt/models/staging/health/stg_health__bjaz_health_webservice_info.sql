-- Staging model for source table BJAZ_HEALTH_WEBSERVICE_INFO (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "ADD_ON_PREM"::number as add_on_prem,
    nullif(trim("ADVICE_NO"::varchar), '') as advice_no,
    "BANCA_REF_ID"::number as banca_ref_id,
    nullif(trim("BANK_BRANCH_NAME"::varchar), '') as bank_branch_name,
    nullif(trim("BANK_NAME"::varchar), '') as bank_name,
    nullif(trim(to_varchar("BRANCH_CODE")), '') as branch_code,
    nullif(trim("BUSINESS_TYPE"::varchar), '') as business_type,
    nullif(trim("CENTRAL_GST"::varchar), '') as central_gst,
    nullif(trim("CHEQUE_TYPE"::varchar), '') as cheque_type,
    "COMMERCIAL_DISCOUNT"::number as commercial_discount,
    "COMMERCIAL_DISCOUNT_PER"::number as commercial_discount_per,
    "COMM_DISC_RATE"::number as comm_disc_rate,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    nullif(trim(to_varchar("DEAL_ID")), '') as deal_id,
    nullif(trim(to_varchar("DEPT_CODE")), '') as dept_code,
    "FAMILY_DISCOUNT"::number as family_discount,
    "GRID_LOAD"::number as grid_load,
    "GRID_LOAD_RATE"::number as grid_load_rate,
    "GROSS_PREMIUM"::number as gross_premium,
    nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
    nullif(trim("INSTRUMENT_AMT"::varchar), '') as instrument_amt,
    nullif(trim("INSTR_DATE"::varchar), '') as instr_date,
    nullif(trim("INSTR_NUMBER"::varchar), '') as instr_number,
    nullif(trim("INTRUMENT_TYPE"::varchar), '') as intrument_type,
    nullif(trim("I_GST"::varchar), '') as i_gst,
    nullif(trim(to_varchar("LOAN_ACCNO")), '') as loan_accno,
    "MEMBER_LOADING"::number as member_loading,
    "NET_PREMIUM"::number as net_premium,
    nullif(trim("ORDER_NUMBER"::varchar), '') as order_number,
    "OTHER_DISCOUNT"::number as other_discount,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim("PAYMENT_MODE"::varchar), '') as payment_mode,
    "POLICY_PERIOD"::number as policy_period,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
    nullif(trim(to_varchar("PTRANSACTION_ID")), '') as ptransaction_id,
    nullif(trim("RECEIPT_NO"::varchar), '') as receipt_no,
    nullif(trim("REMARKS"::varchar), '') as remarks,
    nullif(trim(to_varchar("SCRUTINY_NO")), '') as scrutiny_no,
    "SERVICE_TAX_AMT"::number as service_tax_amt,
    nullif(trim("SI_FLAG"::varchar), '') as si_flag,
    nullif(trim("STATE_GST"::varchar), '') as state_gst,
    nullif(trim(to_varchar("SUB_IMD_CODE")), '') as sub_imd_code,
    "SURG_COVER_BASE_PREM"::number as surg_cover_base_prem,
    "TERM_END_DATE"::timestamp_ntz as term_end_date,
    "TERM_START_DATE"::timestamp_ntz as term_start_date,
    "TOT_PLAN_SI"::number as tot_plan_si,
    "UW_LOADING_AMT"::number as uw_loading_amt,
    "UW_LOADING_PER"::number as uw_loading_per,
    "UW_LOAD_AMT"::number as uw_load_amt,
    "UW_LOAD_RATE"::number as uw_load_rate
    from {{ source('health_raw', 'BJAZ_HEALTH_WEBSERVICE_INFO') }}

)

select * from source
