{{ config(materialized='view') }}
-- BUILD-SIDE BUSINESS KEYS for LNK_POLICY_PRODUCT (Policy Product): 2 feeder(s) over 2 hub leg(s).
--
-- Not in the mapper's map. Each feeder is a stg2_mt__ view in which every hub of this link
-- has exactly ONE key slot, so both/all legs come from one source row with no pairing
-- guesswork. Views with several slots per hub are deliberately left out. The NK columns
-- are the hub stage models' own, so a leg and its hub are byte-identical.
-- Written by generators/gen_mt_links_extra.py.
    select POLICY_NK as POLICY_NK, POLICY_BK as POLICY_BK, PRODUCT_NK as PRODUCT_NK, PRODUCT_BK as PRODUCT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol') }}
    where POLICY_BK is not null and PRODUCT_BK is not null
union all
    select POLICY_NK as POLICY_NK, POLICY_BK as POLICY_BK, PRODUCT_NK as PRODUCT_NK, PRODUCT_BK as PRODUCT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_rskp_sp_pv') }}
    where POLICY_BK is not null and PRODUCT_BK is not null
