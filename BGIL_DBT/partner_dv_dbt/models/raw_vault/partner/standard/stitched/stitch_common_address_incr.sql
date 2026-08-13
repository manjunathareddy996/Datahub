{{ config(materialized='view') }}

-- Incremental stitch view for SAT_COMMON_ADDRESS (HUB_LOCATION grain).
-- code_branch: 6 tables using the stitch_incremental macro (T-1 key-filtered).
-- composite_branch: 6 UNION ALL contributions with content-hash keys (T-1 filtered directly).

{%- set sources = [
    {
        'model': 'stg_partner__azbj_address_extn',
        'alias': 't0',
        'key_column': 'add_id',
        'ldts_column': 'gg_change_date',
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
        'ldts_column': 'gg_change_date',
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
        'ldts_column': 'gg_change_date',
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
        'ldts_column': 'gg_change_date',
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
        'ldts_column': 'gg_change_date',
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
        'ldts_column': 'gg_change_date',
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
    unique_key='parent_bk'
) }}

UNION ALL

-- composite_branch: content-hash keyed address rows, T-1 filtered
SELECT
    COALESCE(NULLIF(UPPER(TRIM(TO_VARCHAR(address))), ''), '') || '|' || COALESCE(NULLIF(UPPER(TRIM(TO_VARCHAR(city))), ''), '') || '|' || COALESCE(NULLIF(UPPER(TRIM(TO_VARCHAR(state))), ''), '') || '|' || COALESCE(NULLIF(UPPER(TRIM(TO_VARCHAR(pin))), ''), '') AS parent_bk,
    NULLIF(UPPER(TRIM(TO_VARCHAR(address))), '') AS addressline1,
    CAST(NULL AS VARCHAR) AS addressline2, CAST(NULL AS VARCHAR) AS addressline3, CAST(NULL AS VARCHAR) AS buildingname,
    NULLIF(UPPER(TRIM(TO_VARCHAR(city))), '') AS city,
    CAST(NULL AS VARCHAR) AS countrycode, CAST(NULL AS VARCHAR) AS countryname, CAST(NULL AS VARCHAR) AS doornumber,
    NULLIF(UPPER(TRIM(TO_VARCHAR(pin))), '') AS postalcode,
    NULLIF(UPPER(TRIM(TO_VARCHAR(state))), '') AS statename,
    CAST(NULL AS VARCHAR) AS streetname,
    'BJAZ_HM_MEMBER_DTLS' AS record_source
FROM {{ ref('stg_partner__bjaz_hm_member_dtls') }}
WHERE gg_change_date >= DATEADD(DAY, -1, CURRENT_DATE())
  AND (NULLIF(UPPER(TRIM(TO_VARCHAR(address))), '') IS NOT NULL OR NULLIF(UPPER(TRIM(TO_VARCHAR(city))), '') IS NOT NULL OR NULLIF(UPPER(TRIM(TO_VARCHAR(state))), '') IS NOT NULL OR NULLIF(UPPER(TRIM(TO_VARCHAR(pin))), '') IS NOT NULL)

UNION ALL

SELECT
    COALESCE(NULLIF(UPPER(TRIM(TO_VARCHAR(address))), ''), '') AS parent_bk,
    NULLIF(UPPER(TRIM(TO_VARCHAR(address))), '') AS addressline1,
    CAST(NULL AS VARCHAR), CAST(NULL AS VARCHAR), CAST(NULL AS VARCHAR),
    CAST(NULL AS VARCHAR), CAST(NULL AS VARCHAR), CAST(NULL AS VARCHAR), CAST(NULL AS VARCHAR),
    CAST(NULL AS VARCHAR), CAST(NULL AS VARCHAR), CAST(NULL AS VARCHAR),
    'BJAZ_SH_MEM_DTLS_EXTN' AS record_source
FROM {{ ref('stg_partner__bjaz_sh_mem_dtls_extn') }}
WHERE NULLIF(UPPER(TRIM(TO_VARCHAR(address))), '') IS NOT NULL

UNION ALL

SELECT
    COALESCE(NULLIF(UPPER(TRIM(TO_VARCHAR(insured_address))), ''), '') AS parent_bk,
    NULLIF(UPPER(TRIM(TO_VARCHAR(insured_address))), '') AS addressline1,
    CAST(NULL AS VARCHAR), CAST(NULL AS VARCHAR), CAST(NULL AS VARCHAR),
    CAST(NULL AS VARCHAR), CAST(NULL AS VARCHAR), CAST(NULL AS VARCHAR), CAST(NULL AS VARCHAR),
    CAST(NULL AS VARCHAR), CAST(NULL AS VARCHAR), CAST(NULL AS VARCHAR),
    'BJAZ_CTNGY_GC_MEM_DATA' AS record_source
FROM {{ ref('stg_partner__bjaz_ctngy_gc_mem_data') }}
WHERE gg_change_date >= DATEADD(DAY, -1, CURRENT_DATE())
  AND NULLIF(UPPER(TRIM(TO_VARCHAR(insured_address))), '') IS NOT NULL

UNION ALL

SELECT
    COALESCE(NULLIF(UPPER(TRIM(TO_VARCHAR(address1))), ''), '') || '|' || COALESCE(NULLIF(UPPER(TRIM(TO_VARCHAR(address2))), ''), '') || '|' || COALESCE(NULLIF(UPPER(TRIM(TO_VARCHAR(city_name))), ''), '') || '|' || COALESCE(NULLIF(UPPER(TRIM(TO_VARCHAR(state_name))), ''), '') || '|' || COALESCE(NULLIF(UPPER(TRIM(TO_VARCHAR(pin_code))), ''), '') AS parent_bk,
    NULLIF(UPPER(TRIM(TO_VARCHAR(address1))), '') AS addressline1,
    NULLIF(UPPER(TRIM(TO_VARCHAR(address2))), '') AS addressline2,
    CAST(NULL AS VARCHAR) AS addressline3, CAST(NULL AS VARCHAR) AS buildingname,
    NULLIF(UPPER(TRIM(TO_VARCHAR(city_name))), '') AS city,
    CAST(NULL AS VARCHAR) AS countrycode, CAST(NULL AS VARCHAR) AS countryname, CAST(NULL AS VARCHAR) AS doornumber,
    NULLIF(UPPER(TRIM(TO_VARCHAR(pin_code))), '') AS postalcode,
    NULLIF(UPPER(TRIM(TO_VARCHAR(state_name))), '') AS statename,
    CAST(NULL AS VARCHAR) AS streetname,
    'BJAZ_HM_HOSPITAL_MASTER' AS record_source
FROM {{ ref('stg_partner__bjaz_hm_hospital_master') }}
WHERE gg_change_date >= DATEADD(DAY, -1, CURRENT_DATE())
  AND (NULLIF(UPPER(TRIM(TO_VARCHAR(address1))), '') IS NOT NULL OR NULLIF(UPPER(TRIM(TO_VARCHAR(address2))), '') IS NOT NULL OR NULLIF(UPPER(TRIM(TO_VARCHAR(city_name))), '') IS NOT NULL OR NULLIF(UPPER(TRIM(TO_VARCHAR(state_name))), '') IS NOT NULL OR NULLIF(UPPER(TRIM(TO_VARCHAR(pin_code))), '') IS NOT NULL)

UNION ALL

SELECT
    COALESCE(NULLIF(UPPER(TRIM(TO_VARCHAR(house_no))), ''), '') || '|' || COALESCE(NULLIF(UPPER(TRIM(TO_VARCHAR(street_name))), ''), '') || '|' || COALESCE(NULLIF(UPPER(TRIM(TO_VARCHAR(mem_address))), ''), '') || '|' || COALESCE(NULLIF(UPPER(TRIM(TO_VARCHAR(city))), ''), '') || '|' || COALESCE(NULLIF(UPPER(TRIM(TO_VARCHAR(state))), ''), '') || '|' || COALESCE(NULLIF(UPPER(TRIM(TO_VARCHAR(pin_code))), ''), '') AS parent_bk,
    NULLIF(UPPER(TRIM(TO_VARCHAR(mem_address))), '') AS addressline1,
    CAST(NULL AS VARCHAR) AS addressline2, CAST(NULL AS VARCHAR) AS addressline3, CAST(NULL AS VARCHAR) AS buildingname,
    NULLIF(UPPER(TRIM(TO_VARCHAR(city))), '') AS city,
    CAST(NULL AS VARCHAR) AS countrycode, CAST(NULL AS VARCHAR) AS countryname,
    NULLIF(UPPER(TRIM(TO_VARCHAR(house_no))), '') AS doornumber,
    NULLIF(UPPER(TRIM(TO_VARCHAR(pin_code))), '') AS postalcode,
    NULLIF(UPPER(TRIM(TO_VARCHAR(state))), '') AS statename,
    NULLIF(UPPER(TRIM(TO_VARCHAR(street_name))), '') AS streetname,
    'BJAZ_CTNGY_PA_MEM_DTLS' AS record_source
FROM {{ ref('stg_partner__bjaz_ctngy_pa_mem_dtls') }}
WHERE gg_change_date >= DATEADD(DAY, -1, CURRENT_DATE())
  AND (NULLIF(UPPER(TRIM(TO_VARCHAR(house_no))), '') IS NOT NULL OR NULLIF(UPPER(TRIM(TO_VARCHAR(street_name))), '') IS NOT NULL OR NULLIF(UPPER(TRIM(TO_VARCHAR(mem_address))), '') IS NOT NULL OR NULLIF(UPPER(TRIM(TO_VARCHAR(city))), '') IS NOT NULL OR NULLIF(UPPER(TRIM(TO_VARCHAR(state))), '') IS NOT NULL OR NULLIF(UPPER(TRIM(TO_VARCHAR(pin_code))), '') IS NOT NULL)

UNION ALL

SELECT
    COALESCE(NULLIF(UPPER(TRIM(TO_VARCHAR(assigne_address))), ''), '') AS parent_bk,
    NULLIF(UPPER(TRIM(TO_VARCHAR(assigne_address))), '') AS addressline1,
    CAST(NULL AS VARCHAR), CAST(NULL AS VARCHAR), CAST(NULL AS VARCHAR),
    CAST(NULL AS VARCHAR), CAST(NULL AS VARCHAR), CAST(NULL AS VARCHAR), CAST(NULL AS VARCHAR),
    CAST(NULL AS VARCHAR), CAST(NULL AS VARCHAR), CAST(NULL AS VARCHAR),
    'BJAZ_CTNGY_PA_MEM_DTLS' AS record_source
FROM {{ ref('stg_partner__bjaz_ctngy_pa_mem_dtls') }}
WHERE gg_change_date >= DATEADD(DAY, -1, CURRENT_DATE())
  AND NULLIF(UPPER(TRIM(TO_VARCHAR(assigne_address))), '') IS NOT NULL
