PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS pls_tag_value_dimension_mappings (
  id TEXT PRIMARY KEY,
  platform_tag_catalog_id TEXT NOT NULL,
  platform TEXT NOT NULL,
  tag_type TEXT NOT NULL,
  leaf_label TEXT NOT NULL,
  label_path TEXT NOT NULL,
  dimension_id TEXT NOT NULL,
  inherited_tag_type_mapping_id TEXT NOT NULL,
  mapping_status TEXT NOT NULL DEFAULT 'approved'
    CHECK (mapping_status IN ('proposed', 'approved', 'review_needed', 'unmapped', 'rejected')),
  mapping_method TEXT NOT NULL DEFAULT 'inherited_tag_type'
    CHECK (mapping_method IN ('inherited_tag_type', 'rule', 'manual', 'imported')),
  confidence REAL NOT NULL DEFAULT 0
    CHECK (confidence >= 0 AND confidence <= 1),
  rationale TEXT NOT NULL,
  source_ref TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'inactive', 'archived')),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  FOREIGN KEY (platform_tag_catalog_id)
    REFERENCES platform_tag_catalog(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  FOREIGN KEY (dimension_id)
    REFERENCES pls_semantic_dimensions(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  FOREIGN KEY (inherited_tag_type_mapping_id)
    REFERENCES pls_tag_type_dimension_mappings(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  UNIQUE (platform_tag_catalog_id)
);

CREATE INDEX IF NOT EXISTS idx_pls_tag_value_dimension_mappings_dimension
ON pls_tag_value_dimension_mappings (dimension_id, mapping_status);

CREATE INDEX IF NOT EXISTS idx_pls_tag_value_dimension_mappings_platform
ON pls_tag_value_dimension_mappings (platform, tag_type, mapping_status);

CREATE INDEX IF NOT EXISTS idx_pls_tag_value_dimension_mappings_leaf_label
ON pls_tag_value_dimension_mappings (leaf_label);

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
  ('field_pls_tag_value_dimension_mappings_id', 'pls_tag_value_dimension_mappings', 'id', '标签值映射ID', '标签值级PLS映射记录的稳定唯一标识。', '用于唯一定位一条平台标签值到PLS维度的映射关系。', 'pvalmap_tmall_001', 'DataBase/migrations/008_create_pls_tag_value_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_tag_value_dimension_mappings_platform_tag_catalog_id', 'pls_tag_value_dimension_mappings', 'platform_tag_catalog_id', '平台标签目录ID', '对应 platform_tag_catalog 表中的原始平台标签记录。', '保证每一条标签值映射都能追溯回原始平台标签。', 'ptag_tmall_000001', 'DataBase/migrations/008_create_pls_tag_value_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_tag_value_dimension_mappings_platform', 'pls_tag_value_dimension_mappings', 'platform', '平台', '标签值来自哪个平台。', '用于区分天猫、抖音以及后续接入的京东等平台。', '天猫', 'DataBase/migrations/008_create_pls_tag_value_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_tag_value_dimension_mappings_tag_type', 'pls_tag_value_dimension_mappings', 'tag_type', '标签类型', '平台原始标签类型。', '说明该标签值属于平台哪一类标签，是继承PLS维度的上层依据。', '美妆行业-护肤品功效需求', 'DataBase/migrations/008_create_pls_tag_value_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_tag_value_dimension_mappings_leaf_label', 'pls_tag_value_dimension_mappings', 'leaf_label', '标签值', '平台标签目录中的最细粒度标签值。', '后续画像、人群分层和模型消费时真正会匹配到的业务标签。', '保湿补水', 'DataBase/migrations/008_create_pls_tag_value_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_tag_value_dimension_mappings_label_path', 'pls_tag_value_dimension_mappings', 'label_path', '标签路径', '平台标签从上级分类到标签值的完整路径。', '用于在标签值同名时保留上下文，避免业务理解歧义。', '美妆>护肤品功效需求>保湿补水', 'DataBase/migrations/008_create_pls_tag_value_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_tag_value_dimension_mappings_dimension_id', 'pls_tag_value_dimension_mappings', 'dimension_id', 'PLS维度ID', '该标签值映射到的PLS标准维度。', '让平台标签值可以统一进入PLS三层九维模型。', 'pls_dim_s_conversion_friction', 'DataBase/migrations/008_create_pls_tag_value_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_tag_value_dimension_mappings_inherited_tag_type_mapping_id', 'pls_tag_value_dimension_mappings', 'inherited_tag_type_mapping_id', '继承的标签类型映射ID', '说明该标签值当前继承自哪条标签类型级映射。', '用于追踪标签值映射来源；未来标签值需要单独修正时也能知道原始继承关系。', 'ptypemap_天猫_美妆行业', 'DataBase/migrations/008_create_pls_tag_value_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_tag_value_dimension_mappings_mapping_status', 'pls_tag_value_dimension_mappings', 'mapping_status', '映射状态', '标签值映射当前是否已经批准或需要复核。', '用于区分已批准、待复核、无法映射或已拒绝的标签值映射。', 'approved', 'DataBase/migrations/008_create_pls_tag_value_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_tag_value_dimension_mappings_mapping_method', 'pls_tag_value_dimension_mappings', 'mapping_method', '映射方法', '说明该标签值映射是继承、规则、人工还是导入产生。', '帮助评估映射可信度和后续是否需要人工抽检。', 'inherited_tag_type', 'DataBase/migrations/008_create_pls_tag_value_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_tag_value_dimension_mappings_confidence', 'pls_tag_value_dimension_mappings', 'confidence', '置信度', '标签值映射的可信度，范围0到1。', '用于后续排序抽检和识别低置信映射。', '1.0', 'DataBase/migrations/008_create_pls_tag_value_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_tag_value_dimension_mappings_rationale', 'pls_tag_value_dimension_mappings', 'rationale', '映射理由', '说明该标签值为什么映射到当前PLS维度。', '让业务用户能理解映射依据，而不是只看到英文代码。', '继承已批准的标签类型级映射。', 'DataBase/migrations/008_create_pls_tag_value_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_tag_value_dimension_mappings_source_ref', 'pls_tag_value_dimension_mappings', 'source_ref', '来源引用', '记录该映射来自哪条平台标签目录记录。', '用于审计、回溯和重新导入时定位数据来源。', 'platform_tag_catalog:ptag_tmall_000001', 'DataBase/migrations/008_create_pls_tag_value_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_tag_value_dimension_mappings_status', 'pls_tag_value_dimension_mappings', 'status', '状态', '该映射记录是否仍然有效。', '用于保留历史映射，同时过滤已停用或归档记录。', 'active', 'DataBase/migrations/008_create_pls_tag_value_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_tag_value_dimension_mappings_created_at', 'pls_tag_value_dimension_mappings', 'created_at', '创建时间', '记录这条映射第一次创建的时间。', '用于审计和数据生命周期追踪。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/008_create_pls_tag_value_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_pls_tag_value_dimension_mappings_updated_at', 'pls_tag_value_dimension_mappings', 'updated_at', '更新时间', '记录这条映射最近一次更新的时间。', '用于判断映射是否被重新导入、人工修正或复审。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/008_create_pls_tag_value_dimension_mappings.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z');
