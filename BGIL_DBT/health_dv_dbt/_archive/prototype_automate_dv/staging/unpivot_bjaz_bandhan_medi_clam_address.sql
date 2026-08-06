{{ config(materialized='view') }}

-- PROTOTYPE (AutomateDV evaluation) -- see docs/prototype_automate_dv/README.md.
-- Single-table row reshape, NOT a cross-table join: BJAZ_BANDHAN_MEDI_CLAM carries two
-- addresses per row (permanent P_*, mailing M_*). stage()'s hashed_columns/derived_columns
-- map column-to-column on a fixed row shape -- they can't turn 1 row into 2 -- so this one
-- unpivot has to happen before stage(), same as it would have to for any tool. Everything
-- downstream of this is still exactly 1 staging source table in, 1 output.

with permanent as (

    select
        customer_id,
        'permanent' as address_usage_type,
        p_address_line_1 as address_line_1,
        p_address_line_2 as address_line_2,
        p_city as city,
        p_state as state_code,
        p_pincode as postal_code
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where customer_id is not null
      and (p_address_line_1 is not null or p_city is not null or p_pincode is not null)

),

mailing as (

    select
        customer_id,
        'mailing' as address_usage_type,
        m_address_line_1 as address_line_1,
        m_address_line_2 as address_line_2,
        m_city as city,
        m_state as state_code,
        m_pincode as postal_code
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where customer_id is not null
      and (m_address_line_1 is not null or m_city is not null or m_pincode is not null)

)

select * from permanent
union all
select * from mailing
