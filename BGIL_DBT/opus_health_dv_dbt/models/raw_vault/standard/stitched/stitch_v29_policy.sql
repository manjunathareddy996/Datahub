{{ config(materialized='view') }}
-- CENTRAL VIEW v29_policy -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BA_HCP_PORT_WORDINGS (opus_health_legacy_v4)
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GPG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_HAT_ID_MEM_DETLS (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HC_PART_EXTN (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_HLT_ENSURE_MEM_DTLS (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_POLICY_BASES_EXTN (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_POLICY_PORTABILITY_MIGRATION
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- Consumer view over parts: stitch_policy_portability_migration

select
    policy_bk as POLICY_BK,
    policy_portability_migration__continuity_period_granted as POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED,
    policy_portability_migration__cumulative_bonus_ported as POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED,
    policy_portability_migration__portability_indicator as POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR,
    policy_portability_migration__previous_insurer_name as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
    policy_portability_migration__previous_policy_number as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
    policy_portability_migration__previous_sum_insured as POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED
from {{ ref('stitch_policy_portability_migration') }}
