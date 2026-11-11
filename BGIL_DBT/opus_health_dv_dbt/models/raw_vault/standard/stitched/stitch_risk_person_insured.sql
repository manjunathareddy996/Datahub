{{ config(materialized='view') }}
-- This part feeds SAT_RISK_PERSON_INSURED only. Original precedence comments are kept below (from stitch_v34_risk_object).
-- CENTRAL VIEW v34_risk_object -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HM_CLAIM_TRACKER (opus_health_v2)
--   BJAZ_HM_HCS_TECH_ASSESS_COV (opus_health_v2)
--   BJAZ_HM_MEMBER_HLTH_DTLS (opus_health_v2)
--   BJAZ_PMSBY_DATA_WEB_SERVICE (opus_health_v2)
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_REMEDINET_PATIENT_DETAILS (opus_health_delta3)
--   BJAZ_RISK_TRANS_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CHANNEL_DIGITAL_INTEGRATION
--   SAT_AUG_CLAIM_STATUS_TRANSITION
--   SAT_AUG_RISK_HEALTH_MEMBER_MEDICAL
--   SAT_AUG_RISK_PERSON_INSURED
--   SAT_CLAIM_SLA_TRACKING
--   SAT_LNK_ROLE_BANCASSURANCE
--   SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS
--   SAT_POLICY_PREMIUM_SETTLEMENT
--   SAT_RISK_HEALTH_MEMBER_COVERAGE
--   SAT_RISK_HEALTH_MEMBER_MEDICAL
--   SAT_RISK_PERSON_INSURED
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CLAIM_RISK_OBJECT
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_RISK_OBJECT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hm_hcs_tech_assess_cov') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_member_hlth_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_pmsby_data_web_service') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
-- depends_on: {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_hcf_member_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_remedinet_patient_details') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_hcs_tech_assess_cov',
      'alias': 't0',
      'key_column': "nullif('HEALTHCARD:' || nullif(trim(id_card_no),''), 'HEALTHCARD:')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCS_TECH_ASSESS_COV',
      'columns': [
        {'src': 'id_card_no', 'tgt': 'risk_person_insured__health_card_number'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_member_hlth_dtls',
      'alias': 't1',
      'key_column': "nullif('MEMBER:' || coalesce(nullif(trim(contract_id),''),'') || '#' || coalesce(nullif(trim(member_id),''),''), 'MEMBER:#')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_HLTH_DTLS',
      'columns': [
        {'src': 'body_mas_indes', 'tgt': 'risk_person_insured__body_mass_index'},
        {'src': 'height_cm', 'tgt': 'risk_person_insured__height'},
        {'src': 'ihg_clm_load', 'tgt': 'risk_person_insured__member_risk_loading_percentage'},
        {'src': 'pre_existing_diseases', 'tgt': 'risk_person_insured__pre_existing_disease_description'},
        {'src': 'smoker_yn', 'tgt': 'risk_person_insured__smoker_indicator'},
        {'src': 'weight_kg', 'tgt': 'risk_person_insured__weight'}
      ]
    },
    {
      'model': 'stg_health__bjaz_pmsby_data_web_service',
      'alias': 't2',
      'key_column': "nullif('CUSTID:' || nullif(trim(cust_id),''), 'CUSTID:')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_PMSBY_DATA_WEB_SERVICE',
      'columns': [
        {'src': 'card_number', 'tgt': 'risk_person_insured__health_card_number'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8428_gpg_loader',
      'alias': 't3',
      'key_column': "pol_serial_no || '|' || md_seq_no",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8428_GPG_LOADER',
      'columns': [
        {'src': 'md_height_cm', 'tgt': 'risk_person_insured__height'},
        {'src': 'md_pre_exist_disease_dis_inf', 'tgt': 'risk_person_insured__pre_existing_disease_description'},
        {'src': 'md_relation', 'tgt': 'risk_person_insured__relationship_to_proposer'},
        {'src': 'md_weight_kg', 'tgt': 'risk_person_insured__weight'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't4',
      'key_column': "pol_serial_no || '|' || md_seq_no",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': 'md_bmi', 'tgt': 'risk_person_insured__body_mass_index'},
        {'src': 'md_height_cm', 'tgt': 'risk_person_insured__height'},
        {'src': 'md_pre_exist_disease_dis_inf', 'tgt': 'risk_person_insured__pre_existing_disease_description'},
        {'src': 'md_smoker_tobacco_chewer', 'tgt': 'risk_person_insured__smoker_indicator'},
        {'src': 'md_weight_kg', 'tgt': 'risk_person_insured__weight'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ec_mem_dtls_extn',
      'alias': 't5',
      'key_column': "contract_id || '|' || member_no",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EC_MEM_DTLS_EXTN',
      'columns': [
        {'src': 'height_cm', 'tgt': 'risk_person_insured__height'},
        {'src': 'disease_dtls', 'tgt': 'risk_person_insured__pre_existing_disease_description'},
        {'src': 'relation', 'tgt': 'risk_person_insured__relationship_to_proposer'},
        {'src': 'smoker_yn', 'tgt': 'risk_person_insured__smoker_indicator'},
        {'src': 'weight_kg', 'tgt': 'risk_person_insured__weight'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't6',
      'key_column': "contract_id || '|' || member_no",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': 'load_per', 'tgt': 'risk_person_insured__member_risk_loading_percentage'},
        {'src': 'preexist_dicease', 'tgt': 'risk_person_insured__pre_existing_disease_description'},
        {'src': 'relation', 'tgt': 'risk_person_insured__relationship_to_proposer'},
        {'src': 'smoker_flag', 'tgt': 'risk_person_insured__smoker_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_remedinet_patient_details',
      'alias': 't7',
      'key_column': "nullif('MEMBER:' || nullif(trim(member_no),''), 'MEMBER:')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_REMEDINET_PATIENT_DETAILS',
      'columns': [
        {'src': 'relationship_name', 'tgt': 'risk_person_insured__relationship_to_proposer'}
      ]
    }
] -%}
{%- set output_columns = [
    'risk_person_insured__health_card_number',
    'risk_person_insured__body_mass_index',
    'risk_person_insured__height',
    'risk_person_insured__member_risk_loading_percentage',
    'risk_person_insured__pre_existing_disease_description',
    'risk_person_insured__smoker_indicator',
    'risk_person_insured__weight',
    'risk_person_insured__relationship_to_proposer'
] -%}
{%- set coalesce_rules = {
    'risk_person_insured__health_card_number': ['t0', 't2'],
    'risk_person_insured__body_mass_index': ['t1', 't4'],
    'risk_person_insured__height': ['t1', 't3', 't4', 't5'],
    'risk_person_insured__member_risk_loading_percentage': ['t1', 't6'],
    'risk_person_insured__pre_existing_disease_description': ['t1', 't3', 't4', 't5', 't6'],
    'risk_person_insured__smoker_indicator': ['t1', 't4', 't5', 't6'],
    'risk_person_insured__weight': ['t1', 't3', 't4', 't5'],
    'risk_person_insured__relationship_to_proposer': ['t3', 't5', 't6', 't7']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='risk_object_bk',
    target_sat='sat_risk_person_insured'
) }}
