-- Intermediate harmonisation view for HUB_AGREEMENT.
-- Unions the HUB_AGREEMENT business key from every Health source table/column carrying it. (4 of 5 source columns are discovered/mapper-confirmed, not explicitly tagged in the original mapping -- see docs.)
-- Pure UNION ALL fan-in: 0-join complexity. This view alone fully supplies hub_agreement.sql.

with unioned as (

    select distinct
        deal_id as business_key,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where deal_id is not null

    union all

    -- CONFIRMED
    select distinct
        hosid as business_key,
        'BJAZ_HM_HOSPITAL_MASTER' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master') }}
    where hosid is not null

    union all

    -- CONFIRMED
    select distinct
        hosid as business_key,
        'BJAZ_HM_HOSPITAL_MASTER_EXTN' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where hosid is not null

    union all

    -- CONFIRMED
    select distinct
        hosid as business_key,
        'BJAZ_HM_HOSP_MASTER_EXTN1' as record_source
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where hosid is not null

    union all

    -- CONFIRMED
    select distinct
        remedinet_provider_code as business_key,
        'BJAZ_REMEDINET_CLAIM_DETAILS' as record_source
    from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
    where remedinet_provider_code is not null

)

select distinct business_key, record_source
from unioned
