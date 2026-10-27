{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_QUOTE_HEALTH_DECLARATION: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        QUOTE_HKEY as QUOTE_HKEY,
        PRE_EXISTING_DISEASE_ONSET_MONTH,
        PRE_EXISTING_DISEASE_ONSET_YEAR,
        HASHDIFF_QUOTE_HEALTH_DECLARATION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_qpd_polp_msp_imsd_inp_pv__sat_aug_quote_health_declaration') }}
    where QUOTE_HKEY is not null
