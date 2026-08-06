{{
    config(
        materialized='incremental',
        unique_key=None
    )
}}

-- Satellite: SAT_LNK_ROLE_EMPLOYEE
-- SUBJECT-ATTRIBUTION REANCHOR: 9 contributing branch(es) hold a DIFFERENT person's data than the table's default
-- anchor party (nominee/RM/intermediary/hospital/provider) -- keyed via their own
-- companion column, not the table's main HUB_PARTY key. Branches: BA_HCP_PROD_8428_GPG_LOADER::imd-relationship-manager, BA_HCP_PROD_8428_GPG_LOADER::insurer-relationship-manager, BA_HCP_PROD_8432_ECP_LOADER::imd-relationship-manager, BA_HCP_PROD_8432_ECP_LOADER::insurer-relationship-manager, BA_HCP_PROD_8433_FHC_LOADER::imd-relationship-manager, BA_HCP_PROD_8433_FHC_LOADER::insurer-relationship-manager, BA_HCP_PROD_8439_CLH_LOADER::imd-relationship-manager, BA_HCP_PROD_8439_CLH_LOADER::insurer-relationship-manager, BJAZ_GPG_POL_DTLS::relationship-manager. See docs/appendix_9_subject_attribution.csv.
-- MODELLING DEVIATION: canonical parent is LNK_PARTY_ROLE, but no Health source table
-- carries a role-instance/sequence column. Built directly off HUB_PARTY with a literal
-- role-type discriminator ('EMPLOYEE'), NOT tied to lnk_party_role.party_role_hkey.
-- Parent: HUB_PARTY
-- Multi-active grain key: literal role type (EMPLOYEE)
-- Source: {{ ref('int_health__sat_lnk_role_employee') }}. No joins in THIS load.

with source_data as (

    select parent_bk, role_type_ck, employee_code, record_source
    from {{ ref('int_health__sat_lnk_role_employee') }}

),

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(["'HUB_PARTY'", 'parent_bk']) }} as party_hkey,
        parent_bk, role_type_ck,
        employee_code,
        record_source
    from source_data

),

hashed as (

    select
        party_hkey,
        role_type_ck,
        employee_code,
        {{ dbt_utils.generate_surrogate_key(['employee_code']) }} as hashdiff,
        record_source,
        current_timestamp() as load_dts
    from keyed

),

deduped as (

    select *
    from hashed
    qualify row_number() over (
        partition by party_hkey, role_type_ck, hashdiff
        order by record_source
    ) = 1

)

select
    party_hkey,
    role_type_ck,
        employee_code,
    hashdiff,
    record_source,
    load_dts
from deduped d
{% if is_incremental() %}
where not exists (
    select 1 from {{ this }} t
    where t.party_hkey = d.party_hkey and t.role_type_ck = d.role_type_ck
      and t.hashdiff = d.hashdiff
)
{% endif %}
