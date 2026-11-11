{{ config(materialized='view') }}
-- This part feeds SAT_RISK_HEALTH_MEMBER_MEDICAL only. Original precedence comments are kept below (from stitch_v34_risk_object).
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
-- depends_on: {{ ref('stg_health__bjaz_hm_member_hlth_dtls') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
-- depends_on: {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_hcf_member_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_member_hlth_dtls',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif('MEMBER:' || coalesce(nullif(trim(contract_id),''),'') || '#' || coalesce(nullif(trim(member_id),''),''), 'MEMBER:#'))) || '|' || coalesce(member_id, '~') || '|' || 'DIABETES'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_HLTH_DTLS',
      'columns': [
        {'src': "nullif('MEMBER:' || coalesce(nullif(trim(contract_id),''),'') || '#' || coalesce(nullif(trim(member_id),''),''), 'MEMBER:#')", 'tgt': 'risk_object_bk'},
        {'src': 'member_id', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'DIABETES'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'diabetes_yn', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_member_hlth_dtls',
      'alias': 't1',
      'key_column': "trim(to_varchar(nullif('MEMBER:' || coalesce(nullif(trim(contract_id),''),'') || '#' || coalesce(nullif(trim(member_id),''),''), 'MEMBER:#'))) || '|' || coalesce(member_id, '~') || '|' || 'HYPERTENSION'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_HLTH_DTLS',
      'columns': [
        {'src': "nullif('MEMBER:' || coalesce(nullif(trim(contract_id),''),'') || '#' || coalesce(nullif(trim(member_id),''),''), 'MEMBER:#')", 'tgt': 'risk_object_bk'},
        {'src': 'member_id', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'HYPERTENSION'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'hypertension_yn', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_member_hlth_dtls',
      'alias': 't2',
      'key_column': "trim(to_varchar(nullif('MEMBER:' || coalesce(nullif(trim(contract_id),''),'') || '#' || coalesce(nullif(trim(member_id),''),''), 'MEMBER:#'))) || '|' || coalesce(member_id, '~') || '|' || 'ASTHMA'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_HLTH_DTLS',
      'columns': [
        {'src': "nullif('MEMBER:' || coalesce(nullif(trim(contract_id),''),'') || '#' || coalesce(nullif(trim(member_id),''),''), 'MEMBER:#')", 'tgt': 'risk_object_bk'},
        {'src': 'member_id', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'ASTHMA'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'asthma_yn', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_member_hlth_dtls',
      'alias': 't3',
      'key_column': "trim(to_varchar(nullif('MEMBER:' || coalesce(nullif(trim(contract_id),''),'') || '#' || coalesce(nullif(trim(member_id),''),''), 'MEMBER:#'))) || '|' || coalesce(member_id, '~') || '|' || 'RENAL_DISEASE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_HLTH_DTLS',
      'columns': [
        {'src': "nullif('MEMBER:' || coalesce(nullif(trim(contract_id),''),'') || '#' || coalesce(nullif(trim(member_id),''),''), 'MEMBER:#')", 'tgt': 'risk_object_bk'},
        {'src': 'member_id', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'RENAL_DISEASE'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'renal_problem', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_member_hlth_dtls',
      'alias': 't4',
      'key_column': "trim(to_varchar(nullif('MEMBER:' || coalesce(nullif(trim(contract_id),''),'') || '#' || coalesce(nullif(trim(member_id),''),''), 'MEMBER:#'))) || '|' || coalesce(member_id, '~') || '|' || 'IHD'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_HLTH_DTLS',
      'columns': [
        {'src': "nullif('MEMBER:' || coalesce(nullif(trim(contract_id),''),'') || '#' || coalesce(nullif(trim(member_id),''),''), 'MEMBER:#')", 'tgt': 'risk_object_bk'},
        {'src': 'member_id', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'IHD'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'gmc_ihd', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_member_hlth_dtls',
      'alias': 't5',
      'key_column': "trim(to_varchar(nullif('MEMBER:' || coalesce(nullif(trim(contract_id),''),'') || '#' || coalesce(nullif(trim(member_id),''),''), 'MEMBER:#'))) || '|' || coalesce(member_id, '~') || '|' || 'DECLARED_OTHER'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_HLTH_DTLS',
      'columns': [
        {'src': "nullif('MEMBER:' || coalesce(nullif(trim(contract_id),''),'') || '#' || coalesce(nullif(trim(member_id),''),''), 'MEMBER:#')", 'tgt': 'risk_object_bk'},
        {'src': 'member_id', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'DECLARED_OTHER'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'disease_dtls', 'tgt': 'risk_health_member_medical__condition_name'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't6',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(pol_serial_no)), '') || '|' || nullif(trim(to_varchar(md_seq_no)), ''))) || '|' || coalesce(md_seq_no, '~') || '|' || 'ASTHMA'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': "nullif(trim(to_varchar(pol_serial_no)), '') || '|' || nullif(trim(to_varchar(md_seq_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'md_seq_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'ASTHMA'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'md_asthma', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't7',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(pol_serial_no)), '') || '|' || nullif(trim(to_varchar(md_seq_no)), ''))) || '|' || coalesce(md_seq_no, '~') || '|' || 'CHOLESTEROL_DISORDER'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': "nullif(trim(to_varchar(pol_serial_no)), '') || '|' || nullif(trim(to_varchar(md_seq_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'md_seq_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'CHOLESTEROL_DISORDER'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'md_cholesterol_disorders', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't8',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(pol_serial_no)), '') || '|' || nullif(trim(to_varchar(md_seq_no)), ''))) || '|' || coalesce(md_seq_no, '~') || '|' || 'HEART_DISEASE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': "nullif(trim(to_varchar(pol_serial_no)), '') || '|' || nullif(trim(to_varchar(md_seq_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'md_seq_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'HEART_DISEASE'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'md_heart_diseases', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't9',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(pol_serial_no)), '') || '|' || nullif(trim(to_varchar(md_seq_no)), ''))) || '|' || coalesce(md_seq_no, '~') || '|' || 'HYPERTENSION'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': "nullif(trim(to_varchar(pol_serial_no)), '') || '|' || nullif(trim(to_varchar(md_seq_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'md_seq_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'HYPERTENSION'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'md_hypertension', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't10',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(pol_serial_no)), '') || '|' || nullif(trim(to_varchar(md_seq_no)), ''))) || '|' || coalesce(md_seq_no, '~') || '|' || 'DIABETES'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': "nullif(trim(to_varchar(pol_serial_no)), '') || '|' || nullif(trim(to_varchar(md_seq_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'md_seq_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'DIABETES'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'md_diabetes', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't11',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(pol_serial_no)), '') || '|' || nullif(trim(to_varchar(md_seq_no)), ''))) || '|' || coalesce(md_seq_no, '~') || '|' || 'OBESITY'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': "nullif(trim(to_varchar(pol_serial_no)), '') || '|' || nullif(trim(to_varchar(md_seq_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'md_seq_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'OBESITY'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'md_obesity', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ec_mem_dtls_extn',
      'alias': 't12',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))) || '|' || coalesce(member_no, '~') || '|' || 'DIABETES'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EC_MEM_DTLS_EXTN',
      'columns': [
        {'src': "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'member_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'DIABETES'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'diabetes_yn', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ec_mem_dtls_extn',
      'alias': 't13',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))) || '|' || coalesce(member_no, '~') || '|' || 'HYPERTENSION'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EC_MEM_DTLS_EXTN',
      'columns': [
        {'src': "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'member_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'HYPERTENSION'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'hypertension_yn', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ec_mem_dtls_extn',
      'alias': 't14',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))) || '|' || coalesce(member_no, '~') || '|' || 'ASTHMA'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EC_MEM_DTLS_EXTN',
      'columns': [
        {'src': "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'member_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'ASTHMA'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'asthma_yn', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ec_mem_dtls_extn',
      'alias': 't15',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))) || '|' || coalesce(member_no, '~') || '|' || 'PREGNANCY'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EC_MEM_DTLS_EXTN',
      'columns': [
        {'src': "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'member_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'PREGNANCY'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'pregnant_yn', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ec_mem_dtls_extn',
      'alias': 't16',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))) || '|' || coalesce(member_no, '~') || '|' || 'HISTORY_PAST_4YR'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EC_MEM_DTLS_EXTN',
      'columns': [
        {'src': "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'member_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'HISTORY_PAST_4YR'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'past_4yr_illness', 'tgt': 'risk_health_member_medical__condition_name'},
        {'src': 'past_4yr_treat_date', 'tgt': 'risk_health_member_medical__last_treatment_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ec_mem_dtls_extn',
      'alias': 't17',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))) || '|' || coalesce(member_no, '~') || '|' || 'HISTORY_PRIOR_4YR'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EC_MEM_DTLS_EXTN',
      'columns': [
        {'src': "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'member_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'HISTORY_PRIOR_4YR'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'prior_4yr_illness', 'tgt': 'risk_health_member_medical__condition_name'},
        {'src': 'prior_4yr_treat_date', 'tgt': 'risk_health_member_medical__last_treatment_date'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't18',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))) || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'coalesce(bmi_load, diabetes_load, hyperlipidemia_load, hypertens_load, obesity_load, other_risk_load)', 'tgt': 'risk_health_member_medical__underwriting_loading_percentage'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't19',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))) || '|' || coalesce(member_no, '~') || '|' || 'ASTHMA'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'member_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'ASTHMA'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'asthma_flag', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't20',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))) || '|' || coalesce(member_no, '~') || '|' || 'CHOLESTEROL_DISORDER'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'member_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'CHOLESTEROL_DISORDER'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'holesterol_flag', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't21',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))) || '|' || coalesce(member_no, '~') || '|' || 'HEART_DISEASE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'member_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'HEART_DISEASE'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'heart_flag', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't22',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))) || '|' || coalesce(member_no, '~') || '|' || 'HYPERTENSION'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'member_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'HYPERTENSION'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'hipertension_flag', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't23',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))) || '|' || coalesce(member_no, '~') || '|' || 'DIABETES'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'member_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'DIABETES'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'diabetes_type', 'tgt': 'risk_health_member_medical__condition_name'},
        {'src': 'diabetes_flag', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't24',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))) || '|' || coalesce(member_no, '~') || '|' || 'HEIGHT'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'member_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'HEIGHT'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'height_flag', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't25',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))) || '|' || coalesce(member_no, '~') || '|' || 'WEIGHT'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'member_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'WEIGHT'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'weight_flag', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't26',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))) || '|' || coalesce(member_no, '~') || '|' || 'OBESITY'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'member_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'OBESITY'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'obesity_flag', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't27',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))) || '|' || coalesce(member_no, '~') || '|' || 'BMI'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'member_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'BMI'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'bmi_flag', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't28',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))) || '|' || coalesce(member_no, '~') || '|' || 'DECLARED_OTHER'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'member_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'DECLARED_OTHER'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'other_risk_flag', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't29',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))) || '|' || coalesce(member_no, '~') || '|' || 'HYPERLIPIDEMIA'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'member_no', 'tgt': 'risk_health_member_medical__member_reference_ck'},
        {'src': "'HYPERLIPIDEMIA'", 'tgt': 'risk_health_member_medical__condition_code_ck'},
        {'src': 'hyperlipide_flag', 'tgt': 'risk_health_member_medical__disclosed_indicator'}
      ]
    }
] -%}
{%- set output_columns = [
    'risk_object_bk',
    'risk_health_member_medical__member_reference_ck',
    'risk_health_member_medical__condition_code_ck',
    'risk_health_member_medical__disclosed_indicator',
    'risk_health_member_medical__condition_name',
    'risk_health_member_medical__last_treatment_date',
    'risk_health_member_medical__underwriting_loading_percentage'
] -%}
{%- set coalesce_rules = {
    'risk_object_bk': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't19', 't20', 't21', 't22', 't23', 't24', 't25', 't26', 't27', 't28', 't29'],
    'risk_health_member_medical__member_reference_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't19', 't20', 't21', 't22', 't23', 't24', 't25', 't26', 't27', 't28', 't29'],
    'risk_health_member_medical__condition_code_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't19', 't20', 't21', 't22', 't23', 't24', 't25', 't26', 't27', 't28', 't29'],
    'risk_health_member_medical__disclosed_indicator': ['t0', 't1', 't2', 't3', 't4', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't19', 't20', 't21', 't22', 't23', 't24', 't25', 't26', 't27', 't28', 't29'],
    'risk_health_member_medical__condition_name': ['t5', 't16', 't17', 't23'],
    'risk_health_member_medical__last_treatment_date': ['t16', 't17'],
    'risk_health_member_medical__underwriting_loading_percentage': ['t18']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='risk_health_member_medical_pk',
    target_sat='sat_risk_health_member_medical'
) }}
