-- Intermediate harmonisation view for LNK_CLAIM_ASSESSMENT (Claim Assessment).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        scrutiny_no as assessment_bk,
        reference_id as claim_bk,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where scrutiny_no is not null and reference_id is not null

    union all

    select distinct
        docasess_id as assessment_bk,
        claim_id as claim_bk,
        'BJAZ_HM_DOCTOR_ASSESS' as record_source
    from {{ ref('stg_health__bjaz_hm_doctor_assess') }}
    where docasess_id is not null and claim_id is not null

    union all

    select distinct
        docasess_id as assessment_bk,
        claim_id as claim_bk,
        'BJAZ_HM_DOCTOR_MULTI_ASSESS' as record_source
    from {{ ref('stg_health__bjaz_hm_doctor_multi_assess') }}
    where docasess_id is not null and claim_id is not null

    union all

    select distinct
        docasess_id as assessment_bk,
        claim_id as claim_bk,
        'BJAZ_HM_PCS_MULTI_ASSESS' as record_source
    from {{ ref('stg_health__bjaz_hm_pcs_multi_assess') }}
    where docasess_id is not null and claim_id is not null

    union all

    select distinct
        assess_id as assessment_bk,
        claim_id as claim_bk,
        'BJAZ_HM_PRO_ASSESSMENT' as record_source
    from {{ ref('stg_health__bjaz_hm_pro_assessment') }}
    where assess_id is not null and claim_id is not null

)

select distinct assessment_bk, claim_bk, record_source
from unioned
