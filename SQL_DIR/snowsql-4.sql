CREATE OR REPLACE PROCEDURE TRANSACTIONAL.LOSS_MAKING_RENEWAL("MIRROR_DB" VARCHAR(16777216), "F_DATE" DATE DEFAULT CURRENT_DATE(), "T_DATE" DATE DEFAULT CURRENT_DATE())
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE
v_sqltext varchar;
BEGIN

v_sqltext :=''
CREATE OR REPLACE TABLE INTERMEDIATE.wrk_loss_mark_renewal_12 AS(
WITH wrk_loss_mark_renewal_1 AS(
select /*+parallel(20)*/a.r_policy_ref as p_policy_number,a.r_red as p_risk_expiry_date from TRANSACTIONAL.ODS_RENEWAL_DTLS a
where a.r_tbr_rid between DATE_TRUNC(''''DAY'''',CURRENT_DATE()-1)  and DATE_TRUNC(''''DAY'''',CURRENT_DATE()-1)+90
--where a.r_tbr_rid between ''''01-Mar-2025'''' and ''''31-May-2025''''
and a.r_product_id in (6001,6002,6003,6004,6005,6007,6008,6009,6010,6011,6012,6014,6015,6016,6017,6018,
6019,6030,6033,6034,6037,6041,6042,8401,8404,8405,8406,8407,8408,8409,8410,8411,
8412,8413,8414,8415,8416,8417,8418,8419,8420,8421,8422,8423,8425,8426,8427,8429,
8430,8431,8432,8435,8436,8441,8442,8445,8447,8448,8449,8450,8451,8453,8454,8455,8456,8457,8458)
and r_policy_status <>''''O''''    
),

wrk_loss_mark_renewal_2 AS(
    select /*+parallel(10)*/wrk_loss_mark_renewal_1.p_policy_number as dueforrenewal,wrk_loss_mark_renewal_1.p_risk_expiry_date as renew_date,
    --a.r_rnwd_policy_issue_date as renew_date,
    a.r_policy_ref as Journey_1,
    a.r_policy_issue_date as p_renew_date_1,
    b.r_policy_ref as Journey_2,
    b.r_policy_issue_date as p_renew_date_2,
    c.r_policy_ref as Journey_3,
    c.r_policy_issue_date as p_renew_date_3,
    d.r_policy_ref as Journey_4,
    d.r_policy_issue_date as p_renew_date_4,
    e.r_policy_ref as Journey_5,
    e.r_policy_issue_date as p_renew_date_5,
    f.r_policy_ref as Journey_6,
    f.r_policy_issue_date as p_renew_date_6,
    g.r_policy_ref as Journey_7,
    g.r_policy_issue_date as p_renew_date_7
    from wrk_loss_mark_renewal_1 ,
    (select * from TRANSACTIONAL.ODS_RENEWAL_DTLS a)a,
    (select * from TRANSACTIONAL.ODS_RENEWAL_DTLS b)b,
    (select * from TRANSACTIONAL.ODS_RENEWAL_DTLS c)c,
    (select * from TRANSACTIONAL.ODS_RENEWAL_DTLS d)d,
    (select * from TRANSACTIONAL.ODS_RENEWAL_DTLS e)e,
    (select * from TRANSACTIONAL.ODS_RENEWAL_DTLS f)f,
    (select * from TRANSACTIONAL.ODS_RENEWAL_DTLS g)g,
    (select * from TRANSACTIONAL.ODS_RENEWAL_DTLS h)h
    where wrk_loss_mark_renewal_1.p_policy_number  = a.r_rnwd_policy_ref(+)
    and a.r_policy_ref=b.r_rnwd_policy_ref(+)
    and b.r_policy_ref=c.r_rnwd_policy_ref(+)
    and c.r_policy_ref=d.r_rnwd_policy_ref(+)
    and d.r_policy_ref=e.r_rnwd_policy_ref(+)
    and e.r_policy_ref=f.r_rnwd_policy_ref(+)
    and f.r_policy_ref=g.r_rnwd_policy_ref(+)
    and g.r_policy_ref=h.r_rnwd_policy_ref(+)
),
wrk_loss_mark_renewal_3 AS
(
    select dueforrenewal from wrk_loss_mark_renewal_2
    union
    select Journey_1 from wrk_loss_mark_renewal_2
    union
    select Journey_2 from wrk_loss_mark_renewal_2
),

wrk_loss_mark_renewal_bad_icd AS
(
    select dueforrenewal from wrk_loss_mark_renewal_2
    union
    select Journey_1 from wrk_loss_mark_renewal_2
    union
    select Journey_2 from wrk_loss_mark_renewal_2
    union
    select Journey_3 from wrk_loss_mark_renewal_2
    union
    select Journey_4 from wrk_loss_mark_renewal_2
    union
    select Journey_5 from wrk_loss_mark_renewal_2
    union
    select Journey_6 from wrk_loss_mark_renewal_2
    union
    select Journey_7 from wrk_loss_mark_renewal_2
),
wrk_loss_mark_renewal_4 AS 
(
    select /*+parallel(10)*/y.dueforrenewal as p_policy_number,c_claim_no,c_regn_date,--z.icd_code,z.icd_description,replace (z.icd_code,'''','''',''''-'''') as icd_code_1,
    x.p_department_desc,
    sum(x.paid_claim)paid_claim,
    sum(x.os_amt)os_amt
    from wrk_loss_mark_renewal_3 y,MV_CLAIM_REGISTER x--,prod.bjaz_hm_hcm_extract_mv z
    where y.dueforrenewal = x.p_policy_number(+)
    --and x.c_claim_no = z.claim_no(+)
    group by y.dueforrenewal,c_claim_no,c_regn_date,--z.icd_code,z.icd_description,REPLACE (z.icd_code,'''','''',''''-''''),
    x.p_department_desc
),
wrk_loss_mark_renewal_5 AS
(
    select b.*,
    /*coalesce(case when regexp_substr (b.icd_code_1,''''[^ -]+'''',1,1) in (select icd_code from wrk_hat_tag)
                then 1 end,
            case when regexp_substr (b.icd_code_1,''''[^ -]+'''',1,2) in (select icd_code from wrk_hat_tag)
                then 1 end,
            case when regexp_substr (b.icd_code_1,''''[^ -]+'''',1,3) in (select icd_code from wrk_hat_tag)
                then 1 end,
            case when regexp_substr (b.icd_code_1,''''[^ -]+'''',1,4) in (select icd_code from wrk_hat_tag)
                then 1 end,
            case when regexp_substr (b.icd_code_1,''''[^ -]+'''',1,5) in (select icd_code from wrk_hat_tag)
                then 1 end,
            case when regexp_substr (b.icd_code_1,''''[^ -]+'''',1,6) in (select icd_code from wrk_hat_tag)
                then 1 end,
            case when regexp_substr (b.icd_code_1,''''[^ -]+'''',1,7) in (select icd_code from wrk_hat_tag)
                then 1 end,
            case when regexp_substr (b.icd_code_1,''''[^ -]+'''',1,8) in (select icd_code from wrk_hat_tag)
                then 1 end,
            case when regexp_substr (b.icd_code_1,''''[^ -]+'''',1,9) in (select icd_code from wrk_hat_tag)
                then 1 end,
            case when regexp_substr (b.icd_code_1,''''[^ -]+'''',1,10) in (select icd_code from wrk_hat_tag)
                then 1
                else 0 end)hat_tag_y_n,*/
    case when p_department_desc = ''''HEALTH'''' and c_claim_no not like ''''%OC%'''' and
                        c_claim_no like ''''%P'''' and length(c_claim_no) < 25 then c_claim_no
                when p_department_desc = ''''HEALTH'''' and c_claim_no like ''''%OC%'''' and
                        length(c_claim_no) < 25 then c_claim_no
                when p_department_desc <> ''''HEALTH'''' then c_claim_no
                end parent_claim
    from wrk_loss_mark_renewal_4 b    
),
wrk_loss_mak_renewal_bad_icd_1 AS
(
select /*+parallel(10)*/y.dueforrenewal as p_policy_number,c_claim_no,c_regn_date,z.icd_code,z.icd_description,replace (z.icd_code,'''','''',''''-'''') as icd_code_1,
x.p_department_desc,
sum(x.paid_claim)paid_claim,
sum(x.os_amt)os_amt
from wrk_loss_mark_renewal_bad_icd y,
TRANSACTIONAL.MV_CLAIM_REGISTER x,
''|| MIRROR_DB ||''.MAXI_IIMS_REP.BJAZ_HM_HCM_EXTRACT_MV z 
where y.dueforrenewal = x.p_policy_number(+)
and x.c_claim_no = z.claim_no(+)
group by y.dueforrenewal,c_claim_no,c_regn_date,z.icd_code,z.icd_description,
REPLACE (z.icd_code,'''','''',''''-''''),x.p_department_desc
),
wrk_loss_mak_renewal_bad_icd_2 AS
(
    select /*+parallel(10)*/b.p_policy_number,b.c_claim_no,
    coalesce(case when regexp_substr (b.icd_code_1,''''[^ -]+'''',1,1) in (select icd_code from wrk_hat_tag)
                then 1 end,
            case when regexp_substr (b.icd_code_1,''''[^ -]+'''',1,2) in (select icd_code from wrk_hat_tag)
                then 1 end,
            case when regexp_substr (b.icd_code_1,''''[^ -]+'''',1,3) in (select icd_code from wrk_hat_tag)
                then 1 end,
            case when regexp_substr (b.icd_code_1,''''[^ -]+'''',1,4) in (select icd_code from wrk_hat_tag)
                then 1 end,
            case when regexp_substr (b.icd_code_1,''''[^ -]+'''',1,5) in (select icd_code from wrk_hat_tag)
                then 1 end,
            case when regexp_substr (b.icd_code_1,''''[^ -]+'''',1,6) in (select icd_code from wrk_hat_tag)
                then 1 end,
            case when regexp_substr (b.icd_code_1,''''[^ -]+'''',1,7) in (select icd_code from wrk_hat_tag)
                then 1 end,
            case when regexp_substr (b.icd_code_1,''''[^ -]+'''',1,8) in (select icd_code from wrk_hat_tag)
                then 1 end,
            case when regexp_substr (b.icd_code_1,''''[^ -]+'''',1,9) in (select icd_code from wrk_hat_tag)
                then 1 end,
            case when regexp_substr (b.icd_code_1,''''[^ -]+'''',1,10) in (select icd_code from wrk_hat_tag)
                then 1
                else 0 end)hat_tag_y_n
    from wrk_loss_mak_renewal_bad_icd_1 b
),
wrk_loss_mak_renewal_bad_icd_3 AS
(
    select a1.p_policy_number,sum(a1.hat_tag_y_n)hat_tag_y_n
    --count(a1.parent_claim)parent_claim_count,
    --sum(a1.paid_claim)paid_claim,
    --sum(a1.os_amt)os_amt
    from wrk_loss_mak_renewal_bad_icd_2 a1
    group by  a1.p_policy_number
),
wrk_loss_mark_renewal_6 AS
(
    select a1.p_policy_number,cast(0 as float) as hat_tag_y_n,count(a1.parent_claim)parent_claim_count,sum(nvl(a1.paid_claim,0))paid_claim,
    sum(nvl(a1.os_amt,0))os_amt
    from wrk_loss_mark_renewal_5 a1
    group by  a1.p_policy_number
    UNION ALL
    select n1.p_policy_number,n1.hat_tag_y_n,0,0,0
    from wrk_loss_mak_renewal_bad_icd_3 n1
),
wrk_loss_mark_renewal_7 AS
(
    select a1.p_policy_number,sum(hat_tag_y_n) as hat_tag_y_n,sum(a1.parent_claim_count)parent_claim_count,
    sum(nvl(a1.paid_claim,0))paid_claim,sum(nvl(a1.os_amt,0))os_amt
    from wrk_loss_mark_renewal_6 a1
    group by  a1.p_policy_number
),
wrk_loss_mark_renewal_8 AS
(
    select  /*+parallel(10)*/a.p_policy_number,sum(a.netcop)netcop,sum(a.netsurcharge)netsurcharge
    from TRANSACTIONAL.MV_PREMIUM_REGISTER a
    where a.p_policy_number in (select distinct dueforrenewal from wrk_loss_mark_renewal_3)
    group by a.p_policy_number
),
wrk_loss_mark_renewal_9 AS
(
    select a1.p_policy_number,
sum(a1.hat_tag_y_n)hat_tag_y_n,
sum(a1.parent_claim_count)parent_claim_count,
sum(a1.paid_claim)paid_claim,
sum(a1.os_amt)os_amt,
sum(a2.netcop)netcop,
sum(a2.netsurcharge)netsurcharge
from wrk_loss_mark_renewal_7 a1,
wrk_loss_mark_renewal_8 a2
where a1.p_policy_number = a2.p_policy_number(+)
group by  a1.p_policy_number
),
wrk_loss_mark_renewal_10 AS
( 
    SELECT A.DUEFORRENEWAL,renew_date,a.journey_1,a.journey_2,a.journey_3,a.journey_4,a.journey_5,a.journey_6,a.journey_7,
    sum(nvl(b.hat_tag_y_n,0))hat_tag_y_n_1,
    sum(nvl(b.parent_claim_count,0))parent_claim_count_1,
    sum(nvl(b.paid_claim,0))paid_claim_1,
    sum(nvl(b.os_amt,0))os_amt_1,
    sum(nvl(b.netcop,0))netcop_1,
    sum(nvl(b.netsurcharge,0))netsurcharge_1,
    sum(nvl(c.hat_tag_y_n,0))hat_tag_y_n_2,
    sum(nvl(c.parent_claim_count,0))parent_claim_count_2,
    sum(nvl(c.paid_claim,0))paid_claim_2,
    sum(nvl(c.os_amt,0))os_amt_2,
    sum(nvl(c.netcop,0))netcop_2,
    sum(nvl(c.netsurcharge,0))netsurcharge_2,
    sum(nvl(d.hat_tag_y_n,0))hat_tag_y_n_3,
    sum(nvl(d.parent_claim_count,0))parent_claim_count_3,
    sum(nvl(d.paid_claim,0))paid_claim_3,
    sum(nvl(d.os_amt,0))os_amt_3,
    sum(nvl(d.netcop,0))netcop_3,
    sum(nvl(d.netsurcharge,0))netsurcharge_3,

    sum(nvl(e.hat_tag_y_n,0))hat_tag_y_n_4,
    sum(nvl(e.parent_claim_count,0))parent_claim_count_4,
    sum(nvl(e.paid_claim,0))paid_claim_4,
    sum(nvl(e.os_amt,0))os_amt_4,
    sum(nvl(e.netcop,0))netcop_4,
    sum(nvl(e.netsurcharge,0))netsurcharge_4,

    sum(nvl(f.hat_tag_y_n,0))hat_tag_y_n_5,
    sum(nvl(f.parent_claim_count,0))parent_claim_count_5,
    sum(nvl(f.paid_claim,0))paid_claim_5,
    sum(nvl(f.os_amt,0))os_amt_5,
    sum(nvl(f.netcop,0))netcop_5,
    sum(nvl(f.netsurcharge,0))netsurcharge_5,

    sum(nvl(g.hat_tag_y_n,0))hat_tag_y_n_6,
    sum(nvl(g.parent_claim_count,0))parent_claim_count_6,
    sum(nvl(g.paid_claim,0))paid_claim_6,
    sum(nvl(g.os_amt,0))os_amt_6,
    sum(nvl(g.netcop,0))netcop_6,
    sum(nvl(g.netsurcharge,0))netsurcharge_6,

    sum(nvl(h.hat_tag_y_n,0))hat_tag_y_n_7,
    sum(nvl(h.parent_claim_count,0))parent_claim_count_7,
    sum(nvl(h.paid_claim,0))paid_claim_7,
    sum(nvl(h.os_amt,0))os_amt_7,
    sum(nvl(h.netcop,0))netcop_7,
    sum(nvl(h.netsurcharge,0))netsurcharge_7,

    sum(nvl(i.hat_tag_y_n,0))hat_tag_y_n_8,
    sum(nvl(i.parent_claim_count,0))parent_claim_count_8,
    sum(nvl(i.paid_claim,0))paid_claim_8,
    sum(nvl(i.os_amt,0))os_amt_8,
    sum(nvl(i.netcop,0))netcop_8,
    sum(nvl(i.netsurcharge,0))netsurcharge_8

    FROM wrk_loss_mark_renewal_2 A, wrk_loss_mark_renewal_9 B,wrk_loss_mark_renewal_9 c,wrk_loss_mark_renewal_9 d,
    wrk_loss_mark_renewal_9 e,wrk_loss_mark_renewal_9 f,wrk_loss_mark_renewal_9 g,wrk_loss_mark_renewal_9 h,
    wrk_loss_mark_renewal_9 i
    WHERE A.DUEFORRENEWAL = B.P_POLICY_NUMBER(+)
    and a.journey_1 = c.P_POLICY_NUMBER(+)
    and a.journey_2 = d.P_POLICY_NUMBER(+)
    and a.journey_3 = e.P_POLICY_NUMBER(+)
    and a.journey_4 = f.P_POLICY_NUMBER(+)
    and a.journey_5 = g.P_POLICY_NUMBER(+)
    and a.journey_6 = h.P_POLICY_NUMBER(+)
    and a.journey_7 = i.P_POLICY_NUMBER(+)
    GROUP BY A.DUEFORRENEWAL,renew_date,a.journey_1,a.journey_2,a.journey_3,a.journey_4,a.journey_5,a.journey_6,a.journey_7
),
wrk_loss_mark_renewal_11 AS
(
    select a.dueforrenewal,renew_date,a.journey_1,a.journey_2,a.journey_3,a.journey_4,a.journey_5,a.journey_6,a.journey_7,
    sum(hat_tag_y_n_1+hat_tag_y_n_2+hat_tag_y_n_3+hat_tag_y_n_4+hat_tag_y_n_5+hat_tag_y_n_6+hat_tag_y_n_7+hat_tag_y_n_8)hat_tag_y_n,
                                sum(parent_claim_count_1+parent_claim_count_2+parent_claim_count_3+parent_claim_count_4+parent_claim_count_5+parent_claim_count_6+parent_claim_count_7+parent_claim_count_8)parent_claim_count,
    sum(paid_claim_1+paid_claim_2+paid_claim_3+paid_claim_4+paid_claim_5+paid_claim_6+paid_claim_7+paid_claim_8+
    +os_amt_1+os_amt_2+os_amt_3+os_amt_4+os_amt_5+os_amt_6+os_amt_7+os_amt_8)Gross_Incurred,
    sum(netcop_1+netcop_2+netcop_3+netsurcharge_1+netsurcharge_2+netsurcharge_3
    +netsurcharge_4+netsurcharge_5+netsurcharge_6+netsurcharge_7+netsurcharge_8)Total_Premium
    from wrk_loss_mark_renewal_10 a
    group by a.dueforrenewal,renew_date,a.journey_1,a.journey_2,a.journey_3,a.journey_4,a.journey_5,a.journey_6,a.journey_7
),
wrk_loss_mark_renewal_12 AS
( 
    select a.dueforrenewal,renew_date,a.journey_1,a.journey_2,a.journey_3,a.journey_4,a.journey_5,a.journey_6,a.journey_7,
    Total_Premium as Total_Premium,
    Gross_Incurred as Gross_Incurred,
    parent_claim_count as parent_claim_count,
    hat_tag_y_n as hat_tag_y_n,
    round(((Gross_Incurred/nullif(Total_Premium,0))*100)) as Loss_Ratio
    from wrk_loss_mark_renewal_11 a
)
SELECT * FROM wrk_loss_mark_renewal_12
)
'';
EXECUTE IMMEDIATE v_sqltext;

v_sqltext :='' 

insert into TRANSACTIONAL.WRK_LOSS_MAKING_RENEWAL_IDENTI(dueforrenewal,renew_date,journey_1,journey_2,journey_3,journey_4,journey_5,journey_6,journey_7,
total_premium,gross_incurred,parent_claim_count,hat_tag_y_n,loss_ratio,renewal_tagging)
select dueforrenewal,renew_date,journey_1,journey_2,journey_3,journey_4,journey_5,journey_6,journey_7,
Total_Premium,Gross_Incurred,parent_claim_count,hat_tag_y_n,Loss_Ratio,
case when hat_tag_y_n <> 0 then ''''Not_Preferred_Catgegory_A''''
     when hat_tag_y_n = 0 and parent_claim_count >=3 and Loss_Ratio > 100 then ''''Not_Preferred_Catgegory_B''''
      when hat_tag_y_n = 0 and parent_claim_count >=3 and Loss_Ratio <= 100 then ''''Blank''''
       when hat_tag_y_n = 0 and parent_claim_count <3 and Loss_Ratio > 100 then ''''Blank''''
        when hat_tag_y_n = 0 and parent_claim_count <3 and Loss_Ratio <= 100 then ''''Blank''''
          end  as Renewal_Tagging
from wrk_loss_mark_renewal_12

'';

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
