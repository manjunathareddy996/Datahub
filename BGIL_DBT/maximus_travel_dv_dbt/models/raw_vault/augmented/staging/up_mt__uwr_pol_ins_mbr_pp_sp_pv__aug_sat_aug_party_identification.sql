{{ config(materialized='view') }}

-- AUGMENTED instance fan-out for SAT_AUG_PARTY_IDENTIFICATION from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
-- 9 branch(es): a column-as-instance family on the unratified track.
--
-- Payload null-padded to the SATELLITE, not to a branch (BUILD_RULES 6).

    select
        nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__INSURED_MEMBER,
        'AADHAAR' as IDENTIFICATION_TYPE_CODE,
        cast(null as varchar) as EIA_CREDIT_REQUIRED_INDICATOR,
        cast(null as varchar) as EIA_DETAILS_NARRATIVE,
        cast(null as varchar) as EIA_HELD_INDICATOR,
        cast(null as varchar) as EIA_LINKED_DATE,
        cast(null as varchar) as EIA_REQUIRED_INDICATOR,
        cast(null as varchar) as IDENTIFICATION_DETAILS_NARRATIVE,
        cast(null as varchar) as IDENTIFICATION_VERIFICATION_STATUS,
        name_as_per_aadhaar as NAME_AS_PER_IDENTIFICATION_DOCUMENT,
        cast(null as varchar) as OVD_CATEGORY_OTHER_DESCRIPTION,
        cast(null as varchar) as PAN_AADHAAR_LINKED_INDICATOR,
        cast(null as varchar) as PASSPORT_DETAIL_DESCRIPTION,
        cast(null as varchar) as PASSPORT_FILE_NUMBER,
        cast(null as varchar) as PASSPORT_ISSUING_COUNTRY,
        cast(null as varchar) as PROOF_OF_ADDRESS_OTHER_DESCRIPTION,
        cast(null as varchar) as STATE_WISE_GSTIN_REGISTRATION_DETAILS,
        rec_refresh_at,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
    where name_as_per_aadhaar is not null
union all
    select
        nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__INSURED_MEMBER,
        'CKYC' as IDENTIFICATION_TYPE_CODE,
        cast(null as varchar) as EIA_CREDIT_REQUIRED_INDICATOR,
        cast(null as varchar) as EIA_DETAILS_NARRATIVE,
        cast(null as varchar) as EIA_HELD_INDICATOR,
        cast(null as varchar) as EIA_LINKED_DATE,
        cast(null as varchar) as EIA_REQUIRED_INDICATOR,
        cast(null as varchar) as IDENTIFICATION_DETAILS_NARRATIVE,
        cast(null as varchar) as IDENTIFICATION_VERIFICATION_STATUS,
        name_as_per_ckyc as NAME_AS_PER_IDENTIFICATION_DOCUMENT,
        cast(null as varchar) as OVD_CATEGORY_OTHER_DESCRIPTION,
        cast(null as varchar) as PAN_AADHAAR_LINKED_INDICATOR,
        cast(null as varchar) as PASSPORT_DETAIL_DESCRIPTION,
        cast(null as varchar) as PASSPORT_FILE_NUMBER,
        cast(null as varchar) as PASSPORT_ISSUING_COUNTRY,
        cast(null as varchar) as PROOF_OF_ADDRESS_OTHER_DESCRIPTION,
        cast(null as varchar) as STATE_WISE_GSTIN_REGISTRATION_DETAILS,
        rec_refresh_at,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
    where name_as_per_ckyc is not null
union all
    select
        nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__INSURED_MEMBER,
        'DRIVING_LICENCE' as IDENTIFICATION_TYPE_CODE,
        cast(null as varchar) as EIA_CREDIT_REQUIRED_INDICATOR,
        cast(null as varchar) as EIA_DETAILS_NARRATIVE,
        cast(null as varchar) as EIA_HELD_INDICATOR,
        cast(null as varchar) as EIA_LINKED_DATE,
        cast(null as varchar) as EIA_REQUIRED_INDICATOR,
        driving_license_details as IDENTIFICATION_DETAILS_NARRATIVE,
        cast(null as varchar) as IDENTIFICATION_VERIFICATION_STATUS,
        cast(null as varchar) as NAME_AS_PER_IDENTIFICATION_DOCUMENT,
        cast(null as varchar) as OVD_CATEGORY_OTHER_DESCRIPTION,
        cast(null as varchar) as PAN_AADHAAR_LINKED_INDICATOR,
        cast(null as varchar) as PASSPORT_DETAIL_DESCRIPTION,
        cast(null as varchar) as PASSPORT_FILE_NUMBER,
        cast(null as varchar) as PASSPORT_ISSUING_COUNTRY,
        cast(null as varchar) as PROOF_OF_ADDRESS_OTHER_DESCRIPTION,
        cast(null as varchar) as STATE_WISE_GSTIN_REGISTRATION_DETAILS,
        rec_refresh_at,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
    where driving_license_details is not null
union all
    select
        nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__INSURED_MEMBER,
        'EIA' as IDENTIFICATION_TYPE_CODE,
        eia_credit_required as EIA_CREDIT_REQUIRED_INDICATOR,
        eia_details as EIA_DETAILS_NARRATIVE,
        eia_available as EIA_HELD_INDICATOR,
        eia_when_linked as EIA_LINKED_DATE,
        eia_required as EIA_REQUIRED_INDICATOR,
        cast(null as varchar) as IDENTIFICATION_DETAILS_NARRATIVE,
        cast(null as varchar) as IDENTIFICATION_VERIFICATION_STATUS,
        cast(null as varchar) as NAME_AS_PER_IDENTIFICATION_DOCUMENT,
        cast(null as varchar) as OVD_CATEGORY_OTHER_DESCRIPTION,
        cast(null as varchar) as PAN_AADHAAR_LINKED_INDICATOR,
        cast(null as varchar) as PASSPORT_DETAIL_DESCRIPTION,
        cast(null as varchar) as PASSPORT_FILE_NUMBER,
        cast(null as varchar) as PASSPORT_ISSUING_COUNTRY,
        cast(null as varchar) as PROOF_OF_ADDRESS_OTHER_DESCRIPTION,
        cast(null as varchar) as STATE_WISE_GSTIN_REGISTRATION_DETAILS,
        rec_refresh_at,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
    where eia_available is not null or eia_credit_required is not null or eia_details is not null or eia_required is not null or eia_when_linked is not null
union all
    select
        nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__INSURED_MEMBER,
        'GSTIN' as IDENTIFICATION_TYPE_CODE,
        cast(null as varchar) as EIA_CREDIT_REQUIRED_INDICATOR,
        cast(null as varchar) as EIA_DETAILS_NARRATIVE,
        cast(null as varchar) as EIA_HELD_INDICATOR,
        cast(null as varchar) as EIA_LINKED_DATE,
        cast(null as varchar) as EIA_REQUIRED_INDICATOR,
        cast(null as varchar) as IDENTIFICATION_DETAILS_NARRATIVE,
        cast(null as varchar) as IDENTIFICATION_VERIFICATION_STATUS,
        cast(null as varchar) as NAME_AS_PER_IDENTIFICATION_DOCUMENT,
        cast(null as varchar) as OVD_CATEGORY_OTHER_DESCRIPTION,
        cast(null as varchar) as PAN_AADHAAR_LINKED_INDICATOR,
        cast(null as varchar) as PASSPORT_DETAIL_DESCRIPTION,
        cast(null as varchar) as PASSPORT_FILE_NUMBER,
        cast(null as varchar) as PASSPORT_ISSUING_COUNTRY,
        cast(null as varchar) as PROOF_OF_ADDRESS_OTHER_DESCRIPTION,
        statewise_gstin_details as STATE_WISE_GSTIN_REGISTRATION_DETAILS,
        rec_refresh_at,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
    where statewise_gstin_details is not null
union all
    select
        nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__INSURED_MEMBER,
        'PAN' as IDENTIFICATION_TYPE_CODE,
        cast(null as varchar) as EIA_CREDIT_REQUIRED_INDICATOR,
        cast(null as varchar) as EIA_DETAILS_NARRATIVE,
        cast(null as varchar) as EIA_HELD_INDICATOR,
        cast(null as varchar) as EIA_LINKED_DATE,
        cast(null as varchar) as EIA_REQUIRED_INDICATOR,
        cast(null as varchar) as IDENTIFICATION_DETAILS_NARRATIVE,
        cast(null as varchar) as IDENTIFICATION_VERIFICATION_STATUS,
        name_as_per_pan as NAME_AS_PER_IDENTIFICATION_DOCUMENT,
        cast(null as varchar) as OVD_CATEGORY_OTHER_DESCRIPTION,
        pan_aadhaar_linked as PAN_AADHAAR_LINKED_INDICATOR,
        cast(null as varchar) as PASSPORT_DETAIL_DESCRIPTION,
        cast(null as varchar) as PASSPORT_FILE_NUMBER,
        cast(null as varchar) as PASSPORT_ISSUING_COUNTRY,
        cast(null as varchar) as PROOF_OF_ADDRESS_OTHER_DESCRIPTION,
        cast(null as varchar) as STATE_WISE_GSTIN_REGISTRATION_DETAILS,
        rec_refresh_at,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
    where name_as_per_pan is not null or pan_aadhaar_linked is not null
union all
    select
        nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__INSURED_MEMBER,
        'PASSPORT' as IDENTIFICATION_TYPE_CODE,
        cast(null as varchar) as EIA_CREDIT_REQUIRED_INDICATOR,
        cast(null as varchar) as EIA_DETAILS_NARRATIVE,
        cast(null as varchar) as EIA_HELD_INDICATOR,
        cast(null as varchar) as EIA_LINKED_DATE,
        cast(null as varchar) as EIA_REQUIRED_INDICATOR,
        cast(null as varchar) as IDENTIFICATION_DETAILS_NARRATIVE,
        cast(null as varchar) as IDENTIFICATION_VERIFICATION_STATUS,
        cast(null as varchar) as NAME_AS_PER_IDENTIFICATION_DOCUMENT,
        cast(null as varchar) as OVD_CATEGORY_OTHER_DESCRIPTION,
        cast(null as varchar) as PAN_AADHAAR_LINKED_INDICATOR,
        passport_details as PASSPORT_DETAIL_DESCRIPTION,
        cast(null as varchar) as PASSPORT_FILE_NUMBER,
        cast(null as varchar) as PASSPORT_ISSUING_COUNTRY,
        cast(null as varchar) as PROOF_OF_ADDRESS_OTHER_DESCRIPTION,
        cast(null as varchar) as STATE_WISE_GSTIN_REGISTRATION_DETAILS,
        rec_refresh_at,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
    where passport_details is not null
union all
    select
        nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__INSURED_MEMBER,
        'PROOF_OF_ADDRESS' as IDENTIFICATION_TYPE_CODE,
        cast(null as varchar) as EIA_CREDIT_REQUIRED_INDICATOR,
        cast(null as varchar) as EIA_DETAILS_NARRATIVE,
        cast(null as varchar) as EIA_HELD_INDICATOR,
        cast(null as varchar) as EIA_LINKED_DATE,
        cast(null as varchar) as EIA_REQUIRED_INDICATOR,
        cast(null as varchar) as IDENTIFICATION_DETAILS_NARRATIVE,
        claim_poa_status as IDENTIFICATION_VERIFICATION_STATUS,
        cast(null as varchar) as NAME_AS_PER_IDENTIFICATION_DOCUMENT,
        proof_of_address_submitted_for_current_permanent_overseas_addressothers as OVD_CATEGORY_OTHER_DESCRIPTION,
        cast(null as varchar) as PAN_AADHAAR_LINKED_INDICATOR,
        cast(null as varchar) as PASSPORT_DETAIL_DESCRIPTION,
        cast(null as varchar) as PASSPORT_FILE_NUMBER,
        cast(null as varchar) as PASSPORT_ISSUING_COUNTRY,
        cast(null as varchar) as PROOF_OF_ADDRESS_OTHER_DESCRIPTION,
        cast(null as varchar) as STATE_WISE_GSTIN_REGISTRATION_DETAILS,
        rec_refresh_at,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
    where claim_poa_status is not null or proof_of_address_submitted_for_current_permanent_overseas_addressothers is not null
union all
    select
        nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__INSURED_MEMBER,
        'PROOF_OF_IDENTITY' as IDENTIFICATION_TYPE_CODE,
        cast(null as varchar) as EIA_CREDIT_REQUIRED_INDICATOR,
        cast(null as varchar) as EIA_DETAILS_NARRATIVE,
        cast(null as varchar) as EIA_HELD_INDICATOR,
        cast(null as varchar) as EIA_LINKED_DATE,
        cast(null as varchar) as EIA_REQUIRED_INDICATOR,
        cast(null as varchar) as IDENTIFICATION_DETAILS_NARRATIVE,
        claim_poi_status as IDENTIFICATION_VERIFICATION_STATUS,
        cast(null as varchar) as NAME_AS_PER_IDENTIFICATION_DOCUMENT,
        cast(null as varchar) as OVD_CATEGORY_OTHER_DESCRIPTION,
        cast(null as varchar) as PAN_AADHAAR_LINKED_INDICATOR,
        cast(null as varchar) as PASSPORT_DETAIL_DESCRIPTION,
        cast(null as varchar) as PASSPORT_FILE_NUMBER,
        cast(null as varchar) as PASSPORT_ISSUING_COUNTRY,
        cast(null as varchar) as PROOF_OF_ADDRESS_OTHER_DESCRIPTION,
        cast(null as varchar) as STATE_WISE_GSTIN_REGISTRATION_DETAILS,
        rec_refresh_at,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
    where claim_poi_status is not null
