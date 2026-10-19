

-- =====================================================================
-- ITEM 15 : SAT_LNK_ROLE_AGENT (BJAZ_INTERMEDIARY) - 254 orphans remain.
-- Satellite keys HUB_PARTY on intermediary_id, but ratified key is partner_id.
-- Compare: how many rows resolve under intermediary_id vs under partner_id?
-- =====================================================================
with p as (
    select distinct PARTY_HKEY as k
    from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
)
select
    count(*) as rows_checked,
    -- current keying: intermediary_id
    count_if(md5(('HUB_PARTY|' || intermediary_id)) is not null
             and (select max(1) from p where p.k = TO_BINARY(md5(('HUB_PARTY|' || intermediary_id)),'HEX')) is null) as orphans_on_intermediary_id,
    count(distinct intermediary_id) as distinct_intermediary_id,
    count(distinct partner_id)      as distinct_partner_id,
    count_if(partner_id is null)    as null_partner_id,
    count_if(intermediary_id is null) as null_intermediary_id
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__bjaz_intermediary;

-- Simpler check: do intermediary_id and partner_id differ on this table?
select count(*) as rows_,
       count_if(intermediary_id = partner_id) as same,
       count_if(intermediary_id <> partner_id) as different,
       count_if(partner_id is null) as partner_id_null
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__bjaz_intermediary;


-- =====================================================================
-- ITEM 16 : SAT_LNK_ROLE_CUSTOMER (CLM_INTERESTED_PARTIES) - 4 orphans.
-- Satellite keys HUB_PARTY on 'claimant' (a ratified HUB_PARTY key per
-- mapper docs: CLM_INTERESTED_PARTIES verified on PART_ID / CLAIMANT).
-- Only 4 rows orphan -> inspect the 4 claimant values: null/blank? present
-- in cp_partners master? present as part_id elsewhere?
-- =====================================================================
with p as (
    select distinct PARTY_HKEY as k
    from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
),
cp as (
    select distinct part_id as id
    from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__cp_partners
    where part_id is not null
)
select s.claimant,
       count(*) as rows_,
       max(iff(cp.id is null, 'NOT_IN_CP', 'IN_CP')) as in_cp_master
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__clm_interested_parties s
left join cp on cp.id = s.claimant
left join p  on p.k = TO_BINARY(md5('HUB_PARTY|' || s.claimant), 'HEX')
where p.k is null            -- orphans only
  and s.claimant is not null
group by s.claimant
order by rows_ desc;


-- =====================================================================
-- ITEM 16 (post-fix) : SAT_LNK_ROLE_CUSTOMER now keyed on part_id.
-- 15 orphans remain -> which part_id values are missing from HUB_PARTY,
-- and are they present in the cp_partners master?
-- =====================================================================
with p as (
    select distinct PARTY_HKEY as k
    from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
),
cp as (
    select distinct part_id as id
    from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__cp_partners
    where part_id is not null
)
select s.part_id,
       count(*) as rows_,
       max(iff(cp.id is null, 'NOT_IN_CP', 'IN_CP')) as in_cp_master
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__clm_interested_parties s
left join cp on cp.id = s.part_id
left join p  on p.k = TO_BINARY(md5('HUB_PARTY|' || s.part_id), 'HEX')
where p.k is null
  and s.part_id is not null
group by s.part_id
order by rows_ desc;


-- =====================================================================
-- ITEM 17 : SAT_LNK_ROLE_NOMINEE_BENEFICIARY (HUB_PARTY grain, partner_id).
-- Recon (DM-R1 section 17) FAILs on two record sources:
--   OPUS_BJAZ_HCF_MEMBER_DTLS   : 370,896 orphan rows / 362,587 orphan keys
--   OPUS_BJAZ_CTNGY_GC_MEM_DATA : 1 orphan row / 1 orphan key
-- Both stg2 models key HUB_PARTY on NK 'HUB_PARTY|' || partner_id. HUB_PARTY is
-- loaded from CP_PARTNERS (authoritative part_id) + AZBJ_PARTNER_EXTN +
-- BJAZ_INTERMEDIARY + KYC feeds -- NOT from these member tables. So the question
-- is: are the orphan partner_id values present in the CP_PARTNERS master?
-- =====================================================================

-- 17a. HCF_MEMBER_DTLS -- orphan partner_id values: present in cp_partners master?
--      (large source: aggregate, do not list every key)
with p as (
    select distinct PARTY_HKEY as k
    from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
),
cp as (
    select distinct part_id as id
    from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__cp_partners
    where part_id is not null
)
select
    count(*)                                   as rows_checked,
    count_if(s.partner_id is null)             as null_partner_id,
    count_if(p.k is null)                      as orphan_rows,
    count(distinct iff(p.k is null, s.partner_id, null)) as orphan_keys,
    count(distinct iff(p.k is null and cp.id is not null, s.partner_id, null)) as orphan_keys_in_cp_master,
    count(distinct iff(p.k is null and cp.id is null,     s.partner_id, null)) as orphan_keys_not_in_cp_master
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__bjaz_hcf_member_dtls s
left join cp on cp.id = s.partner_id
left join p  on p.k  = TO_BINARY(md5('HUB_PARTY|' || s.partner_id), 'HEX');

-- 17b. CTNGY_GC_MEM_DATA -- the single orphan partner_id: null/blank? in cp master?
with p as (
    select distinct PARTY_HKEY as k
    from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
),
cp as (
    select distinct part_id as id
    from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__cp_partners
    where part_id is not null
)
select s.partner_id,
       count(*) as rows_,
       max(iff(cp.id is null, 'NOT_IN_CP', 'IN_CP')) as in_cp_master
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__bjaz_ctngy_gc_mem_data s
left join cp on cp.id = s.partner_id
left join p  on p.k = TO_BINARY(md5('HUB_PARTY|' || s.partner_id), 'HEX')
where p.k is null
group by s.partner_id
order by rows_ desc;


-- =====================================================================
-- ITEM 17 (confirmed) : the orphan partner_id is '494049720.0000000000'.
-- Native PARTNER_ID is NUMBER(_,10) in the member tables, so ::varchar renders
-- a trailing '.0000000000'. CP_PARTNERS.PART_ID casts to a clean integer string,
-- so 'HUB_PARTY|' || partner_id never matches the hub NK. Not missing parties --
-- a numeric-formatting mismatch. Re-test HCF orphans after stripping '.0*':
-- all should resolve.
-- =====================================================================
with p as (
    select distinct PARTY_HKEY as k
    from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
)
select
    count(*)                                                          as rows_checked,
    count_if(p_raw.k is null)                                         as orphans_raw,       -- current keying
    count_if(p_fix.k is null)                                         as orphans_normalized -- after stripping trailing .0*
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__bjaz_hcf_member_dtls s
left join p p_raw on p_raw.k = TO_BINARY(md5('HUB_PARTY|' || s.partner_id), 'HEX')
left join p p_fix on p_fix.k = TO_BINARY(md5('HUB_PARTY|' || regexp_replace(s.partner_id, '\\.0+$', '')), 'HEX')
where s.partner_id is not null;


-- =====================================================================
-- ITEM 18 : SAT_LNK_ROLE_PROVIDER (BJAZ_HM_HOSPITAL_MASTER) - 76,478 orphans.
-- The satellite keys HUB_PARTY on 'HUB_PARTY|' || hosid (hospital id), but:
--   (a) the hospital HUB_PARTY branch stg2_hub_bjaz_hm_hospital_master__party
--       is NOT listed in hub_party.sql's source_model (never loaded), and
--   (b) that branch keys on partner_id, not hosid -- so even if wired it would
--       not match the hosid-keyed satellites.
-- CLM_SUPPLIERS passes because it keys on part_id (a real cp_partners key).
-- Confirm: do hosid-derived keys exist in HUB_PARTY at all, and would wiring a
-- hosid-keyed hub branch resolve them?
-- =====================================================================
with p as (
    select distinct PARTY_HKEY as k
    from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
)
select
    count(*)                                                  as rows_checked,
    count_if(s.hosid is null)                                 as null_hosid,
    count(distinct s.hosid)                                   as distinct_hosid,
    count_if(p.k is null)                                     as orphans_on_hosid,          -- current (hosid) keying
    count(distinct iff(p.k is null, s.hosid, null))           as orphan_keys_on_hosid
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__bjaz_hm_hospital_master s
left join p on p.k = TO_BINARY(md5('HUB_PARTY|' || s.hosid), 'HEX')
where s.hosid is not null;


-- =====================================================================
-- ITEM 19 : SAT_LNK_ROLE_SURVEYOR (BJAZ_CLM_SUPP_EXTN) - 1 orphan of 298,600.
-- Keys HUB_PARTY on 'HUB_PARTY|' || partner_id. Single orphan -> inspect the one
-- partner_id: is it the item-17 NUMBER '.0' artifact, blank, or genuinely absent
-- from the cp_partners master?
-- =====================================================================
with p as (
    select distinct PARTY_HKEY as k
    from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
),
cp as (
    select distinct part_id as id
    from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__cp_partners
    where part_id is not null
)
select s.partner_id,
       count(*) as rows_,
       max(iff(cp.id is null, 'NOT_IN_CP', 'IN_CP')) as in_cp_master,
       -- would stripping a trailing '.0*' resolve it? (item-17 style)
       max(iff(cp2.id is null, 'STILL_NOT_IN_CP', 'IN_CP_AFTER_STRIP')) as in_cp_after_strip
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__bjaz_clm_supp_extn s
left join cp  on cp.id  = s.partner_id
left join cp  cp2 on cp2.id = regexp_replace(s.partner_id, '\\.0+$', '')
left join p   on p.k   = TO_BINARY(md5('HUB_PARTY|' || s.partner_id), 'HEX')
where p.k is null
  and s.partner_id is not null
group by s.partner_id
order by rows_ desc;


-- =====================================================================
-- ITEM 22 : SAT_PARTY_CLAIM_HISTORY (stitch-backed, HUB_PARTY grain).
-- Recon (DM-R1 section 22) FAILs only on OPUS_BJAZ_HCF_MEMBER_DTLS:
--   362,587 orphan rows / 362,587 orphan keys (100% of the HCF branch).
--   OPUS_BJAZ_HM_MEMBER_DTLS passes.
-- Both branches key HUB_PARTY on 'HUB_PARTY|' || partner_id (stitch
-- key_column=partner_id for t1=HCF and t3=HM) -- identical logic. HCF is the
-- same table as item 17, whose PARTNER_ID is a scaled NUMBER rendering the
-- '.0000000000' artifact; the orphan count equals item 17's distinct-key count
-- (362,587). So this is the SAME root cause as item 17, surfacing through the
-- stitch path. The item-17 staging fix (to_number(_,38,0)) already covers it;
-- SAT_PARTY_CLAIM_HISTORY (incremental/append) just needs a --full-refresh.
-- Confirm: raw-keyed orphans vs normalized-key orphans on the HCF branch.
-- =====================================================================
with p as (
    select distinct PARTY_HKEY as k
    from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
)
select
    count(*)                                                 as rows_checked,
    count_if(s.partner_id is null)                           as null_partner_id,
    count_if(p_raw.k is null)                                as orphans_raw,        -- 'HUB_PARTY|' || partner_id  (pre-fix)
    count_if(p_fix.k is null)                                as orphans_normalized  -- after stripping trailing .0*  (post-fix)
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__bjaz_hcf_member_dtls s
left join p p_raw on p_raw.k = TO_BINARY(md5('HUB_PARTY|' || s.partner_id), 'HEX')
left join p p_fix on p_fix.k = TO_BINARY(md5('HUB_PARTY|' || regexp_replace(s.partner_id, '\\.0+$', '')), 'HEX')
where s.partner_id is not null;


-- =====================================================================
-- ITEM 23 : SAT_PARTY_CONTACT_ADDRESS_LINK (parent LNK_PARTY_LOCATION).
-- Recon (DM-R1 section 23) FAILs 100% on two record sources:
--   OPUS_BJAZ_CP_ADDRESS_LINK      : 2,312,234 orphan rows / 2,271,195 keys
--   OPUS_BJAZ_T_CKYC_PERSONAL_DTLS :    90,402 orphan rows /    42,454 keys
-- The satellite PARTY_LOCATION_HKEY uses the SAME formula + SAME source as the
-- link feed (stg2_link_bjaz_cp_address_link__party_location):
--   'LNK_PARTY_LOCATION|' || part_id || '|' || add_id
-- So keying is not the issue -- a 100% orphan means the link simply doesn't hold
-- those keys. LNK_PARTY_LOCATION is incremental; most likely the cp_address_link
-- / ckyc feeds were added to the link AFTER its last load, so the sat rows have
-- no parent yet. Confirm: do the sat keys exist in the link at all, and does
-- re-deriving from the link feed resolve them?
-- =====================================================================

-- 23a. CP_ADDRESS_LINK -- sat keys present in LNK_PARTY_LOCATION? vs present in the link FEED view?
with lnk as (
    select distinct PARTY_LOCATION_HKEY as k
    from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_PARTY_LOCATION
),
feed as (  -- the link's own stage view for this table (what SHOULD be in the link)
    select distinct PARTY_LOCATION_HKEY as k
    from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_link_bjaz_cp_address_link__party_location
)
select
    count(*)                                   as feed_rows,
    count_if(lnk.k is null)                    as feed_keys_missing_from_link,   -- link never loaded them
    count_if(lnk.k is not null)                as feed_keys_present_in_link
from feed
left join lnk on lnk.k = feed.k;

-- 23b. same question for the CKYC correspondence + permanent feeds
with lnk as (
    select distinct PARTY_LOCATION_HKEY as k
    from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_PARTY_LOCATION
)
select 'correspondence' as feed, count(*) as feed_rows,
       count_if(lnk.k is null) as missing_from_link
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_link_bjaz_t_ckyc_personal_dtls__party_location__correspondence f
  left join lnk on lnk.k = f.PARTY_LOCATION_HKEY
 group by 1
union all
select 'permanent' as feed, count(*) as feed_rows,
       count_if(lnk.k is null) as missing_from_link
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_link_bjaz_t_ckyc_personal_dtls__party_location__permanent f
  left join lnk on lnk.k = f.PARTY_LOCATION_HKEY
 group by 1;


-- =====================================================================
-- ITEM 27 : SAT_PARTY_HEALTH_PROFILE (stitch-backed, HUB_PARTY grain).
-- Recon (DM-R1 section 27) FAILs only on OPUS_BJAZ_HCF_MEMBER_DTLS:
--   362,587 orphan rows / 362,587 keys. The two KYC feeds pass.
-- stitch_party_health_profile keys the HCF branch (t1) on partner_id -- same
-- table, same count, same item-17 '.0000000000' NUMBER root cause as items 17
-- and 22. The staging fix (to_number(_,38,0)) already covers it; the satellite
-- (incremental/append) needs a --full-refresh to flush stale orphan rows.
-- Confirm raw vs normalized orphans on the HCF branch:
-- =====================================================================
with p as (
    select distinct PARTY_HKEY as k
    from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
)
select
    count(*)                             as rows_checked,
    count_if(s.partner_id is null)       as null_partner_id,
    count_if(p_raw.k is null)            as orphans_raw,
    count_if(p_fix.k is null)            as orphans_normalized
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__bjaz_hcf_member_dtls s
left join p p_raw on p_raw.k = TO_BINARY(md5('HUB_PARTY|' || s.partner_id), 'HEX')
left join p p_fix on p_fix.k = TO_BINARY(md5('HUB_PARTY|' || regexp_replace(s.partner_id, '\\.0+$', '')), 'HEX')
where s.partner_id is not null;


-- =====================================================================
-- ITEM 27 (follow-up) : --full-refresh ran but stitch_party_health_profile
-- returns 0 rows. This is NOT a keying issue -- it is a watermark deadlock in
-- the stitch_incremental macro. Trace top-down, layer by layer.
--
-- Mechanism (stitch_incremental, target_sat='sat_party_health_profile'):
--   affected_keys filters sources to  from_date < inc_job_updated_at <= to_date
--   from_date = MAX(DBT_RUN_TS) of the target sat WHERE RECORD_SOURCE LIKE 'OPUS_%'.
-- The sat already holds stale rows with a recent DBT_RUN_TS, while every source
-- row's inc_job_updated_at is OLDER than that watermark -> affected_keys empty ->
-- stitch emits 0 -> sat never reloads. The stitch is a VIEW, so --full-refresh
-- does not reset this; the window must be forced via var('from_date').
-- =====================================================================

-- 27-L1 (TOP: satellite) -- what watermark is gating the stitch? (MAX DBT_RUN_TS per system)
select 'sat_party_health_profile' as model,
       count(*) as sat_rows,
       count_if(RECORD_SOURCE like 'OPUS_%') as opus_rows,
       max(iff(RECORD_SOURCE like 'OPUS_%', DBT_RUN_TS, null)) as opus_max_dbt_run_ts  -- == from_date the macro computes
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_HEALTH_PROFILE;

-- 27-L2 (MIDDLE: stitch view) -- does the view return anything right now, and across what ldts range?
select 'stitch_party_health_profile' as model,
       count(*) as stitch_rows,
       min(inc_job_updated_at) as min_ldts,
       max(inc_job_updated_at) as max_ldts
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stitch_party_health_profile;

-- 27-L3 (BOTTOM: source staging) -- the source ldts range the window must cover.
-- If max(inc_job_updated_at) here is <= the L1 watermark, affected_keys is empty.
select 'stg_partner__bjaz_hcf_member_dtls' as model,
       count(*) as src_rows,
       count_if(partner_id is not null) as keyed_rows,
       min(inc_job_updated_at) as min_ldts,
       max(inc_job_updated_at) as max_ldts
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__bjaz_hcf_member_dtls;

-- 27-L4 (CONFIRM the deadlock) -- rows the stitch WOULD emit under the live watermark
-- vs under a forced sentinel from_date. If live=0 and forced>0, the watermark is the cause.
with wm as (
    select coalesce(max(iff(RECORD_SOURCE like 'OPUS_%', DBT_RUN_TS, null)),
                    to_timestamp_ntz('1900-01-01')) as from_date_live
    from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_HEALTH_PROFILE
)
select
    (select count(distinct partner_id)
       from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__bjaz_hcf_member_dtls s, wm
      where s.partner_id is not null
        and s.inc_job_updated_at >  wm.from_date_live) as keys_under_live_watermark,
    (select count(distinct partner_id)
       from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__bjaz_hcf_member_dtls s
      where s.partner_id is not null
        and s.inc_job_updated_at >  to_timestamp_ntz('1900-01-01')) as keys_under_sentinel;


-- =====================================================================
-- ITEM 27 (correction) : the watermark-deadlock theory is WRONG.
-- RCA results:
--   L1 sat_party_health_profile      : 0 rows, opus_max_dbt_run_ts = NULL
--                                      (full-refresh already emptied it -> from_date
--                                       falls back to the 1900 sentinel; no watermark gate)
--   L2 stitch_party_health_profile   : 0 rows
--   L3 stg_partner__bjaz_hcf_member_dtls : 728,494 rows, ALL keyed,
--                                      min_ldts = max_ldts = 2026-09-30 04:11:41.399
--   L4 keys_under_live = keys_under_sentinel = 362,587 (identical; lower bound is fine)
--
-- The lower bound is not the problem. The source inc_job_updated_at is 2026-09-30,
-- a FUTURE timestamp vs the run clock. affected_keys also requires
--   inc_job_updated_at <= to_date,  to_date = run_started_at (UTC) -> IST ("now").
-- If 2026-09-30 > now, EVERY row fails the UPPER bound -> affected_keys empty ->
-- stitch 0. L4 only tested the lower bound, which is why it looked clean.
-- Confirm the upper-bound exclusion:
-- =====================================================================
select
    current_timestamp()                                                   as clock_now,
    cast(convert_timezone('UTC','Asia/Kolkata', current_timestamp()::timestamp_ntz) as timestamp_ntz) as to_date_ist_approx,
    min(s.inc_job_updated_at)                                             as src_min_ldts,
    max(s.inc_job_updated_at)                                             as src_max_ldts,
    count_if(s.inc_job_updated_at >  cast(convert_timezone('UTC','Asia/Kolkata', current_timestamp()::timestamp_ntz) as timestamp_ntz)) as rows_ABOVE_to_date,  -- excluded by upper bound
    count_if(s.inc_job_updated_at <= cast(convert_timezone('UTC','Asia/Kolkata', current_timestamp()::timestamp_ntz) as timestamp_ntz)) as rows_within_window
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__bjaz_hcf_member_dtls s
where s.partner_id is not null;


-- =====================================================================
-- ITEM 27 (both bounds) : individually each bound passes all rows, but the macro
-- applies BOTH together with the SAME from_date/to_date it computed at run time.
-- Reproduce affected_keys EXACTLY (sentinel from_date, since the sat was empty;
-- to_date = run clock in IST) with both predicates at once.
-- =====================================================================
with bounds as (
    select to_timestamp_ntz('1900-01-01') as from_date,  -- sat empty -> sentinel
           cast(convert_timezone('UTC','Asia/Kolkata', current_timestamp()::timestamp_ntz) as timestamp_ntz) as to_date
)
select
    (select from_date from bounds) as from_date,
    (select to_date   from bounds) as to_date,
    count(*)                       as src_rows,
    count_if(s.inc_job_updated_at >  (select from_date from bounds)
         and s.inc_job_updated_at <= (select to_date   from bounds)) as rows_in_affected_keys
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__bjaz_hcf_member_dtls s
where s.partner_id is not null;

-- 27 (direct) : bypass all theories -- just query the stitch view's affected_keys
-- outcome by selecting straight from the compiled view. If this > 0 now but the
-- --full-refresh produced 0, the run used a DIFFERENT clock (run_started_at) than now.
-- Compare the view's live row count to the to_date used at build time.
select count(*) as stitch_rows_now,
       min(inc_job_updated_at) as mn,
       max(inc_job_updated_at) as mx
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stitch_party_health_profile;


-- =====================================================================
-- ITEM 27 (RESOLVED) : confirmed by the two checks above --
--   stitch_rows_now        = 0   (compiled view, baked to_date)
--   rows_in_affected_keys  > 0   (live clock, same source data)
--
-- ROOT CAUSE (top-down, confirmed):
--   1. sat_party_health_profile was emptied by --full-refresh -> from_date = 1900
--      sentinel, so the LOWER bound execludes nothing.
--   2. Every source row (stg_partner__bjaz_hcf_member_dtls) carries
--      inc_job_updated_at = 2026-09-30, and ALL columns are keyed.
--   3. stitch_incremental renders to_date as a CONSTANT literal baked into the
--      stitch VIEW DDL at build time, from run_started_at (-> IST). The
--      --full-refresh run's clock was EARLIER than 2026-09-30, so the baked
--      upper bound (inc_job_updated_at <= to_date) excludes 100% of rows.
--   4. Because to_date is a frozen literal in the view, re-querying the view today
--      still returns 0 -- the stale bound travels with the DDL until rebuilt.
--   => NOT keying, NOT a watermark deadlock, NOT the lower bound. It is the baked
--      to_date upper bound vs future-dated source ldts (2026-09-30).
--
-- FIX: rebuild the stitch + sat with an explicit to_date past the source ldts, so
--      the baked upper bound includes the 2026-09-30 rows:
--   dbt run --select stitch_party_health_profile sat_party_health_profile \
--           --full-refresh --vars '{"to_date": "2026-12-31"}'
--
-- NOTE (data quality): source inc_job_updated_at = 2026-09-30 is future-dated
--   relative to the load clock. Any incremental stitch will silently drop these
--   rows whenever run_started_at < the source ldts. Flag the raw feed's ldts.
-- =====================================================================


-- =====================================================================
-- ITEM 28 : SAT_PARTY_IDENTIFICATION (sat_multi_source, 19 feeds, HUB_PARTY grain).
-- Recon collapses all feeds to RECORD_SOURCE='OPUS': 22,639,759 rows, 439,319
-- orphans. The recon can't say WHICH feed orphans, so attribute per feed at the
-- stg2 level: anti-join each feed's PARTY_HKEY to HUB_PARTY.
-- Known-risk feeds by key:
--   hm_hospital_master -> hosid   (item 18: hub branch unwired -> expect orphans)
--   hcf_member_dtls    -> partner_id (item 17: fixed; 0 if rebuilt)
--   bjaz_intermediary  -> intermediary_id (item 15: ratified key is partner_id)
--   KYC feeds          -> subject forms (LICENCE:/PAN:/... -> KYC hub feeds)
-- =====================================================================
with p as (
    select distinct PARTY_HKEY as k
    from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
)
select feed, sat_rows, orphan_rows
from (
    select 'hm_hospital_master' as feed, count(*) as sat_rows, count_if(p.k is null) as orphan_rows
      from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_bjaz_hm_hospital_master__party_identification s
      left join p on p.k = s.PARTY_HKEY group by 1
    union all
    select 'hcf_member_dtls', count(*), count_if(p.k is null)
      from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_bjaz_hcf_member_dtls__party_identification s
      left join p on p.k = s.PARTY_HKEY group by 1
    union all
    select 'bjaz_intermediary', count(*), count_if(p.k is null)
      from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_bjaz_intermediary__party_identification s
      left join p on p.k = s.PARTY_HKEY group by 1
    union all
    select 'clm_supp_extn', count(*), count_if(p.k is null)
      from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_bjaz_clm_supp_extn__party_identification s
      left join p on p.k = s.PARTY_HKEY group by 1
    union all
    select 'ctngy_pa_mem_dtls', count(*), count_if(p.k is null)
      from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_bjaz_ctngy_pa_mem_dtls__party_identification s
      left join p on p.k = s.PARTY_HKEY group by 1
    union all
    select 'ctngy_ff_dtls_extn', count(*), count_if(p.k is null)
      from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_bjaz_ctngy_ff_dtls_extn__party_identification s
      left join p on p.k = s.PARTY_HKEY group by 1
    union all
    select 'ec_mem_dtls_extn', count(*), count_if(p.k is null)
      from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_bjaz_ec_mem_dtls_extn__party_identification s
      left join p on p.k = s.PARTY_HKEY group by 1
    union all
    select 'hlt_ensure_mem_dtls', count(*), count_if(p.k is null)
      from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_bjaz_hlt_ensure_mem_dtls__party_identification s
      left join p on p.k = s.PARTY_HKEY group by 1
    union all
    select 'starpkg_ff_dtls', count(*), count_if(p.k is null)
      from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_bjaz_starpkg_ff_dtls__party_identification s
      left join p on p.k = s.PARTY_HKEY group by 1
    union all
    select 'azbj_partner_extn', count(*), count_if(p.k is null)
      from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_azbj_partner_extn__party_identification s
      left join p on p.k = s.PARTY_HKEY group by 1
    union all
    select 'cp_partners', count(*), count_if(p.k is null)
      from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_cp_partners__party_identification s
      left join p on p.k = s.PARTY_HKEY group by 1
)
order by orphan_rows desc;
