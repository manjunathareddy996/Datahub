{{ config(materialized='view') }}

-- AUGMENTED instance fan-out for SAT_AUG_DOCUMENT_REQUIREMENT_REMINDER from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
-- 3 branch(es): a column-as-instance family on the unratified track.
--
-- Payload null-padded to the SATELLITE, not to a branch (BUILD_RULES 6).

    select
        nullif(trim(case when nullif(trim(inward_number),'') is not null then 'INWARD:' || nullif(trim(inward_number), '') end),'') as DOCUMENT_BK__CLAIM_INWARD_DOCUMENT_SET,
        '1' as REMINDER_SEQUENCE,
        col_1st_reminder_date as REMINDER_DATE,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clma_msp_msd_prop_pv') }}
    where col_1st_reminder_date is not null
union all
    select
        nullif(trim(case when nullif(trim(inward_number),'') is not null then 'INWARD:' || nullif(trim(inward_number), '') end),'') as DOCUMENT_BK__CLAIM_INWARD_DOCUMENT_SET,
        '2' as REMINDER_SEQUENCE,
        col_2nd_reminder_date as REMINDER_DATE,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clma_msp_msd_prop_pv') }}
    where col_2nd_reminder_date is not null
union all
    select
        nullif(trim(case when nullif(trim(inward_number),'') is not null then 'INWARD:' || nullif(trim(inward_number), '') end),'') as DOCUMENT_BK__CLAIM_INWARD_DOCUMENT_SET,
        '3' as REMINDER_SEQUENCE,
        col_3rd_reminder_date as REMINDER_DATE,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clma_msp_msd_prop_pv') }}
    where col_3rd_reminder_date is not null
