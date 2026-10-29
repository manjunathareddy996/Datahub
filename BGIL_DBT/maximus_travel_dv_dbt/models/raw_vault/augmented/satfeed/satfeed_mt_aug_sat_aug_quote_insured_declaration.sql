{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_QUOTE_INSURED_DECLARATION: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        QUOTE_HKEY as QUOTE_HKEY,
        AGE_BAND,
        CURRENT_MEDICATION_DETAIL,
        DATE_OF_BIRTH,
        PRE_EXISTING_DISEASE_CODE,
        PRE_EXISTING_DISEASE_DESCRIPTION,
        HASHDIFF_QUOTE_INSURED_DECLARATION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_qpd_polp_msp_imsd_inp_pv__sat_aug_quote_insured_declaration') }}
    where QUOTE_HKEY is not null
