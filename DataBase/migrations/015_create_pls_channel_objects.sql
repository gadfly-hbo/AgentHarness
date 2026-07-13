PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS pls_channel_objects (
  id TEXT PRIMARY KEY,
  workspace_id TEXT NOT NULL,
  object_type TEXT NOT NULL
    CHECK (object_type IN (
      'platform',
      'trade_area',
      'store',
      'account',
      'marketing_event',
      'business_scenario'
    )),
  target_object TEXT NOT NULL
    CHECK (target_object IN ('ChannelEntity', 'MarketingEvent', 'BusinessScenario')),
  source_stable_key TEXT NOT NULL,
  key_source TEXT NOT NULL,
  canonical_object_key TEXT NOT NULL,
  object_version_id TEXT NOT NULL,
  data_version TEXT NOT NULL,
  source_batch_id TEXT NOT NULL,
  generated_at TEXT NOT NULL,
  time_window TEXT,
  display_name TEXT NOT NULL,
  platform_name TEXT,
  platform_type TEXT,
  entity_status TEXT NOT NULL DEFAULT 'active'
    CHECK (entity_status IN ('active', 'inactive', 'archived')),
  entity_attributes_json TEXT NOT NULL DEFAULT '{}'
    CHECK (json_valid(entity_attributes_json)),
  possible_duplicate INTEGER NOT NULL DEFAULT 0
    CHECK (possible_duplicate IN (0, 1)),
  duplicate_candidate_keys_json TEXT NOT NULL DEFAULT '[]'
    CHECK (json_valid(duplicate_candidate_keys_json)),
  manual_review_status TEXT NOT NULL DEFAULT 'unreviewed'
    CHECK (manual_review_status IN (
      'unreviewed',
      'needs_more_data',
      'approved',
      'rejected',
      'ignored'
    )),
  quality_flags_json TEXT NOT NULL DEFAULT '[]'
    CHECK (json_valid(quality_flags_json)),
  source TEXT NOT NULL,
  source_type TEXT NOT NULL,
  raw_json TEXT NOT NULL
    CHECK (json_valid(raw_json)),
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'inactive', 'archived')),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  UNIQUE (workspace_id, canonical_object_key, data_version),
  UNIQUE (object_version_id)
);

CREATE INDEX IF NOT EXISTS idx_pls_channel_objects_workspace
ON pls_channel_objects (workspace_id, status);

CREATE INDEX IF NOT EXISTS idx_pls_channel_objects_type
ON pls_channel_objects (object_type, platform_type, status);

CREATE INDEX IF NOT EXISTS idx_pls_channel_objects_source_batch
ON pls_channel_objects (source_batch_id, data_version);

CREATE INDEX IF NOT EXISTS idx_pls_channel_objects_review
ON pls_channel_objects (manual_review_status, possible_duplicate, status);

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
  ('field_pls_channel_objects_id', 'pls_channel_objects', 'id', '渠道对象记录ID', 'AgentHarness 内部使用的渠道对象版本记录唯一标识。', '用于唯一定位一条渠道对象导入记录。', 'pco_ws_demo_account_mock_account_douyin_style_v20260706', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_workspace_id', 'pls_channel_objects', 'workspace_id', '工作空间ID', '来源 PLS 工作空间标识。', '用于隔离不同业务空间或客户空间的数据。', 'ws_demo', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_object_type', 'pls_channel_objects', 'object_type', '对象类型', '渠道画像中的对象类型。', '用于区分平台、商圈、店铺、账号、活动和业务场景。', 'account', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_target_object', 'pls_channel_objects', 'target_object', '目标对象模型', 'PLS 前端或后端使用的目标对象模型名称。', '说明该记录落在 ChannelEntity、MarketingEvent 还是 BusinessScenario。', 'ChannelEntity', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_source_stable_key', 'pls_channel_objects', 'source_stable_key', '来源稳定键', '来源系统提供或生成的稳定业务键。', '用于跨批次识别同一个渠道对象。', 'mock_account_douyin_style', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_key_source', 'pls_channel_objects', 'key_source', '键来源', '说明稳定键是来源系统提供、人工提供还是按名称生成。', '用于判断对象ID可信度和是否需要人工复核。', 'source_system_id', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_canonical_object_key', 'pls_channel_objects', 'canonical_object_key', '标准对象键', 'PLS 渠道对象的标准业务键。', '用于绑定关系、画像、商品适配和下游匹配统一引用对象。', 'account:mock_account_douyin_style', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_object_version_id', 'pls_channel_objects', 'object_version_id', '对象版本ID', '带工作空间、对象键和数据版本的对象版本标识。', '用于追踪同一对象在不同数据版本中的状态。', 'ws_demo:account:mock_account_douyin_style:v_channel_object_library_mock_20260706', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_data_version', 'pls_channel_objects', 'data_version', '数据版本', '本次导入或生成的数据版本。', '用于版本隔离和回溯。', 'v_channel_object_library_mock_20260706', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_source_batch_id', 'pls_channel_objects', 'source_batch_id', '来源批次ID', '产生该对象记录的导入批次。', '用于按批次审计、撤回或重新导入。', 'batch_channel_object_library_mock_20260706', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_generated_at', 'pls_channel_objects', 'generated_at', '生成时间', '来源数据生成或导出的时间。', '用于判断数据新鲜度。', '2026-07-06T00:00:00Z', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_time_window', 'pls_channel_objects', 'time_window', '时间窗口', '该对象记录或活动覆盖的业务时间范围。', '用于区分周期性活动或画像统计窗口。', '2026-06-01/2026-06-20', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_display_name', 'pls_channel_objects', 'display_name', '展示名称', '前端展示给业务用户看的对象名称。', '用于渠道对象列表、详情页和人工复核。', 'Mock Douyin Style Account', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_platform_name', 'pls_channel_objects', 'platform_name', '平台名称', '对象所属平台名称。', '用于区分 Douyin、Tmall、JD 等平台来源。', 'Douyin', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_platform_type', 'pls_channel_objects', 'platform_type', '平台类型', '平台或渠道的业务类型。', '用于区分内容电商、传统电商、线下零售等渠道形态。', 'content_ecommerce', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_entity_status', 'pls_channel_objects', 'entity_status', '对象状态', '来源业务对象当前是否有效。', '用于过滤停用或归档的渠道对象。', 'active', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_entity_attributes_json', 'pls_channel_objects', 'entity_attributes_json', '对象属性JSON', '不同对象类型的扩展属性。', '用于保存账号内容形式、店铺类型、商圈半径、活动标签等结构化补充信息。', '{"contentFormats":["short_video","live"]}', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_possible_duplicate', 'pls_channel_objects', 'possible_duplicate', '疑似重复', '该对象是否被来源流程标记为疑似重复。', '用于进入人工复核或去重流程。', '1', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_duplicate_candidate_keys_json', 'pls_channel_objects', 'duplicate_candidate_keys_json', '重复候选键JSON', '疑似重复对象的候选标准对象键列表。', '用于人工复核时定位可能重复的对象。', '["account:mock_account_douyin_style_alt"]', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_manual_review_status', 'pls_channel_objects', 'manual_review_status', '人工复核状态', '对象当前的人工复核状态。', '用于控制对象是否可以进入正式画像和匹配流程。', 'unreviewed', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_quality_flags_json', 'pls_channel_objects', 'quality_flags_json', '质量标记JSON', '来源流程给出的质量问题或样本标记。', '用于数据治理、导入报告和业务解释。', '["mock_sample"]', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_source', 'pls_channel_objects', 'source', '数据来源', '该对象记录来自哪个导入包或来源系统。', '用于追踪数据入口。', 'mock_channel_object_library_sample', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_source_type', 'pls_channel_objects', 'source_type', '来源类型', '说明来源是样例、真实导入、人工配置还是模型生成。', '用于区分生产数据和验证样例。', 'mock_sample', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_raw_json', 'pls_channel_objects', 'raw_json', '原始JSON', '保留导入时的原始对象记录。', '用于审计、回放、字段补充和排查。', '{"canonicalObjectKey":"account:mock_account_douyin_style"}', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_status', 'pls_channel_objects', 'status', '记录状态', 'AgentHarness 内部记录状态。', '用于软删除或归档历史导入记录。', 'active', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_created_at', 'pls_channel_objects', 'created_at', '创建时间', '记录第一次写入 AgentHarness 的时间。', '用于数据生命周期追踪。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_channel_objects_updated_at', 'pls_channel_objects', 'updated_at', '更新时间', '记录最近一次更新 AgentHarness 的时间。', '用于判断该对象记录是否被刷新。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/015_create_pls_channel_objects.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z');
