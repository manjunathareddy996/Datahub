{{
    config(
        materialized='view'
    )
}}

-- Staging: Partner address
-- Source: BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS + ADDRESS_PROPERTY_PIVOT

WITH address_base AS (
    SELECT *
    FROM {{ source('raw_maximus', 'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS') }}
),

address_property AS (
    SELECT *
    FROM {{ source('raw_maximus', 'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW_2_1') }}
),

party_detail AS (
    SELECT FOREIGN_KEY, PARTY_CODE
    FROM {{ source('raw_maximus', 'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL') }}
    WHERE PARTY_CODE IS NOT NULL
),

staged AS (
    SELECT
        pd.PARTY_CODE,
        {{ hash('pd.PARTY_CODE') }} AS hk_prtnr_mstr_cd,
        
        -- Base address fields
        ab.ADDRESS1,
        ab.ADDRESS2,
        ab.ADDRESS3,
        ab.ADDRESS_TYPE,
        ab.ALTERNATE_EMAIL_ID,
        ab.CITY,
        ab.COUNTRY,
        ab.DISTRICT,
        ab.EMAIL_ID,
        ab.FAX,
        ab.LANDLINE_NO,
        ab.MOBILE_NO,
        ab.PHONE_NO,
        ab.PINCODE,
        ab.STATE,
        ab.STD_CODE,
        ab.WORK_NO,
        
        -- Address property pivot fields
        ap.ALTERNATE_MOB_NUMBERLANDLINE_NUMBER,
        ap.AREA,
        ap.CITY AS AREA_CITY,
        ap.FACEBOOK_ID,
        ap.GEO_COORDINATE_ALTITUDE,
        ap.GEO_COORDINATE_LATITUDE,
        ap.GEO_COORDINATE_LONGITUDE,
        ap.INSTAGRAM_ID,
        ap.LAND_MARK,
        ap.LINKED_IN_ID,
        ap.LOCATION_TYPE,
        ap.PINCODE AS AREA_PINCODE,
        ap.POST_OFFICE,
        ap.STATE AS AREA_STATE,
        ap.TWITTER_ID,
        ap.WHATSAPP_NO,
        
        -- Metadata
        ab.INC_JOB_CREATED_AT,
        ab.REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source
        
    FROM address_base ab
    INNER JOIN party_detail pd ON ab.FOREIGN_KEY = pd.FOREIGN_KEY
    LEFT JOIN address_property ap ON ab.FOREIGN_KEY = ap.FOREIGN_KEY
)

SELECT * FROM staged
