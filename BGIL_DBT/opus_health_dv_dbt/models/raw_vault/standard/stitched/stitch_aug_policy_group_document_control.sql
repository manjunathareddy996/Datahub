{{ config(materialized='view') }}
-- This part feeds SAT_AUG_POLICY_GROUP_DOCUMENT_CONTROL only. Original precedence comments are kept below (from stitch_v33_quote).
-- CENTRAL VIEW v33_quote -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_GC_CONTROL (opus_health_v2)
--   BJAZ_ENROLL_POL_DTLS (opus_health_v2)
--   BJAZ_ENROLL_SCR_DTLS (opus_health_v2)
--   BJAZ_GRP_HLT_PREMIUM_DTLS_TYP1 (opus_health_v2)
--   BJAZ_HM_MEMBER_HLTH_DTLS (opus_health_v2)
--   BJAZ_ECARD_POL_DTLS_CONFIG (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_GMC_BASES_EXTN (opus_health_delta3)
--   BJAZ_STARPKG_POL_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_PARTY_ORGANISATION_PROFILE
--   SAT_AUG_POLICY_GROUP
--   SAT_AUG_POLICY_GROUP_DOCUMENT_CONTROL
--   SAT_AUG_PROPOSAL_HEADER
--   SAT_AUG_PROPOSAL_UNDERWRITING
--   SAT_AUG_QUOTE_HEADER
--   SAT_AUG_QUOTE_PREMIUM_RATE_AGE_BAND
--   SAT_AUG_QUOTE_PREMIUM_RATE_SLAB
--   SAT_AUG_QUOTE_RATING
--   SAT_AUG_RISK_HEALTH_MEMBER_COVERAGE
--   SAT_POLICY_DOC_CHECKLIST
--   SAT_QUOTE_RATING_INPUT
--   SAT_RISK_HEALTH_PED_WAITING
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_RISK_OBJECT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_ctngy_gc_control') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_ctngy_gc_control',
      'alias': 't0',
      'key_column': "nullif(trim(policy_ref),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CTNGY_GC_CONTROL',
      'columns': [
        {'src': 'all_loc_prn_yn', 'tgt': 'aug_policy_group_document_control__all_locations_printed_indicator'},
        {'src': 'email_subject_yn', 'tgt': 'aug_policy_group_document_control__configured_email_subject_used_indicator'},
        {'src': 'email_content', 'tgt': 'aug_policy_group_document_control__correspondence_email_body_template'},
        {'src': 'cumm_bonus_text', 'tgt': 'aug_policy_group_document_control__cumulative_bonus_schedule_text'},
        {'src': 'first_page', 'tgt': 'aug_policy_group_document_control__first_page_template_selection'},
        {'src': 'print_card_yn', 'tgt': 'aug_policy_group_document_control__health_card_printing_indicator'},
        {'src': 'it_cert', 'tgt': 'aug_policy_group_document_control__income_tax_certificate_produced_indicator'},
        {'src': 'last_page', 'tgt': 'aug_policy_group_document_control__last_page_template_selection'},
        {'src': 'new_card_logic_yn', 'tgt': 'aug_policy_group_document_control__new_health_card_generation_logic_indicator'},
        {'src': 'pdf_format_new_yn', 'tgt': 'aug_policy_group_document_control__new_pdf_format_indicator'},
        {'src': 'odtp_premium_breakup', 'tgt': 'aug_policy_group_document_control__odtp_premium_breakup_shown_indicator'},
        {'src': 'kit_active_yn', 'tgt': 'aug_policy_group_document_control__policy_kit_active_indicator'},
        {'src': 'policy_schedule', 'tgt': 'aug_policy_group_document_control__policy_schedule_produced_indicator'},
        {'src': 'hide_premium_breakup', 'tgt': 'aug_policy_group_document_control__premium_breakup_suppressed_indicator'},
        {'src': 'hide_premium_table', 'tgt': 'aug_policy_group_document_control__premium_table_suppressed_indicator'},
        {'src': 'display_self_info', 'tgt': 'aug_policy_group_document_control__primary_member_details_displayed_indicator'},
        {'src': 'suminsured_text', 'tgt': 'aug_policy_group_document_control__sum_insured_schedule_text'},
        {'src': 'term_end_date_text', 'tgt': 'aug_policy_group_document_control__term_end_date_schedule_text'},
        {'src': 'transcript_yn', 'tgt': 'aug_policy_group_document_control__transcript_document_produced_indicator'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_policy_group_document_control__all_locations_printed_indicator',
    'aug_policy_group_document_control__configured_email_subject_used_indicator',
    'aug_policy_group_document_control__correspondence_email_body_template',
    'aug_policy_group_document_control__cumulative_bonus_schedule_text',
    'aug_policy_group_document_control__first_page_template_selection',
    'aug_policy_group_document_control__health_card_printing_indicator',
    'aug_policy_group_document_control__income_tax_certificate_produced_indicator',
    'aug_policy_group_document_control__last_page_template_selection',
    'aug_policy_group_document_control__new_health_card_generation_logic_indicator',
    'aug_policy_group_document_control__new_pdf_format_indicator',
    'aug_policy_group_document_control__odtp_premium_breakup_shown_indicator',
    'aug_policy_group_document_control__policy_kit_active_indicator',
    'aug_policy_group_document_control__policy_schedule_produced_indicator',
    'aug_policy_group_document_control__premium_breakup_suppressed_indicator',
    'aug_policy_group_document_control__premium_table_suppressed_indicator',
    'aug_policy_group_document_control__primary_member_details_displayed_indicator',
    'aug_policy_group_document_control__sum_insured_schedule_text',
    'aug_policy_group_document_control__term_end_date_schedule_text',
    'aug_policy_group_document_control__transcript_document_produced_indicator'
] -%}
{%- set coalesce_rules = {
    'aug_policy_group_document_control__all_locations_printed_indicator': ['t0'],
    'aug_policy_group_document_control__configured_email_subject_used_indicator': ['t0'],
    'aug_policy_group_document_control__correspondence_email_body_template': ['t0'],
    'aug_policy_group_document_control__cumulative_bonus_schedule_text': ['t0'],
    'aug_policy_group_document_control__first_page_template_selection': ['t0'],
    'aug_policy_group_document_control__health_card_printing_indicator': ['t0'],
    'aug_policy_group_document_control__income_tax_certificate_produced_indicator': ['t0'],
    'aug_policy_group_document_control__last_page_template_selection': ['t0'],
    'aug_policy_group_document_control__new_health_card_generation_logic_indicator': ['t0'],
    'aug_policy_group_document_control__new_pdf_format_indicator': ['t0'],
    'aug_policy_group_document_control__odtp_premium_breakup_shown_indicator': ['t0'],
    'aug_policy_group_document_control__policy_kit_active_indicator': ['t0'],
    'aug_policy_group_document_control__policy_schedule_produced_indicator': ['t0'],
    'aug_policy_group_document_control__premium_breakup_suppressed_indicator': ['t0'],
    'aug_policy_group_document_control__premium_table_suppressed_indicator': ['t0'],
    'aug_policy_group_document_control__primary_member_details_displayed_indicator': ['t0'],
    'aug_policy_group_document_control__sum_insured_schedule_text': ['t0'],
    'aug_policy_group_document_control__term_end_date_schedule_text': ['t0'],
    'aug_policy_group_document_control__transcript_document_produced_indicator': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_bk',
    target_sat='sat_aug_policy_group_document_control'
) }}
