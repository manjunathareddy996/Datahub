{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stitch for LNK_PRODUCT_COVERAGE (Product Coverage). One SELECT per (source table x hub-key branch
-- combination); every leg's business key is the SAME expression as that branch's hub staging
-- model (stg2_hub_<table>__<branch>.sql, PARENT_BK), so link legs always resolve to a hub row.
-- Both/all legs of a link row come from one source row. 18 branch select(s).
-- Rows where a leg is null (or, for traveller / benefit branches, where the traveller's name /
-- the benefit limit is absent) are not emitted.
    select (policy_ref || '|' || 'TRV_ACC_HOSP_EXP') as COVERAGE_BK, (plan) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where acchospexp is not null and (plan) is not null
union all
    select (policy_ref || '|' || 'TRV_ADVENTURE_SPORT') as COVERAGE_BK, (plan) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where adventuresportbenefit is not null and (plan) is not null
union all
    select (policy_ref || '|' || 'TRV_BOUNCED_HOTEL') as COVERAGE_BK, (plan) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where bouncedhotel is not null and (plan) is not null
union all
    select (policy_ref || '|' || 'TRV_COMPASSIONATE_VISIT') as COVERAGE_BK, (plan) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where compvisitfamilymember is not null and (plan) is not null
union all
    select (policy_ref || '|' || 'TRV_BAGGAGE_DELAY') as COVERAGE_BK, (plan) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where delayofcheckedbaggage is not null and (plan) is not null
union all
    select (policy_ref || '|' || 'TRV_EMER_HOTEL_EXT') as COVERAGE_BK, (plan) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where emergencyhotelextension is not null and (plan) is not null
union all
    select (policy_ref || '|' || 'TRV_EMER_MED_EVAC') as COVERAGE_BK, (plan) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where emermedicalevac is not null and (plan) is not null
union all
    select (policy_ref || '|' || 'TRV_HOME_BURGLARY') as COVERAGE_BK, (plan) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where homeburglaryinsurance is not null and (plan) is not null
union all
    select (policy_ref || '|' || 'TRV_HOSP_DAILY_ALLOW') as COVERAGE_BK, (plan) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where hospdailyallow is not null and (plan) is not null
union all
    select (policy_ref || '|' || 'TRV_BAGGAGE_LOSS') as COVERAGE_BK, (plan) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where lossofbaggage is not null and (plan) is not null
union all
    select (policy_ref || '|' || 'TRV_CHECKED_BAGGAGE_LOSS') as COVERAGE_BK, (plan) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where lossofcheckedbaggage is not null and (plan) is not null
union all
    select (policy_ref || '|' || 'TRV_MISSED_CONNECTION') as COVERAGE_BK, (plan) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where missedconnection is not null and (plan) is not null
union all
    select (policy_ref || '|' || 'TRV_PERSONAL_LIABILITY') as COVERAGE_BK, (plan) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where personalliability is not null and (plan) is not null
union all
    select (policy_ref || '|' || 'TRV_REPAT_REMAINS') as COVERAGE_BK, (plan) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where repatonofremains is not null and (plan) is not null
union all
    select (policy_ref || '|' || 'TRV_TRIP_CANCEL') as COVERAGE_BK, (plan) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where tripcancellation is not null and (plan) is not null
union all
    select (policy_ref || '|' || 'TRV_TRIP_CURTAILMENT') as COVERAGE_BK, (plan) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where tripcurtailment is not null and (plan) is not null
union all
    select (policy_ref || '|' || 'TRV_TRIP_DELAY') as COVERAGE_BK, (plan) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where tripdelaybyscheduledaircraft is not null and (plan) is not null
union all
    select (cover_code) as COVERAGE_BK, (plan_id) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_PLAN' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_plan') }}
    where (cover_code) is not null and (plan_id) is not null
