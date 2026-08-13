-- Staging model for source table BJAZ_GPG_POL_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "ADJ_CESS1_AMT"::number as adj_cess1_amt,
    "ADJ_CESS2_AMT"::number as adj_cess2_amt,
    "ADJ_CESS3_AMT"::number as adj_cess3_amt,
    "ADJ_CGST_AMT"::number as adj_cgst_amt,
    "ADJ_IGST_AMT"::number as adj_igst_amt,
    "ADJ_KKC_AMT"::number as adj_kkc_amt,
    "ADJ_NCC_AMT"::number as adj_ncc_amt,
    "ADJ_SGST_AMT"::number as adj_sgst_amt,
    "ADJ_SWB_AMT"::number as adj_swb_amt,
    "ADJ_UTGST_AMT"::number as adj_utgst_amt,
    nullif(trim(to_varchar("BAGIC_E_CODE")), '') as bagic_e_code,
    nullif(trim(to_varchar("BAGIC_RM_E_CODE")), '') as bagic_rm_e_code,
    nullif(trim("BAGIC_RM_NAME"::varchar), '') as bagic_rm_name,
    nullif(trim("BUSINESS_TYPE"::varchar), '') as business_type,
    "CESS1_AMT"::number as cess1_amt,
    "CESS2_AMT"::number as cess2_amt,
    "CESS3_AMT"::number as cess3_amt,
    "CGST_AMT"::number as cgst_amt,
    nullif(trim(to_varchar("COMPANY_ORG_UNIT")), '') as company_org_unit,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    "FINAL_PREMIUM"::number as final_premium,
    "FULL_YR_TERR_PREM"::number as full_yr_terr_prem,
    "IGST_AMT"::number as igst_amt,
    nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
    nullif(trim("IMD_NAME"::varchar), '') as imd_name,
    "KKC"::number as kkc,
    nullif(trim(to_varchar("LMS_NO")), '') as lms_no,
    "LONG_TERM_DISCOUNT"::number as long_term_discount,
    "MAILING_PINCODE"::number as mailing_pincode,
    "NCC_AMT"::number as ncc_amt,
    "NET_PREMIUM"::number as net_premium,
    nullif(trim("PARTNER_GSTN"::varchar), '') as partner_gstn,
    nullif(trim("PAYMENT_MODE"::varchar), '') as payment_mode,
    nullif(trim("POLICY_PERIOD"::varchar), '') as policy_period,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    "POLICY_TYPE"::number as policy_type,
    nullif(trim("PREV_POLICY_COMP_NAME"::varchar), '') as prev_policy_comp_name,
    nullif(trim("PREV_POL_NO"::varchar), '') as prev_pol_no,
    nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
    nullif(trim(to_varchar("REFERENCE_ID")), '') as reference_id,
    nullif(trim(to_varchar("RE_INSU")), '') as re_insu,
    "RISK_EXPIRY_DATE"::timestamp_ntz as risk_expiry_date,
    "RISK_INCEPTION_DATE"::timestamp_ntz as risk_inception_date,
    nullif(trim("RISK_INCEPTION_TIME"::varchar), '') as risk_inception_time,
    "SB_CESS"::number as sb_cess,
    nullif(trim(to_varchar("SCRUTINY_NO")), '') as scrutiny_no,
    "SERVICE_TAX"::number as service_tax,
    "SGST_AMT"::number as sgst_amt,
    nullif(trim("SPCL_TERMS_COND"::varchar), '') as spcl_terms_cond,
    nullif(trim(to_varchar("SUB_IMD_CODE")), '') as sub_imd_code,
    nullif(trim("SUB_IMD_NAME"::varchar), '') as sub_imd_name,
    nullif(trim("TAX_CODE"::varchar), '') as tax_code,
    "TOTAL_ADDON_PREMIUM"::number as total_addon_premium,
    "TOTAL_BASE_PREMIUM"::number as total_base_premium,
    "UTGST_AMT"::number as utgst_amt
    from {{ source('health_raw', 'BJAZ_GPG_POL_DTLS') }}

)

select * from source
