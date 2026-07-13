.headers on
.mode column

SELECT
  'pls_dimensions_total' AS check_name,
  COUNT(*) AS actual,
  9 AS expected,
  CASE WHEN COUNT(*) = 9 THEN 'pass' ELSE 'fail' END AS result
FROM pls_semantic_dimensions;

SELECT
  'pls_dimensions_by_layer' AS check_name,
  layer_code,
  COUNT(*) AS actual,
  3 AS expected,
  CASE WHEN COUNT(*) = 3 THEN 'pass' ELSE 'fail' END AS result
FROM pls_semantic_dimensions
GROUP BY layer_code
ORDER BY layer_code;

SELECT
  'business_strategy_present' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pls_semantic_dimensions
WHERE trim(business_strategy) = '';

SELECT
  'source_refs_present' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pls_semantic_dimensions
WHERE source_ref NOT LIKE 'PLS业务语义及主数据标准-v0.1.xlsx%';

SELECT
  layer_code,
  layer_name,
  dimension_code,
  dimension_name,
  dimension_definition,
  business_strategy
FROM pls_semantic_dimensions
ORDER BY layer_code, dimension_code;
