.headers on
.mode column

SELECT
  'dimension_features_grouping' AS check_name,
  COUNT(*) AS actual
FROM v_platform_profile_channel_dimension_features;

SELECT
  'dimension_metric_sum_matches_semantics' AS check_name,
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
    dimension_code,
    ROUND(SUM(metric_value), 6) AS semantic_sum
  FROM v_platform_profile_tag_metric_semantics
  GROUP BY
    workspace_id,
    profile_id,
    canonical_object_key,
    metric_name,
    metric_unit,
    profile_time_window,
    source_batch_id,
    dimension_code
) semantic_groups
JOIN v_platform_profile_channel_dimension_features features
  ON features.workspace_id = semantic_groups.workspace_id
  AND features.profile_id = semantic_groups.profile_id
  AND features.canonical_object_key = semantic_groups.canonical_object_key
  AND features.metric_name = semantic_groups.metric_name
  AND features.metric_unit = semantic_groups.metric_unit
  AND features.profile_time_window = semantic_groups.profile_time_window
  AND features.source_batch_id = semantic_groups.source_batch_id
  AND features.dimension_code = semantic_groups.dimension_code
WHERE features.dimension_metric_sum != semantic_groups.semantic_sum;

SELECT
  'missing_comments' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pragma_table_info('v_platform_profile_channel_dimension_features') fields
LEFT JOIN database_field_comments comments
  ON comments.table_name = 'v_platform_profile_channel_dimension_features'
  AND comments.field_name = fields.name
  AND comments.status = 'active'
WHERE comments.id IS NULL;
