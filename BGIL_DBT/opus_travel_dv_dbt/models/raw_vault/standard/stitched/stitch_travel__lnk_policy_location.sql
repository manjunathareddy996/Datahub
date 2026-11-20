{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stitch for LNK_POLICY_LOCATION (Policy Risk Location). One SELECT per (source table x hub-key branch
-- combination); every leg's business key is the SAME expression as that branch's hub staging
-- model (stg2_hub_<table>__<branch>.sql, PARENT_BK), so link legs always resolve to a hub row.
-- Both/all legs of a link row come from one source row. 4 branch select(s).
-- Rows where a leg is null (or, for traveller / benefit branches, where the traveller's name /
-- the benefit limit is absent) are not emitted.
    select (coalesce(building, '') || '|' || coalesce(streetname, '') || '|' || coalesce(subareacity, '') || '|' || coalesce(state, '') || '|' || coalesce(pincode, '')) as LOCATION_BK, (policy_ref) as POLICY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where replace(coalesce(building, '') || '|' || coalesce(streetname, '') || '|' || coalesce(subareacity, '') || '|' || coalesce(state, '') || '|' || coalesce(pincode, ''), '|', '') <> '' and (policy_ref) is not null
union all
    select (coalesce(building, '') || '|' || coalesce(streetname, '') || '|' || coalesce(city, '') || '|' || coalesce(state, '') || '|' || coalesce(pincode, '') || '|' || coalesce(country, '')) as LOCATION_BK, (policynumber) as POLICY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_LOG_TABLE' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_log_table') }}
    where replace(coalesce(building, '') || '|' || coalesce(streetname, '') || '|' || coalesce(city, '') || '|' || coalesce(state, '') || '|' || coalesce(pincode, '') || '|' || coalesce(country, ''), '|', '') <> '' and (policynumber) is not null
union all
    select (transitfrom) as LOCATION_BK, (policynumber) as POLICY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_LOG_TABLE' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_log_table') }}
    where replace(transitfrom, '|', '') <> '' and (policynumber) is not null
union all
    select (transitto) as LOCATION_BK, (policynumber) as POLICY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_LOG_TABLE' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_log_table') }}
    where replace(transitto, '|', '') <> '' and (policynumber) is not null
