-- ============================================================================
-- Diagnostics for MOBILENUMBER object population in maximus sat_common_contact.
-- Run each query block separately.
-- ============================================================================

-- Q1. Overall non-null MOBILENUMBER count per source stg_2 (how much data each table has).
SELECT 'pd_addr' AS src, COUNT(*) AS total_rows, COUNT(MOBILENUMBER) AS non_null_mobile, COUNT(DISTINCT PARTY_HKEY) AS parties_with_mobile
FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_mp__pd_addr WHERE MOBILENUMBER IS NOT NULL
UNION ALL
SELECT 'pd_party_addr_prop_pv', COUNT(*), COUNT(MOBILENUMBER), COUNT(DISTINCT PARTY_HKEY)
FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_mp__pd_party_addr_prop_pv WHERE MOBILENUMBER IS NOT NULL
UNION ALL
SELECT 'pd_prop_msdp_pv', COUNT(*), COUNT(MOBILENUMBER), COUNT(DISTINCT PARTY_HKEY)
FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_mp__pd_prop_msdp_pv WHERE MOBILENUMBER IS NOT NULL
UNION ALL
SELECT 'pd_prop_sp_pv', COUNT(*), COUNT(MOBILENUMBER), COUNT(DISTINCT PARTY_HKEY)
FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_mp__pd_prop_sp_pv WHERE MOBILENUMBER IS NOT NULL;


-- Q2. Which object keys actually appear in the final satellite (MAXIMUS rows only),
--     and how many rows carry each key. This proves whether 1, 2, 3 or 4 source tables
--     ever land in the MOBILENUMBER object across the whole dataset.
SELECT f.key AS source_table_key, COUNT(*) AS rows_with_key, COUNT(f.value) AS rows_with_non_null_value
FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.sat_common_contact s,
     LATERAL FLATTEN(input => s.MOBILENUMBER) f
WHERE s.RECORD_SOURCE = 'MAXIMUS'
GROUP BY 1
ORDER BY 2 DESC;


-- Q3. Distribution of how many keys each MAXIMUS row's MOBILENUMBER object has.
SELECT num_keys, COUNT(*) AS party_rows
FROM (
    SELECT ARRAY_SIZE(OBJECT_KEYS(MOBILENUMBER)) AS num_keys
    FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.sat_common_contact
    WHERE RECORD_SOURCE = 'MAXIMUS' AND MOBILENUMBER IS NOT NULL
)
GROUP BY 1
ORDER BY 1;


-- ============================================================================
-- Q4. Why does pd_prop_sp_pv contribute no object key despite 3066 mobiles?
--     Check PARTY_HKEY nullness among rows that have a mobile.
-- ============================================================================
SELECT
    COUNT(*)                                            AS rows_with_mobile,
    COUNT(PARTY_HKEY)                                   AS rows_with_party_hkey,
    SUM(IFF(PARTY_HKEY IS NULL, 1, 0))                  AS rows_null_party_hkey
FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_mp__pd_prop_sp_pv
WHERE MOBILENUMBER IS NOT NULL;


-- ============================================================================
-- Q5. For pd_prop_sp_pv rows that have a mobile: is foreign_key populated even
--     though bagic_employee_code (current party key) is null?
--     If foreign_key is non-null here, the party key mapping is wrong for this model.
-- ============================================================================
SELECT
    COUNT(*)                                        AS rows_with_mobile,
    SUM(IFF(bagic_employee_code IS NOT NULL,1,0))   AS has_bagic_employee_code,
    SUM(IFF(foreign_key IS NOT NULL,1,0))           AS has_foreign_key,
    SUM(IFF(parent_key_hash IS NOT NULL,1,0))       AS has_parent_key_hash
FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_maximus__pd_prop_sp_pv
WHERE coalesce(administrator_mobile_no, billing_persons_mobile_no, ceo_mobile_no, claim_mobile_number,
               contact_person_mobile_no_1, contact_person_mobile_no_2, finance_officer_mobile_number,
               marketing_head_mobile_no, medical_director_mobile_no, medical_superintendent_mobile_no,
               registered_mobile_number) IS NOT NULL;


-- ============================================================================
-- Q6. Exact, full object keys present in MOBILENUMBER across MAXIMUS rows.
--     No truncation: shows the complete source-table key string + row count.
-- ============================================================================
SELECT f.key AS full_source_table_key, COUNT(*) AS rows_with_key
FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.sat_common_contact s,
     LATERAL FLATTEN(input => s.MOBILENUMBER) f
WHERE s.RECORD_SOURCE = 'MAXIMUS'
GROUP BY 1
ORDER BY 2 DESC;

-- Q7. Does the PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT key exist at all? (explicit match)
SELECT COUNT(*) AS rows_with_addr_prop_key
FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.sat_common_contact s
WHERE s.RECORD_SOURCE = 'MAXIMUS'
  AND s.MOBILENUMBER:"BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW_2_1" IS NOT NULL;


-- ============================================================================
-- Q8. Probe BOTH exact address keys independently in the final object.
--     Confirms whether pd_party_addr_prop_pv's key truly landed or not.
-- ============================================================================
SELECT
    SUM(IFF(s.MOBILENUMBER:"BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS" IS NOT NULL,1,0))
        AS pd_addr_key_rows,
    SUM(IFF(s.MOBILENUMBER:"BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW_2_1" IS NOT NULL,1,0))
        AS pd_party_addr_prop_pv_key_rows,
    COUNT(*) AS total_maximus_rows
FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.sat_common_contact s
WHERE s.RECORD_SOURCE = 'MAXIMUS';

-- Q9. What RECORD_SOURCE / SOURCE_TABLE do the pd_party_addr_prop_pv mobile rows carry
--     in the stg_2 itself? Verifies the key string the macro would derive.
SELECT DISTINCT RECORD_SOURCE
FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_mp__pd_party_addr_prop_pv
WHERE MOBILENUMBER IS NOT NULL;
