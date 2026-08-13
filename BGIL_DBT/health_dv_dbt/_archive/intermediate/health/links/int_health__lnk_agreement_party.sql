-- Intermediate harmonisation view for LNK_AGREEMENT_PARTY (Agreement Party).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        hosid as agreement_bk,
        hosid as party_bk,
        'BJAZ_HM_HOSPITAL_MASTER' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master') }}
    where hosid is not null and hosid is not null

    union all

    select distinct
        hosid as agreement_bk,
        hosid as party_bk,
        'BJAZ_HM_HOSPITAL_MASTER_EXTN' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where hosid is not null and hosid is not null

    union all

    select distinct
        hosid as agreement_bk,
        hosid as party_bk,
        'BJAZ_HM_HOSP_MASTER_EXTN1' as record_source
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where hosid is not null and hosid is not null

    union all

    select distinct
        remedinet_provider_code as agreement_bk,
        payer_code as party_bk,
        'BJAZ_REMEDINET_CLAIM_DETAILS' as record_source
    from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
    where remedinet_provider_code is not null and payer_code is not null

)

select distinct agreement_bk, party_bk, record_source
from unioned
