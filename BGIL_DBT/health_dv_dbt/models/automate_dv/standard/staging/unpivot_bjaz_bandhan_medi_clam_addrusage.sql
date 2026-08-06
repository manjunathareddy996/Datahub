{{ config(materialized='view') }}

-- STANDARD-MODEL: single-table row reshape (not a join) for the M4 party-address route.
-- BJAZ_BANDHAN_MEDI_CLAM carries two addresses per row -- P_* (proposer) and M_* (member),
-- per MAPPER_NOTE_V5_MODELSYNC.md's address_usage vocabulary (proposer/member/payee/
-- diagnostic-centre). Unpivoted into two rows before stage() can map column-to-column.

with proposer as (

    select
        customer_id,
        'proposer' as address_usage_type,
        p_address_line_1 as address_line_1,
        p_address_line_2 as address_line_2,
        p_city as city,
        p_state as state_code,
        p_pincode as postal_code
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where customer_id is not null
      and (p_address_line_1 is not null or p_city is not null or p_pincode is not null)

),

member as (

    select
        customer_id,
        'member' as address_usage_type,
        m_address_line_1 as address_line_1,
        m_address_line_2 as address_line_2,
        m_city as city,
        m_state as state_code,
        m_pincode as postal_code
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where customer_id is not null
      and (m_address_line_1 is not null or m_city is not null or m_pincode is not null)

)

select * from proposer
union all
select * from member
