

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
