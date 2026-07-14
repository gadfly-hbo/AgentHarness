.headers on
.mode column

SELECT
  'tag_type_mappings_total' AS check_name,
  COUNT(*) AS actual,
  474 AS expected,
  CASE WHEN COUNT(*) = 474 THEN 'pass' ELSE 'fail' END AS result
FROM pls_tag_type_dimension_mappings
WHERE platform IN ('天猫', '抖音', '京东');

SELECT
  'tag_type_mappings_by_platform' AS check_name,
  platform,
  COUNT(*) AS actual,
  CASE platform
    WHEN '天猫' THEN 366
    WHEN '抖音' THEN 70
    WHEN '京东' THEN 38
  END AS expected,
  CASE
    WHEN platform = '天猫' AND COUNT(*) = 366 THEN 'pass'
    WHEN platform = '抖音' AND COUNT(*) = 70 THEN 'pass'
    WHEN platform = '京东' AND COUNT(*) = 38 THEN 'pass'
    ELSE 'fail'
  END AS result
FROM pls_tag_type_dimension_mappings
WHERE platform IN ('天猫', '抖音', '京东')
GROUP BY platform
ORDER BY platform;

SELECT
  'orphan_dimension_refs' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pls_tag_type_dimension_mappings mappings
LEFT JOIN pls_semantic_dimensions dimensions
  ON dimensions.id = mappings.dimension_id
WHERE mappings.dimension_id IS NOT NULL
  AND dimensions.id IS NULL;

SELECT
  mapping_status,
  COUNT(*) AS count
FROM pls_tag_type_dimension_mappings
GROUP BY mapping_status
ORDER BY mapping_status;

SELECT
  dimensions.layer_code,
  dimensions.dimension_code,
  COUNT(*) AS mapping_count
FROM pls_tag_type_dimension_mappings mappings
JOIN pls_semantic_dimensions dimensions
  ON dimensions.id = mappings.dimension_id
GROUP BY dimensions.layer_code, dimensions.dimension_code
ORDER BY dimensions.layer_code, dimensions.dimension_code;

SELECT
  platform,
  tag_type,
  mapping_status,
  confidence,
  dimension_id,
  rationale
FROM pls_tag_type_dimension_mappings
WHERE mapping_status IN ('unmapped', 'review_needed')
ORDER BY platform, mapping_status, tag_type
LIMIT 80;
