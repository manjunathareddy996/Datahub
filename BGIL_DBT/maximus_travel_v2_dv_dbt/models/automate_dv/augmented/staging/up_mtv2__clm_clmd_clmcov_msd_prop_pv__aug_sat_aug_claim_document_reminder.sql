{{ config(materialized='view') }}

-- AUGMENTED instance fan-out for SAT_AUG_CLAIM_DOCUMENT_REMINDER from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
-- 3 branch(es): a column-as-instance family on the unratified track.
--
-- Payload null-padded to the SATELLITE, not to a branch (BUILD_RULES 6).

    select
        nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        '1' as REMINDER_SEQUENCE,
        'REQUIREMENT_TYPE_NAME' as REQUIREMENT_TYPE_NAME,
        col_1st_reminder_date as REMINDER_DATE,
        'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmcov_msd_prop_pv') }}
    where col_1st_reminder_date is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        '2' as REMINDER_SEQUENCE,
        'REQUIREMENT_TYPE_NAME' as REQUIREMENT_TYPE_NAME,
        col_2nd_reminder_date as REMINDER_DATE,
        'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmcov_msd_prop_pv') }}
    where col_2nd_reminder_date is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        '3' as REMINDER_SEQUENCE,
        'REQUIREMENT_TYPE_NAME' as REQUIREMENT_TYPE_NAME,
        col_3rd_reminder_date as REMINDER_DATE,
        'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmcov_msd_prop_pv') }}
    where col_3rd_reminder_date is not null
