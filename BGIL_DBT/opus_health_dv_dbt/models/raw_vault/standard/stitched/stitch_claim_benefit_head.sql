{{ config(materialized='view') }}
-- This part feeds SAT_CLAIM_BENEFIT_HEAD only. Original precedence comments are kept below (from stitch_v07_claim).
-- CENTRAL VIEW v07_claim -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HM_CLAIM_CLOSE (opus_health_v2)
--   BJAZ_HM_CLAIM_REOPEN (opus_health_v2)
--   BJAZ_HM_CLAIM_TRACKER (opus_health_v2)
--   BJAZ_HM_GPA_BILL_DTLS (opus_health_v2)
--   BJAZ_HM_HCS_TECH_ASSESS_COV (opus_health_v2)
--   BJAZ_HM_PREAUTH_REQUEST (opus_health_v2)
--   BJAZ_HAT_OCR_FINA_DTLS_LST (opus_health_legacy_v4)
--   BJAZ_HM_COINSU_CLM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_ORPHAN_REG (opus_health_legacy_v4)
--   BJAZ_HM_PRO_ASSESSMENT (opus_health_legacy_v4)
--   BJAZ_REMEDINET_CLAIM_DETAILS (opus_health_legacy_v4)
--   BJAZ_TPA_CLAIM_DETAILS_WS (opus_health_legacy_v4)
--   BJAZ_RISK_TRANS_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CLAIM_BENEFIT_HEAD
--   SAT_AUG_CLAIM_REOPEN
--   SAT_CLAIM_BENEFIT_HEAD
--   SAT_CLAIM_HEADER
--   SAT_CLAIM_REPUDIATION
--   SAT_CLAIM_SETTLEMENT
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hm_gpa_bill_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hcs_tech_assess_cov') }}
-- depends_on: {{ ref('stg_health__bjaz_hat_ocr_fina_dtls_lst') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hcm_extract') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_gpa_bill_dtls',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || 'DEATH'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_GPA_BILL_DTLS',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': "'DEATH'", 'tgt': 'claim_benefit_head__benefit_head_code_ck'},
        {'src': 'death_approved_amt', 'tgt': 'claim_benefit_head__approved_amount'},
        {'src': 'death_bill_amt', 'tgt': 'claim_benefit_head__claimed_amount'},
        {'src': 'death_disallow_amt', 'tgt': 'claim_benefit_head__deduction_amount'},
        {'src': 'death_disallow_reason', 'tgt': 'claim_benefit_head__deduction_reason'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_gpa_bill_dtls',
      'alias': 't1',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || 'PTD'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_GPA_BILL_DTLS',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': "'PTD'", 'tgt': 'claim_benefit_head__benefit_head_code_ck'},
        {'src': 'ptd_approved_amt', 'tgt': 'claim_benefit_head__approved_amount'},
        {'src': 'ptd_bill_amt', 'tgt': 'claim_benefit_head__claimed_amount'},
        {'src': 'ptd_disallow_amt', 'tgt': 'claim_benefit_head__deduction_amount'},
        {'src': 'ptd_disallow_reason', 'tgt': 'claim_benefit_head__deduction_reason'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_gpa_bill_dtls',
      'alias': 't2',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || 'TTD'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_GPA_BILL_DTLS',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': "'TTD'", 'tgt': 'claim_benefit_head__benefit_head_code_ck'},
        {'src': 'ttd_approved_amt', 'tgt': 'claim_benefit_head__approved_amount'},
        {'src': 'ttd_bill_amt', 'tgt': 'claim_benefit_head__claimed_amount'},
        {'src': 'ttd_disallow_amt', 'tgt': 'claim_benefit_head__deduction_amount'},
        {'src': 'ttd_disallow_reason', 'tgt': 'claim_benefit_head__deduction_reason'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_gpa_bill_dtls',
      'alias': 't3',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || 'MED'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_GPA_BILL_DTLS',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': "'MED'", 'tgt': 'claim_benefit_head__benefit_head_code_ck'},
        {'src': 'med_approved_amt', 'tgt': 'claim_benefit_head__approved_amount'},
        {'src': 'med_bill_amt', 'tgt': 'claim_benefit_head__claimed_amount'},
        {'src': 'med_disallow_amt', 'tgt': 'claim_benefit_head__deduction_amount'},
        {'src': 'med_disallow_reason', 'tgt': 'claim_benefit_head__deduction_reason'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_gpa_bill_dtls',
      'alias': 't4',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || 'CHILD'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_GPA_BILL_DTLS',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': "'CHILD'", 'tgt': 'claim_benefit_head__benefit_head_code_ck'},
        {'src': 'child_approved_amt', 'tgt': 'claim_benefit_head__approved_amount'},
        {'src': 'child_bill_amt', 'tgt': 'claim_benefit_head__claimed_amount'},
        {'src': 'child_disallow_amt', 'tgt': 'claim_benefit_head__deduction_amount'},
        {'src': 'child_disallow_reason', 'tgt': 'claim_benefit_head__deduction_reason'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_gpa_bill_dtls',
      'alias': 't5',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || 'TRANS'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_GPA_BILL_DTLS',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': "'TRANS'", 'tgt': 'claim_benefit_head__benefit_head_code_ck'},
        {'src': 'trans_approved_amt', 'tgt': 'claim_benefit_head__approved_amount'},
        {'src': 'trans_bill_amt', 'tgt': 'claim_benefit_head__claimed_amount'},
        {'src': 'trans_disallow_amt', 'tgt': 'claim_benefit_head__deduction_amount'},
        {'src': 'trans_disallow_reason', 'tgt': 'claim_benefit_head__deduction_reason'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_gpa_bill_dtls',
      'alias': 't6',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || 'FAMILY'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_GPA_BILL_DTLS',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': "'FAMILY'", 'tgt': 'claim_benefit_head__benefit_head_code_ck'},
        {'src': 'family_approved_amt', 'tgt': 'claim_benefit_head__approved_amount'},
        {'src': 'family_bill_amt', 'tgt': 'claim_benefit_head__claimed_amount'},
        {'src': 'family_disallow_amt', 'tgt': 'claim_benefit_head__deduction_amount'},
        {'src': 'family_disallow_reason', 'tgt': 'claim_benefit_head__deduction_reason'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_gpa_bill_dtls',
      'alias': 't7',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || 'FUNERAL'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_GPA_BILL_DTLS',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': "'FUNERAL'", 'tgt': 'claim_benefit_head__benefit_head_code_ck'},
        {'src': 'funeral_approved_amt', 'tgt': 'claim_benefit_head__approved_amount'},
        {'src': 'funeral_bill_amt', 'tgt': 'claim_benefit_head__claimed_amount'},
        {'src': 'funeral_disallow_amt', 'tgt': 'claim_benefit_head__deduction_amount'},
        {'src': 'funeral_disallow_reason', 'tgt': 'claim_benefit_head__deduction_reason'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_gpa_bill_dtls',
      'alias': 't8',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || 'EDU'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_GPA_BILL_DTLS',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': "'EDU'", 'tgt': 'claim_benefit_head__benefit_head_code_ck'},
        {'src': 'edu_approved_amt', 'tgt': 'claim_benefit_head__approved_amount'},
        {'src': 'edu_bill_amt', 'tgt': 'claim_benefit_head__claimed_amount'},
        {'src': 'edu_disallow_amt', 'tgt': 'claim_benefit_head__deduction_amount'},
        {'src': 'edu_disallow_reason', 'tgt': 'claim_benefit_head__deduction_reason'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_gpa_bill_dtls',
      'alias': 't9',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || 'EMI'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_GPA_BILL_DTLS',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': "'EMI'", 'tgt': 'claim_benefit_head__benefit_head_code_ck'},
        {'src': 'emi_approved_amt', 'tgt': 'claim_benefit_head__approved_amount'},
        {'src': 'emi_bill_amt', 'tgt': 'claim_benefit_head__claimed_amount'},
        {'src': 'emi_disallow_amt', 'tgt': 'claim_benefit_head__deduction_amount'},
        {'src': 'emi_disallow_reason', 'tgt': 'claim_benefit_head__deduction_reason'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_gpa_bill_dtls',
      'alias': 't10',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || 'CRITIC'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_GPA_BILL_DTLS',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': "'CRITIC'", 'tgt': 'claim_benefit_head__benefit_head_code_ck'},
        {'src': 'critic_approved_amt', 'tgt': 'claim_benefit_head__approved_amount'},
        {'src': 'critic_bill_amt', 'tgt': 'claim_benefit_head__claimed_amount'},
        {'src': 'critic_disallow_amt', 'tgt': 'claim_benefit_head__deduction_amount'},
        {'src': 'critic_disallow_reason', 'tgt': 'claim_benefit_head__deduction_reason'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_gpa_bill_dtls',
      'alias': 't11',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || 'HOSP'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_GPA_BILL_DTLS',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': "'HOSP'", 'tgt': 'claim_benefit_head__benefit_head_code_ck'},
        {'src': 'hosp_approved_amt', 'tgt': 'claim_benefit_head__approved_amount'},
        {'src': 'hosp_bill_amt', 'tgt': 'claim_benefit_head__claimed_amount'},
        {'src': 'hosp_disallow_amt', 'tgt': 'claim_benefit_head__deduction_amount'},
        {'src': 'hosp_disallow_reason', 'tgt': 'claim_benefit_head__deduction_reason'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcs_tech_assess_cov',
      'alias': 't12',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || coalesce(cover_section, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCS_TECH_ASSESS_COV',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': 'cover_section', 'tgt': 'claim_benefit_head__benefit_head_code_ck'},
        {'src': 'tot_approved_amt', 'tgt': 'claim_benefit_head__approved_amount'},
        {'src': 'cover_section', 'tgt': 'claim_benefit_head__benefit_head_code'},
        {'src': 'tot_claimed_amt', 'tgt': 'claim_benefit_head__claimed_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hat_ocr_fina_dtls_lst',
      'alias': 't13',
      'key_column': "case_id || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HAT_OCR_FINA_DTLS_LST',
      'columns': [
        {'src': 'case_id', 'tgt': 'claim_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'claim_benefit_head__benefit_head_code_ck'},
        {'src': 'total', 'tgt': 'claim_benefit_head__claimed_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcm_extract',
      'alias': 't14',
      'key_column': "clid || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCM_EXTRACT',
      'columns': [
        {'src': 'clid', 'tgt': 'claim_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'claim_benefit_head__benefit_head_code_ck'},
        {'src': 'claimed_amt', 'tgt': 'claim_benefit_head__claimed_amount'}
      ]
    }
] -%}
{%- set output_columns = [
    'claim_bk',
    'claim_benefit_head__benefit_head_code_ck',
    'claim_benefit_head__approved_amount',
    'claim_benefit_head__claimed_amount',
    'claim_benefit_head__deduction_amount',
    'claim_benefit_head__deduction_reason',
    'claim_benefit_head__benefit_head_code'
] -%}
{%- set coalesce_rules = {
    'claim_bk': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14'],
    'claim_benefit_head__benefit_head_code_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14'],
    'claim_benefit_head__approved_amount': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12'],
    'claim_benefit_head__claimed_amount': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14'],
    'claim_benefit_head__deduction_amount': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11'],
    'claim_benefit_head__deduction_reason': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11'],
    'claim_benefit_head__benefit_head_code': ['t12']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='claim_benefit_head_pk',
    target_sat='sat_claim_benefit_head'
) }}
