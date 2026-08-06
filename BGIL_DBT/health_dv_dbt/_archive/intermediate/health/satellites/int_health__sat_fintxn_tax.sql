-- Intermediate harmonisation view for SAT_FINTXN_TAX (HUB_FINANCIAL_TRANSACTION grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 3 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select * from (

select parent_bk, tax_type_ck, cess_amount, cgst_amount, component_tax_amount, igst_amount, service_tax_amount, service_tax_exemption_indicator, service_tax_rate, service_tax_registration_number, sgst_amount, tax_type, tds_rate, record_source from (
    select distinct
        ptransaction_id as parent_bk,
        cast(null as varchar) as tax_type_ck,
        cast(null as varchar) as cess_amount,
        nullif(trim(to_varchar(central_gst)), '') as cgst_amount,
        cast(null as varchar) as component_tax_amount,
        nullif(trim(to_varchar(i_gst)), '') as igst_amount,
        nullif(trim(to_varchar(service_tax_amt)), '') as service_tax_amount,
        cast(null as varchar) as service_tax_exemption_indicator,
        cast(null as varchar) as service_tax_rate,
        cast(null as varchar) as service_tax_registration_number,
        nullif(trim(to_varchar(state_gst)), '') as sgst_amount,
        cast(null as varchar) as tax_type,
        cast(null as varchar) as tds_rate,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where ptransaction_id is not null
    )

union all

select parent_bk, tax_type_ck, cess_amount, cgst_amount, component_tax_amount, igst_amount, service_tax_amount, service_tax_exemption_indicator, service_tax_rate, service_tax_registration_number, sgst_amount, tax_type, tds_rate, record_source from (
    select distinct
        claim_no || '|' || utr_no as parent_bk,
        cast(null as varchar) as tax_type_ck,
        cast(null as varchar) as cess_amount,
        cast(null as varchar) as cgst_amount,
        cast(null as varchar) as component_tax_amount,
        cast(null as varchar) as igst_amount,
        nullif(trim(to_varchar(service_tax_amount)), '') as service_tax_amount,
        cast(null as varchar) as service_tax_exemption_indicator,
        nullif(trim(to_varchar(service_tax_rate)), '') as service_tax_rate,
        cast(null as varchar) as service_tax_registration_number,
        cast(null as varchar) as sgst_amount,
        cast(null as varchar) as tax_type,
        nullif(trim(to_varchar(tds_rate)), '') as tds_rate,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where claim_no is not null and utr_no is not null
    )

union all

select parent_bk, tax_type_ck, cess_amount, cgst_amount, component_tax_amount, igst_amount, service_tax_amount, service_tax_exemption_indicator, service_tax_rate, service_tax_registration_number, sgst_amount, tax_type, tds_rate, record_source from (
    select distinct
        tpa_trans_key as parent_bk,
        cast(null as varchar) as tax_type_ck,
        cast(null as varchar) as cess_amount,
        cast(null as varchar) as cgst_amount,
        cast(null as varchar) as component_tax_amount,
        cast(null as varchar) as igst_amount,
        nullif(trim(to_varchar(service_tax_amount)), '') as service_tax_amount,
        cast(null as varchar) as service_tax_exemption_indicator,
        cast(null as varchar) as service_tax_rate,
        nullif(trim(to_varchar(service_tax_no)), '') as service_tax_registration_number,
        cast(null as varchar) as sgst_amount,
        cast(null as varchar) as tax_type,
        cast(null as varchar) as tds_rate,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where tpa_trans_key is not null
    )

)
