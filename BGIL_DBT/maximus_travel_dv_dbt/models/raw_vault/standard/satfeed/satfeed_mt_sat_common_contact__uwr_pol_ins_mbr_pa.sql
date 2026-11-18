{{ config(materialized='view') }}

-- FEED for SAT_COMMON_CONTACT from stg2_mt_up__uwr_pol_ins_mbr_pa__sat_common_contact.
-- One satfeed per stage (no UNION) so the sat's per-source watermark and change detection stay intact.
--
-- Payload columns are renamed to the shared names the partner projects write (MOBILENUMBER, ...).
-- RECORD_SOURCE gets the instance (CONTACT_POINT_TYPE) appended. sat_multi_source builds the
-- MOBILENUMBER object keyed by RECORD_SOURCE (group prefix removed), so without this suffix the
-- claim / KYC / registered ... mobiles of one stage would share a key and only one would survive.
-- The unpivot and stg2_mt_up__ models are untouched, so hub_party keeps its original RECORD_SOURCE.

select
    PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY,
    HASHDIFF_COMMON_CONTACT as HASHDIFF,
    ALTERNATE_EMAIL_ADDRESS as ALTERNATE_EMAIL_ADDRESS,
    ALTERNATE_MOBILE_NUMBER as ALTERNATE_MOBILE_NUMBER,
    CONTACT_POINT_USAGE,
    EMAIL_ADDRESS as EMAIL_ADDRESS,
    FAX_NUMBER as FAX_NUMBER,
    LANDLINE_NUMBER as LANDLINE_NUMBER,
    MOBILE_NUMBER as MOBILE_NUMBER,
    SOCIAL_MEDIA_HANDLE as SOCIALMEDIAHANDLE,
    STD_CODE as STD_CODE,
    LOAD_DATETIME,
    RECORD_SOURCE || '_' || CONTACT_POINT_TYPE as RECORD_SOURCE
from {{ ref('stg2_mt_up__uwr_pol_ins_mbr_pa__sat_common_contact') }}
where PARTY_HKEY__INSURED_MEMBER is not null
