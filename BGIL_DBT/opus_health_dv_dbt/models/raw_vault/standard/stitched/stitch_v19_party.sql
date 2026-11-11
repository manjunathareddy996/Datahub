{{ config(materialized='view') }}
-- CENTRAL VIEW v19_party -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_BANDHAN_MEDI_CLAM (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GP_HOSPITAL_CASH (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HC_PART_EXTN (opus_health_legacy_v4)
--   BJAZ_HDFC_SEC_FHPP (opus_health_legacy_v4)
--   BJAZ_HLT_ENSURE_MEM_DTLS (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_LNK_ROLE_NOMINEE_BENEFICIARY
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- Consumer view over parts: stitch_lnk_role_nominee_beneficiary__nominee_beneficiary, stitch_lk_party_role__v19

select
    party_bk as PARTY_BK,
    cast(null as varchar) as ROLE_TYPE_CODE,
    lnk_role_nominee_beneficiary__role_type_ck as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
    lnk_role_nominee_beneficiary__relationship_to_insured as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED
from {{ ref('stitch_lnk_role_nominee_beneficiary__nominee_beneficiary') }}

union all

select
    party_bk as PARTY_BK,
    role_type_code as ROLE_TYPE_CODE,
    cast(null as varchar) as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
    cast(null as varchar) as LNK_ROLE_NOMINEE_BENEFICIARY__RELATIONSHIP_TO_INSURED
from {{ ref('stitch_lk_party_role__v19') }}
