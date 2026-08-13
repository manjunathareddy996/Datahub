-- Intermediate harmonisation view for LNK_CLAIM_LOCATION (Claim Location).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        reference_id as claim_bk,
        location_code as location_bk,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where reference_id is not null and location_code is not null

    union all

    select distinct
        clid as claim_bk,
        policy_location as location_bk,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where clid is not null and policy_location is not null

    union all

    select distinct
        claim_id as claim_bk,
        location_code as location_bk,
        'BJAZ_HM_INWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where claim_id is not null and location_code is not null

    union all

    select distinct
        claim_id as claim_bk,
        orphan_loc as location_bk,
        'BJAZ_HM_ORPHAN_REG' as record_source
    from {{ ref('stg_health__bjaz_hm_orphan_reg') }}
    where claim_id is not null and orphan_loc is not null

    union all

    select distinct
        claim_id as claim_bk,
        location_code as location_bk,
        'BJAZ_HM_OUTWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_outward_dtls') }}
    where claim_id is not null and location_code is not null

    union all

    select distinct
        claim_id as claim_bk,
        location_code as location_bk,
        'BJAZ_CLM_WG_TRANS_DTLS' as record_source
    from {{ ref('stg_health__bjaz_clm_wg_trans_dtls') }}
    where claim_id is not null and location_code is not null

    union all

    select distinct
        claim_id as claim_bk,
        location_code as location_bk,
        'BJAZ_CLM_WG_TRANS_DTLS_HIST' as record_source
    from {{ ref('stg_health__bjaz_clm_wg_trans_dtls_hist') }}
    where claim_id is not null and location_code is not null

)

select distinct claim_bk, location_bk, record_source
from unioned
