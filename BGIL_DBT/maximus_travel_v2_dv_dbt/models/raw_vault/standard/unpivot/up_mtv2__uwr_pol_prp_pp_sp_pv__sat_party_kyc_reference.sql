{{ config(materialized='view') }}

-- UNPIVOT for SAT_PARTY_KYC_REFERENCE from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
-- one row PER INSTANCE: 2 branch(es).
--
-- Each branch below is ONE instance of the satellite, carrying all of its own
-- attributes on a single row and discriminated by KYC_REFERENCE_TYPE.
-- The hash is taken once, downstream, by stg2_mtv2_up__uwr_pol_prp_pp_sp_pv__sat_party_kyc_reference.
--
-- Payload is null-padded to the SATELLITE's full payload (1 column(s)), not to this
-- feeder's columns, so every feeder of SAT_PARTY_KYC_REFERENCE is union-compatible (BUILD_RULES 6).
--
-- Instances on this view:
--   proof_of_address                         1 attribute(s)
--   proof_of_identity                        1 attribute(s)

    select
        nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__PROPOSER,
        'PROOF_OF_ADDRESS' as KYC_REFERENCE_TYPE,
        poa_status as VERIFICATION_STATUS,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_prp_pp_sp_pv') }}
    where poa_status is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__PROPOSER,
        'PROOF_OF_IDENTITY' as KYC_REFERENCE_TYPE,
        poi_status as VERIFICATION_STATUS,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_prp_pp_sp_pv') }}
    where poi_status is not null
