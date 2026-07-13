CREATE VIEW IF NOT EXISTS v_subject_pls_dimension_features AS
SELECT
  subject_type,
  subject_id,
  subject_entity_id,
  layer_code,
  layer_name,
  dimension_code,
  dimension_name,
  COUNT(*) AS observation_count,
  ROUND(SUM(observation_weight), 6) AS total_weight,
  ROUND(AVG(observation_weight), 6) AS avg_weight,
  ROUND(MAX(observation_weight), 6) AS max_weight,
  COUNT(DISTINCT platform) AS platform_count,
  GROUP_CONCAT(DISTINCT platform) AS platforms,
  COUNT(DISTINCT tag_type) AS tag_type_count,
  COUNT(DISTINCT leaf_label) AS leaf_label_count,
  MIN(observed_at) AS first_observed_at,
  MAX(observed_at) AS last_observed_at,
  MAX(observation_updated_at) AS latest_observation_updated_at
FROM v_profile_tag_observation_semantics
GROUP BY
  subject_type,
  subject_id,
  subject_entity_id,
  layer_code,
  layer_name,
  dimension_code,
  dimension_name;

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
  ('field_v_subject_pls_dimension_features_subject_type', 'v_subject_pls_dimension_features', 'subject_type', '主体类型', '被聚合画像的对象类型。', '用于区分用户、账号、人群、商品或样例主体。', 'sample_subject', 'DataBase/migrations/013_create_v_subject_pls_dimension_features.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_dimension_features_subject_id', 'v_subject_pls_dimension_features', 'subject_id', '主体ID', '被聚合画像对象的业务ID。', '模型或产品可按该ID读取PLS维度特征。', 'pls_demo_beauty_sensitive_audience', 'DataBase/migrations/013_create_v_subject_pls_dimension_features.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_dimension_features_subject_entity_id', 'v_subject_pls_dimension_features', 'subject_entity_id', '主体实体ID', '可选的统一实体ID。', '用于和 AgentHarness entities 表中的对象打通。', 'ent_module_pls_profile', 'DataBase/migrations/013_create_v_subject_pls_dimension_features.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_dimension_features_layer_code', 'v_subject_pls_dimension_features', 'layer_code', 'PLS层级代码', '聚合特征所属的P/L/S层。', '用于按层读取画像特征。', 'S', 'DataBase/migrations/013_create_v_subject_pls_dimension_features.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_dimension_features_layer_name', 'v_subject_pls_dimension_features', 'layer_name', 'PLS层级名称', 'PLS层级中文名。', '帮助业务用户理解特征层级。', '瞬时应激频率', 'DataBase/migrations/013_create_v_subject_pls_dimension_features.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_dimension_features_dimension_code', 'v_subject_pls_dimension_features', 'dimension_code', '维度代码', 'PLS九维机器代码。', '供模型、规则和程序稳定引用。', 'S_CONVERSION_FRICTION', 'DataBase/migrations/013_create_v_subject_pls_dimension_features.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_dimension_features_dimension_name', 'v_subject_pls_dimension_features', 'dimension_name', '维度名称', 'PLS九维中文名。', '表示该行是主体在某个PLS维度上的聚合特征。', '转化决策摩擦', 'DataBase/migrations/013_create_v_subject_pls_dimension_features.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_dimension_features_observation_count', 'v_subject_pls_dimension_features', 'observation_count', '观测数量', '该主体在该PLS维度下命中的标签观测条数。', '用于衡量该维度证据数量。', '2', 'DataBase/migrations/013_create_v_subject_pls_dimension_features.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_dimension_features_total_weight', 'v_subject_pls_dimension_features', 'total_weight', '总权重', '该主体在该PLS维度下所有观测权重之和。', '可作为主体级PLS维度强度特征。', '1.8', 'DataBase/migrations/013_create_v_subject_pls_dimension_features.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_dimension_features_avg_weight', 'v_subject_pls_dimension_features', 'avg_weight', '平均权重', '该主体在该PLS维度下观测权重平均值。', '用于衡量单条证据的平均强度。', '0.9', 'DataBase/migrations/013_create_v_subject_pls_dimension_features.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_dimension_features_max_weight', 'v_subject_pls_dimension_features', 'max_weight', '最大权重', '该主体在该PLS维度下最强一条观测权重。', '可作为该维度的峰值信号。', '0.92', 'DataBase/migrations/013_create_v_subject_pls_dimension_features.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_dimension_features_platform_count', 'v_subject_pls_dimension_features', 'platform_count', '平台数量', '该维度证据来自多少个平台。', '用于判断特征是否跨平台一致。', '1', 'DataBase/migrations/013_create_v_subject_pls_dimension_features.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_dimension_features_platforms', 'v_subject_pls_dimension_features', 'platforms', '平台列表', '该维度证据来源平台列表。', '用于展示或调试平台来源。', '天猫,抖音', 'DataBase/migrations/013_create_v_subject_pls_dimension_features.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_dimension_features_tag_type_count', 'v_subject_pls_dimension_features', 'tag_type_count', '标签类型数量', '该维度下命中的不同标签类型数。', '用于衡量该维度证据覆盖面。', '2', 'DataBase/migrations/013_create_v_subject_pls_dimension_features.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_dimension_features_leaf_label_count', 'v_subject_pls_dimension_features', 'leaf_label_count', '标签值数量', '该维度下命中的不同标签值数。', '用于衡量该维度标签多样性。', '2', 'DataBase/migrations/013_create_v_subject_pls_dimension_features.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_dimension_features_first_observed_at', 'v_subject_pls_dimension_features', 'first_observed_at', '首次观测时间', '该主体该维度最早观测时间。', '用于时间窗分析和新鲜度判断。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/013_create_v_subject_pls_dimension_features.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_dimension_features_last_observed_at', 'v_subject_pls_dimension_features', 'last_observed_at', '最近观测时间', '该主体该维度最近观测时间。', '用于时间窗分析和标签衰减。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/013_create_v_subject_pls_dimension_features.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_dimension_features_latest_observation_updated_at', 'v_subject_pls_dimension_features', 'latest_observation_updated_at', '最近观测更新时间', '该聚合特征来源观测的最近更新时间。', '用于判断聚合特征是否需要刷新。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/013_create_v_subject_pls_dimension_features.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z');
