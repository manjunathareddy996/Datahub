{{
    config(
        materialized='incremental',
        unique_key='case_policy_hkey'
    )
}}

-- Link: LNK_CASE_POLICY (Case Policy) -- Associative
-- Associates a policy with a service/grievance/compliance case.
-- Single contributing source table: no intermediate view created (collapsed).
-- Member end keys are namespaced (see hub hashing convention) and (re)computed with the same
-- formula the parent hub models use, so no join back to the hub tables is needed.

with source_data as (

    select case_bk, policy_bk, record_source
    from (
    select distinct
        itrack_no as case_bk,
        policy_no as policy_bk,
        'BJAZ_TRV_CLM_ITRACK_DTLS' as record_source
    from {{ ref('stg_health__bjaz_trv_clm_itrack_dtls') }}
    where itrack_no is not null and policy_no is not null
    )

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_CASE'", 'case_bk']) }} as case_hkey,
        {{ dbt_utils.generate_surrogate_key(["'HUB_POLICY'", 'policy_bk']) }} as policy_hkey,
        case_bk, policy_bk,
        record_source
    from source_data

),

hashed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'LNK_CASE_POLICY'", 'case_hkey', 'policy_hkey']) }} as case_policy_hkey,
        case_hkey, case_bk, policy_hkey, policy_bk,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (partition by case_policy_hkey order by record_source) = 1

)

select case_policy_hkey, case_hkey, case_bk, policy_hkey, policy_bk, record_source, load_dts
from deduped
{% if is_incremental() %}
where case_policy_hkey not in (select case_policy_hkey from {{ this }})
{% endif %}
