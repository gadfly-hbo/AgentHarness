DROP VIEW IF EXISTS v_platform_profile_channel_feature_matrix;

CREATE VIEW v_platform_profile_channel_feature_matrix AS
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
  COUNT(DISTINCT dimension_code) AS active_dimension_count,
  SUM(metric_row_count) AS total_metric_row_count,
  SUM(tag_type_count) AS total_tag_type_count,
  SUM(tag_value_count) AS total_tag_value_count,
  ROUND(SUM(dimension_metric_sum), 6) AS total_metric_sum,
  ROUND(AVG(avg_mapping_confidence), 6) AS avg_mapping_confidence,
  MAX(latest_metric_updated_at) AS latest_metric_updated_at,
  MAX(latest_mapping_updated_at) AS latest_mapping_updated_at,
  ROUND(SUM(CASE WHEN dimension_code = 'P_DEMOGRAPHICS' THEN dimension_metric_sum ELSE 0 END), 6) AS p_demographics_metric_sum,
  ROUND(SUM(CASE WHEN dimension_code = 'P_PURCHASING_POWER' THEN dimension_metric_sum ELSE 0 END), 6) AS p_purchasing_power_metric_sum,
  ROUND(SUM(CASE WHEN dimension_code = 'P_IDENTITY_CLUSTER' THEN dimension_metric_sum ELSE 0 END), 6) AS p_identity_cluster_metric_sum,
  ROUND(SUM(CASE WHEN dimension_code = 'L_CONTENT_VISUAL_MIND' THEN dimension_metric_sum ELSE 0 END), 6) AS l_content_visual_mind_metric_sum,
  ROUND(SUM(CASE WHEN dimension_code = 'L_INNOVATION_BRAND_MIND' THEN dimension_metric_sum ELSE 0 END), 6) AS l_innovation_brand_mind_metric_sum,
  ROUND(SUM(CASE WHEN dimension_code = 'L_LIFESTYLE' THEN dimension_metric_sum ELSE 0 END), 6) AS l_lifestyle_metric_sum,
  ROUND(SUM(CASE WHEN dimension_code = 'S_PRICE_INCENTIVE_RESPONSE' THEN dimension_metric_sum ELSE 0 END), 6) AS s_price_incentive_response_metric_sum,
  ROUND(SUM(CASE WHEN dimension_code = 'S_CONVERSION_FRICTION' THEN dimension_metric_sum ELSE 0 END), 6) AS s_conversion_friction_metric_sum,
  ROUND(SUM(CASE WHEN dimension_code = 'S_ENVIRONMENT' THEN dimension_metric_sum ELSE 0 END), 6) AS s_environment_metric_sum
FROM v_platform_profile_channel_dimension_features
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
  source_batch_id;

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
  'field_v_platform_profile_channel_feature_matrix_' || name,
  'v_platform_profile_channel_feature_matrix',
  name,
  CASE
    WHEN name LIKE '%metric_sum' THEN replace(name, '_', ' ')
    WHEN name = 'active_dimension_count' THEN '命中维度数'
    ELSE name
  END,
  '真实画像指标按渠道对象和指标名展开后的PLS九维宽表字段。',
  '用于模型、报表和画像卡片按对象读取真实画像九维特征。',
  name,
  'DataBase/migrations/027_create_v_platform_profile_channel_feature_matrix.sql',
  'active',
  '2026-07-14T00:00:00.000Z',
  '2026-07-14T00:00:00.000Z'
FROM pragma_table_info('v_platform_profile_channel_feature_matrix');
