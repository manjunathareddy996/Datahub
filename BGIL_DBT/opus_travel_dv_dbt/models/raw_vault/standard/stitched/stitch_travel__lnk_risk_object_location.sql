{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stitch for LNK_RISK_OBJECT_LOCATION (Risk Object Location). One SELECT per (source table x hub-key branch
-- combination); every leg's business key is the SAME expression as that branch's hub staging
-- model (stg2_hub_<table>__<branch>.sql, PARENT_BK), so link legs always resolve to a hub row.
-- Both/all legs of a link row come from one source row. 6 branch select(s).
-- Rows where a leg is null (or, for traveller / benefit branches, where the traveller's name /
-- the benefit limit is absent) are not emitted.
    select (coalesce(building, '') || '|' || coalesce(streetname, '') || '|' || coalesce(subareacity, '') || '|' || coalesce(state, '') || '|' || coalesce(pincode, '')) as LOCATION_BK, (policy_ref || '|MEMBER1') as RISK_OBJECT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where replace(coalesce(building, '') || '|' || coalesce(streetname, '') || '|' || coalesce(subareacity, '') || '|' || coalesce(state, '') || '|' || coalesce(pincode, ''), '|', '') <> '' and member1name is not null
union all
    select (coalesce(building, '') || '|' || coalesce(streetname, '') || '|' || coalesce(subareacity, '') || '|' || coalesce(state, '') || '|' || coalesce(pincode, '')) as LOCATION_BK, (policy_ref || '|MEMBER2') as RISK_OBJECT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where replace(coalesce(building, '') || '|' || coalesce(streetname, '') || '|' || coalesce(subareacity, '') || '|' || coalesce(state, '') || '|' || coalesce(pincode, ''), '|', '') <> '' and member2name is not null
union all
    select (coalesce(building, '') || '|' || coalesce(streetname, '') || '|' || coalesce(subareacity, '') || '|' || coalesce(state, '') || '|' || coalesce(pincode, '')) as LOCATION_BK, (policy_ref || '|MEMBER3') as RISK_OBJECT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where replace(coalesce(building, '') || '|' || coalesce(streetname, '') || '|' || coalesce(subareacity, '') || '|' || coalesce(state, '') || '|' || coalesce(pincode, ''), '|', '') <> '' and member3name is not null
union all
    select (coalesce(building, '') || '|' || coalesce(streetname, '') || '|' || coalesce(subareacity, '') || '|' || coalesce(state, '') || '|' || coalesce(pincode, '')) as LOCATION_BK, (policy_ref || '|MEMBER4') as RISK_OBJECT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where replace(coalesce(building, '') || '|' || coalesce(streetname, '') || '|' || coalesce(subareacity, '') || '|' || coalesce(state, '') || '|' || coalesce(pincode, ''), '|', '') <> '' and member4name is not null
union all
    select (coalesce(building, '') || '|' || coalesce(streetname, '') || '|' || coalesce(subareacity, '') || '|' || coalesce(state, '') || '|' || coalesce(pincode, '')) as LOCATION_BK, (policy_ref || '|MEMBER5') as RISK_OBJECT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where replace(coalesce(building, '') || '|' || coalesce(streetname, '') || '|' || coalesce(subareacity, '') || '|' || coalesce(state, '') || '|' || coalesce(pincode, ''), '|', '') <> '' and member5name is not null
union all
    select (coalesce(building, '') || '|' || coalesce(streetname, '') || '|' || coalesce(city, '') || '|' || coalesce(state, '') || '|' || coalesce(pincode, '') || '|' || coalesce(country, '')) as LOCATION_BK, (policynumber) as RISK_OBJECT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_LOG_TABLE' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_log_table') }}
    where replace(coalesce(building, '') || '|' || coalesce(streetname, '') || '|' || coalesce(city, '') || '|' || coalesce(state, '') || '|' || coalesce(pincode, '') || '|' || coalesce(country, ''), '|', '') <> '' and (policynumber) is not null
