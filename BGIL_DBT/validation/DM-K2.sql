/* =====================================================================================
   DM-K2  |  Key checks  |  "No extra / unexpected keys"
   Sign-off: Every hub business key exists in the SF Mirror source.
   Method:   anti-join  HUB  ->  RAW source  (reconcile against RAW Mirror tables, NOT the
             stg / stitch / unpivot / hubfeed views, so a view-layer defect cannot hide a
             key that was fabricated, mis-mapped, or mis-prefixed on the way in).
   Pass:     unexpected_keys = 0 for every hub  (status = 'PASS').

   HKEY reproduction  (automate_dv 0.11.5, Snowflake, vars: hash=md5, hash_content_casing=upper)
       HKEY            = MD5_BINARY( NULLIF( UPPER( TRIM( CAST(<NK> AS VARCHAR) ) ), '' ) )
       <NK>            = 'HUB_<ENTITY>|' || <key>
       <key> (stg)     = nullif(trim(to_varchar(<RAW_COL>)), '')
   Comparison is on HKEY (binary), so a case-only difference between the stored PARENT_BK
   and a source value is NOT reported as unexpected -- same behaviour as the hub load.

   Shared vault: both projects write the SAME physical hub tables in BGIL_DATA_MODEL.
   Hub rows are scoped by RECORD_SOURCE prefix (MAXIMUS_ / OPUS_); each project's hub rows
   are checked only against that project's raw tables.  Query 3 lists rows owned by neither.

   Output (queries 1 and 2): one row per hub
       hub_keys_in_scope | unexpected_keys | status | sample_unexpected_bk (first 10)
   For the full list of unexpected keys swap the final SELECT for the commented DETAIL one.

   Replace the schema placeholders before running (same as DM-K1):
     &VAULT_SCHEMA   -> BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL
     &MAXI_RAW       -> BAGIC_PROD_MIRROR_DB.MAXI_RAW
     &OPUS_RAW       -> BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE   (prod)
                        BAGIC_PREPROD_CURATED_DB.UTILS          (test -- what the opus
                                                                 stg models read today)
   ===================================================================================== */


/* =====================================================================================
   1. MAXIMUS PROJECT  (hub rows with RECORD_SOURCE starting 'MAXIMUS_')
   Raw tables: &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL[_*]  (names per _sources.yml)
   ===================================================================================== */
with
-- ---------------------------------------------------------------------------------------
-- Every key the Maximus raw tables can legitimately produce, per hub, as HKEY.
-- ---------------------------------------------------------------------------------------
src as (

    -- HUB_PARTY  <- PD.PARTY_CODE ------------------------------------------------------
    select 'HUB_PARTY' as hub,
           MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PARTY|' || nullif(trim(to_varchar(PARTY_CODE)), ''))), '')) as hkey
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL
    -- HUB_PARTY  <- FOREIGN_KEY of the child views
    union all
    select 'HUB_PARTY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), ''))), ''))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS
    union all
    select 'HUB_PARTY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), ''))), ''))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
    union all
    select 'HUB_PARTY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), ''))), ''))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    union all
    select 'HUB_PARTY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), ''))), ''))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_RELATION
    union all
    select 'HUB_PARTY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), ''))), ''))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY
    -- HUB_PARTY  <- SIMPLE_PROPERTY_PIVOT_VW.BAGIC_EMPLOYEE_CODE (stage + all sp_pv unpivots)
    union all
    select 'HUB_PARTY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PARTY|' || nullif(trim(to_varchar(BAGIC_EMPLOYEE_CODE)), ''))), ''))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW

    -- HUB_LOCATION  <- content-hash BK (concat_ws returns NULL if ANY part is NULL) -------
    union all
    select 'HUB_LOCATION',
           MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || md5(concat_ws('|',
               upper(nullif(trim(to_varchar(ADDRESS1)), '')),
               upper(nullif(trim(to_varchar(ADDRESS2)), '')),
               upper(nullif(trim(to_varchar(ADDRESS3)), '')),
               upper(nullif(trim(to_varchar(CITY)), '')),
               upper(nullif(trim(to_varchar(DISTRICT)), '')),
               upper(nullif(trim(to_varchar(STATE)), '')),
               upper(nullif(trim(to_varchar(PINCODE)), '')),
               upper(nullif(trim(to_varchar(COUNTRY)), '')))))), ''))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS
    union all
    select 'HUB_LOCATION',
           MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || md5(concat_ws('|',
               upper(nullif(trim(to_varchar(LAND_MARK)), '')),
               upper(nullif(trim(to_varchar(AREA)), '')),
               upper(nullif(trim(to_varchar(POST_OFFICE)), '')),
               upper(nullif(trim(to_varchar(CITY)), '')),
               upper(nullif(trim(to_varchar(STATE)), '')),
               upper(nullif(trim(to_varchar(PINCODE)), '')))))), ''))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
    union all
    select 'HUB_LOCATION',
           MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || md5(concat_ws('|',
               upper(nullif(trim(to_varchar(OUR_OFFICE_ADDRESS)), '')),
               upper(nullif(trim(to_varchar(CURRENT_PERMANENT_OVERSEAS_ADDRESS_LINE_2)), '')),
               upper(nullif(trim(to_varchar(CURRENT_PERMANENT_OVERSEAS_ADDRESS_LINE_3)), '')),
               upper(nullif(trim(to_varchar(CURRENT_PERMANENT_OVERSEAS_ADDRESS_CITY_TOWN_VILLAGE)), '')),
               upper(nullif(trim(to_varchar(CORRESPONDENCE_LOCAL_ADDRESS_DISTRICT)), '')),
               upper(nullif(trim(to_varchar(CURRENT_PERMANENT_OVERSEAS_ADDRESS_STATE_UT)), '')),
               upper(nullif(trim(to_varchar(LOCAL_ADDRESS_PIN_CODE)), '')),
               upper(nullif(trim(to_varchar(CURRENT_PERMANENT_OVERSEAS_ADDRESS_COUNTRY)), '')))))), ''))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW

    -- HUB_DOCUMENT  <- DOCUMENT_DETAIL.DOCUMENT_ID --------------------------------------
    union all
    select 'HUB_DOCUMENT', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_DOCUMENT|' || nullif(trim(to_varchar(DOCUMENT_ID)), ''))), ''))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_DOCUMENT_DETAIL

    -- HUB_FINANCIAL_ACCOUNT  <- none: account_code is cast(null) in stg_maximus__pd_prop_msdp_pv,
    --                          so ANY Maximus row in this hub is unexpected.

    -- HUB_ORG_UNIT  <- MSDP_PV.COMPANY   (sp_pv branch_code is cast(null) -> contributes nothing)
    union all
    select 'HUB_ORG_UNIT', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_ORG_UNIT|' || nullif(trim(to_varchar(COMPANY)), ''))), ''))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW

    -- HUB_PAYMENT_INSTRUMENT  <- MSDP_PV.FOREIGN_KEY  (BK already prefixed -> NK double-prefixed)
    union all
    select 'HUB_PAYMENT_INSTRUMENT',
           MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PAYMENT_INSTRUMENT|' || ('HUB_PAYMENT_INSTRUMENT|' || nullif(trim(to_varchar(FOREIGN_KEY)), '')))), ''))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW

    -- HUB_POLICY / HUB_PRODUCT / HUB_DISTRIBUTION_CHANNEL  <- SIMPLE_PROPERTY_PIVOT_VW ----
    union all
    select 'HUB_POLICY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim(to_varchar(PA_POLICY)), ''))), ''))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    union all
    select 'HUB_PRODUCT', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PRODUCT|' || nullif(trim(to_varchar(PRODUCT_CODE)), ''))), ''))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    union all
    select 'HUB_DISTRIBUTION_CHANNEL', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_DISTRIBUTION_CHANNEL|' || nullif(trim(to_varchar(AGENT_CHANNEL)), ''))), ''))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW

    -- HUB_STAKE_CODE  <- RELATED_PARTY.STAKE_CODE ---------------------------------------
    union all
    select 'HUB_STAKE_CODE', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_STAKE_CODE|' || nullif(trim(to_varchar(STAKE_CODE)), ''))), ''))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY
),
src_keys as (
    select distinct hub, hkey from src where hkey is not null
),
-- ---------------------------------------------------------------------------------------
-- Hub rows owned by Maximus.
-- ---------------------------------------------------------------------------------------
hub_keys as (
    select 'HUB_PARTY' as hub, PARTY_HKEY as hkey, PARENT_BK as bk, RECORD_SOURCE
      from &VAULT_SCHEMA..HUB_PARTY                where startswith(RECORD_SOURCE, 'MAXIMUS_')
    union all
    select 'HUB_LOCATION', LOCATION_HKEY, PARENT_BK, RECORD_SOURCE
      from &VAULT_SCHEMA..HUB_LOCATION             where startswith(RECORD_SOURCE, 'MAXIMUS_')
    union all
    select 'HUB_DOCUMENT', DOCUMENT_HKEY, PARENT_BK, RECORD_SOURCE
      from &VAULT_SCHEMA..HUB_DOCUMENT             where startswith(RECORD_SOURCE, 'MAXIMUS_')
    union all
    select 'HUB_FINANCIAL_ACCOUNT', FINANCIAL_ACCOUNT_HKEY, PARENT_BK, RECORD_SOURCE
      from &VAULT_SCHEMA..HUB_FINANCIAL_ACCOUNT    where startswith(RECORD_SOURCE, 'MAXIMUS_')
    union all
    select 'HUB_ORG_UNIT', ORG_UNIT_HKEY, PARENT_BK, RECORD_SOURCE
      from &VAULT_SCHEMA..HUB_ORG_UNIT             where startswith(RECORD_SOURCE, 'MAXIMUS_')
    union all
    select 'HUB_PAYMENT_INSTRUMENT', PAYMENT_INSTRUMENT_HKEY, PARENT_BK, RECORD_SOURCE
      from &VAULT_SCHEMA..HUB_PAYMENT_INSTRUMENT   where startswith(RECORD_SOURCE, 'MAXIMUS_')
    union all
    select 'HUB_POLICY', POLICY_HKEY, PARENT_BK, RECORD_SOURCE
      from &VAULT_SCHEMA..HUB_POLICY               where startswith(RECORD_SOURCE, 'MAXIMUS_')
    union all
    select 'HUB_PRODUCT', PRODUCT_HKEY, PARENT_BK, RECORD_SOURCE
      from &VAULT_SCHEMA..HUB_PRODUCT              where startswith(RECORD_SOURCE, 'MAXIMUS_')
    union all
    select 'HUB_DISTRIBUTION_CHANNEL', DISTRIBUTION_CHANNEL_HKEY, PARENT_BK, RECORD_SOURCE
      from &VAULT_SCHEMA..HUB_DISTRIBUTION_CHANNEL where startswith(RECORD_SOURCE, 'MAXIMUS_')
    union all
    select 'HUB_STAKE_CODE', STAKE_CODE_HKEY, STAKE_CODE_BK, RECORD_SOURCE   -- src_nk = STAKE_CODE_BK
      from &VAULT_SCHEMA..HUB_STAKE_CODE           where startswith(RECORD_SOURCE, 'MAXIMUS_')
),
hub_list as (
    select column1 as hub from values
        ('HUB_PARTY'), ('HUB_LOCATION'), ('HUB_DOCUMENT'), ('HUB_FINANCIAL_ACCOUNT'),
        ('HUB_ORG_UNIT'), ('HUB_PAYMENT_INSTRUMENT'), ('HUB_POLICY'), ('HUB_PRODUCT'),
        ('HUB_DISTRIBUTION_CHANNEL'), ('HUB_STAKE_CODE')
),
unexpected as (
    select h.*
      from hub_keys h
      left join src_keys s
             on s.hub  = h.hub
            and s.hkey = h.hkey
     where s.hkey is null
)
-- SUMMARY (sign-off evidence) ------------------------------------------------------------
select 'MAXIMUS'                               as project,
       'DM-K2'                                 as check_id,
       l.hub,
       coalesce(c.n, 0)                        as hub_keys_in_scope,
       coalesce(x.n, 0)                        as unexpected_keys,
       iff(coalesce(x.n, 0) = 0, 'PASS', 'FAIL') as status,
       x.sample_bk                             as sample_unexpected_bk
  from hub_list l
  left join (select hub, count(*) as n from hub_keys group by hub) c
         on c.hub = l.hub
  left join (select hub, count(*) as n, array_slice(array_agg(bk), 0, 10) as sample_bk
               from unexpected group by hub) x
         on x.hub = l.hub
 order by l.hub;
-- DETAIL (replace the SUMMARY select above with this to list every unexpected key):
-- select 'MAXIMUS' as project, hub, bk as unexpected_bk, hkey, RECORD_SOURCE
--   from unexpected order by hub, bk;



/* =====================================================================================
   2. OPUS PROJECT  (hub rows with RECORD_SOURCE starting 'OPUS_')
   Raw tables: &OPUS_RAW..<TABLE>  (names per _partner__sources.yml)
   Key cast in opus stg models: nullif(trim("<COL>"::varchar), '')
   Stitch-fed branches (stg2_common_address, stg2_policy_header, stg2_policy_bonus_tracking,
   stg2_product_definition) are expanded to the raw key column of every stitch source:
   the stitch views are watermark-windowed, so they are NOT a full key set.
   Stitch-fed hub rows carry a comma list RECORD_SOURCE ('OPUS_A, OPUS_B') -- still 'OPUS_'.
   ===================================================================================== */
with
src as (

    -- HUB_PARTY  <- CP_PARTNERS.PART_ID   (only branch in hub_party.sql) ----------------
    select 'HUB_PARTY' as hub,
           MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PARTY|' || nullif(trim("PART_ID"::varchar), ''))), '')) as hkey
      from &OPUS_RAW..CP_PARTNERS

    -- HUB_AGENT / HUB_AGREEMENT  <- BJAZ_INTERMEDIARY.INTERMEDIARY_ID ------------------
    union all
    select 'HUB_AGENT', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_AGENT|' || nullif(trim("INTERMEDIARY_ID"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_INTERMEDIARY
    union all
    select 'HUB_AGREEMENT', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_AGREEMENT|' || nullif(trim("INTERMEDIARY_ID"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_INTERMEDIARY

    -- HUB_CLAIM / HUB_RISK_OBJECT  <- CLM_INTERESTED_PARTIES ----------------------------
    union all
    select 'HUB_CLAIM', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_CLAIM|' || nullif(trim("CLAIM_ID"::varchar), ''))), ''))
      from &OPUS_RAW..CLM_INTERESTED_PARTIES
    union all
    select 'HUB_RISK_OBJECT', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_RISK_OBJECT|' || nullif(trim("INS_OBJ_UID"::varchar), ''))), ''))
      from &OPUS_RAW..CLM_INTERESTED_PARTIES

    -- HUB_DISTRIBUTION_CHANNEL  <- BJAZ_INTERMEDIARY.INTERMEDIARY_ID, BJAZ_CLM_SUPP_EXTN.IMD_CODE
    union all
    select 'HUB_DISTRIBUTION_CHANNEL', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_DISTRIBUTION_CHANNEL|' || nullif(trim("INTERMEDIARY_ID"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_INTERMEDIARY
    union all
    select 'HUB_DISTRIBUTION_CHANNEL', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_DISTRIBUTION_CHANNEL|' || nullif(trim("IMD_CODE"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_CLM_SUPP_EXTN

    -- HUB_LOCATION  <- stitch_common_address (5 raw keys) + 6 direct branches ------------
    union all
    select 'HUB_LOCATION', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || nullif(trim("ADD_ID"::varchar), ''))), ''))
      from &OPUS_RAW..AZBJ_ADDRESS_EXTN
    union all
    select 'HUB_LOCATION', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || nullif(trim("BILLING_LOC"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_CLM_SUPP_EXTN
    union all
    select 'HUB_LOCATION', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || nullif(trim("PINCODE"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_PINCODE
    union all
    select 'HUB_LOCATION', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || nullif(trim("PINCODE"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_PINCODE_MASTER
    union all
    select 'HUB_LOCATION', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || nullif(trim("ADD_ID"::varchar), ''))), ''))
      from &OPUS_RAW..CP_ADDRESSES
    union all
    select 'HUB_LOCATION', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || nullif(trim("MAIL_ADD_ID"::varchar), ''))), ''))
      from &OPUS_RAW..AZBJ_PARTNER_EXTN
    union all
    select 'HUB_LOCATION', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || nullif(trim("LOCATION_CODE"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_CLM_SUPP_EXTN
    union all
    select 'HUB_LOCATION', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || nullif(trim("ADD_ID"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_CP_ADDRESS_LINK
    union all
    select 'HUB_LOCATION', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || nullif(trim("LOC_CODE"::varchar), ''))), ''))
      from &OPUS_RAW..CLM_SUPPLIERS
    union all
    select 'HUB_LOCATION', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || nullif(trim("ADD_ID"::varchar), ''))), ''))
      from &OPUS_RAW..CP_PARTNERS
    union all
    select 'HUB_LOCATION', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || nullif(trim("MAILING_ADDRESS_ID"::varchar), ''))), ''))
      from &OPUS_RAW..OCP_INTERESTED_PARTIES

    -- HUB_POLICY  <- stitch_policy_header + stitch_policy_bonus_tracking + 6 direct ------
    union all
    select 'HUB_POLICY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("EXISTING_POLICY_PID"::varchar), ''))), ''))
      from &OPUS_RAW..AZBJ_PARTNER_EXTN
    union all
    select 'HUB_POLICY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("POLICY_REF"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_CTNGY_GC_MEM_DATA
    union all
    select 'HUB_POLICY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_CTNGY_PA_MEM_DTLS
    union all
    select 'HUB_POLICY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_EC_MEM_DTLS_EXTN
    union all
    select 'HUB_POLICY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_HCF_MEMBER_DTLS
    union all
    select 'HUB_POLICY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_HC_PART_EXTN
    union all
    select 'HUB_POLICY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_HM_MEMBER_DTLS
    union all
    select 'HUB_POLICY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_PA_DETL_EXTN
    union all
    select 'HUB_POLICY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_SH_MEM_DTLS_EXTN
    union all
    select 'HUB_POLICY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_SPP_MEMBER_DTLS
    union all
    select 'HUB_POLICY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_HLT_ENSURE_MEM_DTLS                       -- bonus_tracking only
    union all
    select 'HUB_POLICY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from &OPUS_RAW..BA_HCP_DT_MEM
    union all
    select 'HUB_POLICY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_CTNGY_FF_DTLS_EXTN
    union all
    select 'HUB_POLICY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("POLICY_NUMBER"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_HCF_MEMBER_DTLS
    union all
    select 'HUB_POLICY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("POLICY_NUMBER"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_SPP_MEMBER_DTLS
    union all
    select 'HUB_POLICY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_STARPKG_FF_DTLS
    union all
    select 'HUB_POLICY', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from &OPUS_RAW..OCP_INTERESTED_PARTIES

    -- HUB_PRODUCT  <- stitch_product_definition ----------------------------------------
    union all
    select 'HUB_PRODUCT', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PRODUCT|' || nullif(trim("SCHEME_CODE"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_CTNGY_FF_DTLS_EXTN
    union all
    select 'HUB_PRODUCT', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PRODUCT|' || nullif(trim("SCHEME_CODE"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_CTNGY_PA_MEM_DTLS
    union all
    select 'HUB_PRODUCT', MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PRODUCT|' || nullif(trim("PRODUCT_CODE"::varchar), ''))), ''))
      from &OPUS_RAW..BJAZ_HM_MEMBER_DTLS
),
src_keys as (
    select distinct hub, hkey from src where hkey is not null
),
hub_keys as (
    select 'HUB_PARTY' as hub, PARTY_HKEY as hkey, PARENT_BK as bk, RECORD_SOURCE
      from &VAULT_SCHEMA..HUB_PARTY                where startswith(RECORD_SOURCE, 'OPUS_')
    union all
    select 'HUB_AGENT', AGENT_HKEY, PARENT_BK, RECORD_SOURCE
      from &VAULT_SCHEMA..HUB_AGENT                where startswith(RECORD_SOURCE, 'OPUS_')
    union all
    select 'HUB_AGREEMENT', AGREEMENT_HKEY, PARENT_BK, RECORD_SOURCE
      from &VAULT_SCHEMA..HUB_AGREEMENT            where startswith(RECORD_SOURCE, 'OPUS_')
    union all
    select 'HUB_CLAIM', CLAIM_HKEY, PARENT_BK, RECORD_SOURCE
      from &VAULT_SCHEMA..HUB_CLAIM                where startswith(RECORD_SOURCE, 'OPUS_')
    union all
    select 'HUB_RISK_OBJECT', RISK_OBJECT_HKEY, PARENT_BK, RECORD_SOURCE
      from &VAULT_SCHEMA..HUB_RISK_OBJECT          where startswith(RECORD_SOURCE, 'OPUS_')
    union all
    select 'HUB_DISTRIBUTION_CHANNEL', DISTRIBUTION_CHANNEL_HKEY, PARENT_BK, RECORD_SOURCE
      from &VAULT_SCHEMA..HUB_DISTRIBUTION_CHANNEL where startswith(RECORD_SOURCE, 'OPUS_')
    union all
    select 'HUB_LOCATION', LOCATION_HKEY, PARENT_BK, RECORD_SOURCE
      from &VAULT_SCHEMA..HUB_LOCATION             where startswith(RECORD_SOURCE, 'OPUS_')
    union all
    select 'HUB_POLICY', POLICY_HKEY, PARENT_BK, RECORD_SOURCE
      from &VAULT_SCHEMA..HUB_POLICY               where startswith(RECORD_SOURCE, 'OPUS_')
    union all
    select 'HUB_PRODUCT', PRODUCT_HKEY, PARENT_BK, RECORD_SOURCE
      from &VAULT_SCHEMA..HUB_PRODUCT              where startswith(RECORD_SOURCE, 'OPUS_')
),
hub_list as (
    select column1 as hub from values
        ('HUB_PARTY'), ('HUB_AGENT'), ('HUB_AGREEMENT'), ('HUB_CLAIM'), ('HUB_RISK_OBJECT'),
        ('HUB_DISTRIBUTION_CHANNEL'), ('HUB_LOCATION'), ('HUB_POLICY'), ('HUB_PRODUCT')
),
unexpected as (
    select h.*
      from hub_keys h
      left join src_keys s
             on s.hub  = h.hub
            and s.hkey = h.hkey
     where s.hkey is null
)
-- SUMMARY (sign-off evidence) ------------------------------------------------------------
select 'OPUS'                                  as project,
       'DM-K2'                                 as check_id,
       l.hub,
       coalesce(c.n, 0)                        as hub_keys_in_scope,
       coalesce(x.n, 0)                        as unexpected_keys,
       iff(coalesce(x.n, 0) = 0, 'PASS', 'FAIL') as status,
       x.sample_bk                             as sample_unexpected_bk
  from hub_list l
  left join (select hub, count(*) as n from hub_keys group by hub) c
         on c.hub = l.hub
  left join (select hub, count(*) as n, array_slice(array_agg(bk), 0, 10) as sample_bk
               from unexpected group by hub) x
         on x.hub = l.hub
 order by l.hub;
-- DETAIL (replace the SUMMARY select above with this to list every unexpected key):
-- select 'OPUS' as project, hub, bk as unexpected_bk, hkey, RECORD_SOURCE
--   from unexpected order by hub, bk;


/* =====================================================================================
   3. OWNERSHIP SWEEP (shared hubs) -- informational, not part of the pass criterion.
   Rows in the shared hubs whose RECORD_SOURCE is neither MAXIMUS_ nor OPUS_ are not
   covered by queries 1-2. Expected: 0 rows, or only record sources of other known
   projects (e.g. health / travel) that write the same table.
   ===================================================================================== */
select hub, RECORD_SOURCE, count(*) as rows_not_covered
  from (
        select 'HUB_PARTY'                as hub, RECORD_SOURCE from &VAULT_SCHEMA..HUB_PARTY
        union all select 'HUB_LOCATION',             RECORD_SOURCE from &VAULT_SCHEMA..HUB_LOCATION
        union all select 'HUB_POLICY',               RECORD_SOURCE from &VAULT_SCHEMA..HUB_POLICY
        union all select 'HUB_PRODUCT',              RECORD_SOURCE from &VAULT_SCHEMA..HUB_PRODUCT
        union all select 'HUB_DISTRIBUTION_CHANNEL', RECORD_SOURCE from &VAULT_SCHEMA..HUB_DISTRIBUTION_CHANNEL
       )
 where not startswith(RECORD_SOURCE, 'MAXIMUS_')
   and not startswith(RECORD_SOURCE, 'OPUS_')
 group by hub, RECORD_SOURCE
 order by hub, RECORD_SOURCE;
