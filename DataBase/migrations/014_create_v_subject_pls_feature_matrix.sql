CREATE VIEW IF NOT EXISTS v_subject_pls_feature_matrix AS
SELECT
  subject_type,
  subject_id,
  subject_entity_id,
  COUNT(DISTINCT dimension_code) AS active_dimension_count,
  SUM(observation_count) AS total_observation_count,
  ROUND(SUM(total_weight), 6) AS total_feature_weight,
  MAX(platform_count) AS max_dimension_platform_count,
  MIN(first_observed_at) AS first_observed_at,
  MAX(last_observed_at) AS last_observed_at,
  ROUND(SUM(CASE WHEN dimension_code = 'P_DEMOGRAPHICS' THEN total_weight ELSE 0 END), 6) AS p_demographics_score,
  ROUND(SUM(CASE WHEN dimension_code = 'P_PURCHASING_POWER' THEN total_weight ELSE 0 END), 6) AS p_purchasing_power_score,
  ROUND(SUM(CASE WHEN dimension_code = 'P_IDENTITY_CLUSTER' THEN total_weight ELSE 0 END), 6) AS p_identity_cluster_score,
  ROUND(SUM(CASE WHEN dimension_code = 'L_CONTENT_VISUAL_MIND' THEN total_weight ELSE 0 END), 6) AS l_content_visual_mind_score,
  ROUND(SUM(CASE WHEN dimension_code = 'L_INNOVATION_BRAND_MIND' THEN total_weight ELSE 0 END), 6) AS l_innovation_brand_mind_score,
  ROUND(SUM(CASE WHEN dimension_code = 'L_LIFESTYLE' THEN total_weight ELSE 0 END), 6) AS l_lifestyle_score,
  ROUND(SUM(CASE WHEN dimension_code = 'S_PRICE_INCENTIVE_RESPONSE' THEN total_weight ELSE 0 END), 6) AS s_price_incentive_response_score,
  ROUND(SUM(CASE WHEN dimension_code = 'S_CONVERSION_FRICTION' THEN total_weight ELSE 0 END), 6) AS s_conversion_friction_score,
  ROUND(SUM(CASE WHEN dimension_code = 'S_ENVIRONMENT' THEN total_weight ELSE 0 END), 6) AS s_environment_score
FROM v_subject_pls_dimension_features
GROUP BY
  subject_type,
  subject_id,
  subject_entity_id;

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
  ('field_v_subject_pls_feature_matrix_subject_type', 'v_subject_pls_feature_matrix', 'subject_type', '主体类型', '被聚合画像的对象类型。', '用于区分用户、账号、人群、商品或样例主体。', 'sample_subject', 'DataBase/migrations/014_create_v_subject_pls_feature_matrix.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_feature_matrix_subject_id', 'v_subject_pls_feature_matrix', 'subject_id', '主体ID', '被聚合画像对象的业务ID。', '模型、报表和画像卡片可按该ID读取九维特征。', 'pls_demo_beauty_sensitive_audience', 'DataBase/migrations/014_create_v_subject_pls_feature_matrix.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_feature_matrix_subject_entity_id', 'v_subject_pls_feature_matrix', 'subject_entity_id', '主体实体ID', '可选的统一实体ID。', '用于和 AgentHarness entities 表中的对象打通。', 'ent_module_pls_profile', 'DataBase/migrations/014_create_v_subject_pls_feature_matrix.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_feature_matrix_active_dimension_count', 'v_subject_pls_feature_matrix', 'active_dimension_count', '命中维度数', '该主体至少有观测命中的PLS维度数量。', '用于衡量画像覆盖了多少个PLS维度。', '3', 'DataBase/migrations/014_create_v_subject_pls_feature_matrix.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_feature_matrix_total_observation_count', 'v_subject_pls_feature_matrix', 'total_observation_count', '总观测数', '该主体所有PLS维度下的标签观测总数。', '用于衡量画像证据数量。', '12', 'DataBase/migrations/014_create_v_subject_pls_feature_matrix.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_feature_matrix_total_feature_weight', 'v_subject_pls_feature_matrix', 'total_feature_weight', '总特征权重', '该主体九维特征分数的总和。', '用于衡量整体画像信号强度。', '1.8', 'DataBase/migrations/014_create_v_subject_pls_feature_matrix.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_feature_matrix_max_dimension_platform_count', 'v_subject_pls_feature_matrix', 'max_dimension_platform_count', '最大维度平台数', '该主体任一维度最多来自几个平台。', '用于判断是否存在跨平台共同支撑的维度。', '2', 'DataBase/migrations/014_create_v_subject_pls_feature_matrix.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_feature_matrix_first_observed_at', 'v_subject_pls_feature_matrix', 'first_observed_at', '首次观测时间', '该主体最早标签观测时间。', '用于时间窗分析和新鲜度判断。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/014_create_v_subject_pls_feature_matrix.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_feature_matrix_last_observed_at', 'v_subject_pls_feature_matrix', 'last_observed_at', '最近观测时间', '该主体最近标签观测时间。', '用于时间窗分析和标签衰减。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/014_create_v_subject_pls_feature_matrix.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_feature_matrix_p_demographics_score', 'v_subject_pls_feature_matrix', 'p_demographics_score', '基础人口学分数', '主体在基础人口学维度上的聚合权重。', 'P层静态社会坐标中的基础人口学特征分。', '0.73', 'DataBase/migrations/014_create_v_subject_pls_feature_matrix.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_feature_matrix_p_purchasing_power_score', 'v_subject_pls_feature_matrix', 'p_purchasing_power_score', '社会资产与购买力分数', '主体在社会资产与购买力维度上的聚合权重。', '用于表示消费能力、会员等级、价值水位等信号。', '1.0', 'DataBase/migrations/014_create_v_subject_pls_feature_matrix.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_feature_matrix_p_identity_cluster_score', 'v_subject_pls_feature_matrix', 'p_identity_cluster_score', '综合身份聚类分数', '主体在综合身份聚类维度上的聚合权重。', '用于表示家庭、职业、圈层身份等综合人群簇信号。', '0.0', 'DataBase/migrations/014_create_v_subject_pls_feature_matrix.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_feature_matrix_l_content_visual_mind_score', 'v_subject_pls_feature_matrix', 'l_content_visual_mind_score', '内容与视觉心智分数', '主体在内容与视觉心智维度上的聚合权重。', '用于表示内容兴趣、媒体偏好、审美偏好等信号。', '0.86', 'DataBase/migrations/014_create_v_subject_pls_feature_matrix.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_feature_matrix_l_innovation_brand_mind_score', 'v_subject_pls_feature_matrix', 'l_innovation_brand_mind_score', '创新与品牌心智分数', '主体在创新与品牌心智维度上的聚合权重。', '用于表示品牌、品质、先锋度、新品接受度等信号。', '0.0', 'DataBase/migrations/014_create_v_subject_pls_feature_matrix.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_feature_matrix_l_lifestyle_score', 'v_subject_pls_feature_matrix', 'l_lifestyle_score', '圈层生活方式分数', '主体在圈层生活方式维度上的聚合权重。', '用于表示品类、兴趣、生活方式和场景偏好。', '0.81', 'DataBase/migrations/014_create_v_subject_pls_feature_matrix.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_feature_matrix_s_price_incentive_response_score', 'v_subject_pls_feature_matrix', 's_price_incentive_response_score', '价格与利益应激分数', '主体在价格与利益应激维度上的聚合权重。', '用于表示优惠、折扣、价格刺激敏感度。', '0.95', 'DataBase/migrations/014_create_v_subject_pls_feature_matrix.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_feature_matrix_s_conversion_friction_score', 'v_subject_pls_feature_matrix', 's_conversion_friction_score', '转化决策摩擦分数', '主体在转化决策摩擦维度上的聚合权重。', '用于表示功效、颜色、尺码、点击、频次等临门选择条件。', '1.8', 'DataBase/migrations/014_create_v_subject_pls_feature_matrix.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_subject_pls_feature_matrix_s_environment_score', 'v_subject_pls_feature_matrix', 's_environment_score', '物理/数字环境分数', '主体在物理/数字环境维度上的聚合权重。', '用于表示设备、时段、城市限制、数字触达环境等信号。', '0.8', 'DataBase/migrations/014_create_v_subject_pls_feature_matrix.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z');
