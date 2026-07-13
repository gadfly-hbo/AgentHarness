.headers on
.mode column

SELECT
  'semantic_view_total' AS check_name,
  COUNT(*) AS actual,
  (
    SELECT COUNT(*)
    FROM pls_tag_value_dimension_mappings
    WHERE status = 'active'
  ) AS expected,
  CASE
    WHEN COUNT(*) = (
      SELECT COUNT(*)
      FROM pls_tag_value_dimension_mappings
      WHERE status = 'active'
    ) THEN 'pass'
    ELSE 'fail'
  END AS result
FROM v_pls_platform_tag_value_semantics;

SELECT
  'semantic_view_by_platform' AS check_name,
  platform,
  COUNT(*) AS actual
FROM v_pls_platform_tag_value_semantics
GROUP BY platform
ORDER BY platform;

SELECT
  'semantic_view_missing_dimension_name' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM v_pls_platform_tag_value_semantics
WHERE dimension_name IS NULL OR dimension_name = '';

SELECT
  layer_code,
  dimension_name,
  dimension_code,
  COUNT(*) AS tag_value_count
FROM v_pls_platform_tag_value_semantics
GROUP BY layer_code, dimension_name, dimension_code
ORDER BY layer_code, dimension_code;
