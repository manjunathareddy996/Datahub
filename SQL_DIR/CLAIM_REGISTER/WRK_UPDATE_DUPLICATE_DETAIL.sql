CREATE OR REPLACE PROCEDURE TRANSACTIONAL.WRK_UPDATE_DUPLICATE_DETAIL("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE
v_sqltext VARCHAR;

/*  Author      : Chandrakant khemnar*/
/*  Create Date : 10-feb-2020*/
/*  Purpose     :  to update duplicate policy detail*/
/*----------------------------------------------------------------------------------------------------------------------------*/
l_start NUMBER;
BEGIN
/*l_start := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/


v_sqltext:= ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_MV_CR_DUP_BASE1'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_MV_CR_DUP_BASE1
      SELECT c_claim_no,
             P_RISK_INC_DATE,
             P_RISK_EXPIRY_DATE,
             P_POLICY_ISSUE_DATE,
             P_REN_INDICATOR,
             P_GC_PLAN,
             CASE_YEAR,
             I_IMD_DESC,
             I_IMD_NAME,
             P_SUB_IMD,
             IMD_CHANNEL,
             V_VEHICLE_MAKE,
             M_VEHICLE_MODEL,
             PT_PARTNER_ID,
             PT_PARTNER_DESC,
             ren_roll_nb_flag,
             C_COMMENTS,
             P_YEAR_OF_MANU,
             P_REGN_NO,
             P_CHASSIS_NUMBER,
             P_ENGINE_NUMBER,
             TP_COMPRO_DEFENSE,
             top_indicator
        FROM TRANSACTIONAL.MV_CLAIM_REGISTER
       WHERE t_date_desc = DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE|| '''''')) - 1'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_MV_CR_DUP_BASE2'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_MV_CR_DUP_BASE2
      SELECT DISTINCT c_claim_no,
                      P_RISK_INC_DATE,
                      P_RISK_EXPIRY_DATE,
                      P_POLICY_ISSUE_DATE,
                      P_REN_INDICATOR,
                      P_GC_PLAN,
                      CASE_YEAR,
                      I_IMD_DESC,
                      I_IMD_NAME,
                      P_SUB_IMD,
                      IMD_CHANNEL,
                      V_VEHICLE_MAKE,
                      M_VEHICLE_MODEL,
                      PT_PARTNER_ID,
                      PT_PARTNER_DESC,
                      ren_roll_nb_flag,
                      C_COMMENTS,
                      P_YEAR_OF_MANU,
                      P_REGN_NO,
                      P_CHASSIS_NUMBER,
                      P_ENGINE_NUMBER,
                      TP_COMPRO_DEFENSE
        FROM TRANSACTIONAL.MV_CLAIM_REGISTER
       WHERE c_claim_no IN
                (SELECT DISTINCT c_claim_no FROM INTERMEDIATE.WRK_MV_CR_DUP_BASE1)'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_MV_CR_DUP_UPDT1'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_MV_CR_DUP_UPDT1
      SELECT c_claim_no,
             P_RISK_INC_DATE,
             P_RISK_EXPIRY_DATE,
             P_POLICY_ISSUE_DATE,
             P_REN_INDICATOR,
             P_GC_PLAN,
             CASE_YEAR,
             I_IMD_DESC,
             I_IMD_NAME,
             P_SUB_IMD,
             IMD_CHANNEL,
             V_VEHICLE_MAKE,
             M_VEHICLE_MODEL,
             PT_PARTNER_ID,
             PT_PARTNER_DESC,
             ren_roll_nb_flag,
             C_COMMENTS,
             P_YEAR_OF_MANU,
             P_REGN_NO,
             P_CHASSIS_NUMBER,
             P_ENGINE_NUMBER,
             TP_COMPRO_DEFENSE
        FROM TRANSACTIONAL.MV_CLAIM_REGISTER
       WHERE     c_claim_no IN (  SELECT c_claim_no
                                    FROM INTERMEDIATE.WRK_MV_CR_DUP_BASE2
                                GROUP BY c_claim_no
                                  HAVING COUNT (*) > 1)
             AND top_indicator = ''''Y'''''';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext := ''UPDATE TRANSACTIONAL.MV_CLAIM_REGISTER
as target
            SET P_RISK_INC_DATE = src.P_RISK_INC_DATE,
            P_RISK_EXPIRY_DATE = src.P_RISK_EXPIRY_DATE,
            P_POLICY_ISSUE_DATE = src.P_POLICY_ISSUE_DATE,
            P_REN_INDICATOR = src.P_REN_INDICATOR,
            P_GC_PLAN = src.P_GC_PLAN,
            CASE_YEAR = src.CASE_YEAR,
            I_IMD_DESC = src.I_IMD_DESC,
            I_IMD_NAME = src.I_IMD_NAME,
            P_SUB_IMD = src.P_SUB_IMD,
            IMD_CHANNEL = src.IMD_CHANNEL,
            V_VEHICLE_MAKE = src.V_VEHICLE_MAKE,
            M_VEHICLE_MODEL = src.M_VEHICLE_MODEL,
            PT_PARTNER_ID = src.PT_PARTNER_ID,
            PT_PARTNER_DESC = src.PT_PARTNER_DESC,
            REN_ROLL_NB_FLAG = src.REN_ROLL_NB_FLAG,
            C_COMMENTS = src.C_COMMENTS,
            P_YEAR_OF_MANU = src.P_YEAR_OF_MANU,
            P_REGN_NO = src.P_REGN_NO,
            P_CHASSIS_NUMBER = src.P_CHASSIS_NUMBER,
            P_ENGINE_NUMBER = src.P_ENGINE_NUMBER,
            TP_COMPRO_DEFENSE = src.TP_COMPRO_DEFENSE,
            CHANGE_DATE = TO_DATE(''''''|| T_DATE|| ''''''),
            TRUNC_CHANGE_DATE = DATE_TRUNC(''''DAY'''', TO_DATE(''''''|| T_DATE|| ''''''))
FROM
(SELECT * FROM INTERMEDIATE.WRK_MV_CR_DUP_UPDT1) AS src
WHERE target.C_CLAIM_NO = src.C_CLAIM_NO'';
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