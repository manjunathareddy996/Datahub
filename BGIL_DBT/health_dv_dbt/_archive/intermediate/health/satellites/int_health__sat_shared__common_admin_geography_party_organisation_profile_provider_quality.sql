-- SHARED intermediate view for SAT_COMMON_ADMIN_GEOGRAPHY, SAT_PARTY_ORGANISATION_PROFILE, SAT_PROVIDER_QUALITY -- identical (parent hub, grain, contributing tables); built once.
-- Stitched via a single source table.
-- record_source lists every table that actually contributed to a given row.
select parent_bk, city_class_code, industry_description, legal_constitution_code, msme_indicator, quality_rating, record_source
from (
        select distinct
            hosid as parent_bk,
            nullif(trim(to_varchar(city_class)), '') as city_class_code,
            cast(null as varchar) as industry_description,
            cast(null as varchar) as legal_constitution_code,
            cast(null as varchar) as msme_indicator,
            cast(null as varchar) as quality_rating,
            'BJAZ_HM_HOSPITAL_MASTER_EXTN' as record_source
        from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
        where hosid is not null
    )
