-- Intermediate harmonisation view for LNK_PARTY_LOCATION (Party at Location).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        child_loc_code as location_bk,
        user_id as party_bk,
        'BA_HCP_POL_MST' as record_source
    from {{ ref('stg_health__ba_hcp_pol_mst') }}
    where child_loc_code is not null and user_id is not null

    union all

    select distinct
        location_code as location_bk,
        customer_id as party_bk,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where location_code is not null and customer_id is not null

    union all

    select distinct
        policy_location as location_bk,
        hospital_id as party_bk,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where policy_location is not null and hospital_id is not null

    union all

    select distinct
        pin_code as location_bk,
        hosid as party_bk,
        'BJAZ_HM_HOSPITAL_MASTER' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master') }}
    where pin_code is not null and hosid is not null

    union all

    select distinct
        location_code as location_bk,
        courier_id as party_bk,
        'BJAZ_HM_INWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where location_code is not null and courier_id is not null

    union all

    select distinct
        location_code as location_bk,
        user_id as party_bk,
        'BJAZ_GC_GROUP_GUARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gc_group_guard_dtls') }}
    where location_code is not null and user_id is not null

    union all

    select distinct
        locationcode as location_bk,
        bdr_code as party_bk,
        'BJAZ_PNB_GPA_DATA' as record_source
    from {{ ref('stg_health__bjaz_pnb_gpa_data') }}
    where locationcode is not null and bdr_code is not null

    union all

    select distinct
        location_code as location_bk,
        customer_id as party_bk,
        'BJAZ_SUPER_SURAKSHA_DTLS' as record_source
    from {{ ref('stg_health__bjaz_super_suraksha_dtls') }}
    where location_code is not null and customer_id is not null

)

select distinct location_bk, party_bk, record_source
from unioned
