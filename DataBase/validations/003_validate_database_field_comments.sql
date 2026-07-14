.headers on
.mode column

SELECT
  'field_comments_total' AS check_name,
  COUNT(*) AS actual,
  (
    SELECT COUNT(*)
    FROM sqlite_schema objects
    JOIN pragma_table_info(objects.name) fields
    WHERE objects.type IN ('table', 'view')
      AND objects.name NOT LIKE 'sqlite_%'
  ) AS expected_minimum,
  CASE
    WHEN COUNT(*) >= (
      SELECT COUNT(*)
      FROM sqlite_schema objects
      JOIN pragma_table_info(objects.name) fields
      WHERE objects.type IN ('table', 'view')
        AND objects.name NOT LIKE 'sqlite_%'
    ) THEN 'pass'
    ELSE 'fail'
  END AS result
FROM database_field_comments
WHERE status = 'active';

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
  SELECT objects.name AS table_name, fields.name AS field_name
  FROM sqlite_schema objects
  JOIN pragma_table_info(objects.name) fields
  WHERE objects.type IN ('table', 'view')
    AND objects.name NOT LIKE 'sqlite_%'
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
