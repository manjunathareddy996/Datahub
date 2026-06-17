{{
    config(
        materialized='incremental',
        unique_key=['hk_prtnr_role_cd', 'ld_dt_tm']
    )
}}

-- Satellite Partner Legal Advocate Details
-- Hub: hub_prtnr_role (legal/advocate attributes per role)
-- Sources: MAXIMUS (simple property) + OPUS (clm_supplier_extn - LAWYER_TYPE discriminator)

WITH hub_role AS (
    SELECT 
        hk_prtnr_role_cd,
        prty_id,
        stake_cd
    FROM {{ ref('hub_prtnr_role') }}
),

maximus_source AS (
    SELECT
        h.hk_prtnr_role_cd,
        sp.load_dt_tm AS ld_dt_tm,
        sp.record_source AS rcrd_src_nm,
        
        -- Lawyer classification
        CAST(sp.TYPE_OF_LAWYER AS VARCHAR) AS lawyer_type,
        NULL AS lawyer_category,
        NULL AS lawyer_specialization,
        
        -- Bar association
        CAST(sp.BAR_ASSOCIATION_NAMELAWYER AS VARCHAR) AS bar_association_name,
        NULL AS bar_association_number,
        NULL AS bar_association_state,
        NULL AS bar_council_registration,
        
        -- Court details
        CAST(sp.COURT_NAME AS VARCHAR) AS court_name,
        NULL AS court_type,
        NULL AS court_jurisdiction,
        
        -- Enrolment
        CAST(sp.ENROLMENT_NOLAWYER AS VARCHAR) AS enrolment_no,
        CAST(sp.DATE_OF_JOININGLAWYER AS VARCHAR) AS enrolment_date,
        NULL AS enrolment_state,
        
        -- Case volume metrics
        CAST(sp.NO_OF_BRIEFS AS VARCHAR) AS no_of_briefs,
        NULL AS no_of_companies,
        NULL AS no_of_mact,
        NULL AS no_of_wc,
        
        -- OPUS-only
        NULL AS covered_court_loc,
        NULL AS yr_experience,
        NULL AS date_of_joining,
        NULL AS no_of_consumer,
        NULL AS no_of_junior,
        NULL AS acd_qualification,
        NULL AS internet_access,
        NULL AS access_online_journal,
        NULL AS availability_library
    FROM {{ ref('stg_partner_simple_property') }} sp
    INNER JOIN hub_role h 
        ON h.prty_id = CAST(sp.PARTY_CODE AS VARCHAR)
    WHERE sp.TYPE_OF_LAWYER IS NOT NULL
),

opus_source AS (
    SELECT
        h.hk_prtnr_role_cd,
        ocs.load_dt_tm AS ld_dt_tm,
        ocs.record_source AS rcrd_src_nm,
        
        CAST(ocs.LAWYER_TYPE AS VARCHAR) AS lawyer_type,
        NULL AS lawyer_category,
        NULL AS lawyer_specialization,
        CAST(ocs.BAR_ASSOCIATION_NAME AS VARCHAR) AS bar_association_name,
        NULL AS bar_association_number,
        NULL AS bar_association_state,
        NULL AS bar_council_registration,
        CAST(ocs.COVERED_COURT_LOC AS VARCHAR) AS court_name,
        NULL AS court_type,
        NULL AS court_jurisdiction,
        CAST(ocs.ENROLMENT_NO AS VARCHAR) AS enrolment_no,
        NULL AS enrolment_date,
        NULL AS enrolment_state,
        CAST(ocs.NO_OF_BRIEFS AS VARCHAR) AS no_of_briefs,
        CAST(ocs.NO_OF_COMPANIES AS VARCHAR) AS no_of_companies,
        CAST(ocs.NO_OF_MACT AS VARCHAR) AS no_of_mact,
        CAST(ocs.NO_OF_WC AS VARCHAR) AS no_of_wc,
        
        -- OPUS-only
        CAST(ocs.COVERED_COURT_LOC AS VARCHAR) AS covered_court_loc,
        CAST(ocs.YR_EXPERIENCE AS VARCHAR) AS yr_experience,
        CAST(ocs.DATE_OF_JOINING AS VARCHAR) AS date_of_joining,
        CAST(ocs.NO_OF_CONSUMER AS VARCHAR) AS no_of_consumer,
        CAST(ocs.NO_OF_JUNIOR AS VARCHAR) AS no_of_junior,
        CAST(ocs.ACD_QUALIFICATION AS VARCHAR) AS acd_qualification,
        CAST(ocs.INTERNET_ACCESS AS VARCHAR) AS internet_access,
        CAST(ocs.ACCESS_ONLINE_JOURNAL AS VARCHAR) AS access_online_journal,
        CAST(ocs.AVAILABILITY_LIBRARY AS VARCHAR) AS availability_library
    FROM {{ ref('stg_opus_clm_supplier_extn') }} ocs
    INNER JOIN hub_role h 
        ON ocs.PART_ID = h.prty_id
    WHERE ocs.LAWYER_TYPE IS NOT NULL
       OR ocs.BAR_ASSOCIATION_NAME IS NOT NULL
       OR ocs.ENROLMENT_NO IS NOT NULL
),

combined AS (
    SELECT *, 
        {{ hash_diff(['lawyer_type', 'bar_association_name', 'enrolment_no',
                      'court_name', 'no_of_briefs']) }} AS rcrd_hsh_id
    FROM maximus_source
    UNION ALL
    SELECT *, 
        {{ hash_diff(['lawyer_type', 'bar_association_name', 'enrolment_no',
                      'court_name', 'no_of_briefs']) }} AS rcrd_hsh_id
    FROM opus_source
)

{% if is_incremental() %}
, existing AS (
    SELECT hk_prtnr_role_cd, rcrd_hsh_id
    FROM {{ this }}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY hk_prtnr_role_cd ORDER BY ld_dt_tm DESC) = 1
)

SELECT c.*
FROM combined c
LEFT JOIN existing e ON c.hk_prtnr_role_cd = e.hk_prtnr_role_cd
WHERE e.hk_prtnr_role_cd IS NULL
   OR c.rcrd_hsh_id != e.rcrd_hsh_id

{% else %}

SELECT * FROM combined

{% endif %}
