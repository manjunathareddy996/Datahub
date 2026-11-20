{{ config(materialized='view', tags=['lnk_extra']) }}
-- BUILD-SIDE BUSINESS KEYS for LNK_POLICY_COVERAGE (Policy Coverage): 3 feeder(s) over 2 hub leg(s).
--
-- Not in the mapper's map. Each feeder is a stg2_mt__ view in which every hub of this link
-- has exactly ONE key slot, so both/all legs come from one source row with no pairing
-- guesswork. Views with several slots per hub are deliberately left out. The NK columns
-- are the hub stage models' own, so a leg and its hub are byte-identical.
-- Written by generators/gen_mt_links_extra.py.
    select POLICY_NK as POLICY_NK, POLICY_BK as POLICY_BK, COVERAGE_NK as COVERAGE_NK, COVERAGE_BK as COVERAGE_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_cov') }}
    where POLICY_BK is not null and COVERAGE_BK is not null
union all
    select POLICY_NK as POLICY_NK, POLICY_BK as POLICY_BK, COVERAGE_NK as COVERAGE_NK, COVERAGE_BK as COVERAGE_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_cov_covp_sp_pv') }}
    where POLICY_BK is not null and COVERAGE_BK is not null
union all
    select POLICY_NK as POLICY_NK, POLICY_BK as POLICY_BK, COVERAGE_NK as COVERAGE_NK, COVERAGE_BK as COVERAGE_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_rskp_sp_pv') }}
    where POLICY_BK is not null and COVERAGE_BK is not null
