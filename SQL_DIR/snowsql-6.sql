CREATE OR REPLACE PROCEDURE BAGIC_DEV_CURATED_DB.TRANSACTIONAL.INSERT_PR_DATA("MIRROR_DB" VARCHAR(1677216), "P_FROM_DATE" DATE DEFAULT TRUNCDATETOMonth(DATE_ADDDAYSTODATE(CAST(NEGATE(1) AS NUMBER(1,0)), CURRENT_DATE())), "P_TO_DATE" DATE DEFAULT DATE_ADDDAYSTODATE(CAST(NEGATE(1) AS NUMBER(1,0)), CURRENT_DATE()))
RETURNS VARCHAR(167716)
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE
v_sqltext varchar;

BEGIN
/*--commented by venkati and VP  on 27MAY2017*/
/*if TO_CHAR(CURRENT_DATE-1,''dd'') > ''25'' then*/
/*insert  into bjaz_daily_pr select * from bjaz_daily_pr_25 ;  commit;*/
/*CALL LOGTRACE(''LOG'',10010,''PR table merged'' || (DATE_PART(epoch_second, CURRENT_TIMESTAMP())-l_start)/6000 || '' mins'',''GL_PR_RECO'');*/
/*commit;*/
/*END_IF;*/
/*l_start := DATE_PART(epoch_second, CURRENT_TIMESTAMP());*/
/*execute immediate ''truncate table if exists bjaz_daily_pr'';*/
v_sqltext := ''insert into TRANSACTIONAL.BJAZ_DAILY_PR
With BJAZ_GST_STATE_MASTER as (
select distinct state_code,a.pincode
         from   PROD_DWH_MIGRATED_DB.STAGE.AZBJ_PINCODE a, BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_GST_STATE_MASTER b
         where a.state = b.state_name
                and status = ''''A''''  
)
(select ods_policy_dim.p_policy_number,
case substr (ods_policy_premium_fact.version, 1, 1)
when ''''E''''
then
ods_policy_dim.p_policy_number
|| ''''-''''
|| ods_policy_premium_fact.version
else
ods_policy_dim.p_policy_number
end
policy_ref,
ods_policy_premium_fact.version,
ods_policy_dim.p_policy_issue_date,
ods_time_dim.t_date_desc,
ods_location_dim.office_location_id,
ods_location_dim.zone_desc,
--decode (ods_imd_dim.i_imd_desc, ''''DIRECT'''', NVL (p_subimd_channel, i_imd_new_channel), i_imd_new_channel)
 
--CASE WHEN  ods_imd_dim.I_IMD_DESC IN (''''DIRECT'''',''''10035203'''',''''10078229'''',''''66666624'''',''''66666620'''',''''66666674'''',''''66666618'''',''''66666621'''',''''66666623'''',''''66666622'''',''''66666638'''',''''66666644'''',''''55555559'''',''''66666676'''',''''55555550'''',''''66666678'''',''''66666665'''',''''66666666'''',''''66666664'''') THEN   NVL(P_SUBIMD_CHANNEL, I_IMD_NEW_CHANNEL) ELSE I_IMD_NEW_CHANNEL END  IMD_CHANNEL ,
CASE WHEN  IMDSUB_IMD_CHANNEL.imd_list IS NOT NULL
          THEN NVL(P_SUBIMD_CHANNEL, I_IMD_NEW_CHANNEL)
          ELSE I_IMD_NEW_CHANNEL END IMD_CHANNEL ,
ods_product_dim.p_product_id,
partner_dim_policy.pt_partner_desc,
ods_policy_dim.p_risk_inc_date,
ods_policy_dim.p_risk_expiry_date,
ods_policy_dim.p_cover_note_no,
ods_policy_dim.p_sub_imd,
min (ods_policy_premium_fact.sum_insured) sum_insured,
sum (ods_policy_premium_fact.policy_level_premium) gross_premium,
sum (ods_policy_premium_fact.service_tax) service_tax,
sum (ods_policy_premium_fact.edu_cess) education_cess,
sum (ods_policy_premium_fact.stamp_duty) stamp_duty,
nvl(sum (ods_policy_premium_fact.surcharge),0) surcharge,
sum (ods_policy_premium_fact.envt_fund) envt_fund,
sum(ods_policy_premium_fact.net_premium)net_premium,
ods_imd_dim.i_imd_desc,
ods_policy_premium_fact.username,
ods_policy_premium_fact.receipt_details,
partner_dim_policy.pt_partner_id,
sum ( case when cp_company_id_sk = 1 then ods_policy_premium_fact.net_premium end) net_cop,
CURRENT_TIMESTAMP load_date,
sum (
NVL (
(case
when cp_company_id_sk = 1 then NVL (od_premium, 0)
else 0
end),
0))
od_prem,
sum (
NVL (
(case when cp_company_id_sk = 1 then NVL (tp_premium, 0) end),
0))
tp_prem,
pt_partner_region,
ods_policy_premium_fact.contract,
max (case when cp_company_id_sk = 1 then share_rate end) share_rate,
max (case when cp_company_id_sk = 1 then leader end) leader,
sum (
case
when cp_company_id_sk = 1
then
NVL (ods_policy_premium_fact.surcharge, 0)
end)
net_surcharge,
coins_dtls,
case
when ods_location_dim.office_location_id = 1100 then 1101
when ods_location_dim.office_location_id = 1500 then 1501
when ods_location_dim.office_location_id = 1700 then 1701
when ods_location_dim.office_location_id = 1800 then 1801
when ods_location_dim.office_location_id = 1900 then 1901
when ods_location_dim.office_location_id = 2000 then 2001
when ods_location_dim.office_location_id = 2200 then 2201
when ods_location_dim.office_location_id = 2400 then 2401
else ods_location_dim.office_location_id
end
remap_office_loc,
 
--decode (ods_imd_dim.i_imd_desc, ''''DIRECT'''', NVL(chn2.REMAP_IMD_CHANNEL,NVL(chn1.REMAP_IMD_CHANNEL,''''MKTDI'''')), NVL(chn1.REMAP_IMD_CHANNEL,''''MKTDI'''')),
 
--NVL(REMAP_IMD_CHANNEL,''''MKTDI'''') remap_imd_channel,
CASE WHEN  IMDSUB_IMD_CHANNEL.imd_list IS NOT NULL then NVL(
  chn2.REMAP_IMD_CHANNEL,NVL(chn1.REMAP_IMD_CHANNEL,''''MKTDI''''))
  else NVL(chn1.REMAP_IMD_CHANNEL,''''MKTDI'''') end,
case
when sum(ods_policy_premium_fact.service_tax)=0 and sum(ods_policy_premium_fact.net_premium)!=0 then ''''E''''
when sum(ods_policy_premium_fact.service_tax)=0 and sum(ods_policy_premium_fact.net_premium)=0 then ''''N''''
else ''''S''''
end as service_tax_flag,
TAX_CODE,
sum(NVL(KKC_AMT,0))KKC_AMT,
sum(NVL(SWB_AMT,0))SWB_AMT,
-------------commited on 09JAN19----
--sum(NVL(sgst_amt,0))sgst_amt,
--sum(NVL(utgst_amt,0))utgst_amt,
--sum(NVL(cgst_amt,0))cgst_amt,
--sum(NVL(igst_amt,0))igst_amt,
-------------added on 09JAN19----
sum(NVL(ods_policy_premium_fact.sgst_amt,0)+NVL(ods_policy_premium_fact.tp_sgst_amt,0))sgst_amt,
sum(NVL(ods_policy_premium_fact.utgst_amt,0)+NVL(ods_policy_premium_fact.tp_utgst_amt,0))utgst_amt,
sum(NVL(ods_policy_premium_fact.cgst_amt,0)+NVL(ods_policy_premium_fact.tp_cgst_amt,0))cgst_amt,
sum(NVL(ods_policy_premium_fact.igst_amt,0)+NVL(ods_policy_premium_fact.tp_igst_amt,0))igst_amt,
----------------------------------------
sum(NVL(ncc_amt,0))ncc_amt,
ods_policy_premium_fact.mailing_pincode,
ods_policy_premium_fact.partner_gstn,
-- b.state_code partner_state_code,
BJAZ_GST_STATE_MASTER.state_code partner_state_code,
-- MIN(gst_state.state_code) AS partner_state_code,
c.state_code branch_state_code,
ods_policy_dim.p_sub_channel_code,
d.fin_sub_channel_code fin_sub_channel_code,
case when lt.contract is not null then ''''Y'''' end long_term_flag,
sum(NVL(ods_policy_premium_fact.BTP_SGST_AMT,0))BTP_SGST_AMT,
sum(NVL(ods_policy_premium_fact.BTP_UTGST_AMT,0))BTP_UTGST_AMT,
sum(NVL(ods_policy_premium_fact.BTP_CGST_AMT,0))BTP_CGST_AMT,
sum(NVL(ods_policy_premium_fact.BTP_IGST_AMT,0))BTP_IGST_AMT,
----------------------------------Added on 22nd Jan 2019------------------------------
nvl(BASIC_TP_PREMIUM,0) BTP_PREM,
ods_policy_dim.P_VEHICLE_TYPE,
V_Vehicle_Type,
----------------------------------Added on 05th Jul 2019------------------------------
sum(NVL(CESS1_AMT,0))KFC_CESS_AMT,
--------------------------------------------------------------------------------------
ODS_POLICY_PREMIUM_FACT.MAXI_FLAG,    ----ADDED ON 27TH MAY 2020v
SUM(ROUND(NVL(CASE WHEN P_RISK_INC_DATE>=''''01-OCT-2019'''' AND ODS_POLICY_DIM.P_PRODUCT_ID LIKE ''''18%''''THEN ods_policy_premium_fact.Cpa_Premium
 ELSE 0 END,0)))CPA_PREM,   -----added on 31 OCT 2020 by Nitin M
case when ods_policy_premium_fact.maxi_flag=''''Y'''' then ods_policy_premium_fact.GST_INVOICE_NUMBER else ods_policy_premium_fact.CONTRACT::number(38)||''''/''''||ods_policy_premium_fact.VER_NO END GST_INVOICE_NUMBER,--added on 15 SEP 2022 by SAM/PRAVIN
ods_policy_dim.p_policy_status,
ods_policy_premium_fact.Endorsement_No AS P_Endorsement_No,
ods_policy_premium_fact.Ver_No,
ods_policy_dim.p_master_policy_no  --addded by bk on 30-jun-2025
FROM
TRANSACTIONAL.ODS_PARTNER_DIM partner_dim_policy,
TRANSACTIONAL.ODS_POLICY_DIM,
TRANSACTIONAL.ODS_TIME_DIM,
TRANSACTIONAL.ODS_IMD_DIM,
TRANSACTIONAL.ODS_LOCATION_DIM,
TRANSACTIONAL.ODS_POLICY_PREMIUM_FACT ODS_POLICY_PREMIUM_FACT,
TRANSACTIONAL.ODS_PRODUCT_DIM ODS_PRODUCT_DIM,
BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_POLICY_SUMMARY a,
BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_BRANCH_MASTER c,
BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_SUB_CHANNEL_MASTER d,
(select distinct contract from TRANSACTIONAL.ods_policy_premium_fact_lt
where t_date_desc BETWEEN ''''''|| p_from_date ||'''''' AND ''''''|| p_to_date ||'''''') lt,
-- BAGIC_PROD_CURATED_DB.TRANSACTIONAL.ODS_COVER_PREM_DIM btp,
TRANSACTIONAL.ODS_VEHICLE_TYPE_DIM,
PROD_DWH_MIGRATED_DB.PROD.IMD_CHANNEL_LOOKUP_FIN chn1,
PROD_DWH_MIGRATED_DB.PROD.IMD_CHANNEL_LOOKUP_FIN chn2,
TRANSACTIONAL.IMDSUB_IMD_CHANNEL,
-- (select state_code
--          from   PROD_DWH_MIGRATED_DB.STAGE.AZBJ_PINCODE a, BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE.BJAZ_GST_STATE_MASTER b
--          where  a.state = b.state_name
--                 and status = ''''A'''') 
                BJAZ_GST_STATE_MASTER 
where
ods_policy_dim.p_product_id= ods_product_dim.p_product_id  and
ods_policy_dim.p_partner_id_sk=partner_dim_policy.pt_partner_id_sk  and
ods_policy_dim.p_office_loc_id = ods_location_dim.office_location_id and
ods_policy_dim.p_policy_no_sk=ods_policy_premium_fact.p_policy_no_sk and
ods_policy_premium_fact.t_date_id_sk = ods_time_dim.t_date_id_sk and
ods_policy_dim.p_imd_id_sk = ods_imd_dim.i_imd_id_sk(+) and
ods_policy_premium_fact.contract = a.contract_id(+) and
UTILS.STRIP_CHARS(ods_policy_premium_fact.version) =to_varchar(a.version_no(+)) and
ods_policy_dim.p_office_loc_id=c.branch_code  and
ods_time_dim.t_date_desc between ''''''|| p_from_date ||'''''' AND ''''''|| p_to_date ||''''''
and nvl(ods_policy_dim.p_sub_channel_code,''''XYZ'''')=d.org_sub_channel_code(+)
and ods_policy_premium_fact.contract=lt.contract(+)
-- and ods_policy_premium_fact.contract = btp.contract_id(+)
-- and UTILS.STRIP_CHARS (ods_policy_premium_fact.version) =to_varchar(btp.version_no(+))
and NVL(P_VEHICLE_TYPE,0)=NVL(V_VEHICLE_TYPE_CODE(+),0)
and i_imd_new_channel=chn1.IMD_CHANNEL(+)
and p_subimd_channel=chn2.IMD_CHANNEL(+)
and ODS_IMD_DIM.I_IMD_DESC = IMDSUB_IMD_CHANNEL.imd_list(+)  
and BJAZ_GST_STATE_MASTER.pincode(+) = ods_policy_premium_fact.mailing_pincode
group by
ods_policy_dim.p_policy_number,
case 
substr (ods_policy_premium_fact.version, 1, 1)
when ''''E''''
then
ods_policy_dim.p_policy_number
|| ''''-''''
|| ods_policy_premium_fact.version
else
ods_policy_dim.p_policy_number
end,
ods_policy_premium_fact.version,
ods_policy_dim.p_policy_issue_date,
partner_state_code,
ods_time_dim.t_date_desc,
ods_location_dim.office_location_id,
ods_location_dim.zone_desc,
--decode (ods_imd_dim.i_imd_desc, ''''DIRECT'''', NVL (p_subimd_channel, i_imd_new_channel), i_imd_new_channel),
 
--CASE WHEN  ods_imd_dim.I_IMD_DESC IN (''''DIRECT'''',''''10035203'''',''''10078229'''',''''66666624'''',''''66666620'''',''''66666674'''',''''66666618'''',''''66666621'''',''''66666623'''',''''66666622'''',''''66666638'''',''''66666644'''',''''55555559'''',''''66666676'''',''''55555550'''',''''66666678'''',''''66666665'''',''''66666666'''',''''66666664'''') THEN   NVL(P_SUBIMD_CHANNEL, I_IMD_NEW_CHANNEL) ELSE I_IMD_NEW_CHANNEL END  ,
CASE WHEN  IMDSUB_IMD_CHANNEL.imd_list IS NOT NULL
          THEN NVL(P_SUBIMD_CHANNEL, I_IMD_NEW_CHANNEL)
          ELSE I_IMD_NEW_CHANNEL END ,
CASE WHEN  IMDSUB_IMD_CHANNEL.imd_list IS NOT NULL then NVL(
  chn2.REMAP_IMD_CHANNEL,NVL(chn1.REMAP_IMD_CHANNEL,''''MKTDI''''))
  else NVL(chn1.REMAP_IMD_CHANNEL,''''MKTDI'''') end,
ods_product_dim.p_product_id,
partner_dim_policy.pt_partner_desc,
ods_policy_dim.p_risk_inc_date,
ods_policy_dim.p_risk_expiry_date,
ods_policy_dim.p_cover_note_no,
ods_policy_dim.p_sub_imd,
ods_imd_dim.i_imd_desc,
ods_policy_premium_fact.username,
ods_policy_premium_fact.receipt_details,
partner_dim_policy.pt_partner_id,
CURRENT_DATE(),
pt_partner_region,
ods_policy_premium_fact.contract,
coins_dtls,
decode (p_coinsurance_type, ''''IN'''', ''''N'''', ''''Y''''),
case
when ods_location_dim.office_location_id = 1100 then 1101
when ods_location_dim.office_location_id = 1500 then 1501
when ods_location_dim.office_location_id = 1700 then 1701
when ods_location_dim.office_location_id = 1800 then 1801
when ods_location_dim.office_location_id = 1900 then 1901
when ods_location_dim.office_location_id = 2000 then 2001
when ods_location_dim.office_location_id = 2200 then 2201
when ods_location_dim.office_location_id = 2400then 2401
else ods_location_dim.office_location_id
end,
--decode (ods_imd_dim.i_imd_desc, ''''DIRECT'''', NVL(chn2.REMAP_IMD_CHANNEL,NVL(chn1.REMAP_IMD_CHANNEL,''''MKTDI'''')), NVL(chn1.REMAP_IMD_CHANNEL,''''MKTDI'''')),
decode (ods_imd_dim.i_imd_desc, ''''DIRECT'''', NVL(chn2.REMAP_IMD_CHANNEL,NVL(chn1.REMAP_IMD_CHANNEL,''''MKTDI'''')),
                                ''''10035203'''', NVL(chn2.REMAP_IMD_CHANNEL,NVL(chn1.REMAP_IMD_CHANNEL,''''MKTDI'''')),
                                 NVL(chn1.REMAP_IMD_CHANNEL,''''MKTDI'''')) ,
TAX_CODE,
ods_policy_premium_fact.mailing_pincode,
ods_policy_premium_fact.partner_gstn,
--b.state_code,
c.state_code,
ods_policy_dim.p_sub_channel_code,
d.fin_sub_channel_code,
case when lt.contract is not null then ''''Y'''' end,
--------------------------Added on 22nd Jan 2019------------------------------
BASIC_TP_PREMIUM,
ods_policy_dim.P_VEHICLE_TYPE,
V_Vehicle_Type,ODS_POLICY_PREMIUM_FACT.MAXI_FLAG,ods_policy_premium_fact.Cpa_Premium,
case 
when ods_policy_premium_fact.maxi_flag=''''Y'''' 
then ods_policy_premium_fact.GST_INVOICE_NUMBER 
else ods_policy_premium_fact.CONTRACT::number(38)||''''/''''||ods_policy_premium_fact.VER_NO 
END,
ods_policy_dim.p_policy_status,
ods_policy_premium_fact.Endorsement_No,
ods_policy_premium_fact.Ver_No,
ods_policy_dim.p_master_policy_no
--------------------------------------------------------------------------------------
)'';
EXECUTE IMMEDIATE v_sqltext;

--COMMIT;
/*-----------------------------------------------------------------------------------------------------------------------------------------------*/
v_sqltext := ''update TRANSACTIONAL.BJAZ_DAILY_PR
set remap_office_loc =
case
when imd_channel = ''''AXIS''''   then 9904
when imd_channel = ''''HDFC'''' then 9905
end
where imd_channel in (''''AXIS'''',''''HDFC'''')
and t_date_desc between ''''''|| p_from_date ||'''''' and ''''''|| p_to_date ||'''''''';

EXECUTE IMMEDIATE v_sqltext;

/*---------------------------------------------------------------------------------------------------------------------------------------------------*/
/*begin*/
/*for i in*/
/*(*/
/*select*/
/*a.policy_ref,*/
/*case*/
/*when service_tax!=0 then tax_flag*/
/*when service_tax=0 and net_premium!=0 then ''E''*/
/*when net_premium=0 then ''N''*/
/*end tax_flag*/
/*from*/
/*work.bjaz_daily_pr a left outer join*/
/*(select*/
/*NVL(endt_ref,policy_ref) policy_ref,tax_flag*/
/*from bjaz_daily_gl*/
/*where length (policy_ref)=24 and account_category_code in ( ''2115220034'',''2115220001'')*/
/*and accounting_date between p_from_date and p_to_date*/
/*) b*/
/*on (a.policy_ref=b.policy_ref)*/
/*and t_date_desc between p_from_date and p_to_date*/
/*)*/
/*loop*/
/*update work.bjaz_daily_pr*/
/*set service_tax_flag=i.tax_flag*/
/*where*/
/*policy_ref=i.policy_ref;*/
/*commit;*/
/*END_LOOP;*/
/*end;*/
/*------------------------new code for service tax updation --------------------*/
/*begin*/
/*update   bjaz_daily_pr a*/
/*set service_tax_flag =''S''*/
/*where service_tax!=0*/
/*and service_tax_flag is null*/
/*and policy_ref in (select policy_ref from bjaz_daily_gl g where account_category_code in (''2115220001'') );--tax_flag =''S''*/
/*commit;*/
/*end;*/
/*-----------------------------------------------------------------------*/
--BEGIN
--CALL PROD_DWH_MIGRATED_DB.PROD.DUMMY_PROCEDURE();
/*---------------------------------------------------------------------------------------------------------------------------------------------------*/
/*begin*/
/*for i in*/
/*(*/
/*select*/
/*a.policy_ref,*/
/*case*/
/*when service_tax!=0 then tax_flag*/
/*when service_tax=0 and net_premium!=0 then ''E''*/
/*when net_premium=0 then ''N''*/
/*end tax_flag*/
/*from*/
/*work.bjaz_daily_pr a left outer join*/
/*(select*/
/*NVL(endt_ref,policy_ref) policy_ref,tax_flag*/
/*from bjaz_daily_gl*/
/*where length (policy_ref)=24 and account_category_code in ( ''2115220034'',''2115220001'')*/
/*and accounting_date between p_from_date and p_to_date*/
/*) b*/
/*on (a.policy_ref=b.policy_ref)*/
/*and t_date_desc between p_from_date and p_to_date*/
/*)*/
/*loop*/
/*update work.bjaz_daily_pr*/
/*set service_tax_flag=i.tax_flag*/
/*where*/
/*policy_ref=i.policy_ref;*/
/*commit;*/
/*END_LOOP;*/
/*end;*/
/*------------------------new code for service tax updation --------------------*/
/*begin*/
/*update   bjaz_daily_pr a*/
/*set service_tax_flag =''S''*/
/*where service_tax!=0*/
/*and service_tax_flag is null*/
/*and policy_ref in (select policy_ref from bjaz_daily_gl g where account_category_code in (''2115220001'') );--tax_flag =''S''*/
/*commit;*/
/*end;*/
/*-----------------------------------------------------------------------*/
v_sqltext := ''update TRANSACTIONAL.BJAZ_DAILY_PR a
set service_tax_flag =''''G''''
where service_tax!=0
--and service_tax_flag is null
and policy_ref in (select NVL(endt_ref,policy_ref) 
from 
TRANSACTIONAL.BJAZ_DAILY_GL g 
where 
account_category_code in (''''2115220034'''') )'';
EXECUTE IMMEDIATE v_sqltext;

/*tax_flag =''G''*/
--COMMIT;

--END;
/*-----------------------------------------------------------------------*/
/*begin*/
/*update   bjaz_daily_pr a*/
/*set service_tax_flag = case when service_tax=0 and net_premium!=0 then ''E'' when net_premium=0 then ''N'' end*/
/*where  service_tax=0;*/
/*--and service_tax_flag is null;*/
/*commit;*/
/*end;*/
/*-----------------------------end service tax updation-------------*/
--COMMIT;
/*CALL LOGTRACE(''LOG'',10010,''PR table loaded'' || (DATE_PART(epoch_second, CURRENT_TIMESTAMP())-l_start)/6000 || '' mins'',''GL_PR_RECO'');*/
/*send_sms_proc (''DAILY PR TABLE LOADED'', ''8055005828'', ''D'');*/
/*send_sms_proc (''DAILY PR TABLE LOADED'', ''9970364604'', ''D'');*/
/*send_sms_proc (''DAILY PR TABLE LOADED'', ''9028110243'', ''D'');*/
/*send_sms_proc (''DAILY PR TABLE LOADED'', ''9913645009'', ''D'');*/
--COMMIT;
EXECUTE IMMEDIATE ''COMMIT'';
 RETURN ''Procedure executed successfully'';

    EXCEPTION
         WHEN OTHER THEN
             EXECUTE IMMEDIATE ''ROLLBACK'';
             RAISE ;
             RETURN ''Error occurred: '' || SQLERRM || ''\\n'' || ''SQL: '' || ''\\n'' || v_sqltext;

END;
';
