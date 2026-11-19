-- =====================================================================
-- PARTNER -> TRAVEL LINEAGE  (Snowflake, read-only)
-- Uses ONLY final vault tables: HUB_*, LNK_*, SAT_* in BGIL_DATA_MODEL.
-- No stg_ / stg2_ views, the same objects a business user would query.
--
-- One row per: picked partner x matched travel party x travel policy (when known).
--
-- HOW TO USE: set the variables, then run the SET lines and the query together.
--   partner_codes      : comma-separated partner codes (HUB_PARTY.PARENT_BK = part_id / party_code).
--                        Leave '' to sample partners instead.
--   sample_size        : how many partners to sample when partner_codes is ''.
--   sample_mode        : 'IN_TRAVEL' = only partners that travel also loaded (use this to test)
--                        'RANDOM'    = any partner.
--   max_parties_per_id : an ID value held by more parties than this is a placeholder or a
--                        shared corporate ID, so it is NOT used for matching.
--
-- WHAT THE VAULT CAN AND CANNOT ANSWER TODAY
--   * Maximus travel: party -> policy is in LNK_POLICY_PARTY (+ role in SAT_LNK_POLICY_PARTY_ROLE),
--     party -> claim is in LNK_CLAIM_PARTY. Policy, role, dates and product are returned.
--   * Opus travel: the vault has NO policy-party link (no lnk_ model in opus_travel_dv_dbt).
--     The query can only say the party was loaded by Opus travel (party satellites with an
--     OPUS_TRAVEL_ source) plus the payer / proposer flags in the SAT_AUG_* role satellites.
--     Policy columns stay empty for Opus travel until an Opus travel lnk_policy_party is built.
--
-- RECORD_SOURCE -> line of business (deployed data):
--   Partner rows still carry the old prefix OPUS_<TABLE> / MAXIMUS_<TABLE>; travel rows carry
--   OPUS_TRAVEL_* / MAXIMUS_TRAVEL_* (or the older OPUS_BA_TRV_*, OPUS_BJAZ_TRV_*, MAXIMUS_NONHLTH_TRV_*).
--   Hubs and links keep only the FIRST loader's RECORD_SOURCE per key, satellites keep every
--   source, so LOB membership is read from the satellites.
-- SAT_PARTY_IDENTIFICATION still has the old column names (PANNUMBER, not PAN_NUMBER) and at
-- least one ID column is not text, so values go through TO_VARCHAR.
-- =====================================================================
SET partner_codes      = '';            -- e.g. '10045514,10045515'
SET sample_size        = 10;
SET sample_mode        = 'IN_TRAVEL';   -- 'IN_TRAVEL' or 'RANDOM'
SET max_parties_per_id = 5;

WITH
-- ---------------------------------------------------------------------------------------
-- 0. INPUT: passed codes, else a sample
-- ---------------------------------------------------------------------------------------
passed_partner AS (
    SELECT DISTINCT TRIM(value) AS partner_bk
    FROM   TABLE(SPLIT_TO_TABLE($partner_codes, ','))
    WHERE  TRIM(value) <> ''
),
-- sample: partner keys from SAT_PARTY_IDENTITY (partner source = old OPUS_<T> / MAXIMUS_<T>,
-- i.e. not travel / health / motor). IN_TRAVEL also needs a travel row for the same key.
sampled_partner AS (
    SELECT h.PARENT_BK AS partner_bk
    FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTITY s
    JOIN   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY h ON h.PARTY_HKEY = s.PARTY_HKEY
    WHERE  NOT EXISTS (SELECT 1 FROM passed_partner)
      AND  s.RECORD_SOURCE RLIKE '^(OPUS|MAXIMUS)_.*'
      AND  NOT s.RECORD_SOURCE RLIKE '^(OPUS|MAXIMUS)_(TRAVEL|HEALTH|MOTOR|BA_TRV|BJAZ_TRV|NONHLTH_TRV)_.*'
      AND ($sample_mode <> 'IN_TRAVEL'
           OR EXISTS (SELECT 1
                      FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTITY t
                      WHERE  t.PARTY_HKEY = s.PARTY_HKEY
                        AND  t.RECORD_SOURCE RLIKE '^(OPUS|MAXIMUS)_(TRAVEL|BA_TRV|BJAZ_TRV|NONHLTH_TRV)_.*'))
    GROUP BY h.PARENT_BK
    QUALIFY ROW_NUMBER() OVER (ORDER BY RANDOM()) <= $sample_size
),
picked_partner AS (
    SELECT partner_bk FROM passed_partner
    UNION ALL
    SELECT partner_bk FROM sampled_partner
),

-- ---------------------------------------------------------------------------------------
-- 1. PARTNER SIDE: key + which partner sources wrote it
-- ---------------------------------------------------------------------------------------
partner_key AS (
    SELECT h.PARTY_HKEY, h.PARENT_BK AS partner_bk
    FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY h
    JOIN   picked_partner p ON p.partner_bk = h.PARENT_BK
),

-- ---------------------------------------------------------------------------------------
-- 2. IDENTITY RESOLUTION (from SAT_PARTY_IDENTIFICATION only)
-- ---------------------------------------------------------------------------------------
-- 2a. the partners' own well-formed IDs
partner_id AS (
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
    WHERE (id_type = 'PAN'      AND REGEXP_LIKE(id_value, '[A-Z]{5}[0-9]{4}[A-Z]'))
       OR (id_type = 'AADHAAR'  AND REGEXP_LIKE(id_value, '[0-9]{12}') AND id_value NOT IN ('000000000000', '111111111111'))
       OR (id_type = 'PASSPORT' AND REGEXP_LIKE(id_value, '[A-Z][0-9]{7}'))
       OR (id_type = 'GSTIN'    AND REGEXP_LIKE(id_value, '[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][0-9A-Z]Z[0-9A-Z]'))
),
-- 2b. other parties with the same ID value (tier 2); values shared too widely are dropped
id_match AS (
    SELECT DISTINCT pi.PARTY_HKEY AS partner_hkey, o.PARTY_HKEY AS travel_party_hkey,
           pi.id_type AS match_method, pi.id_value AS matched_value, o.parties_with_value
    FROM   partner_id pi
    JOIN  (
      SELECT PARTY_HKEY, id_type, id_value,
             COUNT(DISTINCT PARTY_HKEY) OVER (PARTITION BY id_type, id_value) AS parties_with_value
      FROM (
        SELECT PARTY_HKEY, 'PAN' AS id_type, UPPER(TRIM(TO_VARCHAR(PANNUMBER))) AS id_value
        FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION
        WHERE  UPPER(TRIM(TO_VARCHAR(PANNUMBER))) IN (SELECT id_value FROM partner_id WHERE id_type = 'PAN')
        UNION ALL
        SELECT PARTY_HKEY, 'AADHAAR', UPPER(TRIM(TO_VARCHAR(AADHAARNUMBER)))
        FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION
        WHERE  UPPER(TRIM(TO_VARCHAR(AADHAARNUMBER))) IN (SELECT id_value FROM partner_id WHERE id_type = 'AADHAAR')
        UNION ALL
        SELECT PARTY_HKEY, 'PASSPORT', UPPER(TRIM(TO_VARCHAR(PASSPORTNUMBER)))
        FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION
        WHERE  UPPER(TRIM(TO_VARCHAR(PASSPORTNUMBER))) IN (SELECT id_value FROM partner_id WHERE id_type = 'PASSPORT')
        UNION ALL
        SELECT PARTY_HKEY, 'GSTIN', UPPER(TRIM(TO_VARCHAR(GSTIN)))
        FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION
        WHERE  UPPER(TRIM(TO_VARCHAR(GSTIN))) IN (SELECT id_value FROM partner_id WHERE id_type = 'GSTIN')
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
candidate AS (SELECT DISTINCT travel_party_hkey FROM xref),

-- ---------------------------------------------------------------------------------------
-- 3. LOB MEMBERSHIP of partner + candidate keys (party satellites keep every source)
-- ---------------------------------------------------------------------------------------
key_src AS (
    SELECT PARTY_HKEY, RECORD_SOURCE FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTITY
    WHERE  PARTY_HKEY IN (SELECT travel_party_hkey FROM candidate)
    UNION
    SELECT PARTY_HKEY, RECORD_SOURCE FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION
    WHERE  PARTY_HKEY IN (SELECT travel_party_hkey FROM candidate)
    UNION
    SELECT PARTY_HKEY, RECORD_SOURCE FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_CONTACT
    WHERE  PARTY_HKEY IN (SELECT travel_party_hkey FROM candidate)
    UNION
    SELECT PARTY_HKEY, RECORD_SOURCE FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
    WHERE  PARTY_HKEY IN (SELECT travel_party_hkey FROM candidate)
),
key_lob AS (
    SELECT PARTY_HKEY, RECORD_SOURCE,
           CASE WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL')    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
                  OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')                                       THEN 'OPUS_TRAVEL'
                WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL') OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'MAXIMUS_TRAVEL'
                WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_HEALTH')    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_HEALTH')
                  OR STARTSWITH(RECORD_SOURCE, 'OPUS_MOTOR')                                           THEN 'OTHER'
                WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_')                                                THEN 'OPUS_PARTNER'
                WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_')                                             THEN 'MAXIMUS_PARTNER'
                ELSE 'OTHER' END AS lob
    FROM key_src
),
partner AS (
    SELECT  k.PARTY_HKEY,
            k.partner_bk,
            COALESCE(NULLIF(LISTAGG(DISTINCT IFF(l.lob IN ('OPUS_PARTNER', 'MAXIMUS_PARTNER'), l.lob, NULL), '+'), ''),
                     'NOT FOUND AS PARTNER') AS partner_system,
            LISTAGG(DISTINCT IFF(l.lob IN ('OPUS_PARTNER', 'MAXIMUS_PARTNER'), l.RECORD_SOURCE, NULL), ', ')
                AS partner_record_sources
    FROM    partner_key k
    LEFT JOIN key_lob l ON l.PARTY_HKEY = k.PARTY_HKEY
    GROUP BY k.PARTY_HKEY, k.partner_bk
),
-- travel systems that loaded each candidate key
travel_presence AS (
    SELECT PARTY_HKEY AS travel_party_hkey, lob AS travel_system,
           LISTAGG(DISTINCT RECORD_SOURCE, ', ') AS travel_record_sources
    FROM   key_lob
    WHERE  lob IN ('OPUS_TRAVEL', 'MAXIMUS_TRAVEL')
    GROUP BY 1, 2
),

-- ---------------------------------------------------------------------------------------
-- 4. TRAVEL INVOLVEMENT
-- ---------------------------------------------------------------------------------------
-- 4a. Maximus travel: party -> policy (link) + role (link satellite)
mx_policy AS (
    SELECT DISTINCT
           l.PARTY_HKEY  AS travel_party_hkey,
           l.POLICY_HKEY AS policy_hkey,
           COALESCE(r.PARTY_ROLE_TYPE, 'UNKNOWN') AS role
    FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_PARTY l
    LEFT JOIN BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_POLICY_PARTY_ROLE r
           ON r.POLICY_PARTY_HKEY = l.POLICY_PARTY_HKEY
    WHERE  l.PARTY_HKEY IN (SELECT travel_party_hkey FROM candidate)
      -- shared link: keep Maximus travel rows (link keeps the first loader; the role sat its own rows)
      AND (l.RECORD_SOURCE ILIKE ANY ('MAXIMUS%TRAVEL%', 'MAXIMUS%TRV%')
        OR r.RECORD_SOURCE ILIKE ANY ('MAXIMUS%TRAVEL%', 'MAXIMUS%TRV%'))
),
-- 4b. Maximus travel: claims the party is on
mx_claim AS (
    SELECT l.PARTY_HKEY AS travel_party_hkey, COUNT(DISTINCT l.CLAIM_HKEY) AS claim_count
    FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_CLAIM_PARTY l
    WHERE  l.PARTY_HKEY IN (SELECT travel_party_hkey FROM candidate)
      AND  l.RECORD_SOURCE ILIKE ANY ('MAXIMUS%TRAVEL%', 'MAXIMUS%TRV%')
    GROUP BY 1
),
-- 4c. Opus travel: role flags on the party (no policy link exists in the vault)
opus_role AS (
    SELECT p.PARTY_HKEY AS travel_party_hkey,
           MAX(TO_VARCHAR(p.PREMIUM_PAYER_INDICATOR))         AS opus_premium_payer_indicator,
           MAX(TO_VARCHAR(c.PROPOSER_IS_TRAVELLER_INDICATOR)) AS opus_proposer_is_traveller_indicator
    FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_LNK_PARTY_ROLE_CORE p
    LEFT JOIN BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_LNK_ROLE_CUSTOMER c
           ON c.PARTY_HKEY = p.PARTY_HKEY
          AND (STARTSWITH(c.RECORD_SOURCE, 'OPUS_TRAVEL') OR STARTSWITH(c.RECORD_SOURCE, 'OPUS_BA_TRV_')
               OR STARTSWITH(c.RECORD_SOURCE, 'OPUS_BJAZ_TRV_'))
    WHERE  p.PARTY_HKEY IN (SELECT travel_party_hkey FROM candidate)
      AND (STARTSWITH(p.RECORD_SOURCE, 'OPUS_TRAVEL') OR STARTSWITH(p.RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(p.RECORD_SOURCE, 'OPUS_BJAZ_TRV_'))
    GROUP BY 1
),
-- 4d. one row per travel party x system x policy (policy NULL for Opus travel)
travel AS (
    SELECT tp.travel_party_hkey, tp.travel_system, tp.travel_record_sources,
           mp.policy_hkey, mp.role
    FROM   travel_presence tp
    LEFT JOIN mx_policy mp
           ON mp.travel_party_hkey = tp.travel_party_hkey
          AND tp.travel_system = 'MAXIMUS_TRAVEL'
),

-- ---------------------------------------------------------------------------------------
-- 5. POLICY + PRODUCT (latest satellite row each)
-- ---------------------------------------------------------------------------------------
pol AS (
    SELECT POLICY_HKEY, POLICY_REFERENCE_NUMBER, POLICY_STATUS, POLICY_TYPE,
           RISK_INCEPTION_DATE, RISK_EXPIRY_DATE, SUM_INSURED_TOTAL, PRODUCT_REFERENCE
    FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_HEADER
    WHERE  POLICY_HKEY IN (SELECT policy_hkey FROM mx_policy)
    QUALIFY ROW_NUMBER() OVER (PARTITION BY POLICY_HKEY ORDER BY LOAD_DATETIME DESC) = 1
),
policy_bk AS (
    SELECT POLICY_HKEY, PARENT_BK AS policy_bk
    FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY
    WHERE  POLICY_HKEY IN (SELECT policy_hkey FROM mx_policy)
),
prod AS (
    SELECT h.PARENT_BK AS product_bk, s.PRODUCT_NAME, s.PRODUCT_CATEGORY
    FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PRODUCT h
    JOIN   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_DEFINITION s
           ON s.PRODUCT_HKEY = h.PRODUCT_HKEY
    WHERE  h.PARENT_BK IN (SELECT PRODUCT_REFERENCE FROM pol)
    QUALIFY ROW_NUMBER() OVER (PARTITION BY h.PARENT_BK ORDER BY s.LOAD_DATETIME DESC) = 1
),
party_bk AS (
    SELECT PARTY_HKEY, PARENT_BK
    FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
    WHERE  PARTY_HKEY IN (SELECT travel_party_hkey FROM candidate)
)

-- ---------------------------------------------------------------------------------------
-- 6. OUTPUT: every picked partner appears at least once
-- ---------------------------------------------------------------------------------------
SELECT  pp.partner_bk,
        p.partner_system,
        p.partner_record_sources,
        x.match_method,
        x.matched_value,
        x.parties_with_value,
        pb.PARENT_BK                  AS travel_party_bk,
        t.travel_system,
        t.travel_record_sources,
        t.role                        AS maximus_policy_role,
        orl.opus_premium_payer_indicator,
        orl.opus_proposer_is_traveller_indicator,
        polbk.policy_bk,
        pol.POLICY_REFERENCE_NUMBER,
        pol.POLICY_STATUS,
        pol.RISK_INCEPTION_DATE,
        pol.RISK_EXPIRY_DATE,
        pol.SUM_INSURED_TOTAL,
        pol.PRODUCT_REFERENCE,
        prod.PRODUCT_NAME,
        prod.PRODUCT_CATEGORY,
        COALESCE(mc.claim_count, 0)   AS maximus_travel_claim_count,
        CASE WHEN t.travel_party_hkey IS NULL       THEN 'NO TRAVEL INVOLVEMENT'
             WHEN t.policy_hkey IS NOT NULL         THEN 'IN TRAVEL - POLICY LINKED'
             WHEN t.travel_system = 'OPUS_TRAVEL'   THEN 'IN TRAVEL - PARTY ONLY (Opus travel has no policy link)'
             ELSE                                        'IN TRAVEL - PARTY ONLY (no Maximus policy link)'
        END                           AS travel_flag
FROM    picked_partner pp
LEFT JOIN partner     p     ON p.partner_bk = pp.partner_bk
LEFT JOIN xref        x     ON x.partner_hkey = p.PARTY_HKEY
LEFT JOIN travel      t     ON t.travel_party_hkey = x.travel_party_hkey
LEFT JOIN party_bk    pb    ON pb.PARTY_HKEY = t.travel_party_hkey
LEFT JOIN opus_role   orl   ON orl.travel_party_hkey = t.travel_party_hkey AND t.travel_system = 'OPUS_TRAVEL'
LEFT JOIN mx_claim    mc    ON mc.travel_party_hkey = t.travel_party_hkey AND t.travel_system = 'MAXIMUS_TRAVEL'
LEFT JOIN policy_bk   polbk ON polbk.POLICY_HKEY = t.policy_hkey
LEFT JOIN pol               ON pol.POLICY_HKEY = t.policy_hkey
LEFT JOIN prod              ON prod.product_bk = pol.PRODUCT_REFERENCE
QUALIFY t.travel_party_hkey IS NOT NULL
     -- partner with no travel at all: keep one row so it still shows up
     OR ROW_NUMBER() OVER (PARTITION BY pp.partner_bk
                           ORDER BY IFF(t.travel_party_hkey IS NULL, 1, 0), x.match_method) = 1
ORDER BY pp.partner_bk, t.travel_system, pol.RISK_INCEPTION_DATE DESC;
