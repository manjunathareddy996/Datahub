{{ config(materialized='view') }}
-- This part feeds SAT_CLAIM_HEADER only. Original precedence comments are kept below (from stitch_v07_claim).
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
-- depends_on: {{ ref('stg_health__bjaz_hm_claim_close') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_claim_reopen') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_claim_tracker') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_gpa_bill_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hcs_tech_assess_cov') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_preauth_request') }}
-- depends_on: {{ ref('stg_health__bjaz_hat_ocr_fina_dtls_lst') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hcm_extract') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_orphan_reg') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_pro_assessment') }}
-- depends_on: {{ ref('stg_health__bjaz_remedinet_claim_details') }}
-- depends_on: {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
-- depends_on: {{ ref('stg_health__bjaz_risk_trans_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_claim_close',
      'alias': 't0',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_CLAIM_CLOSE',
      'columns': [
        {'src': 'clid_hpms', 'tgt': 'claim_header__claim_reference_number'},
        {'src': 'close_status', 'tgt': 'claim_header__claim_status'},
        {'src': 'close_date', 'tgt': 'claim_header__closed_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_claim_reopen',
      'alias': 't1',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_CLAIM_REOPEN',
      'columns': [
        {'src': 'clid_hpms', 'tgt': 'claim_header__claim_reference_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_claim_tracker',
      'alias': 't2',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_CLAIM_TRACKER',
      'columns': [
        {'src': 'claim_status', 'tgt': 'claim_header__claim_status'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_gpa_bill_dtls',
      'alias': 't3',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_GPA_BILL_DTLS',
      'columns': [
        {'src': 'clid_hpms', 'tgt': 'claim_header__claim_reference_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcs_tech_assess_cov',
      'alias': 't4',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCS_TECH_ASSESS_COV',
      'columns': [
        {'src': 'clid_hpms', 'tgt': 'claim_header__claim_reference_number'},
        {'src': 'date_of_loss', 'tgt': 'claim_header__loss_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_preauth_request',
      'alias': 't5',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_PREAUTH_REQUEST',
      'columns': [
        {'src': 'claim_ref', 'tgt': 'claim_header__claim_reference_number'},
        {'src': 'injury_date', 'tgt': 'claim_header__loss_date'},
        {'src': 'policy_ref', 'tgt': 'claim_header__policy_reference'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hat_ocr_fina_dtls_lst',
      'alias': 't6',
      'key_column': 'case_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HAT_OCR_FINA_DTLS_LST',
      'columns': [
        {'src': 'inward_no', 'tgt': 'claim_header__claim_reference_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_coinsu_clm_dtls',
      'alias': 't7',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_COINSU_CLM_DTLS',
      'columns': [
        {'src': 'claim_ref', 'tgt': 'claim_header__claim_reference_number'},
        {'src': 'status', 'tgt': 'claim_header__claim_status'},
        {'src': 'rfa_status', 'tgt': 'claim_header__claim_sub_status'},
        {'src': 'type_of_claim', 'tgt': 'claim_header__claim_type'},
        {'src': 'amt_of_claim_lodged', 'tgt': 'claim_header__gross_incurred_amount'},
        {'src': 'total_amount', 'tgt': 'claim_header__net_incurred_amount'},
        {'src': 'claim_date', 'tgt': 'claim_header__notification_date'},
        {'src': 'date_of_cl_lodged', 'tgt': 'claim_header__registration_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcm_extract',
      'alias': 't8',
      'key_column': 'clid',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCM_EXTRACT',
      'columns': [
        {'src': 'general_remarks', 'tgt': 'claim_header__claim_remarks'},
        {'src': 'claim_status', 'tgt': 'claim_header__claim_status'},
        {'src': 'claim_close_status', 'tgt': 'claim_header__claim_sub_status'},
        {'src': 'claim_type', 'tgt': 'claim_header__claim_type'},
        {'src': 'close_date', 'tgt': 'claim_header__closed_date'},
        {'src': 'registration_date', 'tgt': 'claim_header__registration_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_orphan_reg',
      'alias': 't9',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_ORPHAN_REG',
      'columns': [
        {'src': 'orphan_remark', 'tgt': 'claim_header__claim_remarks'},
        {'src': 'claim_type', 'tgt': 'claim_header__claim_type'},
        {'src': 'orphan_inti_date', 'tgt': 'claim_header__notification_date'},
        {'src': 'orphan_date', 'tgt': 'claim_header__registration_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_pro_assessment',
      'alias': 't10',
      'key_column': 'claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_PRO_ASSESSMENT',
      'columns': [
        {'src': 'closer_letdate', 'tgt': 'claim_header__closed_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_remedinet_claim_details',
      'alias': 't11',
      'key_column': 'claim_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_REMEDINET_CLAIM_DETAILS',
      'columns': [
        {'src': 'payer_reference_no', 'tgt': 'claim_header__claim_reference_number'},
        {'src': 'claim_status', 'tgt': 'claim_header__claim_status'},
        {'src': 'action_status', 'tgt': 'claim_header__claim_sub_status'},
        {'src': 'claim_type', 'tgt': 'claim_header__claim_type'}
      ]
    },
    {
      'model': 'stg_health__bjaz_tpa_claim_details_ws',
      'alias': 't12',
      'key_column': 'bjaz_claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_TPA_CLAIM_DETAILS_WS',
      'columns': [
        {'src': 'claim_category', 'tgt': 'claim_header__claim_category'},
        {'src': 'bjaz_claim_status', 'tgt': 'claim_header__claim_status'},
        {'src': 'claim_type', 'tgt': 'claim_header__claim_type'},
        {'src': 'intimation_date', 'tgt': 'claim_header__notification_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_risk_trans_dtls',
      'alias': 't13',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_RISK_TRANS_DTLS',
      'columns': [
        {'src': 'claim_ref', 'tgt': 'claim_header__claim_reference_number'}
      ]
    }
] -%}
{%- set output_columns = [
    'claim_header__claim_reference_number',
    'claim_header__claim_status',
    'claim_header__closed_date',
    'claim_header__loss_date',
    'claim_header__policy_reference',
    'claim_header__claim_sub_status',
    'claim_header__claim_type',
    'claim_header__gross_incurred_amount',
    'claim_header__net_incurred_amount',
    'claim_header__notification_date',
    'claim_header__registration_date',
    'claim_header__claim_remarks',
    'claim_header__claim_category'
] -%}
{%- set coalesce_rules = {
    'claim_header__claim_reference_number': ['t0', 't1', 't3', 't4', 't5', 't6', 't7', 't11', 't13'],
    'claim_header__claim_status': ['t0', 't2', 't7', 't8', 't11', 't12'],
    'claim_header__closed_date': ['t0', 't8', 't10'],
    'claim_header__loss_date': ['t4', 't5'],
    'claim_header__policy_reference': ['t5'],
    'claim_header__claim_sub_status': ['t7', 't8', 't11'],
    'claim_header__claim_type': ['t7', 't8', 't9', 't11', 't12'],
    'claim_header__gross_incurred_amount': ['t7'],
    'claim_header__net_incurred_amount': ['t7'],
    'claim_header__notification_date': ['t7', 't9', 't12'],
    'claim_header__registration_date': ['t7', 't8', 't9'],
    'claim_header__claim_remarks': ['t8', 't9'],
    'claim_header__claim_category': ['t12']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='claim_bk',
    target_sat='sat_claim_header'
) }}
