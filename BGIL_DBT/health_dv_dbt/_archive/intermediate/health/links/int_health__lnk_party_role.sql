-- Intermediate harmonisation view for LNK_PARTY_ROLE (Party Plays Role).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        part_id as party_bk,
        mem_seqno as link_instance_bk,
        'BA_HCP_DT_MEM_COV' as record_source
    from {{ ref('stg_health__ba_hcp_dt_mem_cov') }}
    where part_id is not null and mem_seqno is not null

    union all

    select distinct
        alloted_to as party_bk,
        mem_seqno as link_instance_bk,
        'BA_HCP_PP_MEM_DTLS' as record_source
    from {{ ref('stg_health__ba_hcp_pp_mem_dtls') }}
    where alloted_to is not null and mem_seqno is not null

)

select distinct party_bk, link_instance_bk, record_source
from unioned
