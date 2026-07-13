CREATE VIEW IF NOT EXISTS v_pls_channel_profile_overview AS
SELECT
  objects.workspace_id,
  objects.canonical_object_key,
  objects.object_type,
  objects.target_object,
  objects.display_name,
  objects.platform_name,
  objects.platform_type,
  objects.entity_status,
  objects.data_version,
  objects.source_batch_id,
  objects.generated_at AS object_generated_at,
  objects.time_window AS object_time_window,
  objects.manual_review_status,
  objects.possible_duplicate,
  objects.quality_flags_json AS object_quality_flags_json,
  objects.entity_attributes_json,
  audience.profile_id AS audience_profile_id,
  audience.time_window AS audience_time_window,
  audience.sample_size AS audience_sample_size,
  audience.confidence AS audience_confidence,
  COALESCE(json_array_length(audience.tags_json), 0) AS audience_tag_count,
  COALESCE(json_array_length(audience.unmapped_fields_json), 0) AS audience_unmapped_field_count,
  audience.tags_json AS audience_tags_json,
  audience.unmapped_fields_json AS audience_unmapped_fields_json,
  audience.quality_flags_json AS audience_quality_flags_json,
  product_fit.profile_id AS product_fit_profile_id,
  product_fit.source AS product_fit_source,
  product_fit.time_window AS product_fit_time_window,
  product_fit.sample_size AS product_fit_sample_size,
  product_fit.confidence AS product_fit_confidence,
  COALESCE(json_array_length(product_fit.fit_categories_json), 0) AS fit_category_count,
  COALESCE(json_array_length(product_fit.fit_price_bands_json), 0) AS fit_price_band_count,
  COALESCE(json_array_length(product_fit.fit_styles_json), 0) AS fit_style_count,
  COALESCE(json_array_length(product_fit.fit_occasions_json), 0) AS fit_occasion_count,
  COALESCE(json_array_length(product_fit.fit_launch_types_json), 0) AS fit_launch_type_count,
  COALESCE(json_array_length(product_fit.evidence_json), 0) AS product_fit_evidence_count,
  product_fit.fit_categories_json,
  product_fit.fit_price_bands_json,
  product_fit.fit_styles_json,
  product_fit.fit_occasions_json,
  product_fit.fit_launch_types_json,
  product_fit.evidence_json AS product_fit_evidence_json,
  product_fit.quality_flags_json AS product_fit_quality_flags_json,
  CASE WHEN audience.id IS NOT NULL THEN 1 ELSE 0 END AS has_audience_profile,
  CASE WHEN product_fit.id IS NOT NULL THEN 1 ELSE 0 END AS has_product_fit_profile,
  CASE
    WHEN audience.id IS NOT NULL AND product_fit.id IS NOT NULL THEN 'complete'
    WHEN audience.id IS NOT NULL AND product_fit.id IS NULL THEN 'audience_only'
    WHEN audience.id IS NULL AND product_fit.id IS NOT NULL THEN 'product_fit_only'
    ELSE 'object_only'
  END AS profile_coverage_status
FROM pls_channel_objects objects
LEFT JOIN pls_audience_profiles audience
  ON audience.workspace_id = objects.workspace_id
  AND audience.canonical_object_key = objects.canonical_object_key
  AND audience.data_version = objects.data_version
  AND audience.status = 'active'
LEFT JOIN pls_product_fit_profiles product_fit
  ON product_fit.workspace_id = objects.workspace_id
  AND product_fit.canonical_object_key = objects.canonical_object_key
  AND product_fit.data_version = objects.data_version
  AND product_fit.status = 'active'
WHERE objects.status = 'active';

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
  ('field_v_pls_channel_profile_overview_workspace_id', 'v_pls_channel_profile_overview', 'workspace_id', '工作空间ID', '来源 PLS 工作空间标识。', '用于隔离不同业务空间或客户空间的渠道画像概览。', 'ws_demo', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_canonical_object_key', 'v_pls_channel_profile_overview', 'canonical_object_key', '标准对象键', 'PLS 渠道对象的标准业务键。', '用于统一引用渠道对象、人群画像和商品适配画像。', 'account:mock_account_douyin_style', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_object_type', 'v_pls_channel_profile_overview', 'object_type', '对象类型', '渠道画像中的对象类型。', '用于区分平台、商圈、店铺、账号、活动和业务场景。', 'account', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_target_object', 'v_pls_channel_profile_overview', 'target_object', '目标对象模型', 'PLS 前端或后端使用的目标对象模型名称。', '用于判断该记录是渠道实体、活动还是业务场景。', 'ChannelEntity', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_display_name', 'v_pls_channel_profile_overview', 'display_name', '展示名称', '前端展示给业务用户看的对象名称。', '用于渠道画像列表、详情页和人工复核。', 'Mock Douyin Style Account', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_platform_name', 'v_pls_channel_profile_overview', 'platform_name', '平台名称', '对象所属平台名称。', '用于区分 Douyin、Tmall、JD 等平台来源。', 'Douyin', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_platform_type', 'v_pls_channel_profile_overview', 'platform_type', '平台类型', '平台或渠道的业务类型。', '用于区分内容电商、传统电商、线下零售等渠道形态。', 'content_ecommerce', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_entity_status', 'v_pls_channel_profile_overview', 'entity_status', '对象状态', '来源业务对象当前是否有效。', '用于过滤停用或归档的渠道对象。', 'active', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_data_version', 'v_pls_channel_profile_overview', 'data_version', '数据版本', '当前渠道画像概览所对应的数据版本。', '用于版本隔离和回溯。', 'v_channel_object_library_mock_20260706', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_source_batch_id', 'v_pls_channel_profile_overview', 'source_batch_id', '来源批次ID', '产生该渠道对象记录的导入批次。', '用于按批次审计、撤回或重新导入。', 'batch_channel_object_library_mock_20260706', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_object_generated_at', 'v_pls_channel_profile_overview', 'object_generated_at', '对象生成时间', '渠道对象来源数据生成或导出的时间。', '用于判断对象主数据新鲜度。', '2026-07-06T00:00:00Z', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_object_time_window', 'v_pls_channel_profile_overview', 'object_time_window', '对象时间窗口', '渠道对象或活动本身覆盖的业务时间范围。', '用于区分活动周期或静态对象。', '2026-06-01/2026-06-20', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_manual_review_status', 'v_pls_channel_profile_overview', 'manual_review_status', '人工复核状态', '对象当前的人工复核状态。', '用于控制对象是否可以进入正式画像和匹配流程。', 'unreviewed', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_possible_duplicate', 'v_pls_channel_profile_overview', 'possible_duplicate', '疑似重复', '该对象是否被来源流程标记为疑似重复。', '用于进入人工复核或去重流程。', '1', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_object_quality_flags_json', 'v_pls_channel_profile_overview', 'object_quality_flags_json', '对象质量标记JSON', '渠道对象来源流程给出的质量标记。', '用于识别样例对象、生成键待复核、疑似重复等问题。', '["mock_sample"]', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_entity_attributes_json', 'v_pls_channel_profile_overview', 'entity_attributes_json', '对象属性JSON', '不同对象类型的扩展属性。', '用于保存账号内容形式、店铺类型、商圈半径、活动标签等结构化补充信息。', '{"contentFormats":["short_video","live"]}', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_audience_profile_id', 'v_pls_channel_profile_overview', 'audience_profile_id', '人群画像ID', '关联的人群画像快照ID。', '用于定位该渠道对象的人群画像来源记录。', 'audience_account_mock_001', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_audience_time_window', 'v_pls_channel_profile_overview', 'audience_time_window', '人群画像时间窗口', '人群画像统计覆盖的闭合日期窗口。', '用于理解画像反映的是哪个时间段的人群结构。', '2026-06-01/2026-06-30', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_audience_sample_size', 'v_pls_channel_profile_overview', 'audience_sample_size', '人群画像样本量', '生成该人群画像所依据的样本数量。', '用于判断画像可信度和统计稳定性。', '1000', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_audience_confidence', 'v_pls_channel_profile_overview', 'audience_confidence', '人群画像置信度', '人群画像整体置信度，范围0到1。', '用于判断画像是否适合进入正式匹配或模型消费。', '0.82', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_audience_tag_count', 'v_pls_channel_profile_overview', 'audience_tag_count', '人群标签数', '该对象人群画像包含的标签数量。', '用于快速判断人群画像丰富度。', '2', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_audience_unmapped_field_count', 'v_pls_channel_profile_overview', 'audience_unmapped_field_count', '未映射字段数', '该对象人群画像中暂未映射字段数量。', '用于快速识别词表或映射缺口。', '1', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_audience_tags_json', 'v_pls_channel_profile_overview', 'audience_tags_json', '人群标签JSON', '人群画像标签分数数组。', '用于查看该渠道对象面对什么样的人群。', '[{"tagId":"demo.age_25_34","score":0.64}]', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_audience_unmapped_fields_json', 'v_pls_channel_profile_overview', 'audience_unmapped_fields_json', '人群未映射字段JSON', '来源里暂时不能映射到标准画像标签的字段。', '用于保留长尾标签、异常字段或待补充词表内容。', '[{"sourceField":"mock_interest_long_tail"}]', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_audience_quality_flags_json', 'v_pls_channel_profile_overview', 'audience_quality_flags_json', '人群画像质量标记JSON', '人群画像来源流程给出的质量标记。', '用于识别样例数据、缺失谱系、未审批标签等质量问题。', '["mock_sample"]', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_product_fit_profile_id', 'v_pls_channel_profile_overview', 'product_fit_profile_id', '商品适配画像ID', '关联的商品适配画像快照ID。', '用于定位该渠道对象的商品适配来源记录。', 'product_fit_account_mock_001', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_product_fit_source', 'v_pls_channel_profile_overview', 'product_fit_source', '商品适配来源', '商品适配画像来源。', '用于区分用户导入、表现派生和人工配置。', 'user_imported', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_product_fit_time_window', 'v_pls_channel_profile_overview', 'product_fit_time_window', '商品适配时间窗口', '商品适配画像统计覆盖的日期窗口。', '用于理解适配判断基于哪个时间段；人工配置可以为空。', '2026-06-01/2026-06-30', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_product_fit_sample_size', 'v_pls_channel_profile_overview', 'product_fit_sample_size', '商品适配样本量', '生成该商品适配画像所依据的样本数量。', '用于判断适配结论的统计稳定性；人工配置可以为空。', '320', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_product_fit_confidence', 'v_pls_channel_profile_overview', 'product_fit_confidence', '商品适配置信度', '商品适配画像整体置信度，范围0到1。', '用于判断商品适配画像是否适合进入正式匹配或模型消费。', '0.78', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_fit_category_count', 'v_pls_channel_profile_overview', 'fit_category_count', '适合品类数', '商品适配画像中的适合品类数量。', '用于快速判断商品适配覆盖范围。', '2', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_fit_price_band_count', 'v_pls_channel_profile_overview', 'fit_price_band_count', '适合价格带数', '商品适配画像中的适合价格带数量。', '用于快速判断价格带覆盖范围。', '1', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_fit_style_count', 'v_pls_channel_profile_overview', 'fit_style_count', '适合风格数', '商品适配画像中的适合风格数量。', '用于快速判断风格覆盖范围。', '1', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_fit_occasion_count', 'v_pls_channel_profile_overview', 'fit_occasion_count', '适合使用场景数', '商品适配画像中的适合使用场景数量。', '用于快速判断场景覆盖范围。', '1', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_fit_launch_type_count', 'v_pls_channel_profile_overview', 'fit_launch_type_count', '适合上新类型数', '商品适配画像中的适合上新类型数量。', '用于快速判断运营动作覆盖范围。', '1', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_product_fit_evidence_count', 'v_pls_channel_profile_overview', 'product_fit_evidence_count', '商品适配证据数', '支撑商品适配画像的证据数量。', '用于快速判断适配结论证据强度。', '1', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_fit_categories_json', 'v_pls_channel_profile_overview', 'fit_categories_json', '适合品类JSON', '该渠道对象适合销售的商品品类数组。', '用于商品和渠道匹配时判断品类适配度。', '["apparel","top"]', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_fit_price_bands_json', 'v_pls_channel_profile_overview', 'fit_price_bands_json', '适合价格带JSON', '该渠道对象适合销售的商品价格带数组。', '用于商品定价和渠道承接能力匹配。', '["mid"]', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_fit_styles_json', 'v_pls_channel_profile_overview', 'fit_styles_json', '适合风格JSON', '该渠道对象适合销售的商品风格数组。', '用于风格心智、内容调性和渠道匹配。', '["minimal"]', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_fit_occasions_json', 'v_pls_channel_profile_overview', 'fit_occasions_json', '适合使用场景JSON', '该渠道对象适合承接的商品使用场景数组。', '用于场景化推荐和渠道适配解释。', '["work"]', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_fit_launch_types_json', 'v_pls_channel_profile_overview', 'fit_launch_types_json', '适合上新类型JSON', '该渠道对象适合的商品生命周期或运营动作数组。', '用于判断新品首发、日常补货、清仓等场景是否适配。', '["new_product_launch"]', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_product_fit_evidence_json', 'v_pls_channel_profile_overview', 'product_fit_evidence_json', '商品适配证据JSON', '支撑商品适配画像的证据数组。', '用于解释适配结论来自导入、表现数据、人工理由还是模型判断。', '[{"type":"mock_imported_profile"}]', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_product_fit_quality_flags_json', 'v_pls_channel_profile_overview', 'product_fit_quality_flags_json', '商品适配质量标记JSON', '商品适配画像来源流程给出的质量标记。', '用于识别样例数据、人工配置无统计样本等质量问题。', '["mock_sample"]', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_has_audience_profile', 'v_pls_channel_profile_overview', 'has_audience_profile', '是否有人群画像', '该渠道对象是否已经关联人群画像。', '用于快速筛选画像完整度。', '1', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_has_product_fit_profile', 'v_pls_channel_profile_overview', 'has_product_fit_profile', '是否有商品适配画像', '该渠道对象是否已经关联商品适配画像。', '用于快速筛选画像完整度。', '1', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('field_v_pls_channel_profile_overview_profile_coverage_status', 'v_pls_channel_profile_overview', 'profile_coverage_status', '画像覆盖状态', '该渠道对象的人群画像和商品适配画像覆盖情况。', '用于识别完整画像、仅有人群画像、仅有商品适配画像或只有对象主数据。', 'complete', 'DataBase/migrations/019_create_v_pls_channel_profile_overview.sql', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z');
