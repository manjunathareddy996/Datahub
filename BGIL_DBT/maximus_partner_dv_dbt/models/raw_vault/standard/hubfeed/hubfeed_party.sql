{{ config(materialized='view') }}

-- Feed for HUB_PARTY: renames Maximus's PARTY_BK / PARTY_HKEY to the names
-- partner_dv_dbt already writes (PARENT_BK / PARTY_HKEY), so both projects populate ONE
-- set of columns in the shared table instead of two.

    select PARTY_HKEY as PARTY_HKEY, PARTY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd') }}
    union all
    select PARTY_HKEY as PARTY_HKEY, PARTY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_addr') }}
    union all
    select PARTY_HKEY as PARTY_HKEY, PARTY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_party_addr_prop_pv') }}
    union all
    select PARTY_HKEY as PARTY_HKEY, PARTY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_prop_msdp_pv') }}
    union all
    select PARTY_HKEY as PARTY_HKEY, PARTY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_prop_sp_pv') }}
    union all
    select PARTY_HKEY as PARTY_HKEY, PARTY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_rel') }}
    union all
    select PARTY_HKEY as PARTY_HKEY, PARTY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_relparty') }}
    union all
    select PARTY_HKEY as PARTY_HKEY, PARTY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp_up__pd_prop_msdp_pv__lnk_party_role_core') }}
    union all
    select PARTY_HKEY as PARTY_HKEY, PARTY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp_up__pd_prop_msdp_pv__party_digital_identity') }}
    union all
    select PARTY_HKEY as PARTY_HKEY, PARTY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp_up__pd_prop_sp_pv__lnk_party_role_core') }}
    union all
    select PARTY_HKEY as PARTY_HKEY, PARTY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp_up__pd_prop_sp_pv__party_digital_identity') }}
    union all
    select PARTY_HKEY as PARTY_HKEY, PARTY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp_up__pd_prop_sp_pv__party_org_directors') }}
    union all
    select PARTY_HKEY as PARTY_HKEY, PARTY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp_up__pd_prop_sp_pv__party_provider_capability') }}
    union all
    select PARTY_HKEY as PARTY_HKEY, PARTY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp_up__pd_rel__lnk_party_role_core') }}
    union all
    select PARTY_HKEY as PARTY_HKEY, PARTY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp_up__pd_relparty__lnk_party_role_core') }}
