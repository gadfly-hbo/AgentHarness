.headers on
.mode column

SELECT
  'v_pls_channel_dimension_features_total' AS check_name,
  COUNT(*) AS actual,
  5 AS expected,
  CASE WHEN COUNT(*) = 5 THEN 'pass' ELSE 'fail' END AS result
FROM v_pls_channel_dimension_features;

SELECT
  'dimension_score_matches_tag_score' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM (
  SELECT
    canonical_object_key,
    dimension_code,
    ROUND(SUM(tag_score), 6) AS raw_sum
  FROM v_pls_audience_tag_semantics
  GROUP BY canonical_object_key, dimension_code
) raw
JOIN v_pls_channel_dimension_features features
  ON features.canonical_object_key = raw.canonical_object_key
  AND features.dimension_code = raw.dimension_code
WHERE features.dimension_score != raw.raw_sum;

SELECT
  'channel_feature_distribution' AS check_name,
  canonical_object_key,
  COUNT(*) AS dimension_count,
  ROUND(SUM(dimension_score), 6) AS total_dimension_score
FROM v_pls_channel_dimension_features
GROUP BY canonical_object_key
ORDER BY canonical_object_key;

SELECT
  canonical_object_key,
  display_name,
  layer_code,
  dimension_name,
  tag_count,
  dimension_score,
  avg_tag_confidence,
  avg_mapping_confidence,
  tag_labels_zh
FROM v_pls_channel_dimension_features
ORDER BY canonical_object_key, layer_code, dimension_code;
