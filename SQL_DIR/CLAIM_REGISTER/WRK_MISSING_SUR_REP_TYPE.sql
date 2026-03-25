CREATE OR REPLACE PROCEDURE TRANSACTIONAL.WRK_MISSING_SUR_REP_TYPE("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE

v_sqltext VARCHAR;

BEGIN
v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_SUR_REP_MISSING_UPDATE'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT
         INTO  INTERMEDIATE.WRK_SUR_REP_MISSING_UPDATE
      SELECT C_CLAIM_ID
        FROM TRANSACTIONAL.MV_CLAIM_REGISTER
       WHERE     TOP_INDICATOR = ''''Y''''
             AND C_SUR_NAME IS NOT NULL
             AND T_DATE_DESC >= DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''')) - 10
             AND C_SUR_NAME NOT LIKE ''''%SUR%''''
      UNION
      SELECT C_CLAIM_ID
        FROM TRANSACTIONAL.MV_CLAIM_REGISTER
       WHERE     TOP_INDICATOR = ''''Y''''
             AND C_REP_NAME IS NOT NULL
             AND T_DATE_DESC >= DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''')) - 10
             AND (    C_REP_NAME NOT LIKE ''''%REP%''''
                  AND C_REP_NAME NOT LIKE ''''%BAPW%'''')
      UNION
      SELECT A.CLAIM_ID
        FROM '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.BJAZ_WB_CLM_STATUS_REPOSITORY A, '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.CLM_BASES B, TRANSACTIONAL.ODS_CLAIM_DIM
       WHERE     A.CLAIM_ID = B.CLAIM_ID
             AND B.CLM_REF = C_CLAIM_NO
             AND DATE_TRUNC(''''DAY'''', MSG_DATE) >= DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || '''''')) - 10
             AND (C_SUR_NAME IS NULL OR C_REP_NAME IS NULL)
             AND (   STATUS_MSG LIKE ''''Surveyor Deputed%''''
                  OR STATUS_MSG LIKE ''''Repairer Appointer%'''')'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_REP_SUR_ADV_STG'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_REP_SUR_ADV_STG
        SELECT
              CLM_REF CLM_REF,
               1 SUPP_ID,
               DD.CLAIM_ID,
               MAX (
                  CASE
                     WHEN CLM_INTERESTED_PARTIES.IP_TYPE IN
                             (''''BAPW'''', ''''TIEUPREP'''', ''''REP'''')
                     THEN
                           (DECODE (
                               PARTNER_TYPE,
                               ''''I'''', INSTITUTION_NAME,
                                  FIRST_NAME
                               || '''' ''''
                               || MIDDLE_NAME
                               || '''' ''''
                               || SURNAME))
                        || ''''|''''
                        || SUPP_ID
                        || ''''|''''
                        || SUPP_TYPE
                  END)
                  AS REP_NAME,
               MAX (
                  CASE
                     WHEN '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.CLM_INTERESTED_PARTIES.IP_TYPE IN
                             (''''INH_SUR'''', ''''SUR'''')
                     THEN
                           (DECODE (
                               PARTNER_TYPE,
                               ''''I'''', INSTITUTION_NAME,
                                  FIRST_NAME
                               || '''' ''''
                               || MIDDLE_NAME
                               || '''' ''''
                               || SURNAME))
                        || ''''|''''
                        || SUPP_ID
                        || ''''|''''
                        || SUPP_TYPE
                  END)
                  SUR_NAME,
               MAX (
                  CASE
                     WHEN '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.CLM_INTERESTED_PARTIES.IP_TYPE IN (''''LAW'''')
                     THEN
                           (DECODE (
                               PARTNER_TYPE,
                               ''''I'''', INSTITUTION_NAME,
                                  FIRST_NAME
                               || '''' ''''
                               || MIDDLE_NAME
                               || '''' ''''
                               || SURNAME))
                        || ''''|''''
                        || SUPP_ID
                        || ''''|''''
                        || SUPP_TYPE
                  END)
                  ADV_NAME
          FROM '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.CLM_INTERESTED_PARTIES,

'' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.CP_PARTNERS,
	       '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.CLM_SUPPLIERS BB,
	       '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.CLM_BASES DD
	       WHERE
'' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.CP_PARTNERS.PART_ID = BB.PART_ID(+)
	       AND DD.CLAIM_ID = '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.CLM_INTERESTED_PARTIES.CLAIM_ID
               AND '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.CLM_INTERESTED_PARTIES.PART_ID =

'' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.CP_PARTNERS.PART_ID
               AND IP_TYPE = SUPP_TYPE
               AND BB.SUPP_STATUS(+) NOT IN (''''3'''', ''''5'''')
               AND DD.CLAIM_ID IN (SELECT * FROM INTERMEDIATE.WRK_SUR_REP_MISSING_UPDATE)
               AND (IP_NO,
                    DD.CLAIM_ID,
                    CASE
                       WHEN IP_TYPE IN (''''BAPW'''', ''''TIEUPREP'''', ''''REP'''') THEN ''''REP''''
                       WHEN IP_TYPE IN (''''INH_SUR'''', ''''SUR'''') THEN ''''SUR''''
                       WHEN IP_TYPE IN (''''LAW'''') THEN ''''LAW''''
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
                           FROM '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.CLM_INTERESTED_PARTIES K, '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.CLM_SUPPLIERS KK
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
                       GROUP BY K.CLAIM_ID,
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
                                END)
      GROUP BY CLM_REF, DD.CLAIM_ID'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.ODS_CLAIM_DIM
as target
            SET C_ADV_NAME = src.ADV_NAME,
            C_REP_NAME = src.REP_NAME,
            C_SUR_NAME = src.SUR_NAME,
            ETL_REFRESH_AT = CURRENT_TIMESTAMP()
FROM
(
SELECT * FROM INTERMEDIATE.WRK_REP_SUR_ADV_STG
) AS src
WHERE target.C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;


v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER
as target
            SET C_ADV_NAME = src.ADV_NAME,
            C_REP_NAME = src.REP_NAME,
            C_SUR_NAME = src.SUR_NAME,
            CHANGE_DATE = CURRENT_DATE,
            TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE || ''''''))
FROM
(
SELECT * FROM INTERMEDIATE.WRK_REP_SUR_ADV_STG
) AS src
WHERE target.C_CLAIM_NO = src.CLM_REF'';
EXECUTE IMMEDIATE v_sqltext;

EXECUTE IMMEDIATE ''COMMIT'';
	RETURN ''Procedure executed successfully'';

	EXCEPTION
		WHEN OTHER THEN
			EXECUTE IMMEDIATE ''ROLLBACK'';
			RAISE ;
			RETURN ''Error occurred: '' || SQLERRM || ''\\\\\\\\n'' || ''SQL: '' || ''\\\\\\\\n'' || v_sqltext;


END;
';