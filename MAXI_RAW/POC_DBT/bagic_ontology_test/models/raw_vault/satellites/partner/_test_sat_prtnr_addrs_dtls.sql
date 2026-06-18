{{
    config(
        materialized='incremental',
        unique_key=['hk_prtnr_mstr_cd', 'ld_dt_tm']
    )
}}

-- Satellite Partner Address Details
-- Hub: hub_prtnr_mstr
-- Sources: MAXIMUS (stg_partner_address) + OPUS (stg_opus_address, stg_opus_address_extn, stg_opus_address_hist)

WITH hub_mstr AS (
    SELECT 
        hk_prtnr_mstr_cd,
        prty_id
    FROM {{ ref('hub_prtnr_mstr') }}
    LIMIT 100
),

maximus_source AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        
        -- MAXIMUS Address fields
        a.ADDRESS1,
        a.ADDRESS2,
        a.ADDRESS3,
        a.ADDRESS_TYPE,
        a.CITY,
        a.COUNTRY,
        a.DISTRICT,
        a.PINCODE,
        a.STATE,
        
        -- MAXIMUS Address property pivot
        a.AREA,
        a.GEO_COORDINATE_ALTITUDE,
        a.GEO_COORDINATE_LATITUDE,
        a.GEO_COORDINATE_LONGITUDE,
        a.LAND_MARK,
        a.LOCATION_TYPE,
        a.POST_OFFICE,
        a.WHATSAPP_NO,
        
        -- MAXIMUS Contact
        a.ALTERNATE_EMAIL_ID,
        a.EMAIL_ID,
        a.FAX,
        a.LANDLINE_NO,
        a.MOBILE_NO,
        a.PHONE_NO,
        a.STD_CODE,
        a.WORK_NO,
        
        -- OPUS columns (NULL for MAXIMUS)
        NULL AS ADDRESS_LINE4,
        NULL AS ADDRESS_LINE5,
        NULL AS ADDRESS_LINE6,
        NULL AS ADDRESS_LINE7,
        NULL AS POSTCODE,
        NULL AS COUNTRY_CODE,
        NULL AS TELEPHONE,
        NULL AS ADD_ID,
        NULL AS ADD_TYPE_OPUS,
        NULL AS VALID_ADD,
        NULL AS RESIDENCE_COUNTRY,
        NULL AS DOOR_NO,
        NULL AS BUILDING_NAME,
        NULL AS PLOT_STREET_NO,
        NULL AS TELEPHONE_NO1,
        NULL AS TELEPHONE_NO2,
        NULL AS CONTACT_DTLS,
        NULL AS PASSPORT_NO,
        NULL AS SPOUSE_NAME,
        NULL AS FAMILY_INCOME,
        NULL AS NO_SON,
        NULL AS NO_DAUGHTER,
        NULL AS P_POLICY_FLAG,
        NULL AS POLICY_REF,
        NULL AS PRPOSER_FLAG,
        NULL AS PRPOSER_DTLS,
        NULL AS UNIQUE_ID,
        NULL AS OTHER_DETAILS,
        NULL AS VERSION,
        NULL AS EVENT_DATE,
        NULL AS FROM_DATE,
        
        -- Metadata
        a.load_dt_tm AS ld_dt_tm,
        a.record_source AS rcrd_src_nm,
        
        -- Hash diff (MAXIMUS columns only)
        {{ hash_diff([
            'a.ADDRESS1', 'a.ADDRESS2', 'a.ADDRESS3', 'a.ADDRESS_TYPE',
            'a.CITY', 'a.COUNTRY', 'a.DISTRICT', 'a.PINCODE', 'a.STATE',
            'a.MOBILE_NO', 'a.EMAIL_ID'
        ]) }} AS rcrd_hsh_id
        
    FROM hub_mstr h
    INNER JOIN {{ ref('stg_partner_address') }} a
        ON h.prty_id = a.PARTY_CODE
),

opus_address AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        
        -- Map OPUS to MAXIMUS columns
        o.ADDRESS_LINE1 AS ADDRESS1,
        o.ADDRESS_LINE2 AS ADDRESS2,
        o.ADDRESS_LINE3 AS ADDRESS3,
        NULL AS ADDRESS_TYPE,
        NULL AS CITY,
        o.COUNTRY_CODE AS COUNTRY,
        NULL AS DISTRICT,
        o.POSTCODE AS PINCODE,
        NULL AS STATE,
        
        -- MAXIMUS-only columns (NULL for OPUS)
        NULL AS AREA,
        NULL AS GEO_COORDINATE_ALTITUDE,
        NULL AS GEO_COORDINATE_LATITUDE,
        NULL AS GEO_COORDINATE_LONGITUDE,
        NULL AS LAND_MARK,
        NULL AS LOCATION_TYPE,
        NULL AS POST_OFFICE,
        NULL AS WHATSAPP_NO,
        NULL AS ALTERNATE_EMAIL_ID,
        NULL AS EMAIL_ID,
        NULL AS FAX,
        NULL AS LANDLINE_NO,
        o.TELEPHONE AS MOBILE_NO,
        NULL AS PHONE_NO,
        NULL AS STD_CODE,
        NULL AS WORK_NO,
        
        -- OPUS-specific columns
        o.ADDRESS_LINE4,
        o.ADDRESS_LINE5,
        NULL AS ADDRESS_LINE6,
        NULL AS ADDRESS_LINE7,
        o.POSTCODE,
        o.COUNTRY_CODE,
        o.TELEPHONE,
        o.ADD_ID,
        NULL AS ADD_TYPE_OPUS,
        NULL AS VALID_ADD,
        NULL AS RESIDENCE_COUNTRY,
        NULL AS DOOR_NO,
        NULL AS BUILDING_NAME,
        NULL AS PLOT_STREET_NO,
        NULL AS TELEPHONE_NO1,
        NULL AS TELEPHONE_NO2,
        NULL AS CONTACT_DTLS,
        NULL AS PASSPORT_NO,
        NULL AS SPOUSE_NAME,
        NULL AS FAMILY_INCOME,
        NULL AS NO_SON,
        NULL AS NO_DAUGHTER,
        NULL AS P_POLICY_FLAG,
        NULL AS POLICY_REF,
        NULL AS PRPOSER_FLAG,
        NULL AS PRPOSER_DTLS,
        NULL AS UNIQUE_ID,
        NULL AS OTHER_DETAILS,
        o.VERSION,
        o.EVENT_DATE,
        o.FROM_DATE,
        
        -- Metadata
        o.load_dt_tm AS ld_dt_tm,
        o.record_source AS rcrd_src_nm,
        
        -- Hash diff (OPUS columns)
        {{ hash_diff([
            'o.ADDRESS_LINE1', 'o.ADDRESS_LINE2', 'o.ADDRESS_LINE3',
            'o.POSTCODE', 'o.COUNTRY_CODE', 'o.TELEPHONE'
        ]) }} AS rcrd_hsh_id
        
    FROM hub_mstr h
    INNER JOIN {{ ref('stg_opus_address') }} o
        ON h.prty_id = o.PART_ID
),

opus_address_extn AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        
        -- MAXIMUS columns (NULL for extension)
        NULL AS ADDRESS1,
        NULL AS ADDRESS2,
        NULL AS ADDRESS3,
        NULL AS ADDRESS_TYPE,
        NULL AS CITY,
        e.COUNTRY AS COUNTRY,
        NULL AS DISTRICT,
        NULL AS PINCODE,
        NULL AS STATE,
        NULL AS AREA,
        NULL AS GEO_COORDINATE_ALTITUDE,
        NULL AS GEO_COORDINATE_LATITUDE,
        NULL AS GEO_COORDINATE_LONGITUDE,
        NULL AS LAND_MARK,
        NULL AS LOCATION_TYPE,
        NULL AS POST_OFFICE,
        NULL AS WHATSAPP_NO,
        NULL AS ALTERNATE_EMAIL_ID,
        NULL AS EMAIL_ID,
        NULL AS FAX,
        NULL AS LANDLINE_NO,
        e.TELEPHONE_NO1 AS MOBILE_NO,
        NULL AS PHONE_NO,
        NULL AS STD_CODE,
        NULL AS WORK_NO,
        
        -- OPUS columns
        NULL AS ADDRESS_LINE4,
        NULL AS ADDRESS_LINE5,
        e.ADDRESS_LINE6,
        e.ADDRESS_LINE7,
        NULL AS POSTCODE,
        NULL AS COUNTRY_CODE,
        NULL AS TELEPHONE,
        e.ADD_ID,
        e.ADD_TYPE AS ADD_TYPE_OPUS,
        e.VALID_ADD,
        e.RESIDENCE_COUNTRY,
        e.DOOR_NO,
        e.BUILDING_NAME,
        e.PLOT_STREET_NO,
        e.TELEPHONE_NO1,
        e.TELEPHONE_NO2,
        e.CONTACT_DTLS,
        e.PASSPORT_NO,
        e.SPOUSE_NAME,
        e.FAMILY_INCOME,
        e.NO_SON,
        e.NO_DAUGHTER,
        e.P_POLICY_FLAG,
        e.POLICY_REF,
        e.PRPOSER_FLAG,
        e.PRPOSER_DTLS,
        e.UNIQUE_ID,
        e.OTHER_DETAILS,
        NULL AS VERSION,
        NULL AS EVENT_DATE,
        NULL AS FROM_DATE,
        
        -- Metadata
        e.load_dt_tm AS ld_dt_tm,
        e.record_source AS rcrd_src_nm,
        
        -- Hash diff
        {{ hash_diff([
            'e.ADD_ID', 'e.ADD_TYPE', 'e.DOOR_NO', 'e.BUILDING_NAME',
            'e.COUNTRY', 'e.RESIDENCE_COUNTRY'
        ]) }} AS rcrd_hsh_id
        
    FROM hub_mstr h
    INNER JOIN {{ ref('stg_opus_address_extn') }} e
        ON h.prty_id = e.PART_ID
),

opus_address_hist AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        
        -- Map OPUS hist to MAXIMUS columns
        oh.ADDRESS_LINE1 AS ADDRESS1,
        oh.ADDRESS_LINE2 AS ADDRESS2,
        oh.ADDRESS_LINE3 AS ADDRESS3,
        NULL AS ADDRESS_TYPE,
        NULL AS CITY,
        oh.COUNTRY_CODE AS COUNTRY,
        NULL AS DISTRICT,
        oh.POSTCODE AS PINCODE,
        NULL AS STATE,
        
        -- MAXIMUS-only columns (NULL)
        NULL AS AREA,
        NULL AS GEO_COORDINATE_ALTITUDE,
        NULL AS GEO_COORDINATE_LATITUDE,
        NULL AS GEO_COORDINATE_LONGITUDE,
        NULL AS LAND_MARK,
        NULL AS LOCATION_TYPE,
        NULL AS POST_OFFICE,
        NULL AS WHATSAPP_NO,
        NULL AS ALTERNATE_EMAIL_ID,
        NULL AS EMAIL_ID,
        NULL AS FAX,
        NULL AS LANDLINE_NO,
        oh.TELEPHONE AS MOBILE_NO,
        NULL AS PHONE_NO,
        NULL AS STD_CODE,
        NULL AS WORK_NO,
        
        -- OPUS columns
        oh.ADDRESS_LINE4,
        oh.ADDRESS_LINE5,
        NULL AS ADDRESS_LINE6,
        NULL AS ADDRESS_LINE7,
        oh.POSTCODE,
        oh.COUNTRY_CODE,
        oh.TELEPHONE,
        oh.ADD_ID,
        NULL AS ADD_TYPE_OPUS,
        NULL AS VALID_ADD,
        NULL AS RESIDENCE_COUNTRY,
        NULL AS DOOR_NO,
        NULL AS BUILDING_NAME,
        NULL AS PLOT_STREET_NO,
        NULL AS TELEPHONE_NO1,
        NULL AS TELEPHONE_NO2,
        NULL AS CONTACT_DTLS,
        NULL AS PASSPORT_NO,
        NULL AS SPOUSE_NAME,
        NULL AS FAMILY_INCOME,
        NULL AS NO_SON,
        NULL AS NO_DAUGHTER,
        NULL AS P_POLICY_FLAG,
        NULL AS POLICY_REF,
        NULL AS PRPOSER_FLAG,
        NULL AS PRPOSER_DTLS,
        NULL AS UNIQUE_ID,
        NULL AS OTHER_DETAILS,
        oh.VERSION,
        oh.EVENT_DATE,
        oh.FROM_DATE,
        
        -- Metadata
        oh.load_dt_tm AS ld_dt_tm,
        oh.record_source AS rcrd_src_nm,
        
        -- Hash diff
        {{ hash_diff([
            'oh.ADDRESS_LINE1', 'oh.ADDRESS_LINE2', 'oh.ADDRESS_LINE3',
            'oh.POSTCODE', 'oh.COUNTRY_CODE', 'oh.VERSION'
        ]) }} AS rcrd_hsh_id
        
    FROM hub_mstr h
    INNER JOIN {{ ref('stg_opus_address_hist') }} oh
        ON h.prty_id = oh.PART_ID
),

combined AS (
    SELECT * FROM maximus_source
    UNION ALL
    SELECT * FROM opus_address
    UNION ALL
    SELECT * FROM opus_address_extn
    UNION ALL
    SELECT * FROM opus_address_hist
)

{% if is_incremental() %}
,
existing AS (
    SELECT hk_prtnr_mstr_cd, rcrd_hsh_id
    FROM {{ this }}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY hk_prtnr_mstr_cd 
        ORDER BY ld_dt_tm DESC
    ) = 1
)

SELECT c.*
FROM combined c
LEFT JOIN existing e 
    ON c.hk_prtnr_mstr_cd = e.hk_prtnr_mstr_cd
WHERE e.hk_prtnr_mstr_cd IS NULL
   OR c.rcrd_hsh_id != e.rcrd_hsh_id

{% else %}

SELECT * FROM combined

{% endif %}
