.headers on
.mode column

SELECT
  'pls_platform_mappings_total' AS check_name,
  COUNT(*) AS actual,
  27 AS expected,
  CASE WHEN COUNT(*) = 27 THEN 'pass' ELSE 'fail' END AS result
FROM pls_platform_tag_mappings;

SELECT
  'pls_platform_mappings_by_platform' AS check_name,
  platform,
  COUNT(*) AS actual,
  9 AS expected,
  CASE WHEN COUNT(*) = 9 THEN 'pass' ELSE 'fail' END AS result
FROM pls_platform_tag_mappings
GROUP BY platform
ORDER BY platform;

SELECT
  'pls_platform_mappings_by_dimension' AS check_name,
  dimension_id,
  COUNT(*) AS actual,
  3 AS expected,
  CASE WHEN COUNT(*) = 3 THEN 'pass' ELSE 'fail' END AS result
FROM pls_platform_tag_mappings
GROUP BY dimension_id
ORDER BY dimension_id;

SELECT
  'orphan_dimension_refs' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pls_platform_tag_mappings mappings
LEFT JOIN pls_semantic_dimensions dimensions
  ON dimensions.id = mappings.dimension_id
WHERE dimensions.id IS NULL;

SELECT
  data_availability,
  COUNT(*) AS count
FROM pls_platform_tag_mappings
GROUP BY data_availability
ORDER BY data_availability;

SELECT
  mappings.platform,
  dimensions.layer_code,
  dimensions.dimension_code,
  mappings.raw_tag_fields,
  mappings.raw_enum_examples,
  mappings.data_availability,
  mappings.mapping_strategy
FROM pls_platform_tag_mappings mappings
JOIN pls_semantic_dimensions dimensions
  ON dimensions.id = mappings.dimension_id
ORDER BY dimensions.layer_code, dimensions.dimension_code, mappings.platform;
