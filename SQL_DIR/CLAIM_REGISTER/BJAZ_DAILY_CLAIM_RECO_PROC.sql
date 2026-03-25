CREATE OR REPLACE PROCEDURE INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO_PROC("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE

v_sqltext VARCHAR;
l_start NUMBER;
rows_cnt NUMBER;

BEGIN

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO (clm_ref, reason, load_date)
      SELECT clm_ref, ''''Claim Not in DWH'''', TO_DATE(''''''|| T_DATE || '''''')
        FROM (SELECT DISTINCT  clm_bases.clm_ref
                -- clm_bases_mv.claim_id
                FROM  '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.CLM_BASES,
                      '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.CLM_TRANS,
                      '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.CLM_POL_BASES
               WHERE      clm_bases.claim_id =
                             CLM_TRANS.claim_id
                     AND  clm_bases.claim_id =
                             '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.CLM_POL_BASES.claim_id
                     AND date_reported >= DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''')) - 30
                     AND trans_date < DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || ''''''))
                     --AND POLICY_REF <> ''''X''''
                     AND NVL(POLICY_REF,''''Y'''') <> ''''X'''' -- Change suggested by Ramesh Meesala on above line
                     AND clm_ref != ''''Error''''
              MINUS
              SELECT c_claim_no
                FROM TRANSACTIONAL.MV_CLAIM_REGISTER
               WHERE     top_indicator = ''''Y''''
                     AND NVL (MAXIMUS_FLAG, ''''RCS'''') not in(''''A'''', ''''Y'''', ''''C'''')
                     AND t_date_desc >= DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''')) - 30
                     AND c_regn_date >= DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''')) - 30)'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''INSERT INTO INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO (claim_id_sk, reason, load_date)
      SELECT
            c_claim_id_sk, ''''Claim Not in MV'''', TO_DATE(''''''|| T_DATE || '''''')
        FROM TRANSACTIONAL.ODS_CLAIM_FACT a, PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM b
       WHERE     a.t_date_id_sk = b.t_date_id_sk
             AND t_date_desc BETWEEN DATE_TRUNC (''''MONTH'''',TO_DATE(''''''|| F_DATE || '''''') - 1)
                                 AND DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''') - 1)
      MINUS
      SELECT
            c_claim_id_sk, ''''Claim Not in MV'''', TO_DATE(''''''|| T_DATE || '''''')
        FROM TRANSACTIONAL.ODS_CLAIM_FACT_MV a, PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM b
       WHERE     a.t_date_id_sk = b.t_date_id_sk
             AND t_date_desc BETWEEN DATE_TRUNC (''''MONTH'''',TO_DATE(''''''|| F_DATE || '''''') - 1)
                                 AND DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''') - 1)'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''INSERT INTO INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO (claim_id_sk, reason, load_date)
      SELECT
            a.c_claim_id_sk, ''''Claim Not in Fact'''', TO_DATE(''''''|| T_DATE || '''''')
        FROM TRANSACTIONAL.ODS_CLAIM_FACT_MV a, PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM b
       WHERE     a.t_date_id_sk = b.t_date_id_sk
             AND NVL (MAXIMUS_FLAG, ''''RCS'''') not in(''''A'''', ''''Y'''', ''''C'''')
             AND t_date_desc BETWEEN DATE_TRUNC (''''MONTH'''',TO_DATE(''''''|| F_DATE || '''''') - 1)
                                 AND DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''') - 1)
      MINUS
      SELECT
            c_claim_id_sk, ''''Claim Not in Fact'''', TO_DATE(''''''|| T_DATE || '''''')
        FROM TRANSACTIONAL.ODS_CLAIM_FACT a, PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM b
       WHERE     a.t_date_id_sk = b.t_date_id_sk
             AND t_date_desc BETWEEN DATE_TRUNC (''''MONTH'''',TO_DATE(''''''|| F_DATE || '''''') - 1)
                                 AND DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''') - 1)'';
EXECUTE IMMEDIATE v_sqltext;



v_sqltext := ''INSERT INTO INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO (claim_id_sk, reason, load_date)
        SELECT a.c_claim_id_sk, ''''Paid diff in Fact  MV'''', TO_DATE(''''''|| T_DATE || '''''')
          FROM (  SELECT a.c_claim_id_sk, (SUM (NVL (paid_claim, 0))) mvpd
                    FROM TRANSACTIONAL.ODS_CLAIM_FACT_MV a, PROD_DWH_MIGRATED_DB.PROD.ods_time_dim b --, TRANSACTIONAL.ODS_CLAIM_DIM c
                   WHERE     a.t_date_id_sk = b.t_date_id_sk
                         -- and a.c_Claim_id_sk =c.c_Claim_id_sk
                          AND NVL (MAXIMUS_FLAG, ''''RCS'''') not in(''''A'''', ''''Y'''', ''''C'''')
                         AND t_date_desc >= ''''1-apr-2025''''
                --AND t_date_desc BETWEEN DATE_TRUNC (''''MONTH'''',CURRENT_DATE - 1)
                --  AND DATE_TRUNC(''''DAY'''', CURRENT_DATE - 1)
                GROUP BY a.c_claim_id_sk) a,
               (  SELECT c_claim_id_sk,
                         FLOOR (SUM (NVL (paid_claim_amount, 0))) pd
                    FROM TRANSACTIONAL.ODS_CLAIM_FACT a, PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM b
                   WHERE     t_date_desc >=  ''''1-apr-2025''''
                         AND a.t_date_id_sk = b.t_date_id_sk
                --AND t_date_desc BETWEEN DATE_TRUNC (''''MONTH'''',CURRENT_DATE - 1)
                --   AND DATE_TRUNC(''''DAY'''', CURRENT_DATE - 1)
                GROUP BY c_claim_id_sk) b
         WHERE a.c_claim_id_sk = b.c_claim_id_sk
      --and mvpd <> pd ;
      GROUP BY a.c_claim_id_sk
        HAVING ABS (SUM (mvpd) - SUM (pd)) >= 5'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''INSERT INTO INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO (claim_id_sk, reason, load_date)
        SELECT a.c_claim_id_sk, ''''Reserve diff in Fact  MV'''', TO_DATE(''''''|| T_DATE || '''''')
          FROM (  SELECT
                        a.c_claim_id_sk, (SUM (NVL (reserve_amount, 0))) mvpd
                    FROM TRANSACTIONAL.ODS_CLAIM_FACT_MV a, PROD_DWH_MIGRATED_DB.PROD.ods_time_dim b --, TRANSACTIONAL.ODS_CLAIM_DIM c
                   WHERE     a.t_date_id_sk = b.t_date_id_sk
                         -- and a.c_Claim_id_sk =c.c_Claim_id_sk
                          AND NVL (MAXIMUS_FLAG, ''''RCS'''') not in(''''A'''', ''''Y'''', ''''C'''')
                         AND t_date_desc >=  ''''1-apr-2025''''
                GROUP BY a.c_claim_id_sk) a,
               (  SELECT
                        c_claim_id_sk, (SUM (NVL (reserve_amount, 0))) pd
                    FROM TRANSACTIONAL.ODS_CLAIM_FACT a, PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM b
                   WHERE     a.t_date_id_sk = b.t_date_id_sk
                         AND t_date_desc >=  ''''1-apr-2025''''
                GROUP BY c_claim_id_sk) b
         WHERE a.c_claim_id_sk = b.c_claim_id_sk
      --and mvpd <> pd;
      GROUP BY a.c_claim_id_sk
        HAVING ABS (SUM (mvpd) - SUM (pd)) >= 5'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''INSERT INTO INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO (clm_ref,
                                      reason,
                                      pdres,
                                      dwres,
                                      load_date)
        SELECT clm_ref,
               ''''Diff in Reserve Production  DWH'''',
               SUM (srcres),
               SUM (dwhres),
               TO_DATE(''''''|| T_DATE || '''''')
          FROM (  SELECT
                        clm_ref, (SUM (NVL (trans_amt, 0))) srcres
                    FROM '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.CLM_BASES a, '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.CLM_TRANS b
                   WHERE     a.claim_id = b.claim_id
                         AND DATE_TRUNC(''''DAY'''', trans_date) BETWEEN  ''''1-apr-2025''''
                                                    AND DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''') - 1)
                         AND b.clm_status IN (''''AUTHOR'''')
                GROUP BY clm_ref) a,
               (  SELECT
                        c_claim_no, (SUM (NVL (reserve_amount, 0))) dwhres
                    FROM TRANSACTIONAL.MV_CLAIM_REGISTER a
                   WHERE     t_date_desc BETWEEN  ''''1-apr-2025''''
                                             AND DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''') - 1)
                          AND NVL (MAXIMUS_FLAG, ''''RCS'''') not in(''''A'''', ''''Y'''', ''''C'''')
                GROUP BY c_claim_no) b
         WHERE a.clm_ref = b.c_claim_no
      GROUP BY clm_ref
        HAVING ABS (SUM (srcres) - SUM (dwhres)) >= 5'';
EXECUTE IMMEDIATE v_sqltext;


/*- paid diff in opus and dwh-- starts here*/

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_OPUS_PAID'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_OPUS_PAID                                         -- 35 sec
        SELECT a.clm_ref, (SUM (NVL (a.trans_amt, 0))) opus_paid
          FROM '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_APPROVAL a                         --, clm_bases b
         WHERE     (trans_date) BETWEEN  ''''1-apr-2025'''' -- DATE_TRUNC (CURRENT_DATE - 1, ''''MM'''')
                                                    AND DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''') - 1) --AND a.claim_id = b.claim_id
               AND pay_status NOT LIKE ''''%DEL%''''
      GROUP BY a.clm_ref'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_DEL_PAID'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_DEL_PAID                                           --24 sec
        SELECT k.clm_ref, (SUM (NVL (k.trans_amt, 0))) del_paid
          FROM '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_APPROVAL_HIST k                 --, clm_bases b
         WHERE                       --                k.claim_id = b.claim_id
                                    --               AND k.clm_ref = b.clm_ref
                   (TRANS_DATE) BETWEEN  ''''1-apr-2025'''' AND DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''') - 1) ---= DATE_TRUNC(''''DAY'''', CURRENT_DATE)
               AND PAY_STATUS LIKE ''''%DEL%''''
      GROUP BY k.clm_ref'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_TOT_OPUS_PAID'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_TOT_OPUS_PAID                                     --1.15min
        SELECT a.clm_ref,
               SUM (NVL (opus_paid, 0) + NVL (del_paid, 0)) opus_paid
          FROM INTERMEDIATE.WRK_OPUS_PAID a, INTERMEDIATE.WRK_DEL_PAID b
         WHERE a.clm_ref = b.clm_ref(+)
      GROUP BY a.clm_ref'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_TOT_PAID'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_TOT_PAID
        SELECT c_claim_no, opus_paid, dwh_paid
          FROM (SELECT * FROM INTERMEDIATE.wrk_tot_opus_paid) a,
               (  SELECT c_claim_no, (SUM (NVL (paid_claim, 0))) dwh_paid
                    FROM TRANSACTIONAL.MV_CLAIM_REGISTER a
                   WHERE     t_date_desc BETWEEN  ''''1-apr-2025'''' --DATE_TRUNC (CURRENT_DATE - 1, ''''MM'''')
                                             AND DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''') - 1)
                          AND NVL (MAXIMUS_FLAG, ''''RCS'''') not in(''''A'''', ''''Y'''', ''''C'''')
                GROUP BY c_claim_no) b
         WHERE a.clm_ref = b.c_claim_no
      GROUP BY c_claim_no, opus_paid, dwh_paid
        HAVING ABS (SUM (NVL (a.opus_paid, 0)) - SUM (NVL (b.dwh_paid, 0))) >=
                  5'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO (clm_ref,
                                      reason,
                                      srcpd,
                                      dwhpd,
                                      load_date)
      SELECT c_claim_no,
             ''''Diff in Paid Prod n DWH'''',
             opus_paid,
             dwh_paid,
             TO_DATE(''''''|| T_DATE || '''''')
        FROM INTERMEDIATE.WRK_TOT_PAID'';
EXECUTE IMMEDIATE v_sqltext;

/*CALL LOGTRACE (
      ''LOG'',
      10001,
         ''Clm Res Chk 4th insert - time taken in mins : ''
      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - l_start) / 100 / 60),
      ''daily_clm_res_check'');*/
/*---and a.clm_ref like ''oc-10%''; -----changed for this fy.......*/



v_sqltext := ''INSERT INTO INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO (claim_id_sk, reason, load_date)
        SELECT a.c_claim_id_sk, ''''Service Tax diff in Fact  MV'''', TO_DATE(''''''|| T_DATE || '''''')
          FROM (  SELECT c_claim_id_sk, (SUM (NVL (service_tax, 0))) mvpd
                    FROM TRANSACTIONAL.ODS_CLAIM_FACT_MV a, PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM b
                   WHERE     a.t_date_id_sk = b.t_date_id_sk
                         AND NVL (MAXIMUS_FLAG, ''''RCS'''') not in(''''A'''', ''''Y'''', ''''C'''')
                         AND --TO_CHAR((t_date_desc),''''mon.yyyy'''')=TO_CHAR(DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''')-1),''''mon.yyyy'''')
                            t_date_desc BETWEEN  ''''1-apr-2025'''' --DATE_TRUNC (CURRENT_DATE - 1, ''''MM'''')
                                            AND DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''') - 1)
                GROUP BY c_claim_id_sk) a,
               (  SELECT c_claim_id_sk, (SUM (NVL (service_tax, 0))) pd
                    FROM TRANSACTIONAL.ODS_CLAIM_FACT a, PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM b
                   WHERE     a.t_date_id_sk = b.t_date_id_sk
                         AND --TO_CHAR((t_date_desc),''''mon.yyyy'''')=TO_CHAR(DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''')-1),''''mon.yyyy'''')
                            t_date_desc BETWEEN  ''''1-apr-2025'''' ---DATE_TRUNC (CURRENT_DATE - 1, ''''MM'''')
                                            AND DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''') - 1)
                GROUP BY c_claim_id_sk) b
         WHERE a.c_claim_id_sk = b.c_claim_id_sk
      GROUP BY a.c_claim_id_sk
        HAVING ABS (SUM (mvpd) - SUM (pd)) >= 5'';
EXECUTE IMMEDIATE v_sqltext;

/*CALL LOGTRACE (
      ''LOG'',
      10001,
         ''Clm Res Chk 5th insert -serv tax diff in Fact & MV-  :''
      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - l_start) / 100 / 60),
      ''daily_clm_res_check'');*/


v_sqltext := ''INSERT INTO INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO (clm_ref,
                                      reason,
                                      PDRES,
                                      DWRES,
                                      load_date)
        SELECT clm_ref,
               ''''Service Tax diff in DWH  PROD'''',
               SUM (mvpd),
               SUM (pd),
               TO_DATE(''''''|| T_DATE || '''''')
          FROM (  SELECT clm_ref,
                         FLOOR (
                            SUM (
                               CASE
                                  WHEN UPPER (pay_status) LIKE ''''%DEL%''''
                                  THEN
                                     NVL (-1 * service_tax, 0)
                                  ELSE
                                     service_tax
                               END))
                            mvpd
                    FROM '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_APPROVAL
                   WHERE DATE_TRUNC(''''DAY'''', trans_date) BETWEEN  ''''1-apr-2025'''' --- DATE_TRUNC (CURRENT_DATE - 1, ''''MM'''')
                                                AND DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''') - 1)
                --AND UPPER (pay_status) NOT LIKE ''''%DEL%''''
                GROUP BY clm_ref) a,
               (  SELECT c_claim_no, FLOOR (SUM (NVL (service_tax, 0))) pd
                    FROM TRANSACTIONAL.MV_CLAIM_REGISTER
                   WHERE --TO_CHAR((t_date_desc),''''mon.yyyy'''')=TO_CHAR(DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''')-1),''''mon.yyyy'''')
                        t_date_desc BETWEEN  ''''1-apr-2025'''' ----DATE_TRUNC (CURRENT_DATE - 1, ''''MM'''')
                                                        AND DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''') - 1)
                GROUP BY c_claim_no) b
         WHERE a.clm_ref = b.c_claim_no
      GROUP BY a.clm_ref
        HAVING SUM (mvpd) - SUM (pd) > 5'';
EXECUTE IMMEDIATE v_sqltext;


/*CALL LOGTRACE (
      ''LOG'',
      10001,
         ''Clm Res Chk 4th insert - time taken in mins : ''
      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - l_start) / 100 / 60),
      ''daily_clm_res_check'');*/


v_sqltext := ''INSERT INTO INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO (CLAIM_ID_SK,
                                      PDRES,
                                      DWRES,
                                      REASON,
                                      load_date)
      SELECT a.c_claim_id_sk,
             a.prod,
             b.dwh,
             ''''Salvage Mismatch'''',
             TO_DATE(''''''|| T_DATE || '''''')
        FROM (  SELECT c_claim_id_sk, SUM (trans_amount) prod
                  FROM TRANSACTIONAL.bjaz_salvage_load
              GROUP BY c_claim_id_sk) a,
             (  SELECT c_claim_id_sk, SUM (NVL (salvage_amount, 0)) dwh
                  FROM TRANSACTIONAL.ODS_CLAIM_FACT a, PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM b
                 WHERE     a.t_date_id_sk = b.t_date_id_sk
                       AND --TO_CHAR ( (t_date_desc), ''''mon.yyyy'''') =TO_CHAR (DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''') - 1), ''''mon.yyyy'''')
                          t_date_desc BETWEEN DATE_TRUNC (''''MONTH'''',TO_DATE(''''''|| F_DATE || '''''') - 1)
                                          AND DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''') - 1)
              GROUP BY c_claim_id_sk) b
       WHERE     a.c_claim_id_sk = b.c_claim_id_sk(+)
             AND (prod - dwh IS NULL OR prod - dwh <> 0)'';
EXECUTE IMMEDIATE v_sqltext;


/*CALL LOGTRACE (
      ''LOG'',
      10001,
         ''Clm Res Chk  salvage 4.1th insert - time taken in mins : ''
      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - l_start) / 100 / 60),
      ''daily_clm_res_check'');*/


v_sqltext := ''INSERT INTO INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO (CLAIM_ID_SK,
                                      PDRES,
                                      DWRES,
                                      REASON,
                                      load_date)
        SELECT a.c_claim_id_sk,
               SUM (a.dwh),
               SUM (b.dwh),
               ''''Salvage  Diff fact n mv'''',
               TO_DATE(''''''|| T_DATE || '''''')
          FROM (  SELECT a.c_claim_id_sk, SUM (salvage_amount) dwh
                    FROM TRANSACTIONAL.ODS_CLAIM_FACT_MV a, PROD_DWH_MIGRATED_DB.PROD.ods_time_dim b --,TRANSACTIONAL.ODS_CLAIM_DIM c
                   WHERE     a.t_date_id_sk = b.t_date_id_sk
                         AND r_reserve_type_id = 9001
                         -- and a.c_claim_id_sk=c.c_claim_id_sk
                     AND NVL (MAXIMUS_FLAG, ''''RCS'''') not in(''''A'''', ''''Y'''', ''''C'''')
                         AND --TO_CHAR ( (t_date_desc), ''''mon.yyyy'''') = TO_CHAR (DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''') - 1), ''''mon.yyyy'''')
                            t_date_desc BETWEEN  ''''1-apr-2025'''' ---DATE_TRUNC (CURRENT_DATE - 1, ''''MM'''')
                                            AND DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''') - 1)
                GROUP BY a.c_claim_id_sk) a,
               (  SELECT c_claim_id_sk, SUM (salvage_amount) dwh
                    FROM TRANSACTIONAL.ODS_CLAIM_FACT a, PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM b
                   WHERE     a.t_date_id_sk = b.t_date_id_sk
                         AND --TO_CHAR ( (t_date_desc), ''''mon.yyyy'''') =TO_CHAR (DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''') - 1), ''''mon.yyyy'''')
                            t_date_desc BETWEEN  ''''1-apr-2025'''' --DATE_TRUNC (CURRENT_DATE - 1, ''''MM'''')
                                            AND DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''') - 1)
                         AND r_reserve_type_id = 9001
                GROUP BY c_claim_id_sk) b
         WHERE a.c_claim_id_sk(+) = b.c_claim_id_sk
      --AND (b.DWH - a.dwh IS NULL OR b.DWH - a.dwh <> 0)
      GROUP BY a.c_claim_id_sk
        HAVING SUM (b.DWH) - SUM (a.dwh) > 5'';
EXECUTE IMMEDIATE v_sqltext;

/*CALL LOGTRACE (
      ''LOG'',
      10001,
         ''Clm Res Chk  salvage 4.2th insert - time taken in mins : ''
      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - l_start) / 100 / 60),
      ''JOB_RUN'');*/
v_sqltext := ''INSERT INTO INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO (CLAIM_ID_SK, REASON, load_date)
      WITH table1
           AS (  SELECT a.c_claim_id_sk, SUM (salvage_amount) fact_salvage
                   FROM TRANSACTIONAL.ODS_CLAIM_FACT a, PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM b
                  WHERE     a.t_date_id_sk = b.t_date_id_sk
                        AND t_date_desc BETWEEN  ''''1-apr-2025''''
                                            AND DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''') - 1)
                        AND r_reserve_type_id = 9001
               GROUP BY a.c_claim_id_sk
                 HAVING SUM (salvage_amount) <> 0),
           table2
           AS (  SELECT a.c_claim_id_sk, SUM (salvage_amount) fact_mv_salvage
                   FROM TRANSACTIONAL.ODS_CLAIM_FACT_MV a, PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM b
                  WHERE     a.t_date_id_sk = b.t_date_id_sk
                         AND NVL (MAXIMUS_FLAG, ''''RCS'''') not in(''''A'''', ''''Y'''', ''''C'''')
                        AND r_reserve_type_id = 9001
                        AND t_date_desc BETWEEN  ''''1-apr-2025''''
                                            AND DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''') - 1)
               GROUP BY a.c_claim_id_sk
                 HAVING SUM (salvage_amount) <> 0)
      SELECT a.c_claim_id_sk, ''''Salvage Missing IN MV'''', TO_DATE(''''''|| T_DATE || '''''')
        FROM table1 a, table2 b
       WHERE     a.c_claim_id_sk = b.c_claim_id_sk(+)
             AND (NVL (fact_salvage, 0) - NVL (fact_mv_salvage, 0)) > 5'';
EXECUTE IMMEDIATE v_sqltext;


/*CALL LOGTRACE (
      ''LOG'',
      10001,
         ''Clm Res Chk  salvage 4.3 rd  insert - time taken in mins : ''
      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - l_start) / 100 / 60),
      ''daily_clm_res_check'');*/


v_sqltext := ''DELETE FROM INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO
         WHERE clm_ref LIKE ''''C-%'''''';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''DELETE FROM INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO
         WHERE clm_ref LIKE ''''OC-03%'''''';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''DELETE FROM INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO
         WHERE clm_ref LIKE ''''C-02%'''''';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''DELETE FROM INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO
         WHERE clm_ref LIKE ''''OC-04%'''''';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''DELETE FROM INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO
         WHERE clm_ref IN
                  (SELECT c_claim_no
                     FROM (  SELECT c_claim_no, NVL (SUM (paid_Claim), 0) paid
                               FROM TRANSACTIONAL.MV_CLAIM_REGISTER a,
                                    INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO b
                              WHERE     c_claim_no = clm_ref
                                    AND reason = ''''Diff in Paid Prod n DWH''''
                           --and c_claim_no =''''OC-16-2416-1803-00000431''''
                           GROUP BY c_claim_no) a,
                          (  SELECT a.clm_ref, NVL (SUM (trans_amt), 0) src_pd
                               FROM '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_APPROVAL a,
                                    INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO b
                              WHERE     reason = ''''Diff in Paid Prod n DWH''''
                                    AND DATE_TRUNC(''''DAY'''', trans_date) < DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || ''''''))
                                    AND a.clm_ref = b.clm_ref
                                    AND PAY_STATUS NOT LIKE ''''%DEL%''''
                           GROUP BY a.clm_ref) b
                    WHERE c_claim_no = b.clm_ref AND paid = src_pd)'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''DELETE FROM INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO
         WHERE     CLM_REF IN
                      (WITH TABLE1
                            AS (  SELECT C_CLAIM_NO,
                                         C_CLAIM_TYPE,
                                         SUM (PAID_CLAIM) PAID_CLAIM
                                    FROM TRANSACTIONAL.MV_CLAIM_REGISTER
                                   WHERE     C_CLAIM_NO IN
                                                (SELECT CLM_REF
                                                   FROM INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO
                                                  WHERE REASON =
                                                           ''''Diff in Paid Prod n DWH'''')
                                         AND T_DATE_DESC BETWEEN  ''''1-apr-2025''''
                                                             AND   DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || ''''''))
                                                                 - 1
                                         AND NVL (MAXIMUS_FLAG, ''''RCS'''') not in(''''A'''', ''''Y'''', ''''C'''')
                                GROUP BY C_CLAIM_NO, C_CLAIM_TYPE),
                            TABLE3
                            AS (  SELECT CLM_REF, SUM (TRANS_AMT) PD
                                    FROM '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_APPROVAL
                                   WHERE     CLM_REF IN
                                                (SELECT CLM_REF
                                                   FROM INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO
                                                  WHERE REASON =
                                                           ''''Diff in Paid Prod n DWH'''')
                                         AND PAY_STATUS NOT LIKE ''''%DEL%''''
                                         AND TRANS_DATE BETWEEN  ''''1-apr-2025''''
                                                            AND   DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || ''''''))
                                                                - 1
                                GROUP BY CLM_REF)
                       SELECT C_CLAIM_NO
                         FROM TABLE1 A, TABLE3 C
                        WHERE C_CLAIM_NO = C.CLM_REF AND PAID_CLAIM = PD)
               AND REASON = ''''Diff in Paid Prod n DWH'''''';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''DELETE FROM INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO
         WHERE     reason = ''''Closed with  Ostd amount''''
               AND NVL (DWRES, 0) = NVL (PDRES, 0)
               AND NVL (SRCPD, 0) = NVL (DWHPD, 0)'';
EXECUTE IMMEDIATE v_sqltext;


SELECT COUNT (*) INTO :rows_cnt FROM INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO;


v_sqltext := ''INSERT INTO INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO_bkp
      SELECT * FROM INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''DELETE FROM INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO_bkp
         WHERE DATE_TRUNC(''''DAY'''', load_date) <= DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''')) - 90'';
EXECUTE IMMEDIATE v_sqltext;


/*
IF (rows_cnt >= 1)
   THEN
   utl_mail.send (
         ''mis.team@bajajallianz.co.in'',
         ''chandrakant.khemnar@its.bajajallianz.co.in'',
         ''mis.team@bajajallianz.co.in'',
         NULL,
         ''Daily Claim Reco - Done'',
            ''Please check INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO DWH claim reco with OPUS .''
         || DBMS_UTILITY.format_error_backtrace ()
         || SQLERRM);

END IF;*/

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_FLIPKART_RECO'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_FLIPKART_RECO
      SELECT clm_ref,
             dwres dwh_reserve,
             pdres opus_reserve,
             load_date
        FROM INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO a, TRANSACTIONAL.MV_CLAIM_REGISTER b
       WHERE     reason = ''''Closed with Ostd amount''''
             AND dwres <> pdres
             AND clm_ref = c_claim_no
             AND top_indicator = ''''Y''''
             AND i_imd_Desc IN (''''66666668'''', ''''10065301'''')'';
EXECUTE IMMEDIATE v_sqltext;


-- Developed by Siddhant Sahoo
v_sqltext := '' CREATE OR REPLACE TABLE INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO_ALL AS
with
DWH_PROD_MINUS_SF_CTE as (
select
C_CLAIM_NO,
sum(PAID_CLAIM) PAID_CLAIM,
sum(RESERVE_AMOUNT) RESERVE_AMOUNT,
''''DWH_PROD MINUS SF'''' AS MINUS_QUERY
from PROD_DWH_MIGRATED_DB.DWH_PROD.mv_claim_register
WHERE r_reserve_desc <> ''''R-OTH''''
AND t_date_desc BETWEEN DATE_TRUNC(''''MONTH'''', DATE ''''2025-04-01'''') AND CURRENT_DATE
group by C_CLAIM_NO

minus

select
C_CLAIM_NO,
sum(PAID_CLAIM) PAID_CLAIM,
sum(RESERVE_AMOUNT) RESERVE_AMOUNT,
''''DWH_PROD MINUS SF'''' AS MINUS_QUERY
from bagic_prod_curated_db.TRANSACTIONAL.mv_claim_register
WHERE r_reserve_desc <> ''''R-OTH''''
AND t_date_desc BETWEEN DATE_TRUNC(''''MONTH'''', DATE ''''2025-04-01'''') AND CURRENT_DATE
group by C_CLAIM_NO
),

SF_PROD_MINUS_DWH_CTE as (
select
C_CLAIM_NO,
sum(PAID_CLAIM) PAID_CLAIM,
sum(RESERVE_AMOUNT) RESERVE_AMOUNT,
''''SF MINUS DWH_PROD'''' AS MINUS_QUERY
from bagic_prod_curated_db.TRANSACTIONAL.mv_claim_register
WHERE r_reserve_desc <> ''''R-OTH''''
AND t_date_desc BETWEEN DATE_TRUNC(''''MONTH'''', DATE ''''2025-04-01'''') AND CURRENT_DATE
group by C_CLAIM_NO

minus

select
C_CLAIM_NO,
sum(PAID_CLAIM) PAID_CLAIM,
sum(RESERVE_AMOUNT) RESERVE_AMOUNT,
''''SF MINUS DWH_PROD'''' AS MINUS_QUERY
from PROD_DWH_MIGRATED_DB.DWH_PROD.mv_claim_register
WHERE r_reserve_desc <> ''''R-OTH''''
AND t_date_desc BETWEEN DATE_TRUNC(''''MONTH'''', DATE ''''2025-04-01'''') AND CURRENT_DATE
group by C_CLAIM_NO
)

select
TO_CHAR(CURRENT_DATE, ''''Mon-YYYY'''') AS REPORT_START_MONTH,
CASE
        WHEN A.C_CLAIM_NO IS NULL THEN ''''Claim not in DWH''''
        WHEN B.C_CLAIM_NO IS NULL THEN ''''Claim not in SF''''
        WHEN ABS(A.PAID_CLAIM - B.PAID_CLAIM) > 5 AND ABS(A.RESERVE_AMOUNT - B.RESERVE_AMOUNT) > 5 THEN ''''Diff in Paid and Diff in Reserve''''
        WHEN ABS(A.RESERVE_AMOUNT - B.RESERVE_AMOUNT) > 5 THEN ''''Diff in Reserve''''
        WHEN ABS(A.PAID_CLAIM - B.PAID_CLAIM) > 5 THEN ''''Diff in Paid''''
        ELSE ''''Other''''
    END AS REASON,
COALESCE(A.MINUS_QUERY, B.MINUS_QUERY) AS MINUS_QUERY,
A.C_CLAIM_NO DWH_C_CLAIM_NO,
B.C_CLAIM_NO SF_C_CLAIM_NO,
A.PAID_CLAIM DWH_PAID,
B.PAID_CLAIM SF_PAID,
A.PAID_CLAIM - B.PAID_CLAIM DIFF_PAID,
A.RESERVE_AMOUNT DWH_RESERVE,
B.RESERVE_AMOUNT SF_RESERVE,
A.RESERVE_AMOUNT - B.RESERVE_AMOUNT DIFF_RESERVE
from DWH_PROD_MINUS_SF_CTE A full outer join SF_PROD_MINUS_DWH_CTE B on (A.C_CLAIM_NO = B.C_CLAIM_NO)

WHERE
    ABS(COALESCE(A.RESERVE_AMOUNT,0) - COALESCE(B.RESERVE_AMOUNT,0)) > 5
    OR ABS(COALESCE(A.PAID_CLAIM,0) - COALESCE(B.PAID_CLAIM,0)) > 5
    OR A.C_CLAIM_NO IS NULL
    OR B.C_CLAIM_NO IS NULL

order by B.C_CLAIM_NO'';
EXECUTE IMMEDIATE v_sqltext;

/*
PROD.dump_table_to_csv (''WRK_FLIPKART_RECO'', -- table / view name which needs to be exported
                              ''UTL_PATH_C'', -- database directory where it has to be exported
                              ''WRK_FLIPKART_RECO.CSV'', -- required file name for the output file
                              '',''                      ---¿ required separator
                                 );*/

/*ces.email_files (
         FROM_NAME      => ''mis.team@bajajallianz.co.in'',
         TO_NAMES       => ''Chandrakant.Khemnar@bajajallianz.co.in ,Niranjan.Rote@bajajallianz.co.in'',
         CC_NAMES       => ''Rahul.Mane01@bajajallianz.co.in,priyanka.totala@its.bajajallianz.co.in,trilok.sonker@its.bajajallianz.co.in'',
         SUBJECT        => ''Daily Reprot Of SMS Submitted As On '' || CURRENT_DATE,
         HTML_MESSAGE   => ''Dear Team, <br><br> <br>  Please find Attachment.</b>  <br><br><br>Regards,<br>DWH TEAM <br>Genral<br>'',
         FILENAME1      => ''/UTL_PATH_C/WRK_FLIPKART_RECO.CSV'',
         FILETYPE1      => ''text/plain'');*/

/*CALL LOGTRACE (
      ''LOG'',
      10001,
         ''INTERMEDIATE.BJAZ_DAILY_CLAIM_RECO_proc - time taken in mins : ''
      || TO_CHAR ( (DATE_PART(epoch_second, CURRENT_TIMESTAMP()) - l_start) / 100 / 60),
      ''daily_clm_res_check'');*/


EXECUTE IMMEDIATE ''COMMIT'';
	RETURN ''Procedure executed successfully'';

	EXCEPTION
		WHEN OTHER THEN
			EXECUTE IMMEDIATE ''ROLLBACK'';
			RAISE ;
			RETURN ''Error occurred: '' || SQLERRM || ''\\\\\\\\n'' || ''SQL: '' || ''\\\\\\\\n'' || v_sqltext;

END;
';