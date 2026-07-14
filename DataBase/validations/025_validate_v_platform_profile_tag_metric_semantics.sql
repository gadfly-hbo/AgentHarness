.headers on
.mode column

SELECT
  'semantic_view_total' AS check_name,
  COUNT(*) AS actual,
  (
    SELECT COUNT(*)
    FROM platform_profile_tag_metrics
    WHERE status = 'active'
  ) AS expected,
  CASE
    WHEN COUNT(*) = (
      SELECT COUNT(*)
      FROM platform_profile_tag_metrics
      WHERE status = 'active'
    ) THEN 'pass'
    ELSE 'fail'
  END AS result
FROM v_platform_profile_tag_metric_semantics;

SELECT
  'missing_dimension' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM v_platform_profile_tag_metric_semantics
WHERE dimension_code IS NULL OR dimension_code = '';

SELECT
  'missing_comments' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pragma_table_info('v_platform_profile_tag_metric_semantics') fields
LEFT JOIN database_field_comments comments
  ON comments.table_name = 'v_platform_profile_tag_metric_semantics'
  AND comments.field_name = fields.name
  AND comments.status = 'active'
WHERE comments.id IS NULL;
