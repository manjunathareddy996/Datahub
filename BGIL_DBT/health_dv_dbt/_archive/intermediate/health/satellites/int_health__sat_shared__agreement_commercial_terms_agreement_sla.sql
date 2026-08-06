-- SHARED intermediate view for SAT_AGREEMENT_COMMERCIAL_TERMS, SAT_AGREEMENT_SLA -- identical (parent hub, grain, contributing tables); built once.
-- Stitched via a single source table.
-- record_source lists every table that actually contributed to a given row.
select parent_bk, credit_period, payment_terms, service_level_target, tat_commitment, record_source
from (
        select distinct
            hosid as parent_bk,
            nullif(trim(to_varchar(credit_period)), '') as credit_period,
            nullif(trim(to_varchar(interest_clause)), '') as payment_terms,
            cast(null as varchar) as service_level_target,
            cast(null as varchar) as tat_commitment,
            'BJAZ_HM_HOSPITAL_MASTER_EXTN' as record_source
        from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
        where hosid is not null
    )
