-- SHARED intermediate view for SAT_POLICY_LIFECYCLE, SAT_PRODUCT_HEALTH_MEMBERSHIP_RULES, SAT_PRODUCT_RATING_FACTOR -- identical (parent hub, grain, contributing tables); built once.
-- Stitched via a single source table.
-- record_source lists every table that actually contributed to a given row.
select parent_bk, termination_date, natural_addition_newborn_days, natural_addition_rule_indicator, natural_addition_spouse_days, rating_factor_name, record_source
from (
        select distinct
            policy_ref as parent_bk,
            nullif(trim(to_varchar(deactive_pol_date)), '') as termination_date,
            cast(null as varchar) as natural_addition_newborn_days,
            cast(null as varchar) as natural_addition_rule_indicator,
            cast(null as varchar) as natural_addition_spouse_days,
            cast(null as varchar) as rating_factor_name,
            'BJAZ_ECARD_POL_DTLS_CONFIG' as record_source
        from {{ ref('stg_health__bjaz_ecard_pol_dtls_config') }}
        where policy_ref is not null
    )
