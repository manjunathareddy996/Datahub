{{ config(materialized='view') }}
-- CENTRAL VIEW v21_party -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_PARTY_FINANCIAL_PROFILE
--   SAT_PARTY_POLICY_HISTORY
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_PARTY_CHANNEL
--   LNK_PARTY_DOCUMENT
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_DOCUMENT
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_POLICY_RISK_OBJECT
--   LNK_RISK_OBJECT_DOCUMENT
--   LNK_RISK_OBJECT_PARTY
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- Consumer view over parts: stitch_party_financial_profile, stitch_party_policy_history, stitch_lk_party_channel__v21, stitch_lk_party_document__v21, stitch_lk_policy_channel__v21, stitch_lk_policy_document__v21, stitch_lk_policy_party__v21, stitch_lk_policy_risk_object__v21, stitch_lk_risk_object_document__v21, stitch_lk_risk_object_party__v21, stitch_lk_policy_product__v21

select
    cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
    cast(null as varchar) as DOCUMENT_BK,
    party_bk as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    cast(null as varchar) as PRODUCT_BK,
    cast(null as varchar) as RISK_OBJECT_BK,
    cast(null as int) as __LNK_PARTY_CHANNEL,
    cast(null as int) as __LNK_PARTY_DOCUMENT,
    cast(null as int) as __LNK_POLICY_CHANNEL,
    cast(null as int) as __LNK_POLICY_DOCUMENT,
    cast(null as int) as __LNK_POLICY_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_POLICY_RISK_OBJECT,
    cast(null as int) as __LNK_RISK_OBJECT_DOCUMENT,
    cast(null as int) as __LNK_RISK_OBJECT_PARTY,
    party_financial_profile__annual_income as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
    cast(null as varchar) as PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED
from {{ ref('stitch_party_financial_profile') }}

union all

select
    cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
    cast(null as varchar) as DOCUMENT_BK,
    party_bk as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    cast(null as varchar) as PRODUCT_BK,
    cast(null as varchar) as RISK_OBJECT_BK,
    cast(null as int) as __LNK_PARTY_CHANNEL,
    cast(null as int) as __LNK_PARTY_DOCUMENT,
    cast(null as int) as __LNK_POLICY_CHANNEL,
    cast(null as int) as __LNK_POLICY_DOCUMENT,
    cast(null as int) as __LNK_POLICY_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_POLICY_RISK_OBJECT,
    cast(null as int) as __LNK_RISK_OBJECT_DOCUMENT,
    cast(null as int) as __LNK_RISK_OBJECT_PARTY,
    cast(null as varchar) as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
    party_policy_history__continuous_years_insured as PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED
from {{ ref('stitch_party_policy_history') }}

union all

select
    distribution_channel_bk as DISTRIBUTION_CHANNEL_BK,
    cast(null as varchar) as DOCUMENT_BK,
    party_bk as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    cast(null as varchar) as PRODUCT_BK,
    cast(null as varchar) as RISK_OBJECT_BK,
    1 as __LNK_PARTY_CHANNEL,
    cast(null as int) as __LNK_PARTY_DOCUMENT,
    cast(null as int) as __LNK_POLICY_CHANNEL,
    cast(null as int) as __LNK_POLICY_DOCUMENT,
    cast(null as int) as __LNK_POLICY_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_POLICY_RISK_OBJECT,
    cast(null as int) as __LNK_RISK_OBJECT_DOCUMENT,
    cast(null as int) as __LNK_RISK_OBJECT_PARTY,
    cast(null as varchar) as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
    cast(null as varchar) as PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED
from {{ ref('stitch_lk_party_channel__v21') }}

union all

select
    cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
    document_bk as DOCUMENT_BK,
    party_bk as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    cast(null as varchar) as PRODUCT_BK,
    cast(null as varchar) as RISK_OBJECT_BK,
    cast(null as int) as __LNK_PARTY_CHANNEL,
    1 as __LNK_PARTY_DOCUMENT,
    cast(null as int) as __LNK_POLICY_CHANNEL,
    cast(null as int) as __LNK_POLICY_DOCUMENT,
    cast(null as int) as __LNK_POLICY_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_POLICY_RISK_OBJECT,
    cast(null as int) as __LNK_RISK_OBJECT_DOCUMENT,
    cast(null as int) as __LNK_RISK_OBJECT_PARTY,
    cast(null as varchar) as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
    cast(null as varchar) as PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED
from {{ ref('stitch_lk_party_document__v21') }}

union all

select
    distribution_channel_bk as DISTRIBUTION_CHANNEL_BK,
    cast(null as varchar) as DOCUMENT_BK,
    cast(null as varchar) as PARTY_BK,
    policy_bk as POLICY_BK,
    cast(null as varchar) as PRODUCT_BK,
    cast(null as varchar) as RISK_OBJECT_BK,
    cast(null as int) as __LNK_PARTY_CHANNEL,
    cast(null as int) as __LNK_PARTY_DOCUMENT,
    1 as __LNK_POLICY_CHANNEL,
    cast(null as int) as __LNK_POLICY_DOCUMENT,
    cast(null as int) as __LNK_POLICY_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_POLICY_RISK_OBJECT,
    cast(null as int) as __LNK_RISK_OBJECT_DOCUMENT,
    cast(null as int) as __LNK_RISK_OBJECT_PARTY,
    cast(null as varchar) as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
    cast(null as varchar) as PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED
from {{ ref('stitch_lk_policy_channel__v21') }}

union all

select
    cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
    document_bk as DOCUMENT_BK,
    cast(null as varchar) as PARTY_BK,
    policy_bk as POLICY_BK,
    cast(null as varchar) as PRODUCT_BK,
    cast(null as varchar) as RISK_OBJECT_BK,
    cast(null as int) as __LNK_PARTY_CHANNEL,
    cast(null as int) as __LNK_PARTY_DOCUMENT,
    cast(null as int) as __LNK_POLICY_CHANNEL,
    1 as __LNK_POLICY_DOCUMENT,
    cast(null as int) as __LNK_POLICY_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_POLICY_RISK_OBJECT,
    cast(null as int) as __LNK_RISK_OBJECT_DOCUMENT,
    cast(null as int) as __LNK_RISK_OBJECT_PARTY,
    cast(null as varchar) as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
    cast(null as varchar) as PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED
from {{ ref('stitch_lk_policy_document__v21') }}

union all

select
    cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
    cast(null as varchar) as DOCUMENT_BK,
    party_bk as PARTY_BK,
    policy_bk as POLICY_BK,
    cast(null as varchar) as PRODUCT_BK,
    cast(null as varchar) as RISK_OBJECT_BK,
    cast(null as int) as __LNK_PARTY_CHANNEL,
    cast(null as int) as __LNK_PARTY_DOCUMENT,
    cast(null as int) as __LNK_POLICY_CHANNEL,
    cast(null as int) as __LNK_POLICY_DOCUMENT,
    1 as __LNK_POLICY_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_POLICY_RISK_OBJECT,
    cast(null as int) as __LNK_RISK_OBJECT_DOCUMENT,
    cast(null as int) as __LNK_RISK_OBJECT_PARTY,
    cast(null as varchar) as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
    cast(null as varchar) as PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED
from {{ ref('stitch_lk_policy_party__v21') }}

union all

select
    cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
    cast(null as varchar) as DOCUMENT_BK,
    cast(null as varchar) as PARTY_BK,
    policy_bk as POLICY_BK,
    cast(null as varchar) as PRODUCT_BK,
    risk_object_bk as RISK_OBJECT_BK,
    cast(null as int) as __LNK_PARTY_CHANNEL,
    cast(null as int) as __LNK_PARTY_DOCUMENT,
    cast(null as int) as __LNK_POLICY_CHANNEL,
    cast(null as int) as __LNK_POLICY_DOCUMENT,
    cast(null as int) as __LNK_POLICY_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    1 as __LNK_POLICY_RISK_OBJECT,
    cast(null as int) as __LNK_RISK_OBJECT_DOCUMENT,
    cast(null as int) as __LNK_RISK_OBJECT_PARTY,
    cast(null as varchar) as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
    cast(null as varchar) as PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED
from {{ ref('stitch_lk_policy_risk_object__v21') }}

union all

select
    cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
    document_bk as DOCUMENT_BK,
    cast(null as varchar) as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    cast(null as varchar) as PRODUCT_BK,
    risk_object_bk as RISK_OBJECT_BK,
    cast(null as int) as __LNK_PARTY_CHANNEL,
    cast(null as int) as __LNK_PARTY_DOCUMENT,
    cast(null as int) as __LNK_POLICY_CHANNEL,
    cast(null as int) as __LNK_POLICY_DOCUMENT,
    cast(null as int) as __LNK_POLICY_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_POLICY_RISK_OBJECT,
    1 as __LNK_RISK_OBJECT_DOCUMENT,
    cast(null as int) as __LNK_RISK_OBJECT_PARTY,
    cast(null as varchar) as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
    cast(null as varchar) as PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED
from {{ ref('stitch_lk_risk_object_document__v21') }}

union all

select
    cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
    cast(null as varchar) as DOCUMENT_BK,
    party_bk as PARTY_BK,
    cast(null as varchar) as POLICY_BK,
    cast(null as varchar) as PRODUCT_BK,
    risk_object_bk as RISK_OBJECT_BK,
    cast(null as int) as __LNK_PARTY_CHANNEL,
    cast(null as int) as __LNK_PARTY_DOCUMENT,
    cast(null as int) as __LNK_POLICY_CHANNEL,
    cast(null as int) as __LNK_POLICY_DOCUMENT,
    cast(null as int) as __LNK_POLICY_PARTY,
    cast(null as int) as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_POLICY_RISK_OBJECT,
    cast(null as int) as __LNK_RISK_OBJECT_DOCUMENT,
    1 as __LNK_RISK_OBJECT_PARTY,
    cast(null as varchar) as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
    cast(null as varchar) as PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED
from {{ ref('stitch_lk_risk_object_party__v21') }}

union all

select
    cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
    cast(null as varchar) as DOCUMENT_BK,
    cast(null as varchar) as PARTY_BK,
    policy_bk as POLICY_BK,
    product_bk as PRODUCT_BK,
    cast(null as varchar) as RISK_OBJECT_BK,
    cast(null as int) as __LNK_PARTY_CHANNEL,
    cast(null as int) as __LNK_PARTY_DOCUMENT,
    cast(null as int) as __LNK_POLICY_CHANNEL,
    cast(null as int) as __LNK_POLICY_DOCUMENT,
    cast(null as int) as __LNK_POLICY_PARTY,
    1 as __LNK_POLICY_PRODUCT,
    cast(null as int) as __LNK_POLICY_RISK_OBJECT,
    cast(null as int) as __LNK_RISK_OBJECT_DOCUMENT,
    cast(null as int) as __LNK_RISK_OBJECT_PARTY,
    cast(null as varchar) as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
    cast(null as varchar) as PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED
from {{ ref('stitch_lk_policy_product__v21') }}
