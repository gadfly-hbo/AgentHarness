CREATE VIEW IF NOT EXISTS v_pls_platform_tag_value_semantics AS
SELECT
  value_mapping.platform,
  value_mapping.tag_type,
  value_mapping.leaf_label,
  value_mapping.label_path,
  dimensions.layer_code,
  dimensions.layer_name,
  dimensions.dimension_code,
  dimensions.dimension_name,
  dimensions.dimension_definition,
  dimensions.business_strategy,
  value_mapping.mapping_status,
  value_mapping.mapping_method,
  value_mapping.confidence,
  value_mapping.rationale,
  value_mapping.platform_tag_catalog_id,
  value_mapping.id AS tag_value_mapping_id,
  value_mapping.inherited_tag_type_mapping_id,
  value_mapping.source_ref,
  value_mapping.updated_at
FROM pls_tag_value_dimension_mappings value_mapping
JOIN pls_semantic_dimensions dimensions
  ON dimensions.id = value_mapping.dimension_id
WHERE value_mapping.status = 'active';

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
  ('field_v_pls_platform_tag_value_semantics_platform', 'v_pls_platform_tag_value_semantics', 'platform', '平台', '标签值来自哪个平台。', '下游产品可以按平台过滤天猫、抖音以及未来接入的平台。', '天猫', 'DataBase/migrations/010_create_v_pls_platform_tag_value_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_platform_tag_value_semantics_tag_type', 'v_pls_platform_tag_value_semantics', 'tag_type', '标签类型', '平台原始标签类型。', '用于理解标签值所属的平台分类。', '美妆行业-护肤品功效需求', 'DataBase/migrations/010_create_v_pls_platform_tag_value_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_platform_tag_value_semantics_leaf_label', 'v_pls_platform_tag_value_semantics', 'leaf_label', '标签值', '平台标签目录中的最细粒度标签值。', '这是画像、分层和模型消费时最常用的业务标签。', '保湿补水', 'DataBase/migrations/010_create_v_pls_platform_tag_value_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_platform_tag_value_semantics_label_path', 'v_pls_platform_tag_value_semantics', 'label_path', '标签路径', '平台标签完整路径。', '用于保留标签上下文，避免同名标签值被误解。', '美妆>护肤品功效需求>保湿补水', 'DataBase/migrations/010_create_v_pls_platform_tag_value_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_platform_tag_value_semantics_layer_code', 'v_pls_platform_tag_value_semantics', 'layer_code', 'PLS层级代码', '该标签值所属的P/L/S层。', '帮助下游模型按静态人群、生活心智、临场转化刺激分层消费。', 'S', 'DataBase/migrations/010_create_v_pls_platform_tag_value_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_platform_tag_value_semantics_layer_name', 'v_pls_platform_tag_value_semantics', 'layer_name', 'PLS层级名称', 'PLS层级的中文业务名称。', '让业务用户直接理解该标签值进入哪一层PLS逻辑。', '临场转化刺激', 'DataBase/migrations/010_create_v_pls_platform_tag_value_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_platform_tag_value_semantics_dimension_code', 'v_pls_platform_tag_value_semantics', 'dimension_code', '维度代码', 'PLS九维中的稳定机器代码。', '供程序、模型和规则稳定引用。', 'S_CONVERSION_FRICTION', 'DataBase/migrations/010_create_v_pls_platform_tag_value_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_platform_tag_value_semantics_dimension_name', 'v_pls_platform_tag_value_semantics', 'dimension_name', '维度名称', 'PLS九维中的中文维度名称。', '供业务用户理解标签值所属语义维度。', '转化决策摩擦', 'DataBase/migrations/010_create_v_pls_platform_tag_value_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_platform_tag_value_semantics_dimension_definition', 'v_pls_platform_tag_value_semantics', 'dimension_definition', '维度定义', '该PLS维度覆盖的业务内涵。', '用于解释为什么该标签值属于这个维度。', '临门行为阻力与选择条件', 'DataBase/migrations/010_create_v_pls_platform_tag_value_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_platform_tag_value_semantics_business_strategy', 'v_pls_platform_tag_value_semantics', 'business_strategy', '业务策略', '该维度对算法、运营或投放策略的指导意义。', '帮助产品判断这个标签值在画像和分层中应该如何使用。', '【S层触发】：临场转化刺激与阻力处理。', 'DataBase/migrations/010_create_v_pls_platform_tag_value_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_platform_tag_value_semantics_mapping_status', 'v_pls_platform_tag_value_semantics', 'mapping_status', '映射状态', '该标签值映射当前是否已批准。', '下游产品默认只消费 approved 映射。', 'approved', 'DataBase/migrations/010_create_v_pls_platform_tag_value_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_platform_tag_value_semantics_mapping_method', 'v_pls_platform_tag_value_semantics', 'mapping_method', '映射方法', '说明映射来自继承、规则、人工还是导入。', '用于判断映射来源和可信程度。', 'inherited_tag_type', 'DataBase/migrations/010_create_v_pls_platform_tag_value_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_platform_tag_value_semantics_confidence', 'v_pls_platform_tag_value_semantics', 'confidence', '置信度', '映射可信度，范围0到1。', '用于抽检和排查低置信映射。', '1.0', 'DataBase/migrations/010_create_v_pls_platform_tag_value_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_platform_tag_value_semantics_rationale', 'v_pls_platform_tag_value_semantics', 'rationale', '映射理由', '说明标签值映射到当前PLS维度的依据。', '帮助业务用户理解映射不是黑盒。', '继承已批准的标签类型级映射。', 'DataBase/migrations/010_create_v_pls_platform_tag_value_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_platform_tag_value_semantics_platform_tag_catalog_id', 'v_pls_platform_tag_value_semantics', 'platform_tag_catalog_id', '平台标签目录ID', '原始平台标签目录记录ID。', '用于从消费视图回溯到原始标签目录。', 'ptag_天猫_...', 'DataBase/migrations/010_create_v_pls_platform_tag_value_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_platform_tag_value_semantics_tag_value_mapping_id', 'v_pls_platform_tag_value_semantics', 'tag_value_mapping_id', '标签值映射ID', '标签值级映射记录ID。', '用于从消费视图回溯到标签值映射表。', 'pvalmap_...', 'DataBase/migrations/010_create_v_pls_platform_tag_value_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_platform_tag_value_semantics_inherited_tag_type_mapping_id', 'v_pls_platform_tag_value_semantics', 'inherited_tag_type_mapping_id', '继承的标签类型映射ID', '标签值继承的标签类型级映射ID。', '用于追踪该标签值当前PLS维度的上层映射来源。', 'ptypemap_...', 'DataBase/migrations/010_create_v_pls_platform_tag_value_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_platform_tag_value_semantics_source_ref', 'v_pls_platform_tag_value_semantics', 'source_ref', '来源引用', '该映射的来源记录引用。', '用于审计和数据回溯。', 'platform_tag_catalog:ptag_...', 'DataBase/migrations/010_create_v_pls_platform_tag_value_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_platform_tag_value_semantics_updated_at', 'v_pls_platform_tag_value_semantics', 'updated_at', '更新时间', '该映射最近一次更新时间。', '用于判断消费视图中的数据新鲜度。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/010_create_v_pls_platform_tag_value_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z');
