PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS pls_product_fit_profiles (
  id TEXT PRIMARY KEY,
  workspace_id TEXT NOT NULL,
  profile_id TEXT NOT NULL,
  canonical_object_key TEXT NOT NULL,
  source TEXT NOT NULL,
  source_batch_id TEXT NOT NULL,
  data_version TEXT NOT NULL,
  generated_at TEXT NOT NULL,
  time_window TEXT,
  sample_size INTEGER
    CHECK (sample_size IS NULL OR sample_size >= 0),
  confidence REAL NOT NULL
    CHECK (confidence >= 0 AND confidence <= 1),
  fit_categories_json TEXT NOT NULL DEFAULT '[]'
    CHECK (json_valid(fit_categories_json)),
  fit_price_bands_json TEXT NOT NULL DEFAULT '[]'
    CHECK (json_valid(fit_price_bands_json)),
  fit_styles_json TEXT NOT NULL DEFAULT '[]'
    CHECK (json_valid(fit_styles_json)),
  fit_occasions_json TEXT NOT NULL DEFAULT '[]'
    CHECK (json_valid(fit_occasions_json)),
  fit_launch_types_json TEXT NOT NULL DEFAULT '[]'
    CHECK (json_valid(fit_launch_types_json)),
  evidence_json TEXT NOT NULL DEFAULT '[]'
    CHECK (json_valid(evidence_json)),
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

CREATE INDEX IF NOT EXISTS idx_pls_product_fit_profiles_object
ON pls_product_fit_profiles (workspace_id, canonical_object_key, status);

CREATE INDEX IF NOT EXISTS idx_pls_product_fit_profiles_batch
ON pls_product_fit_profiles (source_batch_id, data_version);

CREATE INDEX IF NOT EXISTS idx_pls_product_fit_profiles_source
ON pls_product_fit_profiles (source, confidence, status);

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
  ('field_pls_product_fit_profiles_id', 'pls_product_fit_profiles', 'id', '商品适配画像记录ID', 'AgentHarness 内部使用的商品适配画像快照唯一标识。', '用于唯一定位某个渠道对象的一次商品适配画像导入记录。', 'ppfp_ws_demo_product_fit_account_mock_001_v20260706', 'DataBase/migrations/018_create_pls_product_fit_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_product_fit_profiles_workspace_id', 'pls_product_fit_profiles', 'workspace_id', '工作空间ID', '来源 PLS 工作空间标识。', '用于隔离不同业务空间或客户空间的商品适配画像。', 'ws_demo', 'DataBase/migrations/018_create_pls_product_fit_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_product_fit_profiles_profile_id', 'pls_product_fit_profiles', 'profile_id', '来源适配画像ID', 'PLS 来源数据中的商品适配画像快照ID。', '用于与 PLS 原始导入包、报告或审计日志对齐。', 'product_fit_account_mock_001', 'DataBase/migrations/018_create_pls_product_fit_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_product_fit_profiles_canonical_object_key', 'pls_product_fit_profiles', 'canonical_object_key', '标准对象键', '该商品适配画像所属的 PLS 渠道对象键。', '用于把商品适配画像挂回平台、商圈、店铺或账号。', 'account:mock_account_douyin_style', 'DataBase/migrations/018_create_pls_product_fit_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_product_fit_profiles_source', 'pls_product_fit_profiles', 'source', '数据来源', '该商品适配画像来自哪个导入包、工具、人工配置或表现数据。', '用于区分用户导入、表现派生和人工配置。', 'user_imported', 'DataBase/migrations/018_create_pls_product_fit_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_product_fit_profiles_source_batch_id', 'pls_product_fit_profiles', 'source_batch_id', '来源批次ID', '产生该商品适配画像的导入批次。', '用于按批次审计、撤回或重新导入。', 'batch_channel_object_library_mock_20260706', 'DataBase/migrations/018_create_pls_product_fit_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_product_fit_profiles_data_version', 'pls_product_fit_profiles', 'data_version', '数据版本', '本次导入或生成的数据版本。', '用于确保商品适配画像连接的是同一版本的渠道对象。', 'v_channel_object_library_mock_20260706', 'DataBase/migrations/018_create_pls_product_fit_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_product_fit_profiles_generated_at', 'pls_product_fit_profiles', 'generated_at', '生成时间', '来源商品适配画像生成或导出的时间。', '用于判断商品适配画像数据新鲜度。', '2026-07-06T00:00:00Z', 'DataBase/migrations/018_create_pls_product_fit_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_product_fit_profiles_time_window', 'pls_product_fit_profiles', 'time_window', '时间窗口', '商品适配画像统计覆盖的日期窗口。', '用于理解适配判断基于哪个时间段；人工配置可以为空。', '2026-06-01/2026-06-30', 'DataBase/migrations/018_create_pls_product_fit_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_product_fit_profiles_sample_size', 'pls_product_fit_profiles', 'sample_size', '样本量', '生成该商品适配画像所依据的样本数量。', '用于判断适配结论的统计稳定性；人工配置可以为空。', '320', 'DataBase/migrations/018_create_pls_product_fit_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_product_fit_profiles_confidence', 'pls_product_fit_profiles', 'confidence', '置信度', '来源或映射流程给出的整体置信度，范围0到1。', '用于判断商品适配画像是否适合进入正式匹配或模型消费。', '0.78', 'DataBase/migrations/018_create_pls_product_fit_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_product_fit_profiles_fit_categories_json', 'pls_product_fit_profiles', 'fit_categories_json', '适合品类JSON', '该渠道对象适合销售的商品品类数组。', '用于商品和渠道匹配时判断品类适配度。', '["apparel","top"]', 'DataBase/migrations/018_create_pls_product_fit_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_product_fit_profiles_fit_price_bands_json', 'pls_product_fit_profiles', 'fit_price_bands_json', '适合价格带JSON', '该渠道对象适合销售的商品价格带数组。', '用于商品定价和渠道承接能力匹配。', '["mid"]', 'DataBase/migrations/018_create_pls_product_fit_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_product_fit_profiles_fit_styles_json', 'pls_product_fit_profiles', 'fit_styles_json', '适合风格JSON', '该渠道对象适合销售的商品风格数组。', '用于风格心智、内容调性和渠道匹配。', '["minimal"]', 'DataBase/migrations/018_create_pls_product_fit_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_product_fit_profiles_fit_occasions_json', 'pls_product_fit_profiles', 'fit_occasions_json', '适合使用场景JSON', '该渠道对象适合承接的商品使用场景数组。', '用于场景化推荐和渠道适配解释。', '["work"]', 'DataBase/migrations/018_create_pls_product_fit_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_product_fit_profiles_fit_launch_types_json', 'pls_product_fit_profiles', 'fit_launch_types_json', '适合上新类型JSON', '该渠道对象适合的商品生命周期或运营动作数组。', '用于判断新品首发、日常补货、清仓等场景是否适配。', '["new_product_launch"]', 'DataBase/migrations/018_create_pls_product_fit_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_product_fit_profiles_evidence_json', 'pls_product_fit_profiles', 'evidence_json', '证据JSON', '支撑商品适配画像的证据数组。', '用于解释适配结论来自导入、表现数据、人工理由还是模型判断。', '[{"type":"mock_imported_profile"}]', 'DataBase/migrations/018_create_pls_product_fit_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_product_fit_profiles_quality_flags_json', 'pls_product_fit_profiles', 'quality_flags_json', '质量标记JSON', '来源流程给出的商品适配画像质量标记。', '用于识别样例数据、人工配置无统计样本等质量问题。', '["mock_sample"]', 'DataBase/migrations/018_create_pls_product_fit_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_product_fit_profiles_raw_json', 'pls_product_fit_profiles', 'raw_json', '原始JSON', '保留导入时的原始商品适配画像记录。', '用于审计、回放、字段补充和排查。', '{"profileId":"product_fit_account_mock_001"}', 'DataBase/migrations/018_create_pls_product_fit_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_product_fit_profiles_status', 'pls_product_fit_profiles', 'status', '记录状态', 'AgentHarness 内部商品适配画像记录状态。', '用于软删除或归档历史画像。', 'active', 'DataBase/migrations/018_create_pls_product_fit_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_product_fit_profiles_created_at', 'pls_product_fit_profiles', 'created_at', '创建时间', '记录第一次写入 AgentHarness 的时间。', '用于数据生命周期追踪。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/018_create_pls_product_fit_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_product_fit_profiles_updated_at', 'pls_product_fit_profiles', 'updated_at', '更新时间', '记录最近一次更新 AgentHarness 的时间。', '用于判断该商品适配画像记录是否被刷新。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/018_create_pls_product_fit_profiles.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z');
