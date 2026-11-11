-- CENTRAL VIEW v07_document -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_DOCUMENTS_DOCUMENT_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_QUERY_DETAILS_ROWS_COLUMNS_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_REQUIREMENTS_ROWS_COLUMNS_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_COMMUNICATION_DETAILS_ADDITION_TAB_MAIL
--   MAXI_HLTH_UWR_VW_DATA_COMMUNICATION_DETAILS_ADDITION_TAB_SMS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_REQUIREMENT_DETAILS_ROWS_CHILD_ROWS_ROWS_COLUMNS_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_REQUIREMENT_DETAILS_ROWS_COLUMNS_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_REQUIREMENT_DETAILS_ROWS_CHILD_ROWS_ROWS_COLUMNS_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_REQUIREMENT_DETAILS_ROWS_COLUMNS_PIVOT_VW
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_QUERY_DETAILS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_QUERY_DETAILS_ROWS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_QUERY_DETAILS_ROWS_COLUMNS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_REQUIREMENTS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_REQUIREMENTS_ROWS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_REQUIREMENTS_ROWS_COLUMNS
--   MAXI_HLTH_UWR_VW_DATA
--   MAXI_HLTH_UWR_VW_DATA_COMMUNICATION_DETAILS_ADDITION_TAB
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_REQUIREMENT_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_REQUIREMENT_DETAILS_ROWS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_REQUIREMENT_DETAILS_ROWS_COLUMNS
--   MAXI_HLTH_UWR_VW_DATA_REQUIREMENT_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_REQUIREMENT_DETAILS_ROWS
--   MAXI_HLTH_UWR_VW_DATA_REQUIREMENT_DETAILS_ROWS_COLUMNS
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_DOCUMENT_CHECKLIST
--   SAT_AUG_DOCUMENT_EMAIL_CONTENT
--   SAT_DOCUMENT_DEFINITION
--   SAT_DOCUMENT_EMAIL_CONTENT
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every feeding table.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif(t0.document_id, '') as DOCUMENT_BK,
        cast(null as varchar) as AUG_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK,
        cast(null as varchar) as AUG_DOCUMENT_CHECKLIST__DOCUMENT_BELONGS_TO_PARTY_ROLE,
        cast(null as varchar) as AUG_DOCUMENT_CHECKLIST__REQUIRED_FROM_PARTY_ROLE,
        cast(null as varchar) as AUG_DOCUMENT_CHECKLIST__REQUIREMENT_RAISED_BY_REFERENCE,
        cast(null as varchar) as AUG_DOCUMENT_CHECKLIST__REQUIREMENT_RAISED_DATE,
        cast(null as varchar) as AUG_DOCUMENT_EMAIL_CONTENT__DELIVERY_STATUS,
        cast(null as varchar) as DOCUMENT_DEFINITION__DOCUMENT_CATEGORY,
        cast(null as varchar) as DOCUMENT_DEFINITION__DOCUMENT_NAME,
        t0.document_number as DOCUMENT_DEFINITION__DOCUMENT_REFERENCE_NUMBER,
        cast(null as varchar) as DOCUMENT_DEFINITION__DOCUMENT_STATUS,
        t0.type_of_document as DOCUMENT_DEFINITION__DOCUMENT_TYPE,
        cast(null as varchar) as DOCUMENT_DEFINITION__FILE_SIZE,
        cast(null as varchar) as DOCUMENT_DEFINITION__PAGE_COUNT,
        t0.document_received_date as DOCUMENT_DEFINITION__RECEIVED_DATE,
        t0.source_of_document as DOCUMENT_DEFINITION__SOURCE_CHANNEL,
        cast(null as varchar) as DOCUMENT_EMAIL_CONTENT__EMAIL_BODY,
        cast(null as varchar) as DOCUMENT_EMAIL_CONTENT__EMAIL_FROM,
        cast(null as varchar) as DOCUMENT_EMAIL_CONTENT__EMAIL_SUBJECT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.document_id, '')) is not null

    union all

    -- branch 1: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif('INWARD:' || nullif(trim(t0.inward_number),''), '') as DOCUMENT_BK,
        null, null, null, null, null, null, null,
        coalesce(t0.inward_document_list, t0.uploaded_inward_document) as DOCUMENT_DEFINITION__DOCUMENT_NAME,
        t0.inward_number as DOCUMENT_DEFINITION__DOCUMENT_REFERENCE_NUMBER,
        t0.inward_status as DOCUMENT_DEFINITION__DOCUMENT_STATUS,
        null, null,
        t0.number_of_pages as DOCUMENT_DEFINITION__PAGE_COUNT,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('INWARD:' || nullif(trim(t0.inward_number),''), '')) is not null

    union all

    -- branch 2: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif('INWARD:' || nullif(trim(t0.child_inward),''), '') as DOCUMENT_BK,
        null, null, null, null, null, null, null, null,
        t0.child_inward as DOCUMENT_DEFINITION__DOCUMENT_REFERENCE_NUMBER,
        null, null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('INWARD:' || nullif(trim(t0.child_inward),''), '')) is not null

    union all

    -- branch 3: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_DOCUMENTS_DOCUMENT_PIVOT_VW
    select
        nullif(t0.document_id, '') as DOCUMENT_BK,
        null, null, null, null, null, null,
        t0.adhoc_doc_type as DOCUMENT_DEFINITION__DOCUMENT_CATEGORY,
        t0.document_name as DOCUMENT_DEFINITION__DOCUMENT_NAME,
        null,
        t0.upload_status as DOCUMENT_DEFINITION__DOCUMENT_STATUS,
        t0.document_type as DOCUMENT_DEFINITION__DOCUMENT_TYPE,
        t0.document_size as DOCUMENT_DEFINITION__FILE_SIZE,
        null,
        t0.created_on as DOCUMENT_DEFINITION__RECEIVED_DATE,
        null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_documents_document_pv') }} t0
    where (nullif(t0.document_id, '')) is not null

    union all

    -- branch 4: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_QUERY_DETAILS_ROWS_COLUMNS_PIVOT_VW
    select
        nullif('CLMDOC:' || nullif(trim(j4.claim_number),'') || '#' || t0.document_name, '') as DOCUMENT_BK,
        t0.document_type as AUG_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK,
        t0._document_belongs_to as AUG_DOCUMENT_CHECKLIST__DOCUMENT_BELONGS_TO_PARTY_ROLE,
        null, null, null, null, null,
        t0.document_name as DOCUMENT_DEFINITION__DOCUMENT_NAME,
        null, null,
        t0.document_type as DOCUMENT_DEFINITION__DOCUMENT_TYPE,
        null, null,
        t0.created_on as DOCUMENT_DEFINITION__RECEIVED_DATE,
        null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_query_dtls_rows_columns_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_query_dtls_rows_columns') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_query_dtls_rows') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_query_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif('CLMDOC:' || nullif(trim(j4.claim_number),'') || '#' || t0.document_name, '')) is not null

    union all

    -- branch 5: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_REQUIREMENTS_ROWS_COLUMNS_PIVOT_VW
    select
        nullif('CLMDOC:' || nullif(trim(j4.claim_number),'') || '#' || t0.document_name, '') as DOCUMENT_BK,
        t0.document_type as AUG_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK,
        null,
        t0._required_from as AUG_DOCUMENT_CHECKLIST__REQUIRED_FROM_PARTY_ROLE,
        t0.created_by as AUG_DOCUMENT_CHECKLIST__REQUIREMENT_RAISED_BY_REFERENCE,
        t0.created_on as AUG_DOCUMENT_CHECKLIST__REQUIREMENT_RAISED_DATE,
        null, null,
        t0.document_name as DOCUMENT_DEFINITION__DOCUMENT_NAME,
        null, null,
        t0.document_type as DOCUMENT_DEFINITION__DOCUMENT_TYPE,
        null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_requirements_rows_columns_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_requirements_rows_columns') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_requirements_rows') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_requirements') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif('CLMDOC:' || nullif(trim(j4.claim_number),'') || '#' || t0.document_name, '')) is not null

    union all

    -- branch 6: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif('INWARD:' || nullif(trim(t0.inward_number),''), '') as DOCUMENT_BK,
        null, null, null, null, null, null,
        t0.inward_type as DOCUMENT_DEFINITION__DOCUMENT_CATEGORY,
        null,
        t0.inward_number as DOCUMENT_DEFINITION__DOCUMENT_REFERENCE_NUMBER,
        null, null, null, null,
        t0.inward_date as DOCUMENT_DEFINITION__RECEIVED_DATE,
        t0.document_source as DOCUMENT_DEFINITION__SOURCE_CHANNEL,
        null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif('INWARD:' || nullif(trim(t0.inward_number),''), '')) is not null

    union all

    -- branch 7: MAXI_HLTH_UWR_VW_DATA_COMMUNICATION_DETAILS_ADDITION_TAB_MAIL
    select
        nullif('COMM-MAIL:' || coalesce(nullif(trim(j2.proposal_number),''),'') || ':' || md5(normalise(nullif(trim(coalesce(t0.from_col,'') || '#' || coalesce(t0.subject,'') || '#' || coalesce(t0.body,'')), '##'))), '') as DOCUMENT_BK,
        null, null, null, null, null,
        t0.status as AUG_DOCUMENT_EMAIL_CONTENT__DELIVERY_STATUS,
        null, null, null, null,
        t0.communication_type as DOCUMENT_DEFINITION__DOCUMENT_TYPE,
        null, null, null, null,
        t0.body as DOCUMENT_EMAIL_CONTENT__EMAIL_BODY,
        t0.from_col as DOCUMENT_EMAIL_CONTENT__EMAIL_FROM,
        t0.subject as DOCUMENT_EMAIL_CONTENT__EMAIL_SUBJECT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_communication_dtls_addition_tab_mail') }} t0
    left join {{ ref('stg_mxh__uwr_communication_dtls_addition_tab') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif('COMM-MAIL:' || coalesce(nullif(trim(j2.proposal_number),''),'') || ':' || md5(normalise(nullif(trim(coalesce(t0.from_col,'') || '#' || coalesce(t0.subject,'') || '#' || coalesce(t0.body,'')), '##'))), '')) is not null

    union all

    -- branch 8: MAXI_HLTH_UWR_VW_DATA_COMMUNICATION_DETAILS_ADDITION_TAB_SMS
    select
        nullif('COMM-SMS:' || coalesce(nullif(trim(j2.proposal_number),''),'') || ':' || md5(normalise(nullif(trim(coalesce(t0.from_col,'') || '#' || coalesce(t0.subject,'') || '#' || coalesce(t0.body,'')), '##'))), '') as DOCUMENT_BK,
        null, null, null, null, null,
        t0.status as AUG_DOCUMENT_EMAIL_CONTENT__DELIVERY_STATUS,
        null, null, null, null,
        t0.communication_type as DOCUMENT_DEFINITION__DOCUMENT_TYPE,
        null, null, null, null,
        t0.body as DOCUMENT_EMAIL_CONTENT__EMAIL_BODY,
        t0.from_col as DOCUMENT_EMAIL_CONTENT__EMAIL_FROM,
        t0.subject as DOCUMENT_EMAIL_CONTENT__EMAIL_SUBJECT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_communication_dtls_addition_tab_sms') }} t0
    left join {{ ref('stg_mxh__uwr_communication_dtls_addition_tab') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif('COMM-SMS:' || coalesce(nullif(trim(j2.proposal_number),''),'') || ':' || md5(normalise(nullif(trim(coalesce(t0.from_col,'') || '#' || coalesce(t0.subject,'') || '#' || coalesce(t0.body,'')), '##'))), '')) is not null

    union all

    -- branch 9: MAXI_HLTH_UWR_VW_DATA_MEMBERS_REQUIREMENT_DETAILS_ROWS_CHILD_ROWS_ROWS_COLUMNS_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.parent_key_hash,'') || '#' || coalesce(t0.requirementname,'')), '#'))), '') as DOCUMENT_BK,
        null, null, null, null, null, null, null,
        t0.uploadedrequirement as DOCUMENT_DEFINITION__DOCUMENT_NAME,
        null, null, null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_requirement_dtls_rows_child_rows_rows_columns_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.parent_key_hash,'') || '#' || coalesce(t0.requirementname,'')), '#'))), '')) is not null

    union all

    -- branch 10: MAXI_HLTH_UWR_VW_DATA_MEMBERS_REQUIREMENT_DETAILS_ROWS_COLUMNS_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(nullif(trim(j5.proposal_number),''),'') || '|' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),'') || '|' || coalesce(t0.documenttype,'') || '|' || coalesce(t0.documentname,'')), '|||'))), '') as DOCUMENT_BK,
        null, null, null, null, null, null,
        t0.documentbelongsto as DOCUMENT_DEFINITION__DOCUMENT_CATEGORY,
        t0.documentname as DOCUMENT_DEFINITION__DOCUMENT_NAME,
        null, null,
        t0.documenttype as DOCUMENT_DEFINITION__DOCUMENT_TYPE,
        null, null,
        t0.createdon as DOCUMENT_DEFINITION__RECEIVED_DATE,
        null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_requirement_dtls_rows_columns_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_requirement_dtls_rows_columns') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_requirement_dtls_rows') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_requirement_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j4.KEY_HASH
    where (nullif(md5(normalise(nullif(trim(coalesce(nullif(trim(j5.proposal_number),''),'') || '|' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),'') || '|' || coalesce(t0.documenttype,'') || '|' || coalesce(t0.documentname,'')), '|||'))), '')) is not null

    union all

    -- branch 11: MAXI_HLTH_UWR_VW_DATA_REQUIREMENT_DETAILS_ROWS_CHILD_ROWS_ROWS_COLUMNS_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.parent_key_hash,'') || '#' || coalesce(t0.requirementname,'')), '#'))), '') as DOCUMENT_BK,
        null, null, null, null, null, null, null,
        t0.uploadedrequirement as DOCUMENT_DEFINITION__DOCUMENT_NAME,
        null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_requirement_dtls_rows_child_rows_rows_columns_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.parent_key_hash,'') || '#' || coalesce(t0.requirementname,'')), '#'))), '')) is not null

    union all

    -- branch 12: MAXI_HLTH_UWR_VW_DATA_REQUIREMENT_DETAILS_ROWS_COLUMNS_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(nullif(trim(j4.proposal_number),''),'') || '|' || coalesce(t0.documenttype,'') || '|' || coalesce(t0.documentname,'')), '||'))), '') as DOCUMENT_BK,
        null, null, null, null, null, null,
        t0.documentbelongsto as DOCUMENT_DEFINITION__DOCUMENT_CATEGORY,
        t0.documentname as DOCUMENT_DEFINITION__DOCUMENT_NAME,
        null, null,
        t0.documenttype as DOCUMENT_DEFINITION__DOCUMENT_TYPE,
        null, null,
        t0.createdon as DOCUMENT_DEFINITION__RECEIVED_DATE,
        null, null, null, null,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_requirement_dtls_rows_columns_pv') }} t0
    left join {{ ref('stg_mxh__uwr_requirement_dtls_rows_columns') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_requirement_dtls_rows') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_requirement_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(md5(normalise(nullif(trim(coalesce(nullif(trim(j4.proposal_number),''),'') || '|' || coalesce(t0.documenttype,'') || '|' || coalesce(t0.documentname,'')), '||'))), '')) is not null

)

select
    DOCUMENT_BK,
    AUG_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK,
    first_value(AUG_DOCUMENT_CHECKLIST__DOCUMENT_BELONGS_TO_PARTY_ROLE) ignore nulls over (partition by DOCUMENT_BK, AUG_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_CHECKLIST__DOCUMENT_BELONGS_TO_PARTY_ROLE,
    first_value(AUG_DOCUMENT_CHECKLIST__REQUIRED_FROM_PARTY_ROLE) ignore nulls over (partition by DOCUMENT_BK, AUG_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_CHECKLIST__REQUIRED_FROM_PARTY_ROLE,
    first_value(AUG_DOCUMENT_CHECKLIST__REQUIREMENT_RAISED_BY_REFERENCE) ignore nulls over (partition by DOCUMENT_BK, AUG_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_CHECKLIST__REQUIREMENT_RAISED_BY_REFERENCE,
    first_value(AUG_DOCUMENT_CHECKLIST__REQUIREMENT_RAISED_DATE) ignore nulls over (partition by DOCUMENT_BK, AUG_DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_CHECKLIST__REQUIREMENT_RAISED_DATE,
    first_value(AUG_DOCUMENT_EMAIL_CONTENT__DELIVERY_STATUS) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_EMAIL_CONTENT__DELIVERY_STATUS,
    first_value(DOCUMENT_DEFINITION__DOCUMENT_CATEGORY) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_DEFINITION__DOCUMENT_CATEGORY,
    first_value(DOCUMENT_DEFINITION__DOCUMENT_NAME) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_DEFINITION__DOCUMENT_NAME,
    first_value(DOCUMENT_DEFINITION__DOCUMENT_REFERENCE_NUMBER) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_DEFINITION__DOCUMENT_REFERENCE_NUMBER,
    first_value(DOCUMENT_DEFINITION__DOCUMENT_STATUS) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_DEFINITION__DOCUMENT_STATUS,
    first_value(DOCUMENT_DEFINITION__DOCUMENT_TYPE) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_DEFINITION__DOCUMENT_TYPE,
    first_value(DOCUMENT_DEFINITION__FILE_SIZE) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_DEFINITION__FILE_SIZE,
    first_value(DOCUMENT_DEFINITION__PAGE_COUNT) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_DEFINITION__PAGE_COUNT,
    first_value(DOCUMENT_DEFINITION__RECEIVED_DATE) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_DEFINITION__RECEIVED_DATE,
    first_value(DOCUMENT_DEFINITION__SOURCE_CHANNEL) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_DEFINITION__SOURCE_CHANNEL,
    first_value(DOCUMENT_EMAIL_CONTENT__EMAIL_BODY) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_EMAIL_CONTENT__EMAIL_BODY,
    first_value(DOCUMENT_EMAIL_CONTENT__EMAIL_FROM) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_EMAIL_CONTENT__EMAIL_FROM,
    first_value(DOCUMENT_EMAIL_CONTENT__EMAIL_SUBJECT) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_EMAIL_CONTENT__EMAIL_SUBJECT
from merged
