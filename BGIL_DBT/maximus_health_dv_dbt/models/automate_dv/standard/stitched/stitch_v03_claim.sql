-- CENTRAL VIEW v03_claim -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_HLTH_CLM_VW_DATA_AUTHORIZATION_REMARKS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_NOTES_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_QUERY_DETAILS_ROWS_COLUMNS_CHILD_ROWS_ROWS_COLUMNS_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_REQUIREMENTS_ROWS_COLUMNS_CHILD_ROWS_ROWS_COLUMNS_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_POLICY_HISTORY_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_POLICY_CLAIM_HISTORY_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_REQUIREMENT_DETAILS_ROWS_CHILD_ROWS_ROWS_COLUMNS_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_REQUIREMENT_DETAILS_ROWS_CHILD_ROWS_ROWS_COLUMNS_PIVOT_VW
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_HLTH_CLM_VW_DATA
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_NOTES
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_NOTES_ATTRIBUTES
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_QUERY_DETAILS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_QUERY_DETAILS_ROWS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_QUERY_DETAILS_ROWS_COLUMNS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_QUERY_DETAILS_ROWS_COLUMNS_CHILD_ROWS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_QUERY_DETAILS_ROWS_COLUMNS_CHILD_ROWS_ROWS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_QUERY_DETAILS_ROWS_COLUMNS_CHILD_ROWS_ROWS_COLUMNS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_POLICY_HISTORY
--   MAXI_HLTH_CLM_VW_DATA_POLICY_CLAIM_HISTORY
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CLAIM_NOTE
--   SAT_AUG_CLAIM_PRIOR_POLICY_HISTORY
--   SAT_CLAIM_COMMUNICATION
--   SAT_CLAIM_EVIDENCE
--   SAT_CLAIM_NOTE
--   SAT_DOCUMENT_CHECKLIST
-- Links whose legs come from one source row on this view (rule 6):
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_HLTH_CLM_VW_DATA_AUTHORIZATION_REMARKS
    select
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as CLAIM_BK,
        cast(null as varchar) as DOCUMENT_BK,
        cast(null as varchar) as AUG_CLAIM_NOTE__NOTE_SEQUENCE_CK,
        cast(null as varchar) as AUG_CLAIM_NOTE__ASSIGNED_TO_NAME,
        cast(null as varchar) as AUG_CLAIM_NOTE__ASSIGNED_TO_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_NOTE__NOTE_SUMMARY,
        cast(null as varchar) as AUG_CLAIM_PRIOR_POLICY_HISTORY__PRIOR_POLICY_NUMBER_CK,
        cast(null as varchar) as AUG_CLAIM_PRIOR_POLICY_HISTORY__PRIOR_POLICY_REFERENCE_CK,
        cast(null as varchar) as AUG_CLAIM_PRIOR_POLICY_HISTORY__PRIOR_CLAIM_HISTORY_DESCRIPTION,
        cast(null as varchar) as AUG_CLAIM_PRIOR_POLICY_HISTORY__PRIOR_POLICY_HISTORY_DETAIL,
        cast(null as varchar) as CLAIM_COMMUNICATION__COMMUNICATION_DATE_CK,
        cast(null as varchar) as CLAIM_COMMUNICATION__SEQUENCE_CK,
        cast(null as varchar) as CLAIM_COMMUNICATION__COMMUNICATION_DATE,
        cast(null as varchar) as CLAIM_COMMUNICATION__SENT_BY_REFERENCE,
        cast(null as varchar) as CLAIM_COMMUNICATION__STATUS,
        cast(null as varchar) as CLAIM_COMMUNICATION__SUBJECT,
        cast(null as varchar) as CLAIM_EVIDENCE__EVIDENCE_TYPE_CK,
        cast(null as varchar) as CLAIM_EVIDENCE__MEDIA_REFERENCE_CK,
        cast(null as varchar) as CLAIM_EVIDENCE__EVIDENCE_TYPE,
        cast(null as varchar) as CLAIM_EVIDENCE__MEDIA_REFERENCE,
        t0.name as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        cast(null as varchar) as CLAIM_NOTE__NOTE_CATEGORY,
        t0.value as CLAIM_NOTE__NOTE_TEXT,
        t0.name as CLAIM_NOTE__NOTE_TYPE,
        cast(null as varchar) as DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK,
        cast(null as varchar) as DOCUMENT_CHECKLIST__MANDATORY_INDICATOR,
        cast(null as varchar) as DOCUMENT_CHECKLIST__RECEIVED_INDICATOR,
        cast(null as varchar) as DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE,
        cast(null as varchar) as DOCUMENT_CHECKLIST__VERIFICATION_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_auth_remarks') }} t0
    left join {{ ref('stg_mxh__clm') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.claim_number) as _V, count(distinct d0.claim_number) as _N
            from {{ ref('stg_mxh__clm_cd') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j1.KEY_HASH
    where (nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 1: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_NOTE.Note Sequence=REMARK_1
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'REMARK_1' as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        null,
        t0.remarks1 as CLAIM_NOTE__NOTE_TEXT,
        null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.claim_number, '')) is not null

    union all

    -- branch 2: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_NOTE.Note Sequence=REMARK_2
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'REMARK_2' as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        null,
        t0.remarks2 as CLAIM_NOTE__NOTE_TEXT,
        null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.claim_number, '')) is not null

    union all

    -- branch 3: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_NOTE.Note Sequence=REMARK_3
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'REMARK_3' as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        null,
        t0.remarks3 as CLAIM_NOTE__NOTE_TEXT,
        null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.claim_number, '')) is not null

    union all

    -- branch 4: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_NOTE.Note Sequence=REMARK_4
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'REMARK_4' as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        null,
        t0.remarks4 as CLAIM_NOTE__NOTE_TEXT,
        null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.claim_number, '')) is not null

    union all

    -- branch 5: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_NOTE.Note Sequence=REMARK_5
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'REMARK_5' as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        null,
        t0.remarks5 as CLAIM_NOTE__NOTE_TEXT,
        null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.claim_number, '')) is not null

    union all

    -- branch 6: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_NOTE.Note Sequence=REMARK_6
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'REMARK_6' as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        null,
        t0.remarks6 as CLAIM_NOTE__NOTE_TEXT,
        null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.claim_number, '')) is not null

    union all

    -- branch 7: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_NOTE.Note Sequence=REMARK_7
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'REMARK_7' as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        null,
        t0.remarks7 as CLAIM_NOTE__NOTE_TEXT,
        null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.claim_number, '')) is not null

    union all

    -- branch 8: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_NOTE.Note Sequence=REMARK_8
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'REMARK_8' as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        null,
        t0.remarks8 as CLAIM_NOTE__NOTE_TEXT,
        null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.claim_number, '')) is not null

    union all

    -- branch 9: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_NOTE.Note Sequence=REMARK_9
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'REMARK_9' as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        null,
        t0.remarks9 as CLAIM_NOTE__NOTE_TEXT,
        null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.claim_number, '')) is not null

    union all

    -- branch 10: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_NOTE.Note Sequence=REMARK_10
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'REMARK_10' as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        null,
        t0.remarks10 as CLAIM_NOTE__NOTE_TEXT,
        null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.claim_number, '')) is not null

    union all

    -- branch 11: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_NOTE.Note Sequence=REMARK_11
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'REMARK_11' as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        null,
        t0.remarks11 as CLAIM_NOTE__NOTE_TEXT,
        null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.claim_number, '')) is not null

    union all

    -- branch 12: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_NOTE.Note Sequence=REMARK_12
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'REMARK_12' as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        null,
        t0.remarks12 as CLAIM_NOTE__NOTE_TEXT,
        null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.claim_number, '')) is not null

    union all

    -- branch 13: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_NOTE.Note Sequence=FOLLOW_UP_DETAILS
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FOLLOW_UP_DETAILS' as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        null,
        t0.follow_up_details as CLAIM_NOTE__NOTE_TEXT,
        null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.claim_number, '')) is not null

    union all

    -- branch 14: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_NOTE.Note Sequence=INVESTIGATION_COMMENTS
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'INVESTIGATION_COMMENTS' as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        null,
        t0.investigation_comments as CLAIM_NOTE__NOTE_TEXT,
        null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.claim_number, '')) is not null

    union all

    -- branch 15: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_NOTE.Note Sequence=NEGOTIATION_REMARKS
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NEGOTIATION_REMARKS' as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        null,
        t0.negotiated_remarks as CLAIM_NOTE__NOTE_TEXT,
        null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.claim_number, '')) is not null

    union all

    -- branch 16: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_NOTE.Note Sequence=OTHERS
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'OTHERS' as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        null,
        t0.others as CLAIM_NOTE__NOTE_TEXT,
        null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.claim_number, '')) is not null

    union all

    -- branch 17: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
    select
        null,
        nullif('INWARD:' || nullif(trim(t0.inward_number),''), '') as DOCUMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.type_of_document as DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK,
        null,
        t0.inward_document_received as DOCUMENT_CHECKLIST__RECEIVED_INDICATOR,
        null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('INWARD:' || nullif(trim(t0.inward_number),''), '')) is not null

    union all

    -- branch 18: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_NOTES_ATTRIBUTES_PIVOT_VW
    select
        nullif(nullif(trim(j3.claim_number),''), '') as CLAIM_BK,
        null,
        t0.note_code as AUG_CLAIM_NOTE__NOTE_SEQUENCE_CK,
        t0.assigned_user_name as AUG_CLAIM_NOTE__ASSIGNED_TO_NAME,
        t0.assigned_user_code as AUG_CLAIM_NOTE__ASSIGNED_TO_REFERENCE,
        t0.description as AUG_CLAIM_NOTE__NOTE_SUMMARY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.note_code as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        null,
        t0.long_description as CLAIM_NOTE__NOTE_TEXT,
        t0.note_code as CLAIM_NOTE__NOTE_TYPE,
        null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_notes_attrs_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_notes_attrs') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd_notes') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.claim_number),''), '')) is not null

    union all

    -- branch 19: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_QUERY_DETAILS_ROWS_COLUMNS_CHILD_ROWS_ROWS_COLUMNS_PIVOT_VW
    select
        nullif(nullif(trim(j7.claim_number),''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null,
        t0.chaser_date as CLAIM_COMMUNICATION__COMMUNICATION_DATE_CK,
        t0.sequence_no as CLAIM_COMMUNICATION__SEQUENCE_CK,
        t0.chaser_date as CLAIM_COMMUNICATION__COMMUNICATION_DATE,
        null,
        t0.chaser_status as CLAIM_COMMUNICATION__STATUS,
        t0.chaser_document as CLAIM_COMMUNICATION__SUBJECT,
        t0.document_title as CLAIM_EVIDENCE__EVIDENCE_TYPE_CK,
        t0.uploaded_documents as CLAIM_EVIDENCE__MEDIA_REFERENCE_CK,
        t0.document_title as CLAIM_EVIDENCE__EVIDENCE_TYPE,
        t0.uploaded_documents as CLAIM_EVIDENCE__MEDIA_REFERENCE,
        t0.raised_date || '#' || t0.sequence_no as CLAIM_NOTE__NOTE_SEQUENCE_CK,
        t0.medicaltechnical as CLAIM_NOTE__NOTE_CATEGORY,
        t0.remarks as CLAIM_NOTE__NOTE_TEXT,
        null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_query_dtls_rows_columns_child_rows_rows_columns_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_query_dtls_rows_columns_child_rows_rows_columns') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd_query_dtls_rows_columns_child_rows_rows') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_query_dtls_rows_columns_child_rows') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_query_dtls_rows_columns') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_query_dtls_rows') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_query_dtls') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j7 on j7.KEY_HASH = j6.PARENT_KEY_HASH
    where (nullif(nullif(trim(j7.claim_number),''), '')) is not null

    union all

    -- branch 20: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_QUERY_DETAILS_ROWS_COLUMNS_CHILD_ROWS_ROWS_COLUMNS_PIVOT_VW
    select
        nullif(nullif(trim(j7.claim_number),''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null,
        t0.raised_date as CLAIM_COMMUNICATION__COMMUNICATION_DATE_CK,
        t0.sequence_no as CLAIM_COMMUNICATION__SEQUENCE_CK,
        t0.raised_date as CLAIM_COMMUNICATION__COMMUNICATION_DATE,
        t0.raised_by as CLAIM_COMMUNICATION__SENT_BY_REFERENCE,
        t0.requirement_status as CLAIM_COMMUNICATION__STATUS,
        t0.requirement_details as CLAIM_COMMUNICATION__SUBJECT,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_query_dtls_rows_columns_child_rows_rows_columns_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_query_dtls_rows_columns_child_rows_rows_columns') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd_query_dtls_rows_columns_child_rows_rows') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_query_dtls_rows_columns_child_rows') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_query_dtls_rows_columns') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_query_dtls_rows') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_query_dtls') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j7 on j7.KEY_HASH = j6.PARENT_KEY_HASH
    where (nullif(nullif(trim(j7.claim_number),''), '')) is not null

    union all

    -- branch 21: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_REQUIREMENTS_ROWS_COLUMNS_CHILD_ROWS_ROWS_COLUMNS_PIVOT_VW
    select
        null,
        nullif(md5(normalise(nullif(trim(t0.foreign_key), ''))), '') as DOCUMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.document_title || '#' || t0.sequence_no as DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK,
        t0.mandatoryoptional as DOCUMENT_CHECKLIST__MANDATORY_INDICATOR,
        null,
        t0.document_title as DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE,
        null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_requirements_rows_columns_child_rows_rows_columns_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(t0.foreign_key), ''))), '')) is not null

    union all

    -- branch 22: MAXI_HLTH_CLM_VW_DATA_CLAIM_POLICY_HISTORY_PIVOT_VW
    select
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as CLAIM_BK,
        null, null, null, null, null, null, null,
        t0.claim_history as AUG_CLAIM_PRIOR_POLICY_HISTORY__PRIOR_CLAIM_HISTORY_DESCRIPTION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_claim_policy_history_pv') }} t0
    left join {{ ref('stg_mxh__clm_claim_policy_history') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.claim_number) as _V, count(distinct d0.claim_number) as _N
            from {{ ref('stg_mxh__clm_cd') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 23: MAXI_HLTH_CLM_VW_DATA_POLICY_CLAIM_HISTORY_PIVOT_VW
    select
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null,
        t0.policy_history as AUG_CLAIM_PRIOR_POLICY_HISTORY__PRIOR_POLICY_HISTORY_DETAIL,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_policy_claim_history_pv') }} t0
    left join {{ ref('stg_mxh__clm_policy_claim_history') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.claim_number) as _V, count(distinct d0.claim_number) as _N
            from {{ ref('stg_mxh__clm_cd') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 24: MAXI_HLTH_UWR_VW_DATA_MEMBERS_REQUIREMENT_DETAILS_ROWS_CHILD_ROWS_ROWS_COLUMNS_PIVOT_VW
    select
        null,
        nullif(md5(normalise(nullif(trim(coalesce(t0.parent_key_hash,'') || '#' || coalesce(t0.requirementname,'')), '#'))), '') as DOCUMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.requirementname || '#' || t0.sequenceno as DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK,
        t0.mandatoryoptional as DOCUMENT_CHECKLIST__MANDATORY_INDICATOR,
        null,
        t0.requirementname as DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE,
        t0.requirementstatus as DOCUMENT_CHECKLIST__VERIFICATION_STATUS,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_requirement_dtls_rows_child_rows_rows_columns_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.parent_key_hash,'') || '#' || coalesce(t0.requirementname,'')), '#'))), '')) is not null

    union all

    -- branch 25: MAXI_HLTH_UWR_VW_DATA_REQUIREMENT_DETAILS_ROWS_CHILD_ROWS_ROWS_COLUMNS_PIVOT_VW
    select
        null,
        nullif(md5(normalise(nullif(trim(coalesce(t0.parent_key_hash,'') || '#' || coalesce(t0.requirementname,'')), '#'))), '') as DOCUMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.requirementname || '#' || t0.sequenceno as DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK,
        t0.mandatoryoptional as DOCUMENT_CHECKLIST__MANDATORY_INDICATOR,
        null,
        t0.requirementname as DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE,
        t0.requirementstatus as DOCUMENT_CHECKLIST__VERIFICATION_STATUS,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_requirement_dtls_rows_child_rows_rows_columns_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.parent_key_hash,'') || '#' || coalesce(t0.requirementname,'')), '#'))), '')) is not null

)

select
    CLAIM_BK,
    DOCUMENT_BK,
    AUG_CLAIM_NOTE__NOTE_SEQUENCE_CK,
    first_value(AUG_CLAIM_NOTE__ASSIGNED_TO_NAME) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_NOTE__NOTE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_NOTE__ASSIGNED_TO_NAME,
    first_value(AUG_CLAIM_NOTE__ASSIGNED_TO_REFERENCE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_NOTE__NOTE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_NOTE__ASSIGNED_TO_REFERENCE,
    first_value(AUG_CLAIM_NOTE__NOTE_SUMMARY) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_NOTE__NOTE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_NOTE__NOTE_SUMMARY,
    AUG_CLAIM_PRIOR_POLICY_HISTORY__PRIOR_POLICY_NUMBER_CK,
    AUG_CLAIM_PRIOR_POLICY_HISTORY__PRIOR_POLICY_REFERENCE_CK,
    first_value(AUG_CLAIM_PRIOR_POLICY_HISTORY__PRIOR_CLAIM_HISTORY_DESCRIPTION) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PRIOR_POLICY_HISTORY__PRIOR_POLICY_NUMBER_CK, AUG_CLAIM_PRIOR_POLICY_HISTORY__PRIOR_POLICY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PRIOR_POLICY_HISTORY__PRIOR_CLAIM_HISTORY_DESCRIPTION,
    first_value(AUG_CLAIM_PRIOR_POLICY_HISTORY__PRIOR_POLICY_HISTORY_DETAIL) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PRIOR_POLICY_HISTORY__PRIOR_POLICY_NUMBER_CK, AUG_CLAIM_PRIOR_POLICY_HISTORY__PRIOR_POLICY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PRIOR_POLICY_HISTORY__PRIOR_POLICY_HISTORY_DETAIL,
    CLAIM_COMMUNICATION__COMMUNICATION_DATE_CK,
    CLAIM_COMMUNICATION__SEQUENCE_CK,
    first_value(CLAIM_COMMUNICATION__COMMUNICATION_DATE) ignore nulls over (partition by CLAIM_BK, CLAIM_COMMUNICATION__COMMUNICATION_DATE_CK, CLAIM_COMMUNICATION__SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_COMMUNICATION__COMMUNICATION_DATE,
    first_value(CLAIM_COMMUNICATION__SENT_BY_REFERENCE) ignore nulls over (partition by CLAIM_BK, CLAIM_COMMUNICATION__COMMUNICATION_DATE_CK, CLAIM_COMMUNICATION__SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_COMMUNICATION__SENT_BY_REFERENCE,
    first_value(CLAIM_COMMUNICATION__STATUS) ignore nulls over (partition by CLAIM_BK, CLAIM_COMMUNICATION__COMMUNICATION_DATE_CK, CLAIM_COMMUNICATION__SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_COMMUNICATION__STATUS,
    first_value(CLAIM_COMMUNICATION__SUBJECT) ignore nulls over (partition by CLAIM_BK, CLAIM_COMMUNICATION__COMMUNICATION_DATE_CK, CLAIM_COMMUNICATION__SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_COMMUNICATION__SUBJECT,
    CLAIM_EVIDENCE__EVIDENCE_TYPE_CK,
    CLAIM_EVIDENCE__MEDIA_REFERENCE_CK,
    first_value(CLAIM_EVIDENCE__EVIDENCE_TYPE) ignore nulls over (partition by CLAIM_BK, CLAIM_EVIDENCE__EVIDENCE_TYPE_CK, CLAIM_EVIDENCE__MEDIA_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_EVIDENCE__EVIDENCE_TYPE,
    first_value(CLAIM_EVIDENCE__MEDIA_REFERENCE) ignore nulls over (partition by CLAIM_BK, CLAIM_EVIDENCE__EVIDENCE_TYPE_CK, CLAIM_EVIDENCE__MEDIA_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_EVIDENCE__MEDIA_REFERENCE,
    CLAIM_NOTE__NOTE_SEQUENCE_CK,
    first_value(CLAIM_NOTE__NOTE_CATEGORY) ignore nulls over (partition by CLAIM_BK, CLAIM_NOTE__NOTE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_NOTE__NOTE_CATEGORY,
    first_value(CLAIM_NOTE__NOTE_TEXT) ignore nulls over (partition by CLAIM_BK, CLAIM_NOTE__NOTE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_NOTE__NOTE_TEXT,
    first_value(CLAIM_NOTE__NOTE_TYPE) ignore nulls over (partition by CLAIM_BK, CLAIM_NOTE__NOTE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_NOTE__NOTE_TYPE,
    DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK,
    first_value(DOCUMENT_CHECKLIST__MANDATORY_INDICATOR) ignore nulls over (partition by DOCUMENT_BK, DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_CHECKLIST__MANDATORY_INDICATOR,
    first_value(DOCUMENT_CHECKLIST__RECEIVED_INDICATOR) ignore nulls over (partition by DOCUMENT_BK, DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_CHECKLIST__RECEIVED_INDICATOR,
    first_value(DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE) ignore nulls over (partition by DOCUMENT_BK, DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE,
    first_value(DOCUMENT_CHECKLIST__VERIFICATION_STATUS) ignore nulls over (partition by DOCUMENT_BK, DOCUMENT_CHECKLIST__REQUIRED_DOCUMENT_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as DOCUMENT_CHECKLIST__VERIFICATION_STATUS
from merged
