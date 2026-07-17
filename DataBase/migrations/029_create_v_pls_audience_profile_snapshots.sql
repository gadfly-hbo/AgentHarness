CREATE VIEW IF NOT EXISTS v_pls_audience_profile_snapshots AS
SELECT
  profiles.workspace_id,
  profiles.profile_id,
  profiles.canonical_object_key,
  profiles.data_version,
  profiles.source_batch_id,
  profiles.generated_at,
  profiles.time_window,
  profiles.sample_size,
  profiles.confidence,
  profiles.quality_flags_json
FROM pls_audience_profiles profiles
JOIN pls_channel_objects objects
  ON objects.workspace_id = profiles.workspace_id
  AND objects.canonical_object_key = profiles.canonical_object_key
  AND objects.data_version = profiles.data_version
  AND objects.status = 'active'
WHERE profiles.status = 'active';

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
  ('field_v_pls_audience_profile_snapshots_workspace_id', 'v_pls_audience_profile_snapshots', 'workspace_id', '工作空间ID', '来源 PLS 工作空间标识。', '用于隔离不同业务空间或客户空间的人群画像快照。', 'ws_demo', 'DataBase/migrations/029_create_v_pls_audience_profile_snapshots.sql', 'active', '2026-07-17T00:00:00.000Z', '2026-07-17T00:00:00.000Z'),
  ('field_v_pls_audience_profile_snapshots_profile_id', 'v_pls_audience_profile_snapshots', 'profile_id', '来源画像ID', 'PLS 来源人群画像快照ID。', '用于定位每个来源画像快照，并与下游 PortraitSnapshot 身份对齐。', 'audience_account_mock_001', 'DataBase/migrations/029_create_v_pls_audience_profile_snapshots.sql', 'active', '2026-07-17T00:00:00.000Z', '2026-07-17T00:00:00.000Z'),
  ('field_v_pls_audience_profile_snapshots_canonical_object_key', 'v_pls_audience_profile_snapshots', 'canonical_object_key', '标准对象键', '该人群画像所属的 PLS 渠道对象键。', '作为画像所属对象的不透明引用，不在本 view 中展开对象展示字段。', 'account:mock_account_douyin_style', 'DataBase/migrations/029_create_v_pls_audience_profile_snapshots.sql', 'active', '2026-07-17T00:00:00.000Z', '2026-07-17T00:00:00.000Z'),
  ('field_v_pls_audience_profile_snapshots_data_version', 'v_pls_audience_profile_snapshots', 'data_version', '数据版本', '来源画像快照的数据版本。', '与 workspace_id、profile_id 共同构成本 view 的业务唯一键，并确保画像连接同版本渠道对象。', 'v_channel_object_library_mock_20260706', 'DataBase/migrations/029_create_v_pls_audience_profile_snapshots.sql', 'active', '2026-07-17T00:00:00.000Z', '2026-07-17T00:00:00.000Z'),
  ('field_v_pls_audience_profile_snapshots_source_batch_id', 'v_pls_audience_profile_snapshots', 'source_batch_id', '来源批次ID', '产生该画像记录的导入批次。', '用于按批次审计、撤回、重新导入或下游追溯。', 'batch_channel_object_library_mock_20260706', 'DataBase/migrations/029_create_v_pls_audience_profile_snapshots.sql', 'active', '2026-07-17T00:00:00.000Z', '2026-07-17T00:00:00.000Z'),
  ('field_v_pls_audience_profile_snapshots_generated_at', 'v_pls_audience_profile_snapshots', 'generated_at', '生成时间', '来源画像数据生成或导出的时间。', '用于判断画像快照新鲜度。', '2026-07-06T00:00:00Z', 'DataBase/migrations/029_create_v_pls_audience_profile_snapshots.sql', 'active', '2026-07-17T00:00:00.000Z', '2026-07-17T00:00:00.000Z'),
  ('field_v_pls_audience_profile_snapshots_time_window', 'v_pls_audience_profile_snapshots', 'time_window', '时间窗口', '人群画像统计覆盖的闭合日期窗口。', '用于理解画像快照反映的是哪个统计周期。', '2026-06-01/2026-06-30', 'DataBase/migrations/029_create_v_pls_audience_profile_snapshots.sql', 'active', '2026-07-17T00:00:00.000Z', '2026-07-17T00:00:00.000Z'),
  ('field_v_pls_audience_profile_snapshots_sample_size', 'v_pls_audience_profile_snapshots', 'sample_size', '样本量', '生成该人群画像所依据的样本数量，来源缺失时保持 NULL。', '用于判断画像可信度和统计稳定性，不得用 0 补缺失。', '1000', 'DataBase/migrations/029_create_v_pls_audience_profile_snapshots.sql', 'active', '2026-07-17T00:00:00.000Z', '2026-07-17T00:00:00.000Z'),
  ('field_v_pls_audience_profile_snapshots_confidence', 'v_pls_audience_profile_snapshots', 'confidence', '置信度', '来源或映射流程给出的整体置信度，范围0到1。', '用于判断画像快照是否适合进入正式匹配或模型消费，不派生默认置信度。', '0.82', 'DataBase/migrations/029_create_v_pls_audience_profile_snapshots.sql', 'active', '2026-07-17T00:00:00.000Z', '2026-07-17T00:00:00.000Z'),
  ('field_v_pls_audience_profile_snapshots_quality_flags_json', 'v_pls_audience_profile_snapshots', 'quality_flags_json', '质量标记JSON', '来源流程给出的画像质量标记 JSON 数组。', '用于识别样例数据、缺失谱系或其他质量问题，不派生 WorkPLS quality status。', '["mock_sample"]', 'DataBase/migrations/029_create_v_pls_audience_profile_snapshots.sql', 'active', '2026-07-17T00:00:00.000Z', '2026-07-17T00:00:00.000Z');
