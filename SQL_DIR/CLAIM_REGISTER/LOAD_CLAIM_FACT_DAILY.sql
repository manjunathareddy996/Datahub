CREATE OR REPLACE PROCEDURE TRANSACTIONAL.LOAD_CLAIM_FACT_DAILY("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE
v_sqltext varchar;


BEGIN

v_sqltext := ''INSERT
         INTO  TRANSACTIONAL.ODS_CLAIM_FACT (C_CLAIM_ID_SK,
                                 P_POLICY_NO_SK,
                                 T_DATE_ID_SK,
                                 R_RESERVE_TYPE_ID,
                                 RESERVE_AMOUNT,
                                 PAID_CLAIM_AMOUNT,
                                 SALVAGE_AMOUNT,
                                 CC_CC_CLAIMTYPE_ID_SK,
                                 C_PAY_APP_NO,
                                 RECOVERY_AMOUNT,
                                 SERVICE_TAX)
      (  SELECT SET_OPERATION_0$2.C_CLAIM_ID_SK$15 C_CLAIM_ID_SK$14,
                SET_OPERATION_0$2.P_POLICY_NO_SK$15 P_POLICY_NO_SK$14,
                SET_OPERATION_0$2.T_DATE_ID_SK$15 T_DATE_ID_SK$14,
                SET_OPERATION_0$2.SF_TOTAL_TYPE_1$9 SF_TOTAL_TYPE_1$8,
                SUM (NVL (SET_OPERATION_0$2.RESERVE_AMT$5, 0))
                   RESERVE_AMT$4,
                SUM (NVL (SET_OPERATION_0$2.PAID_AMT$5, 0)) PAID_AMT$4,
                SUM (NVL (SET_OPERATION_0$2.BASE_AMT$5, 0)) BASE_AMT$4,
                SET_OPERATION_0$2.SF_NO$13 SF_NO$12,
                SET_OPERATION_0$2.PAY_APP_NO$13 PAY_APP_NO$12,
                SUM (NVL (SET_OPERATION_0$2.SALVAGE_AMT$9, 0))
                   SALVAGE_AMT$8,
                SUM (NVL (SET_OPERATION_0$2.SERVICE_TAX$13, 0))
                   SERVICE_TAX$12
           FROM (SELECT RESERVE_AMT RESERVE_AMT$5,
                        SF_TOTAL_TYPE_1 SF_TOTAL_TYPE_1$9,
                        C_CLAIM_ID_SK C_CLAIM_ID_SK$15,
                        PAY_APP_NO PAY_APP_NO$13,
                        PAID_AMT PAID_AMT$5,
                        SF_NO SF_NO$13,
                        P_POLICY_NO_SK P_POLICY_NO_SK$15,
                        T_DATE_ID_SK T_DATE_ID_SK$15,
                        SERVICE_TAX SERVICE_TAX$13,
                        BASE_AMT BASE_AMT$5,
                        SALVAGE_AMT SALVAGE_AMT$9
                   FROM (SELECT SET_OPERATION$2.RESERVE_AMT$6
                                                                 RESERVE_AMT,
                                TO_NUMBER (
                                   SET_OPERATION$2.SF_TOTAL_TYPE_1$10)
                                   SF_TOTAL_TYPE_1,
                                SET_OPERATION$2.C_CLAIM_ID_SK$16
                                   C_CLAIM_ID_SK,
                                SET_OPERATION$2.PAY_APP_NO$14
                                                                 PAY_APP_NO,
                                SET_OPERATION$2.PAID_AMT$6
                                                              PAID_AMT,
                                SET_OPERATION$2.SF_NO$14
                                                            SF_NO,
                                SET_OPERATION$2.P_POLICY_NO_SK$16
                                   P_POLICY_NO_SK,
                                SET_OPERATION$2.T_DATE_ID_SK$16
                                   T_DATE_ID_SK,
                                SET_OPERATION$2.SERVICE_TAX$14
                                   SERVICE_TAX,
                                0
                                 BASE_AMT,
                                SET_OPERATION$2.SALVAGE_AMT$10
                                   SALVAGE_AMT
                           FROM (SELECT TRANS_DATE TRANS_DATE$10,
                                        RESERVE_AMT RESERVE_AMT$6,
                                        SF_TOTAL_TYPE_1 SF_TOTAL_TYPE_1$10,
                                        POLICY_REF_1 POLICY_REF_1$8,
                                        C_CLAIM_ID_SK C_CLAIM_ID_SK$16,
                                        PAY_APP_NO PAY_APP_NO$14,
                                        PAID_AMT PAID_AMT$6,
                                        SF_NO SF_NO$14,
                                        P_POLICY_NO_SK P_POLICY_NO_SK$16,
                                        SERVICE_TAX SERVICE_TAX$14,
                                        T_DATE_ID_SK T_DATE_ID_SK$16,
                                        SALVAGE_AMT SALVAGE_AMT$10
                                   FROM (SELECT DATE_TRUNC(''''DAY'''', AGGREGATOR_0$2.TRANS_DATE$11)
                                                   TRANS_DATE,
                                                AGGREGATOR_0$2.TRANS_AMT$8
                                                   RESERVE_AMT,
                                                AGGREGATOR_0$2.SF_TOTAL_TYPE$4
                                                   SF_TOTAL_TYPE_1,
                                                AGGREGATOR_0$2.POL_REF$4
                                                   POLICY_REF_1,
                                                AGGREGATOR_0$2.C_CLAIM_ID_SK$17
                                                   C_CLAIM_ID_SK,
                                                TO_NUMBER (NULL)
                                                                PAY_APP_NO,
                                                TO_NUMBER (NULL)
                                                                PAID_AMT,
                                                AGGREGATOR_0$2.SF_NO$15
                                                   SF_NO,
                                                AGGREGATOR_0$2.P_POLICY_NO_SK$17
                                                   P_POLICY_NO_SK,
                                                AGGREGATOR_0$2.SERVICE_TAX$15
                                                   SERVICE_TAX,
                                                AGGREGATOR_0$2.T_DATE_ID_SK$17
                                                   T_DATE_ID_SK,
                                                NVL (
                                                   AGGREGATOR_0$2.SALVAGE_AMT$11,
                                                   0)
                                                   SALVAGE_AMT
                                           FROM (  SELECT AGG_INPUT$4.TRANS_DATE$12
                                                             TRANS_DATE$11,
                                                          SUM (
                                                             AGG_INPUT$4.TRANS_AMT$9)
                                                             TRANS_AMT$8,
                                                          AGG_INPUT$4.SF_TYPE$9
                                                             SF_TYPE$8,
                                                          AGG_INPUT$4.SF_TOTAL_TYPE$5
                                                             SF_TOTAL_TYPE$4,
                                                          AGG_INPUT$4.POL_REF$5
                                                             POL_REF$4,
                                                          AGG_INPUT$4.C_CLAIM_ID_SK$18
                                                             C_CLAIM_ID_SK$17,
                                                          AGG_INPUT$4.PAY_APP_NO$16
                                                             PAY_APP_NO$15,
                                                          AGG_INPUT$4.SF_NO$16
                                                             SF_NO$15,
                                                          AGG_INPUT$4.P_POLICY_NO_SK$18
                                                             P_POLICY_NO_SK$17,
                                                          AGG_INPUT$4.SERVICE_TAX$16
                                                             SERVICE_TAX$15,
                                                          AGG_INPUT$4.T_DATE_ID_SK$18
                                                             T_DATE_ID_SK$17,
                                                          SUM (
                                                             AGG_INPUT$4.SALVAGE_AMT$12)
                                                             SALVAGE_AMT$11
                                                     FROM (SELECT DATE_TRUNC(''''DAY'''', CLM_TRANS_MV.TRANS_DATE)
                                                                     TRANS_DATE$12,
                                                                  CLM_TRANS_MV.TRANS_AMT
                                                                     TRANS_AMT$9,
                                                                  CLM_SUBFILES_MV.SF_TYPE
                                                                     SF_TYPE$9,
                                                                  TO_CHAR (
                                                                     INGRP1.R_RESERVE_TYPE_ID_SK)
                                                                     SF_TOTAL_TYPE$5,
                                                                  CLM_POL_BAS_UNION.POLICY_REF_1
                                                                     POL_REF$5,
                                                                 CLM_TRANS_MV.TRANS_AMT
                                                                     TRANS_AMT_GEN$2,
                                                                  ODS_CLAIM_DIM.C_CLAIM_ID_SK
                                                                     C_CLAIM_ID_SK$18,
                                                                  --case when  INGRP1.CLM_STATUS =''''PAID''''
                                                                  --and  INGRP1.PAY_STATUS =''''AP''''
                                                                  --and INGRP1.TRANS_AMT is not null
                                                                  --  then INGRP1.PAY_APP_NO
                                                                  --end
                                                                  BJ_GEN_CLM_APPRVL.PAY_APP_NO
                                                                     PAY_APP_NO$16,
                                                                  CLM_SUBFILES_MV.SF_NO
                                                                     SF_NO$16,
                                                                  ODS_POLICY_DIM.P_POLICY_NO_SK
                                                                     P_POLICY_NO_SK$18,
                                                                  BJ_GEN_CLM_APPRVL.SERVICE_TAX
                                                                     SERVICE_TAX$16,
                                                                  ODS_TIME_DIM.T_DATE_ID_SK
                                                                     T_DATE_ID_SK$18,
                                                                  CASE
                                                                     WHEN UPPER (
                                                                             UTILS.MY_TRIM (
                                                                                CLM_TRANS_MV.TRANS_TYPE)) =
                                                                             70
                                                                     THEN
                                                                        CLM_TRANS_MV.TRANS_AMT
                                                                  END
                                                                     SALVAGE_AMT$12
                                                             FROM (SELECT BJAZ_GEN_CLM_APPROVAL_MV.CLAIM_ID
                                                                             CLAIM_ID,
                                                                          BJAZ_GEN_CLM_APPROVAL_MV.PAY_STATUS
                                                                             PAY_STATUS,
                                                                          BJAZ_GEN_CLM_APPROVAL_MV.TRANS_AMT
                                                                             TRANS_AMT,
                                                                          BJAZ_GEN_CLM_APPROVAL_MV.SF_TOTAL_TYPE
                                                                             SF_TOTAL_TYPE,
                                                                          BJAZ_GEN_CLM_APPROVAL_MV.PAY_APP_NO
                                                                             PAY_APP_NO,
                                                                          BJAZ_GEN_CLM_APPROVAL_MV.TRANS_TYPE
                                                                             TRANS_TYPE,
                                                                          BJAZ_GEN_CLM_APPROVAL_MV.INT_REF
                                                                             INT_REF,
                                                                          BJAZ_GEN_CLM_APPROVAL_MV.SERVICE_TAX
                                                                             SERVICE_TAX
                                                                     FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_APPROVAL BJAZ_GEN_CLM_APPROVAL_MV) BJ_GEN_CLM_APPRVL,
                                                                  (SELECT CLM_SUBFILES_MV.SF_TYPE
                                                                             SF_TYPE,
                                                                          CLM_SUBFILES_MV.CLAIM_ID
                                                                             CLAIM_ID,
                                                                          CLM_SUBFILES_MV.SF_NO
                                                                             SF_NO
                                                                     FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_SUBFILES CLM_SUBFILES_MV) CLM_SUBFILES_MV,
                                                                  (SELECT SET_OPERATION_1$2.CLAIM_ID$2
                                                                             CLAIM_ID,
                                                                          SET_OPERATION_1$2.POLICY_REF_1$9
                                                                             POLICY_REF_1
                                                                     FROM (SELECT CLAIM_ID
                                                                                     CLAIM_ID$2,
                                                                                  POLICY_REF_1
                                                                                     POLICY_REF_1$9
                                                                             FROM (SELECT CLM_POL_BASES_MV.CLAIM_ID
                                                                                             CLAIM_ID,
                                                                                          CLM_POL_BASES_MV.POLICY_REF
                                                                                             POLICY_REF_1
                                                                                     FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_POL_BASES CLM_POL_BASES_MV
                                                                                    WHERE (CLM_POL_BASES_MV.POLICY_REF
                                                                                              IS NOT NULL)
                                                                                   UNION
                                                                                   SELECT CLM_POL_BASES_MV.CLAIM_ID
                                                                                             CLAIM_ID,
                                                                                          OCP_POLICY_BASES_MV.POLICY_REF
                                                                                             POLICY_REF_1
                                                                                     FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_POL_BASES CLM_POL_BASES_MV,
                                                                                          ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.OCP_POLICY_BASES OCP_POLICY_BASES_MV
                                                                                    WHERE     (CLM_POL_BASES_MV.CONTRACT_ID =
                                                                                                  OCP_POLICY_BASES_MV.CONTRACT_ID)
                                                                                          AND (CLM_POL_BASES_MV.POLICY_REF
                                                                                                  IS NULL)
                                                                                          AND (OCP_POLICY_BASES_MV.VERSION_NO =
                                                                                                  1))) SET_OPERATION_1$2) CLM_POL_BAS_UNION,
                                                                  (SELECT ODS_RESERVE_DIM.R_RESERVE_TYPE_ID_SK
                                                                             R_RESERVE_TYPE_ID_SK,
                                                                          ODS_RESERVE_DIM.R_RESERVE_TYPE
                                                                             R_RESERVE_TYPE
                                                                     FROM TRANSACTIONAL.ODS_RESERVE_DIM ODS_RESERVE_DIM) INGRP1,
                                                                  ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES CLM_BASES_MV,
                                                                  ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_TRANS CLM_TRANS_MV,
                                                                  TRANSACTIONAL.ODS_CLAIMTYPE_DIM ODS_CLAIMTYPE_DIM,
                                                                  TRANSACTIONAL.ODS_CLAIM_DIM ODS_CLAIM_DIM,
                                                                  PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM ODS_POLICY_DIM,
                                                                  PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM ODS_TIME_DIM
                                                            WHERE     (DATE_TRUNC(''''DAY'''', CLM_TRANS_MV.TRANS_DATE) =
                                                                            DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))
                                                                          - 1) --between DATE_TRUNC(''''DAY'''', CLAIM_FACT_INCR_NEW_9DEC.LAST_FROM_DATE) AND DATE_TRUNC(''''DAY'''', CLAIM_FACT_INCR_NEW_9DEC.LAST_TO_DATE) ) AND
                                                                  AND (CLM_BASES_MV.CLAIM_ID =
                                                                          CLM_TRANS_MV.CLAIM_ID)
                                                                  AND (CLM_TRANS_MV.CLAIM_ID =
                                                                          BJ_GEN_CLM_APPRVL.CLAIM_ID(+))
                                                                  AND (CLM_TRANS_MV.SF_TOTAL_TYPE =
                                                                          BJ_GEN_CLM_APPRVL.SF_TOTAL_TYPE(+))
                                                                  AND (CLM_TRANS_MV.CLAIM_ID =
                                                                          CLM_SUBFILES_MV.CLAIM_ID(+))
                                                                  AND (CLM_TRANS_MV.SF_NO =
                                                                          CLM_SUBFILES_MV.SF_NO(+))
                                                                  AND (CLM_TRANS_MV.CLAIM_ID =
                                                                          CLM_POL_BAS_UNION.CLAIM_ID(+))
                                                                  AND (ODS_CLAIMTYPE_DIM.CC_CC_CLAIMTYPE_ID =
                                                                          CLM_SUBFILES_MV.SF_TYPE)
                                                                  AND (CLM_BASES_MV.CLM_REF =
                                                                          ODS_CLAIM_DIM.C_CLAIM_NO)
                                                                  AND (INGRP1.R_RESERVE_TYPE(+) =
                                                                          CLM_TRANS_MV.SF_TOTAL_TYPE)
                                                                  AND (CLM_TRANS_MV.CLM_STATUS IN
                                                                          (''''AUTHOR''''))
                                                                  AND (DATE_TRUNC(''''DAY'''', CLM_TRANS_MV.TRANS_DATE) =
                                                                          ODS_TIME_DIM.T_DATE_DESC)
                                                                  AND (ODS_POLICY_DIM.P_POLICY_NUMBER =
                                                                          CLM_POL_BAS_UNION.POLICY_REF_1)
                                                                  AND (ODS_POLICY_DIM.P_CURRENT_INDICATOR =
                                                                          1)
                                                                  AND (CLM_TRANS_MV.INT_REF =
                                                                          BJ_GEN_CLM_APPRVL.INT_REF(+))
                                                                  AND upper(NVL(ASSIGNEE,''''X'''') ) <> (''''MIGRATION'''')) AGG_INPUT$4 ---UPPER(NVL(ASSIGNEE,''''X'''') ) <> (''''MIGRATION'''')  ADDED BY CHANDRAKANT ON 22-MAR-2021 TO EXCLUDE MIGRATION CASES FROM OPS
                                                 GROUP BY AGG_INPUT$4.T_DATE_ID_SK$18,
                                                          AGG_INPUT$4.P_POLICY_NO_SK$18,
                                                          AGG_INPUT$4.SF_NO$16,
                                                          AGG_INPUT$4.SERVICE_TAX$16,
                                                          AGG_INPUT$4.TRANS_DATE$12,
                                                          AGG_INPUT$4.POL_REF$5,
                                                          AGG_INPUT$4.SF_TOTAL_TYPE$5,
                                                          AGG_INPUT$4.PAY_APP_NO$16,
                                                          AGG_INPUT$4.SF_TYPE$9,
                                                          AGG_INPUT$4.C_CLAIM_ID_SK$18
                                                                                          ) AGGREGATOR_0$2
                                         UNION
                                         SELECT DATE_TRUNC(''''DAY'''', AGGREGATOR_1$2.TRANS_DATE$13)
                                                   TRANS_DATE,
                                                TO_NUMBER (NULL)
                                                                RESERVE_AMT,
                                                AGGREGATOR_1$2.SF_TOTAL_TYPE_1$11
                                                   SF_TOTAL_TYPE_1,
                                                AGGREGATOR_1$2.POLICY_REF_1$10
                                                   POLICY_REF_1,
                                                AGGREGATOR_1$2.C_CLAIM_ID_SK$19
                                                   C_CLAIM_ID_SK,
                                                AGGREGATOR_1$2.PAY_APP_NO$17
                                                   PAY_APP_NO,
                                                AGGREGATOR_1$2.TRANS_AMT$10
                                                   PAID_AMT,
                                                AGGREGATOR_1$2.SF_NO$17
                                                   SF_NO,
                                                AGGREGATOR_1$2.P_POLICY_NO_SK$19
                                                   P_POLICY_NO_SK,
                                                AGGREGATOR_1$2.SERVICE_TAX$17
                                                   SERVICE_TAX,
                                                AGGREGATOR_1$2.T_DATE_ID_SK$19
                                                   T_DATE_ID_SK,
                                                0
                                                 SALVAGE_AMT
                                           FROM (  SELECT AGG_INPUT$5.TRANS_DATE$14
                                                             TRANS_DATE$13,
                                                          SUM (
                                                             AGG_INPUT$5.TRANS_AMT$11)
                                                             TRANS_AMT$10,
                                                          AGG_INPUT$5.SF_NO$18
                                                             SF_NO$17,
                                                          AGG_INPUT$5.SF_TOTAL_TYPE_1$12
                                                             SF_TOTAL_TYPE_1$11,
                                                          AGG_INPUT$5.POLICY_REF_1$11
                                                             POLICY_REF_1$10,
                                                          AGG_INPUT$5.C_CLAIM_ID_SK$20
                                                             C_CLAIM_ID_SK$19,
                                                          AGG_INPUT$5.PAY_APP_NO$18
                                                             PAY_APP_NO$17,
                                                          AGG_INPUT$5.SF_TYPE$11
                                                             SF_TYPE$10,
                                                          AGG_INPUT$5.P_POLICY_NO_SK$20
                                                             P_POLICY_NO_SK$19,
                                                          AGG_INPUT$5.SERVICE_TAX$18
                                                             SERVICE_TAX$17,
                                                          AGG_INPUT$5.T_DATE_ID_SK$20
                                                             T_DATE_ID_SK$19
                                                     FROM (SELECT DATE_TRUNC(''''DAY'''', BJ_GEN_CLM_APPRVL.TRANS_DATE)
                                                                     TRANS_DATE$14,
                                                                  BJ_GEN_CLM_APPRVL.TRANS_AMT
                                                                     TRANS_AMT$11,
                                                                  CLM_SUBFILES_MV.SF_NO
                                                                     SF_NO$18,
                                                                  TO_CHAR (
                                                                     ODS_RESERVE_DIM.R_RESERVE_TYPE_ID_SK)
                                                                     SF_TOTAL_TYPE_1$12,
                                                                  CLM_OCP_POL_UNION.POLICY_REF_1
                                                                     POLICY_REF_1$11,
                                                                  ODS_CLAIM_DIM.C_CLAIM_ID_SK
                                                                     C_CLAIM_ID_SK$20,
                                                                  BJ_GEN_CLM_APPRVL.PAY_APP_NO
                                                                     PAY_APP_NO$18,
                                                                  CLM_SUBFILES_MV.SF_TYPE
                                                                     SF_TYPE$11,
                                                                  ODS_POLICY_DIM.P_POLICY_NO_SK
                                                                     P_POLICY_NO_SK$20,
                                                                  BJ_GEN_CLM_APPRVL.SERVICE_TAX
                                                                     SERVICE_TAX$18,
                                                                  ODS_TIME_DIM.T_DATE_ID_SK
                                                                     T_DATE_ID_SK$20
                                                             FROM (SELECT BJAZ_GEN_CLM_APPROVAL_MV.CLAIM_ID
                                                                             CLAIM_ID,
                                                                          BJAZ_GEN_CLM_APPROVAL_MV.SF_TOTAL_TYPE
                                                                             SF_TOTAL_TYPE,
                                                                          BJAZ_GEN_CLM_APPROVAL_MV.TRANS_TYPE
                                                                             TRANS_TYPE,
                                                                          BJAZ_GEN_CLM_APPROVAL_MV.PAY_APP_NO
                                                                             PAY_APP_NO,
                                                                          BJAZ_GEN_CLM_APPROVAL_MV.TRANS_AMT
                                                                             TRANS_AMT,
                                                                          BJAZ_GEN_CLM_APPROVAL_MV.PAY_STATUS
                                                                             PAY_STATUS,
                                                                          BJAZ_GEN_CLM_APPROVAL_MV.INT_REF
                                                                             INT_REF,
                                                                          BJAZ_GEN_CLM_APPROVAL_MV.TRANS_DATE
                                                                             TRANS_DATE,
                                                                          BJAZ_GEN_CLM_APPROVAL_MV.SERVICE_TAX
                                                                             SERVICE_TAX
                                                                     FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_GEN_CLM_APPROVAL BJAZ_GEN_CLM_APPROVAL_MV
                                                                    WHERE (DATE_TRUNC(''''DAY'''', BJAZ_GEN_CLM_APPROVAL_MV.TRANS_DATE) =
                                                                                DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || ''''''))
                                                                              - 1)) BJ_GEN_CLM_APPRVL, --between DATE_TRUNC(''''DAY'''', CLAIM_FACT_INCR_NEW_9DEC.LAST_FROM_DATE) AND DATE_TRUNC(''''DAY'''', CLAIM_FACT_INCR_NEW_9DEC.LAST_TO_DATE) )) BJ_GEN_CLM_APPRVL,
                                                                  (SELECT CLM_SUBFILES_MV.CLAIM_ID
                                                                             CLAIM_ID,
                                                                          CLM_SUBFILES_MV.SF_NO
                                                                             SF_NO,
                                                                          CLM_SUBFILES_MV.SF_TYPE
                                                                             SF_TYPE
                                                                     FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_SUBFILES CLM_SUBFILES_MV) CLM_SUBFILES_MV,
                                                                  (SELECT SET_OPERATION_1$2.CLAIM_ID$2
                                                                             CLAIM_ID,
                                                                          SET_OPERATION_1$2.POLICY_REF_1$9
                                                                             POLICY_REF_1
                                                                     FROM (SELECT CLAIM_ID
                                                                                     CLAIM_ID$2,
                                                                                  POLICY_REF_1
                                                                                     POLICY_REF_1$9
                                                                             FROM (SELECT CLM_POL_BASES_MV.CLAIM_ID
                                                                                             CLAIM_ID,
                                                                                          CLM_POL_BASES_MV.POLICY_REF
                                                                                             POLICY_REF_1
                                                                                     FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_POL_BASES CLM_POL_BASES_MV
                                                                                    WHERE (CLM_POL_BASES_MV.POLICY_REF
                                                                                              IS NOT NULL)
                                                                                   UNION
                                                                                   SELECT CLM_POL_BASES_MV.CLAIM_ID
                                                                                             CLAIM_ID,
                                                                                          OCP_POLICY_BASES_MV.POLICY_REF
                                                                                             POLICY_REF_1
                                                                                     FROM ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_POL_BASES CLM_POL_BASES_MV,
                                                                                          ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.OCP_POLICY_BASES OCP_POLICY_BASES_MV
                                                                                    WHERE     (CLM_POL_BASES_MV.CONTRACT_ID =
                                                                                                  OCP_POLICY_BASES_MV.CONTRACT_ID)
                                                                                          AND (CLM_POL_BASES_MV.POLICY_REF
                                                                                                  IS NULL)
                                                                                          AND (OCP_POLICY_BASES_MV.VERSION_NO =
                                                                                                  1))) SET_OPERATION_1$2) CLM_OCP_POL_UNION,
                                                                  (SELECT ODS_RESERVE_DIM.R_RESERVE_TYPE_ID_SK
                                                                             R_RESERVE_TYPE_ID_SK,
                                                                          ODS_RESERVE_DIM.R_RESERVE_TYPE
                                                                             R_RESERVE_TYPE
                                                                     FROM TRANSACTIONAL.ODS_RESERVE_DIM ODS_RESERVE_DIM) ODS_RESERVE_DIM,
                                                                  ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES CLM_BASES_MV,
                                                                  ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_TRANS CLM_TRANS_MV,
                                                                  TRANSACTIONAL.ODS_CLAIMTYPE_DIM ODS_CLAIMTYPE_DIM,
                                                                  TRANSACTIONAL.ODS_CLAIM_DIM ODS_CLAIM_DIM,
                                                                  PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM ODS_POLICY_DIM,
                                                                  PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM ODS_TIME_DIM
                                                            WHERE     (CLM_BASES_MV.CLAIM_ID =
                                                                          CLM_TRANS_MV.CLAIM_ID)
                                                                  AND (CLM_TRANS_MV.CLAIM_ID =
                                                                          BJ_GEN_CLM_APPRVL.CLAIM_ID(+))
                                                                  AND (CLM_TRANS_MV.SF_TOTAL_TYPE =
                                                                          BJ_GEN_CLM_APPRVL.SF_TOTAL_TYPE(+))
                                                                  AND (CLM_TRANS_MV.CLAIM_ID =
                                                                          CLM_SUBFILES_MV.CLAIM_ID(+))
                                                                  AND (CLM_TRANS_MV.SF_NO =
                                                                          CLM_SUBFILES_MV.SF_NO(+))
                                                                  AND (ODS_CLAIMTYPE_DIM.CC_CC_CLAIMTYPE_ID =
                                                                          CLM_SUBFILES_MV.SF_TYPE)
                                                                  AND (CLM_OCP_POL_UNION.CLAIM_ID(+) =
                                                                          CLM_TRANS_MV.CLAIM_ID)
                                                                  AND (CLM_BASES_MV.CLM_REF =
                                                                          ODS_CLAIM_DIM.C_CLAIM_NO)
                                                                  AND (UPPER (
                                                                          BJ_GEN_CLM_APPRVL.PAY_STATUS) not in
                                                                          (''''DELETED'''', ''''APP_DEL''''))
                                                                  AND (CLM_TRANS_MV.CLM_STATUS IN
                                                                          (''''AP'''',''''FA''''))
                                                                  AND (BJ_GEN_CLM_APPRVL.SF_TOTAL_TYPE <>
                                                                          99)
                                                                  AND (DATE_TRUNC(''''DAY'''', BJ_GEN_CLM_APPRVL.TRANS_DATE) =
                                                                          ODS_TIME_DIM.T_DATE_DESC)
                                                                  AND (BJ_GEN_CLM_APPRVL.TRANS_TYPE IN
                                                                          (10,
                                                                           20,
                                                                           30))
                                                                  AND (ODS_RESERVE_DIM.R_RESERVE_TYPE(+) =
                                                                          BJ_GEN_CLM_APPRVL.SF_TOTAL_TYPE)
                                                                  AND (ODS_POLICY_DIM.P_POLICY_NUMBER =
                                                                          CLM_OCP_POL_UNION.POLICY_REF_1)
                                                                  AND (ODS_POLICY_DIM.P_CURRENT_INDICATOR =
                                                                          1)
                                                                  AND (CLM_TRANS_MV.INT_REF =
                                                                          BJ_GEN_CLM_APPRVL.INT_REF(+))
                                                                  AND upper(NVL(ASSIGNEE,''''X'''') ) <> (''''MIGRATION'''')) AGG_INPUT$5 ---UPPER(NVL(ASSIGNEE,''''X'''') ) <> (''''MIGRATION'''')  ADDED BY CHANDRAKANT ON 22-MAR-2021 TO EXCLUDE MIGRATION CASES FROM OPS
                                                 GROUP BY AGG_INPUT$5.P_POLICY_NO_SK$20,
                                                          AGG_INPUT$5.SF_TOTAL_TYPE_1$12,
                                                          AGG_INPUT$5.T_DATE_ID_SK$20,
                                                          AGG_INPUT$5.SF_TYPE$11,
                                                          AGG_INPUT$5.SERVICE_TAX$18,
                                                          AGG_INPUT$5.POLICY_REF_1$11,
                                                          AGG_INPUT$5.SF_NO$18,
                                                          AGG_INPUT$5.PAY_APP_NO$18,
                                                          AGG_INPUT$5.TRANS_DATE$14,
                                                          AGG_INPUT$5.C_CLAIM_ID_SK$20
                                                                                          ) AGGREGATOR_1$2)) SET_OPERATION$2
                         UNION
                         SELECT 0
                                 RESERVE_AMT,
                                9001
                                    SF_TOTAL_TYPE_1,
                                AGGREGATOR$2.C_CLAIM_ID_SK$21
                                   C_CLAIM_ID_SK,
                                TO_NUMBER (NULL)
                                                PAY_APP_NO,
                                0
                                 PAID_AMT,
                                1
                                 SF_NO,
                                AGGREGATOR$2.P_POLICY_NO_SK$21
                                   P_POLICY_NO_SK,
                                AGGREGATOR$2.T_DATE_ID_SK$21
                                                                T_DATE_ID_SK,
                                0
                                 SERVICE_TAX,
                                -1 * (AGGREGATOR$2.BASE_AMT$6)
                                                                  BASE_AMT,
                                0
                                 SALVAGE_AMT
                           FROM (  SELECT (BJAZ_RECEIPTS_EXTN_MV.BASE_AMT
                                                                             )
                                             BASE_AMT$6,
                                          (ODS_CLAIM_DIM.C_CLAIM_ID_SK
                                                                          )
                                             C_CLAIM_ID_SK$21,
                                          (ODS_POLICY_DIM.P_POLICY_NO_SK
                                                                            )
                                             P_POLICY_NO_SK$21,
                                          MAX ( (ODS_TIME_DIM.T_DATE_ID_SK
                                                                              ))
                                             T_DATE_ID_SK$21
                                     FROM TRANSACTIONAL.ODS_CLAIM_DIM ODS_CLAIM_DIM,
                                          PROD_DWH_MIGRATED_DB.PROD.ODS_POLICY_DIM ODS_POLICY_DIM,
                                          PROD_DWH_MIGRATED_DB.PROD.ODS_TIME_DIM ODS_TIME_DIM,
                                          ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_RECEIPTS_EXTN BJAZ_RECEIPTS_EXTN_MV,
                                          ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.BJAZ_RECEIPTS BJAZ_RECEIPTS_MV,
                                          ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_POL_BASES CLM_POL_BASES_MV,
                                          ''|| MIRROR_DB ||''.OPUS_GG_DWHSTAGE.CLM_BASES CLM_BASES_MV
                                    WHERE     (DATE_TRUNC(''''DAY'''', BJAZ_RECEIPTS_MV.RECD_DATE) =
                                                  DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 1) -- between DATE_TRUNC(''''DAY'''', CLAIM_FACT_INCR_NEW_9DEC.LAST_FROM_DATE) AND DATE_TRUNC(''''DAY'''', CLAIM_FACT_INCR_NEW_9DEC.LAST_TO_DATE) ) AND
                                          AND (BJAZ_RECEIPTS_EXTN_MV.RECEIPT_NO =
                                                  BJAZ_RECEIPTS_MV.RECEIPT_NO)
                                          AND (BJAZ_RECEIPTS_EXTN_MV.CLAIM_REF
                                                  IS NOT NULL)
                                          AND (BJAZ_RECEIPTS_EXTN_MV.BASE_AMT
                                                  IS NOT NULL)
                                          AND (BJAZ_RECEIPTS_EXTN_MV.CLAIM_REF =
                                                  CLM_BASES_MV.CLM_REF)
                                          AND (CLM_BASES_MV.CLAIM_ID =
                                                  CLM_POL_BASES_MV.CLAIM_ID)
                                          AND (CLM_POL_BASES_MV.POLICY_REF =
                                                  ODS_POLICY_DIM.P_POLICY_NUMBER)
                                          AND (CLM_BASES_MV.CLM_REF =
                                                  ODS_CLAIM_DIM.C_CLAIM_NO)
                                          AND (DATE_TRUNC(''''DAY'''', BJAZ_RECEIPTS_MV.RECD_DATE) =
                                                  ODS_TIME_DIM.T_DATE_DESC)
                                          AND (ODS_POLICY_DIM.P_CURRENT_INDICATOR =
                                                  1)
                                 GROUP BY (BJAZ_RECEIPTS_EXTN_MV.BASE_AMT
                                                                             ),
                                          (ODS_POLICY_DIM.P_POLICY_NO_SK
                                                                            ),
                                          (ODS_CLAIM_DIM.C_CLAIM_ID_SK
                                                                          )
                                                                           ) AGGREGATOR$2)) SET_OPERATION_0$2
       --where  SET_OPERATION_0$2.SF_TOTAL_TYPE_1$9 is not null
       GROUP BY SET_OPERATION_0$2.C_CLAIM_ID_SK$15,
                SET_OPERATION_0$2.P_POLICY_NO_SK$15,
                SET_OPERATION_0$2.T_DATE_ID_SK$15,
                SET_OPERATION_0$2.SF_TOTAL_TYPE_1$9,
                SET_OPERATION_0$2.SF_NO$13,
                SET_OPERATION_0$2.PAY_APP_NO$13)'';
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