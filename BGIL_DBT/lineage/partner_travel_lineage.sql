-- =====================================================================
-- PARTNER -> TRAVEL LINEAGE  (Snowflake, read-only)
-- One row per: picked partner x matched travel party x travel policy x role
-- Vault: BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL
--
-- HOW TO USE: set the two variables below, then run the SET lines and the query together.
--   partner_codes : comma-separated partner codes (HUB_PARTY.PARENT_BK = part_id / party_code).
--                   Leave it '' to take a random sample of partners instead.
--   sample_size   : how many partners to sample when partner_codes is ''.
--   sample_mode   : 'IN_TRAVEL' = sample only partners whose key also appears on a travel policy
--                                 (use this to test: most partners have no travel at all)
--                   'RANDOM'    = any partner.
-- Every later step is filtered to the picked partners from the start, so the query
-- only touches their rows.
--
-- Deployed-table notes:
--   * Partner RECORD_SOURCE still has the old prefix OPUS_<TABLE> / MAXIMUS_<TABLE>;
--     travel was backfilled to OPUS_TRAVEL_ / MAXIMUS_TRAVEL_.
--   * SAT_PARTY_IDENTIFICATION still has the old column names (PANNUMBER, not PAN_NUMBER),
--     and at least one ID column is not text, so values go through TO_VARCHAR.
--   * Maximus travel's link model is now lnk_policy_party (was link_policy_party), so it writes
--     the shared LNK_POLICY_PARTY. Re-run it before using this query; LINK_POLICY_PARTY is not read.
--   * Hubs and links keep only the FIRST loader's RECORD_SOURCE per key, so travel joins
--     go by business key / hash key, not by the hub's RECORD_SOURCE.
-- =====================================================================
SET partner_codes = '';      -- e.g. 'PC1001,PC1002,PC1003'
SET sample_size   = 10;
SET sample_mode   = 'IN_TRAVEL';   -- 'IN_TRAVEL' or 'RANDOM'
SET max_parties_per_id = 5;        -- an ID value held by more parties than this is a placeholder or a
                                   -- shared corporate ID, not a person: it is NOT used for matching

WITH
-- 0. INPUT: passed codes if any, else a random sample of partner rows from HUB_PARTY -------
passed_partner AS (
    SELECT DISTINCT TRIM(value) AS partner_bk
    FROM   TABLE(SPLIT_TO_TABLE($partner_codes, ','))
    WHERE  TRIM(value) <> ''
),
-- partner filter: old OPUS_<T> / MAXIMUS_<T> or new *_PARTNER_*; other LOBs and old travel tokens excluded
partner_hub AS (
    SELECT PARTY_HKEY, PARENT_BK
    FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
    WHERE  NOT EXISTS (SELECT 1 FROM passed_partner)
      AND (STARTSWITH(RECORD_SOURCE, 'OPUS_') OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_'))
      AND NOT (   STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')   OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')
               OR STARTSWITH(RECORD_SOURCE, 'OPUS_HEALTH_')   OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_HEALTH_')
               OR STARTSWITH(RECORD_SOURCE, 'OPUS_MOTOR_')
               OR STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')   OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
               OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_'))
),
-- party codes that sit on a travel policy (only built in IN_TRAVEL mode)
travel_party_bk AS (
    SELECT REGEXP_REPLACE(TRIM(TO_VARCHAR(payer_part_id)), '\\.0+$', '') AS bk FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.STG_TRAVEL__BA_TRV_DATA_POLICY_DTLS
    WHERE  $sample_mode = 'IN_TRAVEL' AND NOT EXISTS (SELECT 1 FROM passed_partner)
    UNION
    SELECT REGEXP_REPLACE(TRIM(TO_VARCHAR(cft_mst_comp_ref)), '\\.0+$', '') FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.STG_TRAVEL__BA_TRV_DATA_POLICY_DTLS
    WHERE  $sample_mode = 'IN_TRAVEL' AND NOT EXISTS (SELECT 1 FROM passed_partner)
    UNION
    SELECT REGEXP_REPLACE(TRIM(TO_VARCHAR(part_id)), '\\.0+$', '') FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.STG_TRAVEL__BJAZ_TRV_LOADER_DATA
    WHERE  $sample_mode = 'IN_TRAVEL' AND NOT EXISTS (SELECT 1 FROM passed_partner)
    UNION
    SELECT REGEXP_REPLACE(TRIM(TO_VARCHAR(premiumpayerid)), '\\.0+$', '') FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.STG_TRAVEL__BJAZ_TRV_LOADER_DATA
    WHERE  $sample_mode = 'IN_TRAVEL' AND NOT EXISTS (SELECT 1 FROM passed_partner)
),
travel_party_key AS (
-- LNK_POLICY_PARTY is shared by Opus partner / health / motor and Maximus travel, so keep only
-- Maximus travel rows. The link keeps its first loader's source; the role satellite keeps
-- Maximus travel's own rows, so either one marks the row as travel.
    SELECT DISTINCT l.PARTY_HKEY
    FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_PARTY l
    LEFT JOIN BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_POLICY_PARTY_ROLE r
           ON r.POLICY_PARTY_HKEY = l.POLICY_PARTY_HKEY
    WHERE  $sample_mode = 'IN_TRAVEL' AND NOT EXISTS (SELECT 1 FROM passed_partner)
      AND (l.RECORD_SOURCE ILIKE ANY ('MAXIMUS%TRAVEL%', 'MAXIMUS%TRV%')
        OR r.RECORD_SOURCE ILIKE ANY ('MAXIMUS%TRAVEL%', 'MAXIMUS%TRV%'))
),
sampled_partner AS (
    SELECT ph.PARENT_BK AS partner_bk
    FROM   partner_hub ph
    WHERE  $sample_mode <> 'IN_TRAVEL'
        OR REGEXP_REPLACE(TRIM(TO_VARCHAR(ph.PARENT_BK)), '\\.0+$', '') IN (SELECT bk FROM travel_party_bk)
        OR ph.PARTY_HKEY IN (SELECT PARTY_HKEY FROM travel_party_key)
    QUALIFY ROW_NUMBER() OVER (ORDER BY RANDOM()) <= $sample_size
),
picked_partner AS (
    SELECT partner_bk FROM passed_partner
    UNION ALL
    SELECT partner_bk FROM sampled_partner
),

-- 1. PARTNER SIDE ------------------------------------------------------------------------
partner_key AS (
    SELECT h.PARTY_HKEY, h.PARENT_BK AS partner_bk
    FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY h
    JOIN   picked_partner p ON p.partner_bk = h.PARENT_BK
),
-- every source that wrote these keys (satellites keep one row per source, hubs only the first)
partner_src AS (
    SELECT PARTY_HKEY, RECORD_SOURCE FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
    WHERE  PARTY_HKEY IN (SELECT PARTY_HKEY FROM partner_key)
    UNION
    SELECT PARTY_HKEY, RECORD_SOURCE FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTITY
    WHERE  PARTY_HKEY IN (SELECT PARTY_HKEY FROM partner_key)
    UNION
    SELECT PARTY_HKEY, RECORD_SOURCE FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION
    WHERE  PARTY_HKEY IN (SELECT PARTY_HKEY FROM partner_key)
    UNION
    SELECT PARTY_HKEY, RECORD_SOURCE FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_CONTACT
    WHERE  PARTY_HKEY IN (SELECT PARTY_HKEY FROM partner_key)
),
partner AS (
    SELECT  k.PARTY_HKEY,
            k.partner_bk,
            CASE WHEN MAX(IFF(STARTSWITH(s.RECORD_SOURCE, 'OPUS_'), 1, 0)) = 1
                  AND MAX(IFF(STARTSWITH(s.RECORD_SOURCE, 'MAXIMUS_'), 1, 0)) = 1 THEN 'OPUS+MAXIMUS'
                 WHEN MAX(IFF(STARTSWITH(s.RECORD_SOURCE, 'OPUS_'), 1, 0)) = 1 THEN 'OPUS'
                 WHEN MAX(IFF(STARTSWITH(s.RECORD_SOURCE, 'MAXIMUS_'), 1, 0)) = 1 THEN 'MAXIMUS'
                 ELSE 'NOT FOUND AS PARTNER' END AS partner_system,
            LISTAGG(DISTINCT s.RECORD_SOURCE, ', ') WITHIN GROUP (ORDER BY s.RECORD_SOURCE) AS partner_record_sources
    FROM    partner_key k
    LEFT JOIN partner_src s
           ON s.PARTY_HKEY = k.PARTY_HKEY
          -- partner = old OPUS_<T> / MAXIMUS_<T> or new OPUS_PARTNER_ / MAXIMUS_PARTNER_;
          -- every other LOB and the old travel tokens are excluded (STARTSWITH: '_' is literal)
          AND (STARTSWITH(s.RECORD_SOURCE, 'OPUS_') OR STARTSWITH(s.RECORD_SOURCE, 'MAXIMUS_'))
          AND NOT (   STARTSWITH(s.RECORD_SOURCE, 'OPUS_TRAVEL_')   OR STARTSWITH(s.RECORD_SOURCE, 'MAXIMUS_TRAVEL_')
                   OR STARTSWITH(s.RECORD_SOURCE, 'OPUS_HEALTH_')   OR STARTSWITH(s.RECORD_SOURCE, 'MAXIMUS_HEALTH_')
                   OR STARTSWITH(s.RECORD_SOURCE, 'OPUS_MOTOR_')
                   OR STARTSWITH(s.RECORD_SOURCE, 'OPUS_BA_TRV_')   OR STARTSWITH(s.RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                   OR STARTSWITH(s.RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_'))
    GROUP BY k.PARTY_HKEY, k.partner_bk
),

-- 2. IDENTITY RESOLUTION (only for the picked partners) ------------------------------------
-- 2a. the partners' own ID values (old column names, cast to text)
partner_id_raw AS (
    SELECT DISTINCT PARTY_HKEY, id_type, id_value
    FROM (
        SELECT PARTY_HKEY, 'PAN'      AS id_type, UPPER(TRIM(TO_VARCHAR(PANNUMBER)))      AS id_value FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION WHERE PARTY_HKEY IN (SELECT PARTY_HKEY FROM partner_key)
        UNION ALL
        SELECT PARTY_HKEY, 'AADHAAR',               UPPER(TRIM(TO_VARCHAR(AADHAARNUMBER)))               FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION WHERE PARTY_HKEY IN (SELECT PARTY_HKEY FROM partner_key)
        UNION ALL
        SELECT PARTY_HKEY, 'PASSPORT',              UPPER(TRIM(TO_VARCHAR(PASSPORTNUMBER)))              FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION WHERE PARTY_HKEY IN (SELECT PARTY_HKEY FROM partner_key)
        UNION ALL
        SELECT PARTY_HKEY, 'GSTIN',                 UPPER(TRIM(TO_VARCHAR(GSTIN)))                       FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION WHERE PARTY_HKEY IN (SELECT PARTY_HKEY FROM partner_key)
    )
    -- keep only well-formed IDs: drops blanks, 'NA', '0', '{}' (OBJECT cast) and other placeholders
    WHERE (id_type = 'PAN'      AND REGEXP_LIKE(id_value, '[A-Z]{5}[0-9]{4}[A-Z]'))
       OR (id_type = 'AADHAAR'  AND REGEXP_LIKE(id_value, '[0-9]{12}') AND id_value NOT IN ('000000000000', '111111111111'))
       OR (id_type = 'PASSPORT' AND REGEXP_LIKE(id_value, '[A-Z][0-9]{7}'))
       OR (id_type = 'GSTIN'    AND REGEXP_LIKE(id_value, '[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][0-9A-Z]Z[0-9A-Z]'))
),
-- 2b. other parties carrying the same ID value (tier 2, cross-system)
id_match AS (
    SELECT DISTINCT pi.PARTY_HKEY AS partner_hkey, o.PARTY_HKEY AS travel_party_hkey,
           pi.id_type AS match_method, pi.id_value AS matched_value, o.parties_with_value
    FROM   partner_id_raw pi
    JOIN  (
      SELECT PARTY_HKEY, id_type, id_value,
             COUNT(DISTINCT PARTY_HKEY) OVER (PARTITION BY id_type, id_value) AS parties_with_value
      FROM (
        SELECT PARTY_HKEY, 'PAN' AS id_type, UPPER(TRIM(TO_VARCHAR(PANNUMBER))) AS id_value
        FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION
        WHERE  UPPER(TRIM(TO_VARCHAR(PANNUMBER))) IN (SELECT id_value FROM partner_id_raw WHERE id_type = 'PAN')
        UNION ALL
        SELECT PARTY_HKEY, 'AADHAAR', UPPER(TRIM(TO_VARCHAR(AADHAARNUMBER)))
        FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION
        WHERE  UPPER(TRIM(TO_VARCHAR(AADHAARNUMBER))) IN (SELECT id_value FROM partner_id_raw WHERE id_type = 'AADHAAR')
        UNION ALL
        SELECT PARTY_HKEY, 'PASSPORT', UPPER(TRIM(TO_VARCHAR(PASSPORTNUMBER)))
        FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION
        WHERE  UPPER(TRIM(TO_VARCHAR(PASSPORTNUMBER))) IN (SELECT id_value FROM partner_id_raw WHERE id_type = 'PASSPORT')
        UNION ALL
        SELECT PARTY_HKEY, 'GSTIN', UPPER(TRIM(TO_VARCHAR(GSTIN)))
        FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION
        WHERE  UPPER(TRIM(TO_VARCHAR(GSTIN))) IN (SELECT id_value FROM partner_id_raw WHERE id_type = 'GSTIN')
      )
      QUALIFY parties_with_value <= $max_parties_per_id
    ) o
      ON  o.id_type = pi.id_type AND o.id_value = pi.id_value
     AND  o.PARTY_HKEY <> pi.PARTY_HKEY
),
-- 2c. cross-reference: tier 1 (same key) + tier 2 (same ID)
xref AS (
    SELECT PARTY_HKEY AS partner_hkey, PARTY_HKEY AS travel_party_hkey, 'SAME_KEY' AS match_method,
           partner_bk AS matched_value, 1 AS parties_with_value
    FROM   partner_key
    UNION
    SELECT partner_hkey, travel_party_hkey, match_method, matched_value, parties_with_value FROM id_match
),
candidate AS (
    SELECT DISTINCT x.travel_party_hkey, h.PARENT_BK AS travel_party_bk,
           REGEXP_REPLACE(TRIM(TO_VARCHAR(h.PARENT_BK)), '\\.0+$', '') AS travel_party_bk_norm
    FROM   xref x
    JOIN   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY h ON h.PARTY_HKEY = x.travel_party_hkey
),

-- 3. TRAVEL INVOLVEMENT (only for the candidate parties) ----------------------------------
-- 3a. Maximus travel: policy-party link + role satellite
mx_travel AS (
-- LNK_POLICY_PARTY is shared by Opus partner / health / motor and Maximus travel, so keep only
-- Maximus travel rows. The link keeps its first loader's source; the role satellite keeps
-- Maximus travel's own rows, so either one marks the row as travel.
    SELECT DISTINCT
           l.PARTY_HKEY   AS travel_party_hkey,
           l.POLICY_HKEY  AS policy_hkey,
           COALESCE(r.PARTY_ROLE_TYPE, 'UNKNOWN') AS role,
           'MAXIMUS_TRAVEL' AS travel_system
    FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_PARTY l
    LEFT JOIN BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_POLICY_PARTY_ROLE r
           ON r.POLICY_PARTY_HKEY = l.POLICY_PARTY_HKEY
    WHERE  l.PARTY_HKEY IN (SELECT travel_party_hkey FROM candidate)
      AND (l.RECORD_SOURCE ILIKE ANY ('MAXIMUS%TRAVEL%', 'MAXIMUS%TRV%')
        OR r.RECORD_SOURCE ILIKE ANY ('MAXIMUS%TRAVEL%', 'MAXIMUS%TRV%'))
),
-- 3b. Opus travel: rebuilt from staging (no policy-party link in the model)
--     Opus travel ID columns can come through as '10045514.0000000000' (NUMBER cast to text);
--     the trailing '.000' is stripped on both sides before comparing with the partner code.
opus_raw AS (
    SELECT trv_data_no AS policy_bk, REGEXP_REPLACE(TRIM(TO_VARCHAR(payer_part_id)), '\\.0+$', '') AS party_bk, 'PAYER (payer_part_id)' AS role
    FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.STG_TRAVEL__BA_TRV_DATA_POLICY_DTLS
    WHERE  REGEXP_REPLACE(TRIM(TO_VARCHAR(payer_part_id)), '\\.0+$', '') IN (SELECT travel_party_bk_norm FROM candidate)
    UNION
    SELECT trv_data_no, REGEXP_REPLACE(TRIM(TO_VARCHAR(cft_mst_comp_ref)), '\\.0+$', ''), 'CUSTOMER (cft_mst_comp_ref)'
    FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.STG_TRAVEL__BA_TRV_DATA_POLICY_DTLS
    WHERE  REGEXP_REPLACE(TRIM(TO_VARCHAR(cft_mst_comp_ref)), '\\.0+$', '') IN (SELECT travel_party_bk_norm FROM candidate)
    UNION
    SELECT policy_ref, REGEXP_REPLACE(TRIM(TO_VARCHAR(part_id)), '\\.0+$', ''), 'CUSTOMER (part_id)'
    FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.STG_TRAVEL__BJAZ_TRV_LOADER_DATA
    WHERE  REGEXP_REPLACE(TRIM(TO_VARCHAR(part_id)), '\\.0+$', '') IN (SELECT travel_party_bk_norm FROM candidate)
    UNION
    SELECT policy_ref, REGEXP_REPLACE(TRIM(TO_VARCHAR(premiumpayerid)), '\\.0+$', ''), 'PAYER (premiumpayerid)'
    FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.STG_TRAVEL__BJAZ_TRV_LOADER_DATA
    WHERE  REGEXP_REPLACE(TRIM(TO_VARCHAR(premiumpayerid)), '\\.0+$', '') IN (SELECT travel_party_bk_norm FROM candidate)
),
opus_travel AS (
    SELECT DISTINCT
           c.travel_party_hkey,
           hpol.POLICY_HKEY AS policy_hkey,
           o.role,
           'OPUS_TRAVEL'    AS travel_system
    FROM   opus_raw o
    JOIN   candidate c ON c.travel_party_bk_norm = o.party_bk
    LEFT JOIN BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY hpol
           ON hpol.PARENT_BK = o.policy_bk
    WHERE  o.policy_bk IS NOT NULL
),
travel AS (
    SELECT * FROM mx_travel
    UNION ALL
    SELECT * FROM opus_travel
),

-- 4. POLICY + PRODUCT (only the policies found; latest satellite row each) ----------------
pol AS (
    SELECT POLICY_HKEY, POLICY_REFERENCE_NUMBER, POLICY_STATUS, POLICY_TYPE,
           RISK_INCEPTION_DATE, RISK_EXPIRY_DATE, SUM_INSURED_TOTAL, PRODUCT_REFERENCE
    FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_HEADER
    WHERE  POLICY_HKEY IN (SELECT policy_hkey FROM travel)
    QUALIFY ROW_NUMBER() OVER (PARTITION BY POLICY_HKEY ORDER BY LOAD_DATETIME DESC) = 1
),
policy_bk AS (
    SELECT POLICY_HKEY, ANY_VALUE(PARENT_BK) AS policy_bk
    FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY
    WHERE  POLICY_HKEY IN (SELECT policy_hkey FROM travel)
    GROUP BY POLICY_HKEY
),
prod AS (
    SELECT h.PARENT_BK AS product_bk, s.PRODUCT_NAME, s.PRODUCT_CATEGORY
    FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PRODUCT h
    JOIN   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_DEFINITION s
           ON s.PRODUCT_HKEY = h.PRODUCT_HKEY
    WHERE  h.PARENT_BK IN (SELECT PRODUCT_REFERENCE FROM pol)
    QUALIFY ROW_NUMBER() OVER (PARTITION BY h.PARENT_BK ORDER BY s.LOAD_DATETIME DESC) = 1
)

-- 5. OUTPUT: every picked partner appears; travel columns are NULL when none found ----------
SELECT  p.partner_bk,
        p.partner_system,
        p.partner_record_sources,
        x.match_method,
        x.matched_value,
        x.parties_with_value,
        th.travel_party_bk,
        t.travel_system,
        t.role,
        COALESCE(pb.policy_bk, '(policy not in HUB_POLICY)') AS policy_bk,
        pol.POLICY_REFERENCE_NUMBER,
        pol.POLICY_STATUS,
        pol.RISK_INCEPTION_DATE,
        pol.RISK_EXPIRY_DATE,
        pol.SUM_INSURED_TOTAL,
        pol.PRODUCT_REFERENCE,
        prod.PRODUCT_NAME,
        prod.PRODUCT_CATEGORY,
        IFF(t.travel_party_hkey IS NULL, 'NO TRAVEL INVOLVEMENT', 'IN TRAVEL') AS travel_flag
FROM    picked_partner pp
LEFT JOIN partner   p   ON p.partner_bk = pp.partner_bk
LEFT JOIN xref      x   ON x.partner_hkey = p.PARTY_HKEY
LEFT JOIN travel    t   ON t.travel_party_hkey = x.travel_party_hkey
LEFT JOIN candidate th  ON th.travel_party_hkey = t.travel_party_hkey
LEFT JOIN policy_bk pb  ON pb.POLICY_HKEY = t.policy_hkey
LEFT JOIN pol           ON pol.POLICY_HKEY = t.policy_hkey
LEFT JOIN prod          ON prod.product_bk = pol.PRODUCT_REFERENCE
QUALIFY t.travel_party_hkey IS NOT NULL
     OR ROW_NUMBER() OVER (PARTITION BY pp.partner_bk ORDER BY x.match_method) = 1
ORDER BY pp.partner_bk, t.travel_system, pol.RISK_INCEPTION_DATE DESC;

-- ---------------------------------------------------------------------
-- DIAGNOSTIC (run on its own): how many partner keys appear in travel at all?
-- If both counts are 0, no partner shares a key with travel, and only the
-- PAN / Aadhaar / passport / GSTIN match (tier 2) can link them.
--   WITH ph AS (SELECT PARTY_HKEY, PARENT_BK FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
--               WHERE STARTSWITH(RECORD_SOURCE,'OPUS_') AND NOT STARTSWITH(RECORD_SOURCE,'OPUS_TRAVEL_'))
--   SELECT
--     (SELECT COUNT(DISTINCT ph.PARENT_BK) FROM ph JOIN BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.STG_TRAVEL__BJAZ_TRV_LOADER_DATA t
--        ON ph.PARENT_BK IN (t.part_id, t.premiumpayerid))                                   AS opus_partner_in_loader_data,
--     (SELECT COUNT(DISTINCT ph.PARENT_BK) FROM ph JOIN BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.STG_TRAVEL__BA_TRV_DATA_POLICY_DTLS t
--        ON ph.PARENT_BK IN (t.payer_part_id, t.cft_mst_comp_ref))                           AS opus_partner_in_policy_dtls;
-- ---------------------------------------------------------------------
