-- Staging model for source table AZBJ_ADDRESS_EXTN (Partner LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health LOB build.

with source as (

    select
    nullif(trim("VALID_ADD"::varchar), '') as valid_add,
    nullif(trim("RESIDENCE_COUNTRY"::varchar), '') as residence_country,
    nullif(trim("SPOUSE_NAME"::varchar), '') as spouse_name,
    nullif(trim("COUNTRY"::varchar), '') as country,
    nullif(trim("DOOR_NO"::varchar), '') as door_no,
    nullif(trim("FAMILY_INCOME"::varchar), '') as family_income,
    nullif(trim("PRPOSER_DTLS"::varchar), '') as prposer_dtls,
    "NO_DAUGHTER"::number as no_daughter,
    nullif(trim("BUILDING_NAME"::varchar), '') as building_name,
    nullif(trim("PLOT_STREET_NO"::varchar), '') as plot_street_no,
    nullif(trim("TELEPHONE_NO1"::varchar), '') as telephone_no1,
    nullif(trim("TELEPHONE_NO2"::varchar), '') as telephone_no2,
    "GG_CHANGE_DATE"::timestamp_ntz as gg_change_date,
    nullif(trim("P_POLICY_FLAG"::varchar), '') as p_policy_flag,
    nullif(trim("POLICY_REF"::varchar), '') as policy_ref,
    nullif(trim("UNIQUE_ID"::varchar), '') as unique_id,
    nullif(trim("PRPOSER_FLAG"::varchar), '') as prposer_flag,
    nullif(trim("ADD_ID"::varchar), '') as add_id,
    nullif(trim("ADDRESS_LINE7"::varchar), '') as address_line7,
    nullif(trim("ADDRESS_LINE6"::varchar), '') as address_line6,
    nullif(trim("OTHER_DETAILS"::varchar), '') as other_details,
    nullif(trim("ADD_TYPE"::varchar), '') as add_type,
    nullif(trim("CONTACT_DTLS"::varchar), '') as contact_dtls,
    nullif(trim("PASSPORT_NO"::varchar), '') as passport_no,
    "NO_SON"::number as no_son,
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('partner_raw', 'AZBJ_ADDRESS_EXTN') }}

)

select * from source
