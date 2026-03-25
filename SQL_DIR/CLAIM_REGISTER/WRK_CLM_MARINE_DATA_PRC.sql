CREATE OR REPLACE PROCEDURE INTERMEDIATE.WRK_CLM_MARINE_DATA_PRC("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE
	l_start number;
	v_sqltext VARCHAR;
BEGIN

	v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_MARINE_DATA_STG1'';
	EXECUTE IMMEDIATE v_sqltext;

	v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_MARINE_DATA_STG1
		  SELECT C_CLAIM_NO
			FROM TRANSACTIONAL.MV_CLAIM_REGISTER A
		   WHERE     P_DEPARTMENT_DESC = ''''MARINE''''
				 AND T_DATE_DESC >= DATE_TRUNC(''''DAY'''', TO_DATE('''''' || T_DATE || '''''')) - 5
				 AND TOP_INDICATOR = ''''Y'''''';
	EXECUTE IMMEDIATE v_sqltext;

	v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_MARINE_DATA_STG2'';
	EXECUTE IMMEDIATE v_sqltext;

	v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_MARINE_DATA_STG2
			SELECT
				  C_CLAIM_NO,
				   a.CLM_STATUS,
				   C_OFF_LOC_ID,
				   C_CAUSE_OF_LOSS,
				   P_POLICY_NUMBER,
				   P_POLICY_STATUS,
				   P_PRODUCT_ID,
				   P_DEPARTMENT_DESC,
				   P_MASTER_POLICY_NO,
				   P_COINSURANCE_TYPE,
				   PT_PARTNER_DESC,
				   P_RISK_INC_DATE,
				   P_RISK_EXPIRY_DATE,
				   C_LOSS_DATE,
				   C_INTI_DATE,
				   I_IMD_NAME,
				   I_IMD_DESC,
				   P_SUB_IMD,
				   C_SETTLEMNT_TYPE,
				   C_PLACE_OF_LOSS,
				   C_LANDMARK,
				   C_AREA,
				   C_STATE,
				   C_CITY,
				   C_PINCODE,
				   C_JOURNEY_FROM,
				   C_JOURNEY_TO,
				   C_CONSIGNEE_NAME,
				   C_SURVEY_LOCATION,
				   C_GOODS_DETAILS,
				   POL_GLOBAL_FLAG,
				   COINS_OUR_SHARE,
				   SUM (
					  CASE
						 WHEN UPPER (R_RESERVE_GROUP_DESC) LIKE ''''%EXPENSE%''''
						 THEN
							NVL (OS_AMT, 0)
					  END)
					  exp_os_amt,
				   SUM (
					  CASE
						 WHEN UPPER (R_RESERVE_GROUP_DESC) LIKE ''''%EXPENSE%''''
						 THEN
							NVL (PAID_CLAIM, 0)
					  END)
					  exp_paid_amt,
				   SUM (
					  CASE
						 WHEN UPPER (R_RESERVE_GROUP_DESC) LIKE ''''%EXPENSE%''''
						 THEN
							NVL (reserve_amount, 0)
					  END)
					  exp_reserve_amt,
				   VOLUNTARY_EXCESS,
				   COMPULSORY_EXCESS,
				   SUM (NVL (PAID_CLAIM, 0)) PAID_CLAIM,
				   SUM (NVL (OS_AMT, 0)) OS_AMT,
				   SUM (NVL (RESERVE_AMOUNT, 0)) RESERVE_AMOUNT,
				   CONSIGNEE_ADDR,
				   CONSIGNEE_PHONE,
				   d.CONTACT_PERSON,
				   CONTACT_NO,
				   SURVEY_LOCATION,
				   LOSS_VALUE,
				   REMARKS,
				   PLACE_OF_LOSS,
				   CONSIGNER_NAME,
				   TYPE_OF_CLAIM,
				   LORRY_RECEIPT_DATE,

                   CASE WHEN CLM_SETTLEMENT_TYPE=1 THEN ''''Standard Settlement''''
                   WHEN CLM_SETTLEMENT_TYPE=2 THEN ''''Non-Standard Settlement''''
                   ELSE NULL END AS CLM_SETTLEMENT_TYPE,

				   -- CLM_SETTLEMENT_TYPE,

                  CASE WHEN TRANSACTION_TYPE=1 THEN ''''Sale''''
                  WHEN TRANSACTION_TYPE=2 THEN ''''Purchase''''
                  WHEN TRANSACTION_TYPE=3 THEN ''''Stock Transfer''''
                  WHEN TRANSACTION_TYPE=4 THEN ''''goods return''''
                  WHEN TRANSACTION_TYPE=5 THEN ''''Rejected''''
                  WHEN TRANSACTION_TYPE=6 THEN ''''sample Cargo''''
                  ELSE NULL END TRANSACTION_TYPE,

				  -- TRANSACTION_TYPE,

                CASE WHEN MODE_OF_TRANSPORT=1 THEN ''''Rail''''
               WHEN MODE_OF_TRANSPORT=2 THEN ''''Road''''
               WHEN MODE_OF_TRANSPORT=3 THEN ''''Rail/Road''''
               WHEN MODE_OF_TRANSPORT=4 THEN ''''Air''''
               WHEN MODE_OF_TRANSPORT=5 THEN ''''Courier''''
               WHEN MODE_OF_TRANSPORT=6 THEN ''''Ocean Transit''''
               WHEN MODE_OF_TRANSPORT=7 THEN ''''Composite''''
               WHEN MODE_OF_TRANSPORT=8 THEN ''''Inland Water''''
               WHEN MODE_OF_TRANSPORT=9 THEN ''''Coastal''''
               WHEN MODE_OF_TRANSPORT=99 THEN ''''Any other''''
               ELSE NULL END MODE_OF_TRANSPORT,


				  -- MODE_OF_TRANSPORT,
				   NATURE_OF_LOSS,

              CASE WHEN LOAD_TYPE=1 THEN ''''Partial Load''''
              WHEN LOAD_TYPE=2 THEN ''''Full Truck Load''''
              WHEN LOAD_TYPE=3 THEN ''''LTL (Less than Truck load)''''
              WHEN LOAD_TYPE=4 THEN ''''FTL (Full Truck load)''''
              WHEN LOAD_TYPE=5 THEN ''''FCL (Full Container Load)''''
              WHEN LOAD_TYPE=6 THEN ''''LCL (Less-Than-Container Load)''''
              ELSE NULL END LOAD_TYPE,


				   -- LOAD_TYPE,

                CASE WHEN PACKAGING_TYPE=11 THEN ''''Second Hand single Gunny bags Single gunny2nd''''
               WHEN PACKAGING_TYPE=20 THEN ''''New Double Gunny Bag Nw Double Gunny''''
               WHEN PACKAGING_TYPE=21 THEN ''''Second hand double gunny bags Double gunny2nd''''
               WHEN PACKAGING_TYPE=30 THEN ''''High Density Polythene Bags HDP Lined Bag''''
               WHEN PACKAGING_TYPE=50 THEN ''''Paper Bags - 5 Ply and over Paper-5 Ply''''
               WHEN PACKAGING_TYPE=60 THEN ''''Paper Bags - less than 5 ply Paper < 5 Ply''''
               WHEN PACKAGING_TYPE=80 THEN ''''Poly propelene bags PP Bags''''
               WHEN PACKAGING_TYPE=110 THEN ''''Bales(Fully Pressed) Bales(F Press)''''
               WHEN PACKAGING_TYPE=200 THEN ''''Barrel/Cask - New Bar/Cask New''''
               WHEN PACKAGING_TYPE=210 THEN ''''Barrel/Cask - Second Hand Bar/Cask 2nd''''
               WHEN PACKAGING_TYPE=300 THEN ''''Barrel/Cask - Bundles Bundles''''
               WHEN PACKAGING_TYPE=310 THEN ''''Bulk - Dry Cargo Bulk Dry Cargo''''
               WHEN PACKAGING_TYPE=320 THEN ''''Bulk - Liquid (Tanker) Bulk Liquid''''
               WHEN PACKAGING_TYPE=400   THEN ''''Drums - New Fibre Drums New Fibre Drum''''
               WHEN PACKAGING_TYPE=410 THEN ''''Drums - Second Hand Fibre Drums 2nd Fibre Drum''''
               WHEN PACKAGING_TYPE=420 THEN ''''Drums - New Metallic Drums New Metal Drum''''
               WHEN PACKAGING_TYPE=430 THEN ''''Drums - Second Hand Metallic Drums 2nd Metal Drum''''
               WHEN PACKAGING_TYPE=501 THEN ''''Container - Fully Enclosed Cont-Full Encl''''
               WHEN PACKAGING_TYPE=511 THEN ''''Container - Open Top Cont-Open Top''''
               WHEN PACKAGING_TYPE=521 THEN ''''Container - Insulated Cont-Insulated''''
               WHEN PACKAGING_TYPE=531 THEN ''''Container - Glass Carbuoys Cont-Glass carb''''
               WHEN PACKAGING_TYPE=541 THEN ''''Container - Cartons Cont-Cartons''''
               WHEN PACKAGING_TYPE=601 THEN ''''Special Purpose - Refrigerated Sp Pur-Refrig''''
               WHEN PACKAGING_TYPE=700 THEN ''''Carbuoy/Jars Carbuoy/Jars''''
               WHEN PACKAGING_TYPE=710 THEN ''''Cardboard Box/Carton Card Box/Carton''''
               WHEN PACKAGING_TYPE=720 THEN ''''Cylinder Cylinder''''
               WHEN PACKAGING_TYPE=740 THEN ''''Lift Van Lift Van''''
               WHEN PACKAGING_TYPE=750 THEN ''''Loose/Unpacked Loose/Unpacked''''
               WHEN PACKAGING_TYPE=770 THEN ''''Pallets Pallets''''
               WHEN PACKAGING_TYPE=790 THEN ''''Refrigerated/Cooled/Chilled Cooled/Chilled''''
               WHEN PACKAGING_TYPE=800 THEN ''''Rolls(Paper) Rolls(Paper)''''
               WHEN PACKAGING_TYPE=830 THEN ''''Skids Skids''''
               WHEN PACKAGING_TYPE=840 THEN ''''Tins Tins''''
               WHEN PACKAGING_TYPE=841 THEN ''''Polypacks polypacks''''
               WHEN PACKAGING_TYPE=850 THEN ''''Unitised Unitised''''
               WHEN PACKAGING_TYPE=860 THEN ''''Tankers Tankers''''
               WHEN PACKAGING_TYPE=899 THEN ''''Others Others''''
               WHEN PACKAGING_TYPE=900 THEN ''''Wooden Cases Wooden Cases''''
               WHEN PACKAGING_TYPE=910 THEN ''''Plywood chests for Tea with Aluminium lining Tea Chests''''
               WHEN PACKAGING_TYPE=920 THEN ''''Wooden Crates Wooden Crates''''
               WHEN PACKAGING_TYPE=930 THEN ''''Bottles in Cases Bottles - Cases''''
               WHEN PACKAGING_TYPE=940 THEN ''''Bottles in Cartons Bottles-Cartons''''
               WHEN PACKAGING_TYPE=990 THEN ''''Others Others''''
               ELSE NULL END PACKAGING_TYPE,


				   -- PACKAGING_TYPE,
				   SUPPLIER_ID,

              CASE WHEN  REASON_NON_STD=1 THEN ''''No Damage certificate''''
              WHEN  REASON_NON_STD=1 THEN ''''NNo Letter of Subrogation''''
              WHEN  REASON_NON_STD=1 THEN ''''Courier Transit''''
              WHEN  REASON_NON_STD=1 THEN ''''Recovery Rights Prejudiced''''
              WHEN  REASON_NON_STD=1 THEN ''''thers''''
              ELSE NULL END REASON_NON_STD,




				  -- REASON_NON_STD,
				   NON_STD_PER,
				   TRANSPORTER_NAME,
				   FROM_PLACE,
				   TO_PLACE,
				   GOODS_DETAILS,
				   TYPES_OF_GOODS_DAMAGED,
				   PACKAGING_TYPE_REMARK,
				   JOURNEY_FROM,
				   JOURNEY_TO,
				   BL_RR_LR_AWB_NO,
				   C_SUR_NAME,
				   C_COMMENTS,
				   C_SPECIAL_COMMENTS,
				   C_OMBSMAN_FLAG,
				   C_NAME_OF_IN1,
				   C_REGN_DATE,
				   POLICY_LOCATION_ID,
				   V_VEHICLE_TYPE
			  FROM TRANSACTIONAL.MV_CLAIM_REGISTER a,
				   '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.BJAZ_POLICY_SUMMARY b,
				   '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.CLM_BASES c,
				   '' || MIRROR_DB || ''.OPUS_GG_DWHSTAGE.BJAZ_CLM_MRN_EXTN d
			 WHERE     a.c_claim_no = c.clm_ref
				   AND c.claim_id = d.claim_id
				   AND P_POLICY_NUMBER = POLICY_REF(+)
				   AND C_CLAIM_NO IN (SELECT * FROM INTERMEDIATE.WRK_MARINE_DATA_STG1)
		  GROUP BY C_CLAIM_NO,
				   a.CLM_STATUS,
				   C_OFF_LOC_ID,
				   C_CAUSE_OF_LOSS,
				   P_POLICY_NUMBER,
				   P_POLICY_STATUS,
				   P_PRODUCT_ID,
				   P_DEPARTMENT_DESC,
				   P_MASTER_POLICY_NO,
				   P_COINSURANCE_TYPE,
				   PT_PARTNER_DESC,
				   P_RISK_INC_DATE,
				   P_RISK_EXPIRY_DATE,
				   C_LOSS_DATE,
				   C_INTI_DATE,
				   I_IMD_NAME,
				   I_IMD_DESC,
				   P_SUB_IMD,
				   C_SETTLEMNT_TYPE,
				   C_PLACE_OF_LOSS,
				   C_LANDMARK,
				   C_AREA,
				   C_STATE,
				   C_CITY,
				   C_PINCODE,
				   C_JOURNEY_FROM,
				   C_JOURNEY_TO,
				   C_CONSIGNEE_NAME,
				   C_CONSIGNER_NAME,
				   C_SURVEY_LOCATION,
				   C_GOODS_DETAILS,
				   POL_GLOBAL_FLAG,
				   COINS_OUR_SHARE,
				   VOLUNTARY_EXCESS,
				   COMPULSORY_EXCESS,
				   CONSIGNEE_ADDR,
				   CONSIGNEE_PHONE,
				   d.CONTACT_PERSON,
				   CONTACT_NO,
				   SURVEY_LOCATION,
				   LOSS_VALUE,
				   REMARKS,
				   PLACE_OF_LOSS,
				   CONSIGNER_NAME,
				   TYPE_OF_CLAIM,
				   LORRY_RECEIPT_DATE,

				   CASE WHEN CLM_SETTLEMENT_TYPE=1 THEN ''''Standard Settlement''''
               WHEN CLM_SETTLEMENT_TYPE=2 THEN ''''Non-Standard Settlement''''
               ELSE NULL END,

				   CASE WHEN TRANSACTION_TYPE=1 THEN ''''Sale''''
              WHEN TRANSACTION_TYPE=2 THEN ''''Purchase''''
              WHEN TRANSACTION_TYPE=3 THEN ''''Stock Transfer''''
              WHEN TRANSACTION_TYPE=4 THEN ''''goods return''''
              WHEN TRANSACTION_TYPE=5 THEN ''''Rejected''''
              WHEN TRANSACTION_TYPE=6 THEN ''''sample Cargo''''
              ELSE NULL END,

				   CASE WHEN MODE_OF_TRANSPORT=1 THEN ''''Rail''''
             WHEN MODE_OF_TRANSPORT=2 THEN ''''Road''''
             WHEN MODE_OF_TRANSPORT=3 THEN ''''Rail/Road''''
             WHEN MODE_OF_TRANSPORT=4 THEN ''''Air''''
             WHEN MODE_OF_TRANSPORT=5 THEN ''''Courier''''
             WHEN MODE_OF_TRANSPORT=6 THEN ''''Ocean Transit''''
             WHEN MODE_OF_TRANSPORT=7 THEN ''''Composite''''
             WHEN MODE_OF_TRANSPORT=8 THEN ''''Inland Water''''
             WHEN MODE_OF_TRANSPORT=9 THEN ''''Coastal''''
              WHEN MODE_OF_TRANSPORT=99 THEN ''''Any other''''
              ELSE NULL END,

				   NATURE_OF_LOSS,


				   CASE WHEN LOAD_TYPE=1 THEN ''''Partial Load''''
              WHEN LOAD_TYPE=2 THEN ''''Full Truck Load''''
              WHEN LOAD_TYPE=3 THEN ''''LTL (Less than Truck load)''''
              WHEN LOAD_TYPE=4 THEN ''''FTL (Full Truck load)''''
              WHEN LOAD_TYPE=5 THEN ''''FCL (Full Container Load)''''
              WHEN LOAD_TYPE=6 THEN ''''LCL (Less-Than-Container Load)''''
              ELSE NULL END,

				   CASE WHEN PACKAGING_TYPE=11 THEN ''''Second Hand single Gunny bags Single gunny2nd''''
               WHEN PACKAGING_TYPE=20 THEN ''''New Double Gunny Bag Nw Double Gunny''''
               WHEN PACKAGING_TYPE=21 THEN ''''Second hand double gunny bags Double gunny2nd''''
               WHEN PACKAGING_TYPE=30 THEN ''''High Density Polythene Bags HDP Lined Bag''''
               WHEN PACKAGING_TYPE=50 THEN ''''Paper Bags - 5 Ply and over Paper-5 Ply''''
               WHEN PACKAGING_TYPE=60 THEN ''''Paper Bags - less than 5 ply Paper < 5 Ply''''
               WHEN PACKAGING_TYPE=80 THEN ''''Poly propelene bags PP Bags''''
               WHEN PACKAGING_TYPE=110 THEN ''''Bales(Fully Pressed) Bales(F Press)''''
               WHEN PACKAGING_TYPE=200 THEN ''''Barrel/Cask - New Bar/Cask New''''
               WHEN PACKAGING_TYPE=210 THEN ''''Barrel/Cask - Second Hand Bar/Cask 2nd''''
               WHEN PACKAGING_TYPE=300 THEN ''''Barrel/Cask - Bundles Bundles''''
               WHEN PACKAGING_TYPE=310 THEN ''''Bulk - Dry Cargo Bulk Dry Cargo''''
               WHEN PACKAGING_TYPE=320 THEN ''''Bulk - Liquid (Tanker) Bulk Liquid''''
               WHEN PACKAGING_TYPE=400   THEN ''''Drums - New Fibre Drums New Fibre Drum''''
               WHEN PACKAGING_TYPE=410 THEN ''''Drums - Second Hand Fibre Drums 2nd Fibre Drum''''
               WHEN PACKAGING_TYPE=420 THEN ''''Drums - New Metallic Drums New Metal Drum''''
               WHEN PACKAGING_TYPE=430 THEN ''''Drums - Second Hand Metallic Drums 2nd Metal Drum''''
               WHEN PACKAGING_TYPE=501 THEN ''''Container - Fully Enclosed Cont-Full Encl''''
               WHEN PACKAGING_TYPE=511 THEN ''''Container - Open Top Cont-Open Top''''
               WHEN PACKAGING_TYPE=521 THEN ''''Container - Insulated Cont-Insulated''''
               WHEN PACKAGING_TYPE=531 THEN ''''Container - Glass Carbuoys Cont-Glass carb''''
               WHEN PACKAGING_TYPE=541 THEN ''''Container - Cartons Cont-Cartons''''
               WHEN PACKAGING_TYPE=601 THEN ''''Special Purpose - Refrigerated Sp Pur-Refrig''''
               WHEN PACKAGING_TYPE=700 THEN ''''Carbuoy/Jars Carbuoy/Jars''''
               WHEN PACKAGING_TYPE=710 THEN ''''Cardboard Box/Carton Card Box/Carton''''
               WHEN PACKAGING_TYPE=720 THEN ''''Cylinder Cylinder''''
               WHEN PACKAGING_TYPE=740 THEN ''''Lift Van Lift Van''''
               WHEN PACKAGING_TYPE=750 THEN ''''Loose/Unpacked Loose/Unpacked''''
               WHEN PACKAGING_TYPE=770 THEN ''''Pallets Pallets''''
               WHEN PACKAGING_TYPE=790 THEN ''''Refrigerated/Cooled/Chilled Cooled/Chilled''''
               WHEN PACKAGING_TYPE=800 THEN ''''Rolls(Paper) Rolls(Paper)''''
               WHEN PACKAGING_TYPE=830 THEN ''''Skids Skids''''
               WHEN PACKAGING_TYPE=840 THEN ''''Tins Tins''''
               WHEN PACKAGING_TYPE=841 THEN ''''Polypacks polypacks''''
               WHEN PACKAGING_TYPE=850 THEN ''''Unitised Unitised''''
               WHEN PACKAGING_TYPE=860 THEN ''''Tankers Tankers''''
               WHEN PACKAGING_TYPE=899 THEN ''''Others Others''''
               WHEN PACKAGING_TYPE=900 THEN ''''Wooden Cases Wooden Cases''''
               WHEN PACKAGING_TYPE=910 THEN ''''Plywood chests for Tea with Aluminium lining Tea Chests''''
               WHEN PACKAGING_TYPE=920 THEN ''''Wooden Crates Wooden Crates''''
               WHEN PACKAGING_TYPE=930 THEN ''''Bottles in Cases Bottles - Cases''''
               WHEN PACKAGING_TYPE=940 THEN ''''Bottles in Cartons Bottles-Cartons''''
               WHEN PACKAGING_TYPE=990 THEN ''''Others Others''''
               ELSE NULL END,

				   SUPPLIER_ID,

				   CASE WHEN  REASON_NON_STD=1 THEN ''''No Damage certificate''''
              WHEN  REASON_NON_STD=1 THEN ''''NNo Letter of Subrogation''''
              WHEN  REASON_NON_STD=1 THEN ''''Courier Transit''''
              WHEN  REASON_NON_STD=1 THEN ''''Recovery Rights Prejudiced''''
              WHEN  REASON_NON_STD=1 THEN ''''thers''''
              ELSE NULL END,

				   NON_STD_PER,
				   TRANSPORTER_NAME,
				   FROM_PLACE,
				   TO_PLACE,
				   GOODS_DETAILS,
				   TYPES_OF_GOODS_DAMAGED,
				   PACKAGING_TYPE_REMARK,
				   JOURNEY_FROM,
				   JOURNEY_TO,
				   BL_RR_LR_AWB_NO,
				   C_SUR_NAME,
				   C_COMMENTS,
				   C_SPECIAL_COMMENTS,
				   C_OMBSMAN_FLAG,
				   C_NAME_OF_IN1,
				   C_REGN_DATE,
				   POLICY_LOCATION_ID,
				   V_VEHICLE_TYPE'';
	EXECUTE IMMEDIATE v_sqltext;

	v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_MARINE_DATA_STG3'';
	EXECUTE IMMEDIATE v_sqltext;

	v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_MARINE_DATA_STG3
			SELECT A.C_CLAIM_NO, SUM (A.RESERVE_AMOUNT) ACTUAL_RESERVE_AMOUNT
			  FROM TRANSACTIONAL.MV_CLAIM_REGISTER A,
			  INTERMEDIATE.WRK_MARINE_DATA_STG2 B
			 WHERE     A.C_CLAIM_NO = B.C_CLAIM_NO
				   AND A.T_DATE_DESC IN
						  (SELECT MIN (T_DATE_DESC)
							 FROM TRANSACTIONAL.MV_CLAIM_REGISTER C
							WHERE     C.C_CLAIM_NO = A.C_CLAIM_NO
								  AND RESERVE_AMOUNT <> 0)
		  GROUP BY A.C_CLAIM_NO'';
	EXECUTE IMMEDIATE v_sqltext;

	v_sqltext := ''TRUNCATE TABLE IF EXISTS INTERMEDIATE.WRK_MARINE_DATA_STG4'';
	EXECUTE IMMEDIATE v_sqltext;

	v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_MARINE_DATA_STG4
			SELECT A.C_CLAIM_NO, SUM (A.PAID_CLAIM) ACTUAL_PAID_AMT
			  FROM TRANSACTIONAL.MV_CLAIM_REGISTER A,
			  INTERMEDIATE.WRK_MARINE_DATA_STG2 B
			 WHERE     A.C_CLAIM_NO = B.C_CLAIM_NO
				   AND A.CLM_STATUS = ''''CLOSED''''
				   AND A.T_DATE_DESC IN
						  (SELECT MAX (T_DATE_DESC)
							 FROM TRANSACTIONAL.MV_CLAIM_REGISTER C
							WHERE     C.C_CLAIM_NO = A.C_CLAIM_NO
								  AND PAID_CLAIM <> 0
								  AND CLM_STATUS = ''''CLOSED'''')
		  GROUP BY A.C_CLAIM_NO'';
	EXECUTE IMMEDIATE v_sqltext;

	v_sqltext := ''DELETE FROM INTERMEDIATE.WRK_MARINE_DATA_FINAL
			 WHERE C_CLAIM_NO IN (SELECT C_CLAIM_NO FROM INTERMEDIATE.WRK_MARINE_DATA_STG2)'';
	EXECUTE IMMEDIATE v_sqltext;

	v_sqltext := ''INSERT INTO INTERMEDIATE.WRK_MARINE_DATA_FINAL
		  SELECT A.*, ACTUAL_RESERVE_AMOUNT, ACTUAL_PAID_AMT
			FROM INTERMEDIATE.WRK_MARINE_DATA_STG2 A,
				 INTERMEDIATE.WRK_MARINE_DATA_STG3 B,
				 INTERMEDIATE.WRK_MARINE_DATA_STG4 C
		   WHERE     A.C_CLAIM_NO = B.C_CLAIM_NO(+)
				 AND A.C_CLAIM_NO = C.C_CLAIM_NO(+)'';
	EXECUTE IMMEDIATE v_sqltext;

	EXECUTE IMMEDIATE ''COMMIT'';
	RETURN ''Procedure executed successfully'';

	EXCEPTION
		WHEN OTHER THEN
			EXECUTE IMMEDIATE ''ROLLBACK'';
			RAISE ;
			RETURN ''Error occurred: '' || SQLERRM || ''\\\\n'' || ''SQL: '' || ''\\\\n'' || v_sqltext;



END;
';