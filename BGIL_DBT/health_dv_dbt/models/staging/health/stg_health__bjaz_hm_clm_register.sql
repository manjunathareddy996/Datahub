-- Staging model for source table BJAZ_HM_CLM_REGISTER (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "ACTUAL_DOA"::timestamp_ntz as actual_doa,
    "ACTUAL_DOD"::timestamp_ntz as actual_dod,
    nullif(trim("ADVERSE_HIST"::varchar), '') as adverse_hist,
    nullif(trim("BARIATRIC_SURGERY"::varchar), '') as bariatric_surgery,
    "CASHLESS_IN_ID"::number as cashless_in_id,
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    nullif(trim(to_varchar("CLID_HPMS")), '') as clid_hpms,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    "HOS_NETWORK_TYPE"::number as hos_network_type,
    nullif(trim("IMPLANT_YN"::varchar), '') as implant_yn,
    nullif(trim(to_varchar("INWARD_ID")), '') as inward_id,
    nullif(trim(to_varchar("MAIN_AGENT_CODE")), '') as main_agent_code,
    nullif(trim(to_varchar("MEMBER_ID")), '') as member_id,
    nullif(trim("OPD_FINAL_DIAGNOSIS"::varchar), '') as opd_final_diagnosis,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    nullif(trim("ROOM_DESC"::varchar), '') as room_desc,
    nullif(trim("TREATING_TYPE"::varchar), '') as treating_type
    from {{ source('health_raw', 'BJAZ_HM_CLM_REGISTER') }}

)

select * from source
