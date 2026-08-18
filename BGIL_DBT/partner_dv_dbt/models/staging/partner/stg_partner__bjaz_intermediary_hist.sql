-- Staging model for source table BJAZ_INTERMEDIARY_HIST (Partner LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health LOB build.

with source as (

    select
    nullif(trim(to_varchar("INTERMEDIARY_ID")), '') as intermediary_id,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim("BUSINESS_CHANNEL"::varchar), '') as business_channel,
    nullif(trim("SPL_INTER_CODE"::varchar), '') as spl_inter_code,
    nullif(trim("PAN_NUMBER"::varchar), '') as pan_number,
    "REGION_CODE"::number as region_code,
    nullif(trim("INTERMEDIARY_TYPE"::varchar), '') as intermediary_type,
    "INTERMEDIARY_GROUP"::number as intermediary_group,
    nullif(trim("LICENSE_NO"::varchar), '') as license_no,
    nullif(trim("IRDA_INTERMEDIARY_CODE"::varchar), '') as irda_intermediary_code,
    nullif(trim("IRDA_LICENSE_NO"::varchar), '') as irda_license_no,
    nullif(trim("TDS_RATE_IND"::varchar), '') as tds_rate_ind,
    "SPL_TDS_RATE"::number as spl_tds_rate,
    nullif(trim("STATUS"::varchar), '') as status,
    nullif(trim("USERNAME"::varchar), '') as username,
    "SYSTEM_DATE"::timestamp_ntz as system_date,
    nullif(trim("SUBIMD_YN"::varchar), '') as subimd_yn,
    nullif(trim("INTERMEDIARY_NAME"::varchar), '') as intermediary_name,
    nullif(trim("NEW_BC"::varchar), '') as new_bc,
    nullif(trim("NEW_IMD_TYPE"::varchar), '') as new_imd_type,
    "SHORT_COL_RATE"::number as short_col_rate,
    "LICENSE_EXPIRY_DATE"::timestamp_ntz as license_expiry_date,
    "LICENSE_ISSUE_DATE"::timestamp_ntz as license_issue_date,
    nullif(trim("LICENSE_TYPE"::varchar), '') as license_type,
    nullif(trim("BLOCK_FOR_RECEIPT"::varchar), '') as block_for_receipt,
    nullif(trim("LOGO_FILENAME"::varchar), '') as logo_filename,
    nullif(trim("ISACTIVE_LOGO"::varchar), '') as isactive_logo,
    "DEL_DATE"::timestamp_ntz as del_date,
    nullif(trim("USER_NAME"::varchar), '') as user_name,
    nullif(trim("MACHINE"::varchar), '') as machine,
    nullif(trim("PROGRAM"::varchar), '') as program,
    nullif(trim("GREEN_CHANNEL_IMD"::varchar), '') as green_channel_imd,
    nullif(trim("IMDFLAG"::varchar), '') as imdflag,
    nullif(trim("SUB_CHANNEL_CODE"::varchar), '') as sub_channel_code,
    "SUB_CHN_EFF_DATE"::timestamp_ntz as sub_chn_eff_date,
    nullif(trim("FIN_SUB_CHANNEL_CODE"::varchar), '') as fin_sub_channel_code,
    nullif(trim("INTERMEDIARY_BAND"::varchar), '') as intermediary_band,
    nullif(trim("TYPE_OF_COMM_ARR"::varchar), '') as type_of_comm_arr,
    "UPDATED_ON"::timestamp_ntz as updated_on,
    nullif(trim("NATURE_OF_AGREEMENT"::varchar), '') as nature_of_agreement,
    nullif(trim("NATURE_OF_AGREEMENT_OTHER"::varchar), '') as nature_of_agreement_other,
    nullif(trim("PAN_AADHAR_LINKED"::varchar), '') as pan_aadhar_linked,
    nullif(trim("IT_RETURN_2YR"::varchar), '') as it_return_2yr,
    nullif(trim("FLAGGING"::varchar), '') as flagging,
    nullif(trim("REMARKS_CODE"::varchar), '') as remarks_code,
    "GG_CHANGE_DATE"::timestamp_ntz as gg_change_date,
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
    null as website_link, -- not found in source table
    null as gst_status, -- not found in source table
    null as gst_no -- not found in source table
    from {{ source('partner_raw', 'BJAZ_INTERMEDIARY_HIST') }}

)

select * from source
