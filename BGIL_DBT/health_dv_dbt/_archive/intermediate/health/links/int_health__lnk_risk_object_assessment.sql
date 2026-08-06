-- Intermediate harmonisation view for LNK_RISK_OBJECT_ASSESSMENT (Risk Object Assessment).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        pd_scrutiny_number as assessment_bk,
        pol_serial_no || '|' || md_seq_no as risk_object_bk,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pd_scrutiny_number is not null and pol_serial_no is not null and md_seq_no is not null

    union all

    select distinct
        pd_scrutiny_number as assessment_bk,
        pol_serial_no || '|' || md_seq_no as risk_object_bk,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pd_scrutiny_number is not null and pol_serial_no is not null and md_seq_no is not null

)

select distinct assessment_bk, risk_object_bk, record_source
from unioned
