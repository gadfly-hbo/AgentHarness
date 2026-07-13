.headers on
.mode column

SELECT
  'v_pls_channel_feature_matrix_total' AS check_name,
  COUNT(*) AS actual,
  3 AS expected,
  CASE WHEN COUNT(*) = 3 THEN 'pass' ELSE 'fail' END AS result
FROM v_pls_channel_feature_matrix;

SELECT
  'feature_score_matches_dimensions' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM (
  SELECT
    canonical_object_key,
    ROUND(SUM(dimension_score), 6) AS dimension_total
  FROM v_pls_channel_dimension_features
  GROUP BY canonical_object_key
) dimensions
JOIN v_pls_channel_feature_matrix matrix
  ON matrix.canonical_object_key = dimensions.canonical_object_key
WHERE matrix.total_feature_score != dimensions.dimension_total;

SELECT
  canonical_object_key,
  display_name,
  active_dimension_count,
  total_tag_count,
  total_feature_score,
  p_demographics_score,
  p_purchasing_power_score,
  l_content_visual_mind_score,
  l_lifestyle_score,
  s_environment_score
FROM v_pls_channel_feature_matrix
ORDER BY canonical_object_key;
