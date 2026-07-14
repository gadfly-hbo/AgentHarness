DROP VIEW IF EXISTS v_platform_profile_channel_feature_matrix;
DROP VIEW IF EXISTS v_platform_profile_channel_dimension_features;

CREATE VIEW v_platform_profile_channel_dimension_features AS
SELECT
  workspace_id,
  profile_id,
  canonical_object_key,
  channel_object_type,
  channel_object_name,
  platform,
  metric_name,
  metric_unit,
  profile_time_window,
  source_batch_id,
  layer_code,
  layer_name,
  dimension_code,
  dimension_name,
  dimension_definition,
  business_strategy,
  COUNT(*) AS metric_row_count,
  COUNT(DISTINCT tag_type) AS tag_type_count,
  COUNT(DISTINCT leaf_label) AS tag_value_count,
  ROUND(SUM(metric_value), 6) AS dimension_metric_sum,
  ROUND(AVG(metric_value), 6) AS dimension_metric_avg,
  ROUND(MAX(metric_value), 6) AS dimension_metric_max,
  ROUND(AVG(mapping_confidence), 6) AS avg_mapping_confidence,
  GROUP_CONCAT(DISTINCT tag_type) AS tag_types,
  GROUP_CONCAT(DISTINCT leaf_label) AS leaf_labels,
  MIN(source_file) AS first_source_file,
  MAX(metric_updated_at) AS latest_metric_updated_at,
  MAX(mapping_updated_at) AS latest_mapping_updated_at
FROM v_platform_profile_tag_metric_semantics
GROUP BY
  workspace_id,
  profile_id,
  canonical_object_key,
  channel_object_type,
  channel_object_name,
  platform,
  metric_name,
  metric_unit,
  profile_time_window,
  source_batch_id,
  layer_code,
  layer_name,
  dimension_code,
  dimension_name,
  dimension_definition,
  business_strategy;

INSERT OR IGNORE INTO database_field_comments (
  id,
  table_name,
  field_name,
  zh_name,
  zh_description,
  business_meaning,
  example_value,
  source_ref,
  status,
  created_at,
  updated_at
)
SELECT
  'field_v_platform_profile_channel_dimension_features_' || name,
  'v_platform_profile_channel_dimension_features',
  name,
  CASE name
    WHEN 'dimension_metric_sum' THEN '维度指标总和'
    WHEN 'dimension_metric_avg' THEN '维度指标均值'
    WHEN 'dimension_metric_max' THEN '维度指标最大值'
    WHEN 'metric_row_count' THEN '指标行数'
    WHEN 'tag_type_count' THEN '标签类型数'
    WHEN 'tag_value_count' THEN '标签值数'
    ELSE name
  END,
  '真实画像指标按渠道对象、指标名和PLS维度聚合后的字段。',
  '用于在不混合占比、TGI、人数等不同指标的前提下读取渠道对象维度特征。',
  name,
  'DataBase/migrations/026_create_v_platform_profile_channel_dimension_features.sql',
  'active',
  '2026-07-14T00:00:00.000Z',
  '2026-07-14T00:00:00.000Z'
FROM pragma_table_info('v_platform_profile_channel_dimension_features');
