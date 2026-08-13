-- Staging model for source table BJAZ_PMJAY_PRMBOOK_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("BUSINESS_FLG"::varchar), '') as business_flg,
    "ENDTPASS_ON"::timestamp_ntz as endtpass_on,
    "ENDT_EFF_DATE"::timestamp_ntz as endt_eff_date,
    nullif(trim("ENDT_NO"::varchar), '') as endt_no,
    nullif(trim("ENDT_TYPE"::varchar), '') as endt_type,
    "FAMILY_COVERED"::number as family_covered,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    "TOT_FAMILY_PRM"::number as tot_family_prm
    from {{ source('health_raw', 'BJAZ_PMJAY_PRMBOOK_DTLS') }}

)

select * from source
