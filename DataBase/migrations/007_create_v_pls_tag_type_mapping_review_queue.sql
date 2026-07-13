DROP VIEW IF EXISTS v_pls_tag_type_mapping_review_queue;

CREATE VIEW v_pls_tag_type_mapping_review_queue AS
SELECT
  mappings.id,
  mappings.platform,
  mappings.tag_type,
  catalog_stats.tag_count,
  mappings.mapping_status,
  mappings.mapping_method,
  mappings.confidence,
  mappings.dimension_id,
  dimensions.layer_code,
  dimensions.dimension_code,
  dimensions.dimension_name,
  mappings.rationale,
  CASE
    WHEN mappings.mapping_status = 'unmapped' THEN 1
    WHEN mappings.mapping_status = 'review_needed' THEN 2
    WHEN mappings.mapping_status = 'proposed' THEN 3
    ELSE 9
  END AS review_priority,
  CASE
    WHEN mappings.mapping_status = 'unmapped' THEN '需要人工选择PLS维度'
    WHEN mappings.mapping_status = 'review_needed' THEN '需要人工确认或修正建议维度'
    WHEN mappings.mapping_status = 'proposed' THEN '可批量抽检后批准'
    ELSE '无需进入常规审核队列'
  END AS review_action,
  mappings.source_ref,
  mappings.updated_at
FROM pls_tag_type_dimension_mappings mappings
LEFT JOIN pls_semantic_dimensions dimensions
  ON dimensions.id = mappings.dimension_id
LEFT JOIN (
  SELECT
    platform,
    tag_type,
    COUNT(*) AS tag_count
  FROM platform_tag_catalog
  WHERE status = 'active'
  GROUP BY platform, tag_type
) catalog_stats
  ON catalog_stats.platform = mappings.platform
  AND catalog_stats.tag_type = mappings.tag_type
WHERE mappings.status = 'active'
  AND mappings.mapping_status IN ('unmapped', 'review_needed', 'proposed')
ORDER BY
  review_priority ASC,
  catalog_stats.tag_count DESC,
  mappings.platform ASC,
  mappings.tag_type ASC;
