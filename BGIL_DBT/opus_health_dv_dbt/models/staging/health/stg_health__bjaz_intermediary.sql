-- Staging for source table BJAZ_INTERMEDIARY (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("BLOCK_FOR_RECEIPT")), '') as block_for_receipt,
        nullif(trim(to_varchar("BUSINESS_CHANNEL")), '') as business_channel,
        nullif(trim(to_varchar("FIN_SUB_CHANNEL_CODE")), '') as fin_sub_channel_code,
        nullif(trim(to_varchar("FLAGGING")), '') as flagging,
        nullif(trim(to_varchar("GREEN_CHANNEL_IMD")), '') as green_channel_imd,
        nullif(trim(to_varchar("GST_NO")), '') as gst_no,
        nullif(trim(to_varchar("GST_STATUS")), '') as gst_status,
        nullif(trim(to_varchar("IMDFLAG")), '') as imdflag,
        nullif(trim(to_varchar("INTERMEDIARY_BAND")), '') as intermediary_band,
        nullif(trim(to_varchar("INTERMEDIARY_GROUP")), '') as intermediary_group,
        nullif(trim(to_varchar("INTERMEDIARY_ID")), '') as intermediary_id,
        nullif(trim(to_varchar("INTERMEDIARY_NAME")), '') as intermediary_name,
        nullif(trim(to_varchar("INTERMEDIARY_TYPE")), '') as intermediary_type,
        nullif(trim(to_varchar("IRDA_INTERMEDIARY_CODE")), '') as irda_intermediary_code,
        nullif(trim(to_varchar("IRDA_LICENSE_NO")), '') as irda_license_no,
        nullif(trim(to_varchar("ISACTIVE_LOGO")), '') as isactive_logo,
        nullif(trim(to_varchar("IT_RETURN_2YR")), '') as it_return_2yr,
        nullif(trim(to_varchar("LICENSE_EXPIRY_DATE")), '') as license_expiry_date,
        nullif(trim(to_varchar("LICENSE_ISSUE_DATE")), '') as license_issue_date,
        nullif(trim(to_varchar("LICENSE_NO")), '') as license_no,
        nullif(trim(to_varchar("LICENSE_TYPE")), '') as license_type,
        nullif(trim(to_varchar("LOGO_FILENAME")), '') as logo_filename,
        nullif(trim(to_varchar("NATURE_OF_AGREEMENT")), '') as nature_of_agreement,
        nullif(trim(to_varchar("NATURE_OF_AGREEMENT_OTHER")), '') as nature_of_agreement_other,
        nullif(trim(to_varchar("NEW_BC")), '') as new_bc,
        nullif(trim(to_varchar("NEW_IMD_TYPE")), '') as new_imd_type,
        nullif(trim(to_varchar("PAN_AADHAR_LINKED")), '') as pan_aadhar_linked,
        nullif(trim(to_varchar("PAN_NUMBER")), '') as pan_number,
        nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
        nullif(trim(to_varchar("REGION_CODE")), '') as region_code,
        nullif(trim(to_varchar("REMARKS_CODE")), '') as remarks_code,
        nullif(trim(to_varchar("SHORT_COL_RATE")), '') as short_col_rate,
        nullif(trim(to_varchar("SPL_INTER_CODE")), '') as spl_inter_code,
        nullif(trim(to_varchar("SPL_TDS_RATE")), '') as spl_tds_rate,
        nullif(trim(to_varchar("STATUS")), '') as status,
        nullif(trim(to_varchar("SUBIMD_YN")), '') as subimd_yn,
        nullif(trim(to_varchar("SUB_CHANNEL_CODE")), '') as sub_channel_code,
        nullif(trim(to_varchar("SUB_CHN_EFF_DATE")), '') as sub_chn_eff_date,
        nullif(trim(to_varchar("SYSTEM_DATE")), '') as system_date,
        nullif(trim(to_varchar("TDS_RATE_IND")), '') as tds_rate_ind,
        nullif(trim(to_varchar("TYPE_OF_CHANGE")), '') as type_of_change,
        nullif(trim(to_varchar("TYPE_OF_COMM_ARR")), '') as type_of_comm_arr,
        nullif(trim(to_varchar("USERNAME")), '') as username,
        nullif(trim(to_varchar("WEBSITE_LINK")), '') as website_link
    from {{ source('health_raw', 'BJAZ_INTERMEDIARY') }}

)

select * from source
