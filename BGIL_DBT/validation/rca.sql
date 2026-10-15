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
