PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS pls_channel_object_bindings (
  id TEXT PRIMARY KEY,
  workspace_id TEXT NOT NULL,
  binding_id TEXT NOT NULL,
  binding_type TEXT NOT NULL
    CHECK (binding_type IN (
      'parent_child',
      'event_to_channel_entity',
      'scenario_to_channel_entity'
    )),
  from_canonical_object_key TEXT NOT NULL,
  to_canonical_object_key TEXT NOT NULL,
  source_batch_id TEXT NOT NULL,
  data_version TEXT NOT NULL,
  generated_at TEXT NOT NULL,
  quality_flags_json TEXT NOT NULL DEFAULT '[]'
    CHECK (json_valid(quality_flags_json)),
  raw_json TEXT NOT NULL
    CHECK (json_valid(raw_json)),
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'inactive', 'archived')),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  UNIQUE (workspace_id, binding_id, data_version),
  FOREIGN KEY (workspace_id, from_canonical_object_key, data_version)
    REFERENCES pls_channel_objects(workspace_id, canonical_object_key, data_version)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  FOREIGN KEY (workspace_id, to_canonical_object_key, data_version)
    REFERENCES pls_channel_objects(workspace_id, canonical_object_key, data_version)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_pls_channel_object_bindings_from
ON pls_channel_object_bindings (workspace_id, from_canonical_object_key, status);

CREATE INDEX IF NOT EXISTS idx_pls_channel_object_bindings_to
ON pls_channel_object_bindings (workspace_id, to_canonical_object_key, status);

CREATE INDEX IF NOT EXISTS idx_pls_channel_object_bindings_type
ON pls_channel_object_bindings (binding_type, status);

CREATE INDEX IF NOT EXISTS idx_pls_channel_object_bindings_batch
ON pls_channel_object_bindings (source_batch_id, data_version);

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
  ('field_pls_channel_object_bindings_id', 'pls_channel_object_bindings', 'id', '渠道对象关系记录ID', 'AgentHarness 内部使用的渠道对象关系唯一标识。', '用于唯一定位一条渠道对象关系记录。', 'pcob_ws_demo_bind_account_platform_mock_001_v20260706', 'DataBase/migrations/016_create_pls_channel_object_bindings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_object_bindings_workspace_id', 'pls_channel_object_bindings', 'workspace_id', '工作空间ID', '来源 PLS 工作空间标识。', '用于隔离不同业务空间或客户空间的渠道对象关系。', 'ws_demo', 'DataBase/migrations/016_create_pls_channel_object_bindings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_object_bindings_binding_id', 'pls_channel_object_bindings', 'binding_id', '来源关系ID', 'PLS 来源数据中的关系标识。', '用于与 PLS 原始导入包或审计日志对齐。', 'bind_account_platform_mock_001', 'DataBase/migrations/016_create_pls_channel_object_bindings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_object_bindings_binding_type', 'pls_channel_object_bindings', 'binding_type', '关系类型', '说明两个渠道对象之间是什么业务关系。', '用于区分父子层级、活动关联渠道对象、场景关联渠道对象。', 'parent_child', 'DataBase/migrations/016_create_pls_channel_object_bindings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_object_bindings_from_canonical_object_key', 'pls_channel_object_bindings', 'from_canonical_object_key', '起点标准对象键', '关系起点的 PLS 标准对象键。', '用于表达关系方向，例如平台指向账号、商圈指向店铺。', 'platform:mock_platform_douyin', 'DataBase/migrations/016_create_pls_channel_object_bindings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_object_bindings_to_canonical_object_key', 'pls_channel_object_bindings', 'to_canonical_object_key', '终点标准对象键', '关系终点的 PLS 标准对象键。', '用于定位被绑定、被包含或被应用的渠道对象。', 'account:mock_account_douyin_style', 'DataBase/migrations/016_create_pls_channel_object_bindings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_object_bindings_source_batch_id', 'pls_channel_object_bindings', 'source_batch_id', '来源批次ID', '产生该关系记录的导入批次。', '用于按批次审计、撤回或重新导入。', 'batch_channel_object_library_mock_20260706', 'DataBase/migrations/016_create_pls_channel_object_bindings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_object_bindings_data_version', 'pls_channel_object_bindings', 'data_version', '数据版本', '本次导入或生成的数据版本。', '用于确保关系连接的是同一版本的渠道对象。', 'v_channel_object_library_mock_20260706', 'DataBase/migrations/016_create_pls_channel_object_bindings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_object_bindings_generated_at', 'pls_channel_object_bindings', 'generated_at', '生成时间', '来源关系数据生成或导出的时间。', '用于判断关系数据新鲜度。', '2026-07-06T00:00:00Z', 'DataBase/migrations/016_create_pls_channel_object_bindings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_object_bindings_quality_flags_json', 'pls_channel_object_bindings', 'quality_flags_json', '质量标记JSON', '来源流程给出的关系质量标记。', '用于识别样例关系、缺失父对象、待复核关系等质量问题。', '["mock_sample"]', 'DataBase/migrations/016_create_pls_channel_object_bindings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_object_bindings_raw_json', 'pls_channel_object_bindings', 'raw_json', '原始JSON', '保留导入时的原始关系记录。', '用于审计、回放、字段补充和排查。', '{"bindingId":"bind_account_platform_mock_001"}', 'DataBase/migrations/016_create_pls_channel_object_bindings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_object_bindings_status', 'pls_channel_object_bindings', 'status', '记录状态', 'AgentHarness 内部关系记录状态。', '用于软删除或归档历史关系。', 'active', 'DataBase/migrations/016_create_pls_channel_object_bindings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_object_bindings_created_at', 'pls_channel_object_bindings', 'created_at', '创建时间', '记录第一次写入 AgentHarness 的时间。', '用于数据生命周期追踪。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/016_create_pls_channel_object_bindings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_object_bindings_updated_at', 'pls_channel_object_bindings', 'updated_at', '更新时间', '记录最近一次更新 AgentHarness 的时间。', '用于判断该关系记录是否被刷新。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/016_create_pls_channel_object_bindings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z');
