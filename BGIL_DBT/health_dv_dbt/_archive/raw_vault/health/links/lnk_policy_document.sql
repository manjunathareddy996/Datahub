{{
    config(
        materialized='incremental',
        unique_key='policy_document_hkey'
    )
}}

-- Link: LNK_POLICY_DOCUMENT (Policy Document) -- Associative
-- Associates schedules, certificates and wordings with a policy.
-- Source: {{ ref('int_health__lnk_policy_document') }} (unions 9 contributing tables).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select * from {{ ref('int_health__lnk_policy_document') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_DOCUMENT'", 'document_bk']) }} as document_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'policy_bk']) }} as policy_hkey,
        document_bk, policy_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_POLICY_DOCUMENT'", 'document_hkey', 'policy_hkey']) }} as policy_document_hkey,
        document_hkey, document_bk, policy_hkey, policy_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by policy_document_hkey order by record_source) = 1

)

select policy_document_hkey, document_hkey, document_bk, policy_hkey, policy_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where policy_document_hkey not in (select policy_document_hkey from {{ this }})
{% endif %}
