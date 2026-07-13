CREATE VIEW IF NOT EXISTS v_pls_audience_tag_semantics AS
SELECT
  profiles.workspace_id,
  profiles.profile_id,
  profiles.canonical_object_key,
  objects.object_type,
  objects.display_name,
  objects.platform_name,
  objects.platform_type,
  profiles.profile_stage,
  profiles.source,
  profiles.source_batch_id,
  profiles.data_version,
  profiles.generated_at,
  profiles.time_window,
  profiles.sample_size AS profile_sample_size,
  profiles.confidence AS profile_confidence,
  json_extract(tag.value, '$.tagId') AS tag_id,
  mappings.tag_namespace,
  mappings.tag_label_zh,
  CAST(json_extract(tag.value, '$.score') AS REAL) AS tag_score,
  CAST(json_extract(tag.value, '$.confidence') AS REAL) AS tag_confidence,
  json_extract(tag.value, '$.source') AS tag_source,
  CAST(json_extract(tag.value, '$.sampleSize') AS INTEGER) AS tag_sample_size,
  json_extract(tag.value, '$.timeWindow') AS tag_time_window,
  dimensions.layer_code,
  dimensions.layer_name,
  dimensions.dimension_code,
  dimensions.dimension_name,
  dimensions.dimension_definition,
  dimensions.business_strategy,
  mappings.confidence AS mapping_confidence,
  mappings.mapping_method,
  mappings.rationale AS mapping_rationale,
  mappings.id AS audience_tag_mapping_id,
  profiles.id AS audience_profile_row_id,
  profiles.updated_at AS profile_updated_at,
  mappings.updated_at AS mapping_updated_at
FROM pls_audience_profiles profiles
JOIN pls_channel_objects objects
  ON objects.workspace_id = profiles.workspace_id
  AND objects.canonical_object_key = profiles.canonical_object_key
  AND objects.data_version = profiles.data_version
  AND objects.status = 'active'
JOIN json_each(profiles.tags_json) tag
JOIN pls_audience_tag_dimension_mappings mappings
  ON mappings.tag_id = json_extract(tag.value, '$.tagId')
  AND mappings.status = 'active'
  AND mappings.mapping_status = 'approved'
JOIN pls_semantic_dimensions dimensions
  ON dimensions.id = mappings.dimension_id
WHERE profiles.status = 'active';

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
  ('field_v_pls_audience_tag_semantics_workspace_id', 'v_pls_audience_tag_semantics', 'workspace_id', '工作空间ID', '来源 PLS 工作空间标识。', '用于隔离不同业务空间或客户空间的人群标签语义。', 'ws_demo', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_profile_id', 'v_pls_audience_tag_semantics', 'profile_id', '人群画像ID', 'PLS 来源人群画像快照ID。', '用于定位该标签来自哪条人群画像。', 'audience_account_mock_001', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_canonical_object_key', 'v_pls_audience_tag_semantics', 'canonical_object_key', '标准对象键', '该人群标签所属的 PLS 渠道对象键。', '用于按渠道对象聚合标签和 PLS 维度特征。', 'account:mock_account_douyin_style', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_object_type', 'v_pls_audience_tag_semantics', 'object_type', '对象类型', '渠道画像中的对象类型。', '用于区分平台、商圈、店铺、账号、活动和业务场景。', 'account', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_display_name', 'v_pls_audience_tag_semantics', 'display_name', '展示名称', '前端展示给业务用户看的对象名称。', '用于人群标签解释和渠道画像详情。', 'Mock Douyin Style Account', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_platform_name', 'v_pls_audience_tag_semantics', 'platform_name', '平台名称', '对象所属平台名称。', '用于区分 Douyin、Tmall、JD 等平台来源。', 'Douyin', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_platform_type', 'v_pls_audience_tag_semantics', 'platform_type', '平台类型', '平台或渠道的业务类型。', '用于区分内容电商、传统电商、线下零售等渠道形态。', 'content_ecommerce', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_profile_stage', 'v_pls_audience_tag_semantics', 'profile_stage', '画像阶段', '说明这条标签属于哪个画像阶段。', '当前固定为 channel_audience，表示渠道人群画像。', 'channel_audience', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_source', 'v_pls_audience_tag_semantics', 'source', '画像来源', '该人群画像来自哪个导入包、工具或报告。', '用于追踪画像数据入口。', 'mock_channel_object_library_sample', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_source_batch_id', 'v_pls_audience_tag_semantics', 'source_batch_id', '来源批次ID', '产生该画像记录的导入批次。', '用于按批次审计、撤回或重新导入。', 'batch_channel_object_library_mock_20260706', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_data_version', 'v_pls_audience_tag_semantics', 'data_version', '数据版本', '本次导入或生成的数据版本。', '用于版本隔离和回溯。', 'v_channel_object_library_mock_20260706', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_generated_at', 'v_pls_audience_tag_semantics', 'generated_at', '生成时间', '来源画像数据生成或导出的时间。', '用于判断画像数据新鲜度。', '2026-07-06T00:00:00Z', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_time_window', 'v_pls_audience_tag_semantics', 'time_window', '画像时间窗口', '人群画像统计覆盖的闭合日期窗口。', '用于理解标签反映的是哪个时间段的人群结构。', '2026-06-01/2026-06-30', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_profile_sample_size', 'v_pls_audience_tag_semantics', 'profile_sample_size', '画像样本量', '生成该人群画像所依据的样本数量。', '用于判断画像整体可信度和统计稳定性。', '1000', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_profile_confidence', 'v_pls_audience_tag_semantics', 'profile_confidence', '画像置信度', '人群画像整体置信度，范围0到1。', '用于判断画像是否适合进入正式匹配或模型消费。', '0.82', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_tag_id', 'v_pls_audience_tag_semantics', 'tag_id', '画像标签ID', '从 tags_json 展开的 PLS 渠道画像标签ID。', '用于连接渠道画像标签和 PLS 三层九维映射。', 'demo.age_25_34', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_tag_namespace', 'v_pls_audience_tag_semantics', 'tag_namespace', '标签命名空间', 'tag_id 点号前的标签大类。', '用于按 demo、channel、style、occasion、price 等标签族管理映射。', 'demo', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_tag_label_zh', 'v_pls_audience_tag_semantics', 'tag_label_zh', '标签中文名', '面向业务用户展示的标签中文名称。', '降低非技术用户理解英文 tagId 的成本。', '25-34岁', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_tag_score', 'v_pls_audience_tag_semantics', 'tag_score', '标签分数', '该人群画像标签的强度分数。', '后续可按该分数聚合为渠道对象级 PLS 维度特征。', '0.64', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_tag_confidence', 'v_pls_audience_tag_semantics', 'tag_confidence', '标签置信度', '该标签本身的来源或映射置信度。', '用于区分强弱证据和后续是否需要降权。', '0.86', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_tag_source', 'v_pls_audience_tag_semantics', 'tag_source', '标签来源', '该标签在 tags_json 中记录的来源。', '用于追踪标签来源工具、报告或导入包。', 'mock_channel_object_library_sample', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_tag_sample_size', 'v_pls_audience_tag_semantics', 'tag_sample_size', '标签样本量', '该标签级别记录的样本量。', '用于判断单个标签分数的统计稳定性。', '1000', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_tag_time_window', 'v_pls_audience_tag_semantics', 'tag_time_window', '标签时间窗口', '该标签级别记录的统计时间窗口。', '用于判断单个标签分数反映的时间范围。', '2026-06-01/2026-06-30', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_layer_code', 'v_pls_audience_tag_semantics', 'layer_code', 'PLS层级代码', '该人群标签映射到的 P/L/S 层。', '用于按静态基底、动态心智、临场刺激聚合画像。', 'P', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_layer_name', 'v_pls_audience_tag_semantics', 'layer_name', 'PLS层级名称', 'PLS层级中文名。', '让业务用户理解该标签进入哪一层画像逻辑。', '静态人群基座', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_dimension_code', 'v_pls_audience_tag_semantics', 'dimension_code', '维度代码', 'PLS九维机器代码。', '供模型、规则和程序稳定引用。', 'P_DEMOGRAPHICS', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_dimension_name', 'v_pls_audience_tag_semantics', 'dimension_name', '维度名称', 'PLS九维中文名。', '供业务用户理解该标签归入哪个 PLS 维度。', '基础人口学', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_dimension_definition', 'v_pls_audience_tag_semantics', 'dimension_definition', '维度定义', '该 PLS 维度覆盖的业务内涵。', '用于解释标签映射到当前维度的含义。', '生理与年龄基底', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_business_strategy', 'v_pls_audience_tag_semantics', 'business_strategy', '业务策略', '该维度对算法、运营或投放策略的指导意义。', '帮助消费方理解该标签在画像和分层中的用法。', '【P层拦截】：决定商品能否进入该渠道的最低门槛。', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_mapping_confidence', 'v_pls_audience_tag_semantics', 'mapping_confidence', '映射置信度', '标签到 PLS 维度的映射可信度。', '用于判断是否需要抽检或降权。', '0.95', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_mapping_method', 'v_pls_audience_tag_semantics', 'mapping_method', '映射方法', '标签映射的产生方式。', '用于区分种子规则、规则推断、人工复核或导入映射。', 'manual_seed', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_mapping_rationale', 'v_pls_audience_tag_semantics', 'mapping_rationale', '映射理由', '标签映射到当前 PLS 维度的依据。', '用于解释画像特征的语义来源。', '年龄段标签描述基础生理和年龄基底。', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_audience_tag_mapping_id', 'v_pls_audience_tag_semantics', 'audience_tag_mapping_id', '人群标签映射ID', '标签到 PLS 维度的映射记录ID。', '用于回溯 pls_audience_tag_dimension_mappings。', 'patdim_demo_age_25_34', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_audience_profile_row_id', 'v_pls_audience_tag_semantics', 'audience_profile_row_id', '人群画像记录ID', 'AgentHarness 内部人群画像记录ID。', '用于回溯 pls_audience_profiles 源记录。', 'pap_ws_demo_audience_account_mock_001_v20260706', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_profile_updated_at', 'v_pls_audience_tag_semantics', 'profile_updated_at', '画像更新时间', '人群画像记录最近更新时间。', '用于判断事实数据是否刷新。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_audience_tag_semantics_mapping_updated_at', 'v_pls_audience_tag_semantics', 'mapping_updated_at', '映射更新时间', '标签语义映射最近更新时间。', '用于判断语义标准是否刷新。', '2026-07-13T00:00:00.000Z', 'DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z');
