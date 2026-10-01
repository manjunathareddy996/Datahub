/* =====================================================================================
   DM-K5  |  Completeness  |  "Row-count completeness"
   Sign-off: Source record count reconciles to hub load counts for the agreed data cut.
   Method:   count DISTINCT business keys in the RAW source(s) and compare to the number
             of those keys that are present in the HUB. Report source count, hub-present
             count, and the difference.
   Pass:     diff = 0  (match within agreed tolerance).

   Relationship to DM-K1:
     DM-K1 lists WHICH keys are missing; DM-K5 reports the COUNT reconciliation.
     Both reproduce the hub HKEY from RAW tables (not views) and join on HKEY alone --
     the hub is a shared, HKEY-deduplicated table (maximus + opus + partner_dv), so a key
     is stored once regardless of which project/record_source loaded it. Do NOT scope by
     RECORD_SOURCE (that was proven to cause false shortfalls -- see DM-K1 header).

   HKEY = MD5_BINARY(UPPER(TRIM(COALESCE(CAST(<NK> AS VARCHAR), ''))))  -- BINARY(16)
   <NK>  = 'HUB_<ENTITY>|' || nullif(trim(to_varchar(<RAW_KEY>)), '')

   Fully-qualified names:
     Vault (both projects) : BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL
     Maximus RAW           : BAGIC_PROD_MIRROR_DB.MAXI_RAW
     Opus RAW (test)       : BAGIC_PREPROD_CURATED_DB.UTILS   (source 'partner_test_raw')

   Each query returns one row: source_distinct_keys, hub_present_keys, diff.
   diff > 0 => source keys not loaded (shortfall).  diff should be 0 to PASS.
   ===================================================================================== */


/* =====================================================================================
   MAXIMUS PROJECT
   ===================================================================================== */

----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_PARTY
----------------------------------------------------------------------------------------
with src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(PARTY_CODE)), '') AS VARCHAR), '')))) as HKEY
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL
     where nullif(trim(to_varchar(PARTY_CODE)), '') is not null
    union
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), ''))))
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
    union
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), ''))))
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
    union
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), ''))))
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
    union
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(BAGIC_EMPLOYEE_CODE)), '') AS VARCHAR), ''))))
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1
     where nullif(trim(to_varchar(BAGIC_EMPLOYEE_CODE)), '') is not null
    union
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), ''))))
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_RELATION
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
    union
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), ''))))
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_PARTY' as hub,
       count(*)                        as source_distinct_keys,
       count(h.PARTY_HKEY)             as hub_present_keys,
       count(*) - count(h.PARTY_HKEY)  as diff
  from src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY h
         on h.PARTY_HKEY = s.HKEY;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_STAKE_CODE
----------------------------------------------------------------------------------------
with src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_STAKE_CODE|' || nullif(trim(to_varchar(STAKE_CODE)), '') AS VARCHAR), '')))) as HKEY
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY
     where nullif(trim(to_varchar(STAKE_CODE)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_STAKE_CODE' as hub,
       count(*) as source_distinct_keys,
       count(h.STAKE_CODE_HKEY) as hub_present_keys,
       count(*) - count(h.STAKE_CODE_HKEY) as diff
  from src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_STAKE_CODE h
         on h.STAKE_CODE_HKEY = s.HKEY;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_LOCATION   (composite address key; mirrors each stg2 concat_ws)
----------------------------------------------------------------------------------------
with src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_LOCATION|' || md5(concat_ws('|',
               upper(trim(to_varchar(nullif(trim(to_varchar("ADDRESS1")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("ADDRESS2")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("ADDRESS3")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("CITY")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("DISTRICT")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("STATE")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("PINCODE")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("COUNTRY")), ''))))
           )) AS VARCHAR), '')))) as HKEY
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS
    union
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_LOCATION|' || md5(concat_ws('|',
               upper(trim(to_varchar(nullif(trim(to_varchar("LAND_MARK")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("AREA")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("POST_OFFICE")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("CITY")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("STATE")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("PINCODE")), ''))))
           )) AS VARCHAR), ''))))
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
    union
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_LOCATION|' || md5(concat_ws('|',
               upper(trim(to_varchar(nullif(trim(to_varchar("OUR_OFFICE_ADDRESS")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("CURRENT_PERMANENT_OVERSEAS_ADDRESS_LINE_2")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("CURRENT_PERMANENT_OVERSEAS_ADDRESS_LINE_3")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("CURRENT_PERMANENT_OVERSEAS_ADDRESS_CITY_TOWN_VILLAGE")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("CORRESPONDENCE_LOCAL_ADDRESS_DISTRICT")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("CURRENT_PERMANENT_OVERSEAS_ADDRESS_STATE_UT")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("LOCAL_ADDRESS_PIN_CODE")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("CURRENT_PERMANENT_OVERSEAS_ADDRESS_COUNTRY")), ''))))
           )) AS VARCHAR), ''))))
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1
)
select 'MAXIMUS' as project, 'HUB_LOCATION' as hub,
       count(*) as source_distinct_keys,
       count(h.LOCATION_HKEY) as hub_present_keys,
       count(*) - count(h.LOCATION_HKEY) as diff
  from src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOCATION h
         on h.LOCATION_HKEY = s.HKEY;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_PAYMENT_INSTRUMENT   (NK is double-prefixed -- see DM-K1 note)
----------------------------------------------------------------------------------------
with src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_PAYMENT_INSTRUMENT|HUB_PAYMENT_INSTRUMENT|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), '')))) as HKEY
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_PAYMENT_INSTRUMENT' as hub,
       count(*) as source_distinct_keys,
       count(h.PAYMENT_INSTRUMENT_HKEY) as hub_present_keys,
       count(*) - count(h.PAYMENT_INSTRUMENT_HKEY) as diff
  from src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PAYMENT_INSTRUMENT h
         on h.PAYMENT_INSTRUMENT_HKEY = s.HKEY;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_PRODUCT
----------------------------------------------------------------------------------------
with src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_PRODUCT|' || nullif(trim(to_varchar(PRODUCT_CODE)), '') AS VARCHAR), '')))) as HKEY
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1
     where nullif(trim(to_varchar(PRODUCT_CODE)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_PRODUCT' as hub,
       count(*) as source_distinct_keys,
       count(h.PRODUCT_HKEY) as hub_present_keys,
       count(*) - count(h.PRODUCT_HKEY) as diff
  from src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PRODUCT h
         on h.PRODUCT_HKEY = s.HKEY;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_FINANCIAL_ACCOUNT
-- NA: account_code is cast(null) in staging (not mapped from JSON). No source keys.
----------------------------------------------------------------------------------------
-- (intentionally NA until account_code is mapped -- see DM-K1)


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_DOCUMENT
----------------------------------------------------------------------------------------
with src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_DOCUMENT|' || nullif(trim(to_varchar(DOCUMENT_ID)), '') AS VARCHAR), '')))) as HKEY
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_DOCUMENT_DETAIL
     where nullif(trim(to_varchar(DOCUMENT_ID)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_DOCUMENT' as hub,
       count(*) as source_distinct_keys,
       count(h.DOCUMENT_HKEY) as hub_present_keys,
       count(*) - count(h.DOCUMENT_HKEY) as diff
  from src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DOCUMENT h
         on h.DOCUMENT_HKEY = s.HKEY;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_POLICY
----------------------------------------------------------------------------------------
with src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_POLICY|' || nullif(trim(to_varchar(PA_POLICY)), '') AS VARCHAR), '')))) as HKEY
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1
     where nullif(trim(to_varchar(PA_POLICY)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_POLICY' as hub,
       count(*) as source_distinct_keys,
       count(h.POLICY_HKEY) as hub_present_keys,
       count(*) - count(h.POLICY_HKEY) as diff
  from src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY h
         on h.POLICY_HKEY = s.HKEY;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_DISTRIBUTION_CHANNEL
----------------------------------------------------------------------------------------
with src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_DISTRIBUTION_CHANNEL|' || nullif(trim(to_varchar(AGENT_CHANNEL)), '') AS VARCHAR), '')))) as HKEY
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1
     where nullif(trim(to_varchar(AGENT_CHANNEL)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_DISTRIBUTION_CHANNEL' as hub,
       count(*) as source_distinct_keys,
       count(h.DISTRIBUTION_CHANNEL_HKEY) as hub_present_keys,
       count(*) - count(h.DISTRIBUTION_CHANNEL_HKEY) as diff
  from src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DISTRIBUTION_CHANNEL h
         on h.DISTRIBUTION_CHANNEL_HKEY = s.HKEY;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_ORG_UNIT   (only the `company` source contributes a key -- see DM-K1)
----------------------------------------------------------------------------------------
with src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_ORG_UNIT|' || nullif(trim(to_varchar(COMPANY)), '') AS VARCHAR), '')))) as HKEY
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
     where nullif(trim(to_varchar(COMPANY)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_ORG_UNIT' as hub,
       count(*) as source_distinct_keys,
       count(h.ORG_UNIT_HKEY) as hub_present_keys,
       count(*) - count(h.ORG_UNIT_HKEY) as diff
  from src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_ORG_UNIT h
         on h.ORG_UNIT_HKEY = s.HKEY;


/* =====================================================================================
   OPUS PROJECT
   ===================================================================================== */

----------------------------------------------------------------------------------------
-- OPUS :: HUB_PARTY
----------------------------------------------------------------------------------------
with src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(PART_ID)), '') AS VARCHAR), '')))) as HKEY
      from BAGIC_PREPROD_CURATED_DB.UTILS.CP_PARTNERS
     where nullif(trim(to_varchar(PART_ID)), '') is not null
)
select 'OPUS' as project, 'HUB_PARTY' as hub,
       count(*) as source_distinct_keys,
       count(h.PARTY_HKEY) as hub_present_keys,
       count(*) - count(h.PARTY_HKEY) as diff
  from src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY h
         on h.PARTY_HKEY = s.HKEY;


----------------------------------------------------------------------------------------
-- OPUS :: HUB_AGENT
----------------------------------------------------------------------------------------
with src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_AGENT|' || nullif(trim(to_varchar(INTERMEDIARY_ID)), '') AS VARCHAR), '')))) as HKEY
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_INTERMEDIARY
     where nullif(trim(to_varchar(INTERMEDIARY_ID)), '') is not null
)
select 'OPUS' as project, 'HUB_AGENT' as hub,
       count(*) as source_distinct_keys,
       count(h.AGENT_HKEY) as hub_present_keys,
       count(*) - count(h.AGENT_HKEY) as diff
  from src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_AGENT h
         on h.AGENT_HKEY = s.HKEY;


----------------------------------------------------------------------------------------
-- OPUS :: HUB_AGREEMENT
----------------------------------------------------------------------------------------
with src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_AGREEMENT|' || nullif(trim(to_varchar(INTERMEDIARY_ID)), '') AS VARCHAR), '')))) as HKEY
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_INTERMEDIARY
     where nullif(trim(to_varchar(INTERMEDIARY_ID)), '') is not null
)
select 'OPUS' as project, 'HUB_AGREEMENT' as hub,
       count(*) as source_distinct_keys,
       count(h.AGREEMENT_HKEY) as hub_present_keys,
       count(*) - count(h.AGREEMENT_HKEY) as diff
  from src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_AGREEMENT h
         on h.AGREEMENT_HKEY = s.HKEY;


----------------------------------------------------------------------------------------
-- OPUS :: HUB_CLAIM
----------------------------------------------------------------------------------------
with src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_CLAIM|' || nullif(trim(to_varchar(CLAIM_ID)), '') AS VARCHAR), '')))) as HKEY
      from BAGIC_PREPROD_CURATED_DB.UTILS.CLM_INTERESTED_PARTIES
     where nullif(trim(to_varchar(CLAIM_ID)), '') is not null
)
select 'OPUS' as project, 'HUB_CLAIM' as hub,
       count(*) as source_distinct_keys,
       count(h.CLAIM_HKEY) as hub_present_keys,
       count(*) - count(h.CLAIM_HKEY) as diff
  from src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_CLAIM h
         on h.CLAIM_HKEY = s.HKEY;


----------------------------------------------------------------------------------------
-- OPUS :: HUB_DISTRIBUTION_CHANNEL
----------------------------------------------------------------------------------------
with src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_DISTRIBUTION_CHANNEL|' || nullif(trim(to_varchar(INTERMEDIARY_ID)), '') AS VARCHAR), '')))) as HKEY
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_INTERMEDIARY
     where nullif(trim(to_varchar(INTERMEDIARY_ID)), '') is not null
)
select 'OPUS' as project, 'HUB_DISTRIBUTION_CHANNEL' as hub,
       count(*) as source_distinct_keys,
       count(h.DISTRIBUTION_CHANNEL_HKEY) as hub_present_keys,
       count(*) - count(h.DISTRIBUTION_CHANNEL_HKEY) as diff
  from src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DISTRIBUTION_CHANNEL h
         on h.DISTRIBUTION_CHANNEL_HKEY = s.HKEY;


----------------------------------------------------------------------------------------
-- OPUS :: HUB_LOCATION   (direct raw sources; stitch_common_address composite branch TODO)
----------------------------------------------------------------------------------------
with src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_LOCATION|' || nullif(trim(to_varchar(MAIL_ADD_ID)), '') AS VARCHAR), '')))) as HKEY
      from BAGIC_PREPROD_CURATED_DB.UTILS.AZBJ_PARTNER_EXTN
     where nullif(trim(to_varchar(MAIL_ADD_ID)), '') is not null
    union
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_LOCATION|' || nullif(trim(to_varchar(LOCATION_CODE)), '') AS VARCHAR), ''))))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CLM_SUPP_EXTN
     where nullif(trim(to_varchar(LOCATION_CODE)), '') is not null
    union
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_LOCATION|' || nullif(trim(to_varchar(ADD_ID)), '') AS VARCHAR), ''))))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CP_ADDRESS_LINK
     where nullif(trim(to_varchar(ADD_ID)), '') is not null
    union
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_LOCATION|' || nullif(trim(to_varchar(LOC_CODE)), '') AS VARCHAR), ''))))
      from BAGIC_PREPROD_CURATED_DB.UTILS.CLM_SUPPLIERS
     where nullif(trim(to_varchar(LOC_CODE)), '') is not null
    union
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_LOCATION|' || nullif(trim(to_varchar(ADD_ID)), '') AS VARCHAR), ''))))
      from BAGIC_PREPROD_CURATED_DB.UTILS.CP_PARTNERS
     where nullif(trim(to_varchar(ADD_ID)), '') is not null
    union
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_LOCATION|' || nullif(trim(to_varchar(MAILING_ADDRESS_ID)), '') AS VARCHAR), ''))))
      from BAGIC_PREPROD_CURATED_DB.UTILS.OCP_INTERESTED_PARTIES
     where nullif(trim(to_varchar(MAILING_ADDRESS_ID)), '') is not null
)
select 'OPUS' as project, 'HUB_LOCATION' as hub,
       count(*) as source_distinct_keys,
       count(h.LOCATION_HKEY) as hub_present_keys,
       count(*) - count(h.LOCATION_HKEY) as diff
  from src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOCATION h
         on h.LOCATION_HKEY = s.HKEY;


----------------------------------------------------------------------------------------
-- OPUS :: HUB_POLICY   (direct raw sources; stitched branches TODO)
----------------------------------------------------------------------------------------
with src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_POLICY|' || nullif(trim(to_varchar(CONTRACT_ID)), '') AS VARCHAR), '')))) as HKEY
      from BAGIC_PREPROD_CURATED_DB.UTILS.BA_HCP_DT_MEM
     where nullif(trim(to_varchar(CONTRACT_ID)), '') is not null
    union
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_POLICY|' || nullif(trim(to_varchar(CONTRACT_ID)), '') AS VARCHAR), ''))))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CTNGY_FF_DTLS_EXTN
     where nullif(trim(to_varchar(CONTRACT_ID)), '') is not null
    union
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_POLICY|' || nullif(trim(to_varchar(POLICY_NUMBER)), '') AS VARCHAR), ''))))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_HCF_MEMBER_DTLS
     where nullif(trim(to_varchar(POLICY_NUMBER)), '') is not null
    union
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_POLICY|' || nullif(trim(to_varchar(POLICY_NUMBER)), '') AS VARCHAR), ''))))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_SPP_MEMBER_DTLS
     where nullif(trim(to_varchar(POLICY_NUMBER)), '') is not null
    union
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_POLICY|' || nullif(trim(to_varchar(CONTRACT_ID)), '') AS VARCHAR), ''))))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_STARPKG_FF_DTLS
     where nullif(trim(to_varchar(CONTRACT_ID)), '') is not null
    union
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_POLICY|' || nullif(trim(to_varchar(CONTRACT_ID)), '') AS VARCHAR), ''))))
      from BAGIC_PREPROD_CURATED_DB.UTILS.OCP_INTERESTED_PARTIES
     where nullif(trim(to_varchar(CONTRACT_ID)), '') is not null
)
select 'OPUS' as project, 'HUB_POLICY' as hub,
       count(*) as source_distinct_keys,
       count(h.POLICY_HKEY) as hub_present_keys,
       count(*) - count(h.POLICY_HKEY) as diff
  from src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY h
         on h.POLICY_HKEY = s.HKEY;


----------------------------------------------------------------------------------------
-- OPUS :: HUB_PRODUCT
-- NA: fed only via stitch_product_definition; raw key not confirmed as a single column.
----------------------------------------------------------------------------------------
-- (intentionally NA -- see DM-K1)


----------------------------------------------------------------------------------------
-- OPUS :: HUB_RISK_OBJECT
----------------------------------------------------------------------------------------
with src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_RISK_OBJECT|' || nullif(trim(to_varchar(INS_OBJ_UID)), '') AS VARCHAR), '')))) as HKEY
      from BAGIC_PREPROD_CURATED_DB.UTILS.CLM_INTERESTED_PARTIES
     where nullif(trim(to_varchar(INS_OBJ_UID)), '') is not null
)
select 'OPUS' as project, 'HUB_RISK_OBJECT' as hub,
       count(*) as source_distinct_keys,
       count(h.RISK_OBJECT_HKEY) as hub_present_keys,
       count(*) - count(h.RISK_OBJECT_HKEY) as diff
  from src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_RISK_OBJECT h
         on h.RISK_OBJECT_HKEY = s.HKEY;
