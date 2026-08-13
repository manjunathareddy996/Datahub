-- Intermediate harmonisation view for LNK_AGREEMENT_CHANNEL (Agreement Channel).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        deal_id as agreement_bk,
        partner_id as distribution_channel_bk,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where deal_id is not null and partner_id is not null

    union all

    select distinct
        hosid as agreement_bk,
        partner_id as distribution_channel_bk,
        'BJAZ_HM_HOSPITAL_MASTER' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master') }}
    where hosid is not null and partner_id is not null

    union all

    select distinct
        hosid as agreement_bk,
        distribution_partner as distribution_channel_bk,
        'BJAZ_HM_HOSPITAL_MASTER_EXTN' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where hosid is not null and distribution_partner is not null

)

select distinct agreement_bk, distribution_channel_bk, record_source
from unioned
