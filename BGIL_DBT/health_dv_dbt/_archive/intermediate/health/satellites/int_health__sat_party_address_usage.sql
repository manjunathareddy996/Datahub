-- Intermediate harmonisation view for SAT_PARTY_ADDRESS_USAGE (HUB_PARTY grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 4 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select * from (

select parent_bk, address_usage_type_ck, sequence_ck, address_line_1, address_line_2, city, postal_code, state_code, record_source from (
    select distinct
        alloted_to as parent_bk,
        cast(null as varchar) as address_usage_type_ck,
        cast(null as varchar) as sequence_ck,
        nullif(trim(to_varchar(dc_address)), '') as address_line_1,
        cast(null as varchar) as address_line_2,
        cast(null as varchar) as city,
        cast(null as varchar) as postal_code,
        cast(null as varchar) as state_code,
        'BA_HCP_PP_MEM_DTLS' as record_source
    from {{ ref('stg_health__ba_hcp_pp_mem_dtls') }}
    where alloted_to is not null
    )

union all

select parent_bk, address_usage_type_ck, sequence_ck, address_line_1, address_line_2, city, postal_code, state_code, record_source from (
    select distinct
        customer_id as parent_bk,
        cast(null as varchar) as address_usage_type_ck,
        cast(null as varchar) as sequence_ck,
        nullif(trim(to_varchar(p_address_line_1)), '') as address_line_1,
        nullif(trim(to_varchar(p_address_line_2)), '') as address_line_2,
        nullif(trim(to_varchar(p_city)), '') as city,
        nullif(trim(to_varchar(p_pincode)), '') as postal_code,
        nullif(trim(to_varchar(p_state)), '') as state_code,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where customer_id is not null
    )

union all

select parent_bk, address_usage_type_ck, sequence_ck, address_line_1, address_line_2, city, postal_code, state_code, record_source from (
    select distinct
        member_no as parent_bk,
        cast(null as varchar) as address_usage_type_ck,
        cast(null as varchar) as sequence_ck,
        nullif(trim(to_varchar(addline1)), '') as address_line_1,
        nullif(trim(to_varchar(addline2)), '') as address_line_2,
        cast(null as varchar) as city,
        cast(null as varchar) as postal_code,
        cast(null as varchar) as state_code,
        'BJAZ_HAT_ID_MEM_DETLS' as record_source
    from {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
    where member_no is not null
    )

union all

select parent_bk, address_usage_type_ck, sequence_ck, address_line_1, address_line_2, city, postal_code, state_code, record_source from (
    select distinct
        customer_id as parent_bk,
        cast(null as varchar) as address_usage_type_ck,
        cast(null as varchar) as sequence_ck,
        nullif(trim(to_varchar(payee_address)), '') as address_line_1,
        cast(null as varchar) as address_line_2,
        cast(null as varchar) as city,
        cast(null as varchar) as postal_code,
        cast(null as varchar) as state_code,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where customer_id is not null
    )

)
