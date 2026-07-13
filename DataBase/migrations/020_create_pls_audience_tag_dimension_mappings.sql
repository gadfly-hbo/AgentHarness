PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS pls_audience_tag_dimension_mappings (
  id TEXT PRIMARY KEY,
  tag_id TEXT NOT NULL,
  tag_namespace TEXT NOT NULL,
  tag_label_zh TEXT NOT NULL,
  dimension_id TEXT NOT NULL,
  mapping_status TEXT NOT NULL DEFAULT 'approved'
    CHECK (mapping_status IN ('proposed', 'approved', 'review_needed', 'unmapped', 'rejected')),
  mapping_method TEXT NOT NULL DEFAULT 'manual_seed'
    CHECK (mapping_method IN ('manual_seed', 'rule', 'manual_review', 'imported')),
  confidence REAL NOT NULL
    CHECK (confidence >= 0 AND confidence <= 1),
  rationale TEXT NOT NULL,
  source_ref TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'inactive', 'archived')),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  FOREIGN KEY (dimension_id)
    REFERENCES pls_semantic_dimensions(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  UNIQUE (tag_id)
);

CREATE INDEX IF NOT EXISTS idx_pls_audience_tag_dimension_mappings_namespace
ON pls_audience_tag_dimension_mappings (tag_namespace, mapping_status);

CREATE INDEX IF NOT EXISTS idx_pls_audience_tag_dimension_mappings_dimension
ON pls_audience_tag_dimension_mappings (dimension_id, mapping_status);

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
  ('field_pls_audience_tag_dimension_mappings_id', 'pls_audience_tag_dimension_mappings', 'id', '人群标签映射ID', 'PLS 渠道画像标签到三层九维维度映射的唯一标识。', '用于唯一定位一条渠道画像标签语义映射。', 'patdim_demo_age_25_34', 'DataBase/migrations/020_create_pls_audience_tag_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_tag_dimension_mappings_tag_id', 'pls_audience_tag_dimension_mappings', 'tag_id', '画像标签ID', 'PLS 渠道画像体系中的标签ID。', '用于连接 pls_audience_profiles.tags_json 里的 tagId。', 'demo.age_25_34', 'DataBase/migrations/020_create_pls_audience_tag_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_tag_dimension_mappings_tag_namespace', 'pls_audience_tag_dimension_mappings', 'tag_namespace', '标签命名空间', 'tag_id 点号前的标签大类。', '用于按 demo、channel、style、occasion、price 等标签族管理映射。', 'demo', 'DataBase/migrations/020_create_pls_audience_tag_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_tag_dimension_mappings_tag_label_zh', 'pls_audience_tag_dimension_mappings', 'tag_label_zh', '标签中文名', '面向业务用户展示的标签中文名称。', '降低非技术用户理解英文 tagId 的成本。', '25-34岁', 'DataBase/migrations/020_create_pls_audience_tag_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_tag_dimension_mappings_dimension_id', 'pls_audience_tag_dimension_mappings', 'dimension_id', 'PLS维度ID', '该渠道画像标签映射到的 PLS 三层九维标准维度。', '让渠道画像标签可以进入统一 PLS 分层模型。', 'pls_dim_p_demographics', 'DataBase/migrations/020_create_pls_audience_tag_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_tag_dimension_mappings_mapping_status', 'pls_audience_tag_dimension_mappings', 'mapping_status', '映射状态', '该标签映射当前是否已经批准或需要复核。', '用于区分已批准、待复核、无法映射或已拒绝的标签映射。', 'approved', 'DataBase/migrations/020_create_pls_audience_tag_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_tag_dimension_mappings_mapping_method', 'pls_audience_tag_dimension_mappings', 'mapping_method', '映射方法', '说明映射是种子规则、规则推断、人工复核还是导入产生。', '用于评估映射可信度和后续是否需要人工抽检。', 'manual_seed', 'DataBase/migrations/020_create_pls_audience_tag_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_tag_dimension_mappings_confidence', 'pls_audience_tag_dimension_mappings', 'confidence', '置信度', '标签到 PLS 维度映射的可信度，范围0到1。', '用于后续排序抽检和识别低置信映射。', '0.95', 'DataBase/migrations/020_create_pls_audience_tag_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_tag_dimension_mappings_rationale', 'pls_audience_tag_dimension_mappings', 'rationale', '映射理由', '说明该标签为什么映射到当前 PLS 维度。', '让业务用户能理解映射依据，而不是只看到英文代码。', '年龄段标签属于基础人口学。', 'DataBase/migrations/020_create_pls_audience_tag_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_tag_dimension_mappings_source_ref', 'pls_audience_tag_dimension_mappings', 'source_ref', '来源引用', '记录该映射来自哪个来源文件或判断依据。', '用于审计、回溯和重新导入时定位数据来源。', 'pls:audience_profile_sample', 'DataBase/migrations/020_create_pls_audience_tag_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_tag_dimension_mappings_status', 'pls_audience_tag_dimension_mappings', 'status', '状态', '该映射记录是否仍然有效。', '用于保留历史映射，同时过滤已停用或归档记录。', 'active', 'DataBase/migrations/020_create_pls_audience_tag_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_tag_dimension_mappings_created_at', 'pls_audience_tag_dimension_mappings', 'created_at', '创建时间', '记录这条映射第一次创建的时间。', '用于审计和数据生命周期追踪。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/020_create_pls_audience_tag_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_audience_tag_dimension_mappings_updated_at', 'pls_audience_tag_dimension_mappings', 'updated_at', '更新时间', '记录这条映射最近一次更新的时间。', '用于判断映射是否被重新导入、人工修正或复审。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/020_create_pls_audience_tag_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z');
