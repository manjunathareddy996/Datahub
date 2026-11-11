-- Staging for source table BJAZ_ECARD_POL_DTLS_CONFIG (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ADDON_COND")), '') as addon_cond,
        nullif(trim(to_varchar("ALWMRTL_DTLS")), '') as alwmrtl_dtls,
        nullif(trim(to_varchar("ALWNAT_DTLS")), '') as alwnat_dtls,
        nullif(trim(to_varchar("ALWRLTN1_DTLS")), '') as alwrltn1_dtls,
        nullif(trim(to_varchar("ALWRLTN2_DTLS")), '') as alwrltn2_dtls,
        nullif(trim(to_varchar("ALWSIENHS_DTLS")), '') as alwsienhs_dtls,
        nullif(trim(to_varchar("COMP_CNTRPER")), '') as comp_cntrper,
        nullif(trim(to_varchar("COMP_CONTR")), '') as comp_contr,
        nullif(trim(to_varchar("COMP_CONTR_AMT")), '') as comp_contr_amt,
        nullif(trim(to_varchar("CORPORATE_NAME")), '') as corporate_name,
        nullif(trim(to_varchar("DEACTIVE_POL_DATE")), '') as deactive_pol_date,
        nullif(trim(to_varchar("ENDROSEMENT_WINPRD")), '') as endrosement_winprd,
        nullif(trim(to_varchar("FAMILY_SIZE")), '') as family_size,
        nullif(trim(to_varchar("FAMILY_SIZE_YN")), '') as family_size_yn,
        nullif(trim(to_varchar("FMAL_CVRINLW")), '') as fmal_cvrinlw,
        nullif(trim(to_varchar("FMAL_CVRINLW_YN")), '') as fmal_cvrinlw_yn,
        nullif(trim(to_varchar("FMAL_CVRPRNT")), '') as fmal_cvrprnt,
        nullif(trim(to_varchar("FMAL_CVRPRNT_YN")), '') as fmal_cvrprnt_yn,
        nullif(trim(to_varchar("INCEPTION_WINPRD")), '') as inception_winprd,
        nullif(trim(to_varchar("LOCK_IN_PERIOD")), '') as lock_in_period,
        nullif(trim(to_varchar("MAL_CVRINLW")), '') as mal_cvrinlw,
        nullif(trim(to_varchar("MAL_CVRINLW_YN")), '') as mal_cvrinlw_yn,
        nullif(trim(to_varchar("MAL_CVRPRNT")), '') as mal_cvrprnt,
        nullif(trim(to_varchar("MAL_CVRPRNT_YN")), '') as mal_cvrprnt_yn,
        nullif(trim(to_varchar("NATADD_BRNCHLD_DAY")), '') as natadd_brnchld_day,
        nullif(trim(to_varchar("NATADD_BRNCHLD_YN")), '') as natadd_brnchld_yn,
        nullif(trim(to_varchar("NATADD_SPOUSE_DAY")), '') as natadd_spouse_day,
        nullif(trim(to_varchar("NATADD_SPOUSE_YN")), '') as natadd_spouse_yn,
        nullif(trim(to_varchar("NO_DPND_COVR")), '') as no_dpnd_covr,
        nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
        nullif(trim(to_varchar("POLICY_STATUS")), '') as policy_status,
        nullif(trim(to_varchar("POLICY_TYPE")), '') as policy_type,
        nullif(trim(to_varchar("POL_TYPE")), '') as pol_type,
        nullif(trim(to_varchar("PREM_CAL_1")), '') as prem_cal_1,
        nullif(trim(to_varchar("PREM_CAL_2")), '') as prem_cal_2,
        nullif(trim(to_varchar("PREM_CAL_3")), '') as prem_cal_3,
        nullif(trim(to_varchar("PRNT_CRSRLTN")), '') as prnt_crsrltn,
        nullif(trim(to_varchar("PRNT_CRSRLTN_YN")), '') as prnt_crsrltn_yn,
        nullif(trim(to_varchar("QUOTE_REF")), '') as quote_ref,
        nullif(trim(to_varchar("QUOTE_STATUS")), '') as quote_status,
        nullif(trim(to_varchar("RISK_EXPIRY_DATE")), '') as risk_expiry_date,
        nullif(trim(to_varchar("RISK_INCEPTION_DATE")), '') as risk_inception_date,
        nullif(trim(to_varchar("SHORT_PERIOD_DATE")), '') as short_period_date
    from {{ source('health_raw', 'BJAZ_ECARD_POL_DTLS_CONFIG') }}

)

select * from source
