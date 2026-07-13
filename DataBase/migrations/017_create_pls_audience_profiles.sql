PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS pls_audience_profiles (
  id TEXT PRIMARY KEY,
  workspace_id TEXT NOT NULL,
  profile_id TEXT NOT NULL,
  canonical_object_key TEXT NOT NULL,
  profile_stage TEXT NOT NULL DEFAULT 'channel_audience'
    CHECK (profile_stage IN ('channel_audience')),
  source TEXT NOT NULL,
  source_batch_id TEXT NOT NULL,
  data_version TEXT NOT NULL,
  generated_at TEXT NOT NULL,
  time_window TEXT NOT NULL,
  sample_size INTEGER
    CHECK (sample_size IS NULL OR sample_size >= 0),
  confidence REAL NOT NULL
    CHECK (confidence >= 0 AND confidence <= 1),
  tags_json TEXT NOT NULL DEFAULT '[]'
    CHECK (json_valid(tags_json)),
  unmapped_fields_json TEXT NOT NULL DEFAULT '[]'
    CHECK (json_valid(unmapped_fields_json)),
  quality_flags_json TEXT NOT NULL DEFAULT '[]'
    CHECK (json_valid(quality_flags_json)),
  raw_json TEXT NOT NULL
    CHECK (json_valid(raw_json)),
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'inactive', 'archived')),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  UNIQUE (workspace_id, profile_id, data_version),
  FOREIGN KEY (workspace_id, canonical_object_key, data_version)
    REFERENCES pls_channel_objects(workspace_id, canonical_object_key, data_version)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_pls_audience_profiles_object
ON pls_audience_profiles (workspace_id, canonical_object_key, status);

CREATE INDEX IF NOT EXISTS idx_pls_audience_profiles_batch
ON pls_audience_profiles (source_batch_id, data_version);

CREATE INDEX IF NOT EXISTS idx_pls_audience_profiles_confidence
ON pls_audience_profiles (confidence, status);

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
  ('field_pls_audience_profiles_id', 'pls_audience_profiles', 'id', '人群画像记录ID', 'AgentHarness 内部使用的人群画像快照唯一标识。', '用于唯一定位某个渠道对象的一次人群画像导入记录。', 'pap_ws_demo_audience_account_mock_001_v20260706', 'DataBase/migrations/017_create_pls_audience_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_profiles_workspace_id', 'pls_audience_profiles', 'workspace_id', '工作空间ID', '来源 PLS 工作空间标识。', '用于隔离不同业务空间或客户空间的人群画像。', 'ws_demo', 'DataBase/migrations/017_create_pls_audience_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_profiles_profile_id', 'pls_audience_profiles', 'profile_id', '来源画像ID', 'PLS 来源数据中的人群画像快照ID。', '用于与 PLS 原始导入包、报告或审计日志对齐。', 'audience_account_mock_001', 'DataBase/migrations/017_create_pls_audience_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_profiles_canonical_object_key', 'pls_audience_profiles', 'canonical_object_key', '标准对象键', '该人群画像所属的 PLS 渠道对象键。', '用于把人群画像挂回平台、商圈、店铺或账号。', 'account:mock_account_douyin_style', 'DataBase/migrations/017_create_pls_audience_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_profiles_profile_stage', 'pls_audience_profiles', 'profile_stage', '画像阶段', '说明这条画像属于哪个画像阶段。', '第一阶段固定为 channel_audience，表示渠道人群画像。', 'channel_audience', 'DataBase/migrations/017_create_pls_audience_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_profiles_source', 'pls_audience_profiles', 'source', '数据来源', '该画像记录来自哪个导入包、工具或报告。', '用于追踪画像数据入口。', 'mock_channel_object_library_sample', 'DataBase/migrations/017_create_pls_audience_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_profiles_source_batch_id', 'pls_audience_profiles', 'source_batch_id', '来源批次ID', '产生该画像记录的导入批次。', '用于按批次审计、撤回或重新导入。', 'batch_channel_object_library_mock_20260706', 'DataBase/migrations/017_create_pls_audience_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_profiles_data_version', 'pls_audience_profiles', 'data_version', '数据版本', '本次导入或生成的数据版本。', '用于确保画像连接的是同一版本的渠道对象。', 'v_channel_object_library_mock_20260706', 'DataBase/migrations/017_create_pls_audience_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_profiles_generated_at', 'pls_audience_profiles', 'generated_at', '生成时间', '来源画像数据生成或导出的时间。', '用于判断画像数据新鲜度。', '2026-07-06T00:00:00Z', 'DataBase/migrations/017_create_pls_audience_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_profiles_time_window', 'pls_audience_profiles', 'time_window', '时间窗口', '人群画像统计覆盖的闭合日期窗口。', '用于理解画像反映的是哪个时间段的人群结构。', '2026-06-01/2026-06-30', 'DataBase/migrations/017_create_pls_audience_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_profiles_sample_size', 'pls_audience_profiles', 'sample_size', '样本量', '生成该人群画像所依据的样本数量。', '用于判断画像可信度和统计稳定性。', '1000', 'DataBase/migrations/017_create_pls_audience_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_profiles_confidence', 'pls_audience_profiles', 'confidence', '置信度', '来源或映射流程给出的整体置信度，范围0到1。', '用于判断画像是否适合进入正式匹配或模型消费。', '0.82', 'DataBase/migrations/017_create_pls_audience_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_profiles_tags_json', 'pls_audience_profiles', 'tags_json', '画像标签JSON', '人群画像标签分数数组。', '用于记录该渠道对象的人群特征，例如年龄、内容偏好、风格、价格带等。', '[{"tagId":"demo.age_25_34","score":0.64}]', 'DataBase/migrations/017_create_pls_audience_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_profiles_unmapped_fields_json', 'pls_audience_profiles', 'unmapped_fields_json', '未映射字段JSON', '来源里暂时不能映射到标准画像标签的字段。', '用于保留长尾标签、异常字段或待补充词表内容。', '[{"sourceField":"mock_interest_long_tail"}]', 'DataBase/migrations/017_create_pls_audience_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_profiles_quality_flags_json', 'pls_audience_profiles', 'quality_flags_json', '质量标记JSON', '来源流程给出的画像质量标记。', '用于识别样例数据、缺失谱系、未审批标签等质量问题。', '["mock_sample"]', 'DataBase/migrations/017_create_pls_audience_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_profiles_raw_json', 'pls_audience_profiles', 'raw_json', '原始JSON', '保留导入时的原始人群画像记录。', '用于审计、回放、字段补充和排查。', '{"profileId":"audience_account_mock_001"}', 'DataBase/migrations/017_create_pls_audience_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_profiles_status', 'pls_audience_profiles', 'status', '记录状态', 'AgentHarness 内部画像记录状态。', '用于软删除或归档历史画像。', 'active', 'DataBase/migrations/017_create_pls_audience_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_profiles_created_at', 'pls_audience_profiles', 'created_at', '创建时间', '记录第一次写入 AgentHarness 的时间。', '用于数据生命周期追踪。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/017_create_pls_audience_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_profiles_updated_at', 'pls_audience_profiles', 'updated_at', '更新时间', '记录最近一次更新 AgentHarness 的时间。', '用于判断该画像记录是否被刷新。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/017_create_pls_audience_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z');
