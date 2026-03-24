CREATE OR REPLACE PROCEDURE TRANSACTIONAL.CLAIM_POST_LOAD_UPDATES_OPTIMIZED("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE
v_sqltext VARCHAR;
--L_START NUMBER;
V_FY_START_DATE DATE;

BEGIN

SELECT TO_DATE(CASE
             WHEN TO_CHAR (DATE_TRUNC(''DAY'', TO_DATE(:T_DATE)), ''MM'') < ''04''
             THEN
                TO_DATE (
                      TO_CHAR (''01-apr-'')
                   || UTILS.CLEAN_NUMBER(TO_CHAR (DATE_TRUNC(''DAY'', TO_DATE(:T_DATE)), ''YYYY'') - 1))
             ELSE
                TO_DATE (
                   TO_CHAR (''01-apr-'') || (TO_CHAR (DATE_TRUNC(''DAY'', TO_DATE(:T_DATE)), ''YYYY'')))
          END)
      into :V_FY_START_DATE
     FROM DUAL;


---approval date update.

v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM A
           USING (SELECT DISTINCT CLM_REF, TRANS_DATE
                    FROM (  SELECT CLM_REF, MAX (TRANS_DATE) TRANS_DATE
                              FROM ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_APPROVAL
                             WHERE     PAY_STATUS <> ''''DELETED''''
                                   AND DATE_TRUNC(''''DAY'''', TRANS_DATE) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''')
                                                                     - 2)
                                                              AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')
                                                                     - 1)
                          GROUP BY CLM_REF) A,
                         TRANSACTIONAL.ODS_CLAIM_DIM B
                   WHERE     CLM_REF = C_CLAIM_NO
                         AND NVL (C_APP_DATE, ''''7-nov-1981'''') <> (TRANS_DATE))
              ON (CLM_REF = A.C_CLAIM_NO)
      WHEN MATCHED
      THEN
         UPDATE SET C_APP_DATE = TRANS_DATE,
         ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;




-- v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM
--            USING (SELECT CLM_REF,
--                          LAST_REOPENED_DATE,
--                          USER_NAME,
--                          REOPEN_REMARK
--                     FROM (  SELECT CLM_REF,
--                                    UTILS.MY_TRIM (SUBSTR (STATUS_MSG,
--                                                    REGEXP_INSTR (STATUS_MSG,
--                                                           '''':'''',
--                                                           1,
--                                                           1)
--                                                  + 1,
--                                                  LENGTH (STATUS_MSG)))
--                                       REOPEN_REMARK,
--                                    USER_NAME,
--                                    DATE_TRUNC(''''DAY'''', MAX (MSG_DATE)) LAST_REOPENED_DATE
--                               FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY A,
--                                    ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
--                              WHERE     A.CLAIM_ID = B.CLAIM_ID
--                                    AND (   UPPER (STATUS) = ''''REOPENED''''
--                                         OR LOWER (STATUS_MSG) LIKE ''''%reopen%'''')
--                                    AND (VERSION_NO, A.CLAIM_ID) IN
--                                           (  SELECT MAX (VERSION_NO), CLAIM_ID
--                                                FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY
--                                               WHERE     (   UPPER (STATUS) =
--                                                                ''''REOPENED''''
--                                                          OR LOWER (STATUS_MSG) LIKE
--                                                                ''''%reopen%'''')
--                                                     AND DATE_TRUNC(''''DAY'''', MSG_DATE) =
--                                                            DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
--                                            GROUP BY CLAIM_ID)
--                           GROUP BY CLM_REF,
--                                    UTILS.MY_TRIM (SUBSTR (STATUS_MSG,
--                                                    REGEXP_INSTR (STATUS_MSG,
--                                                           '''':'''',
--                                                           1,
--                                                           1)
--                                                  + 1,
--                                                  LENGTH (STATUS_MSG))),
--                                    USER_NAME)) C
--               ON (C_CLAIM_NO = CLM_REF)
--       WHEN MATCHED


--       THEN
--          UPDATE SET C_LAST_REOPEN_DATE = C.LAST_REOPENED_DATE,
--                     C_REOPEN_REMARK = C.REOPEN_REMARK,
--                     C_REOPEN_BY = C.USER_NAME,
--                     C_REOPEN_FLAG = 1,
--                     ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
-- EXECUTE IMMEDIATE v_sqltext;
-- COMMNETED 25/01/25 REPLACE WITH BELOW MERGE STATEMENT

v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM
           USING (SELECT DISTINCT CLM_REF,
                         LAST_REOPENED_DATE,
                         USER_NAME,
                         REOPEN_REMARK
                    FROM (  SELECT CLM_REF,
                                   TRIM (SUBSTR (STATUS_MSG,
                                                   REGEXP_INSTR (STATUS_MSG,
                                                          '''':'''',
                                                          1,
                                                          1)
                                                 + 1,
                                                 LENGTH (STATUS_MSG)))
                                      REOPEN_REMARK,
                                   USER_NAME,
                                   DATE_TRUNC(''''DAY'''', MAX (MSG_DATE)) LAST_REOPENED_DATE,
                                    -- ROW_NUMBER ()
                              -- OVER (PARTITION BY CLM_REF
                              --       ORDER BY MSG_DATE DESC)
                              --    RNK
                              FROM
                                   PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY A,
                                   BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.CLM_BASES B
                             WHERE     A.CLAIM_ID = B.CLAIM_ID
                                   AND (   UPPER (STATUS) = ''''REOPENED''''
                                        OR LOWER (STATUS_MSG) LIKE ''''%reopen%'''')
                                   AND (VERSION_NO, A.CLAIM_ID) IN
                                          (  SELECT MAX (VERSION_NO), CLAIM_ID
                                               FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY
                                              WHERE     (   UPPER (STATUS) =
                                                               ''''REOPENED''''
                                                         OR LOWER (STATUS_MSG) LIKE
                                                               ''''%reopen%'''')
                                                    AND DATE_TRUNC(''''DAY'''', MSG_DATE) >=
                                                           DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 2)
                                           GROUP BY CLAIM_ID)
                                           -- AND RNK = 1
                          GROUP BY CLM_REF,
                                   TRIM (SUBSTR (STATUS_MSG,
                                                   REGEXP_INSTR (STATUS_MSG,
                                                          '''':'''',
                                                          1,
                                                          1)
                                                 + 1,
                                                 LENGTH (STATUS_MSG))),
                                   USER_NAME) QUALIFY ROW_NUMBER() OVER (PARTITION BY CLM_REF ORDER BY LAST_REOPENED_DATE DESC) = 1 ) C
              ON (C_CLAIM_NO = CLM_REF)
      WHEN MATCHED


      THEN
         UPDATE SET C_LAST_REOPEN_DATE = C.LAST_REOPENED_DATE,
                    C_REOPEN_REMARK = C.REOPEN_REMARK,
                    C_REOPEN_BY = C.USER_NAME,
                    C_REOPEN_FLAG = 1,
                    ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;



v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM
           USING (SELECT CLM_REF, FIRST_REOPENED_DATE
                    FROM (  SELECT CLM_REF,
                                   MIN (DATE_TRUNC(''''DAY'''', MSG_DATE)) FIRST_REOPENED_DATE
                              FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY A, ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
                             WHERE     A.CLAIM_ID = B.CLAIM_ID
                                   AND (   UPPER (STATUS) = ''''REOPENED''''
                                        OR LOWER (STATUS_MSG) LIKE ''''%reopen%'''')
                                   AND A.CLAIM_ID IN
                                          (SELECT CLAIM_ID
                                             FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY
                                            WHERE     (   UPPER (STATUS) =
                                                             ''''REOPENED''''
                                                       OR LOWER (STATUS_MSG) LIKE
                                                             ''''%reopen%'''')
                                                  AND DATE_TRUNC(''''DAY'''', MSG_DATE) >=
                                                         DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1))
                          GROUP BY CLM_REF)) C
              ----ORDER BY 2) a,
              ON (C_CLAIM_NO = CLM_REF)
      WHEN MATCHED
      THEN
         UPDATE SET C_FIRST_REOPEN_DATE = C.FIRST_REOPENED_DATE,
         ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;





v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_INV_SUPP_REP_STG'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_INV_SUPP_REP_STG
         SELECT DISTINCT A.CLAIM_ID, CLM_REF
           FROM ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.CLM_TRANS A, ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
          WHERE A.CLAIM_ID = B.CLAIM_ID AND TRANS_DATE >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
         UNION
         SELECT DISTINCT A.CLAIM_ID, CLM_REF
           FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY A, ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
          WHERE     A.CLAIM_ID = B.CLAIM_ID
                AND DATE_TRUNC(''''DAY'''', MSG_DATE) >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 2)'';
EXECUTE IMMEDIATE v_sqltext;




v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.STG_CLM_SUPPLIERS'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.STG_CLM_SUPPLIERS
            SELECT
            SUPP_ID,
        	SUPP_TYPE,
        	PART_ID,
        	EFF_DATE,
        	EXP_DATE,
        	SUPP_STATUS,
        	CONTACT,
        	COMMENTS,
        	LOC_CODE,
            SUPP_STATUS_DESC ,
        	null as DMS_TIMESTAMP ,
        	null as DMS_COMMIT_TIMESTAMP,
        	null as DMS_H_CHANGE_SEQ,
        	null as DMS_H_STREAM_POSITION,
        	null as DMS_H_USER,
        	null as INC_JOB_CREATED_AT,
        	null as INC_JOB_CREATED_BY,
        	null as INC_JOB_UPDATED_BY,
        	null as INC_JOB_UPDATED_AT,
        	null as INC_JOB_ID,
        	null as OP
           FROM PROD_DWH_MIGRATED_DB.PROD.CLM_SUPPLIERS A
          WHERE                             --SUPP_STATUS not in (''''2'''',''''3'''',''''5'''')
                (PART_ID, SUPP_ID, SUPP_TYPE) IN
                   (  SELECT PART_ID, MAX (SUPP_ID) SUPP_ID, SUPP_TYPE
                        FROM PROD_DWH_MIGRATED_DB.PROD.CLM_SUPPLIERS K
                       WHERE     K.PART_ID = A.PART_ID
                             AND SUPP_STATUS NOT IN (''''3'''', ''''5'''')
                              AND SUPP_STATUS_DESC=''''ACTIVE'''' -- ADDED BY REMESH ON 10-NOV-2025 DUE TO SLA REPORT GOING INCORRECTLY TO NITIN GUPTE(commented by ashish due to airflow dag fail)
                    GROUP BY PART_ID, SUPP_TYPE)'';
EXECUTE IMMEDIATE v_sqltext;



v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_REP_SUR_ADV_STG'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_REP_SUR_ADV_STG
           SELECT
                 CLM_REF CLM_REF,
                  1 SUPP_ID,
                  DD.CLAIM_ID, --dd.claim_id,ip_no, clm_interested_parties_mv.part_id
                  -- bb.supp_id supp_id,dd.claim_id,
                  MAX (
                     CASE
                        WHEN CLM_INTERESTED_PARTIES_MV.IP_TYPE IN
                                (''''BAPW'''', ''''TIEUPREP'''', ''''REP'''')
                        THEN
                              (DECODE (CP_PARTNERS_MV.PARTNER_TYPE,
                                  ''''I'''', CP_PARTNERS_MV.INSTITUTION_NAME,
                                     IFF(CP_PARTNERS_MV.FIRST_NAME IS NULL, '''''''', CP_PARTNERS_MV.FIRST_NAME)
                                  || IFF(CP_PARTNERS_MV.MIDDLE_NAME IS NULL, '''''''', '''' '''' || CP_PARTNERS_MV.MIDDLE_NAME)
								  || IFF(CP_PARTNERS_MV.SURNAME IS NULL, '''''''', '''' '''' || CP_PARTNERS_MV.SURNAME)))
                           || ''''|''''
                           || SUPP_ID
                           || ''''|''''
                           || SUPP_TYPE
                     END)
                     AS REP_NAME,
                  MAX (
                     CASE
                        WHEN CLM_INTERESTED_PARTIES_MV.IP_TYPE IN
                                (''''INH_SUR'''', ''''SUR'''')
                        THEN
                              (DECODE (CP_PARTNERS_MV.PARTNER_TYPE,
                                  ''''I'''', CP_PARTNERS_MV.INSTITUTION_NAME,
                                     IFF(CP_PARTNERS_MV.FIRST_NAME IS NULL, '''''''', CP_PARTNERS_MV.FIRST_NAME)
                                  || IFF(CP_PARTNERS_MV.MIDDLE_NAME IS NULL, '''''''', '''' '''' || CP_PARTNERS_MV.MIDDLE_NAME)
								  || IFF(CP_PARTNERS_MV.SURNAME IS NULL, '''''''', '''' '''' || CP_PARTNERS_MV.SURNAME)))
                           || ''''|''''
                           || SUPP_ID
                           || ''''|''''
                           || SUPP_TYPE
                     END)
                     SUR_NAME,
                  MAX (
                     CASE
                     WHEN CLM_INTERESTED_PARTIES_MV.IP_TYPE IN (''''LAW'''')
                        THEN
                              (DECODE (CP_PARTNERS_MV.PARTNER_TYPE,
                                  ''''I'''', CP_PARTNERS_MV.INSTITUTION_NAME,
                                     IFF(CP_PARTNERS_MV.FIRST_NAME IS NULL, '''''''', CP_PARTNERS_MV.FIRST_NAME)
                                  || IFF(CP_PARTNERS_MV.MIDDLE_NAME IS NULL, '''''''', '''' '''' || CP_PARTNERS_MV.MIDDLE_NAME)
								  || IFF(CP_PARTNERS_MV.SURNAME IS NULL, '''''''', '''' '''' || CP_PARTNERS_MV.SURNAME)))
                           || ''''|''''
                           || SUPP_ID
                           || ''''|''''
                           || SUPP_TYPE
                     END)
                     ADV_NAME
             FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_INTERESTED_PARTIES CLM_INTERESTED_PARTIES_MV,
                  ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.CP_PARTNERS CP_PARTNERS_MV,
                  INTERMEDIATE.STG_CLM_SUPPLIERS BB,
                  INTERMEDIATE.WRK_INV_SUPP_REP_STG DD
            WHERE     CP_PARTNERS_MV.PART_ID = BB.PART_ID(+)
                  AND DD.CLAIM_ID = CLM_INTERESTED_PARTIES_MV.CLAIM_ID
                  AND CLM_INTERESTED_PARTIES_MV.PART_ID =
                         CP_PARTNERS_MV.PART_ID
                  AND IP_TYPE = SUPP_TYPE
                  AND BB.SUPP_STATUS(+) NOT IN (''''3'''', ''''5'''')
                  AND (IP_NO,
                       DD.CLAIM_ID,
                       CASE
                          WHEN IP_TYPE IN (''''BAPW'''', ''''TIEUPREP'''', ''''REP'''')
                          THEN
                             ''''REP''''
                          WHEN IP_TYPE IN (''''INH_SUR'''', ''''SUR'''')
                          THEN
                             ''''SUR''''
                          WHEN IP_TYPE IN (''''LAW'''')
                          THEN
                             ''''LAW''''
                       END) IN
                         (  SELECT MAX (IP_NO),
                                   K.CLAIM_ID,
                                   CASE
                                      WHEN IP_TYPE IN (''''BAPW'''', ''''TIEUPREP'''', ''''REP'''')
                                      THEN
                                         ''''REP''''
                                      WHEN IP_TYPE IN (''''INH_SUR'''', ''''SUR'''')
                                      THEN
                                         ''''SUR''''
                                      WHEN IP_TYPE IN (''''LAW'''')
                                      THEN
                                         ''''LAW''''
                                   END
                              FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_INTERESTED_PARTIES K,
                                   INTERMEDIATE.STG_CLM_SUPPLIERS KK
                             WHERE     K.PART_ID = KK.PART_ID(+)
                                   AND SUPP_STATUS NOT IN (''''3'''', ''''5'''')
                                   AND K.IP_TYPE IN
                                          (''''BAPW'''',
                                           ''''TIEUPREP'''',
                                           ''''REP'''',
                                           ''''INH_SUR'''',
                                           ''''SUR'''',
                                           ''''LAW'''')
                                   AND DD.CLAIM_ID = K.CLAIM_ID
                                   AND CLAIMANT = ''''Y''''
                          GROUP BY K.CLAIM_ID,
                                   CASE
                                      WHEN IP_TYPE IN
                                              (''''BAPW'''', ''''TIEUPREP'''', ''''REP'''')
                                      THEN
                                         ''''REP''''
                                      WHEN IP_TYPE IN (''''INH_SUR'''', ''''SUR'''')
                                      THEN
                                         ''''SUR''''
                                      WHEN IP_TYPE IN (''''LAW'''')
                                      THEN
                                         ''''LAW''''
                                   END)
         GROUP BY CLM_REF, DD.CLAIM_ID'';
EXECUTE IMMEDIATE v_sqltext;



v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM AS target
            SET C_ADV_NAME = src.ADV_NAME,
                C_REP_NAME = src.REP_NAME,
                C_SUR_NAME = src.SUR_NAME,
                ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (
SELECT * FROM INTERMEDIATE.WRK_REP_SUR_ADV_STG
) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;


--CLM_BASES_HISTORY_MV not present in prod that''''s why taken from consumption_dev for testing

-- EXECUTE IMMEDIATE ''''TRUNCATE TABLE IF EXISTS WRK_CLM_BASES_HIST'''';
-- INSERT INTO WRK_CLM_BASES_HIST
--            SELECT CLM_REF CLM_REF_HIST
--              FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES_HISTORY
--             WHERE DATE_TRUNC(''''DAY'''', TO_DATE (SYSTEM_DATE, ''''dd/mm/yyyy hh24:mi:ss'''')) >=
--                      DATE_TRUNC(''''DAY'''', CURRENT_DATE) - 5
--          GROUP BY CLM_REF;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_CLM_BASES_HIST'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_CLM_BASES_HIST
SELECT CLM_REF AS CLM_REF_HIST
FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES_HISTORY
WHERE DATE_TRUNC(''''DAY'''',
                  CASE
                      WHEN SYSTEM_DATE LIKE ''''%-%-%'''' THEN TO_TIMESTAMP(SYSTEM_DATE, ''''dd-mm-yyyy hh24:mi:ss'''')
                      WHEN SYSTEM_DATE LIKE ''''%/%/%'''' THEN TO_TIMESTAMP(SYSTEM_DATE, ''''dd/mm/yyyy hh24:mi:ss'''')
                      ELSE NULL
                  END
                ) >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 5
GROUP BY CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;



-------claim status update.



v_sqltext := ''MERGE
           INTO  TRANSACTIONAL.ODS_CLAIM_DIM
           USING (SELECT DISTINCT
                         ODS_CLAIM_DIM.C_CLAIM_NO,
                         CLM_BASES_MV.CLM_STATUS,
                         CASE
                            WHEN CLM_BASES_MV.CLM_STATUS = ''''CLOSED''''
                            THEN
                               DATE_TRUNC(''''DAY'''', TO_DATE (CLM_BASES_MV.LUA_VALUE_1,
                                           ''''DD-MM-YYYY HH24:MI:SS''''))
                         END
                            LUA_VALUE_1
                    FROM INTERMEDIATE.WRK_CLM_BASES_HIST T,
                         ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES CLM_BASES_MV,
                        TRANSACTIONAL.ODS_CLAIM_DIM
                   WHERE     T.CLM_REF_HIST = CLM_BASES_MV.CLM_REF
                         AND (CLM_BASES_MV.CLM_REF = ODS_CLAIM_DIM.C_CLAIM_NO)
                         --                         AND DATE_TRUNC(''''DAY'''', MODIF_DATE) >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 3
                         AND (NVL (CLM_BASES_MV.CLM_STATUS, ''''X'''') <>
                                 NVL (ODS_CLAIM_DIM.C_CLAIM_STATUS, ''''X''''))
                         AND NVL (
                                DATE_TRUNC(''''DAY'''', TO_DATE (CLM_BASES_MV.LUA_VALUE_1,
                                            ''''DD-MM-YYYY HH24:MI:SS'''')),
                                C_REGN_DATE) < DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))) X
              ON (ODS_CLAIM_DIM.C_CLAIM_NO = X.C_CLAIM_NO)
      WHEN MATCHED
      THEN
         UPDATE SET C_CLAIM_STATUS = X.CLM_STATUS, C_CLO_DATE = X.LUA_VALUE_1, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;




v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM
         SET C_CLAIM_STATUS = ''''OPEN'''',
         ETL_REFRESH_AT = CURRENT_TIMESTAMP()
       WHERE C_CLAIM_NO IN
                (SELECT CLM_REF
                   FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES A, TRANSACTIONAL.ODS_CLAIM_DIM B
                  WHERE     A.CLM_REF = B.C_CLAIM_NO
                        AND DATE_TRUNC(''''DAY'''', TO_DATE (LUA_VALUE_1, ''''DD-MM-YYYY HH24:MI:SS'''')) =
                               DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))
                        AND DATE_TRUNC(''''DAY'''', DATE_REPORTED) = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1
                        AND C_CLAIM_STATUS = ''''CLOSED''''
                        AND C_CLO_DATE IS NULL)'';
EXECUTE IMMEDIATE v_sqltext;



-- v_sqltext := ''DELETE FROM CLM_BASES_MV_UPDT_HIS
--             WHERE DATE_TRUNC(''''DAY'''', MODIF_DATE) < DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 4'';
-- EXECUTE IMMEDIATE v_sqltext;


-- DBMS_STATS.GATHER_TABLE_STATS (''''prod'''',
--                                      ''''clm_bases_mv_updt_his'''',
--                                      ESTIMATE_PERCENT   => 30,
--                                      DEGREE             => 6,
--                                      CASCADE            => TRUE);



/*------investigator name update.*/

v_sqltext := ''MERGE
        INTO  TRANSACTIONAL.ODS_CLAIM_DIM
        USING (SELECT ODS_CLAIM_DIM.C_CLAIM_ID_SK C_CLAIM_ID_SK$28,
                      ODS_CLAIM_DIM.C_CLAIM_NO C_CLAIM_NO$26,
                      BJAZ_MOT_CLM_IP_DMG_EXTN_MV.INJURED_NAME
                         INJURED_NAME
                 FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_MOT_CLM_IP_DMG_EXTN BJAZ_MOT_CLM_IP_DMG_EXTN_MV,
                     TRANSACTIONAL.ODS_CLAIM_DIM,
                      ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES CLM_BASES_MV
                WHERE     (BJAZ_MOT_CLM_IP_DMG_EXTN_MV.CLAIM_ID =
                              CLM_BASES_MV.CLAIM_ID)
                      AND (ODS_CLAIM_DIM.C_CLAIM_NO =
                              CLM_BASES_MV.CLM_REF)
                      AND DATE_REPORTED BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 10)
                                            AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
                      AND (UPPER (
                              BJAZ_MOT_CLM_IP_DMG_EXTN_MV.DAMAGED_OBJECT) =
                              ''''VEHICLE'''')
                      AND (BJAZ_MOT_CLM_IP_DMG_EXTN_MV.INJURED_NAME
                              IS NOT NULL)) MERGE_SUBQUERY$8
           ON (ODS_CLAIM_DIM.C_CLAIM_ID_SK =
                  MERGE_SUBQUERY$8.C_CLAIM_ID_SK$28)
   WHEN MATCHED
   THEN
      UPDATE SET C_NAME_OF_IN1 = MERGE_SUBQUERY$8.INJURED_NAME, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;



------investigator update

v_sqltext := ''MERGE
        INTO  TRANSACTIONAL.ODS_CLAIM_DIM
        USING (SELECT ODS_CLAIM_DIM.C_CLAIM_ID_SK C_CLAIM_ID_SK$29,
                      ODS_CLAIM_DIM.C_CLAIM_NO C_CLAIM_NO$27,
                      BJAZ_VEHICLE_DTLS_MV.REGISTRATION_NO
                         REGISTRATION_NO
                 FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_MOT_CLM_IP_DMG_EXTN BJAZ_MOT_CLM_IP_DMG_EXTN_MV,
                      ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_VEHICLE_DTLS BJAZ_VEHICLE_DTLS_MV,
                      ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES CLM_BASES_MV,
                     TRANSACTIONAL.ODS_CLAIM_DIM
                WHERE     DATE_REPORTED BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 3)
                                            AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
                      AND (BJAZ_MOT_CLM_IP_DMG_EXTN_MV.VEHICLE_ID =
                              BJAZ_VEHICLE_DTLS_MV.VEHICLE_ID)
                      AND (BJAZ_MOT_CLM_IP_DMG_EXTN_MV.VEHICLE_VERSION =
                              BJAZ_VEHICLE_DTLS_MV.VEHICLE_VERSION)
                      AND (BJAZ_MOT_CLM_IP_DMG_EXTN_MV.CLAIM_ID =
                              CLM_BASES_MV.CLAIM_ID)
                      AND (BJAZ_MOT_CLM_IP_DMG_EXTN_MV.IP_NO = 1)
                      AND (UPPER (
                              BJAZ_MOT_CLM_IP_DMG_EXTN_MV.DAMAGED_OBJECT) =
                              ''''VEHICLE'''')
                      AND (BJAZ_VEHICLE_DTLS_MV.REGISTRATION_NO
                              IS NOT NULL)
                      AND (CLM_BASES_MV.CLM_REF =
                              ODS_CLAIM_DIM.C_CLAIM_NO)
                      AND (NVL (ODS_CLAIM_DIM.C_NAME_OF_IN5, ''''X'''') <>
                              NVL (BJAZ_VEHICLE_DTLS_MV.REGISTRATION_NO,
                                   ''''X'''')
                                       )) MERGE_SUBQUERY$9
           ON (ODS_CLAIM_DIM.C_CLAIM_ID_SK =
                  MERGE_SUBQUERY$9.C_CLAIM_ID_SK$29)
   WHEN MATCHED
   THEN
      UPDATE SET      ---   c_claim_no = merge_subquery$9.c_claim_no$27,
                C_NAME_OF_IN5 = MERGE_SUBQUERY$9.REGISTRATION_NO, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;


--------claim type update

v_sqltext := ''MERGE
        INTO  TRANSACTIONAL.ODS_CLAIM_DIM
        USING (SELECT ODS_CLAIM_DIM.C_CLAIM_ID_SK C_CLAIM_ID_SK$30,
                      ODS_CLAIM_DIM.C_CLAIM_NO C_CLAIM_NO$28,
                      C.CLM_TYPE CLM_TYPE$2
                 FROM (SELECT SET_OPERATION$2.CLAIM_ID$35 CLAIM_ID,
                              SET_OPERATION$2.CLM_TYPE$3 CLM_TYPE
                         FROM (SELECT CLAIM_ID CLAIM_ID$35,
                                      CLM_TYPE CLM_TYPE$3
                                 FROM (SELECT BJAZ_CLM_BASE_MOT_EXT_MV.CLAIM_ID
                                                 CLAIM_ID,
                                              BJAZ_CLM_BASE_MOT_EXT_MV.CLM_TYPE
                                                 CLM_TYPE
                                         FROM ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_BASE_MOT_EXT BJAZ_CLM_BASE_MOT_EXT_MV
                                       UNION
                                       SELECT BJAZ_WB_CLM_BASE_MOT_EXT_MV.CLAIM_ID
                                                 CLAIM_ID,
                                              BJAZ_WB_CLM_BASE_MOT_EXT_MV.CLM_TYPE
                                                 CLM_TYPE
                                         FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_BASE_MOT_EXT BJAZ_WB_CLM_BASE_MOT_EXT_MV)) SET_OPERATION$2) C,
                     TRANSACTIONAL.ODS_CLAIM_DIM ,
                      ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES CLM_BASES_MV
                WHERE     C_REGN_DATE BETWEEN DATE_TRUNC(DAY, TO_DATE('''''' || F_DATE || '''''') - 2)
                                          AND DATE_TRUNC(DAY, TO_DATE('''''' || T_DATE || '''''') - 1)
                      AND (ODS_CLAIM_DIM.C_CLAIM_NO =
                              CLM_BASES_MV.CLM_REF)
                      AND (CLM_BASES_MV.CLAIM_ID = C.CLAIM_ID)
                      AND (C.CLM_TYPE IS NOT NULL)
                      AND (NVL (C.CLM_TYPE, ''''-'''') <>
                              NVL (ODS_CLAIM_DIM.C_CLAIM_TYPE, ''''-'''')
                                                                       )
                                                                     QUALIFY ROW_NUMBER() OVER (PARTITION BY CLM_REF ORDER BY LAST_UPDATED_DATE DESC) = 1
                                                                      ) MERGE_SUBQUERY$10
           ON (ODS_CLAIM_DIM.C_CLAIM_ID_SK =
                  MERGE_SUBQUERY$10.C_CLAIM_ID_SK$30)
   WHEN MATCHED
   THEN
      UPDATE SET       --- c_claim_no = merge_subquery$10.c_claim_no$28,
                C_CLAIM_TYPE = MERGE_SUBQUERY$10.CLM_TYPE$2, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;



v_sqltext := ''MERGE
        INTO  TRANSACTIONAL.ODS_CLAIM_DIM
        USING (SELECT ODS_CLAIM_DIM.C_CLAIM_ID_SK
                                                     C_CLAIM_ID_SK$34,
                      ODS_CLAIM_DIM.C_CLAIM_NO
                                                  C_CLAIM_NO$32,
                      SUBSTR (ODS_CLAIM_DIM.C_CLAIM_NO, 7, 4)
                         C_OFF_LOC_ID
                 FROM TRANSACTIONAL.ODS_CLAIM_DIM
                WHERE     (ODS_CLAIM_DIM.C_OFF_LOC_ID IS NULL)
                      AND C_REGN_DATE BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 10)
                                          AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)) MERGE_SUBQUERY$12
           ON (ODS_CLAIM_DIM.C_CLAIM_ID_SK =
                  MERGE_SUBQUERY$12.C_CLAIM_ID_SK$34)
   WHEN MATCHED
   THEN
      UPDATE SET       --- c_claim_no = merge_subquery$12.c_claim_no$32,
                C_OFF_LOC_ID = MERGE_SUBQUERY$12.C_OFF_LOC_ID, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;



------registered username update
--changed by chandrakant(19-mar-2021)----

v_sqltext := ''MERGE
        INTO  TRANSACTIONAL.ODS_CLAIM_DIM
        USING (SELECT DISTINCT ODS_CLAIM_DIM.C_CLAIM_ID_SK C_CLAIM_ID_SK$35,
                      ODS_CLAIM_DIM.C_CLAIM_NO C_CLAIM_NO$33,
                      BJAZ_WB_CLM_BASE_MOT_EXT_MV.ASSIGNEE ASSIGNEE,
                      NOTIFICATION_DATE
                 FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES CLM_BASES_MV,
                     TRANSACTIONAL.ODS_CLAIM_DIM,
                      ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_BASE_MOT_EXT BJAZ_WB_CLM_BASE_MOT_EXT_MV
                WHERE     DATE_REPORTED BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 30)
                                              AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1) -->= v_fy_start_date
                      AND (CLM_BASES_MV.CLAIM_ID =
                              BJAZ_WB_CLM_BASE_MOT_EXT_MV.CLAIM_ID)
                      AND (CLM_BASES_MV.CLM_REF =
                              ODS_CLAIM_DIM.C_CLAIM_NO)
                      AND NOTIFICATION_DATE IS NOT NULL) MERGE_SUBQUERY$13
           ON (ODS_CLAIM_DIM.C_CLAIM_ID_SK =
                  MERGE_SUBQUERY$13.C_CLAIM_ID_SK$35)
   WHEN MATCHED
   THEN
      UPDATE SET C_INTI_DATE = NOTIFICATION_DATE, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;
-- was commented out earlier because of duplicate row issue


--------generic clms registred username update

v_sqltext := ''MERGE
        INTO  TRANSACTIONAL.ODS_CLAIM_DIM
        USING (SELECT DISTINCT ODS_CLAIM_DIM.C_CLAIM_ID_SK
                                                     C_CLAIM_ID_SK$37,
                      GEN_CLM_USERID_MV.CLM_REF
                                                   C_CLAIM_NO$35,
                      GEN_CLM_USERID_MV.USER_NAME
                                                     C_CLAIM_REGD_BY
                 FROM PROD_DWH_MIGRATED_DB.STAGE.GEN_CLM_USERID_MV GEN_CLM_USERID_MV,
                     TRANSACTIONAL.ODS_CLAIM_DIM
                WHERE     (GEN_CLM_USERID_MV.CLM_REF =
                              ODS_CLAIM_DIM.C_CLAIM_NO)
                      AND C_REGN_DATE BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 2)
                                          AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)) MERGE_SUBQUERY$15
           ON (ODS_CLAIM_DIM.C_CLAIM_ID_SK =
                  MERGE_SUBQUERY$15.C_CLAIM_ID_SK$37)
   WHEN MATCHED
   THEN
      UPDATE SET         --c_claim_no = merge_subquery$15.c_claim_no$35,
                C_CLAIM_REGD_BY = MERGE_SUBQUERY$15.C_CLAIM_REGD_BY, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;



---------claim username update

v_sqltext := ''MERGE
        INTO  TRANSACTIONAL.ODS_CLAIM_DIM
        USING (SELECT DISTINCT ODS_CLAIM_DIM.C_CLAIM_ID_SK C_CLAIM_ID_SK$36,
                      ODS_CLAIM_DIM.C_CLAIM_NO C_CLAIM_NO$34,
                      BJAZ_CLM_BASE_MOT_EXT_MV.ASSIGNEE ASSIGNEE$1,
                      NOTIFICATION_DATE
                 FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES CLM_BASES_MV,
                    TRANSACTIONAL.ODS_CLAIM_DIM,
                      ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_BASE_MOT_EXT BJAZ_CLM_BASE_MOT_EXT_MV
                WHERE     (DATE_REPORTED) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 2)
                                              AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1) -->= v_fy_start_date
                      AND (CLM_BASES_MV.CLAIM_ID =
                              BJAZ_CLM_BASE_MOT_EXT_MV.CLAIM_ID)
                      AND (CLM_BASES_MV.CLM_REF =
                              ODS_CLAIM_DIM.C_CLAIM_NO)
                      AND (NVL (BJAZ_CLM_BASE_MOT_EXT_MV.ASSIGNEE, ''''X'''') <>
                              NVL (ODS_CLAIM_DIM.C_CLAIM_REGD_BY, ''''X'''')
                                                                          )) MERGE_SUBQUERY$14
           ON (ODS_CLAIM_DIM.C_CLAIM_ID_SK =
                  MERGE_SUBQUERY$14.C_CLAIM_ID_SK$36)
   WHEN MATCHED
   THEN
      UPDATE SET       --- c_claim_no = merge_subquery$14.c_claim_no$34,
                 -- C_CLAIM_REGD_BY = MERGE_SUBQUERY$14.ASSIGNEE$1,
                 C_INTI_DATE = NOTIFICATION_DATE, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM
           USING (SELECT distinct CLM_REF, DATE_TRUNC(''''DAY'''', INTIMATION_DATE) INIT_DATE
                    FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_GENERIC_INTIM A, ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
                   WHERE     A.CLAIM_ID = B.CLAIM_ID
                         AND DATE_REPORTED BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''')) - 15
                                               AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1) A
              ON (C_CLAIM_NO = CLM_REF)
      WHEN MATCHED
      THEN
         UPDATE SET C_INTI_DATE = A.INIT_DATE, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;





--------cheque issue date update

v_sqltext := ''MERGE
        INTO  TRANSACTIONAL.ODS_CLAIM_DIM
        USING (SELECT DISTINCT AGGREGATOR_5$2.C_CLAIM_ID_SK$39 C_CLAIM_ID_SK$38,
                      AGGREGATOR_5$2.C_CLAIM_NO$37 C_CLAIM_NO$36,
                      AGGREGATOR_5$2.TRANS_DATE$13 TRANS_DATE$12
                 FROM (  SELECT ODS_CLAIM_DIM.C_CLAIM_NO
                                                            C_CLAIM_NO$37,
                                ODS_CLAIM_DIM.C_CLAIM_ID_SK
                                   C_CLAIM_ID_SK$39,
                                MAX (
                                   BJAZ_GEN_CLM_ACC_PAY_DETL_MV.TRANS_DATE)
                                   TRANS_DATE$13
                           FROM TRANSACTIONAL.ODS_CLAIM_DIM,
                                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES CLM_BASES_MV,
                                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_ACC_PAY_DETL BJAZ_GEN_CLM_ACC_PAY_DETL_MV,
                                ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_APPROVAL BJAZ_GEN_CLM_APPROVAL_MV
                          WHERE     BJAZ_GEN_CLM_APPROVAL_MV.TRANS_DATE BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''')
                                                                                   - 2)
                                                                            AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')
                                                                                   - 1)
                                AND (ODS_CLAIM_DIM.C_CLAIM_NO =
                                        CLM_BASES_MV.CLM_REF)
                                AND (CLM_BASES_MV.CLAIM_ID =
                                        BJAZ_GEN_CLM_APPROVAL_MV.CLAIM_ID)
                                AND (BJAZ_GEN_CLM_APPROVAL_MV.PAY_APP_NO =
                                        BJAZ_GEN_CLM_ACC_PAY_DETL_MV.ACC_PAY_REF)
                       GROUP BY ODS_CLAIM_DIM.C_CLAIM_ID_SK,
                                ODS_CLAIM_DIM.C_CLAIM_NO
                                                            ) AGGREGATOR_5$2) MERGE_SUBQUERY$16
           ON (ODS_CLAIM_DIM.C_CLAIM_ID_SK =
                  MERGE_SUBQUERY$16.C_CLAIM_ID_SK$38)
   WHEN MATCHED
   THEN
      UPDATE SET         --c_claim_no = merge_subquery$16.c_claim_no$36,
                C_CHQ_ISS_DATE = MERGE_SUBQUERY$16.TRANS_DATE$12, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;




-----------------------commented by chandrakant(13/5/2019)------------------------------------------------

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM
            SET --C_COMMENTS = UTILS.MY_TRIM (UPPER (src.TXT)), commented by chandrakant
               C_INVOICE_NO = src.REF_TEXT, C_INVOICE_DATE = src.INVOI_DATE, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (
WITH c1 AS (SELECT
        CLM_BASES.CLM_REF,
        SUBSTR(CLM_TRANS.REF_TEXT, 1, 499) AS REF_TEXT,
        DATE_TRUNC(''''DAY'''', CLM_TRANS.TRANS_DATE) AS TR,
        MAX(DATE_TRUNC(''''DAY'''', CLM_TRANS.TRANS_DATE)) OVER (PARTITION BY CLM_BASES.CLM_REF) AS MX,
        BJAZ_LOV_MAST.LOV_TEXT AS TXT
    FROM ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.CLM_TRANS CLM_TRANS
    JOIN ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES
        ON CLM_TRANS.CLAIM_ID = CLM_BASES.CLAIM_ID
    LEFT JOIN ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_LOV_MAST
        ON BJAZ_LOV_MAST.LOV_TYPE = ''''CCR''''
        AND TO_CHAR(BJAZ_LOV_MAST.LOV_CODE) = CLM_TRANS.EXT_USER
    WHERE CLM_TRANS.REF_TEXT IS NOT NULL
      AND DATE_TRUNC(''''DAY'''', CLM_TRANS.TRANS_DATE) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 5)
                                                      AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
),c2 AS (SELECT CLM_REF,
                              MAX (
                                 CASE
                                    WHEN (   LOWER (REF_TEXT) LIKE ''''%job%''''
                                          OR LOWER (REF_TEXT) LIKE ''''%invo%'''')
                                    THEN
                                       REF_TEXT
                                    ELSE
                                       NULL
                                 END)
                                 REF_TEXT,                               --tr,
                              MAX (TXT) TXT,
                              MAX (
                                 CASE
                                    WHEN (   LOWER (REF_TEXT) LIKE ''''%job%''''
                                          OR LOWER (REF_TEXT) LIKE ''''%invo%'''')
                                    THEN
                                       MX
                                 END)
                                 INVOI_DATE
    FROM c1
	WHERE MX = TR
    GROUP BY CLM_REF
)
SELECT *
FROM c2
WHERE REF_TEXT IS NOT NULL
   OR TXT IS NOT NULL
   OR INVOI_DATE IS NOT NULL
) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM
as target
            SET C_COURT_FLAG = src.FLAG, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM
(SELECT CLM_REF,
                     CLAIM_ID,
                     NVL (UTILS.GET_LITIGATION_FLAG (CLAIM_ID), ''''Normal Claim'''') FLAG
                FROM (SELECT CLM_REF, CLAIM_ID
                        FROM TRANSACTIONAL.ODS_CLAIM_DIM A, ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
                       WHERE     DATE_TRUNC(''''DAY'''', C_REGN_DATE) = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
                             AND A.C_CLAIM_NO = B.CLM_REF
                      UNION
                      SELECT CLM_REF, A.CLAIM_ID
                        FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_GENERIC_EXTN A, ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
                       WHERE     TO_CHAR (DATE_TRUNC(''''DAY'''', UPDATED_ON), ''''mon.yyyy'''') =
                                    TO_CHAR (DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1), ''''mon.yyyy'''')
                             AND A.CLAIM_ID = B.CLAIM_ID
                             AND NOT EXISTS
                                        (SELECT 1
                                           FROM ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_BASE_MOT_EXT C
                                          WHERE     A.CLAIM_ID = C.CLAIM_ID
                                                AND CASE
                                                       WHEN LONG_TAIL_DISPUTED =
                                                               ''''Y''''
                                                       THEN
                                                          ''''Long_Tail_Desputed_Case''''
                                                       WHEN INDEMNITY_REC_BOND =
                                                               ''''Y''''
                                                       THEN
                                                          ''''Indemnity_Rec_Bond_case''''
                                                    END
                                                       IS NOT NULL))) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;


------update court flag as per arun patil mail-28-sep-2021

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_COURT_FLAG = src.NEW_COURT_FLAG, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT C_CLAIM_NO,
                    CASE
                       WHEN LONG_TAIL_DISPUTED = ''''Y''''
                       THEN
                          ''''Long_Tail_Desputed_Case''''
                       WHEN INDEMNITY_REC_BOND = ''''Y''''
                       THEN
                          ''''Indemnity_Rec_Bond_case''''
                    END
                       NEW_COURT_FLAG
               FROM TRANSACTIONAL.ODS_CLAIM_DIM A, ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_BASE_MOT_EXT B
              WHERE     A.C_CLAIM_ID = B.CLAIM_ID
                    AND DATE_TRUNC(''''DAY'''', UPDATED_ON) >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 4
                    AND CASE
                           WHEN LONG_TAIL_DISPUTED = ''''Y''''
                           THEN
                              ''''Long_Tail_Desputed_Case''''
                           WHEN INDEMNITY_REC_BOND = ''''Y''''
                           THEN
                              ''''Indemnity_Rec_Bond_case''''
                        END <> C_COURT_FLAG
                    AND CASE
                           WHEN LONG_TAIL_DISPUTED = ''''Y''''
                           THEN
                              ''''Long_Tail_Desputed_Case''''
                           WHEN INDEMNITY_REC_BOND = ''''Y''''
                           THEN
                              ''''Indemnity_Rec_Bond_case''''
                        END
                           IS NOT NULL) AS src
WHERE target.C_CLAIM_NO = src.C_CLAIM_NO'';
EXECUTE IMMEDIATE v_sqltext;



-- UPDATE INTERMEDIATE.ODS_CLAIM_DIM K
--          SET C_COURT_FLAG =
--                 (SELECT NVL (UTILS.GET_LITIGATION_FLAG (CLAIM_ID), ''''Normal Claim'''')
--                            FLAG
--                    FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES
--                   WHERE CLM_REF = K.C_CLAIM_NO)
--        WHERE C_COURT_FLAG IS NULL AND C_REGN_DATE >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1;


v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM
as target
            SET C_COURT_FLAG = src.FLAG, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM
(SELECT NVL (UTILS.GET_LITIGATION_FLAG (CLAIM_ID), ''''Normal Claim'''')
                           FLAG
                   FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES A left join
				   TRANSACTIONAL.ODS_CLAIM_DIM B on A.CLM_REF = B.C_CLAIM_NO
                 ) AS src
WHERE C_COURT_FLAG IS NULL AND C_REGN_DATE >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.BJAZ_CLAIM_REMARKS'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT
            INTO  INTERMEDIATE.BJAZ_CLAIM_REMARKS
         SELECT
               DISTINCT A.CLAIM_ID,
                        VERSION_NO,
                        STATUS_MSG,
                        MSG_TYPE,
                        DATE_TRUNC(''''DAY'''', MSG_DATE) MSG_DATE,
                        USER_NAME,
                        STATUS,
                        DATE_OF_SURVEY,
                        SUBSTR (STATUS_MSG,
                                REGEXP_INSTR (STATUS_MSG,
                                       ''''Special Comments'''',
                                       1,
                                       1),
                                LENGTH (STATUS_MSG))
                           COMMENTS,
                        B.CLM_REF
           FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY A, ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
          WHERE     UPPER (STATUS) LIKE ''''%CLOSED%''''
                AND A.CLAIM_ID = B.CLAIM_ID
                AND VERSION_NO =
                       (SELECT
                              MAX (VERSION_NO)
                          FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY B
                         WHERE     A.CLAIM_ID = B.CLAIM_ID
                               AND UPPER (B.STATUS) LIKE ''''%CLOSED%'''')
                AND DATE_TRUNC(''''DAY'''', MSG_DATE) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 3)
                                         AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM
           USING (  SELECT DISTINCT CLM_REF, MAX (COMMENTS) COMMENTS
                      FROM INTERMEDIATE.BJAZ_CLAIM_REMARKS
                     WHERE     LOWER (COMMENTS) LIKE ''''%special%''''
                           AND CLM_REF <> ''''OC-15-1002-8401-00014834''''
                  GROUP BY CLM_REF) I
              ON (C_CLAIM_NO = CLM_REF)
      WHEN MATCHED
      THEN
         UPDATE SET C_SPECIAL_COMMENTS = UTILS.MY_TRIM (I.COMMENTS), ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;


-------added by chandrakant for c_comments and close date
--logic addded Issue Number : 58792641 -  Update the latest remark


v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_COMMENTS = src.STATUS_MSG, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT CLM_REF,
                    UPPER (
                       CASE
                          WHEN LOWER (STATUS_MSG) LIKE
                                  ''''%claim closing reason%''''
                          THEN
                             UPPER (
                               -- UTILS.MY_TRIM (Code Trim changed on 09-09-25 due to column data discrepancy)
                                TRIM(
                                   SUBSTR (
                                      STATUS_MSG,
                                        REGEXP_INSTR (STATUS_MSG,
                                               '''':-'''',
                                               1,
                                               1)
                                      + 2,
                                        REGEXP_INSTR (SUBSTR (STATUS_MSG,
                                                         REGEXP_INSTR (STATUS_MSG,
                                                                '''':-'''',
                                                                1,
                                                                1)
                                                       + 2),
                                               ''''[.]'''',
                                               1,
                                               1)
                                      - 1)))
                          ELSE
                             STATUS_MSG
                       END)
                       STATUS_MSG
               FROM INTERMEDIATE.BJAZ_CLAIM_REMARKS A,
              TRANSACTIONAL.ODS_CLAIM_DIM B
              WHERE     CLM_REF = C_CLAIM_NO
                    AND NVL (STATUS, ''''ABC'''') = ''''Claim Closed''''
                    AND MAXIMUS_FLAG IS NULL
                    AND UPPER (
                           CASE
                              WHEN LOWER (STATUS_MSG) LIKE
                                      ''''%claim closing reason%''''
                              THEN
                                 UPPER (
                                   -- UTILS.MY_TRIM (Code Trim changed on 09-09-25 due to column data discrepancy)
                                   TRIM(
                                       SUBSTR (
                                          STATUS_MSG,
                                            REGEXP_INSTR (STATUS_MSG,
                                                   '''':-'''',
                                                   1,
                                                   1)
                                          + 2,
                                            REGEXP_INSTR (
                                               SUBSTR (STATUS_MSG,
                                                         REGEXP_INSTR (STATUS_MSG,
                                                                '''':-'''',
                                                                1,
                                                                1)
                                                       + 2),
                                               ''''[.]'''',
                                               1,
                                               1)
                                          - 1)))
                              ELSE
                                 STATUS_MSG
                           END) <> UPPER (NVL (C_COMMENTS, ''''abc''''))) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_CLO_DATE = src.CLOSING_DATE, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT A.CLM_REF,
                    DATE_TRUNC(''''DAY'''', TO_DATE (LUA_VALUE_1, ''''DD-MM-YYYY HH24:MI:SS''''))
                       CLOSING_DATE,
                    MSG_DATE
               FROM INTERMEDIATE.BJAZ_CLAIM_REMARKS A,TRANSACTIONAL.ODS_CLAIM_DIM B, ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES C
              WHERE     A.CLM_REF = B.C_CLAIM_NO
                    AND A.CLM_REF = C.CLM_REF
                    AND NVL (C_CLO_DATE, ''''26-sep-1992'''') <>
                           DATE_TRUNC(''''DAY'''', TO_DATE (LUA_VALUE_1, ''''DD-MM-YYYY HH24:MI:SS''''))
                    AND DATE_TRUNC(''''DAY'''', TO_DATE (LUA_VALUE_1, ''''DD-MM-YYYY HH24:MI:SS'''')) <
                           DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))
                    AND NVL (STATUS, ''''ABC'''') = ''''Claim Closed''''
                    AND MAXIMUS_FLAG IS NULL) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

CALL TRANSACTIONAL.WRK_CLOSING_REMARKS_UPDATE(''BAGIC_PROD_MIRROR_DB'');

v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM
        USING (SELECT DISTINCT A.*
                 FROM (  SELECT CLM_REF,
                                MAX (RECPT_PSR_ON) RECPT_PSR_ON,
                                MAX (RECPT_FSR_ON) RECPT_FSR_ON,
                                MAX (DOC_REC_DATE) DOC_REC_DATE,
                                MAX (SURVEYOR_APP_ON) SURVEYOR_APP_ON
                           FROM (  SELECT C.CLM_REF,
                                          NULL RECPT_PSR_ON,
                                          NULL RECPT_FSR_ON,
                                          NULL DOC_REC_DATE,
                                          MAX (DATE_TRUNC (''''DAY'''',SURVEYOR_APP_ON))
                                             AS SURVEYOR_APP_ON
                                     FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_SURV_TAT A,
                                          ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES C
                                    WHERE     A.CLAIM_ID = C.CLAIM_ID
                                          AND DATE_TRUNC(''''DAY'''', TRANSACTION_DATE) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''')
                           - 3)
                                                                           AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')
                                                                                  - 1)
                                          AND SURVEYOR_APP_ON IS NOT NULL
                                 GROUP BY C.CLM_REF
                                 UNION
                                   SELECT C.CLM_REF,
                                          MAX (A.RECPT_PSR_ON) RECPT_PSR_ON,
                                          MAX (A.RECPT_FSR_ON) RECPT_FSR_ON,
                                          NULL DOC_REC_DATE,
                                          NULL
                                     FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_SURV_TAT A, ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES C
                                    WHERE     A.CLAIM_ID = C.CLAIM_ID
                                          AND (   A.RECPT_FSR_ON IS NOT NULL
                                               OR RECPT_PSR_ON IS NOT NULL)
                                          AND DATE_TRUNC(''''DAY'''', TRANSACTION_DATE) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''')
                                                                                  - 3)
                                                                           AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')
                                                                                  - 1)
                                 --and c.clm_ref =''''oc-12-2401-420-00000001''''
                                 GROUP BY C.CLM_REF
                                 UNION
                                   SELECT CLM_REF,
                                          MAX (
                                             CASE
                                                WHEN SURVEY_STATUS = ''''P''''
                                                THEN
                                                   DATE_TRUNC(''''DAY'''', ENTRY_DATE)
                                             END)
                                             C_RECPT_PSR_DATE,
                                          MAX (
                                             CASE
                                                WHEN SURVEY_STATUS = ''''F''''
                                                THEN
                                                   DATE_TRUNC(''''DAY'''', ENTRY_DATE)
                                             END)
                                             C_RECPT_FSR_DATE,
                                          NULL,
                                          NULL
                                     FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_SURVEY_CLAIM_DETAILS A,
                                          ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
                                    WHERE     SURVEY_STATUS IN (''''P'''', ''''F'''')
                                          AND DATE_TRUNC(''''DAY'''', ENTRY_DATE) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''')
                                                                            - 20)
                                                                     AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')
                                                                            - 1)
                                          AND A.CLAIM_ID = B.CLAIM_ID
                                 GROUP BY CLM_REF
                                 UNION
                                   SELECT C.CLM_REF,
                                          NULL,
                                          NULL,
                                          MAX (DOC_REC_DATE),
                                          NULL
                                     FROM ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_BASE_MOT_EXT A, ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES C
                                    WHERE     A.CLAIM_ID = C.CLAIM_ID
                                          --and c.clm_ref =''''oc-12-2401-420-00000001''''
                                          --and a.claim_id =2677484
                                          AND DOC_REC_DATE IS NOT NULL
                                          AND C.DATE_REPORTED BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''')
                                                                         - 20)
                                                                  AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')
                                                                         - 1)
                                 GROUP BY C.CLM_REF) A,
                               TRANSACTIONAL.ODS_CLAIM_DIM B
                          WHERE     (   A.RECPT_PSR_ON <>
                                           NVL (B.C_RECPT_PSR_DATE,
                                                ''''1-jan-1990'''') --added NVL 19 JUL 2017
                                     OR NVL (C_RECPT_FSR_DATE, ''''1-jan-1990'''') <>
                                           RECPT_FSR_ON --added NVL 19 JUL 2017
                                     OR NVL (C_ALL_DOC_DATE, ''''1-jan-1990'''') <>
                                           DOC_REC_DATE --added NVL 19 JUL 2017
                                     OR SURVEYOR_APP_ON <>
                                           NVL (C_SUR_APP_DATE, ''''1-jan-1990'''')) --added NVL 19 JUL 2017
                                AND CLM_REF = C_CLAIM_NO
                       GROUP BY CLM_REF) A) I
           ON (C_CLAIM_NO = I.CLM_REF)
   WHEN MATCHED
   THEN
      UPDATE SET C_RECPT_PSR_DATE = I.RECPT_PSR_ON,
                 C_RECPT_FSR_DATE = I.RECPT_FSR_ON,
                 C_ALL_DOC_DATE = I.DOC_REC_DATE,
                 C_SUR_APP_DATE = I.SURVEYOR_APP_ON, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;


-----------------added by chandrakant.58776560
v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM
        USING (  SELECT DISTINCT CLM_REF, MAX (MSG_DATE) MSG_DATE
                   FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY A,
                         ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B,
                       TRANSACTIONAL.ODS_CLAIM_DIM D
                  WHERE     A.CLAIM_ID = B.CLAIM_ID
                        AND CLM_REF = C_CLAIM_NO
                        AND UPPER (STATUS_MSG) LIKE ''''SURVEYOR%''''
                        AND C_SUR_APP_DATE IS NULL
                        AND DATE_TRUNC(''''DAY'''', MSG_DATE) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 5)
                                                 AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
               GROUP BY CLM_REF) I
           ON (C_CLAIM_NO = I.CLM_REF)
   WHEN MATCHED
   THEN
      UPDATE SET C_SUR_APP_DATE = I.MSG_DATE, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;

------------------added by chandrakant(22-mar-2024) for audit
v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM
        USING (SELECT DISTINCT CLM_REF, DOC_REC_DATE
                 FROM (  SELECT C.CLM_REF, MAX (DOC_REC_DATE) DOC_REC_DATE
                           FROM ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_BASE_MOT_EXT A, ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES C
                          WHERE     A.CLAIM_ID = C.CLAIM_ID
                                AND DOC_REC_DATE IS NOT NULL
                                AND DATE_TRUNC(''''DAY'''', UPDATED_ON) >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 20
                       GROUP BY C.CLM_REF) A,
                     TRANSACTIONAL.ODS_CLAIM_DIM B
                WHERE     NVL (C_ALL_DOC_DATE, ''''1-jan-1990'''') <> DOC_REC_DATE
                      AND CLM_REF = C_CLAIM_NO) I
           ON (C_CLAIM_NO = I.CLM_REF)
   WHEN MATCHED
   THEN
      UPDATE SET C_ALL_DOC_DATE = I.DOC_REC_DATE, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;



v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM
           USING (SELECT DISTINCT CLM_REF, DOC_REC_DATE
                    FROM (  SELECT C.CLM_REF, MAX (DOC_REC_DATE) DOC_REC_DATE
                              FROM ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_BASE_MOT_EXT A, ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES C
                             WHERE     A.CLAIM_ID = C.CLAIM_ID
                                   AND DOC_REC_DATE IS NOT NULL
                                   AND DATE_TRUNC(''''DAY'''', TO_DATE (LUA_VALUE_1,
                                                   ''''DD-MM-YYYY HH24:MI:SS'''')) >=
                                          DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 20
                          GROUP BY C.CLM_REF) A,
                        TRANSACTIONAL.ODS_CLAIM_DIM B
                   WHERE     NVL (C_ALL_DOC_DATE, ''''1-jan-1990'''') <>
                                DOC_REC_DATE
                         AND CLM_REF = C_CLAIM_NO) I
              ON (C_CLAIM_NO = I.CLM_REF)
      WHEN MATCHED
      THEN
         UPDATE SET C_ALL_DOC_DATE = I.DOC_REC_DATE, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;



v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM
           USING (  SELECT DISTINCT CLM_REF,
                           DATE_REPORTED,
                           MAX (ENTRY_DATE) PSR,
                           MAX (C_RECPT_PSR_DATE)
                      FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_SURVEY_CLAIM_DETAILS A,
                           ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B,
                          TRANSACTIONAL.ODS_CLAIM_DIM,
                           ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_BASE_MOT_EXT C
                     WHERE     A.CLAIM_ID = C.CLAIM_ID
                           AND A.CLAIM_ID = B.CLAIM_ID
                           AND CLM_REF = C_CLAIM_NO
                           AND CLM_TYPE = ''''OD''''
                           AND SURVEY_STATUS = ''''P''''
                           AND DATE_TRUNC(''''DAY'''', ENTRY_DATE) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 10)
                                                      AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
                  GROUP BY CLM_REF, DATE_REPORTED
                    HAVING MAX (DATE_TRUNC(''''DAY'''', ENTRY_DATE)) <>
                              MAX (DATE_TRUNC(''''DAY'''', C_RECPT_PSR_DATE))) A
              ON (CLM_REF = C_CLAIM_NO)
      WHEN MATCHED
      THEN
         UPDATE SET C_RECPT_PSR_DATE = A.PSR, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM
           USING ( select * from (  SELECT DISTINCT CLM_REF,
                           DATE_REPORTED,
                           MAX (REPORT_SUBMITION_DATE) FSR,
                           MAX (C_RECPT_FSR_DATE),
                           ROW_NUMBER() OVER (PARTITION BY A.CLAIM_ID ORDER BY
                           A.GG_CHANGE_DATE DESC) AS RN
                      FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_SUPP_BASES A,
                           ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B,
                          TRANSACTIONAL.ODS_CLAIM_DIM,
                           ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_SURVEY_CLAIM_DETAILS D,
                           ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_BASE_MOT_EXT C
                     WHERE
                        A.CLAIM_ID = C.CLAIM_ID
                           AND A.CLAIM_ID = B.CLAIM_ID
                           AND CLM_REF = C_CLAIM_NO
                           AND CLM_TYPE = ''''OD''''
                           AND SURVEY_STATUS = ''''F''''
                           AND A.CLAIM_ID = D.CLAIM_ID
                           AND DATE_REPORTED BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 4)
                                                 AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)

                  GROUP BY CLM_REF, A.CLAIM_ID, A.GG_CHANGE_DATE, DATE_REPORTED
                    HAVING MAX (DATE_TRUNC(''''DAY'''', REPORT_SUBMITION_DATE)) <>
                              MAX (DATE_TRUNC(''''DAY'''', C_RECPT_FSR_DATE))) where RN = 1 ) A
              ON (CLM_REF = C_CLAIM_NO)
      WHEN MATCHED
      THEN
         UPDATE SET C_RECPT_FSR_DATE = A.FSR, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;


--added for arun patil claim settlement type

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_SETTLEMNT_TYPE = src.SETTLEMENT_TYPE, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT
               C_CLAIM_NO CLM_REF,
                CASE
                   WHEN CLM_SETTLEMENT_TYPE = ''''1''''
                   THEN
                      ''''Standard Settlement''''
                   WHEN CLM_SETTLEMENT_TYPE = ''''2''''
                   THEN
                      ''''Non Standard Settlement''''
                END
                   SETTLEMENT_TYPE,
                CLM_SETTLEMENT_TYPE SETTLEMENT_TYPE1
           FROM TRANSACTIONAL.ODS_CLAIM_DIM B,
           ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_MRN_EXTN MRN
          WHERE     B.C_CLAIM_ID = MRN.CLAIM_ID
                AND B.C_CLAIM_ID IN
                       (SELECT CLAIM_ID
                          FROM ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.CLM_TRANS
                         WHERE DATE_TRUNC(''''DAY'''', TRANS_DATE) >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 5)
                AND CASE
                       WHEN CLM_SETTLEMENT_TYPE = ''''1''''
                       THEN
                          ''''Standard Settlement''''
                       WHEN CLM_SETTLEMENT_TYPE = ''''2''''
                       THEN
                          ''''Non Standard Settlement''''
                    END <> NVL (C_SETTLEMNT_TYPE, ''''BLANK'''')
                AND CLM_SETTLEMENT_TYPE IN (1, 2)) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

-------issue no -39546916

v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM
        USING (  SELECT DISTINCT
                        CLM_REF,  --- added distinct by asawari (7th Nov 2019)
                        MAX (RESPONSIBLE) RESPONSIBLE,
                        NVL (CLAIMED_AMOUNT, 0) CLAIMED_AMOUNT
                   FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_RESP A,
                   ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
                  WHERE     TOP_INDICATOR = ''''Y''''
                        AND A.CLAIM_ID = B.CLAIM_ID
                        AND DATE_TRUNC(''''DAY'''', CHANGED_DATE) = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
               GROUP BY CLM_REF, NVL (CLAIMED_AMOUNT, 0)) I
           ON (CLM_REF = C_CLAIM_NO)
   WHEN MATCHED
   THEN
      UPDATE SET
         C_NAME_OF_IN2 = I.RESPONSIBLE, C_NAME_OF_IN3 = I.CLAIMED_AMOUNT, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;



v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM
        USING (SELECT *
                 FROM (SELECT
                             DISTINCT A.CLAIM_ID,
                              CLM_REF,
                                 REGEXP_REPLACE (UPPER (UTILS.MY_TRIM (STATUS_MSG)),
                                                 ''''[^[:alpha:]|[:space:]]'''','''''''')
                              || MSG_DATE
                                 STATUS_MSG,
                              C_LIGITATION_FLAG,
                              ROW_NUMBER ()
                              OVER (PARTITION BY A.CLAIM_ID
                                    ORDER BY A.CLAIM_ID)
                                 RNK
                         FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY A,
                              ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B,
                              TRANSACTIONAL.ODS_CLAIM_DIM C
                        WHERE     A.CLAIM_ID = B.CLAIM_ID
                              AND CLM_REF = C_CLAIM_NO
                              AND UPPER (UTILS.MY_TRIM (STATUS_MSG)) <>
                                     UPPER (
                                        UTILS.MY_TRIM (NVL (C_LIGITATION_FLAG, ''''NA'''')))
                              AND MSG_TYPE = ''''REMARK''''
                              AND DATE_TRUNC(''''DAY'''', MSG_DATE) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 1)
                                                       AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
                              AND VERSION_NO IN
                                     (SELECT MAX (VERSION_NO)
                                        FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY K
                                       WHERE     A.CLAIM_ID = K.CLAIM_ID
                                             AND MSG_TYPE = ''''REMARK''''))
                WHERE RNK = 1) A
           ON (A.CLM_REF = C_CLAIM_NO)
   WHEN MATCHED
   THEN
      UPDATE SET C_LIGITATION_FLAG = A.STATUS_MSG, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_OMBSMAN_FLAG = src.LOSS_DESC, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT A.CLAIM_ID,
                    CLM_REF,
                    SUBSTR (LOSS_DESC, 1, 3999) LOSS_DESC
               FROM ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_BASE_MOT_EXT A,
               ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B,
               TRANSACTIONAL.ODS_CLAIM_DIM C
              WHERE                                  --a.claim_id =4050629 and
                   A.CLAIM_ID = B.CLAIM_ID
                    AND LOSS_DESC IS NOT NULL
                    AND CLM_REF = C_CLAIM_NO
                    AND C_OMBSMAN_FLAG IS NULL
                    AND DATE_REPORTED >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 3) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_SUR_REP_DATE = src.MSG_DATE, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (  SELECT CLM_REF, MAX (MSG_DATE) MSG_DATE
                 FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY A,
                 ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
                WHERE     A.CLAIM_ID = B.CLAIM_ID
                      AND STATUS_MSG LIKE ''''Surveyor%''''
                      AND DATE_TRUNC(''''DAY'''', MSG_DATE) >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 5)  -- Date changed from T-1 to T-5
             GROUP BY CLM_REF) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

BEGIN

--c_settlemnt_type updates

v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM T
           USING (SELECT
                        DISTINCT
                         C_CLAIM_NO, SETTLEMENT_TYPE, NOTIFICATION_DATE
                    FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_BASE_MOT_EXT A,
                         ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B,
                         TRANSACTIONAL.ODS_CLAIM_DIM C,
                         ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.CLM_TRANS D
                   WHERE     A.CLAIM_ID = B.CLAIM_ID
                         AND CLM_REF = C_CLAIM_NO
                         AND NVL (C_SETTLEMNT_TYPE, ''''NA'''') <>
                                NVL (SETTLEMENT_TYPE, ''''NA'''')
                         AND B.CLAIM_ID = D.CLAIM_ID
                                --AND settlement_type IS NOT NULL
                                --AND T_DATE_DESC >BETWEEN DATE_TRUNC(''''DAY'''', CURRENT_DATE() - 25)
                         AND DATE_TRUNC(''''DAY'''', TRANS_DATE) = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1) --and C_CLAIM_STATUS=''''CLOSED''''
                                                                     --and DATE_TRUNC(''''DAY'''', updated_on) =DATE_TRUNC(''''DAY'''', CURRENT_DATE - 1)
                 ) I
              ON (T.C_CLAIM_NO = I.C_CLAIM_NO)
      WHEN MATCHED
      THEN
         UPDATE SET C_SETTLEMNT_TYPE = I.SETTLEMENT_TYPE, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;

--c_inti_date = i.notification_date;


END;

BEGIN

v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM T
           USING (SELECT
                        DISTINCT C_CLAIM_NO, SETTLEMENT_TYPE, NOTIFICATION_DATE
                    FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_BASE_MOT_EXT A,
                         ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B,
                         TRANSACTIONAL.ODS_CLAIM_DIM C
                   WHERE     A.CLAIM_ID = B.CLAIM_ID
                         AND CLM_REF = C_CLAIM_NO
                         AND NVL (C_SETTLEMNT_TYPE, ''''NA'''') <>
                                NVL (SETTLEMENT_TYPE, ''''NA'''')
                         --AND settlement_type IS NOT NULL
                         --AND T_DATE_DESC >BETWEEN DATE_TRUNC(''''DAY'''', CURRENT_DATE() - 25)
                         AND C.C_CLO_DATE >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 2) --and C_CLAIM_STATUS=''''CLOSED''''
                                                                --and DATE_TRUNC(''''DAY'''', updated_on) =DATE_TRUNC(''''DAY'''', CURRENT_DATE() - 1)
                 ) I
              ON (T.C_CLAIM_NO = I.C_CLAIM_NO)
      WHEN MATCHED
      THEN
         UPDATE SET C_SETTLEMNT_TYPE = I.SETTLEMENT_TYPE, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;

--c_inti_date = i.notification_date;

END;

--Added By chandrakant As discussed with priyank sir, narendra,fareen,mousmi(18-nov-2021)

BEGIN

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_DAILY_HUB_CLM'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_DAILY_HUB_CLM (
    CLM_TRANS_ID,
    VERSION_NO,
    CLAIM_ID,
    INTIMATION_ID,
    CLM_REF,
    DATE_OF_LOSS,
    CLAIM_TYPE,
    POLICY_REF,
    CONTRACT_ID,
    COVERNOTE_NO,
    REGISTRATION_NO,
    COMPANY_CODE,
    BUSINESS_TYPE,
    ORIGINATOR,
    RESPONSIBLE,
    BRANCH_CODE,
    STATUS,
    SUB_STATUS,
    PRODUCT_CODE,
    CLM_REGISTER_DATE,
    RECORD_DATE,
    REMARKS,
    USER_NAME,
    TRANS_FROM_DATE,
    TRANS_TO_DATE,
    TRANS_TAT,
    TARGET_DATE,
    PRIORITY,
    ADDRESS_CHANGE_YN,
    SPOT_SURVEY_YN,
    TAKEN_REPAIR_YN,
    IMDREP_SAME_YN,
    ITRACK_NO,
    VALIDATE_YN,
    TOP_INDICATOR,
    REASON_TO_REFFERAL,
    PERSON_RESPONSIBLE,
    CLAIM_REFER_TO,
    PARTITION_STATUS,
    PORTAL_FLAG,
    DELAY_FLAG,
    TAT_REASON,
    TAT_REMARKS,
    FOLLOW_UP_DATE,
    FOLLOW_UP_TIME,
    DELAY_DAYS,
    DELIVERY_ORDER_DATE,
    SOURCE_FLAG,
    WRK_APRL_DLAY_FLG,
    FLG_RE_INSPECT,
    REPAIRER_NOT_APPOINT_FLAG,
    INITIAL_DOC_REC_DATE,
    KO_INSP_HIST_FLG,
    LAST_DOC_DATE,
    INC_JOB_CREATED_AT,
    INC_JOB_CREATED_BY,
    INC_JOB_ID,
    INC_JOB_UPDATED_AT,
    INC_JOB_UPDATED_BY
)
SELECT
    CLM_TRANS_ID,
    VERSION_NO,
    CLAIM_ID,
    INTIMATION_ID,
    CLM_REF,
    DATE_OF_LOSS,
    CLAIM_TYPE,
    POLICY_REF,
    CONTRACT_ID,
    COVERNOTE_NO,
    REGISTRATION_NO,
    COMPANY_CODE,
    BUSINESS_TYPE,
    ORIGINATOR,
    RESPONSIBLE,
    BRANCH_CODE,
    STATUS,
    SUB_STATUS,
    PRODUCT_CODE,
    CLM_REGISTER_DATE,
    RECORD_DATE,
    REMARKS,
    USER_NAME,
    TRANS_FROM_DATE,
    TRANS_TO_DATE,
    TRANS_TAT,
    TARGET_DATE,
    PRIORITY,
    ADDRESS_CHANGE_YN,
    SPOT_SURVEY_YN,
    TAKEN_REPAIR_YN,
    IMDREP_SAME_YN,
    ITRACK_NO,
    VALIDATE_YN,
    TOP_INDICATOR,
    REASON_TO_REFFERAL,
    PERSON_RESPONSIBLE,
    CLAIM_REFER_TO,
    PARTITION_STATUS,
    PORTAL_FLAG,
    DELAY_FLAG,
    TAT_REASON,
    TAT_REMARKS,
    FOLLOW_UP_DATE,
    FOLLOW_UP_TIME,
    DELAY_DAYS,
    DELIVERY_ORDER_DATE,
    SOURCE_FLAG,
    WRK_APRL_DLAY_FLG,
    FLG_RE_INSPECT,
    REPAIRER_NOT_APPOINT_FLAG,
    INITIAL_DOC_REC_DATE,
    KO_INSP_HIST_FLG,
    LAST_DOC_DATE,
    INC_JOB_CREATED_AT,
    INC_JOB_CREATED_BY,
    INC_JOB_ID,
    INC_JOB_UPDATED_AT,
    INC_JOB_UPDATED_BY
           FROM '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.BJAZ_HUB_CLM_TRANS_DTLS
          WHERE DATE_TRUNC(''''DAY'''', RECORD_DATE) = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)'';
EXECUTE IMMEDIATE v_sqltext;



v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_SETTLEMNT_TYPE = src.SETTLEMENT_TYPE, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT DISTINCT C_CLAIM_NO, SETTLEMENT_TYPE
               FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_BASE_MOT_EXT A,
                    INTERMEDIATE.WRK_DAILY_HUB_CLM D,
                    TRANSACTIONAL.ODS_CLAIM_DIM C
              WHERE     A.CLAIM_ID = D.CLAIM_ID
                    AND D.CLM_REF = C_CLAIM_NO
                    AND NVL (C_SETTLEMNT_TYPE, ''''NA'''') <>
                           NVL (SETTLEMENT_TYPE, ''''NA'''')) AS src
WHERE target.C_CLAIM_NO = src.C_CLAIM_NO'';
EXECUTE IMMEDIATE v_sqltext;

END;

BEGIN
v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_INTI_DATE = src.DATE_OF_INTIMATION, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (  SELECT CLM_REF,
                      MIN (DATE_TRUNC(''''DAY'''', NVL (DATE_OF_INTIMATION, INSERT_DATE)))
                         DATE_OF_INTIMATION -- changed logic by asawari on 3rd nov
                 FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_TPCLM_INTIM_DTL A,
                 ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
                 -- CURRENT_USER sandesh sawant
                WHERE     A.CLAIM_ID = B.CLAIM_ID
                      AND DATE_REPORTED BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 2)
                                            AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
                      AND (   DATE_OF_INTIMATION IS NOT NULL
                           OR INSERT_DATE IS NOT NULL)
             GROUP BY CLM_REF) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

END;

--Added By chandrakant As discussed with priyank sir(18-nov-2021)

BEGIN

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_LOSS_DATE = src.NEW_LOSS_DATE, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT
                   CLAIM_NO,
                    C_LOSS_DATE,
                    NVL (ACTUAL_DOA, EXPECTED_DOA) NEW_LOSS_DATE
               FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_HM_HCM_EXTRACT_MV A,
                    PROD_DWH_MIGRATED_DB.PROD.ODS_PRODUCT_DIM B,
                    TRANSACTIONAL.ODS_CLAIM_DIM C
              WHERE     A.PRODUCT = P_PRODUCT_ID
                    AND P_ACC_LOB = ''''RETAIL HEALTH''''
                    AND CLAIM_NO = C_CLAIM_NO
                    AND MAXIMUS_FLAG IS NOT NULL
                    AND TRUNC_UPDATEDON >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 5
                    AND NVL (C_LOSS_DATE, ''''1-sep-1990'''') <>
                           NVL (NVL (ACTUAL_DOA, EXPECTED_DOA), ''''1-sep-1990'''')) AS src
WHERE C_CLAIM_NO = src.CLAIM_NO'';
EXECUTE IMMEDIATE v_sqltext;

END;

BEGIN

v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM A
           USING (SELECT DISTINCT CLAIM_NO,
                         CLAIM_TYPE,
                         NVL (DOCUMENT_RECEIVE_DATE, DOC_RECEIVE_DATE_MAX)
                            DOC_RECEIVE_DATE_MAX
                    FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_HM_HCM_EXTRACT_MV A,
                    TRANSACTIONAL.ODS_CLAIM_DIM B
                   WHERE     CLAIM_NO = B.C_CLAIM_NO
                         AND DATE_TRUNC(''''DAY'''', TRUNC_UPDATEDON) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 5)
                                                 AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1) --AND c_settlemnt_type IS NULL
                                                                        ) B
              ON (A.C_CLAIM_NO = B.CLAIM_NO)
      WHEN MATCHED
      THEN
         UPDATE SET
            A.C_ALL_DOC_DATE = B.DOC_RECEIVE_DATE_MAX,
            A.C_SETTLEMNT_TYPE = UPPER (B.CLAIM_TYPE), ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;

END;

--for above date condition changed date to -5 by rizwan shaikh DATE_TRUNC(''''DAY'''', TRUNC_UPDATEDON) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 5)


BEGIN

v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM A
           USING (  SELECT DISTINCT CLM_REF, MAX (SETTELEMENT_TYPE) SETTELEMENT_TYPE
                      FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_TPA_CLAIM_DETAILS_WS C,
                      ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES D
                     WHERE     C.BJAZ_CLAIM_ID = D.CLAIM_ID
                           --AND NVL (SETTELEMENT_TYPE, ''''ABC'''') <> NVL (C_SETTLEMNT_TYPE, ''''pqr'''')
                           AND SETTELEMENT_TYPE IS NOT NULL
                           AND DATE_TRUNC(''''DAY'''', INSERTED_ON) >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 2)
                  GROUP BY CLM_REF) B
              ON (A.C_CLAIM_NO = B.CLM_REF)
      WHEN MATCHED
      THEN
         UPDATE SET A.C_SETTLEMNT_TYPE = UPPER (B.SETTELEMENT_TYPE), ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;

END;

BEGIN

v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM A
USING (
        SELECT C_CLAIM_NO, C_CLAIM_ID_SK, DELAY_REASON
        FROM (
            SELECT C_CLAIM_NO, C_CLAIM_ID_SK, DELAY_REASON,
                row_number() over (partition by C_CLAIM_NO order by UPDATED_ON DESC) AS rn
            FROM ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_CLAIM_DELAY_REASON A
            JOIN TRANSACTIONAL.ODS_CLAIM_DIM B
              ON C_CLAIM_NO = CLM_REF
            WHERE DELAY_REASON IS NOT NULL
              AND DATE_TRUNC(''''DAY'''', UPDATED_ON) = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
        )
        where rn = 1
     ) B
ON B.C_CLAIM_NO = A.C_CLAIM_NO
WHEN MATCHED THEN
  UPDATE SET C_DELAY_REASON = B.DELAY_REASON, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;



END;

---to update mrn transaporter name in the sys......itrack issue no:38208594

BEGIN

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_MRN_TRANSPORTER_NAME = src.NME, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT
                   B.CLM_REF CLM_REF, CP.NAME NME
               FROM                                        ---ods_claim_dim a,
                   ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B,
                    ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_MRN_EXTN MRN,
                    ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_SUPPLIERS C,
                    ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.CP_PARTNERS CP
              WHERE                                ----a.c_claim_no =b.clm_ref
                   MRN  .CLAIM_ID = B.CLAIM_ID
                    AND C.PART_ID = CP.PART_ID
                    AND C.SUPP_ID = MRN.SUPPLIER_ID
                    AND DATE_TRUNC(''''DAY'''', LORRY_RECEIPT_DATE) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 2)
                                                       AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

END;

-------------for health billing update
BEGIN

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_BILL_DATE = src.BILL_DATE, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (  SELECT A.CLAIM_ID, CLM_REF, DATE_TRUNC(''''DAY'''', MAX (UPDATED_ON)) BILL_DATE
                 FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_HM_BILL_DETAIL A,
                 ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES  B,
                 TRANSACTIONAL.ODS_CLAIM_DIM C
                WHERE     DATE_TRUNC(''''DAY'''', DATE_REPORTED) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 4)
                                                    AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
                      AND A.CLAIM_ID = B.CLAIM_ID
                      AND CLM_REF = C_CLAIM_NO
                      AND C_BILL_DATE IS NULL
             GROUP BY A.CLAIM_ID, CLM_REF) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;






END;

--   L_START := DBMS_UTILITY.GET_TIME;
   --
   --   INSERT INTO WRK_SAL_MISS (CLAIM_ID_SK, REASON)
   --      SELECT A.*, ''''Salvage Missing IN MV''''
   --        FROM (  SELECT C_CLAIM_ID_SK
   --                  FROM ODS_CLAIM_FACT A, ODS_TIME_DIM B
   --                 WHERE     A.T_DATE_ID_SK = B.T_DATE_ID_SK
   --                       AND TO_CHAR ( (T_DATE_DESC), ''''mon.yyyy'''') =
   --                              TO_CHAR ( (SYSDATE - 1), ''''mon.yyyy'''')
   --                       AND R_RESERVE_TYPE_ID = 9001
   --              GROUP BY C_CLAIM_ID_SK
   --                HAVING SUM (SALVAGE_AMOUNT) <> 0
   --              MINUS
   --                SELECT C_CLAIM_ID_SK
   --                  FROM ODS_CLAIM_FACT_MV A, ODS_TIME_DIM B
   --                 WHERE     A.T_DATE_ID_SK = B.T_DATE_ID_SK
   --                       AND R_RESERVE_TYPE_ID = 9001
   --                       AND TO_CHAR ( (T_DATE_DESC), ''''mon.yyyy'''') =
   --                              TO_CHAR (TRUNC (SYSDATE - 1), ''''mon.yyyy'''')
   --              GROUP BY C_CLAIM_ID_SK
   --                HAVING SUM (SALVAGE_AMOUNT) <> 0) A;
   --
   --

   --   LOGTRACE (
   --      ''''LOG'''',
   --      10001,
   --         ''''claim_post_load_updates Salvage Mismatch 32:''''
   --      || TO_CHAR ( (DBMS_UTILITY.GET_TIME - L_START) / 100 / 60),
   --      ''''CLAIM_POST_LOAD_UPDATES'''');

BEGIN

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_LOSS_DATE = src.DATE_OF_LOSS, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT
                   CLM_REF, DATE_OF_LOSS, C_LOSS_DATE
               FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES  A,
              TRANSACTIONAL.ODS_CLAIM_DIM B
              WHERE     CLM_REF = C_CLAIM_NO
                    AND DATE_REPORTED >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 5
                    AND NVL (DATE_TRUNC(''''DAY'''', DATE_OF_LOSS), DATE_REPORTED) <>
                           NVL (DATE_TRUNC(''''DAY'''', C_LOSS_DATE), C_REGN_DATE)) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

END;


BEGIN

v_sqltext := ''MERGE
           INTO  TRANSACTIONAL.ODS_CLAIM_DIM A
           USING (SELECT DISTINCT CLM_REF, STATUS, TPA_CLAIM_NO
                    FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_TPA_CLAIM_DETAILS_WS A,
                         ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B,
                         TRANSACTIONAL.ODS_CLAIM_DIM C
                   WHERE     A.BJAZ_CLAIM_ID = B.CLAIM_ID
                         AND A.TOP_INDICATOR = ''''Y''''
                         AND CLM_REF = C_CLAIM_NO
                         AND C_REGN_DATE BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 5)
                                             AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
                         AND (   STATUS <> NVL (C_TPA_STATUS, ''''NA'''')
                              OR NVL (C_EMEDITEK_CLAIM_NO, ''''NA'''') <>
                                    TPA_CLAIM_NO)
                            QUALIFY ROW_NUMBER() OVER (PARTITION BY CLM_REF ORDER BY LAST_UPDATED_DATE DESC) = 1
                            ) B
              ON (B.CLM_REF = A.C_CLAIM_NO)
      WHEN MATCHED
      THEN
         UPDATE SET
            C_TPA_STATUS = B.STATUS, C_EMEDITEK_CLAIM_NO = B.TPA_CLAIM_NO, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;


END;

BEGIN

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.ODS_SALVAGE_DTLS'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.ODS_SALVAGE_DTLS
         SELECT A.CLM_REF,
                ESTMD_SAL_VALUE,
                SALVAGE_ID,
                A.UPDATED_ON UPDATE_DATE,
                UTILS.TP_CLM_GET_STATUS (REQ_STATUS, ''''SALVAGE'''') REQ_STATUS,
                PLACE_OF_SAL,
                SALVAGE_DESC,
                REQ_ORIGINATOR,
                RESP_AUTHORITY,
                SAL_BUYER_NAME,
                QUOTATION_AMT,
                CONTACT_NUMBER,
                QUOTATION_REMARK,
                CLAIMED_AMOUNT
           FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_SAL_TRACKER_DTLS A,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_SAL_QUOTATION_DTLS C,
                ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_RESP D
          WHERE     A.CLM_REF = B.CLM_REF
                AND B.CLAIM_ID = C.CLAIM_ID
                AND D.TOP_INDICATOR(+) = ''''Y''''
                AND DATE_REPORTED >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 5
                AND B.CLAIM_ID = D.CLAIM_ID(+)'';
EXECUTE IMMEDIATE v_sqltext;



END;

CALL TRANSACTIONAL.WRK_EVENT_CODE_UPDATE_PRC(''BAGIC_PROD_MIRROR_DB'');

v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM
        USING (SELECT DISTINCT CLM_REF, RFA_DATE
                 FROM (  SELECT A.CLAIM_ID,
                                CLM_REF,
                                MIN (TRANS_DATE) RFA_DATE
                           FROM ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.CLM_TRANS A,
                           ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
                          WHERE     A.CLM_STATUS = ''''AP''''
                                AND A.CLAIM_ID = B.CLAIM_ID
                                --and b.clm_status <>''''CLOSED''''
                                AND TRANS_TYPE <> ''''60''''
                                AND DATE_REPORTED BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 2)
                                                      AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
                       ----and clm_ref =''''OC-12-2001-1811-00000111''''
                       GROUP BY A.CLAIM_ID, CLM_REF) A,
                      TRANSACTIONAL.ODS_CLAIM_DIM B
                WHERE     A.CLM_REF = B.C_CLAIM_NO
                      AND NVL (C_RFA_DATE, DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))) <> RFA_DATE) C
           ON (CLM_REF = C_CLAIM_NO)
   WHEN MATCHED
   THEN
      UPDATE SET C_RFA_DATE = C.RFA_DATE, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;

-- BEGIN

-- v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
--             SET C_PLACE_OF_LOSS = src.PLACE_OF_LOSS,
--                 C_LANDMARK = src.LANDMARK,
--                 C_AREA = src.AREA,
--                 C_STATE = src.STATE,
--                 C_CITY = src.CITY,
--                 C_PINCODE = src.PINCODE,
--                 C_JOURNEY_FROM = src.JOURNEY_FROM,
--                 C_JOURNEY_TO = src.JOURNEY_TO,
--                 C_CONSIGNEE_NAME = src.CONSIGNEE_NAME,
--                 C_CONSIGNER_NAME = src.CONSIGNER_NAME,
--                 C_SURVEY_LOCATION = src.SURVEY_LOCATION,
--                 C_GOODS_DETAILS = src.GOODS_DETAILS, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
-- FROM (SELECT C.CLM_REF,
--                     A.CLAIM_ID,
--                     A.PLACE_OF_LOSS,
--                     LANDMARK,
--                     AREA,
--                     STATE,
--                     CITY,
--                     PINCODE,
--                     JOURNEY_FROM,
--                     JOURNEY_TO,
--                     CONSIGNEE_NAME,
--                     CONSIGNER_NAME,
--                     SURVEY_LOCATION,
--                     GOODS_DETAILS
--                FROM ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_BASE_MOT_EXT A,
--                     ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_MRN_EXTN B,
--                     ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES C
--               WHERE     A.CLAIM_ID = B.CLAIM_ID(+)
--                     AND A.CLAIM_ID = C.CLAIM_ID
--                     AND DATE_REPORTED BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 2)
--                                           AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
--                     AND (   A.PLACE_OF_LOSS IS NOT NULL
--                          OR LANDMARK IS NOT NULL
--                          OR AREA IS NOT NULL
--                          OR STATE IS NOT NULL
--                          OR CITY IS NOT NULL
--                          OR PINCODE IS NOT NULL
--                          OR JOURNEY_FROM IS NOT NULL
--                          OR JOURNEY_TO IS NOT NULL
--                          OR CONSIGNEE_NAME IS NOT NULL
--                          OR CONSIGNER_NAME IS NOT NULL
--                          OR SURVEY_LOCATION IS NOT NULL
--                          OR GOODS_DETAILS IS NOT NULL)) AS src
-- WHERE C_CLAIM_NO = src.CLM_REF'';
-- EXECUTE IMMEDIATE v_sqltext;

-- END;

BEGIN

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET  C_JOURNEY_FROM = src.JOURNEY_FROM,
                C_JOURNEY_TO = src.JOURNEY_TO,
                C_CONSIGNEE_NAME = src.CONSIGNEE_NAME,
                C_CONSIGNER_NAME = src.CONSIGNER_NAME,
                C_SURVEY_LOCATION = src.SURVEY_LOCATION,
                C_GOODS_DETAILS = src.GOODS_DETAILS, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT C.CLM_REF,  JOURNEY_FROM,
                    JOURNEY_TO,
                    CONSIGNEE_NAME,
                    CONSIGNER_NAME,
                    SURVEY_LOCATION,
                    GOODS_DETAILS
               FROM  ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_MRN_EXTN B,
                    ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES C
              WHERE     B.CLAIM_ID = C.CLAIM_ID
                    AND DATE_TRUNC(''''DAY'''',GG_CHANGE_DATE) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 2)
                                          AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
                    AND (
                         JOURNEY_FROM IS NOT NULL
                         OR JOURNEY_TO IS NOT NULL
                         OR CONSIGNEE_NAME IS NOT NULL
                         OR CONSIGNER_NAME IS NOT NULL
                         OR SURVEY_LOCATION IS NOT NULL
                         OR GOODS_DETAILS IS NOT NULL)) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;
END;

BEGIN

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_PLACE_OF_LOSS = src.PLACE_OF_LOSS,
                C_LANDMARK = src.LANDMARK,
                C_AREA = src.AREA,
                C_STATE = src.STATE,
                C_CITY = src.CITY,
                C_PINCODE = src.PINCODE ,
                ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT C.CLM_REF,
                    A.CLAIM_ID,
                    A.PLACE_OF_LOSS,
                    LANDMARK,
                    AREA,
                    STATE,
                    CITY,
                    PINCODE
               FROM ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_BASE_MOT_EXT A,
                    ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES C
              WHERE      A.CLAIM_ID = C.CLAIM_ID
                    AND DATE_TRUNC(''''DAY'''',GG_CHANGE_DATE) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 2)
                                          AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
                    AND (   A.PLACE_OF_LOSS IS NOT NULL
                         OR LANDMARK IS NOT NULL
                         OR AREA IS NOT NULL
                         OR STATE IS NOT NULL
                         OR CITY IS NOT NULL
                         OR PINCODE IS NOT NULL )) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

END;


BEGIN

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_LANDMARK = src.DRIVER_NAME, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT CLM_REF, DRIVER_NAME
               FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_DRV_DTLS A,
               ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
              WHERE     A.CLAIM_ID = B.CLAIM_ID
                    AND DATE_TRUNC(''''DAY'''', A.INSERT_DATE) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 3)
                                                  AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

END;

BEGIN

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_FSR_PSR_STATUS = src.SURVEY_STATUS, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT DISTINCT
                    (B.CLAIM_REF) CLAIM,
                    NVL (A.SURVEY_STATUS, B.STATUS) SURVEY_STATUS
               FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_SURVEY_CLAIM_DETAILS A,
                    ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_DOWNLOAD_DTLS B,
                    ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_BASE_MOT_EXT C,
                    ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES D
              WHERE     A.CLAIM_ID(+) = B.CLAIM_ID
                    AND B.CLAIM_ID = C.CLAIM_ID
                    AND C.CLAIM_ID = D.CLAIM_ID
                    AND DATE_TRUNC(''''DAY'''', ENTRY_DATE) >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) -2) AS src
WHERE C_CLAIM_NO = src.CLAIM'';
EXECUTE IMMEDIATE v_sqltext;



END;

BEGIN

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_FPLM_FLAG = src.FPLM_FLAG, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT
                   C_CLAIM_NO, FPLM_FLAG, DATE_TRUNC(''''DAY'''', UPDATED_ON)
               FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_BASE_MOT_EXT A,
                    ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B,
                    TRANSACTIONAL.ODS_CLAIM_DIM C
              WHERE     A.CLAIM_ID = B.CLAIM_ID
                    AND CLM_REF = C_CLAIM_NO
                    AND C_REGN_DATE BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 3)
                                        AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
                    AND UTILS.MY_TRIM (FPLM_FLAG) IS NOT NULL) AS src
WHERE target.C_CLAIM_NO = src.C_CLAIM_NO'';
EXECUTE IMMEDIATE v_sqltext;

END;

-- v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM T
--         USING (SELECT DISTINCT
--                       B.CLM_REF,
--                       C_CAUSE_OF_LOSS,
--                       UPPER (UTILS.MY_TRIM (C.DESCRIPTION)) DESCRIPTION
--                  FROM INTERMEDIATE.WRK_CLM_BASES_HIST A,
--                       ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B,
--                       ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CC_V_CAUSE_OF_LOSSES C,
--                       TRANSACTIONAL.ODS_CLAIM_DIM D
--                 WHERE     A.CLM_REF_HIST = B.CLM_REF
--                       AND B.CLM_REF = D.C_CLAIM_NO
--                       AND SULA_ORA_NLS_CODE = ''''US''''
--                       AND C.COL_CODE = B.COL_CODE
--                       AND NVL (C_CAUSE_OF_LOSS, ''''OTHERS'''') <>
--                              UPPER (UTILS.MY_TRIM (C.DESCRIPTION))) B
--            ON (T.C_CLAIM_NO = B.CLM_REF)
--    WHEN MATCHED
--    THEN
--       UPDATE SET C_CAUSE_OF_LOSS = B.DESCRIPTION, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
-- EXECUTE IMMEDIATE v_sqltext;
-- commneted on 27/1/25 due to duplicate issue

v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM T
        USING (SELECT DISTINCT
                      B.CLM_REF,
                      C_CAUSE_OF_LOSS,
                      UPPER (TRIM (C.DESCRIPTION)) DESCRIPTION
                 FROM INTERMEDIATE.WRK_CLM_BASES_HIST A,
                      ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B,
                      ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CC_V_CAUSE_OF_LOSSES C,
                      TRANSACTIONAL.ODS_CLAIM_DIM D
                WHERE     A.CLM_REF_HIST = B.CLM_REF
                      AND B.CLM_REF = D.C_CLAIM_NO
                      AND SULA_ORA_NLS_CODE = ''''US''''
                      AND C.COL_CODE = B.COL_CODE
                      AND NVL (C_CAUSE_OF_LOSS, ''''OTHERS'''') <>
                             UPPER (TRIM (C.DESCRIPTION))
							 QUALIFY ROW_NUMBER() OVER (PARTITION BY CLM_REF ORDER BY LAST_UPDATED_DATE DESC) = 1
							 ) B
           ON (T.C_CLAIM_NO = B.CLM_REF)
   WHEN MATCHED
   THEN
      UPDATE SET C_CAUSE_OF_LOSS = B.DESCRIPTION, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;


BEGIN
v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_CAUSE_OF_LOSS = src.CONFIG_DESC, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT A.CLM_REF, TYPE_OF_LOSS, CONFIG_DESC
               FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES A,
                    ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_HM_CLM_REGISTER B,
                   ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_HM_CONFIGURATOR C
              WHERE     A.CLAIM_ID = B.CLAIM_ID
                    AND B.TYPE_OF_LOSS = C.CONFIG_VALUE
                    AND C.CONFIG_NAME = ''''TRAVEL_TYPE_OF_LOSS''''
                    --AND TO_CHAR ( (date_reported), ''''mon.yyyy'''') =TO_CHAR (DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1), ''''mon.yyyy''''))
                    AND DATE_TRUNC(''''DAY'''', UPDATED_ON) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 3)
                                               AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;



END;

--BEGIN

v_sqltext := ''MERGE INTO  TRANSACTIONAL.ODS_CLAIM_DIM T
        USING (  SELECT DISTINCT MAX (A.NEXT_RVW_DATE) N_RVW_DATE,
                        MAX (A.LAST_RVW_DATE) L_RVW_DATE,
                        MAX (B.STATUS_MSG) REMARKS,
                        C.CLAIM_ID,
                        C.CLM_REF
                   FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_RESP A,
                        PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY B,
                        ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES C,
                        TRANSACTIONAL.ODS_CLAIM_DIM D
                  WHERE     A.CLAIM_ID = B.CLAIM_ID
                        AND C.CLAIM_ID = B.CLAIM_ID
                        AND D.C_CLAIM_NO = CLM_REF
                        AND MSG_TYPE = ''''REMARK''''
                        AND A.TOP_INDICATOR = ''''Y''''
                        AND (   NVL (D.C_NEXT_RVW_DATE, ''''1-jan-1980'''') <>
                                   A.NEXT_RVW_DATE
                             OR B.STATUS_MSG <>
                                   NVL (D.C_LAST_RVW_REMARKS, ''''XYZABC''''))
                        AND DATE_TRUNC(''''DAY'''', CHANGED_DATE) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''')) - 2
                                                     AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1 --replaced date_reported  to changed_date
                        --and slab from 90 to 10   23JAN18 vivek
                        AND B.VERSION_NO =
                               (SELECT MAX (VERSION_NO)
                                  FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY
                                 WHERE     CLAIM_ID = C.CLAIM_ID
                                       AND MSG_TYPE = ''''REMARK'''')
               GROUP BY                                        --b.status_msg,
                       C.CLAIM_ID, C.CLM_REF) X
           ON (T.C_CLAIM_NO = X.CLM_REF)
   WHEN MATCHED
   THEN
      UPDATE SET
         T.C_NEXT_RVW_DATE = X.N_RVW_DATE,
         T.C_LAST_RVW_REMARKS = X.REMARKS,
         T.C_LAST_RVW_DATE = X.L_RVW_DATE, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
   WHEN NOT MATCHED
   THEN
      INSERT     (T.C_NEXT_RVW_DATE, T.C_LAST_RVW_REMARKS, C_LAST_RVW_DATE, ETL_REFRESH_AT)
          VALUES (X.N_RVW_DATE, X.REMARKS, X.L_RVW_DATE, CURRENT_TIMESTAMP())'';
EXECUTE IMMEDIATE v_sqltext;



BEGIN

v_sqltext := ''MERGE /*+ append parallel("ods_claim_dim") */
           INTO   TRANSACTIONAL.ODS_CLAIM_DIM X
           USING (SELECT DISTINCT
                         C_CLAIM_ID_SK,
                         C_CLAIM_NO,
                         CLM_STATUS C_CLAIM_STATUS,
                         C_CLO_DATE,
                         CASE
                            WHEN CLM_STATUS = ''''CLOSED''''
                            THEN
                               CASE
                                  WHEN LUA_VALUE_1 IS NULL
                                  THEN
                                     TO_DATE (DATE_REPORTED)
                                  ELSE
                                     DATE_TRUNC(''''DAY'''', TO_DATE (LUA_VALUE_1,''''dd-mm-yyyy hh24:mi:ss''''))
                               END
                            ELSE
                               C_CLO_DATE
                         END
                            LUA_VALUE_1
                    FROM INTERMEDIATE.WRK_CLM_BASES_HIST T,
                    ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES,
                    TRANSACTIONAL.ODS_CLAIM_DIM
                   WHERE     T.CLM_REF_HIST = CLM_REF
                         AND CLM_REF = C_CLAIM_NO
                         AND NVL (
                                DATE_TRUNC(''''DAY'''', TO_DATE (LUA_VALUE_1,
                                            ''''dd-mm-yyyy hh24:mi:ss'''')),
                                C_REGN_DATE) < DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))
                         AND C_CLAIM_STATUS = ''''CLOSED'''') I
              ON (X.C_CLAIM_ID_SK = I.C_CLAIM_ID_SK)
      WHEN MATCHED
      THEN
         UPDATE SET X.C_CLO_DATE = I.LUA_VALUE_1, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;
--- was commnented earlier due to duplicate values

END;
BEGIN

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_INVOICE_NO = src.REFERENCE_TEXT,
                C_INVOICE_DATE = src.TRANS_DATE, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT
                   DISTINCT JJ.CLM_REF,
                            K.CLAIM_ID,
                            MAX(REFERENCE_TEXT)  AS REFERENCE_TEXT,
                            --(Above max statment added due to multiple records different b/w DWh and SF delpoyed code changes as confirmation from sachin/ramesh on 29-09-2025)
                            K.TRANS_DATE
               FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_MOT_CLM_TRANS_EXTN AA,
               ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.CLM_TRANS K,
               ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES JJ
              WHERE     AA.CLAIM_ID = K.CLAIM_ID
                    AND AA.SF_NO = K.SF_NO
                    AND AA.TRANS_NO = K.TRANS_NO
                    AND K.CLAIM_ID = JJ.CLAIM_ID
                    --AND REPLACE (REFERENCE_TEXT, '''','''', '''''''') IS NOT NULL (Manju Code change on 11-09-25 with below line as replaced character is not null)
                    AND NULLIF(REPLACE(REFERENCE_TEXT, '''','''', ''''''''), '''''''') IS NOT NULL
					--AND (DATE change from -2 to -5 for F_DATE by Ramesh on 30-09-2025)
                    AND DATE_TRUNC(''''DAY'''', K.TRANS_DATE) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 5)
                                                 AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
                Group by JJ.CLM_REF, K.CLAIM_ID,K.TRANS_DATE

                                                 ) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

END;





BEGIN
v_sqltext := ''MERGE INTO  TRANSACTIONAL.ODS_CLAIM_DIM A
           USING ( select * from (  SELECT DISTINCT CLM_REF,
                           ADDL_EXCESS,
                           VOLUNTARY_EXCESS,
                           COMPULSORY_EXCESS,
                           MAX (VERSION_NO),
                           ROW_NUMBER() OVER (PARTITION BY A.CLAIM_ID ORDER BY GG_CHANGE_DATE DESC) AS RN
                      FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_SUPP_BASES A,
                      ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
                     WHERE
                     B.CLAIM_ID = A.CLAIM_ID
                           AND DATE_REPORTED BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 5)
                                                 AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)


                  GROUP BY CLM_REF,
                           A.CLAIM_ID,
                           ADDL_EXCESS,
                           VOLUNTARY_EXCESS,
                           COMPULSORY_EXCESS,
                           GG_CHANGE_DATE) where RN = 1) B
              ON (A.C_CLAIM_NO = B.CLM_REF)
      WHEN MATCHED
      THEN
         UPDATE SET
            A.ADDL_EXCESS = B.ADDL_EXCESS,
            A.VOLUNTARY_EXCESS = B.VOLUNTARY_EXCESS,
            A.COMPULSORY_EXCESS = B.COMPULSORY_EXCESS, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;

END;

BEGIN

v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM A
           USING (  SELECT DISTINCT CLM_REF,
                           MAX (
                              CASE
                                 WHEN R_RESERVE_GROUP_DESC = ''''Expense''''
                                 THEN
                                    TRANS_DATE
                              END)
                              EXPENSE_APP_DATE
                      FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES AA,
                      ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.CLM_TRANS A,
                      TRANSACTIONAL.ODS_RESERVE_DIM B
                     WHERE     AA.CLAIM_ID = A.CLAIM_ID
                           AND SF_TOTAL_TYPE = R_RESERVE_TYPE
                           AND A.CLM_STATUS = ''''AP''''
                           AND DATE_TRUNC(''''DAY'''', TRANS_DATE) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''')) - 2
                                                      AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1
                    -- HAVING MAX (
                    --           CASE
                    --              WHEN R_RESERVE_GROUP_DESC = ''''Expense''''
                    --              THEN
                    --                 TRANS_DATE
                    --           END)
                    --           IS NOT NULL
                  GROUP BY CLM_REF
                HAVING MAX(
                   CASE
                       WHEN R_RESERVE_GROUP_DESC = ''''Expense'''' THEN TRANS_DATE
                   END
               ) IS NOT NULL) I
              ON (C_CLAIM_NO = I.CLM_REF)
      WHEN MATCHED
      THEN
         UPDATE SET EXPENSE_APP_DATE = I.EXPENSE_APP_DATE, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
                 --WHERE CLM_REF = C_CLAIM_NO'';
EXECUTE IMMEDIATE v_sqltext;

END;

BEGIN

v_sqltext := ''MERGE INTO  TRANSACTIONAL.ODS_CLAIM_DIM A
           USING (  SELECT DISTINCT CLM_REF,
                           MAX (
                              CASE
                                 WHEN R_RESERVE_GROUP_DESC = ''''Loss''''
                                 THEN
                                    TRANS_DATE
                              END)
                              LOSS_APP_DATE
                      FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES AA,
                      ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.CLM_TRANS A,
                      TRANSACTIONAL.ODS_RESERVE_DIM B
                     WHERE     AA.CLAIM_ID = A.CLAIM_ID
                           AND SF_TOTAL_TYPE = R_RESERVE_TYPE
                           AND A.CLM_STATUS = ''''AP''''
                           AND DATE_TRUNC(''''DAY'''', TRANS_DATE) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''')) - 2
                                                      AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1
                    -- HAVING MAX ()
                    --           CASE
                    --              WHEN R_RESERVE_GROUP_DESC = ''''Loss''''
                    --              THEN
                    --                 TRANS_DATE
                    --           END)
                    --           IS NOT NULL
                  GROUP BY CLM_REF
                  HAVING MAX (
                              CASE
                                 WHEN R_RESERVE_GROUP_DESC = ''''Loss''''
                                 THEN
                                    TRANS_DATE
                              END)
                              IS NOT NULL) I
              ON (C_CLAIM_NO = I.CLM_REF)
      WHEN MATCHED
      THEN
         UPDATE SET LOSS_APP_DATE = I.LOSS_APP_DATE, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
                 --WHERE CLM_REF = C_CLAIM_NO'';
EXECUTE IMMEDIATE v_sqltext;

END;

 -------------for motor ------


   --   EXECUTE IMMEDIATE ''''truncate table wrk_psr_fsr_update'''';
   --
   --   INSERT INTO WRK_PSR_FSR_UPDATE
   --        SELECT A.CLAIM_ID,
   --               A.CLM_REF,
   --               MIN (
   --                  CASE
   --                     WHEN TRIM (SUB_STATUS) IN (33)
   --                     THEN
   --                        TO_DATE (A.RECORD_DATE)
   --                  END)
   --                  PSR_GENERATED,
   --               MAX (
   --                  CASE
   --                     WHEN TRIM (SUB_STATUS) IN (34)
   --                     THEN
   --                        TO_DATE (A.RECORD_DATE)
   --                  END)
   --                  FSR_GENERATED
   --          FROM BJAZ_HUB_CLM_TRANS_DTLS_MV A, ODS_CLAIM_DIM D
   --         WHERE     PARTITION_STATUS = ''''C''''
   --               AND A.CLM_REF = D.C_CLAIM_NO
   --               AND C_CLO_DATE BETWEEN TRUNC (SYSDATE - 2)
   --                                  AND TRUNC (SYSDATE - 1)
   --               AND D.C_CLAIM_STATUS = ''''CLOSED''''
   --      -- and clm_ref = ''''OC-17-2401-1801-00022312''''
   --      GROUP BY A.CLAIM_ID, A.CLM_REF
   --        HAVING     MIN (
   --                      CASE
   --                         WHEN TRIM (SUB_STATUS) IN (33)
   --                         THEN
   --                            TO_DATE (A.RECORD_DATE)
   --                      END) <> MAX (NVL (C_RECPT_PSR_DATE, ''''1-jan-1990''''))
   --               AND MAX (
   --                      CASE
   --                         WHEN TRIM (SUB_STATUS) IN (34)
   --                         THEN
   --                            TO_DATE (A.RECORD_DATE)
   --                      END) <> MAX (NVL (C_RECPT_FSR_DATE, ''''1-jan-1990''''));
   --
   --
   --
   --
   --   BEGIN
   --      MERGE INTO ODS_CLAIM_DIM
   --           USING (SELECT *
   --                    FROM WRK_PSR_FSR_UPDATE
   --                   WHERE    PSR_GENERATED IS NOT NULL
   --                         OR FSR_GENERATED IS NOT NULL)
   --              ON (C_CLAIM_NO = CLM_REF)
   --      WHEN MATCHED
   --      THEN
   --         UPDATE SET
   --            C_RECPT_PSR_DATE = PSR_GENERATED,
   --            C_RECPT_FSR_DATE = FSR_GENERATED;
   --
   --
   --   END;

BEGIN

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_TPA_STATUS = ''''Y'''', ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT CLM_REF
               FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_BASE_MOT_EXT A,
               ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
              WHERE     TP_CLAIM = ''''Y''''
                    AND A.CLAIM_ID = B.CLAIM_ID
                    AND DATE_REPORTED BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 7)
                                          AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';


EXECUTE IMMEDIATE v_sqltext;

--Below condition is changed from 2 to 7
-- DATE_REPORTED BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 2)


END;

BEGIN

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_CLAIM_REGD_BY = src.UPDATED_BY, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT CLM_REF, UPDATED_BY
               FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_HM_CLAIM_TRACKER A,
               ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
              WHERE     A.CLAIM_ID = B.CLAIM_ID
                    AND DATE_TRUNC(''''DAY'''', DATE_REPORTED) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''')) - 2
                                                  AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1
                    AND VERSION_NO = 1) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;


END;

--Identical Code as Above --sarvesh

--BEGIN
--UPDATE INTERMEDIATE.ODS_CLAIM_DIM as target
--            SET C_CLAIM_REGD_BY = src.UPDATED_BY
--FROM (SELECT CLM_REF, UPDATED_BY
--               FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_HM_CLAIM_TRACKER A,
--               ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
--              WHERE     A.CLAIM_ID = B.CLAIM_ID
--                    AND DATE_TRUNC(''''DAY'''', UPDATED_ON) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''')) - 2
--                                               AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1
--                    AND VERSION_NO = 1) AS src
--WHERE C_CLAIM_NO = src.CLM_REF;
--
--END;

CALL TRANSACTIONAL.WRK_CLAIM_REG_BY_UPDATE(''BAGIC_PROD_MIRROR_DB'');

--------------------net_access_amt and dep_amt

   --
   --   BEGIN
   --      MERGE INTO ODS_CLAIM_DIM A
   --           USING (  SELECT /*+ parallel (10)*/
   --                          Z.CLM_REF,
   --                           SUM (TOTAL_PARTS_LABOURS) TOTAL_PARTS_LABOURS
   --                      FROM BJAZ_CLM_SUPP_BASES_MV Y, CLM_BASES Z
   --                     WHERE     DATE_REPORTED BETWEEN TRUNC (SYSDATE - 4)
   --                                                 AND TRUNC (SYSDATE - 1)
   --                           AND Y.CLAIM_ID = Z.CLAIM_ID
   --                           AND TOTAL_PARTS_LABOURS IS NOT NULL
   --                  GROUP BY Z.CLM_REF) B
   --              ON (A.C_CLAIM_NO = B.CLM_REF)
   --      WHEN MATCHED
   --      THEN
   --         UPDATE SET NET_ASSESSED_AMOUNT = B.TOTAL_PARTS_LABOURS;
   --
   --
   --   END;


BEGIN

v_sqltext := ''MERGE INTO  TRANSACTIONAL.ODS_CLAIM_DIM A
           USING (  SELECT DISTINCT
                          Z.CLM_REF, SUM (DEPRECIATION_AMT) DEPRECIATION_AMT
                      FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_SUPP_BILL_PARTS X,
                      ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES Z
                     WHERE     DATE_REPORTED BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 4)
                                                 AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
                           AND X.CLAIM_ID = Z.CLAIM_ID
                           AND DEPRECIATION_AMT IS NOT NULL
                  GROUP BY Z.CLM_REF) B
              ON (A.C_CLAIM_NO = B.CLM_REF)
    WHEN MATCHED
      THEN
         UPDATE SET DEPRECIATION_AMOUNT = B.DEPRECIATION_AMT, ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;


END;


--added chandrakant(logic gieven by fareen Maam) 13-mar-2019

   BEGIN

v_sqltext := ''TRUNCATE TABLE INTERMEDIATE.WRK_NET_ASSIST_AMT'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_NET_ASSIST_AMT
         SELECT A.CLM_REF,
                A.CLAIM_ID,
                NET_ASSES_AMT_PARTS_LABOUR,
                DEP_AMT
           FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES A, ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_SURVEYOR_ASS_DTLS X, TRANSACTIONAL.ODS_CLAIM_DIM C
          WHERE     A.CLAIM_ID = X.CLAIM_ID
                AND CLM_REF = C_CLAIM_NO
                AND NVL (TO_NUMBER(UTILS.CLEAN_NUMBER(NET_ASSESSED_AMOUNT)), 0) <>
                       NVL (TO_NUMBER (NET_ASSES_AMT_PARTS_LABOUR), 0)'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM A
           USING (SELECT distinct * FROM INTERMEDIATE.WRK_NET_ASSIST_AMT) B
              ON (A.C_CLAIM_NO = B.CLM_REF)
      WHEN MATCHED
      THEN
         UPDATE SET
            A.NET_ASSESSED_AMOUNT = TRY_TO_NUMBER (B.NET_ASSES_AMT_PARTS_LABOUR, 38, 10),
            A.DEPRECIATION_AMOUNT = TRY_TO_NUMBER (B.DEP_AMT, 38, 10), ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;

END;





-- BEGIN
--       MERGE INTO INTERMEDIATE.ODS_CLAIM_DIM A
--            USING (  SELECT /*+leading (x,a) */
--                           A.CLM_REF,
--                            A.CLAIM_ID,
--                            NET_ASSES_AMT_PARTS_LABOUR,
--                            DEP_AMT,
--                            MAX (VERSION_NO) VERSION_NO
--                       FROM INTERMEDIATE.WRK_DAILY_HUB_CLM A,
--                       ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_SURVEYOR_ASS_DTLS X
--                      WHERE A.CLAIM_ID = X.CLAIM_ID
--                   -- AND STATUS = 7
--                   --AND SUB_STATUS IN (33, 34)
--                   GROUP BY A.CLM_REF,
--                            A.CLAIM_ID,
--                            NET_ASSES_AMT_PARTS_LABOUR,
--                            DEP_AMT) B
--               ON (A.C_CLAIM_NO = B.CLM_REF)
--       WHEN MATCHED
--       THEN
--          UPDATE SET
--             A.NET_ASSESSED_AMOUNT = TO_NUMBER (B.NET_ASSES_AMT_PARTS_LABOUR),
--             A.DEPRECIATION_AMOUNT = TO_NUMBER (B.DEP_AMT);

--
--    END;


-------------------net_assess_amt for white goods*
BEGIN

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET NET_ASSESSED_AMOUNT = src.NET_ASSESSED_AMT, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (  SELECT
                     B.CLM_REF, SUM (NET_ASSESSED_AMT) NET_ASSESSED_AMT
                 FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_WG_SUPP_BILL_PARTS A,
                 ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
                WHERE     TOP_INDICATOR = ''''Y''''
                      AND A.CLAIM_ID = B.CLAIM_ID
                      AND DATE_TRUNC(''''DAY'''', UPDATED_DATE) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 2)
                                                   AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)
             GROUP BY B.CLM_REF) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

END;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.wrk_hat_portal_flag'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_HAT_PORTAL_FLAG
      SELECT
            DISTINCT B.CLAIM_ID, ''''WEB_SERVICE'''' PORTAL_FLAG
        FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_REMEDINET_CLAIM_DETAILS A,
        ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
       WHERE     NVL (A.CLAIM_ID, 0) <> 0
             AND A.CLAIM_ID = B.CLAIM_ID
             AND DATE_REPORTED >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 2
             AND TOP_INDICATOR = ''''Y''''
      UNION
      SELECT DISTINCT
             B.CLAIM_ID,
             CASE
                WHEN UPDATED_BY = ''''insurancewallet.hat@bajajallianz.co.in''''
                THEN
                   ''''CARINGLY_YOURS_APP''''
                WHEN UPDATED_BY = ''''ecardportal@bajajallianz.com''''
                THEN
                   '''' ECARD_CDC_PORTAL''''
                WHEN UPDATED_BY = ''''healthclaimintimation@bajajallianz.co.in''''
                THEN
                   ''''ONLINE_CLAIM_INTIMATION''''
             END
                PORTAL_FLAG
        FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_HM_CLAIM_TRACKER A,
        ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
       WHERE     VERSION_NO = 1
             AND A.CLAIM_ID = B.CLAIM_ID
             AND DATE_REPORTED >= DATE_TRUNC(''''DAY'''',TO_DATE('''''' || T_DATE || '''''')) - 2
             AND CASE
                    WHEN UPDATED_BY =
                            ''''insurancewallet.hat@bajajallianz.co.in''''
                    THEN
                       ''''CARINGLY_YOURS_APP''''
                    WHEN UPDATED_BY = ''''ecardportal@bajajallianz.com''''
                    THEN
                       '''' ECARD_CDC_PORTAL''''
                    WHEN UPDATED_BY =
                            ''''healthclaimintimation@bajajallianz.co.in''''
                    THEN
                       ''''ONLINE_CLAIM_INTIMATION''''
                 END
                    IS NOT NULL
      UNION
      SELECT DISTINCT C.CLAIM_ID, ''''IMD_PORTAL'''' PORTAL_FLAG
        FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_HM_CLAIM_TRACKER A,
        ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES C,
        ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_HM_CLM_REGISTER D
       WHERE     A.CLAIM_ID = C.CLAIM_ID
             AND A.CLAIM_ID = D.CLAIM_ID
             AND SUBSTR(A.UPDATED_BY, REGEXP_INSTR(A.UPDATED_BY, ''''@'''', 1, LENGTH(A.UPDATED_BY) - LENGTH(REPLACE(A.UPDATED_BY, ''''@'''', '''''''')) + 1) + 1) LIKE
                    ''''general%''''
             AND A.VERSION_NO = 1
             AND A.UPDATED_ON >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 2)
      UNION
      SELECT DISTINCT B.CLAIM_ID, ''''FTP_LOADER_FLAG''''
        FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_HM_COINSU_CLM_DTLS A,
        ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
       WHERE A.CLAIM_ID = B.CLAIM_ID AND DATE_REPORTED >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 2
      UNION
      SELECT DISTINCT B.CLAIM_ID, ''''FTP_LOADER_FLAG''''
        FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_TPA_CLAIM_DETAILS_WS A, ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
       WHERE     TOP_INDICATOR = ''''Y''''
             AND B.CLAIM_ID = A.BJAZ_CLAIM_ID
             AND DATE_REPORTED >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 2
      UNION
      SELECT DISTINCT
             B.CLAIM_ID,
             CASE
                WHEN CLID_HPMS IS NOT NULL THEN ''''HCM_PORTAL''''
                ELSE ''''HOSPITAL_PORTAL''''
             END
        FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_HM_PREAUTH_QUERY A,
             ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_HM_CLM_REGISTER B,
             ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_HM_PREAUTH_ENHANCE C,
             ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES D
       WHERE     A.CLID = CLID_HPMS
             AND A.CLID = C.CLID(+)
             AND B.CLAIM_ID = D.CLAIM_ID
             AND DATE_REPORTED >= DATE_TRUNC(''''DAY'''',TO_DATE('''''' || T_DATE || '''''')) - 2'';
EXECUTE IMMEDIATE v_sqltext;

EXECUTE IMMEDIATE ''COMMIT'';

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.wrk_motor_portal_flag'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_MOTOR_PORTAL_FLAG
 WITH CTE AS (
            SELECT CB.CLM_REF, COUNT(1) AS MOTCLM_COUNT
            FROM ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_WS_MOTCLM_DETAILS WS
            JOIN ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.CLM_BASES CB
              ON WS.CLM_REF = CB.CLM_REF
            WHERE TOP_INDICATOR = ''''Y''''
            GROUP BY CB.CLM_REF
        )

      SELECT *
        FROM (  SELECT
                      C_CLAIM_ID,
                       MAX (
                          CASE

                            WHEN MODULE_FLAG = ''''HYUNDAI_NEW''''
                             THEN
                                ''''HYUNDAI_WEBSERVICE''''

                             WHEN MODULE_FLAG = ''''CUST''''
                             THEN
                                ''''CUSTOMER_PORTAL''''

                            WHEN MODULE_FLAG = ''''EEZEETAB''''
                             THEN
                                ''''EEZEETAB''''

                            when C_CLAIM_REGD_BY =''''AEM_CLAIM''''

                                THEN  ''''WEBSITE''''
                                WHEN MODULE_FLAG = ''''HERO''''
                             THEN
                               ''''HERO WEBSERVICE''''
                                 WHEN MODULE_FLAG = ''''WindShield''''
                             THEN
                                ''''WINDSHIELD WEBSERVICE''''

                             WHEN    MODULE_FLAG = ''''REP''''
                                  OR USERNAME LIKE ''''%rep@repairer%''''
                                  OR USERNAME LIKE ''''%rep01@repairer%''''
                             THEN
                                ''''REPAIRER_PORTAL''''

                             WHEN    C_CLAIM_REGD_BY LIKE ''''%rep@repairer%''''
                                  OR C_CLAIM_REGD_BY LIKE ''''%rep01@repairer%''''
                             THEN
                                ''''REPAIRER_PORTAL''''
                             WHEN USERNAME =
                                     ''''ald.automotive@onlineclaimsportal.com''''
                             THEN
                                ''''ALD_PORTAL''''
                             WHEN USERNAME =
                                     ''''maruticlaims.ws@bajajallianz.co.in''''
                             THEN
                                ''''MIDS_WEBSERVICE''''

                             WHEN MODULE_FLAG = ''''INSURANCE WALLET''''
                             THEN
                                ''''INSURANCE_WALLET''''
                             WHEN MODULE_FLAG = ''''IMD''''
                             THEN
                                ''''IMD_PORTAL''''

                             WHEN MODULE_FLAG = ''''AEM_CLAIM''''
                             THEN
                                ''''WEBSITE''''

                             WHEN (   MODULE_FLAG = ''''OLA''''
                                   OR MODULE_FLAG = ''''OLA_NEW'''')
                             THEN
                                ''''OLA_WEBSERVICE''''
                             WHEN MODULE_FLAG IN (''''CHATPORT'''', ''''CHATBOT'''')
                             THEN
                                ''''CHATBOT''''

                             WHEN MODULE_FLAG = ''''HONDA''''
                             THEN
                                ''''HONDA_WEBSERVICE''''
                             WHEN MODULE_FLAG = ''''FORD''''
                             THEN
                                ''''FORD_WEBSERVICE''''

                             WHEN MODULE_FLAG = ''''DFS''''
                             THEN
                                ''''DFS_WEBSERVICE''''
                             WHEN MODULE_FLAG = ''''BMW''''
                             THEN
                                ''''BMW_WEBSERVICE''''

                             WHEN     MODULE_FLAG = ''''HYUNDAI''''
                                  AND C_CLAIM_REGD_BY =
                                         ''''HIIB.WS@BAJAJALLIANZ.CO.IN''''
                             THEN
                                ''''HIIB_WEBSERVICE''''
                             WHEN     MODULE_FLAG = ''''HYUNDAI''''
                                  AND C_CLAIM_REGD_BY <>
                                         ''''HIIB.WS@BAJAJALLIANZ.CO.IN''''
                             THEN
                                ''''HYUNDAI_ABIBL_WEBSERVICE''''

                             WHEN MODULE_FLAG = ''''TOYOTA''''
                             THEN
                                ''''TOYOTA_WEBSERVICE''''
                             WHEN MODULE_FLAG = ''''MAHINDRA''''
                             THEN
                                '''' MAHINDRA_WEBSERVICE''''
                             WHEN MODULE_FLAG = ''''CITROEN''''
                             THEN
                                ''''CITROEN_WEBSERVICE''''
                             WHEN MODULE_FLAG = ''''MG''''
                             THEN
                                ''''MG_WEBSERVICE''''

                             WHEN (   USERNAME =
                                         ''''maruticlaims.ws@bajajallianz.co.in''''
                                   OR C_CLAIM_REGD_BY =
                                         ''''maruticlaims.ws@bajajallianz.co.in'''')
                             THEN
                                ''''MIDS_WEBSERVICE''''

                             WHEN MODULE_FLAG = ''''TATA''''
                             THEN
                                ''''TATA_WEBSERVICE''''

                             WHEN MODULE_FLAG = ''''KIA''''

                             THEN

                               ''''KIA_WEBSERVICE''''

                             WHEN M.CLM_REF IS NOT NULL

                             THEN

                               ''''KIA_WEBSERVICE''''

                            WHEN

                           USERNAME like ''''kiaclaims.ws%''''
                           THEN ''''KIA_WEBSERVICE''''

                             WHEN MODULE_FLAG = ''''JIP''''
                             THEN
                                ''''JIP_WEBSERVICE''''

                             WHEN MODULE_FLAG = ''''VOLVO''''
                             THEN
                                ''''VOLVO_WEBSERVICE''''
                             WHEN MODULE_FLAG = ''''YAMAHA''''
                             THEN
                                ''''YAMAHA_WEBSERVICE''''
                             WHEN MODULE_FLAG = ''''AL''''
                             THEN
                                ''''ASHOK_LEYLAND_WEBSERVICE''''

                             WHEN MODULE_FLAG = ''''PB_NEW''''
                             THEN
                                ''''PB_NEW_WEBSERVICE''''
                             WHEN MODULE_FLAG = ''''RE''''
                             THEN
                                ''''ROYAL_ENFIELD_WEBSERVICE''''
                            WHEN MODULE_FLAG = ''''JL''''
                             THEN
                                ''''JCB_WEBSERVICE''''
							WHEN UPPER(MODULE_FLAG) = ''''AUDI''''
                             THEN
                                ''''AUDI_WEBSERVICE''''

                            WHEN MODULE_FLAG = ''''VOLKSWAGEN''''
                             THEN
                                ''''VOLKSWAGEN_WEBSERVICE''''

                            WHEN MODULE_FLAG = ''''SKODA''''
                             THEN
                                ''''SKODA_WEBSERVICE''''

                            WHEN MODULE_FLAG = ''''AUDI''''
                             THEN
                                ''''AUDI_WEBSERVICE''''

                            WHEN MODULE_FLAG = ''''LEXUS''''
                             THEN
                                ''''LEXUS_WEBSERVICE''''

                            WHEN MODULE_FLAG = ''''SML ISUZU''''
                             THEN
                                ''''SML ISUZU_WEBSERVICE''''

                            WHEN MODULE_FLAG = ''''BOOM''''
                             THEN
                                ''''BOOM_WEBSERVICE''''

                            WHEN MODULE_FLAG = ''''PURE EV''''
                             THEN
                                ''''PURE EV_WEBSERVICE''''

                            WHEN MODULE_FLAG = ''''HERO ELECTRIC''''
                             THEN
                                ''''HERO ELECTRIC_WEBSERVICE''''

                            WHEN MODULE_FLAG = ''''WEB''''
                             THEN
                                ''''WEB''''
                            WHEN MODULE_FLAG = ''''REPAIRER WALLET''''
                             THEN
                                ''''REPAIRER_PORTAL''''

                            WHEN MODULE_FLAG = ''''INSURANCE%20WALLET''''
                             THEN
                                ''''INSURANCE_WALLET''''
                            WHEN MODULE_FLAG = ''''VOICEBOT''''
                             THEN
                                ''''VOICEBOT''''

                            WHEN C1.MOTCLM_COUNT > 0
                             THEN
                                ''''MIDS_WEBSERVICE''''

                             ELSE
                                ''''CALL_CENTER''''
                          END)
                          MODULE_FLAGGS
                  FROM TRANSACTIONAL.ODS_CLAIM_DIM X,
                      ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_ONLINE_CLAIM_DTLS A,
                       PROD_DWH_MIGRATED_DB.STAGE.GEN_CLM_USERID_MV B,
                       ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_BASE_MOT_EXT C,
                       ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_BASE_MOT_EXT D,
                       ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_WS_KIA_CLAIM_DTLS M,
                       CTE C1
    WHERE     X.C_CLAIM_ID = A.CLAIM_ID(+)
                       AND X.C_CLAIM_NO = B.CLM_REF(+)
                       AND X.C_CLAIM_ID = C.CLAIM_ID(+)
                       AND X.C_CLAIM_ID = D.CLAIM_ID(+)
                       AND X.C_CLAIM_NO = M.CLM_REF(+)
                       AND C1.CLM_REF(+) = X.C_CLAIM_NO
                       AND DATE_TRUNC(''''DAY'''',C_REGN_DATE) >= DATE_TRUNC(''''DAY'''',TO_DATE('''''' || T_DATE || '''''')) - 2
                       AND NOT EXISTS
                              (SELECT 1
                                 FROM INTERMEDIATE.WRK_HAT_PORTAL_FLAG
                                WHERE CLAIM_ID = X.C_CLAIM_ID)
              GROUP BY C_CLAIM_ID)
       WHERE C_CLAIM_ID IS NOT NULL'';
EXECUTE IMMEDIATE v_sqltext;

-- v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_MOTOR_PORTAL_FLAG
-- SELECT *
-- FROM (
--     SELECT X.C_CLAIM_ID,
--            MAX(CASE
--                  WHEN MODULE_FLAG = ''''CUST'''' THEN ''''CUSTOMER_PORTAL''''
--                  WHEN MODULE_FLAG = ''''REP'''' OR USERNAME LIKE ''''%rep@repairer%'''' OR USERNAME LIKE ''''%rep01@repairer%'''' THEN ''''REPAIRER_PORTAL''''
--                  WHEN X.C_CLAIM_REGD_BY LIKE ''''%rep@repairer%'''' OR X.C_CLAIM_REGD_BY LIKE ''''%rep01@repairer%'''' THEN ''''REPAIRER_PORTAL''''
--                  WHEN USERNAME = ''''ald.automotive@onlineclaimsportal.com'''' THEN ''''ALD_PORTAL''''
--                  WHEN USERNAME = ''''maruticlaims.ws@bajajallianz.co.in'''' THEN ''''MIDS_WEBSERVICE''''
--                  WHEN MODULE_FLAG = ''''INSURANCE WALLET'''' THEN ''''INSURANCE_WALLET''''
--                  WHEN MODULE_FLAG = ''''IMD'''' THEN ''''IMD_PORTAL''''
--                  WHEN MODULE_FLAG = ''''AEM_CLAIM'''' THEN ''''WEBSITE''''
--                  -- Use the MOTCLM_COUNT from the CTE
--                  WHEN (SELECT COUNT (1)
--                                      FROM ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_WS_MOTCLM_DETAILS
--                                     WHERE     CLM_REF =
--                                                  (SELECT CLM_REF
--                                                     FROM  ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.CLM_BASES
--                                                    WHERE CLAIM_ID =
--                                                             X.C_CLAIM_ID)
--                                           AND TOP_INDICATOR = ''Y'') > 0 THEN ''''MIDS_WEBSERVICE''''
--                  -- Continue with other conditions...
--                  ELSE ''''CALL_CENTER''''
--                END) AS MODULE_FLAGGS
--                FROM TRANSACTIONAL.ODS_CLAIM_DIM X,
--                     ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_ONLINE_CLAIM_DTLS A,
--                        PROD_DWH_MIGRATED_DB.STAGE.GEN_CLM_USERID_MV B,
--                        ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_BASE_MOT_EXT C,
--                        ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_BASE_MOT_EXT D,
--                        ''|| MIRROR_DB||''.OPUS_GG_DWHSTAGE.BJAZ_WS_KIA_CLAIM_DTLS M
--     WHERE     X.C_CLAIM_ID = A.CLAIM_ID(+)
--                        AND X.C_CLAIM_NO = B.CLM_REF(+)
--                        AND X.C_CLAIM_ID = C.CLAIM_ID(+)
--                        AND X.C_CLAIM_ID = D.CLAIM_ID(+)
--                        AND X.C_CLAIM_NO = M.CLM_REF(+)
--                        AND DATE_TRUNC(''''DAY'''',C_REGN_DATE) >= DATE_TRUNC(''''DAY'''',TO_DATE('''''' || T_DATE || '''''')) - 2
--                        AND NOT EXISTS
--                               (SELECT 1
--                                  FROM INTERMEDIATE.WRK_HAT_PORTAL_FLAG
--                                 WHERE CLAIM_ID = X.C_CLAIM_ID)
--               GROUP BY C_CLAIM_ID)
--        WHERE C_CLAIM_ID IS NOT NULL);
-- EXECUTE IMMEDIATE v_sqltext;


BEGIN

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.STG_CLM_PORTAL_FLAG'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.STG_CLM_PORTAL_FLAG
         SELECT A.*, CLM_REF
           FROM INTERMEDIATE.WRK_HAT_PORTAL_FLAG A,
           ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
          WHERE A.CLAIM_ID = B.CLAIM_ID
         UNION
         SELECT A.*, CLM_REF
           FROM INTERMEDIATE.WRK_MOTOR_PORTAL_FLAG A, ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
          WHERE A.CLAIM_ID = B.CLAIM_ID'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''DELETE FROM INTERMEDIATE.STG_CLM_PORTAL_FLAG
            WHERE CLM_REF IN (  SELECT CLM_REF
                                  FROM INTERMEDIATE.STG_CLM_PORTAL_FLAG
                              GROUP BY CLM_REF
                                HAVING COUNT (*) > 1)'';
EXECUTE IMMEDIATE v_sqltext;




v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_PORTAL_FLAG = src.PORTAL_FLAG, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT * FROM INTERMEDIATE.STG_CLM_PORTAL_FLAG) AS src
WHERE C_CLAIM_ID = src.CLAIM_ID
          AND C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

END;

---ADDED BY CHANDRAKANT (18-MAR-2021)
BEGIN

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_WEBSERVICE_PORTAL_FLAG'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_WEBSERVICE_PORTAL_FLAG
         SELECT A.CLM_REF, ''''KIA_WEBSERVICE''''
           FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_WS_KIA_CLAIM_DTLS A,
           ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
          WHERE     A.CLM_REF = B.CLM_REF
                AND DATE_TRUNC(''''DAY'''', DATE_REPORTED) >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 10
                AND A.CLM_REF IS NOT NULL'';
EXECUTE IMMEDIATE v_sqltext;


--  INSERT INTO WRK_WEBSERVICE_PORTAL_FLAG
--   SELECT /*+PARALLEL(A,10)*/
--   DISTINCT A.CLAIM_NO, ''''ASHOK_LEYLAND_WEBSERVICE''''
--   FROM BJAZ_HONDA_WS_RESPONSE_MV A, CLM_BASES B
--   WHERE     A.CLAIM_NO = B.CLM_REF
--   AND TRUNC (DATE_REPORTED) >= TRUNC (SYSDATE) - 2
--   AND METHOD_TYPE = ''''ALClaimIntimationIc'''';


BEGIN

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_PORTAL_FLAG = src.PORTAL_FLAG, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT * FROM INTERMEDIATE.WRK_WEBSERVICE_PORTAL_FLAG) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

END;

END;


BEGIN

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_PORTAL_FLAG = src.PORTAL_FLAG, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT CLM_REF,
                    CASE
                       WHEN UPPER (USER_NAME) = ''''BAGIC_WEBSITE''''
                       THEN
                          ''''BAGIC_WEBSITE''''
                       WHEN UPPER (USER_NAME) = ''''BAGIC_NMCMRN_PORTAL''''
                       THEN
                          ''''BAGIC_NMCMRN_PORTAL''''
                       WHEN UPPER (USER_NAME) = ''''CARINGLY YOURS''''
                       THEN
                          ''''CARINGLY_YOURS''''
                       WHEN UPPER (USER_NAME) = ''''ONLINE''''
                       THEN
                          ''''ONLINE''''
                       WHEN UPPER (USER_NAME) = ''''BOING''''
                       THEN
                          ''''BOING''''
                    END
                       PORTAL_FLAG
               FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY A,
               ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
              WHERE     A.CLAIM_ID = B.CLAIM_ID
                    AND UPPER (USER_NAME) IN
                           (''''BAGIC_WEBSITE'''',
                            ''''BAGIC_NMCMRN_PORTAL'''',
                            ''''CARINGLY YOURS'''',
                            ''''ONLINE'''',
                            ''''BOING'''')
                    AND DATE_TRUNC(''''DAY'''', MSG_DATE) >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 5
                    AND VERSION_NO = 1
                    AND CASE
                           WHEN LENGTH (CLM_REF) = 23
                           THEN
                              SUBSTR (CLM_REF, 12, 3)
                           ELSE
                              SUBSTR (CLM_REF, 12, 4)
                        END IN
                           (''''301'''',
                            ''''302'''',
                            ''''303'''',
                            ''''304'''',
                            ''''305'''',
                            ''''401'''',
                            ''''402'''',
                            ''''410'''',
                            ''''411'''',
                            ''''412'''',
                            ''''415'''',
                            ''''420'''',
                            ''''421'''',
                            ''''425'''',
                            ''''426'''',
                            ''''427'''',
                            ''''428'''',
                            ''''451'''',
                            ''''1001'''',
                            ''''1002'''',
                            ''''1003'''',
                            ''''1004'''',
                            ''''1005'''',
                            ''''1006'''',
                            ''''1007'''',
                            ''''1008'''',
                            ''''1009'''',
                            ''''1011'''',
                            ''''1013'''',
                            ''''1015'''',
                            ''''1016'''',
                            ''''1017'''',
                            ''''1018'''',
                            ''''1020'''',
                            ''''1021'''',
                            ''''1022'''',
                            ''''1023'''',
                            ''''1024'''',
                            ''''1025'''',
                            ''''1026'''',
                            ''''1027'''',
                            ''''1028'''',
                            ''''1029'''',
                            ''''1040'''',
                            ''''1051'''',
                            ''''1052'''',
                            ''''1053'''',
                            ''''1054'''',
                            ''''1055'''',
                            ''''1056'''',
                            ''''1057'''',
                            ''''1061'''',
                            ''''1063'''',
                            ''''1065'''',
                            ''''1066'''',
                            ''''1067'''',
                            ''''1068'''',
                            ''''2801'''',
                            ''''2802'''',
                            ''''3301'''',
                            ''''3302'''',
                            ''''3303'''',
                            ''''3304'''',
                            ''''3305'''',
                            ''''3306'''',
                            ''''3307'''',
                            ''''3310'''',
                            ''''3311'''',
                            ''''3312'''',
                            ''''3313'''',
                            ''''3314'''',
                            ''''3315'''',
                            ''''3316'''',
                            ''''3317'''',
                            ''''3321'''',
                            ''''3322'''',
                            ''''3383'''',
                            ''''3393'''',
                            ''''3395'''',
                            ''''3396'''',
                            ''''3397'''',
                            ''''4001'''',
                            ''''4002'''',
                            ''''4003'''',
                            ''''4004'''',
                            ''''4005'''',
                            ''''4006'''',
                            ''''4007'''',
                            ''''4008'''',
                            ''''4010'''',
                            ''''4011'''',
                            ''''4012'''',
                            ''''4014'''',
                            ''''4018'''',
                            ''''4019'''',
                            ''''4022'''',
                            ''''4023'''',
                            ''''4024'''',
                            ''''4025'''',
                            ''''4026'''',
                            ''''4027'''',
                            ''''4028'''',
                            ''''4029'''',
                            ''''4030'''',
                            ''''4031'''',
                            ''''4032'''',
                            ''''4033'''',
                            ''''4034'''',
                            ''''4035'''',
                            ''''4036'''',
                            ''''4037'''',
                            ''''4038'''',
                            ''''4039'''',
                            ''''4040'''',
                            ''''4041'''',
                            ''''4042'''',
                            ''''4043'''',
                            ''''4044'''',
                            ''''4045'''',
                            ''''4046'''',
                            ''''4047'''',
                            ''''4048'''',
                            ''''4049'''',
                            ''''4050'''',
                            ''''4055'''',
                            ''''4056'''',
                            ''''4057'''',
                            ''''4058'''',
                            ''''4089'''',
                            ''''4090'''',
                            ''''4091'''',
                            ''''4092'''',
                            ''''4093'''',
                            ''''4094'''',
                            ''''4095'''',
                            ''''4096'''',
                            ''''4097'''',
                            ''''4098'''',
                            ''''4099'''',
                            ''''5001'''',
                            ''''5002'''',
                            ''''5003'''',
                            ''''5004'''',
                            ''''5005'''',
                            ''''5006'''',
                            ''''5007'''',
                            ''''5008'''',
                            ''''5009'''',
                            ''''5010'''',
                            ''''5011'''',
                            ''''5012'''',
                            ''''5019'''',
                            ''''6101'''',
                            ''''6601'''',
                            ''''6602'''',
                            ''''6603'''',
                            ''''6604'''',
                            ''''6605'''',
                            ''''6606'''',
                            ''''6607'''',
                            ''''6608'''',
                            ''''6611'''',
                            ''''6612'''',
                            ''''6615'''',
                            ''''6616'''',
                            ''''6617'''',
                            ''''6618'''',
                            ''''6620'''',
                            ''''6801'''',
                            ''''6802'''',
                            ''''6803'''',
                            ''''6804'''',
                            ''''6805'''',
                            ''''6999'''',
                            ''''9900'''',
                            ''''9920'''',
                            ''''9930'''',
                            ''''9931'''',
                            ''''9932'''',
                            ''''9933'''',
                            ''''9934'''',
                            ''''9935'''',
                            ''''9936'''',
                            ''''9937'''',
                            ''''9940'''',
                            ''''9960'''',
                            ''''9961'''',
                            ''''9962'''',
                            ''''9970'''')) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

END;

BEGIN

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_PORTAL_FLAG = src.PORTAL_FLAG, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT CLM_REF, ''''UDYAM_SEVA_PORTAL'''' PORTAL_FLAG
               FROM PROD_DWH_MIGRATED_DB.PROD.BJAZ_WB_CLM_STATUS_REPOSITORY A,
               ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
              WHERE     A.CLAIM_ID = B.CLAIM_ID
                    AND VERSION_NO = 1
                    AND DATE_TRUNC(''''DAY'''', MSG_DATE) >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 3
                    AND UPPER (STATUS_MSG) LIKE ''''%UDYAM_SEVA_PORTAL%''''
                    AND CASE
                           WHEN LENGTH (CLM_REF) = 23
                           THEN
                              SUBSTR (CLM_REF, 12, 3)
                           ELSE
                              SUBSTR (CLM_REF, 12, 4)
                        END IN
                           (''''301'''',
                            ''''302'''',
                            ''''303'''',
                            ''''304'''',
                            ''''305'''',
                            ''''401'''',
                            ''''402'''',
                            ''''410'''',
                            ''''411'''',
                            ''''412'''',
                            ''''415'''',
                            ''''420'''',
                            ''''421'''',
                            ''''425'''',
                            ''''426'''',
                            ''''427'''',
                            ''''428'''',
                            ''''451'''',
                            ''''1001'''',
                            ''''1002'''',
                            ''''1003'''',
                            ''''1004'''',
                            ''''1005'''',
                            ''''1006'''',
                            ''''1007'''',
                            ''''1008'''',
                            ''''1009'''',
                            ''''1011'''',
                            ''''1013'''',
                            ''''1015'''',
                            ''''1016'''',
                            ''''1017'''',
                            ''''1018'''',
                            ''''1020'''',
                            ''''1021'''',
                            ''''1022'''',
                            ''''1023'''',
                            ''''1024'''',
                            ''''1025'''',
                            ''''1026'''',
                            ''''1027'''',
                            ''''1028'''',
                            ''''1029'''',
                            ''''1040'''',
                            ''''1051'''',
                            ''''1052'''',
                            ''''1053'''',
                            ''''1054'''',
                            ''''1055'''',
                            ''''1056'''',
                            ''''1057'''',
                            ''''1061'''',
                            ''''1063'''',
                            ''''1065'''',
                            ''''1066'''',
                            ''''1067'''',
                            ''''1068'''',
                            ''''2801'''',
                            ''''2802'''',
                            ''''3301'''',
                            ''''3302'''',
                            ''''3303'''',
                            ''''3304'''',
                            ''''3305'''',
                            ''''3306'''',
                            ''''3307'''',
                            ''''3310'''',
                            ''''3311'''',
                            ''''3312'''',
                            ''''3313'''',
                            ''''3314'''',
                            ''''3315'''',
                            ''''3316'''',
                            ''''3317'''',
                            ''''3321'''',
                            ''''3322'''',
                            ''''3383'''',
                            ''''3393'''',
                            ''''3395'''',
                            ''''3396'''',
                            ''''3397'''',
                            ''''4001'''',
                            ''''4002'''',
                            ''''4003'''',
                            ''''4004'''',
                            ''''4005'''',
                            ''''4006'''',
                            ''''4007'''',
                            ''''4008'''',
                            ''''4010'''',
                            ''''4011'''',
                            ''''4012'''',
                            ''''4014'''',
                            ''''4018'''',
                            ''''4019'''',
                            ''''4022'''',
                            ''''4023'''',
                            ''''4024'''',
                            ''''4025'''',
                            ''''4026'''',
                            ''''4027'''',
                            ''''4028'''',
                            ''''4029'''',
                            ''''4030'''',
                            ''''4031'''',
                            ''''4032'''',
                            ''''4033'''',
                            ''''4034'''',
                            ''''4035'''',
                            ''''4036'''',
                            ''''4037'''',
                            ''''4038'''',
                            ''''4039'''',
                            ''''4040'''',
                            ''''4041'''',
                            ''''4042'''',
                            ''''4043'''',
                            ''''4044'''',
                            ''''4045'''',
                            ''''4046'''',
                            ''''4047'''',
                            ''''4048'''',
                            ''''4049'''',
                            ''''4050'''',
                            ''''4055'''',
                            ''''4056'''',
                            ''''4057'''',
                            ''''4058'''',
                            ''''4089'''',
                            ''''4090'''',
                            ''''4091'''',
                            ''''4092'''',
                            ''''4093'''',
                            ''''4094'''',
                            ''''4095'''',
                            ''''4096'''',
                            ''''4097'''',
                            ''''4098'''',
                            ''''4099'''',
                            ''''5001'''',
                            ''''5002'''',
                            ''''5003'''',
                            ''''5004'''',
                            ''''5005'''',
                            ''''5006'''',
                            ''''5007'''',
                            ''''5008'''',
                            ''''5009'''',
                            ''''5010'''',
                            ''''5011'''',
                            ''''5012'''',
                            ''''5019'''',
                            ''''6101'''',
                            ''''6601'''',
                            ''''6602'''',
                            ''''6603'''',
                            ''''6604'''',
                            ''''6605'''',
                            ''''6606'''',
                            ''''6607'''',
                            ''''6608'''',
                            ''''6611'''',
                            ''''6612'''',
                            ''''6615'''',
                            ''''6616'''',
                            ''''6617'''',
                            ''''6618'''',
                            ''''6620'''',
                            ''''6801'''',
                            ''''6802'''',
                            ''''6803'''',
                            ''''6804'''',
                            ''''6805'''',
                            ''''6999'''',
                            ''''9900'''',
                            ''''9920'''',
                            ''''9930'''',
                            ''''9931'''',
                            ''''9932'''',
                            ''''9933'''',
                            ''''9934'''',
                            ''''9935'''',
                            ''''9936'''',
                            ''''9937'''',
                            ''''9940'''',
                            ''''9960'''',
                            ''''9961'''',
                            ''''9962'''',
                            ''''9970'''')) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;





END;

BEGIN
v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET BASE_SUM_INSURED = src.SUM_INSURED, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT CLM_REF, SUM_INSURED
               FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES A,
               ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_POL_BASES B,
               ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_POLICY_SUMMARY C
              WHERE     A.CLAIM_ID = B.CLAIM_ID
                    AND B.POLICY_REF = C.POLICY_REF
                    AND DATE_REPORTED = DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 5)) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;


END;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_MLT_UPDATE'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_MLT_UPDATE
      SELECT B.P_POLICY_NUMBER,
             A.P_POLICY_NO_SK,
             C_CLAIM_NO,
             FROM_DATE,
             TO_DATE,
             YEAR,
             CASE
             WHEN C_LOSS_DATE BETWEEN FROM_DATE AND TO_DATE THEN YEAR
             END
                C_MLT_FLAG
        FROM PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_PREMIUM_FACT_LT A,
             PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM B,
             TRANSACTIONAL.MV_CLAIM_REGISTER C
       WHERE     A.P_POLICY_NO_SK = B.P_POLICY_NO_SK
             AND TOP_INDICATOR = ''''Y''''
             AND B.P_POLICY_NUMBER = C.P_POLICY_NUMBER
             AND P_CURRENT_INDICATOR = 1
             AND C.T_DATE_DESC >= DATE_TRUNC(''''DAY'''',TO_DATE('''''' || T_DATE || '''''')) - 5
             AND C_REGN_DATE >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 5
             AND CASE
                    WHEN C_LOSS_DATE BETWEEN FROM_DATE AND TO_DATE THEN YEAR
                 END
                    IS NOT NULL'';
EXECUTE IMMEDIATE v_sqltext;


BEGIN

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_MLT_YEAR = src.YEAR, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT A.C_CLAIM_NO, YEAR
                  FROM  TRANSACTIONAL.ODS_CLAIM_DIM A, INTERMEDIATE.WRK_MLT_UPDATE B
                 WHERE A.C_CLAIM_NO = B.C_CLAIM_NO) AS src
WHERE target.C_CLAIM_NO = src.C_CLAIM_NO'';
EXECUTE IMMEDIATE v_sqltext;


END;

BEGIN

v_sqltext := ''TRUNCATE TABLE IF EXISTS select count(*) from INTERMEDIATE.WRK_C_DRI_LIC_NO'';

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_C_DRI_LIC_NO
         SELECT
               C_CLAIM_NO, DL_NO
           FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_SUPP_BASES A,
           TRANSACTIONAL.ODS_CLAIM_DIM B
          WHERE     A.CLAIM_REF = C_CLAIM_NO
                AND NVL(TO_VARCHAR(DL_NO), ''''0'''') <> NVL(TO_VARCHAR(C_DRI_LIC_NO), ''''0'''')
                AND DATE_TRUNC(''''DAY'''', SURVEY_DATE) >= DATE_TRUNC(''''DAY'''',TO_DATE('''''' || T_DATE || '''''')) - 5'';
EXECUTE IMMEDIATE v_sqltext;

END;

BEGIN

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_DRI_LIC_NO = src.DL_NO, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT * FROM INTERMEDIATE.WRK_C_DRI_LIC_NO) AS src
WHERE target.C_CLAIM_NO = src.C_CLAIM_NO'';
EXECUTE IMMEDIATE v_sqltext;

END;

BEGIN


v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_EW_CAUSE_OF_LOSS'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_EW_CAUSE_OF_LOSS
           SELECT C_CLAIM_NO,
       A.CASUSE_OF_LOSS,
       UPPER(DESCRIPTION) AS C_CAUSE_OF_LOSS
FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_WG_INSPECTION_DTLS A
JOIN ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES A1
    ON A.CLAIM_ID = A1.CLAIM_ID
JOIN TRANSACTIONAL.ODS_CLAIM_DIM B
    ON CLM_REF = C_CLAIM_NO
JOIN ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CC_V_CAUSE_OF_LOSSES C
    ON NVL(A.CASUSE_OF_LOSS, A1.COL_CODE) = C.COL_CODE AND
     SULA_ORA_NLS_CODE = ''''US''''
WHERE UPPER(DESCRIPTION) <> C_CAUSE_OF_LOSS
  AND DATE_TRUNC(''''DAY'''', UPDATED_DATE) >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 5
GROUP BY C_CLAIM_NO, CASUSE_OF_LOSS, UPPER(DESCRIPTION)'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_CAUSE_OF_LOSS = src.C_CAUSE_OF_LOSS, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT A.*
                  FROM INTERMEDIATE.WRK_EW_CAUSE_OF_LOSS A) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

END;

BEGIN

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_LOSS_DATE_BACKDATED'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_LOSS_DATE_BACKDATED
SELECT
                           CLM_REF, DATE_OF_LOSS
                       FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES_HISTORY A
                      WHERE DATE_TRUNC(''''DAY'''', CASE WHEN SYSTEM_DATE LIKE ''''%-%-%'''' THEN TO_TIMESTAMP(SYSTEM_DATE, ''''dd-mm-yyyy hh24:mi:ss'''')
                      WHEN SYSTEM_DATE LIKE ''''%/%/%'''' THEN TO_TIMESTAMP(SYSTEM_DATE, ''''dd/mm/yyyy hh24:mi:ss'''')
                      ELSE NULL
                  END) >=
                               DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 5
                   GROUP BY CLM_REF, DATE_OF_LOSS
           HAVING COUNT (*) > 1'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM as target
            SET C_LOSS_DATE = src.DATE_OF_LOSS, ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM (SELECT A.CLM_REF, A.DATE_OF_LOSS
                  FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES A,
                  INTERMEDIATE.WRK_LOSS_DATE_BACKDATED B
                 WHERE A.CLM_REF = B.CLM_REF) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER as target
            SET C_LOSS_DATE = src.DATE_OF_LOSS
FROM (SELECT A.CLM_REF, A.DATE_OF_LOSS
                  FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES A,
                  INTERMEDIATE.WRK_LOSS_DATE_BACKDATED B
                 WHERE A.CLM_REF = B.CLM_REF) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.BJAZ_OSTD_CLAIM as target
            SET C_LOSS_DATE = src.DATE_OF_LOSS
FROM (SELECT A.CLM_REF, A.DATE_OF_LOSS
                  FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES A,
                  INTERMEDIATE.WRK_LOSS_DATE_BACKDATED B
                 WHERE A.CLM_REF = B.CLM_REF) AS src
WHERE C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

END;


      v_sqltext := ''MERGE INTO TRANSACTIONAL.ODS_CLAIM_DIM A
           USING (SELECT CLM_REF, HHID
                    FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_BASE_MOT_EXT A,
                    ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES B
                   WHERE     A.CLAIM_ID = B.CLAIM_ID
                         AND HHID IS NOT NULL and
                       DATE_TRUNC(''''DAY'''',GG_CHANGE_DATE) BETWEEN DATE_TRUNC(''''DAY'''', TO_DATE('''''' || F_DATE || '''''') - 2)
                                          AND DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''') - 1)) b

              ON (a.c_claim_no = b.CLM_REF)
      WHEN MATCHED
      THEN
         UPDATE SET C_HHID = b.HHID,
         ETL_REFRESH_AT = CURRENT_TIMESTAMP()'';
EXECUTE IMMEDIATE v_sqltext;



v_sqltext := ''MERGE  INTO  TRANSACTIONAL.ODS_CLAIM_DIM
           USING (
                SELECT CLM_REF,
               MAX (SURVEYOR_APP_ON) SURVEYOR_APP_ON,
               MAX (RECPT_PSR_ON) RECPT_PSR_ON,
               MAX (RECPT_FSR_ON) RECPT_FSR_ON
          FROM BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_CLM_SURV_TAT A,
               BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.CLM_BASES C
         WHERE     A.CLAIM_ID = C.CLAIM_ID
               AND (   SURVEYOR_APP_ON IS NOT NULL
                    OR RECPT_PSR_ON IS NOT NULL
                    OR RECPT_FSR_ON IS NOT NULL)
               AND CLM_REF IN
                      (SELECT CLM_REF FROM INTERMEDIATE.WRK_INV_SUPP_REP_STG)
               AND VERSION_NO IN
                      (SELECT MAX (VERSION_NO)
                         FROM BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_CLM_SURV_TAT B
                        WHERE     A.CLAIM_ID = B.CLAIM_ID
                              AND B.TOP_INDICATOR = ''''Y'''')
          GROUP BY CLM_REF
                      ) X
                  ON (ODS_CLAIM_DIM.C_CLAIM_NO = X.CLM_REF)
          WHEN MATCHED
          THEN
             UPDATE SET
                C_RECPT_PSR_DATE = X.RECPT_PSR_ON,
                C_RECPT_FSR_DATE = X.RECPT_FSR_ON,
                C_SUR_APP_DATE = X.SURVEYOR_APP_ON'';
EXECUTE IMMEDIATE v_sqltext;

-- ADDED ON 8th Oct, 2025 new logic added for columns C_NET_TAX_LABOUR, C_NET_TAX_PARTS, C_OD_TYPE_OF_LOSS

v_sqltext := ''TRUNCATE TABLE INTERMEDIATE.WRK_NET_TAX_LABOUR'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_NET_TAX_LABOUR
(CLM_REF, NET_TAX_LABOUR)
SELECT CLM_REF, SUM (D.NET_TAX) AS NET_TAX_LABOUR
FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES A, ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_SUPP_LABOUR_DTLS D
WHERE A.CLAIM_ID = D.CLAIM_ID
AND D.VERSION_NO = 1
AND NVL (D.PART_NAME, ''''abc'''') <> ''''Towing''''
GROUP BY CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE INTERMEDIATE.WRK_NET_TAX_PARTS'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_NET_TAX_PARTS
(CLM_REF, NET_TAX_PARTS)
SELECT CLM_REF,
         SUM (
            CASE
               WHEN     C.VERSION_NO = 1
                    AND C.QTY > 0
                    AND C.RETAIL_PRICE > 0
                    AND NVL (C.ALLOW_FLAG, ''''Y'''') = ''''Y''''
               THEN
                  C.NET_TAX
            END)
            NET_TAX_PARTS
    FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES A, ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_SUPP_BILL_PARTS C
   WHERE  A.CLAIM_ID = C.CLAIM_ID
GROUP BY CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE INTERMEDIATE.WRK_NET_TAX_LABOUR_TAX_PARTS'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_NET_TAX_LABOUR_TAX_PARTS
(CLM_REF, NET_TAX_LABOUR, NET_TAX_PARTS)
SELECT A.CLM_REF,
NVL(NET_TAX_LABOUR,0) NET_TAX_LABOUR,
NVL(NET_TAX_PARTS,0) NET_TAX_PARTS
FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES A ,INTERMEDIATE.WRK_NET_TAX_LABOUR B, INTERMEDIATE.WRK_NET_TAX_PARTS C
WHERE A.CLM_REF=B.CLM_REF(+)
AND A.CLM_REF=C.CLM_REF(+)'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE INTERMEDIATE.WRK_NET_TAX_LABOUR_TAX_PARTS_1'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_NET_TAX_LABOUR_TAX_PARTS_1
(
CLM_REF,
NET_TAX_LABOUR,
NET_TAX_PARTS
)
   SELECT CLM_REF,
NET_TAX_LABOUR,
NET_TAX_PARTS
     FROM INTERMEDIATE.WRK_NET_TAX_LABOUR_TAX_PARTS A, TRANSACTIONAL.ODS_CLAIM_DIM B
    WHERE     CLM_REF = C_CLAIM_NO
          AND (NVL (C_NET_TAX_LABOUR, 0) <> NVL (NET_TAX_LABOUR, 0)
               OR NVL (C_NET_TAX_PARTS, 0) <> NVL (NET_TAX_PARTS, 0))'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE INTERMEDIATE.WRK_NET_TAX_LABOUR_TAX_UPDATE'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_NET_TAX_LABOUR_TAX_UPDATE
(CLM_REF,
NET_TAX_LABOUR,
NET_TAX_PARTS)
SELECT CLM_REF,
NET_TAX_LABOUR,
NET_TAX_PARTS
FROM INTERMEDIATE.WRK_NET_TAX_LABOUR_TAX_PARTS_1'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM A
               SET C_NET_TAX_LABOUR = I.NET_TAX_LABOUR,
                   C_NET_TAX_PARTS = I.NET_TAX_PARTS
                FROM (SELECT * FROM INTERMEDIATE.WRK_NET_TAX_LABOUR_TAX_UPDATE) I
             WHERE A.C_CLAIM_NO = I.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE INTERMEDIATE.WRK_TYPE_OF_LOSS'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_TYPE_OF_LOSS
WITH DAMAGE_TOTAL AS (
    SELECT CLAIM_ID, KIND_OF_DAMAGE
    FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_MOT_CLM_IP_DMG_EXTN
    WHERE DAMAGED_OBJECT = ''''Vehicle'''' AND KIND_OF_DAMAGE = ''''Total''''
    QUALIFY ROW_NUMBER() OVER (PARTITION BY CLAIM_ID ORDER BY CLAIM_ID) = 1
),
DAMAGE_PARTIAL AS (
    SELECT CLAIM_ID, KIND_OF_DAMAGE
    FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_MOT_CLM_IP_DMG_EXTN
    WHERE DAMAGED_OBJECT = ''''Vehicle'''' AND KIND_OF_DAMAGE = ''''Partial''''
    QUALIFY ROW_NUMBER() OVER (PARTITION BY CLAIM_ID ORDER BY CLAIM_ID) = 1
),
LATEST_CHANGE AS (
    SELECT CLAIM_ID, CHANGE_DESCRIPTION
    FROM (
        SELECT s.CLAIM_ID, s.CHANGE_DESCRIPTION,
               ROW_NUMBER() OVER (PARTITION BY s.CLAIM_ID ORDER BY VERSION_NO DESC) AS rn
        FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_CLM_STATUS_DTL s
        WHERE PROCESS_TYPE = ''''KINDOFLOSS''''
    ) t
    WHERE rn = 1
),
cte2 as
(SELECT c.C_CLAIM_NO,
       COALESCE(dt.KIND_OF_DAMAGE, dp.KIND_OF_DAMAGE, lc.CHANGE_DESCRIPTION, '''''''') AS C_KIND_OF_DAMAGE,
       NVL(c.C_OD_TYPE_OF_LOSS, ''''a'''') AS C_OD_TYPE_OF_LOSS
FROM TRANSACTIONAL.ODS_CLAIM_DIM c
LEFT JOIN DAMAGE_TOTAL dt ON dt.CLAIM_ID = c.C_CLAIM_ID
LEFT JOIN DAMAGE_PARTIAL dp ON dp.CLAIM_ID = c.C_CLAIM_ID
LEFT JOIN LATEST_CHANGE lc ON lc.CLAIM_ID = c.C_CLAIM_ID
WHERE C.C_REGN_DATE >= DATE_TRUNC(''''DAY'''',CURRENT_DATE)-2)
Select * from cte2
where C_KIND_OF_DAMAGE IS NOT NULL
AND C_KIND_OF_DAMAGE <> C_OD_TYPE_OF_LOSS'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM A
       SET C_OD_TYPE_OF_LOSS = I.C_KIND_OF_DAMAGE
       FROM (SELECT * FROM INTERMEDIATE.WRK_TYPE_OF_LOSS) I
    WHERE A.C_CLAIM_NO = I.C_CLAIM_NO'';

EXECUTE IMMEDIATE v_sqltext;




EXECUTE IMMEDIATE ''COMMIT'';
    RETURN ''Procedure executed successfully'';

EXCEPTION
    WHEN OTHER THEN
        EXECUTE IMMEDIATE ''ROLLBACK'';
        RAISE ;
        RETURN ''Error occurred: '' || SQLERRM || ''\\n'' || ''SQL: '' || ''\\n'' || v_sqltext;

END;
';
