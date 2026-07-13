PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS profile_tag_observations (
  id TEXT PRIMARY KEY,
  subject_type TEXT NOT NULL
    CHECK (subject_type IN ('user', 'account', 'audience_segment', 'product', 'sample_subject')),
  subject_id TEXT NOT NULL,
  subject_entity_id TEXT,
  platform_tag_catalog_id TEXT NOT NULL,
  platform TEXT NOT NULL,
  tag_type TEXT NOT NULL,
  leaf_label TEXT NOT NULL,
  observed_value TEXT,
  observation_weight REAL NOT NULL DEFAULT 1
    CHECK (observation_weight >= 0 AND observation_weight <= 1),
  observation_source TEXT NOT NULL,
  observed_at TEXT NOT NULL,
  evidence_ref TEXT,
  context_json TEXT NOT NULL DEFAULT '{}'
    CHECK (json_valid(context_json)),
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'inactive', 'archived')),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  FOREIGN KEY (subject_entity_id)
    REFERENCES entities(id)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  FOREIGN KEY (platform_tag_catalog_id)
    REFERENCES platform_tag_catalog(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  UNIQUE (
    subject_type,
    subject_id,
    platform_tag_catalog_id,
    observed_at,
    observation_source
  )
);

CREATE INDEX IF NOT EXISTS idx_profile_tag_observations_subject
ON profile_tag_observations (subject_type, subject_id, status);

CREATE INDEX IF NOT EXISTS idx_profile_tag_observations_catalog
ON profile_tag_observations (platform_tag_catalog_id, status);

CREATE INDEX IF NOT EXISTS idx_profile_tag_observations_platform
ON profile_tag_observations (platform, tag_type, status);

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
  ('field_profile_tag_observations_id', 'profile_tag_observations', 'id', '画像标签观测ID', '一条画像标签命中记录的稳定唯一标识。', '用于唯一定位某个主体命中的某个标签值。', 'ptobs_sample_001', 'DataBase/migrations/011_create_profile_tag_observations.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_profile_tag_observations_subject_type', 'profile_tag_observations', 'subject_type', '主体类型', '说明被打标签的对象类型。', '用于区分用户、账号、人群、商品或样例主体。', 'audience_segment', 'DataBase/migrations/011_create_profile_tag_observations.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_profile_tag_observations_subject_id', 'profile_tag_observations', 'subject_id', '主体ID', '被打标签对象在来源系统或业务中的ID。', '下游画像和分层会按这个ID聚合标签。', 'pls_demo_segment_beauty_001', 'DataBase/migrations/011_create_profile_tag_observations.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_profile_tag_observations_subject_entity_id', 'profile_tag_observations', 'subject_entity_id', '主体实体ID', '可选的 AgentHarness entities 表引用。', '当主体已登记为统一实体时，用它和其他系统对象打通。', 'ent_module_pls_profile', 'DataBase/migrations/011_create_profile_tag_observations.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_profile_tag_observations_platform_tag_catalog_id', 'profile_tag_observations', 'platform_tag_catalog_id', '平台标签目录ID', '命中的原始平台标签值ID。', '通过它连接平台原始标签和PLS标准语义。', 'ptag_天猫_...', 'DataBase/migrations/011_create_profile_tag_observations.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_profile_tag_observations_platform', 'profile_tag_observations', 'platform', '平台', '标签观测来自哪个平台。', '用于按天猫、抖音等来源过滤画像标签。', '天猫', 'DataBase/migrations/011_create_profile_tag_observations.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_profile_tag_observations_tag_type', 'profile_tag_observations', 'tag_type', '标签类型', '命中的平台标签类型。', '用于保留平台标签上下文，方便排查和解释。', '美妆行业-护肤品功效需求', 'DataBase/migrations/011_create_profile_tag_observations.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_profile_tag_observations_leaf_label', 'profile_tag_observations', 'leaf_label', '标签值', '命中的平台标签值。', '这是画像事实表里最关键的业务标签。', '保湿补水', 'DataBase/migrations/011_create_profile_tag_observations.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_profile_tag_observations_observed_value', 'profile_tag_observations', 'observed_value', '观测值', '标签命中的原始观测值或补充值。', '某些标签可能需要记录分数、次数、等级或原始取值。', 'high', 'DataBase/migrations/011_create_profile_tag_observations.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_profile_tag_observations_observation_weight', 'profile_tag_observations', 'observation_weight', '观测权重', '该标签命中的强度，范围0到1。', '用于画像聚合和模型特征加权。', '0.85', 'DataBase/migrations/011_create_profile_tag_observations.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_profile_tag_observations_observation_source', 'profile_tag_observations', 'observation_source', '观测来源', '说明这条标签命中来自哪里。', '用于区分导入、模型预测、人工标注或样例数据。', 'seed:pls_demo', 'DataBase/migrations/011_create_profile_tag_observations.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_profile_tag_observations_observed_at', 'profile_tag_observations', 'observed_at', '观测时间', '标签命中发生或被采集的时间。', '用于时间窗画像、标签衰减和新鲜度判断。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/011_create_profile_tag_observations.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_profile_tag_observations_evidence_ref', 'profile_tag_observations', 'evidence_ref', '证据引用', '指向产生该标签命中的外部记录或任务。', '用于审计和问题排查。', 'seed:pls_demo:beauty', 'DataBase/migrations/011_create_profile_tag_observations.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_profile_tag_observations_context_json', 'profile_tag_observations', 'context_json', '上下文JSON', '保存暂未结构化的观测上下文。', '用于承载导入批次、渠道、场景等补充信息。', '{"demo":true}', 'DataBase/migrations/011_create_profile_tag_observations.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_profile_tag_observations_status', 'profile_tag_observations', 'status', '状态', '该观测记录当前是否有效。', '用于过滤已停用或归档的标签观测。', 'active', 'DataBase/migrations/011_create_profile_tag_observations.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_profile_tag_observations_created_at', 'profile_tag_observations', 'created_at', '创建时间', '记录这条观测第一次创建的时间。', '用于数据生命周期追踪。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/011_create_profile_tag_observations.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_profile_tag_observations_updated_at', 'profile_tag_observations', 'updated_at', '更新时间', '记录这条观测最近一次更新的时间。', '用于判断观测数据是否被刷新。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/011_create_profile_tag_observations.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z');
