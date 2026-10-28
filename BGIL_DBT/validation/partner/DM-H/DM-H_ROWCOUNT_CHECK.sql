/* =====================================================================================
   DM-H  |  Row-count pre-check for the member test plan
   -------------------------------------------------------------------------------------
   Run this BEFORE starting DM-H1..DM-H4. It reports the row count of every satellite
   assigned in DM-H_MEMBER_PLAN.md, split by project (RECORD_SOURCE prefix).

   If a satellite shows total_rows = 0 (or 0 for the project you are testing), that sat
   cannot produce DM-H evidence. SWAP it for another sat of the SAME macro path from
   DM-H_REMAINING.md, and record the swap (old -> new) in your results.

   Vault: BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL
   Scope per project: MAXIMUS rows -> RECORD_SOURCE like 'MAXIMUS_%'  (object sats: = 'MAXIMUS')
                      OPUS    rows -> RECORD_SOURCE like 'OPUS_%'     (object sats: = 'OPUS')
   ===================================================================================== */

set VAULT = 'BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL';

-- One row per assigned satellite. member/path columns are for traceability only.
with assigned (member, path, satellite) as (
    select * from values
        -- Path 1: automate_dv.sat
        ('M1','automate_dv.sat','SAT_COMMON_ADMIN_GEOGRAPHY'),
        ('M1','automate_dv.sat','SAT_PARTY_FINANCIAL_PROFILE'),
        ('M2','automate_dv.sat','SAT_COMMON_CONSENT'),
        ('M2','automate_dv.sat','SAT_PARTY_FRAUD_PROFILE'),
        ('M3','automate_dv.sat','SAT_COMMON_CLASSIFICATION'),
        ('M3','automate_dv.sat','SAT_PARTY_RELATIONSHIP_PROFILE'),
        -- Path 2: sat_multi_source plain
        ('M1','sat_multi_source','SAT_COMMON_ADDRESS'),
        ('M1','sat_multi_source','SAT_PARTY_BANKING'),
        ('M1','sat_multi_source','SAT_PARTY_IDENTITY'),
        ('M1','sat_multi_source','SAT_LOCATION_PROFILE'),
        ('M1','sat_multi_source','SAT_PARTY_VEHICLE_PRIOR_INSURANCE'),
        ('M1','sat_multi_source','SAT_POLICY_CERTIFICATE'),
        ('M1','sat_multi_source','SAT_AUG_PARTY'),
        ('M2','sat_multi_source','SAT_COMMON_GEO'),
        ('M2','sat_multi_source','SAT_PARTY_ORGANISATION_PROFILE'),
        ('M2','sat_multi_source','SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS'),
        ('M2','sat_multi_source','SAT_PARTY_CONSENT_MANDATE'),
        ('M2','sat_multi_source','SAT_PARTY_BANKING'),
        ('M2','sat_multi_source','SAT_PARTY_KYC'),
        ('M2','sat_multi_source','SAT_AUG_KYC_DOCUMENT'),
        ('M3','sat_multi_source','SAT_PARTY_HIERARCHY'),
        ('M3','sat_multi_source','SAT_PARTY_AGENT_LICENCE_LINE'),
        ('M3','sat_multi_source','SAT_PARTY_PAYOUT_PROFILE'),
        ('M3','sat_multi_source','SAT_AUG_PARTY_IDENTIFICATION'),
        ('M3','sat_multi_source','SAT_PARTY_KYC_REFERENCE'),
        ('M3','sat_multi_source','SAT_POLICY_PREMIUM_SUMMARY'),
        ('M3','sat_multi_source','SAT_AUG_LOCATION'),
        -- Path 3: sat_multi_source OBJECT
        ('M1','sat_multi_source(OBJECT)','SAT_COMMON_CONTACT'),
        ('M1','sat_multi_source(OBJECT)','SAT_PARTY_IDENTIFICATION'),
        ('M2','sat_multi_source(OBJECT)','SAT_PARTY_IDENTIFICATION'),
        ('M3','sat_multi_source(OBJECT)','SAT_COMMON_CONTACT'),
        -- Path 4: ma_sat_multi_source
        ('M1','ma_sat_multi_source','SAT_LNK_PARTY_ROLE_CORE'),
        ('M1','ma_sat_multi_source','SAT_PARTY_DIGITAL_IDENTITY'),
        ('M2','ma_sat_multi_source','SAT_PARTY_CONTACT_ADDRESS_LINK'),
        ('M2','ma_sat_multi_source','SAT_AUG_POLICY'),
        ('M3','ma_sat_multi_source','SAT_POLICY_CLASSIFICATION'),
        -- Path 5: automate_dv.ma_sat
        ('M1','automate_dv.ma_sat','SAT_PARTY_ORG_DIRECTORS'),
        ('M1','automate_dv.ma_sat','SAT_LNK_CLAIM_PARTY_ROLE'),
        ('M1','automate_dv.ma_sat','SAT_PARTY_CONTACT_ADDRESS_LINK'),
        ('M2','automate_dv.ma_sat','SAT_PARTY_PROVIDER_CAPABILITY'),
        ('M2','automate_dv.ma_sat','SAT_LNK_POLICY_PARTY_ROLE'),
        ('M3','automate_dv.ma_sat','SAT_AUG_PARTY_LEGAL_PANEL_ROLE_LINE'),
        ('M3','automate_dv.ma_sat','SAT_LNK_PARTY_ROLE_CORE'),
        -- Path 6: stitch_incremental (all OPUS)
        ('M1','stitch_incremental','SAT_COMMON_ADDRESS'),
        ('M1','stitch_incremental','SAT_POLICY_HEADER'),
        ('M1','stitch_incremental','SAT_PARTY_IDENTITY'),
        ('M1','stitch_incremental','SAT_COMMON_ADMIN_GEOGRAPHY'),
        ('M1','stitch_incremental','SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS'),
        ('M2','stitch_incremental','SAT_COMMON_GEO'),
        ('M2','stitch_incremental','SAT_PARTY_HEALTH_PROFILE'),
        ('M2','stitch_incremental','SAT_PRODUCT_DEFINITION'),
        ('M2','stitch_incremental','SAT_COMMON_COMMUNICATION_PREFERENCE'),
        ('M2','stitch_incremental','SAT_PARTY_EMPLOYMENT'),
        ('M3','stitch_incremental','SAT_COMMON_CLASSIFICATION'),
        ('M3','stitch_incremental','SAT_PROVIDER_BANKING'),
        ('M3','stitch_incremental','SAT_POLICY_BONUS_TRACKING'),
        ('M3','stitch_incremental','SAT_PARTY_CLAIM_HISTORY'),
        ('M3','stitch_incremental','SAT_PARTY_ORGANISATION_PROFILE')
)
-- NOTE: Snowflake cannot COUNT across tables named in a VALUES list in one query.
-- This SELECT GENERATES one COUNT statement per assigned sat (run_me column).
-- Copy the run_me column, paste, and execute to get the actual row counts.
select 'select '''|| satellite ||''' as satellite, '||
       'count_if(record_source ilike ''MAXIMUS%'') as maximus_rows, '||
       'count_if(record_source ilike ''OPUS%'') as opus_rows, '||
       'count(*) as total_rows from '|| $VAULT ||'.'|| satellite ||';' as run_me
from assigned
order by path, member, satellite;

/* -------------------------------------------------------------------------------------
   HOW TO USE
   1. Run the final SELECT above. It outputs one COUNT statement per assigned sat in
      the run_me column.
   2. Copy the run_me column, paste, and execute. Each row tells you maximus_rows /
      opus_rows / total_rows for that sat.
   3. total_rows = 0  -> swap the sat (same path) using DM-H_REMAINING.md.
      project column = 0 for the project you are signing off -> swap or mark NOT TESTABLE.
   ------------------------------------------------------------------------------------- */
