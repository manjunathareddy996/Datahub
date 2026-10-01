/* =====================================================================================
   DM-K4  |  Key checks  |  "Business key uniqueness"
   Sign-off: No duplicate business keys within a hub (hub grain integrity).
   Method:   group the hub by its hash key; a hub row-count must equal the number of
             distinct business keys. Any hash key that appears more than once is a
             grain violation.
   Pass:     0 rows returned (hub row count = distinct business keys).

   Scope:    runs entirely against the HUB tables -- no raw source needed. The hub is a
             shared, HKEY-deduplicated table (maximus + opus + partner_dv write it), so a
             correctly-built hub has exactly ONE row per hash key regardless of loader.
             A duplicate here is a genuine integrity defect.

   Fully-qualified names:
     Vault (both projects) : BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL

   Each query returns the offending hash key, its business key(s), and the row count.
   A clean hub returns no rows. Interpreting a returned row:
     - row_count > 1 with distinct_bk = 1 : the SAME business key is stored more than once
       (true duplicate / grain break -- the hub load failed to deduplicate).
     - row_count > 1 with distinct_bk > 1 : two DIFFERENT business keys produced the SAME
       hash key (a hash collision -- rare, but a serious key-integrity defect).
   ===================================================================================== */


/* =====================================================================================
   HUB tables shared by MAXIMUS + OPUS (+ partner_dv). Grain = one row per hash key.
   Columns:  <HKEY> = hash key (BINARY(16)),  PARENT_BK / <ENTITY>_BK = business key.
   ===================================================================================== */

----------------------------------------------------------------------------------------
-- HUB_PARTY   (hash key PARTY_HKEY, business key PARENT_BK)
----------------------------------------------------------------------------------------
select 'HUB_PARTY' as hub, PARTY_HKEY as hash_key,
       count(*) as row_count, count(distinct PARENT_BK) as distinct_bk,
       min(PARENT_BK) as sample_bk
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
 group by PARTY_HKEY
having count(*) > 1
 order by row_count desc;


----------------------------------------------------------------------------------------
-- HUB_STAKE_CODE   (hash key STAKE_CODE_HKEY, business key STAKE_CODE_BK)
----------------------------------------------------------------------------------------
select 'HUB_STAKE_CODE' as hub, STAKE_CODE_HKEY as hash_key,
       count(*) as row_count, count(distinct STAKE_CODE_BK) as distinct_bk,
       min(STAKE_CODE_BK) as sample_bk
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_STAKE_CODE
 group by STAKE_CODE_HKEY
having count(*) > 1
 order by row_count desc;


----------------------------------------------------------------------------------------
-- HUB_LOCATION   (hash key LOCATION_HKEY, business key PARENT_BK)
----------------------------------------------------------------------------------------
select 'HUB_LOCATION' as hub, LOCATION_HKEY as hash_key,
       count(*) as row_count, count(distinct PARENT_BK) as distinct_bk,
       min(PARENT_BK) as sample_bk
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOCATION
 group by LOCATION_HKEY
having count(*) > 1
 order by row_count desc;


----------------------------------------------------------------------------------------
-- HUB_PAYMENT_INSTRUMENT   (hash key PAYMENT_INSTRUMENT_HKEY, business key PARENT_BK)
----------------------------------------------------------------------------------------
select 'HUB_PAYMENT_INSTRUMENT' as hub, PAYMENT_INSTRUMENT_HKEY as hash_key,
       count(*) as row_count, count(distinct PARENT_BK) as distinct_bk,
       min(PARENT_BK) as sample_bk
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PAYMENT_INSTRUMENT
 group by PAYMENT_INSTRUMENT_HKEY
having count(*) > 1
 order by row_count desc;


----------------------------------------------------------------------------------------
-- HUB_PRODUCT   (hash key PRODUCT_HKEY, business key PARENT_BK)
----------------------------------------------------------------------------------------
select 'HUB_PRODUCT' as hub, PRODUCT_HKEY as hash_key,
       count(*) as row_count, count(distinct PARENT_BK) as distinct_bk,
       min(PARENT_BK) as sample_bk
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PRODUCT
 group by PRODUCT_HKEY
having count(*) > 1
 order by row_count desc;


----------------------------------------------------------------------------------------
-- HUB_FINANCIAL_ACCOUNT   (hash key FINANCIAL_ACCOUNT_HKEY, business key PARENT_BK)
----------------------------------------------------------------------------------------
select 'HUB_FINANCIAL_ACCOUNT' as hub, FINANCIAL_ACCOUNT_HKEY as hash_key,
       count(*) as row_count, count(distinct PARENT_BK) as distinct_bk,
       min(PARENT_BK) as sample_bk
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_FINANCIAL_ACCOUNT
 group by FINANCIAL_ACCOUNT_HKEY
having count(*) > 1
 order by row_count desc;


----------------------------------------------------------------------------------------
-- HUB_DOCUMENT   (hash key DOCUMENT_HKEY, business key PARENT_BK)
----------------------------------------------------------------------------------------
select 'HUB_DOCUMENT' as hub, DOCUMENT_HKEY as hash_key,
       count(*) as row_count, count(distinct PARENT_BK) as distinct_bk,
       min(PARENT_BK) as sample_bk
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DOCUMENT
 group by DOCUMENT_HKEY
having count(*) > 1
 order by row_count desc;


----------------------------------------------------------------------------------------
-- HUB_POLICY   (hash key POLICY_HKEY, business key PARENT_BK)
----------------------------------------------------------------------------------------
select 'HUB_POLICY' as hub, POLICY_HKEY as hash_key,
       count(*) as row_count, count(distinct PARENT_BK) as distinct_bk,
       min(PARENT_BK) as sample_bk
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY
 group by POLICY_HKEY
having count(*) > 1
 order by row_count desc;


----------------------------------------------------------------------------------------
-- HUB_DISTRIBUTION_CHANNEL   (hash key DISTRIBUTION_CHANNEL_HKEY, business key PARENT_BK)
----------------------------------------------------------------------------------------
select 'HUB_DISTRIBUTION_CHANNEL' as hub, DISTRIBUTION_CHANNEL_HKEY as hash_key,
       count(*) as row_count, count(distinct PARENT_BK) as distinct_bk,
       min(PARENT_BK) as sample_bk
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DISTRIBUTION_CHANNEL
 group by DISTRIBUTION_CHANNEL_HKEY
having count(*) > 1
 order by row_count desc;


----------------------------------------------------------------------------------------
-- HUB_ORG_UNIT   (hash key ORG_UNIT_HKEY, business key PARENT_BK)
----------------------------------------------------------------------------------------
select 'HUB_ORG_UNIT' as hub, ORG_UNIT_HKEY as hash_key,
       count(*) as row_count, count(distinct PARENT_BK) as distinct_bk,
       min(PARENT_BK) as sample_bk
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_ORG_UNIT
 group by ORG_UNIT_HKEY
having count(*) > 1
 order by row_count desc;


----------------------------------------------------------------------------------------
-- HUB_AGENT   (hash key AGENT_HKEY, business key PARENT_BK)   [OPUS vault]
----------------------------------------------------------------------------------------
select 'HUB_AGENT' as hub, AGENT_HKEY as hash_key,
       count(*) as row_count, count(distinct PARENT_BK) as distinct_bk,
       min(PARENT_BK) as sample_bk
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_AGENT
 group by AGENT_HKEY
having count(*) > 1
 order by row_count desc;


----------------------------------------------------------------------------------------
-- HUB_AGREEMENT   (hash key AGREEMENT_HKEY, business key PARENT_BK)   [OPUS vault]
----------------------------------------------------------------------------------------
select 'HUB_AGREEMENT' as hub, AGREEMENT_HKEY as hash_key,
       count(*) as row_count, count(distinct PARENT_BK) as distinct_bk,
       min(PARENT_BK) as sample_bk
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_AGREEMENT
 group by AGREEMENT_HKEY
having count(*) > 1
 order by row_count desc;


----------------------------------------------------------------------------------------
-- HUB_CLAIM   (hash key CLAIM_HKEY, business key PARENT_BK)   [OPUS vault]
----------------------------------------------------------------------------------------
select 'HUB_CLAIM' as hub, CLAIM_HKEY as hash_key,
       count(*) as row_count, count(distinct PARENT_BK) as distinct_bk,
       min(PARENT_BK) as sample_bk
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_CLAIM
 group by CLAIM_HKEY
having count(*) > 1
 order by row_count desc;


----------------------------------------------------------------------------------------
-- HUB_RISK_OBJECT   (hash key RISK_OBJECT_HKEY, business key PARENT_BK)   [OPUS vault]
----------------------------------------------------------------------------------------
select 'HUB_RISK_OBJECT' as hub, RISK_OBJECT_HKEY as hash_key,
       count(*) as row_count, count(distinct PARENT_BK) as distinct_bk,
       min(PARENT_BK) as sample_bk
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_RISK_OBJECT
 group by RISK_OBJECT_HKEY
having count(*) > 1
 order by row_count desc;
