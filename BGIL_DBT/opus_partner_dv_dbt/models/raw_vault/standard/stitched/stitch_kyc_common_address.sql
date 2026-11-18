{{ config(materialized='view') }}

-- PARTNER+KYC stitch view for SAT_COMMON_ADDRESS (HUB_LOCATION grain).
-- 8 branch(es) over 6 source table(s): one row per INSTANCE, because a column-as-
-- instance family names several DIFFERENT locations on one row of the source.
--
-- BD-08 + BD-09. There is NO 'KEY: HUB_LOCATION' row for any KYC table -- all 13 such
-- rows in Source-Target are base-run -- so the key is the tier4_content_hash expression
-- the mapper put on Key Derivations under anchor HUB_LOCATION, translated per BD-01 out
-- of the md5-of-normalise notation into the pipe-joined coalesce chain the gate-PASS
-- baseline realises at stitch_common_address.sql line 135. The outer hash call is
-- dropped entirely; AutomateDV's stage() does the hashing. The notation itself is not a
-- Snowflake function and the baseline's macros directory is empty, so it would have
-- shipped as invalid SQL -- and no gate would have fired, because check_prose_shape.py
-- allow-lists the word as a rendering function.
--
-- BDEC-08: the map's instance label (permanent / correspondence / jurisdiction) is an
-- INSTANCE SELECTOR, not a child key -- data_7 declares SAT_COMMON_ADDRESS single-active
-- with an EMPTY childkey, so each instance is its own HUB_LOCATION row.
--
-- BDEC-05, merged scope: payload conforms to the baseline sat_common_address's
-- existing src_payload so that satellite's hashdiff column list -- and therefore
-- every row a builder has already loaded -- is unchanged. 6 KYC-mapped attribute(s)
-- are consequently NOT carried here: ADDRESSTYPECODE, DISTRICT, LANDMARK, LOCALITY, POSTOFFICENAME, TALUKA.
-- They are reported by name in BUILD_STATUS.json. Overruling re-chains a loaded
-- satellite's hashdiff; that is the open shared-vault hashdiff issue.
--
-- opus_partner_dv_dbt: record_source tagged OPUS_PARTNER_<TABLE> and inc_job_updated_at carried per
-- branch, matching stitch_common_address's outputs (stg2_kyc_common_address loads on it).
--
-- opus_partner_dv_dbt: rewritten onto the stitch_incremental macro, same as the other
-- stitches. Mapping unchanged: each merged UNION ALL branch is one source below with the
-- same key expression (wrapped in its original WHERE condition, so rows merged excluded
-- still produce no key) and the same source->target columns. upper() is kept on every
-- column so values match the original nullif(upper(trim(...))) form.

{%- set sources = [
    {
        'model': 'stg_partner__bjaz_m_kyc_driving_licence',
        'alias': 't0',
        'key_column': "case when nullif(upper(trim(to_varchar(address))), '') is not null or nullif(upper(trim(to_varchar(state))), '') is not null or nullif(upper(trim(to_varchar(zip_code))), '') is not null then coalesce(nullif(upper(trim(to_varchar(address))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(zip_code))), ''), '') end",
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': "upper(address)", 'tgt': 'address_line_1'},
            {'src': "upper(zip_code)", 'tgt': 'postal_code'},
            {'src': "upper(state)", 'tgt': 'state_name'},
            {'src': "cast(null as varchar)", 'tgt': 'careofname'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_M_KYC_DRIVING_LICENCE'
    },
    {
        'model': 'stg_partner__bjaz_m_kyc_gstn',
        'alias': 't1',
        'key_column': "case when nullif(upper(trim(to_varchar(business_place))), '') is not null then coalesce(nullif(upper(trim(to_varchar(business_place))), ''), '') end",
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': "upper(business_place)", 'tgt': 'address_line_1'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_M_KYC_GSTN'
    },
    {
        'model': 'stg_partner__bjaz_m_kyc_voter',
        'alias': 't2',
        'key_column': "case when nullif(upper(trim(to_varchar(state))), '') is not null then coalesce(nullif(upper(trim(to_varchar(part_name))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(district))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(state))), ''), '') end",
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': "upper(state)", 'tgt': 'state_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_M_KYC_VOTER'
    },
    {
        'model': 'stg_partner__bjaz_t_ckyc_personal_dtls',
        'alias': 't3',
        'key_column': "case when nullif(upper(trim(to_varchar(corres_city))), '') is not null or nullif(upper(trim(to_varchar(corres_country))), '') is not null or nullif(upper(trim(to_varchar(corres_line1))), '') is not null or nullif(upper(trim(to_varchar(corres_line2))), '') is not null or nullif(upper(trim(to_varchar(corres_line3))), '') is not null or nullif(upper(trim(to_varchar(corres_pin))), '') is not null or nullif(upper(trim(to_varchar(corres_state))), '') is not null then coalesce(nullif(upper(trim(to_varchar(corres_line1))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(corres_line2))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(corres_line3))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(corres_city))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(corres_dist))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(corres_state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(corres_pin))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(corres_country))), ''), '') end",
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': "upper(corres_line1)", 'tgt': 'address_line_1'},
            {'src': "upper(corres_line2)", 'tgt': 'address_line_2'},
            {'src': "upper(corres_line3)", 'tgt': 'address_line_3'},
            {'src': "upper(corres_city)", 'tgt': 'city'},
            {'src': "upper(corres_country)", 'tgt': 'country_name'},
            {'src': "upper(corres_pin)", 'tgt': 'postal_code'},
            {'src': "upper(corres_state)", 'tgt': 'state_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_T_CKYC_PERSONAL_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_t_ckyc_personal_dtls',
        'alias': 't4',
        'key_column': "case when nullif(upper(trim(to_varchar(juri_city))), '') is not null or nullif(upper(trim(to_varchar(juri_country))), '') is not null or nullif(upper(trim(to_varchar(juri_line1))), '') is not null or nullif(upper(trim(to_varchar(juri_line2))), '') is not null or nullif(upper(trim(to_varchar(juri_line3))), '') is not null or nullif(upper(trim(to_varchar(juri_state))), '') is not null then coalesce(nullif(upper(trim(to_varchar(juri_line1))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(juri_line2))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(juri_line3))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(juri_city))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(juri_dist))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(juri_state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(juri_country))), ''), '') end",
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': "upper(juri_line1)", 'tgt': 'address_line_1'},
            {'src': "upper(juri_line2)", 'tgt': 'address_line_2'},
            {'src': "upper(juri_line3)", 'tgt': 'address_line_3'},
            {'src': "upper(juri_city)", 'tgt': 'city'},
            {'src': "upper(juri_country)", 'tgt': 'country_name'},
            {'src': "upper(juri_state)", 'tgt': 'state_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_T_CKYC_PERSONAL_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_t_ckyc_personal_dtls',
        'alias': 't5',
        'key_column': "case when nullif(upper(trim(to_varchar(perm_city))), '') is not null or nullif(upper(trim(to_varchar(perm_country))), '') is not null or nullif(upper(trim(to_varchar(perm_line1))), '') is not null or nullif(upper(trim(to_varchar(perm_line2))), '') is not null or nullif(upper(trim(to_varchar(perm_line3))), '') is not null or nullif(upper(trim(to_varchar(perm_pin))), '') is not null or nullif(upper(trim(to_varchar(perm_state))), '') is not null then coalesce(nullif(upper(trim(to_varchar(perm_line1))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(perm_line2))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(perm_line3))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(perm_city))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(perm_dist))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(perm_state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(perm_pin))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(perm_country))), ''), '') end",
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': "upper(perm_line1)", 'tgt': 'address_line_1'},
            {'src': "upper(perm_line2)", 'tgt': 'address_line_2'},
            {'src': "upper(perm_line3)", 'tgt': 'address_line_3'},
            {'src': "upper(perm_city)", 'tgt': 'city'},
            {'src': "upper(perm_country)", 'tgt': 'country_name'},
            {'src': "upper(perm_pin)", 'tgt': 'postal_code'},
            {'src': "upper(perm_state)", 'tgt': 'state_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_T_CKYC_PERSONAL_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_t_ekyc',
        'alias': 't6',
        'key_column': "case when nullif(upper(trim(to_varchar(country))), '') is not null or nullif(upper(trim(to_varchar(house_number))), '') is not null or nullif(upper(trim(to_varchar(pin_code))), '') is not null or nullif(upper(trim(to_varchar(state))), '') is not null or nullif(upper(trim(to_varchar(street))), '') is not null or nullif(upper(trim(to_varchar(vtc_name))), '') is not null then coalesce(nullif(upper(trim(to_varchar(house_number))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(street))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(landmark))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(location))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(post_office))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(sub_district))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(vtc_name))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(district))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(country))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pin_code))), ''), '') end",
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': "upper(vtc_name)", 'tgt': 'city'},
            {'src': "upper(country)", 'tgt': 'country_name'},
            {'src': "upper(house_number)", 'tgt': 'door_number'},
            {'src': "upper(pin_code)", 'tgt': 'postal_code'},
            {'src': "upper(state)", 'tgt': 'state_name'},
            {'src': "upper(street)", 'tgt': 'street_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_T_EKYC'
    },
    {
        'model': 'stg_partner__bjaz_t_kyc_ocr',
        'alias': 't7',
        'key_column': "case when nullif(upper(trim(to_varchar(building))), '') is not null or nullif(upper(trim(to_varchar(country_code))), '') is not null or nullif(upper(trim(to_varchar(house_number))), '') is not null or nullif(upper(trim(to_varchar(pin_code))), '') is not null or nullif(upper(trim(to_varchar(state))), '') is not null or nullif(upper(trim(to_varchar(street))), '') is not null then coalesce(nullif(upper(trim(to_varchar(house_number))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(building))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(street))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(location))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(post_office))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(district))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(pin_code))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(country_code))), ''), '') end",
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': "upper(building)", 'tgt': 'building_name'},
            {'src': "upper(country_code)", 'tgt': 'country_code'},
            {'src': "upper(house_number)", 'tgt': 'door_number'},
            {'src': "upper(pin_code)", 'tgt': 'postal_code'},
            {'src': "upper(state)", 'tgt': 'state_name'},
            {'src': "upper(street)", 'tgt': 'street_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_T_KYC_OCR'
    }
] -%}

{%- set output_columns = ['address_line_1', 'address_line_2', 'address_line_3', 'building_name', 'careofname', 'city', 'country_code', 'country_name', 'door_number', 'postal_code', 'state_name', 'street_name'] -%}

{%- set coalesce_rules = {
    'address_line_1': ['t0', 't1', 't3', 't4', 't5'],
    'address_line_2': ['t3', 't4', 't5'],
    'address_line_3': ['t3', 't4', 't5'],
    'building_name': ['t7'],
    'careofname': ['t0'],
    'city': ['t3', 't4', 't5', 't6'],
    'country_code': ['t7'],
    'country_name': ['t3', 't4', 't5', 't6'],
    'door_number': ['t6', 't7'],
    'postal_code': ['t0', 't3', 't5', 't6', 't7'],
    'state_name': ['t0', 't2', 't3', 't4', 't5', 't6', 't7'],
    'street_name': ['t6', 't7']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='sat_common_address'
) }}
