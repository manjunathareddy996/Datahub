-- =====================================================================
-- RCA scratch queries
-- =====================================================================


-- =====================================================================
-- ITEM 9 : SAT_COMMON_CONTACT  (HUB_PARTY grain)
-- =====================================================================

-- Query 9A : per-source-table orphan breakdown
-- Shows which contributing table drives the orphans and the key column it uses.
with p as (
    select distinct PARTY_HKEY as k
    from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
)
select src.tbl, src.key_col,
       count(*)                 as rows_checked,
       count_if(p.k is null)    as orphan_rows
from (
    select 'bjaz_hm_member_dtls'      as tbl, 'partner_id' as key_col, PARTY_HKEY from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_bjaz_hm_member_dtls__common_contact
    union all select 'bjaz_clm_supp_extn',      'partner_id', PARTY_HKEY from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_bjaz_clm_supp_extn__common_contact
    union all select 'bjaz_hm_hospital_master', 'hosid',      PARTY_HKEY from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_bjaz_hm_hospital_master__common_contact
    union all select 'bjaz_ctngy_pa_mem_dtls',  'partner_id', PARTY_HKEY from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_bjaz_ctngy_pa_mem_dtls__common_contact
    union all select 'bjaz_ctngy_gc_mem_data',  'partner_id', PARTY_HKEY from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_bjaz_ctngy_gc_mem_data__common_contact
    union all select 'bjaz_sh_mem_dtls_extn',   'partner_id', PARTY_HKEY from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_bjaz_sh_mem_dtls_extn__common_contact
    union all select 'clm_suppliers',           'part_id',    PARTY_HKEY from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_clm_suppliers__common_contact
    union all select 'cp_partners',             'part_id',    PARTY_HKEY from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_cp_partners__common_contact
    union all select 'azbj_partner_extn',       'part_id',    PARTY_HKEY from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_azbj_partner_extn__common_contact
) src
left join p on p.k = src.PARTY_HKEY
where src.PARTY_HKEY is not null
  and src.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX')
group by src.tbl, src.key_col
order by orphan_rows desc;


-- Query 9B : are the two legit party tables' own keys usable to seed HUB_PARTY?
-- (clm_supp_extn.partner_id , hm_hospital_master.hosid)
select 'clm_supp_extn' as tbl,
       count(*)                      as raw_rows,
       count(distinct partner_id)    as distinct_keys,
       count_if(partner_id is null)  as null_keys
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__bjaz_clm_supp_extn
union all
select 'hm_hospital_master',
       count(*),
       count(distinct hosid),
       count_if(hosid is null)
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__bjaz_hm_hospital_master;


-- =====================================================================
-- ITEM 9 : do the member/supplier/hospital tables' PARTNER_ID values
--          actually exist in the CP_PARTNERS master (part_id)?
-- Premise: HUB_PARTY is built from CP_PARTNERS, which is claimed to hold
-- every partner_id. If true, every satellite should key on partner_id and
-- resolve. This measures how many partner_id values are missing from the
-- cp_partners master.
-- =====================================================================
with master as (
    select distinct part_id as id
    from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__cp_partners
    where part_id is not null
)
select 'bjaz_hm_member_dtls' as tbl, 'partner_id' as key_col,
       count(distinct t.partner_id)                                   as distinct_keys,
       count(distinct iff(m.id is null, t.partner_id, null))          as keys_missing_from_cp
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__bjaz_hm_member_dtls t
left join master m on m.id = t.partner_id
where t.partner_id is not null

union all
select 'bjaz_clm_supp_extn', 'partner_id',
       count(distinct t.partner_id),
       count(distinct iff(m.id is null, t.partner_id, null))
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__bjaz_clm_supp_extn t
left join master m on m.id = t.partner_id
where t.partner_id is not null

union all
-- hospital master: does it even carry partner_id, and is it in cp?
select 'bjaz_hm_hospital_master', 'partner_id',
       count(distinct t.partner_id),
       count(distinct iff(m.id is null, t.partner_id, null))
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg_partner__bjaz_hm_hospital_master t
left join master m on m.id = t.partner_id
where t.partner_id is not null;


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
