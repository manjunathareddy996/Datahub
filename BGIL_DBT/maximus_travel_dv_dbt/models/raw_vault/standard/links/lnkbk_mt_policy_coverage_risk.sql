{{ config(materialized='view') }}
-- BUILD-SIDE BUSINESS KEYS for LNK_POLICY_COVERAGE_RISK (Coverage on Risk Object): 1 feeder(s) over 3 hub leg(s).
--
-- Not in the mapper's map. Each feeder is a stg2_mt__ view in which every hub of this link
-- has exactly ONE key slot, so both/all legs come from one source row with no pairing
-- guesswork. Views with several slots per hub are deliberately left out. The NK columns
-- are the hub stage models' own, so a leg and its hub are byte-identical.
-- Written by generators/gen_mt_links_extra.py.
    select POLICY_NK as POLICY_NK, POLICY_BK as POLICY_BK, COVERAGE_NK as COVERAGE_NK, COVERAGE_BK as COVERAGE_BK, RISK_OBJECT_NK as RISK_OBJECT_NK, RISK_OBJECT_BK as RISK_OBJECT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_cov_covp_sp_pv') }}
    where POLICY_BK is not null and COVERAGE_BK is not null and RISK_OBJECT_BK is not null
