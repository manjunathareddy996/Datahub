-- Intermediate harmonisation view for HUB_RISK_OBJECT.
-- Unions the HUB_RISK_OBJECT business key from every Health source table/column carrying it. (5 of 5 source columns are discovered/mapper-confirmed, not explicitly tagged in the original mapping -- see docs.)
-- Pure UNION ALL fan-in: 0-join complexity. This view alone fully supplies hub_risk_object.sql.

with unioned as (

    -- CONFIRMED
    select distinct
        pol_serial_no || '|' || md_seq_no as business_key,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pol_serial_no is not null and md_seq_no is not null

    union all

    -- CONFIRMED
    select distinct
        pol_serial_no || '|' || md_seq_no as business_key,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pol_serial_no is not null and md_seq_no is not null

    union all

    -- CONFIRMED
    select distinct
        contract_id || '|' || member_no as business_key,
        'BJAZ_EC_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
    where contract_id is not null and member_no is not null

    union all

    -- CONFIRMED
    select distinct
        contract_id || '|' || member_no as business_key,
        'BJAZ_HCF_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
    where contract_id is not null and member_no is not null

    union all

    -- CONFIRMED
    select distinct
        contract_id || '|' || member_ref_number as business_key,
        'BJAZ_CTNGY_PA_MEM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ctngy_pa_mem_dtls') }}
    where contract_id is not null and member_ref_number is not null

)

select distinct business_key, record_source
from unioned
