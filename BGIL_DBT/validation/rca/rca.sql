
-- FIX (same as item 27): override to_date past the source ldts, then the window
-- admits the future-dated rows:
--   dbt run --select sat_aug_kyc_party --full-refresh --vars '{"to_date": "2026-12-31"}'


-- =====================================================================
-- MAXIMUS DM-R2  |  LNK_PARTY_RELATIONSHIP  (sections 5 & 6)
-- Project: MAXIMUS. Link: LNK_PARTY_RELATIONSHIP, 178,191 rows.
-- RAW feed: BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY via
--   stg2_mp__pd_relparty -> hubfeed_party_relationship_lnk. Two FKs, both -> HUB_PARTY:
--     PARTY_HKEY         = MD5('HUB_PARTY|' || foreign_key)   (main party)
--     RELATED_PARTY_HKEY = MD5('HUB_PARTY|' || party_code)    (related party)
-- =====================================================================


-- =====================================================================
-- ITEM M-R2-5 : LNK_PARTY_RELATIONSHIP (b) orphan links (link FK -> hub)  [FAIL]
-- Recon result:
--   PARTY_HKEY          178,191 rows, 0 null, 0 orphan         -> PASS
--   RELATED_PARTY_HKEY  178,191 rows, 0 null, 178,188 orphan   -> FAIL
-- HYPOTHESIS: RELATED_PARTY_HKEY is derived from party_code, but NO party-hub feed
--   in hubfeed_party loads party_code as a party -- every feed keys HUB_PARTY on
--   foreign_key (even stg2_mp__pd_relparty contributes only the foreign_key side).
--   So the related-party side has no hub parent -> ~100% orphan. The primary side
--   (foreign_key) resolves fully. This is a MODELING GAP, not data/timing.
-- Before adding a hub feed for party_code, CONFIRM party_code is actually a party
--   (i.e. it appears as a known party key / foreign_key elsewhere). Run M-R2-5-a..f.
-- =====================================================================

-- M-R2-5-a : eyeball both keys in the related-party RAW view
select FOREIGN_KEY, PARTY_CODE, STAKE_CODE, count(*) as rows
from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY
group by 1,2,3
order by rows desc
limit 50;

-- M-R2-5-b : profile both keys (null %, distinct, range)
select
    count(*)                    as total_rows,
    count(FOREIGN_KEY)          as foreign_key_non_null,
    count(distinct FOREIGN_KEY) as foreign_key_distinct,
    count(PARTY_CODE)           as party_code_non_null,
    count(distinct PARTY_CODE)  as party_code_distinct,
    min(FOREIGN_KEY) as foreign_key_min, max(FOREIGN_KEY) as foreign_key_max,
    min(PARTY_CODE)  as party_code_min,  max(PARTY_CODE)  as party_code_max
from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY;

-- M-R2-5-c : DECISIVE -- do party_code values exist as a FOREIGN_KEY (a known party)
--            in the main party-detail view? high pct_matched => party_code IS a party.
with rp as (
    select distinct nullif(trim(to_varchar(PARTY_CODE)), '') as party_code
    from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY
    where nullif(trim(to_varchar(PARTY_CODE)), '') is not null
),
parties as (
    select distinct nullif(trim(to_varchar(FOREIGN_KEY)), '') as foreign_key
    from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
)
select
    count(*)                        as distinct_party_codes,
    count(p.foreign_key)            as matched_as_party,
    count(*) - count(p.foreign_key) as not_a_known_party,
    round(100 * count(p.foreign_key) / nullif(count(*),0), 1) as pct_matched
from rp
left join parties p on p.foreign_key = rp.party_code;

-- M-R2-5-d : cross-check party_code against the PARTY_RELATION view (2nd party defn)
with rp as (
    select distinct nullif(trim(to_varchar(PARTY_CODE)), '') as k
    from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY
    where nullif(trim(to_varchar(PARTY_CODE)), '') is not null
),
rel as (
    select distinct nullif(trim(to_varchar(FOREIGN_KEY)), '') as k
    from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_RELATION
    where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
)
select
    (select count(*) from rp)                                as distinct_party_codes,
    (select count(*) from rp where k in (select k from rel)) as matched_in_party_relation;

-- M-R2-5-e : recompute RELATED_PARTY_HKEY from RAW party_code, check vs HUB_PARTY
--            (reproduces the orphan count independent of the link table)
with rp as (
    select distinct
        MD5_BINARY(NULLIF(UPPER(TRIM(CAST('HUB_PARTY|' ||
            nullif(trim(to_varchar(PARTY_CODE)), '') AS VARCHAR))), '')) as related_party_hkey
    from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY
    where nullif(trim(to_varchar(PARTY_CODE)), '') is not null
)
select
    count(*)                        as distinct_related_party_keys,
    count(h.PARTY_HKEY)             as present_in_hub_party,
    count(*) - count(h.PARTY_HKEY)  as missing_from_hub_party
from rp
left join (select distinct PARTY_HKEY from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) h
       on h.PARTY_HKEY = rp.related_party_hkey;

-- M-R2-5-f : sanity -- same recompute for foreign_key -> PARTY_HKEY; expect ~100% present
with fk as (
    select distinct
        MD5_BINARY(NULLIF(UPPER(TRIM(CAST('HUB_PARTY|' ||
            nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR))), '')) as party_hkey
    from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY
    where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
)
select
    count(*)                        as distinct_party_keys,
    count(h.PARTY_HKEY)             as present_in_hub_party,
    count(*) - count(h.PARTY_HKEY)  as missing_from_hub_party
from fk
left join (select distinct PARTY_HKEY from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) h
       on h.PARTY_HKEY = fk.party_hkey;

-- RESULTS (run 2026-10-xx):
--   M-R2-5-a  FOREIGN_KEY looks like EMP11798 / EMP10712 (employee-style party IDs);
--             PARTY_CODE looks like 1001 / 1574 / 3216 (small numeric codes) + 'PP0001074'.
--             Different format, different cardinality -- not the same identifier space.
--   M-R2-5-b  total_rows 2,508,518; FOREIGN_KEY distinct 2,168,595;
--             PARTY_CODE distinct 3,163 (min '0000', max 'PP0001074').
--   M-R2-5-c  distinct_party_codes 3,163; matched_as_party 1; not_a_known_party 3,162;
--             pct_matched 0.0%.
--   M-R2-5-d  distinct_party_codes 3,163; matched_in_party_relation 0.
--   M-R2-5-e  distinct_related_party_keys 3,163; present_in_hub_party 2; missing ~3,161.
--   M-R2-5-f  distinct_party_keys 2,168,595; present_in_hub_party 2,168,595; missing 0.
--
-- CONCLUSION: PARTY_CODE is NOT a party.
--   * 0% of PARTY_CODE values appear as a known party key (M-R2-5-c/d); only 2 of 3,163
--     resolve in HUB_PARTY (M-R2-5-e) -- coincidental hash collisions, not real parents.
--   * The FOREIGN_KEY side resolves 100% (M-R2-5-f), proving the recompute method is
--     correct and the ~178k orphans are genuine, not a hashing/normalisation artifact.
--   * PARTY_CODE is a low-cardinality code (3,163 distinct, values like 1001 / PP0001074,
--     tied to STAKE_CODE BRANCH / DFLTSTKORG) -- a stakeholder/relationship/branch code,
--     NOT a person or organisation party.
--
-- FIX (do NOT load party_code into HUB_PARTY -- that would add ~3,161 fake parties):
--   The link LNK_PARTY_RELATIONSHIP models RELATED_PARTY_HKEY as a FK -> HUB_PARTY, but
--   party_code does not denote a HUB_PARTY member. The relationship is mis-modeled:
--     Option 1 (preferred): RELATED_PARTY_HKEY should point at the hub that party_code
--       actually belongs to (e.g. a stakeholder/branch/relationship-type hub). If no such
--       hub exists, party_code likely belongs as a satellite ATTRIBUTE of the relationship
--       (e.g. on SAT_LNK_PARTY_ROLE_CORE / a relationship sat), not as a hub FK.
--     Option 2: if the business rule is truly party-to-party, the RAW party_code column is
--       the wrong source for the related party -- confirm the correct related-party key
--       column with the mapper before re-deriving RELATED_PARTY_NK.
--   Either way the FIX is a MODEL/MAPPING change (modeler decision), and DM-R2's
--   RELATED_PARTY_HKEY -> HUB_PARTY check must be re-scoped once the target is corrected.
--   This is NOT a "missing hub feed" and NOT a data/timing issue.
-- =====================================================================


-- =====================================================================
-- ITEM M-R2-6 : LNK_PARTY_RELATIONSHIP (c) unexpected links (link -> RAW)  [INFO]
-- Recon result: 178,191 link rows, 8 unexpected (informational; not a pass gate).
-- An "unexpected" link = a vault link row whose (foreign_key, party_code)
--   relationship no longer round-trips to the current RAW view. Likely causes:
--   RAW churn/snapshot skew (relationship removed/changed after the link loaded),
--   NULLIF(UPPER(TRIM(...))) normalisation differences, or stale incremental rows.
-- Characterize the 8: pull them out of the link and check presence in RAW.
-- =====================================================================

-- NOTE: the RAW-side link hash is rebuilt with the SAME expression the DM-R2
--   generator uses (automate_dv 0.11.5 MD5_BINARY). Each key form is wrapped
--   individually in nullif(trim(to_varchar(col)),'') and joined with '||'; the
--   whole BK string is then UPPER/TRIM/NULLIF-normalised before MD5_BINARY.
--   Keep the parenthesis grouping exactly as below -- mismatched nesting is what
--   caused the earlier compile error.

-- M-R2-6-a : list the unexpected link rows (link row with no matching RAW relationship)
with src as (
    select distinct
        MD5_BINARY(NULLIF(UPPER(TRIM(CAST(
            'LNK_PARTY_RELATIONSHIP|'
            || ( nullif(trim(to_varchar(FOREIGN_KEY)), '')
                 || '||' ||
                 nullif(trim(to_varchar(PARTY_CODE)), '') )
            AS VARCHAR))), '')) as link_hkey
    from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY
    where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
      and nullif(trim(to_varchar(PARTY_CODE)),  '') is not null
)
select to_varchar(l.PARTY_RELATIONSHIP_HKEY, 'HEX') as link_hkey_hex,
       to_varchar(l.PARTY_HKEY, 'HEX')              as party_hkey_hex,
       to_varchar(l.RELATED_PARTY_HKEY, 'HEX')      as related_party_hkey_hex,
       l.RECORD_SOURCE,
       l.LOAD_DATETIME
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_PARTY_RELATIONSHIP l
left join src k on k.link_hkey = l.PARTY_RELATIONSHIP_HKEY
where startswith(l.RECORD_SOURCE, 'MAXIMUS_')
  and k.link_hkey is null
order by l.LOAD_DATETIME;

-- M-R2-6-b : count + ldts span of the unexpected rows vs the link's latest load
with src as (
    select distinct
        MD5_BINARY(NULLIF(UPPER(TRIM(CAST(
            'LNK_PARTY_RELATIONSHIP|'
            || ( nullif(trim(to_varchar(FOREIGN_KEY)), '')
                 || '||' ||
                 nullif(trim(to_varchar(PARTY_CODE)), '') )
            AS VARCHAR))), '')) as link_hkey
    from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY
    where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
      and nullif(trim(to_varchar(PARTY_CODE)),  '') is not null
)
select
    count(*)                                                        as link_rows,
    count_if(k.link_hkey is null)                                   as unexpected_links,
    min(case when k.link_hkey is null then l.LOAD_DATETIME end)     as min_unexpected_ldts,
    max(case when k.link_hkey is null then l.LOAD_DATETIME end)     as max_unexpected_ldts,
    max(l.LOAD_DATETIME)                                            as link_max_ldts
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_PARTY_RELATIONSHIP l
left join src k on k.link_hkey = l.PARTY_RELATIONSHIP_HKEY
where startswith(l.RECORD_SOURCE, 'MAXIMUS_');

-- INTERPRETATION: 8 / 178,191 is tiny and informational. If M-R2-6-a shows the
--   pairs are simply gone from RAW (removed/changed), record as "legacy/removed RAW
--   relationships" in sign-off -- no code fix. Only revisit if the count grows or
--   the pairs still exist in RAW (which would indicate a normalisation mismatch).
-- =====================================================================
