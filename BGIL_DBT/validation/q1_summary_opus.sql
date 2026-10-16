-- DM-R1 OPUS summary: one row per satellite (orphan-or-null vs parent).
-- Flat UNION ALL (no derived table / no outer order-by on alias).

select 'SAT_AGREEMENT_COMMERCIAL_TERMS' as satellite, 'HUB_AGREEMENT' as parent_table,
       count_if(s.AGREEMENT_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AGREEMENT_COMMERCIAL_TERMS s
  left join (select distinct AGREEMENT_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_AGREEMENT) p on p.k = s.AGREEMENT_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.AGREEMENT_HKEY is null or s.AGREEMENT_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_AGREEMENT_DEFINITION' as satellite, 'HUB_AGREEMENT' as parent_table,
       count_if(s.AGREEMENT_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AGREEMENT_DEFINITION s
  left join (select distinct AGREEMENT_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_AGREEMENT) p on p.k = s.AGREEMENT_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.AGREEMENT_HKEY is null or s.AGREEMENT_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_COMMON_ADDRESS' as satellite, 'HUB_LOCATION' as parent_table,
       count_if(s.LOCATION_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_ADDRESS s
  left join (select distinct LOCATION_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOCATION) p on p.k = s.LOCATION_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.LOCATION_HKEY is null or s.LOCATION_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_COMMON_ADMIN_GEOGRAPHY' as satellite, 'HUB_LOCATION' as parent_table,
       count_if(s.LOCATION_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_ADMIN_GEOGRAPHY s
  left join (select distinct LOCATION_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOCATION) p on p.k = s.LOCATION_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.LOCATION_HKEY is null or s.LOCATION_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_COMMON_CLASSIFICATION' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_CLASSIFICATION s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_COMMON_COMMUNICATION_PREFERENCE' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_COMMUNICATION_PREFERENCE s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_COMMON_CONSENT' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_CONSENT s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_COMMON_CONTACT' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_CONTACT s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where s.RECORD_SOURCE = 'OPUS' and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_COMMON_GEO' as satellite, 'HUB_LOCATION' as parent_table,
       count_if(s.LOCATION_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_GEO s
  left join (select distinct LOCATION_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOCATION) p on p.k = s.LOCATION_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.LOCATION_HKEY is null or s.LOCATION_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_DOCUMENT_DEFINITION' as satellite, 'HUB_DOCUMENT' as parent_table,
       count_if(s.DOCUMENT_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_DOCUMENT_DEFINITION s
  left join (select distinct DOCUMENT_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DOCUMENT) p on p.k = s.DOCUMENT_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.DOCUMENT_HKEY is null or s.DOCUMENT_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_LNK_CLAIM_PARTY_ROLE' as satellite, 'LNK_CLAIM_PARTY' as parent_table,
       count_if(s.CLAIM_PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_CLAIM_PARTY_ROLE s
  left join (select distinct CLAIM_PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_CLAIM_PARTY) p on p.k = s.CLAIM_PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.CLAIM_PARTY_HKEY is null or s.CLAIM_PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_LNK_PARTY_ROLE_CORE' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_PARTY_ROLE_CORE s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_LNK_POLICY_PARTY_ROLE' as satellite, 'LNK_POLICY_PARTY' as parent_table,
       count_if(s.POLICY_PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_POLICY_PARTY_ROLE s
  left join (select distinct POLICY_PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_POLICY_PARTY) p on p.k = s.POLICY_PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.POLICY_PARTY_HKEY is null or s.POLICY_PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_LNK_ROLE_AGENT' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_AGENT s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_LNK_ROLE_CUSTOMER' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_CUSTOMER s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_LNK_ROLE_NOMINEE_BENEFICIARY' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_NOMINEE_BENEFICIARY s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_LNK_ROLE_PROVIDER' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_PROVIDER s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_LNK_ROLE_SURVEYOR' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_SURVEYOR s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_PARTY_AML_SCREENING' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_AML_SCREENING s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_PARTY_BANKING' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_BANKING s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_PARTY_CLAIM_HISTORY' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_CLAIM_HISTORY s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_PARTY_CONTACT_ADDRESS_LINK' as satellite, 'LNK_PARTY_LOCATION' as parent_table,
       count_if(s.PARTY_LOCATION_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_CONTACT_ADDRESS_LINK s
  left join (select distinct PARTY_LOCATION_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LNK_PARTY_LOCATION) p on p.k = s.PARTY_LOCATION_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_LOCATION_HKEY is null or s.PARTY_LOCATION_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_PARTY_EMPLOYMENT' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_EMPLOYMENT s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_PARTY_GROUP_CENSUS' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_GROUP_CENSUS s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_PARTY_GROUP_HOUSEHOLD' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_GROUP_HOUSEHOLD s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_PARTY_HEALTH_PROFILE' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_HEALTH_PROFILE s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_PARTY_IDENTIFICATION' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where s.RECORD_SOURCE = 'OPUS' and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_PARTY_IDENTITY' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTITY s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_PARTY_KYC' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_KYC s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_PARTY_KYC_REFERENCE' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_KYC_REFERENCE s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_PARTY_ORGANISATION_PROFILE' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_ORGANISATION_PROFILE s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_PARTY_VEHICLE_PRIOR_INSURANCE' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_VEHICLE_PRIOR_INSURANCE s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_POLICY_BONUS_TRACKING' as satellite, 'HUB_POLICY' as parent_table,
       count_if(s.POLICY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_BONUS_TRACKING s
  left join (select distinct POLICY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY) p on p.k = s.POLICY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.POLICY_HKEY is null or s.POLICY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_POLICY_CERTIFICATE' as satellite, 'HUB_POLICY' as parent_table,
       count_if(s.POLICY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_CERTIFICATE s
  left join (select distinct POLICY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY) p on p.k = s.POLICY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.POLICY_HKEY is null or s.POLICY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_POLICY_CLASSIFICATION' as satellite, 'HUB_POLICY' as parent_table,
       count_if(s.POLICY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_CLASSIFICATION s
  left join (select distinct POLICY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY) p on p.k = s.POLICY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.POLICY_HKEY is null or s.POLICY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_POLICY_COVERAGE_SCHEDULE' as satellite, 'HUB_POLICY' as parent_table,
       count_if(s.POLICY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_COVERAGE_SCHEDULE s
  left join (select distinct POLICY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY) p on p.k = s.POLICY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.POLICY_HKEY is null or s.POLICY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_POLICY_ENDORSEMENT' as satellite, 'HUB_POLICY' as parent_table,
       count_if(s.POLICY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_ENDORSEMENT s
  left join (select distinct POLICY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY) p on p.k = s.POLICY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.POLICY_HKEY is null or s.POLICY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_POLICY_HEADER' as satellite, 'HUB_POLICY' as parent_table,
       count_if(s.POLICY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_HEADER s
  left join (select distinct POLICY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY) p on p.k = s.POLICY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.POLICY_HKEY is null or s.POLICY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_POLICY_PREMIUM_HEAD' as satellite, 'HUB_POLICY' as parent_table,
       count_if(s.POLICY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_PREMIUM_HEAD s
  left join (select distinct POLICY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY) p on p.k = s.POLICY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.POLICY_HKEY is null or s.POLICY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_POLICY_PREMIUM_SUMMARY' as satellite, 'HUB_POLICY' as parent_table,
       count_if(s.POLICY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_PREMIUM_SUMMARY s
  left join (select distinct POLICY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY) p on p.k = s.POLICY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.POLICY_HKEY is null or s.POLICY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_PRODUCT_DEFINITION' as satellite, 'HUB_PRODUCT' as parent_table,
       count_if(s.PRODUCT_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_DEFINITION s
  left join (select distinct PRODUCT_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PRODUCT) p on p.k = s.PRODUCT_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PRODUCT_HKEY is null or s.PRODUCT_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_PROVIDER_BANKING' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PROVIDER_BANKING s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_PROVIDER_TARIFF' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PROVIDER_TARIFF s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_AUG_AFFINITY_MEMBERSHIP' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_AFFINITY_MEMBERSHIP s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_AUG_AGREEMENT' as satellite, 'HUB_AGREEMENT' as parent_table,
       count_if(s.AGREEMENT_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_AGREEMENT s
  left join (select distinct AGREEMENT_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_AGREEMENT) p on p.k = s.AGREEMENT_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.AGREEMENT_HKEY is null or s.AGREEMENT_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_AUG_CHANNEL' as satellite, 'HUB_DISTRIBUTION_CHANNEL' as parent_table,
       count_if(s.DISTRIBUTION_CHANNEL_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CHANNEL s
  left join (select distinct DISTRIBUTION_CHANNEL_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DISTRIBUTION_CHANNEL) p on p.k = s.DISTRIBUTION_CHANNEL_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.DISTRIBUTION_CHANNEL_HKEY is null or s.DISTRIBUTION_CHANNEL_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_AUG_KYC_DOCUMENT' as satellite, 'HUB_DOCUMENT' as parent_table,
       count_if(s.DOCUMENT_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_KYC_DOCUMENT s
  left join (select distinct DOCUMENT_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DOCUMENT) p on p.k = s.DOCUMENT_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.DOCUMENT_HKEY is null or s.DOCUMENT_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_AUG_KYC_LOCATION' as satellite, 'HUB_LOCATION' as parent_table,
       count_if(s.LOCATION_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_KYC_LOCATION s
  left join (select distinct LOCATION_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOCATION) p on p.k = s.LOCATION_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.LOCATION_HKEY is null or s.LOCATION_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_AUG_KYC_PARTY' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_KYC_PARTY s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_AUG_KYC_POLICY' as satellite, 'HUB_POLICY' as parent_table,
       count_if(s.POLICY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_KYC_POLICY s
  left join (select distinct POLICY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY) p on p.k = s.POLICY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.POLICY_HKEY is null or s.POLICY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_AUG_LAWYER_ADVOCATE_ROLE' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_LAWYER_ADVOCATE_ROLE s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_AUG_LNK_ROLE_AGENT' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_LNK_ROLE_AGENT s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_AUG_LNK_ROLE_CUSTOMER' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_LNK_ROLE_CUSTOMER s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_AUG_LNK_ROLE_PROVIDER' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_LNK_ROLE_PROVIDER s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_AUG_LNK_ROLE_SURVEYOR' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_LNK_ROLE_SURVEYOR s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_AUG_LOCATION' as satellite, 'HUB_LOCATION' as parent_table,
       count_if(s.LOCATION_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_LOCATION s
  left join (select distinct LOCATION_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOCATION) p on p.k = s.LOCATION_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.LOCATION_HKEY is null or s.LOCATION_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_AUG_PARTY' as satellite, 'HUB_PARTY' as parent_table,
       count_if(s.PARTY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY s
  left join (select distinct PARTY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY) p on p.k = s.PARTY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.PARTY_HKEY is null or s.PARTY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
union all
select 'SAT_AUG_POLICY' as satellite, 'HUB_POLICY' as parent_table,
       count_if(s.POLICY_HKEY is null or p.k is null) as orphan_or_null_rows
  from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY s
  left join (select distinct POLICY_HKEY as k from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY) p on p.k = s.POLICY_HKEY
 where startswith(s.RECORD_SOURCE, 'OPUS_') and (s.POLICY_HKEY is null or s.POLICY_HKEY <> TO_BINARY(REPEAT('0', 32), 'HEX'))
;
