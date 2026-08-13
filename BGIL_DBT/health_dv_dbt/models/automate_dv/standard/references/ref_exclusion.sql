{{
    config(
        materialized='view'
    )
}}

-- Reference: REF_EXCLUSION
-- Source confirmed by the mapping owner: BJAZ_HM_EXCLUSION_MASTER is the code master (was
-- previously zero mapped rows in the Health workbook -- see docs/HEALTH_DV_BUILD_NOTES.md).
-- Single source table, no joins, no historisation (a reference code list, not a satellite).
-- Ported from the archived hand-written build (models/_archive/raw_vault) -- references were
-- never part of the AutomateDV standard-model generation pass; this file is unchanged.

select distinct
    exclusion_code,
    exclusion_detail as exclusion_description,
    exclusion_sub_id
from {{ ref('stg_health__bjaz_hm_exclusion_master') }}
where exclusion_code is not null
