/* =====================================================================================
   DM-K1  |  Key checks  |  "No missing keys"
   Sign-off: Every SF Mirror source business key exists in the hub.
   Method:   anti-join  RAW source  ->  HUB   (reconcile against RAW tables, NOT views,
             so a defect in the stg/stitch/unpivot view layer cannot mask a real gap).
   Pass:     0 rows returned (0 missing keys, or documented exceptions).

   HKEY reproduction (identical macro in both projects):
       HKEY = MD5(UPPER(TRIM(COALESCE(CAST( <NK> AS VARCHAR), ''))))
       <NK> = 'HUB_<ENTITY>|' || <trimmed raw key>
       trimmed raw key = nullif(trim(to_varchar(<RAW_COL>)), '')

   Shared vault: both projects write the SAME physical hub tables in BGIL_DATA_MODEL.
   Rows are separated by RECORD_SOURCE prefix (MAXIMUS_% vs OPUS_%); each query is
   scoped to its own project's prefix so one project's keys are not checked against
   the other project's rows.

   Replace the schema placeholders before running:
     &VAULT_SCHEMA   -> BGIL_DATA_MODEL
     &MAXI_RAW       -> BAGIC_PROD_MIRROR_DB.MAXI_RAW
     &OPUS_RAW       -> BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE   (prod)
                        BAGIC_PREPROD_CURATED_DB.UTILS          (test)
   ===================================================================================== */


/* =====================================================================================
   MAXIMUS PROJECT
   ===================================================================================== */

----------------------------------------------------------------------------------------
-- MAXIMUS :: HUB_PARTY   (NK prefix 'HUB_PARTY|')
-- Multi-source: every raw table feeding PARTY_HKEY must have its keys present in the hub.
----------------------------------------------------------------------------------------
with maxi_hub_party_src as (
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(PARTY_CODE)), '') AS VARCHAR), '')))) as PARTY_HKEY
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL
     where nullif(trim(to_varchar(PARTY_CODE)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), ''))))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), ''))))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), ''))))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(BAGIC_EMPLOYEE_CODE)), '') AS VARCHAR), ''))))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1
     where nullif(trim(to_varchar(BAGIC_EMPLOYEE_CODE)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), ''))))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_RELATION
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
    union
    select distinct MD5(UPPER(TRIM(COALESCE(CAST('HUB_PARTY|' || nullif(trim(to_varchar(FOREIGN_KEY)), '') AS VARCHAR), ''))))
      from &MAXI_RAW..BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY
     where nullif(trim(to_varchar(FOREIGN_KEY)), '') is not null
)
select 'MAXIMUS' as project, 'HUB_PARTY' as hub, s.PARTY_HKEY as missing_hkey
  from maxi_hub_party_src s
  left join &VAULT_SCHEMA..HUB_PARTY h
         on h.PARTY_HKEY = s.PARTY_HKEY
        and h.RECORD_SOURCE like 'MAXIMUS_%'
 where h.PARTY_HKEY is null;
