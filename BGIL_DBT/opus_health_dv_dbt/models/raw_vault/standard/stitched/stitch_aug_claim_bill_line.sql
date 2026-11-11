{{ config(materialized='view') }}
-- This part feeds SAT_AUG_CLAIM_BILL_LINE only. Original precedence comments are kept below (from stitch_v08_claim).
-- CENTRAL VIEW v08_claim -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HAT_DISC_SUMMARY_LST (opus_health_v2)
--   BJAZ_HAT_NON_PAYABLE_LST (opus_health_v2)
--   BJAZ_HAT_OCR_FINA_PERTICULARS (opus_health_v2)
--   BJAZ_HAT_RETURN_SUMMARY_LST (opus_health_v2)
--   BJAZ_HM_GPA_BILL_DTLS (opus_health_v2)
--   BJAZ_HM_BILL_CHARGE (opus_health_legacy_v4)
--   BJAZ_HM_BILL_DETAIL (opus_health_legacy_v4)
--   BJAZ_HM_BILL_DETAIL_OCR (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_PRO_ASSESSMENT (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CLAIM_BILL_LINE
--   SAT_AUG_CLAIM_PROVIDER_BILLING
--   SAT_CLAIM_PA_DETAIL
--   SAT_CLAIM_PROVIDER_BILLING
-- Links whose legs come from one source row on this view (rule 6):
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hat_disc_summary_lst') }}
-- depends_on: {{ ref('stg_health__bjaz_hat_non_payable_lst') }}
-- depends_on: {{ ref('stg_health__bjaz_hat_ocr_fina_perticulars') }}
-- depends_on: {{ ref('stg_health__bjaz_hat_return_summary_lst') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hat_disc_summary_lst',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif(trim(disc_case_id),''))) || '|' || 'DISCOUNT' || '|' || coalesce(disc_particular_raw, '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HAT_DISC_SUMMARY_LST',
      'columns': [
        {'src': "nullif(trim(disc_case_id),'')", 'tgt': 'claim_bk'},
        {'src': "'DISCOUNT'", 'tgt': 'aug_claim_bill_line__bill_line_type_ck'},
        {'src': 'disc_particular_raw', 'tgt': 'aug_claim_bill_line__line_particular_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'aug_claim_bill_line__bill_head_code_ck'},
        {'src': 'disc_amount', 'tgt': 'aug_claim_bill_line__line_amount'},
        {'src': 'disc_particular_raw', 'tgt': 'aug_claim_bill_line__line_particular'},
        {'src': 'disc_particular_lead_term', 'tgt': 'aug_claim_bill_line__line_particular_lead_term'},
        {'src': 'disc_particular_profile_term', 'tgt': 'aug_claim_bill_line__line_particular_profile_term'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hat_non_payable_lst',
      'alias': 't1',
      'key_column': "trim(to_varchar(nullif(trim(non_pay_case_id),''))) || '|' || 'NON_PAYABLE' || '|' || coalesce(non_pay_particular, '~') || '|' || coalesce(billhead, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HAT_NON_PAYABLE_LST',
      'columns': [
        {'src': "nullif(trim(non_pay_case_id),'')", 'tgt': 'claim_bk'},
        {'src': "'NON_PAYABLE'", 'tgt': 'aug_claim_bill_line__bill_line_type_ck'},
        {'src': 'non_pay_particular', 'tgt': 'aug_claim_bill_line__line_particular_ck'},
        {'src': 'billhead', 'tgt': 'aug_claim_bill_line__bill_head_code_ck'},
        {'src': 'billhead', 'tgt': 'aug_claim_bill_line__bill_head_code'},
        {'src': 'non_pay_level_1', 'tgt': 'aug_claim_bill_line__bill_head_level_1_name'},
        {'src': 'non_pay_level_2', 'tgt': 'aug_claim_bill_line__bill_head_level_2_name'},
        {'src': 'non_pay_level_3', 'tgt': 'aug_claim_bill_line__bill_head_level_3_name'},
        {'src': 'non_pay_amt_perunit', 'tgt': 'aug_claim_bill_line__line_amount_per_unit'},
        {'src': 'non_pay_claimed_amount', 'tgt': 'aug_claim_bill_line__line_claimed_amount'},
        {'src': 'non_pay_particular', 'tgt': 'aug_claim_bill_line__line_particular'},
        {'src': 'non_pay_is_payable', 'tgt': 'aug_claim_bill_line__line_payable_indicator'},
        {'src': 'non_pay_unit', 'tgt': 'aug_claim_bill_line__line_unit_count'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hat_ocr_fina_perticulars',
      'alias': 't2',
      'key_column': "trim(to_varchar(nullif(trim(case_id),''))) || '|' || 'OCR_PARTICULAR' || '|' || coalesce(particular, '~') || '|' || coalesce(billhead, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HAT_OCR_FINA_PERTICULARS',
      'columns': [
        {'src': "nullif(trim(case_id),'')", 'tgt': 'claim_bk'},
        {'src': "'OCR_PARTICULAR'", 'tgt': 'aug_claim_bill_line__bill_line_type_ck'},
        {'src': 'particular', 'tgt': 'aug_claim_bill_line__line_particular_ck'},
        {'src': 'billhead', 'tgt': 'aug_claim_bill_line__bill_head_code_ck'},
        {'src': 'billhead', 'tgt': 'aug_claim_bill_line__bill_head_code'},
        {'src': 'level_3', 'tgt': 'aug_claim_bill_line__bill_head_level_3_name'},
        {'src': 'amount', 'tgt': 'aug_claim_bill_line__line_amount'},
        {'src': 'particular', 'tgt': 'aug_claim_bill_line__line_particular'},
        {'src': 'sr_no', 'tgt': 'aug_claim_bill_line__line_sequence_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hat_return_summary_lst',
      'alias': 't3',
      'key_column': "trim(to_varchar(nullif(trim(ret_case_id),''))) || '|' || 'RETURNED' || '|' || coalesce(ret_particular, '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HAT_RETURN_SUMMARY_LST',
      'columns': [
        {'src': "nullif(trim(ret_case_id),'')", 'tgt': 'claim_bk'},
        {'src': "'RETURNED'", 'tgt': 'aug_claim_bill_line__bill_line_type_ck'},
        {'src': 'ret_particular', 'tgt': 'aug_claim_bill_line__line_particular_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'aug_claim_bill_line__bill_head_code_ck'},
        {'src': 'ret_level_1', 'tgt': 'aug_claim_bill_line__bill_head_level_1_name'},
        {'src': 'ret_level_2', 'tgt': 'aug_claim_bill_line__bill_head_level_2_name'},
        {'src': 'ret_level_3', 'tgt': 'aug_claim_bill_line__bill_head_level_3_name'},
        {'src': 'ret_amount_per_unit', 'tgt': 'aug_claim_bill_line__line_amount_per_unit'},
        {'src': 'ret_claimed_amount', 'tgt': 'aug_claim_bill_line__line_claimed_amount'},
        {'src': 'ret_particular', 'tgt': 'aug_claim_bill_line__line_particular'},
        {'src': 'ret_is_payable', 'tgt': 'aug_claim_bill_line__line_payable_indicator'},
        {'src': 'ret_unit', 'tgt': 'aug_claim_bill_line__line_unit_count'}
      ]
    }
] -%}
{%- set output_columns = [
    'claim_bk',
    'aug_claim_bill_line__bill_line_type_ck',
    'aug_claim_bill_line__line_particular_ck',
    'aug_claim_bill_line__bill_head_code_ck',
    'aug_claim_bill_line__line_amount',
    'aug_claim_bill_line__line_particular',
    'aug_claim_bill_line__line_particular_lead_term',
    'aug_claim_bill_line__line_particular_profile_term',
    'aug_claim_bill_line__bill_head_code',
    'aug_claim_bill_line__bill_head_level_1_name',
    'aug_claim_bill_line__bill_head_level_2_name',
    'aug_claim_bill_line__bill_head_level_3_name',
    'aug_claim_bill_line__line_amount_per_unit',
    'aug_claim_bill_line__line_claimed_amount',
    'aug_claim_bill_line__line_payable_indicator',
    'aug_claim_bill_line__line_unit_count',
    'aug_claim_bill_line__line_sequence_number'
] -%}
{%- set coalesce_rules = {
    'claim_bk': ['t0', 't1', 't2', 't3'],
    'aug_claim_bill_line__bill_line_type_ck': ['t0', 't1', 't2', 't3'],
    'aug_claim_bill_line__line_particular_ck': ['t0', 't1', 't2', 't3'],
    'aug_claim_bill_line__bill_head_code_ck': ['t0', 't1', 't2', 't3'],
    'aug_claim_bill_line__line_amount': ['t0', 't2'],
    'aug_claim_bill_line__line_particular': ['t0', 't1', 't2', 't3'],
    'aug_claim_bill_line__line_particular_lead_term': ['t0'],
    'aug_claim_bill_line__line_particular_profile_term': ['t0'],
    'aug_claim_bill_line__bill_head_code': ['t1', 't2'],
    'aug_claim_bill_line__bill_head_level_1_name': ['t1', 't3'],
    'aug_claim_bill_line__bill_head_level_2_name': ['t1', 't3'],
    'aug_claim_bill_line__bill_head_level_3_name': ['t1', 't2', 't3'],
    'aug_claim_bill_line__line_amount_per_unit': ['t1', 't3'],
    'aug_claim_bill_line__line_claimed_amount': ['t1', 't3'],
    'aug_claim_bill_line__line_payable_indicator': ['t1', 't3'],
    'aug_claim_bill_line__line_unit_count': ['t1', 't3'],
    'aug_claim_bill_line__line_sequence_number': ['t2']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='aug_claim_bill_line_pk',
    target_sat='sat_aug_claim_bill_line'
) }}
