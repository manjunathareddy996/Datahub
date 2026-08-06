-- Intermediate harmonisation view for LNK_POLICY_COVERAGE (Policy Coverage).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        hcp_seqno as coverage_bk,
        contract_id as policy_bk,
        'BA_HCP_DT_MEM' as record_source
    from {{ ref('stg_health__ba_hcp_dt_mem') }}
    where hcp_seqno is not null and contract_id is not null

    union all

    select distinct
        hcp_seqno as coverage_bk,
        contract_id as policy_bk,
        'BA_HCP_DT_MEM_COV' as record_source
    from {{ ref('stg_health__ba_hcp_dt_mem_cov') }}
    where hcp_seqno is not null and contract_id is not null

    union all

    select distinct
        hcp_seqno as coverage_bk,
        contract_id as policy_bk,
        'BA_HCP_DT_POL_COV' as record_source
    from {{ ref('stg_health__ba_hcp_dt_pol_cov') }}
    where hcp_seqno is not null and contract_id is not null

    union all

    select distinct
        hcp_seqno as coverage_bk,
        contract_id as policy_bk,
        'BA_HCP_DT_PREMIUM' as record_source
    from {{ ref('stg_health__ba_hcp_dt_premium') }}
    where hcp_seqno is not null and contract_id is not null

    union all

    select distinct
        cover_code as coverage_bk,
        contract_id as policy_bk,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where cover_code is not null and contract_id is not null

    union all

    select distinct
        cover_code as coverage_bk,
        contract_id as policy_bk,
        'T_PREM_DATA_COM' as record_source
    from {{ ref('stg_health__t_prem_data_com') }}
    where cover_code is not null and contract_id is not null

)

select distinct coverage_bk, policy_bk, record_source
from unioned
