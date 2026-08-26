{{ config(materialized='view') }}

-- Incremental stitch for SAT_PROVIDER_BANKING (HUB_PARTY grain).
-- 2 sources contributing at this grain via the stitch_incremental macro.

{%- set sources = [
    {
        'model': 'stg_partner__bjaz_clm_supp_extn',
        'alias': 't0',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'tcs_status', 'tgt': 'tcsstatus'}
        ],
        'source_tag': 'BJAZ_CLM_SUPP_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_hm_hospital_master',
        'alias': 't1',
        'key_column': 'hosid',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'stax_reg_no', 'tgt': 'gstregistrationnumber'}
        ],
        'source_tag': 'BJAZ_HM_HOSPITAL_MASTER'
    }
] -%}

{%- set output_columns = ['gstregistrationnumber', 'tcsstatus'] -%}

{%- set coalesce_rules = {
    'gstregistrationnumber': ['t1'],
    'tcsstatus': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='sat_partner_provider_banking'
) }}
