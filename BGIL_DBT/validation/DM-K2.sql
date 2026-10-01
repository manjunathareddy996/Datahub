/* =====================================================================================
   DM-K2  |  Key checks  |  "No extra / unexpected keys"
   Sign-off: Every hub business key exists in the SF Mirror source.
   Method:   anti-join  HUB  ->  RAW source (RAW Mirror tables, NOT the stg/stitch/unpivot/
             hubfeed views).
   Pass:     every query in sections 1-19 returns 0 rows. Section 20 is informational.

   The queries below are IDENTICAL to those in DM-K2.docx (the sign-off evidence document).

   HKEY reproduction (automate_dv 0.11.5, Snowflake):
       HKEY = MD5_BINARY(NULLIF(UPPER(TRIM(CAST(<NK> AS VARCHAR))), ''))   -- BINARY(16)
       <NK> = 'HUB_<ENTITY>|' || <key>,  <key> = nullif(trim(<RAW_COL>::varchar), '')

   Shared vault: hub rows are scoped by RECORD_SOURCE prefix (MAXIMUS_ / OPUS_) and checked
   only against that project's RAW tables.

   Schemas used:
     Vault        BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL
     Maximus RAW  BAGIC_PROD_MIRROR_DB.MAXI_RAW
     Opus RAW     BAGIC_PREPROD_CURATED_DB.UTILS   (test; prod = BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE)
   ===================================================================================== */

----------------------------------------------------------------------------------------
-- 1. MAXIMUS — HUB_PARTY
-- All 15 hubfeed_party branches resolve to these 7 raw key columns.
-- SIMPLE_PROPERTY_PIVOT_VW (stage + every sp_pv unpivot) keys on BAGIC_EMPLOYEE_CODE,
-- not FOREIGN_KEY.
----------------------------------------------------------------------------------------
with maxi_hub_party_src as (
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PARTY|' || nullif(trim(to_varchar(PARTY_CODE)), ''))), '')) as hkey
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), ''))), ''))
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), ''))), ''))
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), ''))), ''))
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), ''))), ''))
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_RELATION
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), ''))), ''))
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PARTY|' || nullif(trim(to_varchar(BAGIC_EMPLOYEE_CODE)), ''))), ''))
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
)
select 'MAXIMUS' as project, 'HUB_PARTY' as hub,
       h.PARENT_BK as unexpected_bk, h.PARTY_HKEY as unexpected_hkey, h.RECORD_SOURCE
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY h
 where startswith(h.RECORD_SOURCE, 'MAXIMUS_')
   and not exists (select 1 from maxi_hub_party_src s where s.hkey = h.PARTY_HKEY);

----------------------------------------------------------------------------------------
-- 2. MAXIMUS — HUB_STAKE_CODE
-- Business key column is STAKE_CODE_BK (not PARENT_BK) in this hub.
----------------------------------------------------------------------------------------
with maxi_hub_stake_code_src as (
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_STAKE_CODE|' || nullif(trim(to_varchar(STAKE_CODE)), ''))), '')) as hkey
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY
)
select 'MAXIMUS' as project, 'HUB_STAKE_CODE' as hub,
       h.STAKE_CODE_BK as unexpected_bk, h.STAKE_CODE_HKEY as unexpected_hkey, h.RECORD_SOURCE
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_STAKE_CODE h
 where startswith(h.RECORD_SOURCE, 'MAXIMUS_')
   and not exists (select 1 from maxi_hub_stake_code_src s where s.hkey = h.STAKE_CODE_HKEY);

----------------------------------------------------------------------------------------
-- 3. MAXIMUS — HUB_LOCATION
-- COMPOSITE KEY: LOCATION_BK = md5(concat_ws('|', ...)) over address columns. Column
-- list and order copied exactly from the LOCATION_BK derived column of
-- stg2_mp__pd_addr, stg2_mp__pd_party_addr_prop_pv and stg2_mp__pd_prop_sp_pv.
-- concat_ws returns NULL if any part is NULL, so such rows produce no hub key (same as
-- the model).
----------------------------------------------------------------------------------------
with maxi_hub_location_src as (
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || md5(concat_ws('|',
                   upper(nullif(trim(to_varchar(ADDRESS1)), '')),
                   upper(nullif(trim(to_varchar(ADDRESS2)), '')),
                   upper(nullif(trim(to_varchar(ADDRESS3)), '')),
                   upper(nullif(trim(to_varchar(CITY)), '')),
                   upper(nullif(trim(to_varchar(DISTRICT)), '')),
                   upper(nullif(trim(to_varchar(STATE)), '')),
                   upper(nullif(trim(to_varchar(PINCODE)), '')),
                   upper(nullif(trim(to_varchar(COUNTRY)), '')))))), '')) as hkey
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || md5(concat_ws('|',
                   upper(nullif(trim(to_varchar(LAND_MARK)), '')),
                   upper(nullif(trim(to_varchar(AREA)), '')),
                   upper(nullif(trim(to_varchar(POST_OFFICE)), '')),
                   upper(nullif(trim(to_varchar(CITY)), '')),
                   upper(nullif(trim(to_varchar(STATE)), '')),
                   upper(nullif(trim(to_varchar(PINCODE)), '')))))), ''))
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || md5(concat_ws('|',
                   upper(nullif(trim(to_varchar(OUR_OFFICE_ADDRESS)), '')),
                   upper(nullif(trim(to_varchar(CURRENT_PERMANENT_OVERSEAS_ADDRESS_LINE_2)), '')),
                   upper(nullif(trim(to_varchar(CURRENT_PERMANENT_OVERSEAS_ADDRESS_LINE_3)), '')),
                   upper(nullif(trim(to_varchar(CURRENT_PERMANENT_OVERSEAS_ADDRESS_CITY_TOWN_VILLAGE)), '')),
                   upper(nullif(trim(to_varchar(CORRESPONDENCE_LOCAL_ADDRESS_DISTRICT)), '')),
                   upper(nullif(trim(to_varchar(CURRENT_PERMANENT_OVERSEAS_ADDRESS_STATE_UT)), '')),
                   upper(nullif(trim(to_varchar(LOCAL_ADDRESS_PIN_CODE)), '')),
                   upper(nullif(trim(to_varchar(CURRENT_PERMANENT_OVERSEAS_ADDRESS_COUNTRY)), '')))))), ''))
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
)
select 'MAXIMUS' as project, 'HUB_LOCATION' as hub,
       h.PARENT_BK as unexpected_bk, h.LOCATION_HKEY as unexpected_hkey, h.RECORD_SOURCE
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOCATION h
 where startswith(h.RECORD_SOURCE, 'MAXIMUS_')
   and not exists (select 1 from maxi_hub_location_src s where s.hkey = h.LOCATION_HKEY);

----------------------------------------------------------------------------------------
-- 4. MAXIMUS — HUB_PAYMENT_INSTRUMENT
-- PAYMENT_INSTRUMENT_BK is already prefixed in stg2_mp__pd_prop_msdp_pv, so the NK is
-- double-prefixed ('HUB_PAYMENT_INSTRUMENT|HUB_PAYMENT_INSTRUMENT|<FOREIGN_KEY>').
-- Reproduced here.
----------------------------------------------------------------------------------------
with maxi_hub_payment_instrument_src as (
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PAYMENT_INSTRUMENT|' || 'HUB_PAYMENT_INSTRUMENT|' || nullif(trim(to_varchar(FOREIGN_KEY)), ''))), '')) as hkey
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
)
select 'MAXIMUS' as project, 'HUB_PAYMENT_INSTRUMENT' as hub,
       h.PARENT_BK as unexpected_bk, h.PAYMENT_INSTRUMENT_HKEY as unexpected_hkey, h.RECORD_SOURCE
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PAYMENT_INSTRUMENT h
 where startswith(h.RECORD_SOURCE, 'MAXIMUS_')
   and not exists (select 1 from maxi_hub_payment_instrument_src s where s.hkey = h.PAYMENT_INSTRUMENT_HKEY);

----------------------------------------------------------------------------------------
-- 5. MAXIMUS — HUB_PRODUCT
----------------------------------------------------------------------------------------
with maxi_hub_product_src as (
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PRODUCT|' || nullif(trim(to_varchar(PRODUCT_CODE)), ''))), '')) as hkey
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
)
select 'MAXIMUS' as project, 'HUB_PRODUCT' as hub,
       h.PARENT_BK as unexpected_bk, h.PRODUCT_HKEY as unexpected_hkey, h.RECORD_SOURCE
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PRODUCT h
 where startswith(h.RECORD_SOURCE, 'MAXIMUS_')
   and not exists (select 1 from maxi_hub_product_src s where s.hkey = h.PRODUCT_HKEY);

----------------------------------------------------------------------------------------
-- 6. MAXIMUS — HUB_FINANCIAL_ACCOUNT
-- No raw source: account_code is cast(null as varchar) in
-- stg_maximus__pd_prop_msdp_pv, so the model cannot produce a key. Expected 0 Maximus
-- rows; ANY row returned is an unexpected key.
----------------------------------------------------------------------------------------
-- No raw source can produce this key (see note): every row is unexpected.
select 'MAXIMUS' as project, 'HUB_FINANCIAL_ACCOUNT' as hub,
       h.PARENT_BK as unexpected_bk, h.FINANCIAL_ACCOUNT_HKEY as unexpected_hkey, h.RECORD_SOURCE
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_FINANCIAL_ACCOUNT h
 where startswith(h.RECORD_SOURCE, 'MAXIMUS_');

----------------------------------------------------------------------------------------
-- 7. MAXIMUS — HUB_DOCUMENT
----------------------------------------------------------------------------------------
with maxi_hub_document_src as (
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_DOCUMENT|' || nullif(trim(to_varchar(DOCUMENT_ID)), ''))), '')) as hkey
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_DOCUMENT_DETAIL
)
select 'MAXIMUS' as project, 'HUB_DOCUMENT' as hub,
       h.PARENT_BK as unexpected_bk, h.DOCUMENT_HKEY as unexpected_hkey, h.RECORD_SOURCE
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DOCUMENT h
 where startswith(h.RECORD_SOURCE, 'MAXIMUS_')
   and not exists (select 1 from maxi_hub_document_src s where s.hkey = h.DOCUMENT_HKEY);

----------------------------------------------------------------------------------------
-- 8. MAXIMUS — HUB_POLICY
----------------------------------------------------------------------------------------
with maxi_hub_policy_src as (
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim(to_varchar(PA_POLICY)), ''))), '')) as hkey
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
)
select 'MAXIMUS' as project, 'HUB_POLICY' as hub,
       h.PARENT_BK as unexpected_bk, h.POLICY_HKEY as unexpected_hkey, h.RECORD_SOURCE
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY h
 where startswith(h.RECORD_SOURCE, 'MAXIMUS_')
   and not exists (select 1 from maxi_hub_policy_src s where s.hkey = h.POLICY_HKEY);

----------------------------------------------------------------------------------------
-- 9. MAXIMUS — HUB_DISTRIBUTION_CHANNEL
----------------------------------------------------------------------------------------
with maxi_hub_distribution_channel_src as (
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_DISTRIBUTION_CHANNEL|' || nullif(trim(to_varchar(AGENT_CHANNEL)), ''))), '')) as hkey
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
)
select 'MAXIMUS' as project, 'HUB_DISTRIBUTION_CHANNEL' as hub,
       h.PARENT_BK as unexpected_bk, h.DISTRIBUTION_CHANNEL_HKEY as unexpected_hkey, h.RECORD_SOURCE
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DISTRIBUTION_CHANNEL h
 where startswith(h.RECORD_SOURCE, 'MAXIMUS_')
   and not exists (select 1 from maxi_hub_distribution_channel_src s where s.hkey = h.DISTRIBUTION_CHANNEL_HKEY);

----------------------------------------------------------------------------------------
-- 10. MAXIMUS — HUB_ORG_UNIT
-- The second branch (SIMPLE_PROPERTY_PIVOT_VW.branch_code) is cast(null) in staging
-- and contributes no keys, so only COMPANY is a legitimate source.
----------------------------------------------------------------------------------------
with maxi_hub_org_unit_src as (
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_ORG_UNIT|' || nullif(trim(to_varchar(COMPANY)), ''))), '')) as hkey
      from BAGIC_PROD_MIRROR_DB.MAXI_RAW.BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
)
select 'MAXIMUS' as project, 'HUB_ORG_UNIT' as hub,
       h.PARENT_BK as unexpected_bk, h.ORG_UNIT_HKEY as unexpected_hkey, h.RECORD_SOURCE
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_ORG_UNIT h
 where startswith(h.RECORD_SOURCE, 'MAXIMUS_')
   and not exists (select 1 from maxi_hub_org_unit_src s where s.hkey = h.ORG_UNIT_HKEY);

----------------------------------------------------------------------------------------
-- 11. OPUS — HUB_PARTY
-- hub_party.sql has a single branch (stg2_hub_cp_partners__party). Other
-- stg2_hub_*__party stages exist but do not feed the hub, so they are not legitimate
-- sources here.
----------------------------------------------------------------------------------------
with opus_hub_party_src as (
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PARTY|' || nullif(trim("PART_ID"::varchar), ''))), '')) as hkey
      from BAGIC_PREPROD_CURATED_DB.UTILS.CP_PARTNERS
)
select 'OPUS' as project, 'HUB_PARTY' as hub,
       h.PARENT_BK as unexpected_bk, h.PARTY_HKEY as unexpected_hkey, h.RECORD_SOURCE
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY h
 where startswith(h.RECORD_SOURCE, 'OPUS_')
   and not exists (select 1 from opus_hub_party_src s where s.hkey = h.PARTY_HKEY);

----------------------------------------------------------------------------------------
-- 12. OPUS — HUB_AGENT
----------------------------------------------------------------------------------------
with opus_hub_agent_src as (
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_AGENT|' || nullif(trim("INTERMEDIARY_ID"::varchar), ''))), '')) as hkey
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_INTERMEDIARY
)
select 'OPUS' as project, 'HUB_AGENT' as hub,
       h.PARENT_BK as unexpected_bk, h.AGENT_HKEY as unexpected_hkey, h.RECORD_SOURCE
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_AGENT h
 where startswith(h.RECORD_SOURCE, 'OPUS_')
   and not exists (select 1 from opus_hub_agent_src s where s.hkey = h.AGENT_HKEY);

----------------------------------------------------------------------------------------
-- 13. OPUS — HUB_AGREEMENT
----------------------------------------------------------------------------------------
with opus_hub_agreement_src as (
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_AGREEMENT|' || nullif(trim("INTERMEDIARY_ID"::varchar), ''))), '')) as hkey
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_INTERMEDIARY
)
select 'OPUS' as project, 'HUB_AGREEMENT' as hub,
       h.PARENT_BK as unexpected_bk, h.AGREEMENT_HKEY as unexpected_hkey, h.RECORD_SOURCE
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_AGREEMENT h
 where startswith(h.RECORD_SOURCE, 'OPUS_')
   and not exists (select 1 from opus_hub_agreement_src s where s.hkey = h.AGREEMENT_HKEY);

----------------------------------------------------------------------------------------
-- 14. OPUS — HUB_CLAIM
----------------------------------------------------------------------------------------
with opus_hub_claim_src as (
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_CLAIM|' || nullif(trim("CLAIM_ID"::varchar), ''))), '')) as hkey
      from BAGIC_PREPROD_CURATED_DB.UTILS.CLM_INTERESTED_PARTIES
)
select 'OPUS' as project, 'HUB_CLAIM' as hub,
       h.PARENT_BK as unexpected_bk, h.CLAIM_HKEY as unexpected_hkey, h.RECORD_SOURCE
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_CLAIM h
 where startswith(h.RECORD_SOURCE, 'OPUS_')
   and not exists (select 1 from opus_hub_claim_src s where s.hkey = h.CLAIM_HKEY);

----------------------------------------------------------------------------------------
-- 15. OPUS — HUB_DISTRIBUTION_CHANNEL
-- Both branches of hub_distribution_channel.sql are included.
-- stg2_hub_bjaz_clm_supp_extn__distribution_channel keys on IMD_CODE; leaving it out
-- would false-flag every IMD_CODE key as unexpected.
----------------------------------------------------------------------------------------
with opus_hub_distribution_channel_src as (
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_DISTRIBUTION_CHANNEL|' || nullif(trim("INTERMEDIARY_ID"::varchar), ''))), '')) as hkey
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_INTERMEDIARY
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_DISTRIBUTION_CHANNEL|' || nullif(trim("IMD_CODE"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CLM_SUPP_EXTN
)
select 'OPUS' as project, 'HUB_DISTRIBUTION_CHANNEL' as hub,
       h.PARENT_BK as unexpected_bk, h.DISTRIBUTION_CHANNEL_HKEY as unexpected_hkey, h.RECORD_SOURCE
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DISTRIBUTION_CHANNEL h
 where startswith(h.RECORD_SOURCE, 'OPUS_')
   and not exists (select 1 from opus_hub_distribution_channel_src s where s.hkey = h.DISTRIBUTION_CHANNEL_HKEY);

----------------------------------------------------------------------------------------
-- 16. OPUS — HUB_LOCATION
-- First 5 sources are the stitch_common_address branches (single-column key_column per
-- source, not composite); remaining 6 are the direct stg2_hub_*__location branches.
-- Stitch views are watermark-windowed, so raw tables are used instead.
----------------------------------------------------------------------------------------
with opus_hub_location_src as (
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || nullif(trim("ADD_ID"::varchar), ''))), '')) as hkey
      from BAGIC_PREPROD_CURATED_DB.UTILS.AZBJ_ADDRESS_EXTN
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || nullif(trim("BILLING_LOC"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CLM_SUPP_EXTN
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || nullif(trim("PINCODE"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_PINCODE
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || nullif(trim("PINCODE"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_PINCODE_MASTER
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || nullif(trim("ADD_ID"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.CP_ADDRESSES
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || nullif(trim("MAIL_ADD_ID"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.AZBJ_PARTNER_EXTN
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || nullif(trim("LOCATION_CODE"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CLM_SUPP_EXTN
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || nullif(trim("ADD_ID"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CP_ADDRESS_LINK
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || nullif(trim("LOC_CODE"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.CLM_SUPPLIERS
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || nullif(trim("ADD_ID"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.CP_PARTNERS
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_LOCATION|' || nullif(trim("MAILING_ADDRESS_ID"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.OCP_INTERESTED_PARTIES
)
select 'OPUS' as project, 'HUB_LOCATION' as hub,
       h.PARENT_BK as unexpected_bk, h.LOCATION_HKEY as unexpected_hkey, h.RECORD_SOURCE
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOCATION h
 where startswith(h.RECORD_SOURCE, 'OPUS_')
   and not exists (select 1 from opus_hub_location_src s where s.hkey = h.LOCATION_HKEY);

----------------------------------------------------------------------------------------
-- 17. OPUS — HUB_POLICY
-- Includes the stitched branches: stitch_policy_header
-- (AZBJ_PARTNER_EXTN.EXISTING_POLICY_PID, BJAZ_CTNGY_GC_MEM_DATA.POLICY_REF,
-- CONTRACT_ID of 8 member tables) and stitch_policy_bonus_tracking (adds
-- BJAZ_HLT_ENSURE_MEM_DTLS.CONTRACT_ID), plus the 6 direct stg2_hub_*__policy
-- branches.
----------------------------------------------------------------------------------------
with opus_hub_policy_src as (
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("EXISTING_POLICY_PID"::varchar), ''))), '')) as hkey
      from BAGIC_PREPROD_CURATED_DB.UTILS.AZBJ_PARTNER_EXTN
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("POLICY_REF"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CTNGY_GC_MEM_DATA
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CTNGY_PA_MEM_DTLS
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_EC_MEM_DTLS_EXTN
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_HCF_MEMBER_DTLS
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_HC_PART_EXTN
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_HM_MEMBER_DTLS
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_PA_DETL_EXTN
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_SH_MEM_DTLS_EXTN
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_SPP_MEMBER_DTLS
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_HLT_ENSURE_MEM_DTLS
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BA_HCP_DT_MEM
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CTNGY_FF_DTLS_EXTN
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("POLICY_NUMBER"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_HCF_MEMBER_DTLS
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("POLICY_NUMBER"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_SPP_MEMBER_DTLS
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_STARPKG_FF_DTLS
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_POLICY|' || nullif(trim("CONTRACT_ID"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.OCP_INTERESTED_PARTIES
)
select 'OPUS' as project, 'HUB_POLICY' as hub,
       h.PARENT_BK as unexpected_bk, h.POLICY_HKEY as unexpected_hkey, h.RECORD_SOURCE
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY h
 where startswith(h.RECORD_SOURCE, 'OPUS_')
   and not exists (select 1 from opus_hub_policy_src s where s.hkey = h.POLICY_HKEY);

----------------------------------------------------------------------------------------
-- 18. OPUS — HUB_PRODUCT
-- Fed only via stg2_product_definition -> stitch_product_definition. Raw keys resolved
-- from the stitch key_column of each of its 3 sources (single-column keys).
----------------------------------------------------------------------------------------
with opus_hub_product_src as (
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PRODUCT|' || nullif(trim("SCHEME_CODE"::varchar), ''))), '')) as hkey
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CTNGY_FF_DTLS_EXTN
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PRODUCT|' || nullif(trim("SCHEME_CODE"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_CTNGY_PA_MEM_DTLS
    union
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_PRODUCT|' || nullif(trim("PRODUCT_CODE"::varchar), ''))), ''))
      from BAGIC_PREPROD_CURATED_DB.UTILS.BJAZ_HM_MEMBER_DTLS
)
select 'OPUS' as project, 'HUB_PRODUCT' as hub,
       h.PARENT_BK as unexpected_bk, h.PRODUCT_HKEY as unexpected_hkey, h.RECORD_SOURCE
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PRODUCT h
 where startswith(h.RECORD_SOURCE, 'OPUS_')
   and not exists (select 1 from opus_hub_product_src s where s.hkey = h.PRODUCT_HKEY);

----------------------------------------------------------------------------------------
-- 19. OPUS — HUB_RISK_OBJECT
----------------------------------------------------------------------------------------
with opus_hub_risk_object_src as (
    select MD5_BINARY(NULLIF(UPPER(TRIM('HUB_RISK_OBJECT|' || nullif(trim("INS_OBJ_UID"::varchar), ''))), '')) as hkey
      from BAGIC_PREPROD_CURATED_DB.UTILS.CLM_INTERESTED_PARTIES
)
select 'OPUS' as project, 'HUB_RISK_OBJECT' as hub,
       h.PARENT_BK as unexpected_bk, h.RISK_OBJECT_HKEY as unexpected_hkey, h.RECORD_SOURCE
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_RISK_OBJECT h
 where startswith(h.RECORD_SOURCE, 'OPUS_')
   and not exists (select 1 from opus_hub_risk_object_src s where s.hkey = h.RISK_OBJECT_HKEY);

----------------------------------------------------------------------------------------
-- 20. MAXIMUS + OPUS — Ownership sweep (shared hubs)
-- Informational, not part of the pass criterion. Rows whose RECORD_SOURCE is neither
-- MAXIMUS_ nor OPUS_ are not covered by sections 1-19. Expected: 0 rows, or only
-- record sources of other known projects writing the same tables.
----------------------------------------------------------------------------------------
-- Informational: rows in shared hubs owned by neither project (not covered above).
select hub, RECORD_SOURCE, count(*) as rows_not_covered
  from (
        select 'HUB_PARTY' as hub, RECORD_SOURCE from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
        union all select 'HUB_LOCATION', RECORD_SOURCE from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOCATION
        union all select 'HUB_POLICY', RECORD_SOURCE from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY
        union all select 'HUB_PRODUCT', RECORD_SOURCE from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PRODUCT
        union all select 'HUB_DISTRIBUTION_CHANNEL', RECORD_SOURCE from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DISTRIBUTION_CHANNEL
       )
 where not startswith(RECORD_SOURCE, 'MAXIMUS_')
   and not startswith(RECORD_SOURCE, 'OPUS_')
 group by hub, RECORD_SOURCE
 order by hub, RECORD_SOURCE;
