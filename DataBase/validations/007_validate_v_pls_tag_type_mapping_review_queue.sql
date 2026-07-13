.headers on
.mode column

SELECT
  'review_queue_total' AS check_name,
  COUNT(*) AS actual,
  (
    SELECT COUNT(*)
    FROM pls_tag_type_dimension_mappings
    WHERE status = 'active'
      AND mapping_status IN ('unmapped', 'review_needed', 'proposed')
  ) AS expected,
  CASE
    WHEN COUNT(*) = (
      SELECT COUNT(*)
      FROM pls_tag_type_dimension_mappings
      WHERE status = 'active'
        AND mapping_status IN ('unmapped', 'review_needed', 'proposed')
    )
    THEN 'pass'
    ELSE 'fail'
  END AS result
FROM v_pls_tag_type_mapping_review_queue;

SELECT
  'review_queue_by_status' AS check_name,
  mapping_status,
  COUNT(*) AS count
FROM v_pls_tag_type_mapping_review_queue
GROUP BY mapping_status
ORDER BY mapping_status;

SELECT
  'review_queue_missing_tag_count' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM v_pls_tag_type_mapping_review_queue
WHERE tag_count IS NULL;

SELECT
  platform,
  tag_type,
  tag_count,
  mapping_status,
  confidence,
  dimension_code,
  review_priority,
  review_action
FROM v_pls_tag_type_mapping_review_queue
ORDER BY review_priority, tag_count DESC, platform, tag_type
LIMIT 40;
