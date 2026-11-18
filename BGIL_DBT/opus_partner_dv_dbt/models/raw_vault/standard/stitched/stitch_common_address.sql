{{ config(materialized='view') }}

-- Incremental stitch for SAT_COMMON_ADDRESS (HUB_LOCATION grain).
-- 5 code_branch sources using the stitch_incremental macro.
-- Composite-branch sources (content-hash keyed) are excluded from this macro-driven pattern.

{%- set sources = [
    {
        'model': 'stg_partner__azbj_address_extn',
        'alias': 't0',
        'key_column': 'add_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'address_line6', 'tgt': 'address_line_2'},
            {'src': 'address_line7', 'tgt': 'address_line_3'},
            {'src': 'building_name', 'tgt': 'building_name'},
            {'src': 'residence_country', 'tgt': 'country_name'},
            {'src': 'door_no', 'tgt': 'door_number'},
            {'src': 'plot_street_no', 'tgt': 'street_name'}
        ],
        'source_tag': 'OPUS_PARTNER_AZBJ_ADDRESS_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_clm_supp_extn',
        'alias': 't1',
        'key_column': 'billing_loc',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'parent_co_add_line1', 'tgt': 'address_line_1'},
            {'src': 'parent_co_add_line2', 'tgt': 'address_line_2'},
            {'src': 'parent_co_add_line3', 'tgt': 'address_line_3'},
            {'src': 'country_code', 'tgt': 'country_code'},
            {'src': 'country', 'tgt': 'country_name'},
            {'src': 'billing_state', 'tgt': 'state_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_CLM_SUPP_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_pincode',
        'alias': 't3',
        'key_column': 'pincode',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'city', 'tgt': 'city'},
            {'src': 'status', 'tgt': 'postal_code'},
            {'src': 'state', 'tgt': 'state_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_PINCODE'
    },
    {
        'model': 'stg_partner__bjaz_pincode_master',
        'alias': 't4',
        'key_column': 'pincode',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'city', 'tgt': 'city'},
            {'src': 'state', 'tgt': 'state_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_PINCODE_MASTER'
    },
    {
        'model': 'stg_partner__cp_addresses',
        'alias': 't5',
        'key_column': 'add_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'address_line1', 'tgt': 'address_line_1'},
            {'src': 'address_line2', 'tgt': 'address_line_2'},
            {'src': 'address_line3', 'tgt': 'address_line_3'},
            {'src': 'country_code', 'tgt': 'country_code'},
            {'src': 'postcode', 'tgt': 'postal_code'}
        ],
        'source_tag': 'OPUS_PARTNER_CP_ADDRESSES'
    }
] -%}

{%- set output_columns = ['address_line_1', 'address_line_2', 'address_line_3', 'building_name', 'city', 'country_code', 'country_name', 'door_number', 'postal_code', 'state_name', 'street_name'] -%}

{%- set coalesce_rules = {
    'address_line_1': ['t1', 't5'],
    'address_line_2': ['t0', 't1', 't5'],
    'address_line_3': ['t0', 't1', 't5'],
    'building_name': ['t0'],
    'city': ['t3', 't4'],
    'country_code': ['t1', 't5'],
    'country_name': ['t0', 't1'],
    'door_number': ['t0'],
    'postal_code': ['t3', 't5'],
    'state_name': ['t1', 't3', 't4'],
    'street_name': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='sat_common_address'
) }}
