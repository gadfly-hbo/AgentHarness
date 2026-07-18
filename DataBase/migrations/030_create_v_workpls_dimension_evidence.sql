DROP VIEW IF EXISTS v_workpls_dimension_evidence;

CREATE VIEW v_workpls_dimension_evidence AS
WITH snapshot_candidates AS (
  SELECT
    features.workspace_id,
    features.profile_id,
    features.canonical_object_key,
    features.metric_name,
    features.metric_unit,
    features.profile_time_window,
    features.source_batch_id,
    features.dimension_code,
    COUNT(*) AS snapshot_match_count,
    MAX(snapshots.data_version) AS data_version,
    MAX(snapshots.quality_flags_json) AS quality_flags_json
  FROM v_platform_profile_channel_dimension_features features
  JOIN v_pls_audience_profile_snapshots snapshots
    ON snapshots.workspace_id = features.workspace_id
    AND snapshots.profile_id = features.profile_id
    AND snapshots.canonical_object_key = features.canonical_object_key
    AND snapshots.source_batch_id = features.source_batch_id
    AND snapshots.time_window = features.profile_time_window
  GROUP BY
    features.workspace_id,
    features.profile_id,
    features.canonical_object_key,
    features.metric_name,
    features.metric_unit,
    features.profile_time_window,
    features.source_batch_id,
    features.dimension_code
),
source_rows AS (
  SELECT DISTINCT
    workspace_id,
    profile_id,
    canonical_object_key,
    metric_name,
    metric_unit,
    profile_time_window,
    source_batch_id,
    dimension_code,
    json_object(
      'sourceSystem', 'agentharness',
      'sourceRecordType', 'platform_profile_tag_metric',
      'sourceRecordId', metric_id,
      'sourceBatchId', source_batch_id,
      'sourceFile', source_file,
      'sourceRow', source_row,
      'platformTagCatalogId', platform_tag_catalog_id
    ) AS source_ref_json
  FROM v_platform_profile_tag_metric_semantics
  WHERE metric_id IS NOT NULL
    AND source_batch_id IS NOT NULL
    AND source_batch_id <> ''
    AND source_file IS NOT NULL
    AND source_file <> ''
    AND source_row IS NOT NULL
    AND platform_tag_catalog_id IS NOT NULL
    AND platform_tag_catalog_id <> ''
),
evidence_refs AS (
  SELECT
    workspace_id,
    profile_id,
    canonical_object_key,
    metric_name,
    metric_unit,
    profile_time_window,
    source_batch_id,
    dimension_code,
    json_group_array(json(source_ref_json)) AS source_evidence_refs_json
  FROM (
    SELECT *
    FROM source_rows
    ORDER BY source_ref_json
  ) ordered_source_rows
  GROUP BY
    workspace_id,
    profile_id,
    canonical_object_key,
    metric_name,
    metric_unit,
    profile_time_window,
    source_batch_id,
    dimension_code
)
SELECT
  features.workspace_id,
  features.profile_id AS snapshot_id,
  features.profile_id,
  features.canonical_object_key,
  snapshots.data_version,
  features.metric_name,
  'sum' AS metric_aggregation,
  features.dimension_code AS dimension_key,
  features.dimension_name AS dimension_label,
  features.dimension_metric_sum AS value,
  features.metric_unit AS unit,
  features.profile_time_window,
  features.source_batch_id,
  snapshots.quality_flags_json AS source_quality_flags_json,
  evidence_refs.source_evidence_refs_json,
  features.metric_row_count,
  features.tag_type_count,
  features.tag_value_count,
  features.avg_mapping_confidence,
  features.latest_metric_updated_at,
  features.latest_mapping_updated_at
FROM v_platform_profile_channel_dimension_features features
JOIN snapshot_candidates snapshots
  ON snapshots.workspace_id = features.workspace_id
  AND snapshots.profile_id = features.profile_id
  AND snapshots.canonical_object_key = features.canonical_object_key
  AND snapshots.metric_name = features.metric_name
  AND snapshots.metric_unit = features.metric_unit
  AND snapshots.profile_time_window = features.profile_time_window
  AND snapshots.source_batch_id = features.source_batch_id
  AND snapshots.dimension_code = features.dimension_code
  AND snapshots.snapshot_match_count = 1
JOIN evidence_refs
  ON evidence_refs.workspace_id = features.workspace_id
  AND evidence_refs.profile_id = features.profile_id
  AND evidence_refs.canonical_object_key = features.canonical_object_key
  AND evidence_refs.metric_name = features.metric_name
  AND evidence_refs.metric_unit = features.metric_unit
  AND evidence_refs.profile_time_window = features.profile_time_window
  AND evidence_refs.source_batch_id = features.source_batch_id
  AND evidence_refs.dimension_code = features.dimension_code
WHERE features.metric_name IS NOT NULL
  AND features.metric_name <> ''
  AND features.metric_unit IS NOT NULL
  AND features.metric_unit <> ''
  AND features.dimension_code IS NOT NULL
  AND features.dimension_code <> ''
  AND features.dimension_name IS NOT NULL
  AND features.dimension_name <> ''
  AND features.dimension_metric_sum IS NOT NULL
  AND features.dimension_metric_sum = features.dimension_metric_sum
  AND features.dimension_metric_sum > -1.0e308
  AND features.dimension_metric_sum < 1.0e308
  AND json_valid(snapshots.quality_flags_json)
  AND json_type(snapshots.quality_flags_json) = 'array'
  AND json_valid(evidence_refs.source_evidence_refs_json)
  AND json_type(evidence_refs.source_evidence_refs_json) = 'array'
  AND json_array_length(evidence_refs.source_evidence_refs_json) > 0;

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
VALUES
  ('field_v_workpls_dimension_evidence_workspace_id', 'v_workpls_dimension_evidence', 'workspace_id', '工作空间ID', '来源 PLS 工作空间标识。', '用于 WorkPLS 只读消费时强制 workspace 隔离。', 'ws_pls_real_001', 'DataBase/migrations/030_create_v_workpls_dimension_evidence.sql', 'active', '2026-07-18T00:00:00.000Z', '2026-07-18T00:00:00.000Z'),
  ('field_v_workpls_dimension_evidence_snapshot_id', 'v_workpls_dimension_evidence', 'snapshot_id', '画像快照ID', '绑定到来源画像快照的稳定 ID，当前等于 profile_id。', '用于 WorkPLS PortraitSnapshot 与 Dimension Evidence 对齐。', 'profile_douyin_101326115008_2026q2', 'DataBase/migrations/030_create_v_workpls_dimension_evidence.sql', 'active', '2026-07-18T00:00:00.000Z', '2026-07-18T00:00:00.000Z'),
  ('field_v_workpls_dimension_evidence_profile_id', 'v_workpls_dimension_evidence', 'profile_id', '来源画像ID', '平台画像指标所属的来源画像 ID。', '用于回溯 platform_profile_tag_metrics 与 snapshot metadata。', 'profile_douyin_101326115008_2026q2', 'DataBase/migrations/030_create_v_workpls_dimension_evidence.sql', 'active', '2026-07-18T00:00:00.000Z', '2026-07-18T00:00:00.000Z'),
  ('field_v_workpls_dimension_evidence_canonical_object_key', 'v_workpls_dimension_evidence', 'canonical_object_key', '标准对象键', '渠道对象的统一业务键。', '用于把 evidence 绑定到 WorkPLS Portrait Object。', 'account:douyin:101326115008', 'DataBase/migrations/030_create_v_workpls_dimension_evidence.sql', 'active', '2026-07-18T00:00:00.000Z', '2026-07-18T00:00:00.000Z'),
  ('field_v_workpls_dimension_evidence_data_version', 'v_workpls_dimension_evidence', 'data_version', '数据版本', '来自唯一绑定画像快照的数据版本。', '用于区分同一对象和画像的不同版本。', 'v_channel_object_library_20260718', 'DataBase/migrations/030_create_v_workpls_dimension_evidence.sql', 'active', '2026-07-18T00:00:00.000Z', '2026-07-18T00:00:00.000Z'),
  ('field_v_workpls_dimension_evidence_metric_name', 'v_workpls_dimension_evidence', 'metric_name', '指标名', '真实画像指标名称。', '用于区分 share、tgi、count、index、score 等不同度量。', 'share', 'DataBase/migrations/030_create_v_workpls_dimension_evidence.sql', 'active', '2026-07-18T00:00:00.000Z', '2026-07-18T00:00:00.000Z'),
  ('field_v_workpls_dimension_evidence_metric_aggregation', 'v_workpls_dimension_evidence', 'metric_aggregation', '指标聚合方式', '当前固定为 sum。', '声明 value 来自同 metric/unit 内的维度指标求和。', 'sum', 'DataBase/migrations/030_create_v_workpls_dimension_evidence.sql', 'active', '2026-07-18T00:00:00.000Z', '2026-07-18T00:00:00.000Z'),
  ('field_v_workpls_dimension_evidence_dimension_key', 'v_workpls_dimension_evidence', 'dimension_key', 'PLS维度键', 'PLS 标准维度代码。', '用于 WorkPLS 稳定识别标准维度。', 'P_DEMOGRAPHICS', 'DataBase/migrations/030_create_v_workpls_dimension_evidence.sql', 'active', '2026-07-18T00:00:00.000Z', '2026-07-18T00:00:00.000Z'),
  ('field_v_workpls_dimension_evidence_dimension_label', 'v_workpls_dimension_evidence', 'dimension_label', 'PLS维度名称', 'PLS 标准维度中文名。', '用于产品展示和解释。', '基础人口学', 'DataBase/migrations/030_create_v_workpls_dimension_evidence.sql', 'active', '2026-07-18T00:00:00.000Z', '2026-07-18T00:00:00.000Z'),
  ('field_v_workpls_dimension_evidence_value', 'v_workpls_dimension_evidence', 'value', '维度证据值', 'dimension_metric_sum 的正式输出值。', '只允许同 metric_name、unit 和 metric_aggregation 内比较。', '47.28', 'DataBase/migrations/030_create_v_workpls_dimension_evidence.sql', 'active', '2026-07-18T00:00:00.000Z', '2026-07-18T00:00:00.000Z'),
  ('field_v_workpls_dimension_evidence_unit', 'v_workpls_dimension_evidence', 'unit', '指标单位', '真实画像指标单位。', '防止跨单位或无单位分数被混合比较。', 'percent', 'DataBase/migrations/030_create_v_workpls_dimension_evidence.sql', 'active', '2026-07-18T00:00:00.000Z', '2026-07-18T00:00:00.000Z'),
  ('field_v_workpls_dimension_evidence_profile_time_window', 'v_workpls_dimension_evidence', 'profile_time_window', '画像时间窗口', '真实画像指标统计时间窗口。', '用于绑定 snapshot 并隔离跨周期 evidence。', '2026-07-01/2026-07-17', 'DataBase/migrations/030_create_v_workpls_dimension_evidence.sql', 'active', '2026-07-18T00:00:00.000Z', '2026-07-18T00:00:00.000Z'),
  ('field_v_workpls_dimension_evidence_source_batch_id', 'v_workpls_dimension_evidence', 'source_batch_id', '来源批次ID', '真实指标与画像快照来源批次。', '用于按批次审计和重跑。', 'platform_profile_v0.1_20260718', 'DataBase/migrations/030_create_v_workpls_dimension_evidence.sql', 'active', '2026-07-18T00:00:00.000Z', '2026-07-18T00:00:00.000Z'),
  ('field_v_workpls_dimension_evidence_source_quality_flags_json', 'v_workpls_dimension_evidence', 'source_quality_flags_json', '来源质量标记JSON', '唯一绑定 snapshot 的质量标记 JSON 数组。', 'WorkPLS 可原样读取并由自身质量策略派生状态，不回写 AgentHarness。', '["mock_sample"]', 'DataBase/migrations/030_create_v_workpls_dimension_evidence.sql', 'active', '2026-07-18T00:00:00.000Z', '2026-07-18T00:00:00.000Z'),
  ('field_v_workpls_dimension_evidence_source_evidence_refs_json', 'v_workpls_dimension_evidence', 'source_evidence_refs_json', '来源证据引用JSON', '支撑该维度证据的真实平台画像指标记录引用 JSON 数组。', '用于 WorkPLS 审计和解释，不暴露 raw_json、rowid 或 SQL/view 名。', '[{"sourceSystem":"agentharness","sourceRecordType":"platform_profile_tag_metric"}]', 'DataBase/migrations/030_create_v_workpls_dimension_evidence.sql', 'active', '2026-07-18T00:00:00.000Z', '2026-07-18T00:00:00.000Z'),
  ('field_v_workpls_dimension_evidence_metric_row_count', 'v_workpls_dimension_evidence', 'metric_row_count', '指标行数', '聚合到该维度的真实指标行数量。', '用于判断 evidence 覆盖密度。', '3', 'DataBase/migrations/030_create_v_workpls_dimension_evidence.sql', 'active', '2026-07-18T00:00:00.000Z', '2026-07-18T00:00:00.000Z'),
  ('field_v_workpls_dimension_evidence_tag_type_count', 'v_workpls_dimension_evidence', 'tag_type_count', '标签类型数', '聚合到该维度的标签类型数量。', '用于理解维度证据由多少类平台标签贡献。', '2', 'DataBase/migrations/030_create_v_workpls_dimension_evidence.sql', 'active', '2026-07-18T00:00:00.000Z', '2026-07-18T00:00:00.000Z'),
  ('field_v_workpls_dimension_evidence_tag_value_count', 'v_workpls_dimension_evidence', 'tag_value_count', '标签值数', '聚合到该维度的标签值数量。', '用于理解维度证据由多少个标签值贡献。', '5', 'DataBase/migrations/030_create_v_workpls_dimension_evidence.sql', 'active', '2026-07-18T00:00:00.000Z', '2026-07-18T00:00:00.000Z'),
  ('field_v_workpls_dimension_evidence_avg_mapping_confidence', 'v_workpls_dimension_evidence', 'avg_mapping_confidence', '平均映射置信度', '标签值到 PLS 维度映射的平均置信度。', '用于评估 evidence 语义映射可信度。', '0.92', 'DataBase/migrations/030_create_v_workpls_dimension_evidence.sql', 'active', '2026-07-18T00:00:00.000Z', '2026-07-18T00:00:00.000Z'),
  ('field_v_workpls_dimension_evidence_latest_metric_updated_at', 'v_workpls_dimension_evidence', 'latest_metric_updated_at', '最新指标更新时间', '参与聚合的真实指标最近更新时间。', '用于判断事实指标是否刷新。', '2026-07-18T00:00:00.000Z', 'DataBase/migrations/030_create_v_workpls_dimension_evidence.sql', 'active', '2026-07-18T00:00:00.000Z', '2026-07-18T00:00:00.000Z'),
  ('field_v_workpls_dimension_evidence_latest_mapping_updated_at', 'v_workpls_dimension_evidence', 'latest_mapping_updated_at', '最新映射更新时间', '参与聚合的标签值语义映射最近更新时间。', '用于判断语义映射是否刷新。', '2026-07-18T00:00:00.000Z', 'DataBase/migrations/030_create_v_workpls_dimension_evidence.sql', 'active', '2026-07-18T00:00:00.000Z', '2026-07-18T00:00:00.000Z');
