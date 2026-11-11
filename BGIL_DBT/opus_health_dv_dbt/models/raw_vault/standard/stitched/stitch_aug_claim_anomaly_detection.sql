{{ config(materialized='view') }}
-- This part feeds SAT_AUG_CLAIM_ANOMALY_DETECTION only. Original precedence comments are kept below (from stitch_v06_claim).
-- CENTRAL VIEW v06_claim -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_BFHL_DTLS (opus_health_v2)
--   BJAZ_HM_CLAIM_CONVERSION (opus_health_v2)
--   BJAZ_HM_ORPHAN_FOLLOW_DTLS (opus_health_v2)
--   BJAZ_HAT_OCR_BILL_DETAILS (opus_health_legacy_v4)
--   BJAZ_HM_BILL_DETAIL (opus_health_legacy_v4)
--   BJAZ_HM_BILL_DETAIL_OCR (opus_health_legacy_v4)
--   BJAZ_HM_ORPHAN_REG (opus_health_legacy_v4)
--   BJAZ_HM_QUERY_REMARK (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CLAIM_ANOMALY_DETECTION
--   SAT_AUG_CLAIM_BILL_DIGITISATION
--   SAT_AUG_CLAIM_CONVERSION_EVENT
--   SAT_AUG_CLAIM_FOLLOW_UP_CHASE
--   SAT_CLAIM_BILL_DIGITISATION
--   SAT_CLAIM_NOTE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CLAIM_LOCATION
--   LNK_CLAIM_POLICY
--   LNK_POLICY_LOCATION
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_bfhl_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_bfhl_dtls',
      'alias': 't0',
      'key_column': "nullif(trim(claim_no),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_BFHL_DTLS',
      'columns': [
        {'src': 'anomaly_description', 'tgt': 'aug_claim_anomaly_detection__anomaly_description'},
        {'src': 'anomaly_timestamp', 'tgt': 'aug_claim_anomaly_detection__anomaly_detected_timestamp'},
        {'src': 'is_anomaly_found', 'tgt': 'aug_claim_anomaly_detection__anomaly_found_indicator'},
        {'src': 'anomaly_sub_type', 'tgt': 'aug_claim_anomaly_detection__anomaly_sub_type_code'},
        {'src': 'anomaly_supporting_doc', 'tgt': 'aug_claim_anomaly_detection__anomaly_supporting_document_uri'},
        {'src': 'anomaly_type', 'tgt': 'aug_claim_anomaly_detection__anomaly_type_code'},
        {'src': 'by_pass_remarks_by', 'tgt': 'aug_claim_anomaly_detection__bypass_authorised_by_user_reference'},
        {'src': 'by_pass_remarks_updated_on', 'tgt': 'aug_claim_anomaly_detection__bypass_decision_timestamp'},
        {'src': 'by_pass_remarks', 'tgt': 'aug_claim_anomaly_detection__bypass_remarks'},
        {'src': 'doc_class', 'tgt': 'aug_claim_anomaly_detection__document_class_examined'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_claim_anomaly_detection__anomaly_description',
    'aug_claim_anomaly_detection__anomaly_detected_timestamp',
    'aug_claim_anomaly_detection__anomaly_found_indicator',
    'aug_claim_anomaly_detection__anomaly_sub_type_code',
    'aug_claim_anomaly_detection__anomaly_supporting_document_uri',
    'aug_claim_anomaly_detection__anomaly_type_code',
    'aug_claim_anomaly_detection__bypass_authorised_by_user_reference',
    'aug_claim_anomaly_detection__bypass_decision_timestamp',
    'aug_claim_anomaly_detection__bypass_remarks',
    'aug_claim_anomaly_detection__document_class_examined'
] -%}
{%- set coalesce_rules = {
    'aug_claim_anomaly_detection__anomaly_description': ['t0'],
    'aug_claim_anomaly_detection__anomaly_detected_timestamp': ['t0'],
    'aug_claim_anomaly_detection__anomaly_found_indicator': ['t0'],
    'aug_claim_anomaly_detection__anomaly_sub_type_code': ['t0'],
    'aug_claim_anomaly_detection__anomaly_supporting_document_uri': ['t0'],
    'aug_claim_anomaly_detection__anomaly_type_code': ['t0'],
    'aug_claim_anomaly_detection__bypass_authorised_by_user_reference': ['t0'],
    'aug_claim_anomaly_detection__bypass_decision_timestamp': ['t0'],
    'aug_claim_anomaly_detection__bypass_remarks': ['t0'],
    'aug_claim_anomaly_detection__document_class_examined': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='claim_bk',
    target_sat='sat_aug_claim_anomaly_detection'
) }}
