-- Intermediate harmonisation view for LNK_CLAIM_COVERAGE (Claim Coverage).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        claim_id as claim_bk,
        cover_section as coverage_bk,
        'BJAZ_HM_DOCTOR_MULTI_ASSESS' as record_source
    from {{ ref('stg_health__bjaz_hm_doctor_multi_assess') }}
    where claim_id is not null and cover_section is not null

    union all

    select distinct
        claim_id as claim_bk,
        cover_section as coverage_bk,
        'BJAZ_HM_DOC_RECOVERY' as record_source
    from {{ ref('stg_health__bjaz_hm_doc_recovery') }}
    where claim_id is not null and cover_section is not null

)

select distinct claim_bk, coverage_bk, record_source
from unioned
