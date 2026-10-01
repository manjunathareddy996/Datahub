/* =====================================================================================
   DM-K1  |  Key checks  |  "No missing keys"
   Sign-off: Every SF Mirror source business key exists in the hub.
   Method:   anti-join  RAW source  ->  HUB   (reconcile against RAW tables, NOT views,
             so a defect in the stg/stitch/unpivot view layer cannot mask a real gap).
   Pass:     0 rows returned (0 missing keys, or documented exceptions).

   HKEY reproduction (AutomateDV default MD5 on Snowflake -> stored as BINARY(16)):
       HKEY = MD5_BINARY(UPPER(TRIM(COALESCE(CAST( <NK> AS VARCHAR), ''))))
       <NK> = 'HUB_<ENTITY>|' || <trimmed raw key>
       NOTE: use MD5_BINARY (not MD5). The hub HKEY column is BINARY(16); MD5() returns
       a VARCHAR(32) hex string and the join fails with a type-conversion error.
       trimmed raw key = nullif(trim(to_varchar(<RAW_COL>)), '')

   Fully-qualified names:
     Vault (both projects) : BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL
     Maximus RAW           : BAGIC_PROD_MIRROR_DB.MAXI_RAW
     Opus RAW (test)       : BAGIC_PREPROD_CURATED_DB.UTILS   (source 'partner_test_raw')

   Shared vault: both projects write the SAME physical hub tables. Rows are separated by
   RECORD_SOURCE prefix (MAXIMUS_% vs OPUS_%); each query is scoped to its own project's
   prefix so one project's keys are not checked against the other project's rows.
   ===================================================================================== */


/* =====================================================================================
   MAXIMUS PROJECT
   ===================================================================================== */

----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_PARTY   (NK prefix 'HUB_PARTY|')
----------------------------------------------------------------------------------------
with maxi_hub_party_src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(PARTY_CODE)), '') AS VARCHAR), '')))) as PARTY_HKEY
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
select 'MAXIMUS' as project, 'HUB_PARTY' as hub, s.PARTY_HKEY as missing_hkey
  from maxi_hub_party_src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY h
         on h.PARTY_HKEY = s.PARTY_HKEY
        and h.RECORD_SOURCE like 'MAXIMUS_%'
 where h.PARTY_HKEY is null;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_STAKE_CODE   (NK prefix 'HUB_STAKE_CODE|')
----------------------------------------------------------------------------------------
with maxi_hub_stake_code_src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_STAKE_CODE|' || nullif(trim(to_varchar(STAKE_CODE)), '') AS VARCHAR), '')))) as STAKE_CODE_HKEY
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY
     where nullif(trim(to_varchar(STAKE_CODE)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_STAKE_CODE' as hub, s.STAKE_CODE_HKEY as missing_hkey
  from maxi_hub_stake_code_src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_STAKE_CODE h
         on h.STAKE_CODE_HKEY = s.STAKE_CODE_HKEY
        and h.RECORD_SOURCE like 'MAXIMUS_%'
 where h.STAKE_CODE_HKEY is null;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_LOCATION   (NK prefix 'HUB_LOCATION|')
-- COMPOSITE KEY: LOCATION_BK = md5(concat_ws('|', upper(trim(<addr cols>)))). The column
-- list differs per source; each branch below mirrors that source's exact stg2 expression,
-- with raw columns wrapped as the layer-1 model does: nullif(trim(to_varchar("COL")),'').
--   Source 1  stg2_mp__pd_addr                (BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS)
--   Source 2  stg2_mp__pd_party_addr_prop_pv  (..._PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW)
--   Source 3  stg2_mp__pd_prop_sp_pv          (..._SIMPLE_PROPERTY_PIVOT_VW_2_1)
----------------------------------------------------------------------------------------
with maxi_hub_location_src as (
    -- Source 1: PARTY_ADDRESS  (address1, address2, address3, city, district, state, pincode, country)
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_LOCATION|' || md5(concat_ws('|',
               upper(trim(to_varchar(nullif(trim(to_varchar("ADDRESS1")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("ADDRESS2")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("ADDRESS3")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("CITY")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("DISTRICT")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("STATE")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("PINCODE")), '')))),
               upper(trim(to_varchar(nullif(trim(to_varchar("COUNTRY")), ''))))
           )) AS VARCHAR), '')))) as LOCATION_HKEY
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS
    union
    -- Source 2: ADDRESS_PROPERTY_PIVOT  (land_mark, area, post_office, city, state, pincode)
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
    -- Source 3: SIMPLE_PROPERTY_PIVOT  (our_office_address, overseas line_2, line_3, city_town_village,
    --                                   local district, overseas state_ut, local pin_code, overseas country)
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
select 'MAXIMUS' as project, 'HUB_LOCATION' as hub, s.LOCATION_HKEY as missing_hkey
  from maxi_hub_location_src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOCATION h
         on h.LOCATION_HKEY = s.LOCATION_HKEY
        and h.RECORD_SOURCE like 'MAXIMUS_%'
 where h.LOCATION_HKEY is null;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_PAYMENT_INSTRUMENT   (NK prefix 'HUB_PAYMENT_INSTRUMENT|')
-- IMPORTANT: the stg2 model double-prefixes the NK:
--   PAYMENT_INSTRUMENT_BK = 'HUB_PAYMENT_INSTRUMENT|' || foreign_key
--   PAYMENT_INSTRUMENT_NK = 'HUB_PAYMENT_INSTRUMENT|' || PAYMENT_INSTRUMENT_BK
-- so the hashed string is 'HUB_PAYMENT_INSTRUMENT|HUB_PAYMENT_INSTRUMENT|' || foreign_key.
-- (This looks like a modelling defect, but the test must match what was actually loaded.)
----------------------------------------------------------------------------------------
with maxi_hub_payment_instrument_src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_PAYMENT_INSTRUMENT|HUB_PAYMENT_INSTRUMENT|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), '')))) as PAYMENT_INSTRUMENT_HKEY
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_PAYMENT_INSTRUMENT' as hub, s.PAYMENT_INSTRUMENT_HKEY as missing_hkey
  from maxi_hub_payment_instrument_src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PAYMENT_INSTRUMENT h
         on h.PAYMENT_INSTRUMENT_HKEY = s.PAYMENT_INSTRUMENT_HKEY
        and h.RECORD_SOURCE like 'MAXIMUS_%'
 where h.PAYMENT_INSTRUMENT_HKEY is null;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_PRODUCT   (NK prefix 'HUB_PRODUCT|')
----------------------------------------------------------------------------------------
with maxi_hub_product_src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_PRODUCT|' || nullif(trim(to_varchar(PRODUCT_CODE)), '') AS VARCHAR), '')))) as PRODUCT_HKEY
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1
     where nullif(trim(to_varchar(PRODUCT_CODE)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_PRODUCT' as hub, s.PRODUCT_HKEY as missing_hkey
  from maxi_hub_product_src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PRODUCT h
         on h.PRODUCT_HKEY = s.PRODUCT_HKEY
        and h.RECORD_SOURCE like 'MAXIMUS_%'
 where h.PRODUCT_HKEY is null;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_FINANCIAL_ACCOUNT   (NK prefix 'HUB_FINANCIAL_ACCOUNT|')
-- NOT APPLICABLE for Maximus at present. The business key FINANCIAL_ACCOUNT_BK is derived
-- from `account_code`, but the layer-1 model stg_maximus__pd_prop_msdp_pv sets
--     cast(null as varchar) as account_code
-- i.e. ACCOUNT_CODE is NOT yet mapped from the source JSON (remapping required). The
-- source therefore contributes zero business keys, so there is nothing to reconcile.
-- Re-enable this check once ACCOUNT_CODE is correctly mapped in the staging layer.
----------------------------------------------------------------------------------------
-- (intentionally NA until account_code is mapped)


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_DOCUMENT   (NK prefix 'HUB_DOCUMENT|')
----------------------------------------------------------------------------------------
with maxi_hub_document_src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_DOCUMENT|' || nullif(trim(to_varchar(DOCUMENT_ID)), '') AS VARCHAR), '')))) as DOCUMENT_HKEY
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_DOCUMENT_DETAIL
     where nullif(trim(to_varchar(DOCUMENT_ID)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_DOCUMENT' as hub, s.DOCUMENT_HKEY as missing_hkey
  from maxi_hub_document_src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DOCUMENT h
         on h.DOCUMENT_HKEY = s.DOCUMENT_HKEY
        and h.RECORD_SOURCE like 'MAXIMUS_%'
 where h.DOCUMENT_HKEY is null;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_POLICY   (NK prefix 'HUB_POLICY|')
----------------------------------------------------------------------------------------
with maxi_hub_policy_src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_POLICY|' || nullif(trim(to_varchar(PA_POLICY)), '') AS VARCHAR), '')))) as POLICY_HKEY
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1
     where nullif(trim(to_varchar(PA_POLICY)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_POLICY' as hub, s.POLICY_HKEY as missing_hkey
  from maxi_hub_policy_src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY h
         on h.POLICY_HKEY = s.POLICY_HKEY
        and h.RECORD_SOURCE like 'MAXIMUS_%'
 where h.POLICY_HKEY is null;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_DISTRIBUTION_CHANNEL   (NK prefix 'HUB_DISTRIBUTION_CHANNEL|')
----------------------------------------------------------------------------------------
with maxi_hub_distribution_channel_src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_DISTRIBUTION_CHANNEL|' || nullif(trim(to_varchar(AGENT_CHANNEL)), '') AS VARCHAR), '')))) as DISTRIBUTION_CHANNEL_HKEY
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1
     where nullif(trim(to_varchar(AGENT_CHANNEL)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_DISTRIBUTION_CHANNEL' as hub, s.DISTRIBUTION_CHANNEL_HKEY as missing_hkey
  from maxi_hub_distribution_channel_src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DISTRIBUTION_CHANNEL h
         on h.DISTRIBUTION_CHANNEL_HKEY = s.DISTRIBUTION_CHANNEL_HKEY
        and h.RECORD_SOURCE like 'MAXIMUS_%'
 where h.DISTRIBUTION_CHANNEL_HKEY is null;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_ORG_UNIT   (NK prefix 'HUB_ORG_UNIT|')
-- Only ONE source actually contributes a key: `company` from the multi-set pivot.
-- The simple-pivot branch derived ORG_UNIT_BK from `branch_code`, but the layer-1 model
-- stg_maximus__pd_prop_sp_pv sets  cast(null as varchar) as branch_code  (the real raw
-- column is BRANCH and is deliberately not used as the key). That branch contributes no
-- keys, so it is excluded here to avoid false "missing key" findings ("Invalid branch code").
----------------------------------------------------------------------------------------
with maxi_hub_org_unit_src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_ORG_UNIT|' || nullif(trim(to_varchar(COMPANY)), '') AS VARCHAR), '')))) as ORG_UNIT_HKEY
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
     where nullif(trim(to_varchar(COMPANY)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_ORG_UNIT' as hub, s.ORG_UNIT_HKEY as missing_hkey
  from maxi_hub_org_unit_src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_ORG_UNIT h
         on h.ORG_UNIT_HKEY = s.ORG_UNIT_HKEY
        and h.RECORD_SOURCE like 'MAXIMUS_%'
 where h.ORG_UNIT_HKEY is null;


/* =====================================================================================
   OPUS PROJECT
   ===================================================================================== */

----------------------------------------------------------------------------------------
-- OPUS :: HUB_PARTY   (NK prefix 'HUB_PARTY|')
----------------------------------------------------------------------------------------
with opus_hub_party_src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(PART_ID)), '') AS VARCHAR), '')))) as PARTY_HKEY
      from BAGIC_PREPROD_CURATED_DB.UTILS.CP_PARTNERS
     where nullif(trim(to_varchar(PART_ID)), '') is not null
)
select 'OPUS' as project, 'HUB_PARTY' as hub, s.PARTY_HKEY as missing_hkey
  from opus_hub_party_src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY h
         on h.PARTY_HKEY = s.PARTY_HKEY
        and h.RECORD_SOURCE like 'OPUS_%'
 where h.PARTY_HKEY is null;


----------------------------------------------------------------------------------------
-- OPUS :: HUB_AGENT   (NK prefix 'HUB_AGENT|')
----------------------------------------------------------------------------------------
with opus_hub_agent_src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_AGENT|' || nullif(trim(to_varchar(INTERMEDIARY_ID)), '') AS VARCHAR), '')))) as AGENT_HKEY
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_INTERMEDIARY
     where nullif(trim(to_varchar(INTERMEDIARY_ID)), '') is not null
)
select 'OPUS' as project, 'HUB_AGENT' as hub, s.AGENT_HKEY as missing_hkey
  from opus_hub_agent_src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_AGENT h
         on h.AGENT_HKEY = s.AGENT_HKEY
        and h.RECORD_SOURCE like 'OPUS_%'
 where h.AGENT_HKEY is null;


----------------------------------------------------------------------------------------
-- OPUS :: HUB_AGREEMENT   (NK prefix 'HUB_AGREEMENT|')
----------------------------------------------------------------------------------------
with opus_hub_agreement_src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_AGREEMENT|' || nullif(trim(to_varchar(INTERMEDIARY_ID)), '') AS VARCHAR), '')))) as AGREEMENT_HKEY
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_INTERMEDIARY
     where nullif(trim(to_varchar(INTERMEDIARY_ID)), '') is not null
)
select 'OPUS' as project, 'HUB_AGREEMENT' as hub, s.AGREEMENT_HKEY as missing_hkey
  from opus_hub_agreement_src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_AGREEMENT h
         on h.AGREEMENT_HKEY = s.AGREEMENT_HKEY
        and h.RECORD_SOURCE like 'OPUS_%'
 where h.AGREEMENT_HKEY is null;


----------------------------------------------------------------------------------------
-- OPUS :: HUB_CLAIM   (NK prefix 'HUB_CLAIM|')
----------------------------------------------------------------------------------------
with opus_hub_claim_src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_CLAIM|' || nullif(trim(to_varchar(CLAIM_ID)), '') AS VARCHAR), '')))) as CLAIM_HKEY
      from BAGIC_PREPROD_CURATED_DB.UTILS.CLM_INTERESTED_PARTIES
     where nullif(trim(to_varchar(CLAIM_ID)), '') is not null
)
select 'OPUS' as project, 'HUB_CLAIM' as hub, s.CLAIM_HKEY as missing_hkey
  from opus_hub_claim_src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_CLAIM h
         on h.CLAIM_HKEY = s.CLAIM_HKEY
        and h.RECORD_SOURCE like 'OPUS_%'
 where h.CLAIM_HKEY is null;


----------------------------------------------------------------------------------------
-- OPUS :: HUB_DISTRIBUTION_CHANNEL   (NK prefix 'HUB_DISTRIBUTION_CHANNEL|')
-- (Second branch BJAZ_CLM_SUPP_EXTN does not contribute the channel key -> omitted.)
----------------------------------------------------------------------------------------
with opus_hub_distribution_channel_src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_DISTRIBUTION_CHANNEL|' || nullif(trim(to_varchar(INTERMEDIARY_ID)), '') AS VARCHAR), '')))) as DISTRIBUTION_CHANNEL_HKEY
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_INTERMEDIARY
     where nullif(trim(to_varchar(INTERMEDIARY_ID)), '') is not null
)
select 'OPUS' as project, 'HUB_DISTRIBUTION_CHANNEL' as hub, s.DISTRIBUTION_CHANNEL_HKEY as missing_hkey
  from opus_hub_distribution_channel_src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DISTRIBUTION_CHANNEL h
         on h.DISTRIBUTION_CHANNEL_HKEY = s.DISTRIBUTION_CHANNEL_HKEY
        and h.RECORD_SOURCE like 'OPUS_%'
 where h.DISTRIBUTION_CHANNEL_HKEY is null;


----------------------------------------------------------------------------------------
-- OPUS :: HUB_LOCATION   (NK prefix 'HUB_LOCATION|')
-- Direct single-column raw sources implemented below.
-- NOTE: stg2_common_address feeds this hub via stitch_common_address (COMPOSITE key).
-- >>> TODO: add that composite-key branch once its concat_ws(...) column list is confirmed.
----------------------------------------------------------------------------------------
with opus_hub_location_src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_LOCATION|' || nullif(trim(to_varchar(MAIL_ADD_ID)), '') AS VARCHAR), '')))) as LOCATION_HKEY
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
select 'OPUS' as project, 'HUB_LOCATION' as hub, s.LOCATION_HKEY as missing_hkey
  from opus_hub_location_src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOCATION h
         on h.LOCATION_HKEY = s.LOCATION_HKEY
        and h.RECORD_SOURCE like 'OPUS_%'
 where h.LOCATION_HKEY is null;


----------------------------------------------------------------------------------------
-- OPUS :: HUB_POLICY   (NK prefix 'HUB_POLICY|')
-- Direct single-column raw sources implemented below.
-- NOTE: stg2_policy_header / stg2_policy_bonus_tracking feed via stitches (NOT included).
-- >>> TODO: add stitched branches once their raw key resolution is confirmed.
----------------------------------------------------------------------------------------
with opus_hub_policy_src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_POLICY|' || nullif(trim(to_varchar(CONTRACT_ID)), '') AS VARCHAR), '')))) as POLICY_HKEY
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
select 'OPUS' as project, 'HUB_POLICY' as hub, s.POLICY_HKEY as missing_hkey
  from opus_hub_policy_src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY h
         on h.POLICY_HKEY = s.POLICY_HKEY
        and h.RECORD_SOURCE like 'OPUS_%'
 where h.POLICY_HKEY is null;


----------------------------------------------------------------------------------------
-- OPUS :: HUB_PRODUCT   (NK prefix 'HUB_PRODUCT|')
-- Fed ONLY via stg2_product_definition -> stitch_product_definition (stitched source).
-- >>> TODO: raw table + raw key for the PRODUCT_DEFINITION stitch not yet confirmed as a
--     single raw column. Implement once the stitch's underlying raw key is verified.
----------------------------------------------------------------------------------------
-- (intentionally unimplemented to avoid a silently-wrong check)


----------------------------------------------------------------------------------------
-- OPUS :: HUB_RISK_OBJECT   (NK prefix 'HUB_RISK_OBJECT|')
----------------------------------------------------------------------------------------
with opus_hub_risk_object_src as (
    select distinct MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_RISK_OBJECT|' || nullif(trim(to_varchar(INS_OBJ_UID)), '') AS VARCHAR), '')))) as RISK_OBJECT_HKEY
      from BAGIC_PREPROD_CURATED_DB.UTILS.CLM_INTERESTED_PARTIES
     where nullif(trim(to_varchar(INS_OBJ_UID)), '') is not null
)
select 'OPUS' as project, 'HUB_RISK_OBJECT' as hub, s.RISK_OBJECT_HKEY as missing_hkey
  from opus_hub_risk_object_src s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_RISK_OBJECT h
         on h.RISK_OBJECT_HKEY = s.RISK_OBJECT_HKEY
        and h.RECORD_SOURCE like 'OPUS_%'
 where h.RISK_OBJECT_HKEY is null;


/* =====================================================================================
   DM-K1 DIAGNOSTIC :: MAXIMUS HUB_PARTY  --  break the missing keys down BY SOURCE.
   Run this to see which contributing source produces the missing PARTY_HKEYs.
   Each branch tags its source so the result groups the gap by origin table.
   ===================================================================================== */
with maxi_party_src_tagged as (
    select 'pd (PARTY_CODE)'                   as src_tag,
           nullif(trim(to_varchar(PARTY_CODE)), '')      as bk,
           MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(PARTY_CODE)), '') AS VARCHAR), '')))) as PARTY_HKEY
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL
     where nullif(trim(to_varchar(PARTY_CODE)), '') is not null
    union all
    select 'pd_addr (FOREIGN_KEY)', nullif(trim(to_varchar(FOREIGN_KEY)), ''),
           MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), ''))))
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
    union all
    select 'pd_party_addr_prop_pv (FOREIGN_KEY)', nullif(trim(to_varchar(FOREIGN_KEY)), ''),
           MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), ''))))
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
    union all
    select 'pd_prop_msdp_pv (FOREIGN_KEY)', nullif(trim(to_varchar(FOREIGN_KEY)), ''),
           MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), ''))))
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
    union all
    select 'pd_prop_sp_pv (BAGIC_EMPLOYEE_CODE)', nullif(trim(to_varchar(BAGIC_EMPLOYEE_CODE)), ''),
           MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(BAGIC_EMPLOYEE_CODE)), '') AS VARCHAR), ''))))
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1
     where nullif(trim(to_varchar(BAGIC_EMPLOYEE_CODE)), '') is not null
    union all
    select 'pd_rel (FOREIGN_KEY)', nullif(trim(to_varchar(FOREIGN_KEY)), ''),
           MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), ''))))
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_RELATION
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
    union all
    select 'pd_relparty (FOREIGN_KEY)', nullif(trim(to_varchar(FOREIGN_KEY)), ''),
           MD5_BINARY(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), ''))))
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
)
select s.src_tag,
       count(distinct s.PARTY_HKEY)                                             as source_distinct_keys,
       count(distinct case when h.PARTY_HKEY is null then s.PARTY_HKEY end)      as missing_keys,
       min(case when h.PARTY_HKEY is null then s.bk end)                         as sample_missing_bk
  from maxi_party_src_tagged s
  left join BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY h
         on h.PARTY_HKEY = s.PARTY_HKEY
        and h.RECORD_SOURCE like 'MAXIMUS_%'
 group by s.src_tag
 order by missing_keys desc;
