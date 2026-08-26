{{ config(materialized='view') }}

-- Incremental stitch for SAT_COMMON_ADDRESS (HUB_LOCATION grain).
-- 6 code_branch sources using the stitch_incremental macro.
-- Composite-branch sources (content-hash keyed) are excluded from this macro-driven pattern.

{%- set sources = [
    {
        'model': 'stg_partner__azbj_address_extn',
        'alias': 't0',
        'key_column': 'add_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'address_line6', 'tgt': 'addressline2'},
            {'src': 'address_line7', 'tgt': 'addressline3'},
            {'src': 'building_name', 'tgt': 'buildingname'},
            {'src': 'residence_country', 'tgt': 'countryname'},
            {'src': 'door_no', 'tgt': 'doornumber'},
            {'src': 'plot_street_no', 'tgt': 'streetname'}
        ],
        'source_tag': 'AZBJ_ADDRESS_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_clm_supp_extn',
        'alias': 't1',
        'key_column': 'billing_loc',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'parent_co_add_line1', 'tgt': 'addressline1'},
            {'src': 'parent_co_add_line2', 'tgt': 'addressline2'},
            {'src': 'parent_co_add_line3', 'tgt': 'addressline3'},
            {'src': 'country_code', 'tgt': 'countrycode'},
            {'src': 'country', 'tgt': 'countryname'},
            {'src': 'billing_state', 'tgt': 'statename'}
        ],
        'source_tag': 'BJAZ_CLM_SUPP_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_cp_add_hist',
        'alias': 't2',
        'key_column': 'add_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'address_line1', 'tgt': 'addressline1'},
            {'src': 'address_line2', 'tgt': 'addressline2'},
            {'src': 'address_line3', 'tgt': 'addressline3'},
            {'src': 'country_code', 'tgt': 'countrycode'},
            {'src': 'postcode', 'tgt': 'postalcode'}
        ],
        'source_tag': 'BJAZ_CP_ADD_HIST'
    },
    {
        'model': 'stg_partner__bjaz_pincode',
        'alias': 't3',
        'key_column': 'pincode',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'city', 'tgt': 'city'},
            {'src': 'status', 'tgt': 'postalcode'},
            {'src': 'state', 'tgt': 'statename'}
        ],
        'source_tag': 'BJAZ_PINCODE'
    },
    {
        'model': 'stg_partner__bjaz_pincode_master',
        'alias': 't4',
        'key_column': 'pincode',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'city', 'tgt': 'city'},
            {'src': 'state', 'tgt': 'statename'}
        ],
        'source_tag': 'BJAZ_PINCODE_MASTER'
    },
    {
        'model': 'stg_partner__cp_addresses',
        'alias': 't5',
        'key_column': 'add_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'address_line1', 'tgt': 'addressline1'},
            {'src': 'address_line2', 'tgt': 'addressline2'},
            {'src': 'address_line3', 'tgt': 'addressline3'},
            {'src': 'country_code', 'tgt': 'countrycode'},
            {'src': 'postcode', 'tgt': 'postalcode'}
        ],
        'source_tag': 'CP_ADDRESSES'
    }
] -%}

{%- set output_columns = ['addressline1', 'addressline2', 'addressline3', 'buildingname', 'city', 'countrycode', 'countryname', 'doornumber', 'postalcode', 'statename', 'streetname'] -%}

{%- set coalesce_rules = {
    'addressline1': ['t1', 't2', 't5'],
    'addressline2': ['t0', 't1', 't2', 't5'],
    'addressline3': ['t0', 't1', 't2', 't5'],
    'buildingname': ['t0'],
    'city': ['t3', 't4'],
    'countrycode': ['t1', 't2', 't5'],
    'countryname': ['t0', 't1'],
    'doornumber': ['t0'],
    'postalcode': ['t2', 't3', 't5'],
    'statename': ['t1', 't3', 't4'],
    'streetname': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='sat_partner_common_address'
) }}
