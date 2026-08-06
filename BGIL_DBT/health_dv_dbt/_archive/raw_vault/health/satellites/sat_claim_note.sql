{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_CLAIM_NOTE
-- Parent: HUB_CLAIM
-- Multi-active grain key: Note Sequence
-- Source: {{ ref('int_health__sat_claim_note') }}. No joins in THIS load.

with source_data as (

    select parent_bk, note_sequence_ck, follow_up_required_indicator, note_text, record_source
    from {{ ref('int_health__sat_claim_note') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CLAIM'", 'parent_bk']) }} as claim_hkey,
        parent_bk, note_sequence_ck,
        follow_up_required_indicator, note_text,
        record_source
    from source_data

),

hashed as (

    select
        claim_hkey,
        note_sequence_ck,
        follow_up_required_indicator, note_text,
        {{ dbt_utils.generate_surrogate_key(['follow_up_required_indicator', 'note_text']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by claim_hkey, note_sequence_ck, hashdiff
        order by record_source
    ) = 1

)

select
    claim_hkey,
    note_sequence_ck,
        follow_up_required_indicator, note_text,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.claim_hkey = d.claim_hkey and t.note_sequence_ck = d.note_sequence_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
