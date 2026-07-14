.headers on
.mode column

SELECT
  'feature_matrix_total' AS check_name,
  COUNT(*) AS actual
FROM v_platform_profile_channel_feature_matrix;

SELECT
  'matrix_total_matches_dimensions' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM (
  SELECT
    workspace_id,
    profile_id,
    canonical_object_key,
    metric_name,
    metric_unit,
    profile_time_window,
    source_batch_id,
    ROUND(SUM(dimension_metric_sum), 6) AS dimension_total
  FROM v_platform_profile_channel_dimension_features
  GROUP BY
    workspace_id,
    profile_id,
    canonical_object_key,
    metric_name,
    metric_unit,
    profile_time_window,
    source_batch_id
) dimensions
JOIN v_platform_profile_channel_feature_matrix matrix
  ON matrix.workspace_id = dimensions.workspace_id
  AND matrix.profile_id = dimensions.profile_id
  AND matrix.canonical_object_key = dimensions.canonical_object_key
  AND matrix.metric_name = dimensions.metric_name
  AND matrix.metric_unit = dimensions.metric_unit
  AND matrix.profile_time_window = dimensions.profile_time_window
  AND matrix.source_batch_id = dimensions.source_batch_id
WHERE matrix.total_metric_sum != dimensions.dimension_total;

SELECT
  'missing_comments' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pragma_table_info('v_platform_profile_channel_feature_matrix') fields
LEFT JOIN database_field_comments comments
  ON comments.table_name = 'v_platform_profile_channel_feature_matrix'
  AND comments.field_name = fields.name
  AND comments.status = 'active'
WHERE comments.id IS NULL;
