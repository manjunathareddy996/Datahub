{{ config(materialized='view') }}

-- MAXIMUS PARTNER AUGMENTED (unconfirmed) WIDE stage() for HUB_LOCATION, view 'pd_prop_sp_pv'.
-- Serves 2 augmented satellite(s), one HASHDIFF each, from 2
-- column(s) with no faithful home in data_7. The KEY is the standard track's own
-- expression for HUB_LOCATION on this view; the ATTRIBUTE GROUPING is the mapper's
-- proposal and is NOT canonical.

{%- set yaml_metadata -%}
source_model: 'stg_maximus__pd_prop_sp_pv'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  HASHDIFF_AUG_COMMON_ADDRESS:
    is_hashdiff: true
    columns:
      - 'FULLADDRESSTEXT'
  HASHDIFF_AUG_COMMON_ADMIN_GEOGRAPHY:
    is_hashdiff: true
    columns:
      - 'UNIONTERRITORYINDICATOR'
derived_columns:
  LOCATION_BK: "case when coalesce(upper(trim(to_varchar(our_office_address))), upper(trim(to_varchar(current_permanent_overseas_address_line_2))), upper(trim(to_varchar(current_permanent_overseas_address_line_3))), upper(trim(to_varchar(current_permanent_overseas_address_city_town_village))), upper(trim(to_varchar(correspondence_local_address_district))), upper(trim(to_varchar(current_permanent_overseas_address_state_ut))), upper(trim(to_varchar(local_address_pin_code))), upper(trim(to_varchar(current_permanent_overseas_address_country)))) is null then null else md5(concat_ws('|', coalesce(upper(trim(to_varchar(our_office_address))), ''), coalesce(upper(trim(to_varchar(current_permanent_overseas_address_line_2))), ''), coalesce(upper(trim(to_varchar(current_permanent_overseas_address_line_3))), ''), coalesce(upper(trim(to_varchar(current_permanent_overseas_address_city_town_village))), ''), coalesce(upper(trim(to_varchar(correspondence_local_address_district))), ''), coalesce(upper(trim(to_varchar(current_permanent_overseas_address_state_ut))), ''), coalesce(upper(trim(to_varchar(local_address_pin_code))), ''), coalesce(upper(trim(to_varchar(current_permanent_overseas_address_country))), ''))) end"
  LOCATION_NK: "'HUB_LOCATION|' || (case when coalesce(upper(trim(to_varchar(our_office_address))), upper(trim(to_varchar(current_permanent_overseas_address_line_2))), upper(trim(to_varchar(current_permanent_overseas_address_line_3))), upper(trim(to_varchar(current_permanent_overseas_address_city_town_village))), upper(trim(to_varchar(correspondence_local_address_district))), upper(trim(to_varchar(current_permanent_overseas_address_state_ut))), upper(trim(to_varchar(local_address_pin_code))), upper(trim(to_varchar(current_permanent_overseas_address_country)))) is null then null else md5(concat_ws('|', coalesce(upper(trim(to_varchar(our_office_address))), ''), coalesce(upper(trim(to_varchar(current_permanent_overseas_address_line_2))), ''), coalesce(upper(trim(to_varchar(current_permanent_overseas_address_line_3))), ''), coalesce(upper(trim(to_varchar(current_permanent_overseas_address_city_town_village))), ''), coalesce(upper(trim(to_varchar(correspondence_local_address_district))), ''), coalesce(upper(trim(to_varchar(current_permanent_overseas_address_state_ut))), ''), coalesce(upper(trim(to_varchar(local_address_pin_code))), ''), coalesce(upper(trim(to_varchar(current_permanent_overseas_address_country))), ''))) end)"
  FULLADDRESSTEXT: "current_permanent_overseas_address_"
  UNIONTERRITORYINDICATOR: "ut_flag"
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_pd_prop_sp_pv'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
