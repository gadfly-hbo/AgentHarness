.headers on
.mode column

SELECT
  'field_comments_total' AS check_name,
  COUNT(*) AS actual,
  69 AS expected,
  CASE WHEN COUNT(*) = 69 THEN 'pass' ELSE 'fail' END AS result
FROM database_field_comments;

SELECT
  'field_comments_self_comments' AS check_name,
  COUNT(*) AS actual,
  11 AS expected,
  CASE WHEN COUNT(*) = 11 THEN 'pass' ELSE 'fail' END AS result
FROM database_field_comments
WHERE table_name = 'database_field_comments';

SELECT
  'entities_field_comments' AS check_name,
  COUNT(*) AS actual,
  9 AS expected,
  CASE WHEN COUNT(*) = 9 THEN 'pass' ELSE 'fail' END AS result
FROM database_field_comments
WHERE table_name = 'entities';

SELECT
  'pls_dimensions_field_comments' AS check_name,
  COUNT(*) AS actual,
  12 AS expected,
  CASE WHEN COUNT(*) = 12 THEN 'pass' ELSE 'fail' END AS result
FROM database_field_comments
WHERE table_name = 'pls_semantic_dimensions';

SELECT
  'pls_platform_mappings_field_comments' AS check_name,
  COUNT(*) AS actual,
  11 AS expected,
  CASE WHEN COUNT(*) = 11 THEN 'pass' ELSE 'fail' END AS result
FROM database_field_comments
WHERE table_name = 'pls_platform_tag_mappings';

SELECT
  'platform_tag_catalog_field_comments' AS check_name,
  COUNT(*) AS actual,
  14 AS expected,
  CASE WHEN COUNT(*) = 14 THEN 'pass' ELSE 'fail' END AS result
FROM database_field_comments
WHERE table_name = 'platform_tag_catalog';

SELECT
  'pls_tag_type_mappings_field_comments' AS check_name,
  COUNT(*) AS actual,
  12 AS expected,
  CASE WHEN COUNT(*) = 12 THEN 'pass' ELSE 'fail' END AS result
FROM database_field_comments
WHERE table_name = 'pls_tag_type_dimension_mappings';

SELECT
  'missing_active_comments_for_existing_fields' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM (
  SELECT 'database_field_comments' AS table_name, name AS field_name
  FROM pragma_table_info('database_field_comments')
  UNION ALL
  SELECT 'entities' AS table_name, name AS field_name
  FROM pragma_table_info('entities')
  UNION ALL
  SELECT 'pls_semantic_dimensions' AS table_name, name AS field_name
  FROM pragma_table_info('pls_semantic_dimensions')
  UNION ALL
  SELECT 'pls_platform_tag_mappings' AS table_name, name AS field_name
  FROM pragma_table_info('pls_platform_tag_mappings')
  UNION ALL
  SELECT 'platform_tag_catalog' AS table_name, name AS field_name
  FROM pragma_table_info('platform_tag_catalog')
  UNION ALL
  SELECT 'pls_tag_type_dimension_mappings' AS table_name, name AS field_name
  FROM pragma_table_info('pls_tag_type_dimension_mappings')
) fields
LEFT JOIN database_field_comments comments
  ON comments.table_name = fields.table_name
  AND comments.field_name = fields.field_name
  AND comments.status = 'active'
WHERE comments.id IS NULL;

SELECT
  table_name,
  field_name,
  zh_name,
  business_meaning,
  example_value
FROM database_field_comments
ORDER BY table_name, field_name;
