{{ config(materialized='view') }}
-- BUILD-SIDE BUSINESS KEYS for LNK_RISK_OBJECT_PARTY (Risk Object Interest): 2 feeder(s) over 2 hub leg(s).
--
-- Not in the mapper's map. Each feeder is a stg2_mt__ view in which every hub of this link
-- has exactly ONE key slot, so both/all legs come from one source row with no pairing
-- guesswork. Views with several slots per hub are deliberately left out. The NK columns
-- are the hub stage models' own, so a leg and its hub are byte-identical.
-- Written by generators/gen_mt_links_extra.py.
    select RISK_OBJECT_NK as RISK_OBJECT_NK, RISK_OBJECT_BK as RISK_OBJECT_BK, PARTY_NK__NOMINEE as PARTY_NK, PARTY_BK__NOMINEE as PARTY_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where RISK_OBJECT_BK is not null and PARTY_BK__NOMINEE is not null
union all
    select RISK_OBJECT_NK as RISK_OBJECT_NK, RISK_OBJECT_BK as RISK_OBJECT_BK, PARTY_NK__NOMINEE as PARTY_NK, PARTY_BK__NOMINEE as PARTY_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_rskl_msp_imsd_inp_pv') }}
    where RISK_OBJECT_BK is not null and PARTY_BK__NOMINEE is not null
