PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS platform_profile_tag_metrics (
  id TEXT PRIMARY KEY,
  workspace_id TEXT NOT NULL,
  profile_id TEXT NOT NULL,
  canonical_object_key TEXT NOT NULL,
  channel_object_type TEXT NOT NULL
    CHECK (channel_object_type IN (
      'platform',
      'trade_area',
      'store',
      'account',
      'marketing_event',
      'business_scenario'
    )),
  channel_object_name TEXT NOT NULL,
  platform TEXT NOT NULL,
  platform_tag_catalog_id TEXT NOT NULL,
  tag_type TEXT NOT NULL,
  leaf_label TEXT NOT NULL,
  metric_name TEXT NOT NULL,
  metric_value REAL NOT NULL,
  metric_unit TEXT NOT NULL,
  metric_display_value TEXT,
  profile_time_window TEXT NOT NULL,
  sample_size INTEGER
    CHECK (sample_size IS NULL OR sample_size >= 0),
  source_file TEXT NOT NULL,
  source_row INTEGER NOT NULL,
  source_batch_id TEXT NOT NULL,
  raw_json TEXT NOT NULL DEFAULT '{}'
    CHECK (json_valid(raw_json)),
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'inactive', 'archived')),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  FOREIGN KEY (platform_tag_catalog_id)
    REFERENCES platform_tag_catalog(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  UNIQUE (
    workspace_id,
    profile_id,
    canonical_object_key,
    platform_tag_catalog_id,
    metric_name,
    profile_time_window,
    source_batch_id
  )
);

CREATE INDEX IF NOT EXISTS idx_platform_profile_tag_metrics_object
ON platform_profile_tag_metrics (
  workspace_id,
  canonical_object_key,
  channel_object_type,
  status
);

CREATE INDEX IF NOT EXISTS idx_platform_profile_tag_metrics_platform_tag
ON platform_profile_tag_metrics (
  platform,
  tag_type,
  leaf_label,
  status
);

CREATE INDEX IF NOT EXISTS idx_platform_profile_tag_metrics_batch
ON platform_profile_tag_metrics (
  source_batch_id,
  source_file,
  profile_time_window
);

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
  ('field_platform_profile_tag_metrics_id', 'platform_profile_tag_metrics', 'id', '画像指标ID', '一条平台画像标签指标记录的稳定唯一标识。', '用于唯一定位某个渠道对象、标签值和指标组合。', 'pptm_tmall_account_001_share_001', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z'),
  ('field_platform_profile_tag_metrics_workspace_id', 'platform_profile_tag_metrics', 'workspace_id', '工作空间ID', '来源 PLS 或业务工作空间标识。', '用于隔离不同客户、业务线或项目空间的真实画像数据。', 'ws_pls_real_001', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z'),
  ('field_platform_profile_tag_metrics_profile_id', 'platform_profile_tag_metrics', 'profile_id', '画像ID', '来源文件或导入批次中的画像快照ID。', '用于区分同一渠道对象的不同画像版本或导出任务。', '101326115008', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z'),
  ('field_platform_profile_tag_metrics_canonical_object_key', 'platform_profile_tag_metrics', 'canonical_object_key', '标准对象键', '渠道对象的统一业务键。', '用于把平台、店铺、账号、活动、场景等画像指标挂到同一对象体系。', 'account:douyin:101326115008', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z'),
  ('field_platform_profile_tag_metrics_channel_object_type', 'platform_profile_tag_metrics', 'channel_object_type', '渠道对象类型', '真实画像指标所属的渠道对象类型。', '用于区分平台、商圈、店铺、账号、活动和业务场景。', 'account', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z'),
  ('field_platform_profile_tag_metrics_channel_object_name', 'platform_profile_tag_metrics', 'channel_object_name', '渠道对象名称', '业务侧可读的渠道对象展示名称。', '用于前端展示、人工核查和导入报告。', '抖音账号101326115008', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z'),
  ('field_platform_profile_tag_metrics_platform', 'platform_profile_tag_metrics', 'platform', '平台', '画像指标来自哪个平台。', '用于按天猫、抖音、京东过滤真实画像指标。', '抖音', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z'),
  ('field_platform_profile_tag_metrics_platform_tag_catalog_id', 'platform_profile_tag_metrics', 'platform_tag_catalog_id', '平台标签目录ID', '对应 platform_tag_catalog 的标签值ID。', '让真实画像指标可以连接到平台标签目录和 PLS 语义维度。', 'ptag_douyin_...', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z'),
  ('field_platform_profile_tag_metrics_tag_type', 'platform_profile_tag_metrics', 'tag_type', '标签类型', '平台画像导出的标签类型。', '用于保留来源平台标签上下文并支持导入排查。', '预测年龄段', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z'),
  ('field_platform_profile_tag_metrics_leaf_label', 'platform_profile_tag_metrics', 'leaf_label', '标签值', '平台画像导出的标签值。', '用于真实画像明细解释和 PLS 维度聚合。', '24-30', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z'),
  ('field_platform_profile_tag_metrics_metric_name', 'platform_profile_tag_metrics', 'metric_name', '指标名', '该行记录的画像指标名称。', '用于区分占比、TGI、人数、指数、分数等不同度量，避免混合聚合。', 'share', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z'),
  ('field_platform_profile_tag_metrics_metric_value', 'platform_profile_tag_metrics', 'metric_value', '指标数值', '画像指标的可计算数值。', '用于后续按 PLS 维度聚合、排序和模型消费。', '47.28', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z'),
  ('field_platform_profile_tag_metrics_metric_unit', 'platform_profile_tag_metrics', 'metric_unit', '指标单位', '画像指标的单位或度量口径。', '帮助消费方理解 metric_value 是百分比、人数、指数还是得分。', 'percent', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z'),
  ('field_platform_profile_tag_metrics_metric_display_value', 'platform_profile_tag_metrics', 'metric_display_value', '指标展示值', '来源文件中的原始展示值。', '用于保留 47.28%、TGI 等展示口径，便于人工核查。', '47.28%', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z'),
  ('field_platform_profile_tag_metrics_profile_time_window', 'platform_profile_tag_metrics', 'profile_time_window', '画像时间窗口', '该画像指标覆盖的统计时间范围。', '用于判断画像新鲜度、做时间窗隔离和趋势对比。', '2026Q2', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z'),
  ('field_platform_profile_tag_metrics_sample_size', 'platform_profile_tag_metrics', 'sample_size', '样本量', '生成该画像指标时的样本数量。', '用于判断指标可信度和统计稳定性；未知时可为空。', '10000', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z'),
  ('field_platform_profile_tag_metrics_source_file', 'platform_profile_tag_metrics', 'source_file', '来源文件', '该指标来自哪个原始或清洗文件。', '用于审计、重放导入和定位问题行。', 'platform_profile_extracts/douyin/v0.1/101326115008_实际可提取画像标签_20260714.csv', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z'),
  ('field_platform_profile_tag_metrics_source_row', 'platform_profile_tag_metrics', 'source_row', '来源行号', '来源文件中的行号。', '用于精确回溯原始导出行。', '2', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z'),
  ('field_platform_profile_tag_metrics_source_batch_id', 'platform_profile_tag_metrics', 'source_batch_id', '来源批次ID', '本次导入任务或文件批次标识。', '用于按批次撤回、重跑或审计真实画像导入。', 'batch_profile_extract_20260714_001', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z'),
  ('field_platform_profile_tag_metrics_raw_json', 'platform_profile_tag_metrics', 'raw_json', '原始JSON', '保留来源行的原始字段和值。', '用于审计、排查和后续字段补充。', '{"占比":"47.28%","tgi":"367.0"}', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z'),
  ('field_platform_profile_tag_metrics_status', 'platform_profile_tag_metrics', 'status', '状态', '该画像指标记录是否有效。', '用于软删除、归档或过滤过期导入。', 'active', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z'),
  ('field_platform_profile_tag_metrics_created_at', 'platform_profile_tag_metrics', 'created_at', '创建时间', '记录第一次写入时间。', '用于数据生命周期和审计。', '2026-07-14T00:00:00.000Z', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z'),
  ('field_platform_profile_tag_metrics_updated_at', 'platform_profile_tag_metrics', 'updated_at', '更新时间', '记录最近一次更新时间。', '用于判断指标是否被刷新或修正。', '2026-07-14T00:00:00.000Z', 'DataBase/migrations/024_create_platform_profile_tag_metrics.sql', 'active', '2026-07-14T00:00:00.000Z', '2026-07-14T00:00:00.000Z');
