-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_POLICY_GROUP_DOCUMENT_CONTROL (parent HUB_POLICY, history SCD2), fed whole from central view stitch_v33_quote.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_policy_group_document_control'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'ALL_LOCATIONS_PRINTED_INDICATOR'
  - 'CONFIGURED_EMAIL_SUBJECT_USED_INDICATOR'
  - 'CORRESPONDENCE_EMAIL_BODY_TEMPLATE'
  - 'CUMULATIVE_BONUS_SCHEDULE_TEXT'
  - 'FIRST_PAGE_TEMPLATE_SELECTION'
  - 'HEALTH_CARD_PRINTING_INDICATOR'
  - 'INCOME_TAX_CERTIFICATE_PRODUCED_INDICATOR'
  - 'LAST_PAGE_TEMPLATE_SELECTION'
  - 'NEW_HEALTH_CARD_GENERATION_LOGIC_INDICATOR'
  - 'NEW_PDF_FORMAT_INDICATOR'
  - 'ODTP_PREMIUM_BREAKUP_SHOWN_INDICATOR'
  - 'POLICY_KIT_ACTIVE_INDICATOR'
  - 'POLICY_SCHEDULE_PRODUCED_INDICATOR'
  - 'PREMIUM_BREAKUP_SUPPRESSED_INDICATOR'
  - 'PREMIUM_TABLE_SUPPRESSED_INDICATOR'
  - 'PRIMARY_MEMBER_DETAILS_DISPLAYED_INDICATOR'
  - 'SUM_INSURED_SCHEDULE_TEXT'
  - 'TERM_END_DATE_SCHEDULE_TEXT'
  - 'TRANSCRIPT_DOCUMENT_PRODUCED_INDICATOR'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                   src_payload=metadata_dict['src_payload'],
                   src_hashdiff=metadata_dict['src_hashdiff'],
                   src_ldts=metadata_dict['src_ldts'],
                   src_source=metadata_dict['src_source'],
                   source_model=metadata_dict['source_model']) }}
