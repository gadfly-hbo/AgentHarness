.headers on
.mode column

SELECT
  'tag_value_mappings_total' AS check_name,
  COUNT(*) AS actual,
  (
    SELECT COUNT(*)
    FROM platform_tag_catalog
    WHERE platform IN ('天猫', '抖音')
      AND status = 'active'
  ) AS expected,
  CASE
    WHEN COUNT(*) = (
      SELECT COUNT(*)
      FROM platform_tag_catalog
      WHERE platform IN ('天猫', '抖音')
        AND status = 'active'
    ) THEN 'pass'
    ELSE 'fail'
  END AS result
FROM pls_tag_value_dimension_mappings
WHERE platform IN ('天猫', '抖音');

SELECT
  'tag_value_mappings_by_platform' AS check_name,
  mappings.platform,
  COUNT(*) AS actual,
  (
    SELECT COUNT(*)
    FROM platform_tag_catalog catalog
    WHERE catalog.platform = mappings.platform
      AND catalog.status = 'active'
  ) AS expected,
  CASE
    WHEN COUNT(*) = (
      SELECT COUNT(*)
      FROM platform_tag_catalog catalog
      WHERE catalog.platform = mappings.platform
        AND catalog.status = 'active'
    ) THEN 'pass'
    ELSE 'fail'
  END AS result
FROM pls_tag_value_dimension_mappings mappings
WHERE mappings.platform IN ('天猫', '抖音')
GROUP BY mappings.platform
ORDER BY mappings.platform;

SELECT
  'orphan_catalog_refs' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pls_tag_value_dimension_mappings mappings
LEFT JOIN platform_tag_catalog catalog
  ON catalog.id = mappings.platform_tag_catalog_id
WHERE catalog.id IS NULL;

SELECT
  'orphan_dimension_refs' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pls_tag_value_dimension_mappings mappings
LEFT JOIN pls_semantic_dimensions dimensions
  ON dimensions.id = mappings.dimension_id
WHERE dimensions.id IS NULL;

SELECT
  'orphan_type_mapping_refs' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pls_tag_value_dimension_mappings mappings
LEFT JOIN pls_tag_type_dimension_mappings type_mappings
  ON type_mappings.id = mappings.inherited_tag_type_mapping_id
WHERE type_mappings.id IS NULL;

SELECT
  mapping_status,
  COUNT(*) AS count
FROM pls_tag_value_dimension_mappings
GROUP BY mapping_status
ORDER BY mapping_status;

SELECT
  dimensions.layer_code,
  dimensions.dimension_code,
  COUNT(*) AS mapping_count
FROM pls_tag_value_dimension_mappings mappings
JOIN pls_semantic_dimensions dimensions
  ON dimensions.id = mappings.dimension_id
GROUP BY dimensions.layer_code, dimensions.dimension_code
ORDER BY dimensions.layer_code, dimensions.dimension_code;
