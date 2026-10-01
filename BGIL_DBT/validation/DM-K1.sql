/* =====================================================================================
   DM-K1  |  Key checks  |  "No missing keys"
   Sign-off: Every SF Mirror source business key exists in the hub.
   Method:   anti-join  RAW source  ->  HUB   (reconcile against RAW tables, NOT views,
             so a defect in the stg/stitch/unpivot view layer cannot mask a real gap).
   Pass:     0 rows returned (0 missing keys, or documented exceptions).

   HKEY reproduction (identical macro in both projects):
       HKEY = MD5(UPPER(TRIM(COALESCE(CAST( <NK> AS VARCHAR), ''))))
       <NK> = 'HUB_<ENTITY>|' || <trimmed raw key>
       trimmed raw key = nullif(trim(to_varchar(<RAW_COL>)), '')

   Shared vault: both projects write the SAME physical hub tables in BGIL_DATA_MODEL.
   Rows are separated by RECORD_SOURCE prefix (MAXIMUS_% vs OPUS_%); each query is
   scoped to its own project's prefix so one project's keys are not checked against
   the other project's rows.

   Replace the schema placeholders before running:
     &VAULT_SCHEMA   -> BGIL_DATA_MODEL
     &MAXI_RAW       -> BAGIC_PROD_MIRROR_DB.MAXI_RAW
     &OPUS_RAW       -> BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE   (prod)
                        BAGIC_PREPROD_CURATED_DB.UTILS          (test)
   ===================================================================================== */


/* =====================================================================================
   MAXIMUS PROJECT
   ===================================================================================== */

----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_PARTY   (NK prefix 'HUB_PARTY|')
-- Multi-source: every raw table feeding PARTY_HKEY must have its keys present in the hub.
----------------------------------------------------------------------------------------
with maxi_hub_party_src as (
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(PARTY_CODE)), '') AS VARCHAR), '')))) as PARTY_HKEY
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL
     where nullif(trim(to_varchar(PARTY_CODE)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), ''))))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), ''))))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), ''))))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(BAGIC_EMPLOYEE_CODE)), '') AS VARCHAR), ''))))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1
     where nullif(trim(to_varchar(BAGIC_EMPLOYEE_CODE)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), ''))))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_RELATION
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), ''))))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_PARTY' as hub, s.PARTY_HKEY as missing_hkey
  from maxi_hub_party_src s
  left join &VAULT_SCHEMA..HUB_PARTY h
         on h.PARTY_HKEY = s.PARTY_HKEY
        and h.RECORD_SOURCE like 'MAXIMUS_%'
 where h.PARTY_HKEY is null;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_STAKE_CODE   (NK prefix 'HUB_STAKE_CODE|')
-- Raw: BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY, key STAKE_CODE
----------------------------------------------------------------------------------------
with maxi_hub_stake_code_src as (
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_STAKE_CODE|' || nullif(trim(to_varchar(STAKE_CODE)), '') AS VARCHAR), '')))) as STAKE_CODE_HKEY
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY
     where nullif(trim(to_varchar(STAKE_CODE)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_STAKE_CODE' as hub, s.STAKE_CODE_HKEY as missing_hkey
  from maxi_hub_stake_code_src s
  left join &VAULT_SCHEMA..HUB_STAKE_CODE h
         on h.STAKE_CODE_HKEY = s.STAKE_CODE_HKEY
        and h.RECORD_SOURCE like 'MAXIMUS_%'
 where h.STAKE_CODE_HKEY is null;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_LOCATION   (NK prefix 'HUB_LOCATION|')
-- COMPOSITE KEY: LOCATION_BK is an MD5 over several concatenated address columns, built
-- in each stg2 derived_columns. The exact column list / order differs per source and
-- MUST match the model exactly or this test will false-flag.
-- >>> TODO: paste the exact LOCATION_BK concat_ws(...) expression from each stg2 model:
--       stg2_mp__pd_addr                 (BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS)
--       stg2_mp__pd_party_addr_prop_pv   (..._PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW)
--       stg2_mp__pd_prop_sp_pv           (..._SIMPLE_PROPERTY_PIVOT_VW_2_1)
-- Pattern (per source):
--   with src as (
--     select distinct MD5(UPPER(TRIM(COALESCE(CAST(
--         'HUB_LOCATION|' || md5(concat_ws('|',
--             upper(trim(to_varchar(<col1>))), upper(trim(to_varchar(<col2>))), ...))
--     AS VARCHAR),'')))) as LOCATION_HKEY
--     from &MAXI_RAW..<RAW_TABLE>
--   )
--   select ... left join &VAULT_SCHEMA..HUB_LOCATION h
--          on h.LOCATION_HKEY = src.LOCATION_HKEY and h.RECORD_SOURCE like 'MAXIMUS_%'
--   where h.LOCATION_HKEY is null;
-- Left intentionally unimplemented to avoid a silently-wrong composite-key check.


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_PAYMENT_INSTRUMENT   (NK prefix 'HUB_PAYMENT_INSTRUMENT|')
-- Raw: ..._MULTI_SET_DETAIL_PROPERTY_PIVOT_VW, key FOREIGN_KEY
----------------------------------------------------------------------------------------
with maxi_hub_payment_instrument_src as (
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_PAYMENT_INSTRUMENT|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), '')))) as PAYMENT_INSTRUMENT_HKEY
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_PAYMENT_INSTRUMENT' as hub, s.PAYMENT_INSTRUMENT_HKEY as missing_hkey
  from maxi_hub_payment_instrument_src s
  left join &VAULT_SCHEMA..HUB_PAYMENT_INSTRUMENT h
         on h.PAYMENT_INSTRUMENT_HKEY = s.PAYMENT_INSTRUMENT_HKEY
        and h.RECORD_SOURCE like 'MAXIMUS_%'
 where h.PAYMENT_INSTRUMENT_HKEY is null;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_PRODUCT   (NK prefix 'HUB_PRODUCT|')
-- Raw: ..._SIMPLE_PROPERTY_PIVOT_VW_2_1, key PRODUCT_CODE
----------------------------------------------------------------------------------------
with maxi_hub_product_src as (
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_PRODUCT|' || nullif(trim(to_varchar(PRODUCT_CODE)), '') AS VARCHAR), '')))) as PRODUCT_HKEY
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1
     where nullif(trim(to_varchar(PRODUCT_CODE)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_PRODUCT' as hub, s.PRODUCT_HKEY as missing_hkey
  from maxi_hub_product_src s
  left join &VAULT_SCHEMA..HUB_PRODUCT h
         on h.PRODUCT_HKEY = s.PRODUCT_HKEY
        and h.RECORD_SOURCE like 'MAXIMUS_%'
 where h.PRODUCT_HKEY is null;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_FINANCIAL_ACCOUNT   (NK prefix 'HUB_FINANCIAL_ACCOUNT|')
-- Raw: ..._MULTI_SET_DETAIL_PROPERTY_PIVOT_VW, key ACCOUNT_CODE
----------------------------------------------------------------------------------------
with maxi_hub_financial_account_src as (
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_FINANCIAL_ACCOUNT|' || nullif(trim(to_varchar(ACCOUNT_CODE)), '') AS VARCHAR), '')))) as FINANCIAL_ACCOUNT_HKEY
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
     where nullif(trim(to_varchar(ACCOUNT_CODE)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_FINANCIAL_ACCOUNT' as hub, s.FINANCIAL_ACCOUNT_HKEY as missing_hkey
  from maxi_hub_financial_account_src s
  left join &VAULT_SCHEMA..HUB_FINANCIAL_ACCOUNT h
         on h.FINANCIAL_ACCOUNT_HKEY = s.FINANCIAL_ACCOUNT_HKEY
        and h.RECORD_SOURCE like 'MAXIMUS_%'
 where h.FINANCIAL_ACCOUNT_HKEY is null;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_DOCUMENT   (NK prefix 'HUB_DOCUMENT|')
-- Raw: BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_DOCUMENT_DETAIL, key DOCUMENT_ID
----------------------------------------------------------------------------------------
with maxi_hub_document_src as (
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_DOCUMENT|' || nullif(trim(to_varchar(DOCUMENT_ID)), '') AS VARCHAR), '')))) as DOCUMENT_HKEY
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_DOCUMENT_DETAIL
     where nullif(trim(to_varchar(DOCUMENT_ID)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_DOCUMENT' as hub, s.DOCUMENT_HKEY as missing_hkey
  from maxi_hub_document_src s
  left join &VAULT_SCHEMA..HUB_DOCUMENT h
         on h.DOCUMENT_HKEY = s.DOCUMENT_HKEY
        and h.RECORD_SOURCE like 'MAXIMUS_%'
 where h.DOCUMENT_HKEY is null;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_POLICY   (NK prefix 'HUB_POLICY|')
-- Raw: ..._SIMPLE_PROPERTY_PIVOT_VW_2_1, key PA_POLICY
----------------------------------------------------------------------------------------
with maxi_hub_policy_src as (
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_POLICY|' || nullif(trim(to_varchar(PA_POLICY)), '') AS VARCHAR), '')))) as POLICY_HKEY
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1
     where nullif(trim(to_varchar(PA_POLICY)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_POLICY' as hub, s.POLICY_HKEY as missing_hkey
  from maxi_hub_policy_src s
  left join &VAULT_SCHEMA..HUB_POLICY h
         on h.POLICY_HKEY = s.POLICY_HKEY
        and h.RECORD_SOURCE like 'MAXIMUS_%'
 where h.POLICY_HKEY is null;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_DISTRIBUTION_CHANNEL   (NK prefix 'HUB_DISTRIBUTION_CHANNEL|')
-- Raw: ..._SIMPLE_PROPERTY_PIVOT_VW_2_1, key AGENT_CHANNEL
----------------------------------------------------------------------------------------
with maxi_hub_distribution_channel_src as (
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_DISTRIBUTION_CHANNEL|' || nullif(trim(to_varchar(AGENT_CHANNEL)), '') AS VARCHAR), '')))) as DISTRIBUTION_CHANNEL_HKEY
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1
     where nullif(trim(to_varchar(AGENT_CHANNEL)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_DISTRIBUTION_CHANNEL' as hub, s.DISTRIBUTION_CHANNEL_HKEY as missing_hkey
  from maxi_hub_distribution_channel_src s
  left join &VAULT_SCHEMA..HUB_DISTRIBUTION_CHANNEL h
         on h.DISTRIBUTION_CHANNEL_HKEY = s.DISTRIBUTION_CHANNEL_HKEY
        and h.RECORD_SOURCE like 'MAXIMUS_%'
 where h.DISTRIBUTION_CHANNEL_HKEY is null;


----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_ORG_UNIT   (NK prefix 'HUB_ORG_UNIT|')
-- Two sources: COMPANY (multi-set pivot) and BRANCH_CODE (simple pivot)
----------------------------------------------------------------------------------------
with maxi_hub_org_unit_src as (
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_ORG_UNIT|' || nullif(trim(to_varchar(COMPANY)), '') AS VARCHAR), '')))) as ORG_UNIT_HKEY
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
     where nullif(trim(to_varchar(COMPANY)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_ORG_UNIT|' || nullif(trim(to_varchar(BRANCH_CODE)), '') AS VARCHAR), ''))))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1
     where nullif(trim(to_varchar(BRANCH_CODE)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_ORG_UNIT' as hub, s.ORG_UNIT_HKEY as missing_hkey
  from maxi_hub_org_unit_src s
  left join &VAULT_SCHEMA..HUB_ORG_UNIT h
         on h.ORG_UNIT_HKEY = s.ORG_UNIT_HKEY
        and h.RECORD_SOURCE like 'MAXIMUS_%'
 where h.ORG_UNIT_HKEY is null;


/* =====================================================================================
   OPUS PROJECT
   ===================================================================================== */

----------------------------------------------------------------------------------------
-- OPUS :: HUB_PARTY   (NK prefix 'HUB_PARTY|')
-- Raw: CP_PARTNERS, key PART_ID (authoritative single source)
----------------------------------------------------------------------------------------
with opus_hub_party_src as (
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(PART_ID)), '') AS VARCHAR), '')))) as PARTY_HKEY
      from &OPUS_RAW..CP_PARTNERS
     where nullif(trim(to_varchar(PART_ID)), '') is not null
)
select 'OPUS' as project, 'HUB_PARTY' as hub, s.PARTY_HKEY as missing_hkey
  from opus_hub_party_src s
  left join &VAULT_SCHEMA..HUB_PARTY h
         on h.PARTY_HKEY = s.PARTY_HKEY
        and h.RECORD_SOURCE like 'OPUS_%'
 where h.PARTY_HKEY is null;


----------------------------------------------------------------------------------------
-- OPUS :: HUB_AGENT   (NK prefix 'HUB_AGENT|')
-- Raw: BJAZ_INTERMEDIARY, key INTERMEDIARY_ID
----------------------------------------------------------------------------------------
with opus_hub_agent_src as (
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_AGENT|' || nullif(trim(to_varchar(INTERMEDIARY_ID)), '') AS VARCHAR), '')))) as AGENT_HKEY
      from &OPUS_RAW..BJAZ_INTERMEDIARY
     where nullif(trim(to_varchar(INTERMEDIARY_ID)), '') is not null
)
select 'OPUS' as project, 'HUB_AGENT' as hub, s.AGENT_HKEY as missing_hkey
  from opus_hub_agent_src s
  left join &VAULT_SCHEMA..HUB_AGENT h
         on h.AGENT_HKEY = s.AGENT_HKEY
        and h.RECORD_SOURCE like 'OPUS_%'
 where h.AGENT_HKEY is null;


----------------------------------------------------------------------------------------
-- OPUS :: HUB_AGREEMENT   (NK prefix 'HUB_AGREEMENT|')
-- Raw: BJAZ_INTERMEDIARY, key INTERMEDIARY_ID
----------------------------------------------------------------------------------------
with opus_hub_agreement_src as (
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_AGREEMENT|' || nullif(trim(to_varchar(INTERMEDIARY_ID)), '') AS VARCHAR), '')))) as AGREEMENT_HKEY
      from &OPUS_RAW..BJAZ_INTERMEDIARY
     where nullif(trim(to_varchar(INTERMEDIARY_ID)), '') is not null
)
select 'OPUS' as project, 'HUB_AGREEMENT' as hub, s.AGREEMENT_HKEY as missing_hkey
  from opus_hub_agreement_src s
  left join &VAULT_SCHEMA..HUB_AGREEMENT h
         on h.AGREEMENT_HKEY = s.AGREEMENT_HKEY
        and h.RECORD_SOURCE like 'OPUS_%'
 where h.AGREEMENT_HKEY is null;


----------------------------------------------------------------------------------------
-- OPUS :: HUB_CLAIM   (NK prefix 'HUB_CLAIM|')
-- Raw: CLM_INTERESTED_PARTIES, key CLAIM_ID
----------------------------------------------------------------------------------------
with opus_hub_claim_src as (
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_CLAIM|' || nullif(trim(to_varchar(CLAIM_ID)), '') AS VARCHAR), '')))) as CLAIM_HKEY
      from &OPUS_RAW..CLM_INTERESTED_PARTIES
     where nullif(trim(to_varchar(CLAIM_ID)), '') is not null
)
select 'OPUS' as project, 'HUB_CLAIM' as hub, s.CLAIM_HKEY as missing_hkey
  from opus_hub_claim_src s
  left join &VAULT_SCHEMA..HUB_CLAIM h
         on h.CLAIM_HKEY = s.CLAIM_HKEY
        and h.RECORD_SOURCE like 'OPUS_%'
 where h.CLAIM_HKEY is null;


----------------------------------------------------------------------------------------
-- OPUS :: HUB_DISTRIBUTION_CHANNEL   (NK prefix 'HUB_DISTRIBUTION_CHANNEL|')
-- Raw: BJAZ_INTERMEDIARY, key INTERMEDIARY_ID
-- (Second branch BJAZ_CLM_SUPP_EXTN does not contribute the channel key -> omitted.)
----------------------------------------------------------------------------------------
with opus_hub_distribution_channel_src as (
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_DISTRIBUTION_CHANNEL|' || nullif(trim(to_varchar(INTERMEDIARY_ID)), '') AS VARCHAR), '')))) as DISTRIBUTION_CHANNEL_HKEY
      from &OPUS_RAW..BJAZ_INTERMEDIARY
     where nullif(trim(to_varchar(INTERMEDIARY_ID)), '') is not null
)
select 'OPUS' as project, 'HUB_DISTRIBUTION_CHANNEL' as hub, s.DISTRIBUTION_CHANNEL_HKEY as missing_hkey
  from opus_hub_distribution_channel_src s
  left join &VAULT_SCHEMA..HUB_DISTRIBUTION_CHANNEL h
         on h.DISTRIBUTION_CHANNEL_HKEY = s.DISTRIBUTION_CHANNEL_HKEY
        and h.RECORD_SOURCE like 'OPUS_%'
 where h.DISTRIBUTION_CHANNEL_HKEY is null;


----------------------------------------------------------------------------------------
-- OPUS :: HUB_LOCATION   (NK prefix 'HUB_LOCATION|')
-- Direct single-column raw sources implemented below.
-- NOTE: stg2_common_address feeds this hub via the stitch_common_address stitch, where
-- LOCATION_BK is a COMPOSITE hash. That branch is NOT included here.
-- >>> TODO: add the stitch_common_address composite-key branch once its concat_ws(...)
--     column list is confirmed, else keys sourced only from COMMON_ADDRESS may false-flag.
----------------------------------------------------------------------------------------
with opus_hub_location_src as (
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_LOCATION|' || nullif(trim(to_varchar(MAIL_ADD_ID)), '') AS VARCHAR), '')))) as LOCATION_HKEY
      from &OPUS_RAW..AZBJ_PARTNER_EXTN
     where nullif(trim(to_varchar(MAIL_ADD_ID)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_LOCATION|' || nullif(trim(to_varchar(LOCATION_CODE)), '') AS VARCHAR), ''))))
      from &OPUS_RAW..BJAZ_CLM_SUPP_EXTN
     where nullif(trim(to_varchar(LOCATION_CODE)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_LOCATION|' || nullif(trim(to_varchar(ADD_ID)), '') AS VARCHAR), ''))))
      from &OPUS_RAW..BJAZ_CP_ADDRESS_LINK
     where nullif(trim(to_varchar(ADD_ID)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_LOCATION|' || nullif(trim(to_varchar(LOC_CODE)), '') AS VARCHAR), ''))))
      from &OPUS_RAW..CLM_SUPPLIERS
     where nullif(trim(to_varchar(LOC_CODE)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_LOCATION|' || nullif(trim(to_varchar(ADD_ID)), '') AS VARCHAR), ''))))
      from &OPUS_RAW..CP_PARTNERS
     where nullif(trim(to_varchar(ADD_ID)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_LOCATION|' || nullif(trim(to_varchar(MAILING_ADDRESS_ID)), '') AS VARCHAR), ''))))
      from &OPUS_RAW..OCP_INTERESTED_PARTIES
     where nullif(trim(to_varchar(MAILING_ADDRESS_ID)), '') is not null
)
select 'OPUS' as project, 'HUB_LOCATION' as hub, s.LOCATION_HKEY as missing_hkey
  from opus_hub_location_src s
  left join &VAULT_SCHEMA..HUB_LOCATION h
         on h.LOCATION_HKEY = s.LOCATION_HKEY
        and h.RECORD_SOURCE like 'OPUS_%'
 where h.LOCATION_HKEY is null;


----------------------------------------------------------------------------------------
-- OPUS :: HUB_POLICY   (NK prefix 'HUB_POLICY|')
-- Direct single-column raw sources implemented below.
-- NOTE: stg2_policy_header and stg2_policy_bonus_tracking feed this hub via stitches
-- (stitch_policy_header / stitch_policy_bonus_tracking). Those branches are NOT included.
-- >>> TODO: add stitched branches once their raw key resolution is confirmed.
----------------------------------------------------------------------------------------
with opus_hub_policy_src as (
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_POLICY|' || nullif(trim(to_varchar(CONTRACT_ID)), '') AS VARCHAR), '')))) as POLICY_HKEY
      from &OPUS_RAW..BA_HCP_DT_MEM
     where nullif(trim(to_varchar(CONTRACT_ID)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_POLICY|' || nullif(trim(to_varchar(CONTRACT_ID)), '') AS VARCHAR), ''))))
      from &OPUS_RAW..BJAZ_CTNGY_FF_DTLS_EXTN
     where nullif(trim(to_varchar(CONTRACT_ID)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_POLICY|' || nullif(trim(to_varchar(POLICY_NUMBER)), '') AS VARCHAR), ''))))
      from &OPUS_RAW..BJAZ_HCF_MEMBER_DTLS
     where nullif(trim(to_varchar(POLICY_NUMBER)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_POLICY|' || nullif(trim(to_varchar(POLICY_NUMBER)), '') AS VARCHAR), ''))))
      from &OPUS_RAW..BJAZ_SPP_MEMBER_DTLS
     where nullif(trim(to_varchar(POLICY_NUMBER)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_POLICY|' || nullif(trim(to_varchar(CONTRACT_ID)), '') AS VARCHAR), ''))))
      from &OPUS_RAW..BJAZ_STARPKG_FF_DTLS
     where nullif(trim(to_varchar(CONTRACT_ID)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_POLICY|' || nullif(trim(to_varchar(CONTRACT_ID)), '') AS VARCHAR), ''))))
      from &OPUS_RAW..OCP_INTERESTED_PARTIES
     where nullif(trim(to_varchar(CONTRACT_ID)), '') is not null
)
select 'OPUS' as project, 'HUB_POLICY' as hub, s.POLICY_HKEY as missing_hkey
  from opus_hub_policy_src s
  left join &VAULT_SCHEMA..HUB_POLICY h
         on h.POLICY_HKEY = s.POLICY_HKEY
        and h.RECORD_SOURCE like 'OPUS_%'
 where h.POLICY_HKEY is null;


----------------------------------------------------------------------------------------
-- OPUS :: HUB_PRODUCT   (NK prefix 'HUB_PRODUCT|')
-- Fed ONLY via stg2_product_definition -> stitch_product_definition (stitched source).
-- >>> TODO: raw table + raw key for PRODUCT_DEFINITION stitch not yet confirmed as a
--     single raw column. Implement once the stitch's underlying raw key is verified.
----------------------------------------------------------------------------------------
-- (intentionally unimplemented to avoid a silently-wrong check)


----------------------------------------------------------------------------------------
-- OPUS :: HUB_RISK_OBJECT   (NK prefix 'HUB_RISK_OBJECT|')
-- Raw: CLM_INTERESTED_PARTIES, key INS_OBJ_UID
----------------------------------------------------------------------------------------
with opus_hub_risk_object_src as (
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_RISK_OBJECT|' || nullif(trim(to_varchar(INS_OBJ_UID)), '') AS VARCHAR), '')))) as RISK_OBJECT_HKEY
      from &OPUS_RAW..CLM_INTERESTED_PARTIES
     where nullif(trim(to_varchar(INS_OBJ_UID)), '') is not null
)
select 'OPUS' as project, 'HUB_RISK_OBJECT' as hub, s.RISK_OBJECT_HKEY as missing_hkey
  from opus_hub_risk_object_src s
  left join &VAULT_SCHEMA..HUB_RISK_OBJECT h
         on h.RISK_OBJECT_HKEY = s.RISK_OBJECT_HKEY
        and h.RECORD_SOURCE like 'OPUS_%'
 where h.RISK_OBJECT_HKEY is null;
