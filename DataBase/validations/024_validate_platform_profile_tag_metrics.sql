.headers on
.mode column

SELECT
  'platform_profile_tag_metrics_total' AS check_name,
  COUNT(*) AS actual,
  '>= 0' AS expected,
  CASE WHEN COUNT(*) >= 0 THEN 'pass' ELSE 'fail' END AS result
FROM platform_profile_tag_metrics;

SELECT
  'platform_profile_tag_metrics_missing_comments' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pragma_table_info('platform_profile_tag_metrics') fields
LEFT JOIN database_field_comments comments
  ON comments.table_name = 'platform_profile_tag_metrics'
  AND comments.field_name = fields.name
  AND comments.status = 'active'
WHERE comments.id IS NULL;

SELECT
  'orphan_catalog_refs' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM platform_profile_tag_metrics metrics
LEFT JOIN platform_tag_catalog catalog
  ON catalog.id = metrics.platform_tag_catalog_id
WHERE catalog.id IS NULL;

SELECT
  'invalid_raw_json' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM platform_profile_tag_metrics
WHERE NOT json_valid(raw_json);
