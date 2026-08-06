-- Intermediate harmonisation view for LNK_POLICY_RISK_OBJECT (Policy Risk Object).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        pol_serial_no as policy_bk,
        pol_serial_no || '|' || md_seq_no as risk_object_bk,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pol_serial_no is not null and pol_serial_no is not null and md_seq_no is not null

    union all

    select distinct
        pol_serial_no as policy_bk,
        pol_serial_no || '|' || md_seq_no as risk_object_bk,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pol_serial_no is not null and pol_serial_no is not null and md_seq_no is not null

    union all

    select distinct
        contract_id as policy_bk,
        contract_id || '|' || member_no as risk_object_bk,
        'BJAZ_EC_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
    where contract_id is not null and contract_id is not null and member_no is not null

    union all

    select distinct
        contract_id as policy_bk,
        contract_id || '|' || member_no as risk_object_bk,
        'BJAZ_HCF_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
    where contract_id is not null and contract_id is not null and member_no is not null

    union all

    select distinct
        contract_id as policy_bk,
        contract_id || '|' || member_ref_number as risk_object_bk,
        'BJAZ_CTNGY_PA_MEM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ctngy_pa_mem_dtls') }}
    where contract_id is not null and contract_id is not null and member_ref_number is not null

)

select distinct policy_bk, risk_object_bk, record_source
from unioned
