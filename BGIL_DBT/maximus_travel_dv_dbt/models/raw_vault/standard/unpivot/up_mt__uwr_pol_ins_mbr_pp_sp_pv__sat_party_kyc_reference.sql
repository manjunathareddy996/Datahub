{{ config(materialized='view') }}

-- UNPIVOT for SAT_PARTY_KYC_REFERENCE from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
-- one row PER INSTANCE: 2 branch(es).
--
-- Each branch below is ONE instance of the satellite, carrying all of its own
-- attributes on a single row and discriminated by KYC_REFERENCE_TYPE.
-- The hash is taken once, downstream, by stg2_mt_up__uwr_pol_ins_mbr_pp_sp_pv__sat_party_kyc_reference.
--
-- Payload is null-padded to the SATELLITE's full payload (1 column(s)), not to this
-- feeder's columns, so every feeder of SAT_PARTY_KYC_REFERENCE is union-compatible (BUILD_RULES 6).
--
-- Instances on this view:
--   proof_of_address                         1 attribute(s)
--   proof_of_identity                        1 attribute(s)

-- INCREMENTAL VIEW: returns only rows whose REC_REFRESH_AT is after the latest
-- LOAD_DATETIME this feeder already wrote to SAT_PARTY_KYC_REFERENCE.
--   Incremental (default):  dbt run -s +sat_party_kyc_reference
--   Full load:              dbt run -s +sat_party_kyc_reference --vars '{full_load: true}'
--   (--full-refresh, or SAT_PARTY_KYC_REFERENCE not existing yet, also gives full data)

{%- set sat_rel = adapter.get_relation(database=this.database, schema=this.schema, identifier='SAT_PARTY_KYC_REFERENCE') if execute else none %}
{%- set is_full_load = var('full_load', false) or flags.FULL_REFRESH or sat_rel is none %}

with src as (
    select *
    from {{ ref('resolved_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
    {%- if not is_full_load %}
    where try_to_timestamp_ntz(to_varchar(rec_refresh_at)) > (
        select coalesce(max(try_to_timestamp_ntz(to_varchar(LOAD_DATETIME))), '1900-01-01'::timestamp_ntz)
        from {{ sat_rel }}
        where RECORD_SOURCE = 'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
    )
    {%- endif %}
)

    select
        nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__INSURED_MEMBER,
        'PROOF_OF_ADDRESS' as KYC_REFERENCE_TYPE,
        poa_status as VERIFICATION_STATUS,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from src
    where poa_status is not null
union all
    select
        nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__INSURED_MEMBER,
        'PROOF_OF_IDENTITY' as KYC_REFERENCE_TYPE,
        poi_status as VERIFICATION_STATUS,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from src
    where poi_status is not null
