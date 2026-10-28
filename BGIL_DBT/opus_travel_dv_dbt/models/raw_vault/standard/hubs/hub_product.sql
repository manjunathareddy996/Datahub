{{ config(materialized='incremental') }}

-- TRAVEL STANDARD-MODEL hub() for HUB_PRODUCT, 10 contributing table(s).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_ba_trv_data_policy_dtls_mv__product_product_code'
  - 'stg2_hub_ba_trv_data_policy_dtls_mv__product_travel_plan_no'
  - 'stg2_hub_ba_trv_plan_mst_mv__product'
  - 'stg2_hub_bjaz_trv_loader_data_mv__product'
  - 'stg2_hub_bjaz_trv_loader_log_table_mv__product_planid'
  - 'stg2_hub_bjaz_trv_loader_log_table_mv__product_travelplan'
  - 'stg2_hub_bjaz_trv_loader_log_table_mv__product_product'
  - 'stg2_hub_bjaz_trv_plan_mv__product'
  - 'stg2_hub_bjaz_trv_rate_master_mv__product'
  - 'stg2_hub_bjaz_trv_detls_extn__product'
src_pk: 'PRODUCT_HKEY'
src_nk: 'PARENT_BK'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                    src_nk=metadata_dict['src_nk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
