create or replace view BAGIC_PREPROD_CURATED_DB.BGIL_DEV_DATA_MODEL.STITCH_COMMON_CLASSIFICATION_INCR(
	PARENT_BK,
	PRIORITYCODE,
	SEGMENTCODE,
	RECORD_SOURCE
) as (
    



WITH affected_keys AS (
    
    SELECT DISTINCT part_id AS parent_bk
    FROM BAGIC_PREPROD_CURATED_DB.BGIL_DEV_DATA_MODEL.stg_partner__azbj_partner_extn
    WHERE part_id IS NOT NULL
      AND gg_change_date >= DATEADD(DAY, -1, CURRENT_DATE())
    UNION
    
    SELECT DISTINCT part_id AS parent_bk
    FROM BAGIC_PREPROD_CURATED_DB.BGIL_DEV_DATA_MODEL.stg_partner__bjaz_azbj_part_ext_hist
    WHERE part_id IS NOT NULL
      AND gg_change_date >= DATEADD(DAY, -1, CURRENT_DATE())
    UNION
    
    SELECT DISTINCT partner_id AS parent_bk
    FROM BAGIC_PREPROD_CURATED_DB.BGIL_DEV_DATA_MODEL.stg_partner__bjaz_hm_member_dtls
    WHERE partner_id IS NOT NULL
      AND gg_change_date >= DATEADD(DAY, -1, CURRENT_DATE())
    UNION
    
    SELECT DISTINCT intermediary_id AS parent_bk
    FROM BAGIC_PREPROD_CURATED_DB.BGIL_DEV_DATA_MODEL.stg_partner__bjaz_intermediary
    WHERE intermediary_id IS NOT NULL
      AND gg_change_date >= DATEADD(DAY, -1, CURRENT_DATE())
    UNION
    
    SELECT DISTINCT intermediary_id AS parent_bk
    FROM BAGIC_PREPROD_CURATED_DB.BGIL_DEV_DATA_MODEL.stg_partner__bjaz_intermediary_hist
    WHERE intermediary_id IS NOT NULL
      AND gg_change_date >= DATEADD(DAY, -1, CURRENT_DATE())
    
    
),

t0 AS (
    SELECT DISTINCT
        part_id AS parent_bk,
        NULLIF(TRIM(TO_VARCHAR(vip_cust)), '') AS prioritycode,
        NULLIF(TRIM(TO_VARCHAR(ucic_flag)), '') AS segmentcode
    FROM BAGIC_PREPROD_CURATED_DB.BGIL_DEV_DATA_MODEL.stg_partner__azbj_partner_extn
    WHERE part_id IS NOT NULL
      AND part_id IN (SELECT parent_bk FROM affected_keys)
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY part_id
        ORDER BY prioritycode, segmentcode
    ) = 1
),

t1 AS (
    SELECT DISTINCT
        part_id AS parent_bk,
        NULLIF(TRIM(TO_VARCHAR(vip_cust)), '') AS prioritycode
    FROM BAGIC_PREPROD_CURATED_DB.BGIL_DEV_DATA_MODEL.stg_partner__bjaz_azbj_part_ext_hist
    WHERE part_id IS NOT NULL
      AND part_id IN (SELECT parent_bk FROM affected_keys)
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY part_id
        ORDER BY prioritycode
    ) = 1
),

t2 AS (
    SELECT DISTINCT
        partner_id AS parent_bk,
        NULLIF(TRIM(TO_VARCHAR(vip_flg)), '') AS prioritycode
    FROM BAGIC_PREPROD_CURATED_DB.BGIL_DEV_DATA_MODEL.stg_partner__bjaz_hm_member_dtls
    WHERE partner_id IS NOT NULL
      AND partner_id IN (SELECT parent_bk FROM affected_keys)
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY partner_id
        ORDER BY prioritycode
    ) = 1
),

t3 AS (
    SELECT DISTINCT
        intermediary_id AS parent_bk,
        NULLIF(TRIM(TO_VARCHAR(flagging)), '') AS segmentcode
    FROM BAGIC_PREPROD_CURATED_DB.BGIL_DEV_DATA_MODEL.stg_partner__bjaz_intermediary
    WHERE intermediary_id IS NOT NULL
      AND intermediary_id IN (SELECT parent_bk FROM affected_keys)
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY intermediary_id
        ORDER BY segmentcode
    ) = 1
),

t4 AS (
    SELECT DISTINCT
        intermediary_id AS parent_bk,
        NULLIF(TRIM(TO_VARCHAR(flagging)), '') AS segmentcode
    FROM BAGIC_PREPROD_CURATED_DB.BGIL_DEV_DATA_MODEL.stg_partner__bjaz_intermediary_hist
    WHERE intermediary_id IS NOT NULL
      AND intermediary_id IN (SELECT parent_bk FROM affected_keys)
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY intermediary_id
        ORDER BY segmentcode
    ) = 1
),

stitched AS (
    SELECT
        COALESCE(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk) AS parent_bk,
        COALESCE(t0.prioritycode, t1.prioritycode, t2.prioritycode) AS prioritycode,
        COALESCE(t0.segmentcode, t3.segmentcode, t4.segmentcode) AS segmentcode,
        ARRAY_TO_STRING(ARRAY_CONSTRUCT_COMPACT(
            CASE WHEN t0.parent_bk IS NOT NULL THEN 'AZBJ_PARTNER_EXTN' END,
            CASE WHEN t1.parent_bk IS NOT NULL THEN 'BJAZ_AZBJ_PART_EXT_HIST' END,
            CASE WHEN t2.parent_bk IS NOT NULL THEN 'BJAZ_HM_MEMBER_DTLS' END,
            CASE WHEN t3.parent_bk IS NOT NULL THEN 'BJAZ_INTERMEDIARY' END,
            CASE WHEN t4.parent_bk IS NOT NULL THEN 'BJAZ_INTERMEDIARY_HIST' END
        ), ', ') AS record_source
    FROM t0
    FULL OUTER JOIN t1
        ON t0.parent_bk = t1.parent_bk
    FULL OUTER JOIN t2
        ON COALESCE(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    FULL OUTER JOIN t3
        ON COALESCE(t0.parent_bk, t1.parent_bk, t2.parent_bk) = t3.parent_bk
    FULL OUTER JOIN t4
        ON COALESCE(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk) = t4.parent_bk
)

SELECT
    parent_bk,
    prioritycode,
    segmentcode,
    record_source
FROM stitched


  );