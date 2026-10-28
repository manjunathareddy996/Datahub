/* =====================================================================================
DM-H4 OPUS — Section 9 diagnostic
SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS, stitch group "stitch_party_individual_demographics (8 tables)"

Purpose: section 9 reports no_source_row = 79 (=> FAIL). This query finds out WHY the
recomputed stitch expectation (e1/st1) has no row for those sampled keys.

Run the three queries below in order. Q1 gives the headline split. Q2 shows, for each
missing key, which of the 8 RAW source tables (if any) actually contains its parent_bk.
Q3 shows whether the keys exist in RAW at all (any source), isolating "RAW coverage gap"
from "key reconstruction mismatch".
===================================================================================== */

-- Shared sampling CTE: the same 100 keys section 9 uses.
-- (regex identical to section 9's s1)
----------------------------------------------------------------------------------------
-- Q1. Headline: sampled vs rebuilt vs missing
----------------------------------------------------------------------------------------
with s1 as (
    select PARTY_HKEY as hkey from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS
     where regexp_like(RECORD_SOURCE, '^(OPUS_AZBJ_PARTNER_EXTN|OPUS_BJAZ_EC_MEM_DTLS_EXTN|OPUS_BJAZ_HCF_MEMBER_DTLS|OPUS_BJAZ_HC_PART_EXTN|OPUS_BJAZ_HM_MEMBER_DTLS|OPUS_BJAZ_SH_MEM_DTLS_EXTN|OPUS_BJAZ_SPP_MEMBER_DTLS|OPUS_CP_PARTNERS)(, (OPUS_AZBJ_PARTNER_EXTN|OPUS_BJAZ_EC_MEM_DTLS_EXTN|OPUS_BJAZ_HCF_MEMBER_DTLS|OPUS_BJAZ_HC_PART_EXTN|OPUS_BJAZ_HM_MEMBER_DTLS|OPUS_BJAZ_SH_MEM_DTLS_EXTN|OPUS_BJAZ_SPP_MEMBER_DTLS|OPUS_CP_PARTNERS))*$')
     group by PARTY_HKEY
     order by max(LOAD_DATETIME) desc, hkey
     limit 100
),
-- rebuilt key set from RAW (all 8 sources, no time window) == what st1/e1 can produce
rebuilt as (
    select MD5_BINARY(NULLIF(UPPER(TRIM(CAST('HUB_PARTY|' || bk AS VARCHAR))), '')) as hkey
    from (
        select nullif(trim("PART_ID"::varchar), '') as bk from BAGIC_PREPROD_CURATED_DB.UTILS.AZBJ_PARTNER_EXTN
        union select nullif(trim("PARTNER_ID"::varchar), '') from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_EC_MEM_DTLS_EXTN
        union select nullif(trim(to_varchar(to_number("PARTNER_ID", 38, 0))), '') from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_HCF_MEMBER_DTLS
        union select nullif(trim("PART_ID"::varchar), '') from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_HC_PART_EXTN
        union select nullif(trim("PARTNER_ID"::varchar), '') from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_HM_MEMBER_DTLS
        union select nullif(trim("PARTNER_ID"::varchar), '') from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_SH_MEM_DTLS_EXTN
        union select nullif(trim("PARTNER_ID"::varchar), '') from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_SPP_MEMBER_DTLS
        union select nullif(trim("PART_ID"::varchar), '') from BAGIC_PREPROD_CURATED_DB.UTILS.CP_PARTNERS
    ) where bk is not null
)
select
    (select count(*) from s1) as sampled_keys,
    (select count(*) from s1 where hkey in (select hkey from rebuilt)) as rebuilt_keys,
    (select count(*) from s1 where hkey not in (select hkey from rebuilt)) as missing_keys;


----------------------------------------------------------------------------------------
-- Q2. Per-source presence for each sampled key.
-- For every sampled key, 1/0 flags showing which of the 8 RAW tables holds its parent_bk.
-- "in_any = 0" rows are the no_source_row keys. Look at whether those keys are simply
-- absent from all RAW tables (coverage gap) or present but under a different key form.
----------------------------------------------------------------------------------------
with s1 as (
    select PARTY_HKEY as hkey from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS
     where regexp_like(RECORD_SOURCE, '^(OPUS_AZBJ_PARTNER_EXTN|OPUS_BJAZ_EC_MEM_DTLS_EXTN|OPUS_BJAZ_HCF_MEMBER_DTLS|OPUS_BJAZ_HC_PART_EXTN|OPUS_BJAZ_HM_MEMBER_DTLS|OPUS_BJAZ_SH_MEM_DTLS_EXTN|OPUS_BJAZ_SPP_MEMBER_DTLS|OPUS_CP_PARTNERS)(, (OPUS_AZBJ_PARTNER_EXTN|OPUS_BJAZ_EC_MEM_DTLS_EXTN|OPUS_BJAZ_HCF_MEMBER_DTLS|OPUS_BJAZ_HC_PART_EXTN|OPUS_BJAZ_HM_MEMBER_DTLS|OPUS_BJAZ_SH_MEM_DTLS_EXTN|OPUS_BJAZ_SPP_MEMBER_DTLS|OPUS_CP_PARTNERS))*$')
     group by PARTY_HKEY
     order by max(LOAD_DATETIME) desc, hkey
     limit 100
),
h(src, hkey) as (
    select 't0_AZBJ_PARTNER_EXTN',  MD5_BINARY(NULLIF(UPPER(TRIM(CAST('HUB_PARTY|' || nullif(trim("PART_ID"::varchar), '') AS VARCHAR))), '')) from BAGIC_PREPROD_CURATED_DB.UTILS.AZBJ_PARTNER_EXTN
    union all select 't3_EC_MEM_DTLS_EXTN', MD5_BINARY(NULLIF(UPPER(TRIM(CAST('HUB_PARTY|' || nullif(trim("PARTNER_ID"::varchar), '') AS VARCHAR))), '')) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_EC_MEM_DTLS_EXTN
    union all select 't4_HCF_MEMBER_DTLS', MD5_BINARY(NULLIF(UPPER(TRIM(CAST('HUB_PARTY|' || nullif(trim(to_varchar(to_number("PARTNER_ID", 38, 0))), '') AS VARCHAR))), '')) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_HCF_MEMBER_DTLS
    union all select 't5_HC_PART_EXTN', MD5_BINARY(NULLIF(UPPER(TRIM(CAST('HUB_PARTY|' || nullif(trim("PART_ID"::varchar), '') AS VARCHAR))), '')) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_HC_PART_EXTN
    union all select 't6_HM_MEMBER_DTLS', MD5_BINARY(NULLIF(UPPER(TRIM(CAST('HUB_PARTY|' || nullif(trim("PARTNER_ID"::varchar), '') AS VARCHAR))), '')) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_HM_MEMBER_DTLS
    union all select 't7_SH_MEM_DTLS_EXTN', MD5_BINARY(NULLIF(UPPER(TRIM(CAST('HUB_PARTY|' || nullif(trim("PARTNER_ID"::varchar), '') AS VARCHAR))), '')) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_SH_MEM_DTLS_EXTN
    union all select 't8_SPP_MEMBER_DTLS', MD5_BINARY(NULLIF(UPPER(TRIM(CAST('HUB_PARTY|' || nullif(trim("PARTNER_ID"::varchar), '') AS VARCHAR))), '')) from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_SPP_MEMBER_DTLS
    union all select 't9_CP_PARTNERS', MD5_BINARY(NULLIF(UPPER(TRIM(CAST('HUB_PARTY|' || nullif(trim("PART_ID"::varchar), '') AS VARCHAR))), '')) from BAGIC_PREPROD_CURATED_DB.UTILS.CP_PARTNERS
)
select to_varchar(s1.hkey, 'HEX') as hkey,
       max(iff(h.src='t0_AZBJ_PARTNER_EXTN',1,0)) as t0,
       max(iff(h.src='t3_EC_MEM_DTLS_EXTN',1,0)) as t3,
       max(iff(h.src='t4_HCF_MEMBER_DTLS',1,0))  as t4,
       max(iff(h.src='t5_HC_PART_EXTN',1,0))      as t5,
       max(iff(h.src='t6_HM_MEMBER_DTLS',1,0))    as t6,
       max(iff(h.src='t7_SH_MEM_DTLS_EXTN',1,0))  as t7,
       max(iff(h.src='t8_SPP_MEMBER_DTLS',1,0))   as t8,
       max(iff(h.src='t9_CP_PARTNERS',1,0))       as t9,
       iff(count(h.hkey) > 0, 1, 0) as in_any
  from s1 left join h on h.hkey = s1.hkey
 group by s1.hkey
 order by in_any, hkey;


----------------------------------------------------------------------------------------
-- Q3. Compare the RECORD_SOURCE stored on the satellite row for the missing keys vs the
-- sources that actually carry the key in RAW. A satellite RECORD_SOURCE that names a
-- table which no longer contains the key => RAW coverage/vintage gap (test-data issue).
----------------------------------------------------------------------------------------
with s1 as (
    select PARTY_HKEY as hkey, max(LOAD_DATETIME) as max_ldts
      from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS
     where regexp_like(RECORD_SOURCE, '^(OPUS_AZBJ_PARTNER_EXTN|OPUS_BJAZ_EC_MEM_DTLS_EXTN|OPUS_BJAZ_HCF_MEMBER_DTLS|OPUS_BJAZ_HC_PART_EXTN|OPUS_BJAZ_HM_MEMBER_DTLS|OPUS_BJAZ_SH_MEM_DTLS_EXTN|OPUS_BJAZ_SPP_MEMBER_DTLS|OPUS_CP_PARTNERS)(, (OPUS_AZBJ_PARTNER_EXTN|OPUS_BJAZ_EC_MEM_DTLS_EXTN|OPUS_BJAZ_HCF_MEMBER_DTLS|OPUS_BJAZ_HC_PART_EXTN|OPUS_BJAZ_HM_MEMBER_DTLS|OPUS_BJAZ_SH_MEM_DTLS_EXTN|OPUS_BJAZ_SPP_MEMBER_DTLS|OPUS_CP_PARTNERS))*$')
     group by PARTY_HKEY
     order by max_ldts desc, hkey
     limit 100
),
sat as (
    select PARTY_HKEY as hkey, RECORD_SOURCE, LOAD_DATETIME
      from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS
     where PARTY_HKEY in (select hkey from s1)
    qualify rank() over (partition by PARTY_HKEY order by LOAD_DATETIME desc) = 1
)
select to_varchar(sat.hkey, 'HEX') as hkey, sat.RECORD_SOURCE as sat_record_source, sat.LOAD_DATETIME
  from sat
 order by sat.LOAD_DATETIME desc;
