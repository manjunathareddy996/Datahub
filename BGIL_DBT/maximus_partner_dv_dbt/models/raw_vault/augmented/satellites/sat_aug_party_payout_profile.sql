{{
    config(
        materialized='incremental',
    )
}}

-- MAXIMUS PARTNER AUGMENTED (unconfirmed) sat() for SAT_AUG_PARTY_PAYOUT_PROFILE, at HUB_PARTY grain.
-- partner_dv_dbt does not build sat_aug_party_payout_profile; Maximus-only augmented table.
-- Payload columns are the mapper's PROPOSED ATTRIBUTE names in partner_dv_dbt's own rendering
-- (squashed), not raw Maximus column names -- a shared table must not gain a second column for a
-- fact that already has one. NOT part of the canonical model.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_mp__pd_prop_msdp_pv__party'
  - 'stg2_aug_mp__pd_prop_sp_pv__party'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'DEFAULTCREDITGLACCOUNTCODE'
  - 'DEFAULTDEBITGLACCOUNTCODE'
  - 'FLOAT_ACCOUNT_ACCESS_INDICATOR'
  - 'FLOATREPLENISHMENTCONDITION'
  - 'INTERIMPAYMENTINDICATOR'
  - 'LOWER_TDS_CERTIFICATE_REFERENCE'
  - 'PAYCLAIMSCANCELMONTHLYINDICATOR'
  - 'PAYEECODE'
  - 'PAYEENAME'
  - 'PAYEETYPE'
  - 'PAYMENTDETAILSDESCRIPTION'
  - 'PAYMENT_MODE'
  - 'PAYMENTPLAN'
  - 'PAYMENTSCHEDULE'
  - 'REWARD_SCHEME_APPLICABLE_INDICATOR'
  - 'SERVICETAXAPPLICABLEINDICATOR'
  - 'TDSCERTIFICATEISSUEDATE'
  - 'TDSCERTIFICATENUMBER'
  - 'TDSCERTIFICATETYPE'
  - 'TDS_CODE'
  - 'TDS_CODE_DESCRIPTION'
  - 'TDSDETAILDESCRIPTION'
  - 'TDSSECTIONCODE'
src_hashdiff: 'HASHDIFF_AUG_PARTY_PAYOUT_PROFILE'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_aug_mp__pd_prop_msdp_pv__party: 'MAXIMUS_PARTNER'
  stg2_aug_mp__pd_prop_sp_pv__party: 'MAXIMUS_PARTNER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_hashdiff_alias='HASHDIFF',
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_column_map={
                        'stg2_aug_mp__pd_prop_msdp_pv__party': ['DEFAULTCREDITGLACCOUNTCODE', 'DEFAULTDEBITGLACCOUNTCODE', 'PAYEETYPE', 'TDSCERTIFICATEISSUEDATE', 'TDSCERTIFICATENUMBER', 'TDSCERTIFICATETYPE', 'TDSSECTIONCODE'],
                        'stg2_aug_mp__pd_prop_sp_pv__party': ['FLOAT_ACCOUNT_ACCESS_INDICATOR', 'FLOATREPLENISHMENTCONDITION', 'INTERIMPAYMENTINDICATOR', 'LOWER_TDS_CERTIFICATE_REFERENCE', 'PAYCLAIMSCANCELMONTHLYINDICATOR', 'PAYEECODE', 'PAYEENAME', 'PAYMENTDETAILSDESCRIPTION', 'PAYMENT_MODE', 'PAYMENTPLAN', 'PAYMENTSCHEDULE', 'REWARD_SCHEME_APPLICABLE_INDICATOR', 'SERVICETAXAPPLICABLEINDICATOR', 'TDS_CODE', 'TDS_CODE_DESCRIPTION', 'TDSDETAILDESCRIPTION']
                    }) }}
