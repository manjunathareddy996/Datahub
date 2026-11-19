-- =====================================================================
-- TRACE: why does a partner show NO TRAVEL INVOLVEMENT?
-- Run ONE step at a time (select the step's SQL and run it).
-- Each step is independent and only needs the SET line below.
-- Write what you see under "MY NOTES" of each step.
-- The first step that returns nothing is where the chain breaks.
-- =====================================================================

SET partner_code = '10045514';


-- =====================================================================
-- STEP 1: Is the partner in HUB_PARTY?
-- What it checks : the partner code exists as a party key in the vault.
-- Expect         : 1 row. Note PARTY_HKEY, you need it later.
-- If 0 rows      : wrong code, or it is stored with a different format.
-- =====================================================================
SELECT PARTY_HKEY, PARENT_BK, RECORD_SOURCE, LOAD_DATETIME
FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
WHERE  PARENT_BK = $partner_code;
-- MY NOTES:
--
--


-- =====================================================================
-- STEP 2: Which sources wrote this party? (partner, travel, health ...)
-- What it checks : hubs keep only the first loader, satellites keep each source.
-- Expect         : at least one OPUS_<partner table> / MAXIMUS_<partner table> row.
--                  If an OPUS_TRAVEL_ / MAXIMUS_TRAVEL_ row also shows up, the
--                  partner and travel share the same key (good sign).
-- =====================================================================
SELECT 'SAT_PARTY_IDENTITY' AS tbl, RECORD_SOURCE, COUNT(*) AS row_cnt
FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTITY
WHERE  PARTY_HKEY IN (SELECT PARTY_HKEY FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY WHERE PARENT_BK = $partner_code)
GROUP BY 1, 2
UNION ALL
SELECT 'SAT_PARTY_IDENTIFICATION', RECORD_SOURCE, COUNT(*)
FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION
WHERE  PARTY_HKEY IN (SELECT PARTY_HKEY FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY WHERE PARENT_BK = $partner_code)
GROUP BY 1, 2
UNION ALL
SELECT 'SAT_COMMON_CONTACT', RECORD_SOURCE, COUNT(*)
FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_CONTACT
WHERE  PARTY_HKEY IN (SELECT PARTY_HKEY FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY WHERE PARENT_BK = $partner_code)
GROUP BY 1, 2
ORDER BY 1, 2;
-- MY NOTES:
--
--


-- =====================================================================
-- STEP 3: How are the party IDs stored in Opus travel staging?
-- What it checks : the raw format of the 4 party columns (is it '10045514'
--                  or '10045514.0000000000'?). No filter on the partner yet.
-- Expect         : 5 sample rows. Compare the format with the partner code.
-- =====================================================================
SELECT trv_data_no, payer_part_id, cft_mst_comp_ref
FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.STG_TRAVEL__BA_TRV_DATA_POLICY_DTLS
WHERE  payer_part_id IS NOT NULL
LIMIT 5;

SELECT policy_ref, part_id, premiumpayerid
FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.STG_TRAVEL__BJAZ_TRV_LOADER_DATA
WHERE  part_id IS NOT NULL
LIMIT 5;
-- MY NOTES:
--
--


-- =====================================================================
-- STEP 4: Is this partner on any Opus travel policy?
-- What it checks : the partner code in any of the 4 Opus travel party columns.
--                  The trailing '.000' is stripped so both formats match.
-- Expect         : rows = this partner is a payer / customer on Opus travel.
-- If 0 rows      : no Opus travel policy under the partner's own code.
--                  (He may still be in travel under another ID, see step 6.)
-- =====================================================================
SELECT 'BA_TRV_DATA_POLICY_DTLS' AS src, trv_data_no AS policy_bk,
       payer_part_id, cft_mst_comp_ref, NULL AS part_id, NULL AS premiumpayerid
FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.STG_TRAVEL__BA_TRV_DATA_POLICY_DTLS
WHERE  REGEXP_REPLACE(TRIM(TO_VARCHAR(payer_part_id)),    '\\.0+$', '') = $partner_code
   OR  REGEXP_REPLACE(TRIM(TO_VARCHAR(cft_mst_comp_ref)), '\\.0+$', '') = $partner_code
UNION ALL
SELECT 'BJAZ_TRV_LOADER_DATA', policy_ref,
       NULL, NULL, part_id, premiumpayerid
FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.STG_TRAVEL__BJAZ_TRV_LOADER_DATA
WHERE  REGEXP_REPLACE(TRIM(TO_VARCHAR(part_id)),        '\\.0+$', '') = $partner_code
   OR  REGEXP_REPLACE(TRIM(TO_VARCHAR(premiumpayerid)), '\\.0+$', '') = $partner_code;
-- MY NOTES:
--
--


-- =====================================================================
-- STEP 4b: Is this partner the AGENT / INTERMEDIARY on Opus travel policies?
-- Why        : step 2 showed source OPUS_TRAVEL_BA_TRV_DATA_POLICY_DTLS on the partner's
--              key, but step 4 found nothing in payer_part_id / cft_mst_comp_ref of that
--              table. Opus travel ALSO writes HUB_PARTY from intermediary_code (the agent,
--              see stg2_party_identity_ba_trv_data_policy_dtls_agent). The main query does
--              not look at the agent columns yet.
-- Expect     : rows here = the partner SOLD travel policies (role = intermediary / agent).
-- =====================================================================
SELECT 'BA_TRV_DATA_POLICY_DTLS' AS src, trv_data_no AS policy_bk, policy_ref,
       intermediary_code, partner_id, subagent_code
FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.STG_TRAVEL__BA_TRV_DATA_POLICY_DTLS
WHERE  REGEXP_REPLACE(TRIM(TO_VARCHAR(intermediary_code)), '\\.0+$', '') = $partner_code
   OR  REGEXP_REPLACE(TRIM(TO_VARCHAR(partner_id)),        '\\.0+$', '') = $partner_code
   OR  REGEXP_REPLACE(TRIM(TO_VARCHAR(subagent_code)),     '\\.0+$', '') = $partner_code
LIMIT 20;

SELECT 'BJAZ_TRV_LOADER_DATA' AS src, policy_ref, intermediary, subimd
FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.STG_TRAVEL__BJAZ_TRV_LOADER_DATA
WHERE  REGEXP_REPLACE(TRIM(TO_VARCHAR(intermediary)), '\\.0+$', '') = $partner_code
   OR  REGEXP_REPLACE(TRIM(TO_VARCHAR(subimd)),       '\\.0+$', '') = $partner_code
LIMIT 20;
-- MY NOTES:
--
--


-- =====================================================================
-- STEP 4c: How often is POLICY_REF empty in BJAZ_TRV_LOADER_DATA?
-- Why        : step 4 found the partner as premiumpayerid, but policy_ref was NULL.
--              HUB_POLICY for this table is keyed on policy_ref, so those rows have
--              no policy at all and the main query drops them.
-- Expect     : the share of rows with no policy_ref, and which other number could
--              identify the policy (receiptno / transactionid / scrutiny_no).
-- =====================================================================
SELECT COUNT(*)                                        AS total_rows,
       COUNT(policy_ref)                               AS with_policy_ref,
       COUNT(*) - COUNT(policy_ref)                    AS without_policy_ref,
       COUNT(receiptno)                                AS with_receiptno,
       COUNT(transactionid)                            AS with_transactionid,
       COUNT(scrutiny_no)                              AS with_scrutiny_no
FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.STG_TRAVEL__BJAZ_TRV_LOADER_DATA;

-- the partner's own loader rows, with every number that could stand for the policy
SELECT policy_ref, receiptno, transactionid, scrutiny_no, part_id, premiumpayerid, inc_job_updated_at
FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.STG_TRAVEL__BJAZ_TRV_LOADER_DATA
WHERE  REGEXP_REPLACE(TRIM(TO_VARCHAR(premiumpayerid)), '\\.0+$', '') = $partner_code
   OR  REGEXP_REPLACE(TRIM(TO_VARCHAR(part_id)),        '\\.0+$', '') = $partner_code;
-- MY NOTES:
--
--


-- =====================================================================
-- STEP 5: Is this partner on any Maximus travel policy?
-- What it checks : the partner's PARTY_HKEY in the policy-party link, and its role.
--                  Reads LNK_POLICY_PARTY (Maximus travel writes it after the link_ -> lnk_ rename).
-- Expect         : rows with a MAXIMUS...TRAVEL / TRV record source.
-- If 0 rows      : no Maximus travel policy under the partner's own key.
-- =====================================================================
SELECT l.POLICY_HKEY, l.RECORD_SOURCE AS link_source,
       r.PARTY_ROLE_TYPE, r.RECORD_SOURCE AS role_source
FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_PARTY l
LEFT JOIN BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_POLICY_PARTY_ROLE r
       ON r.POLICY_PARTY_HKEY = l.POLICY_PARTY_HKEY
WHERE  l.PARTY_HKEY IN (SELECT PARTY_HKEY FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY WHERE PARENT_BK = $partner_code);
-- MY NOTES:
--
--


-- =====================================================================
-- STEP 6: What IDs does this partner have, and are they unique?
-- What it checks : PAN / Aadhaar / passport / GSTIN of the partner, and how
--                  many parties in the vault carry the same value.
-- Expect         : real IDs shared by 1-5 parties (the partner + travel copies).
-- Red flag       : a value shared by hundreds/thousands of parties = placeholder
--                  or shared corporate ID; the main query ignores those (> 5).
-- =====================================================================
WITH partner_ids AS (
    SELECT DISTINCT id_type, id_value
    FROM (
        SELECT 'PAN' AS id_type, UPPER(TRIM(TO_VARCHAR(PANNUMBER))) AS id_value FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION
        WHERE PARTY_HKEY IN (SELECT PARTY_HKEY FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY WHERE PARENT_BK = $partner_code)
        UNION ALL
        SELECT 'AADHAAR', UPPER(TRIM(TO_VARCHAR(AADHAARNUMBER))) FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION
        WHERE PARTY_HKEY IN (SELECT PARTY_HKEY FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY WHERE PARENT_BK = $partner_code)
        UNION ALL
        SELECT 'PASSPORT', UPPER(TRIM(TO_VARCHAR(PASSPORTNUMBER))) FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION
        WHERE PARTY_HKEY IN (SELECT PARTY_HKEY FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY WHERE PARENT_BK = $partner_code)
        UNION ALL
        SELECT 'GSTIN', UPPER(TRIM(TO_VARCHAR(GSTIN))) FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION
        WHERE PARTY_HKEY IN (SELECT PARTY_HKEY FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY WHERE PARENT_BK = $partner_code)
    )
    WHERE id_value IS NOT NULL AND id_value <> ''
)
SELECT p.id_type, p.id_value,
       (SELECT COUNT(DISTINCT s.PARTY_HKEY)
        FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION s
        WHERE  UPPER(TRIM(TO_VARCHAR(
                   CASE p.id_type WHEN 'PAN' THEN s.PANNUMBER WHEN 'AADHAAR' THEN s.AADHAARNUMBER
                                  WHEN 'PASSPORT' THEN s.PASSPORTNUMBER ELSE s.GSTIN END))) = p.id_value
       ) AS parties_with_value
FROM   partner_ids p
ORDER BY p.id_type;
-- MY NOTES:
--
--


-- =====================================================================
-- STEP 7: Who else carries the partner's ID? (only if step 6 found a real ID)
-- What it checks : the other parties with the same ID value, and their source.
--                  A travel source here = the partner IS in travel under another key.
-- Set the ID type and value from step 6 before running.
-- =====================================================================
SET id_type  = 'PAN';           -- PAN / AADHAAR / PASSPORT / GSTIN
SET id_value = '<value from step 6>';

SELECT s.PARTY_HKEY, h.PARENT_BK, s.RECORD_SOURCE
FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION s
JOIN   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY h ON h.PARTY_HKEY = s.PARTY_HKEY
WHERE  UPPER(TRIM(TO_VARCHAR(
           CASE $id_type WHEN 'PAN' THEN s.PANNUMBER WHEN 'AADHAAR' THEN s.AADHAARNUMBER
                         WHEN 'PASSPORT' THEN s.PASSPORTNUMBER ELSE s.GSTIN END))) = $id_value
GROUP BY 1, 2, 3
ORDER BY 3
LIMIT 50;
-- MY NOTES:
--
--


-- =====================================================================
-- STEP 8: Are the travel policies found in steps 4 / 5 in the policy tables?
-- What it checks : the policy number from step 4 exists in HUB_POLICY, and
--                  has a SAT_POLICY_HEADER row (dates, sum insured, product).
-- Set the policy number from step 4 (copy it exactly, including any '.000').
-- =====================================================================
SET policy_bk = '<policy_bk from step 4>';

SELECT h.POLICY_HKEY, h.PARENT_BK, h.RECORD_SOURCE AS hub_source,
       s.POLICY_REFERENCE_NUMBER, s.RISK_INCEPTION_DATE, s.RISK_EXPIRY_DATE,
       s.SUM_INSURED_TOTAL, s.PRODUCT_REFERENCE, s.RECORD_SOURCE AS sat_source
FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY h
LEFT JOIN BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_HEADER s
       ON s.POLICY_HKEY = h.POLICY_HKEY
WHERE  REGEXP_REPLACE(TRIM(TO_VARCHAR(h.PARENT_BK)), '\\.0+$', '')
     = REGEXP_REPLACE($policy_bk, '\\.0+$', '');
-- MY NOTES:
--
--
