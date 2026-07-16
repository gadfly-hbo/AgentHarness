# PLS 数据库能力接入说明

这份文档说明 PLS 画像模块和 ModelEvol 应该如何消费当前
AgentHarness SQLite 中的 PLS 数据库能力。

## 当前数据库

默认 SQLite 路径：

```text
DataBase/agentharness.sqlite
```

当前正式对象：

| 对象 | 类型 | 行数 | 用途 |
| --- | --- | ---: | --- |
| `platform_tag_catalog` | table | 9702 | 平台原始标签目录，目前包含天猫、抖音、京东标签、用户补充的天猫 AI 服饰需求特征，以及抖音实际可提取补充标签。 |
| `pls_channel_objects` | table | 6 | PLS 渠道画像对象库主数据，当前为 6 类对象样例。 |
| `pls_channel_object_bindings` | table | 4 | PLS 渠道画像对象关系，当前为 4 条样例关系。 |
| `pls_audience_profiles` | table | 3 | PLS 渠道对象人群画像，当前为 3 条样例画像。 |
| `pls_audience_tag_dimension_mappings` | table | 5 | PLS 渠道画像标签到三层九维的映射。 |
| `pls_product_fit_profiles` | table | 2 | PLS 渠道对象商品适配画像，当前为 2 条样例画像。 |
| `pls_tag_type_dimension_mappings` | table | 474 | 已审批的“标签类型 -> PLS维度”映射。 |
| `pls_tag_value_dimension_mappings` | table | 9702 | 已审批的“标签值 -> PLS维度”映射。 |
| `platform_profile_tag_metrics` | table | 0 | 三平台真实画像标签指标长表，承接平台、渠道、店铺、账号、活动、场景等对象的真实画像导入。 |
| `profile_tag_observations` | table | 12 | 主体标签观测事实表。当前是样例数据，后续替换为真实 PLS 观测。 |
| `v_platform_profile_tag_metric_semantics` | view | 0 | 读取真实画像标签指标，并展开平台标签与 PLS 三层九维语义。 |
| `v_platform_profile_channel_dimension_features` | view | 0 | 读取真实画像指标在“渠道对象 + 指标名 + PLS维度”粒度的行式聚合特征。 |
| `v_platform_profile_channel_feature_matrix` | view | 0 | 读取真实画像指标在“渠道对象 + 指标名”粒度的九维宽表特征。 |
| `v_pls_platform_tag_value_semantics` | view | 9702 | 读取平台标签值及其 PLS 语义展开。 |
| `v_profile_tag_observation_semantics` | view | 12 | 读取主体命中的标签，并展开 PLS 语义。 |
| `v_subject_pls_dimension_features` | view | 11 | 读取“主体 + PLS维度”的行式特征。 |
| `v_subject_pls_feature_matrix` | view | 11 | 读取“一主体一行”的九维特征宽表。 |
| `v_pls_channel_profile_overview` | view | 6 | 读取 PLS 渠道画像对象、人群画像和商品适配画像概览。 |
| `v_pls_audience_tag_semantics` | view | 5 | 读取渠道人群画像标签及其 PLS 三层九维语义展开。 |
| `v_pls_channel_dimension_features` | view | 5 | 读取渠道对象级 PLS 维度行式特征。 |
| `v_pls_channel_feature_matrix` | view | 3 | 读取“一渠道对象一行”的九维特征宽表。 |

当前范围：

- 已接入：天猫、抖音、京东。
- 暂不接入：小红书。
- 当前平台标签源文件版本：`DataBase/source_files/platform_tags/v0.1/`。
- 当前三平台真实提取标签汇总版本：`DataBase/docs/platform-tag-pls-summary.html`，
  其中天猫 44 个、京东 38 个、抖音 25 个 tag_type。该汇总的 PLS 分层以
  `OntoBase/pls-ontology-business-calibration.md` 第 9 节为语义权威。
- `AI标签_服饰需求特征` 是用户补充的天猫 AI 标签类型，源文件只保留标签值，不保留原始占比。
- 抖音 HTML 汇总范围使用实际可提取画像标签：
  `DataBase/source_files/platform_profile_extracts/douyin/v0.1/`。
- 三平台真实画像指标导入格式以
  `DataBase/docs/platform-profile-extract-spec-v0.1.md` 为准，第一版采用长表，
  保留 `metric_name`、`metric_unit`、`profile_time_window` 和 `source_batch_id`，
  不在导入时混合占比、TGI、人数、指数或分值。
- 真实画像 CSV 可以通过 HTML console 的“真实画像导入”页面预检和写库，也可以通过
  `DataBase/importers/import_platform_profile_tag_metrics.mjs` 命令行导入器执行。
- “真实画像导入”页面支持单个/多个 CSV 文件，也支持选择整个 CSV 文件夹。正式写库前会对
  `metric_name = 'share'` 的标签值占比按标签类型做归一化处理，归一化后的数值写入
  `metric_value`，原始值保留在 `raw_json.normalization.raw_metric_value`。
- 后续平台调整标签时，应新增版本目录，例如 `v0.2`，不要覆盖 `v0.1`。

## 推荐读取入口

产品和模型读取时优先使用这些 view：

| 需求 | 读取对象 |
| --- | --- |
| 查看渠道画像对象、人群画像和商品适配画像概览 | `v_pls_channel_profile_overview` |
| 查看渠道人群画像标签及其 PLS 维度语义 | `v_pls_audience_tag_semantics` |
| 读取渠道对象级 PLS 维度行特征 | `v_pls_channel_dimension_features` |
| 读取模型可直接消费的渠道对象九维特征 | `v_pls_channel_feature_matrix` |
| 查看真实平台画像标签指标及其 PLS 维度语义 | `v_platform_profile_tag_metric_semantics` |
| 读取真实画像指标的渠道对象级 PLS 维度行特征 | `v_platform_profile_channel_dimension_features` |
| 读取真实画像指标的渠道对象九维特征宽表 | `v_platform_profile_channel_feature_matrix` |
| 查看所有平台标签值及其 PLS 映射 | `v_pls_platform_tag_value_semantics` |
| 解释某个主体具体命中了哪些标签 | `v_profile_tag_observation_semantics` |
| 读取主体级 PLS 维度行特征 | `v_subject_pls_dimension_features` |
| 读取模型可直接消费的一主体一行九维特征 | `v_subject_pls_feature_matrix` |

只向源表写入数据：

| 写入需求 | 写入对象 |
| --- | --- |
| 新增或刷新 PLS 渠道画像对象 | `pls_channel_objects` |
| 新增或刷新 PLS 渠道对象关系 | `pls_channel_object_bindings` |
| 新增或刷新 PLS 渠道人群画像 | `pls_audience_profiles` |
| 新增或修正 PLS 渠道画像标签映射 | `pls_audience_tag_dimension_mappings` |
| 新增或刷新 PLS 渠道商品适配画像 | `pls_product_fit_profiles` |
| 导入天猫、抖音、京东真实人群画像标签指标 | `platform_profile_tag_metrics` |
| 新增真实主体的标签命中记录 | `profile_tag_observations` |
| 单独修正某个标签值的 PLS 维度 | `pls_tag_value_dimension_mappings` |
| 修改已审批的标签类型映射 | `pls_tag_type_dimension_mappings` |

不要直接写入 view。

## 核心消费链路

渠道画像对象主数据链路：

```text
PLS channel object library
  -> pls_channel_objects
  -> pls_channel_object_bindings
  -> pls_audience_profiles
  -> pls_audience_tag_dimension_mappings
  -> v_pls_audience_tag_semantics
  -> v_pls_channel_dimension_features
  -> v_pls_channel_feature_matrix
  -> pls_product_fit_profiles
  -> v_pls_channel_profile_overview
```

PLS 标签语义和主体特征链路：

```text
platform_tag_catalog
  -> pls_tag_value_dimension_mappings
  -> v_pls_platform_tag_value_semantics
  -> profile_tag_observations
  -> v_profile_tag_observation_semantics
  -> v_subject_pls_dimension_features
  -> v_subject_pls_feature_matrix
```

真实平台画像指标链路：

```text
platform profile export files
  -> DataBase/console 真实画像导入页
  -> DataBase/importers/platform_profile_tag_metrics_importer.mjs
  -> platform_profile_tag_metrics
  -> v_platform_profile_tag_metric_semantics
  -> v_platform_profile_channel_dimension_features
  -> v_platform_profile_channel_feature_matrix
```

这条链路用于承接后续从三大平台实际拉取的渠道画像数据。真实导入时只写
`platform_profile_tag_metrics`，下游语义展开和 PLS 维度聚合由 view 统一生成。
导入器会先用 `platform + tag_type + leaf_label` 匹配 `platform_tag_catalog`；
如果匹配到多条目录记录，需要在 CSV 中补充 `platform_tag_catalog_id` 精确指定。

## 常用 SQL

### 1. 按 PLS 维度查找平台标签

```sql
SELECT
  platform,
  tag_type,
  leaf_label,
  layer_name,
  dimension_name,
  confidence
FROM v_pls_platform_tag_value_semantics
WHERE dimension_code = 'S_CONVERSION_FRICTION'
ORDER BY platform, tag_type, leaf_label
LIMIT 100;
```

当产品需要知道“哪些平台标签会贡献到某个 PLS 维度”时，使用这个查询。

### 2. 插入一条真实主体标签观测

```sql
INSERT INTO profile_tag_observations (
  id,
  subject_type,
  subject_id,
  subject_entity_id,
  platform_tag_catalog_id,
  platform,
  tag_type,
  leaf_label,
  observed_value,
  observation_weight,
  observation_source,
  observed_at,
  evidence_ref,
  context_json,
  status
)
SELECT
  'ptobs_real_001',
  'audience_segment',
  'pls_segment_001',
  NULL,
  semantics.platform_tag_catalog_id,
  semantics.platform,
  semantics.tag_type,
  semantics.leaf_label,
  'matched',
  0.87,
  'pls:import',
  '2026-07-13T00:00:00.000Z',
  'pls:batch:001',
  '{"source":"pls_import"}',
  'active'
FROM v_pls_platform_tag_value_semantics semantics
WHERE semantics.platform = '天猫'
  AND semantics.tag_type = '美妆行业-护肤品功效需求'
  AND semantics.leaf_label = '保湿补水';
```

生产环境中，`id` 应由来源系统、批次和业务主键生成，保证稳定可追溯。

### 3. 解释某个主体命中了哪些标签

```sql
SELECT
  subject_id,
  platform,
  tag_type,
  leaf_label,
  observation_weight,
  layer_name,
  dimension_name,
  mapping_confidence,
  mapping_rationale
FROM v_profile_tag_observation_semantics
WHERE subject_id = 'pls_demo_beauty_sensitive_audience'
ORDER BY layer_code, dimension_code, platform, tag_type, leaf_label;
```

画像卡片、业务解释、问题排查时，优先使用这个查询。

### 4. 读取主体维度行特征

```sql
SELECT
  subject_id,
  layer_name,
  dimension_name,
  observation_count,
  total_weight,
  avg_weight,
  max_weight,
  platforms
FROM v_subject_pls_dimension_features
WHERE subject_id = 'pls_demo_beauty_sensitive_audience'
ORDER BY layer_code, dimension_code;
```

当分析需要“一行表示一个主体在一个 PLS 维度上的特征”时，使用这个查询。

### 5. 读取模型可用的九维特征宽表

```sql
SELECT
  subject_id,
  p_demographics_score,
  p_purchasing_power_score,
  p_identity_cluster_score,
  l_content_visual_mind_score,
  l_innovation_brand_mind_score,
  l_lifestyle_score,
  s_price_incentive_response_score,
  s_conversion_friction_score,
  s_environment_score
FROM v_subject_pls_feature_matrix
ORDER BY subject_id;
```

ModelEvol 实验、评分逻辑、报表宽表和画像卡片需要紧凑特征时，优先使用这个查询。

## 字段语义

### `profile_tag_observations`

关键字段：

| 字段 | 含义 |
| --- | --- |
| `subject_type` | 主体类型，例如用户、账号、人群、商品或样例主体。 |
| `subject_id` | 用于聚合特征的业务主体ID。 |
| `platform_tag_catalog_id` | 原始平台标签值引用。 |
| `observed_value` | 可选的原始观测值、等级或命中标记。 |
| `observation_weight` | 观测强度，范围为 0 到 1。 |
| `observation_source` | 来源系统、批次或处理流程。 |
| `observed_at` | 标签观测时间。 |
| `context_json` | 额外来源上下文。 |

### `platform_profile_tag_metrics`

关键字段：

| 字段 | 含义 |
| --- | --- |
| `workspace_id` | PLS 工作空间ID。 |
| `profile_id` | 本次平台画像快照ID，建议由平台、对象、时间窗口和批次稳定生成。 |
| `canonical_object_key` | PLS 统一渠道对象键，例如平台、店铺、账号、活动或场景。 |
| `channel_object_type` | 渠道对象类型：`platform`、`trade_area`、`store`、`account`、`marketing_event`、`business_scenario`。 |
| `channel_object_name` | 渠道对象展示名。 |
| `platform` | 标签来源平台：天猫、抖音、京东。 |
| `platform_tag_catalog_id` | 对应 `platform_tag_catalog` 的标签值ID。 |
| `tag_type` | 平台标签类型名称。 |
| `leaf_label` | 平台标签值名称。 |
| `metric_name` | 指标名称，例如 `share`、`tgi`、`count`、`index`、`score`。 |
| `metric_value` | 指标数值，必须保持同一 `metric_name` 和 `metric_unit` 下可比较。 |
| `metric_unit` | 指标单位，例如 `ratio`、`index`、`person`、`score`。 |
| `profile_time_window` | 画像统计时间窗口。 |
| `sample_size` | 该画像或指标对应的样本量。 |
| `source_file` | 原始导出文件路径或文件名。 |
| `source_batch_id` | 导入批次ID，用于回溯、重跑和隔离版本。 |
| `raw_json` | 原始行 JSON，保留平台原始字段，便于后续补字段和排查。 |

注意：同一对象同一标签可以同时有占比、TGI、人数、指数等多种指标，但必须拆成多行，
不要提前合成一个不可解释的分数。

### `v_platform_profile_channel_feature_matrix`

九个分数字段与 `v_pls_channel_feature_matrix` 一致，但该 view 额外按
`metric_name`、`metric_unit`、`profile_time_window` 和 `source_batch_id` 保持隔离。
模型读取前应先决定使用哪一种指标口径，例如只用 `metric_name = 'share'`
或只用 `metric_name = 'tgi'`，不要跨口径直接求和。

### `pls_channel_objects`

关键字段：

| 字段 | 含义 |
| --- | --- |
| `workspace_id` | PLS 工作空间ID。 |
| `object_type` | 渠道对象类型，例如平台、商圈、店铺、账号、活动或业务场景。 |
| `canonical_object_key` | PLS 统一对象键，后续绑定关系和画像都会引用它。 |
| `object_version_id` | 对象版本ID，用于追踪同一对象在不同数据版本中的状态。 |
| `data_version` | 数据版本，用于版本隔离和回溯。 |
| `source_batch_id` | 来源批次ID，用于导入审计和问题回放。 |
| `entity_attributes_json` | 对象类型相关的扩展属性，例如账号内容形式、商圈半径、店铺类型等。 |
| `quality_flags_json` | 来源质量标记，例如样例数据、生成键待复核等。 |
| `raw_json` | 原始导入 JSON，保留用于审计和字段补充。 |

### `pls_channel_object_bindings`

关键字段：

| 字段 | 含义 |
| --- | --- |
| `workspace_id` | PLS 工作空间ID。 |
| `binding_id` | 来源关系ID，用于和 PLS 原始导入包对齐。 |
| `binding_type` | 关系类型，例如父子关系、活动关联渠道对象、场景关联渠道对象。 |
| `from_canonical_object_key` | 关系起点的 PLS 标准对象键。 |
| `to_canonical_object_key` | 关系终点的 PLS 标准对象键。 |
| `data_version` | 数据版本，确保关系连接的是同一版本的渠道对象。 |
| `quality_flags_json` | 来源关系质量标记。 |
| `raw_json` | 原始导入 JSON，保留用于审计和字段补充。 |

### `pls_audience_profiles`

关键字段：

| 字段 | 含义 |
| --- | --- |
| `profile_id` | PLS 来源人群画像快照ID。 |
| `canonical_object_key` | 该画像所属的渠道对象键。 |
| `profile_stage` | 画像阶段，当前固定为 `channel_audience`。 |
| `time_window` | 画像统计覆盖的闭合日期窗口。 |
| `sample_size` | 生成该画像所依据的样本量。 |
| `confidence` | 画像整体置信度，范围 0 到 1。 |
| `tags_json` | 人群画像标签分数数组。 |
| `unmapped_fields_json` | 来源里暂时无法映射到标准画像标签的字段。 |
| `quality_flags_json` | 画像质量标记。 |
| `raw_json` | 原始导入 JSON，保留用于审计和字段补充。 |

注意：`tags_json` 里的 `tagId` 是 PLS 渠道画像分类标签，例如
`demo.age_25_34`、`channel.short_video`、`style.minimal`、`price.mid`。
它们不是 `platform_tag_catalog` 里的天猫、抖音、京东原始平台标签值。
后续需要单独建立映射层，决定这些标签如何贡献到 PLS 三层九维模型。

### `pls_audience_tag_dimension_mappings`

关键字段：

| 字段 | 含义 |
| --- | --- |
| `tag_id` | PLS 渠道画像体系中的标签ID。 |
| `tag_namespace` | 标签命名空间，例如 `demo`、`channel`、`style`、`occasion`、`price`。 |
| `tag_label_zh` | 标签中文名。 |
| `dimension_id` | 映射到的 PLS 三层九维标准维度。 |
| `mapping_status` | 映射状态。 |
| `confidence` | 映射置信度。 |
| `rationale` | 映射理由。 |

当前样例映射：

| 标签 | PLS维度 |
| --- | --- |
| `demo.age_25_34` | 基础人口学 |
| `channel.short_video` | 物理/数字环境 |
| `style.minimal` | 内容与视觉心智 |
| `occasion.work` | 圈层生活方式 |
| `price.mid` | 社会资产与购买力 |

### `pls_product_fit_profiles`

关键字段：

| 字段 | 含义 |
| --- | --- |
| `profile_id` | PLS 来源商品适配画像快照ID。 |
| `canonical_object_key` | 该商品适配画像所属的渠道对象键。 |
| `source` | 商品适配画像来源，例如用户导入、表现派生或人工配置。 |
| `time_window` | 商品适配画像统计覆盖的日期窗口；人工配置可以为空。 |
| `sample_size` | 生成该画像所依据的样本量；人工配置可以为空。 |
| `confidence` | 商品适配画像整体置信度，范围 0 到 1。 |
| `fit_categories_json` | 适合销售的商品品类数组。 |
| `fit_price_bands_json` | 适合销售的价格带数组。 |
| `fit_styles_json` | 适合销售的商品风格数组。 |
| `fit_occasions_json` | 适合承接的商品使用场景数组。 |
| `fit_launch_types_json` | 适合的商品生命周期或运营动作数组。 |
| `evidence_json` | 支撑商品适配结论的证据数组。 |
| `quality_flags_json` | 商品适配画像质量标记。 |
| `raw_json` | 原始导入 JSON，保留用于审计和字段补充。 |

注意：当 `source = 'manual_config'` 时，`sample_size` 和 `time_window`
可以为空。不要为了字段完整性伪造统计样本量或统计窗口。

### `v_pls_channel_profile_overview`

关键字段：

| 字段 | 含义 |
| --- | --- |
| `canonical_object_key` | PLS 渠道对象标准键。 |
| `object_type` | 渠道对象类型。 |
| `display_name` | 业务展示名称。 |
| `audience_tag_count` | 人群画像标签数量。 |
| `audience_sample_size` | 人群画像样本量。 |
| `audience_confidence` | 人群画像置信度。 |
| `fit_category_count` | 商品适配品类数量。 |
| `product_fit_sample_size` | 商品适配画像样本量；人工配置可以为空。 |
| `product_fit_confidence` | 商品适配画像置信度。 |
| `profile_coverage_status` | 画像覆盖状态：`complete`、`audience_only`、`product_fit_only`、`object_only`。 |

产品前端优先读取这张 view 做渠道画像列表和详情概览；不要直接写入 view。

### `v_pls_audience_tag_semantics`

关键字段：

| 字段 | 含义 |
| --- | --- |
| `canonical_object_key` | PLS 渠道对象标准键。 |
| `display_name` | 业务展示名称。 |
| `tag_id` | 从 `tags_json` 展开的人群标签ID。 |
| `tag_label_zh` | 标签中文名。 |
| `tag_score` | 标签分数。 |
| `tag_confidence` | 标签置信度。 |
| `layer_code` | PLS 层级代码。 |
| `dimension_code` | PLS 维度代码。 |
| `dimension_name` | PLS 维度中文名。 |
| `mapping_confidence` | 标签到维度的映射置信度。 |
| `mapping_rationale` | 映射理由。 |

这张 view 是后续“渠道对象级 PLS 维度特征”的输入面。

### `v_pls_channel_dimension_features`

关键字段：

| 字段 | 含义 |
| --- | --- |
| `canonical_object_key` | PLS 渠道对象标准键。 |
| `dimension_code` | PLS 维度代码。 |
| `dimension_name` | PLS 维度中文名。 |
| `tag_count` | 该渠道对象在该维度下命中的标签数量。 |
| `dimension_score` | 该渠道对象在该维度下的标签分数总和。 |
| `avg_tag_score` | 该维度下标签分数平均值。 |
| `max_tag_score` | 该维度下最大标签分数。 |
| `avg_tag_confidence` | 该维度下平均标签置信度。 |
| `avg_mapping_confidence` | 该维度下平均映射置信度。 |
| `tag_ids` | 支撑该维度的标签ID列表。 |
| `tag_labels_zh` | 支撑该维度的标签中文名列表。 |

当前第一版分数规则：

```text
dimension_score = sum(tag_score)
```

复杂归一化、时间衰减和模型特征变换后续应放在明确的特征工程层，不隐藏在基础 view 里。

### `v_pls_channel_feature_matrix`

九个分数字段：

| 字段 | PLS 维度 |
| --- | --- |
| `p_demographics_score` | 基础人口学 |
| `p_purchasing_power_score` | 社会资产与购买力 |
| `p_identity_cluster_score` | 综合身份聚类 |
| `l_content_visual_mind_score` | 内容与视觉心智 |
| `l_innovation_brand_mind_score` | 创新与品牌心智 |
| `l_lifestyle_score` | 圈层生活方式 |
| `s_price_incentive_response_score` | 价格与利益应激 |
| `s_conversion_friction_score` | 转化决策摩擦 |
| `s_environment_score` | 物理/数字环境 |

这张 view 是 PLS 渠道画像进入 ModelEvol 和货渠匹配的第一版宽表入口。
当前只包含已经有人群标签维度特征的渠道对象；完整对象清单仍读取
`v_pls_channel_profile_overview`。

### `v_subject_pls_feature_matrix`

九个分数字段：

| 字段 | PLS 维度 |
| --- | --- |
| `p_demographics_score` | 基础人口学 |
| `p_purchasing_power_score` | 社会资产与购买力 |
| `p_identity_cluster_score` | 综合身份聚类 |
| `l_content_visual_mind_score` | 内容与视觉心智 |
| `l_innovation_brand_mind_score` | 创新与品牌心智 |
| `l_lifestyle_score` | 圈层生活方式 |
| `s_price_incentive_response_score` | 价格与利益应激 |
| `s_conversion_friction_score` | 转化决策摩擦 |
| `s_environment_score` | 物理/数字环境 |

当前分数规则：

```text
dimension score = sum(observation_weight) for that subject and dimension
```

这个规则是第一版数据库层的基础规则，故意保持简单、可审计。
后续如果需要归一化、时间衰减、平台加权或模型特征变换，应放在
ModelEvol 或单独的特征工程层，不要隐藏在基础数据库 view 里。

## 校验命令

修改数据或结构后，执行以下校验：

```bash
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/006_validate_pls_tag_type_dimension_mappings.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/008_validate_pls_tag_value_dimension_mappings.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/010_validate_v_pls_platform_tag_value_semantics.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/011_validate_profile_tag_observations.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/012_validate_v_profile_tag_observation_semantics.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/013_validate_v_subject_pls_dimension_features.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/014_validate_v_subject_pls_feature_matrix.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/015_validate_pls_channel_objects.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/016_validate_pls_channel_object_bindings.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/017_validate_pls_audience_profiles.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/018_validate_pls_product_fit_profiles.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/019_validate_v_pls_channel_profile_overview.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/020_validate_pls_audience_tag_dimension_mappings.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/021_validate_v_pls_audience_tag_semantics.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/022_validate_v_pls_channel_dimension_features.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/023_validate_v_pls_channel_feature_matrix.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/024_validate_platform_profile_tag_metrics.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/025_validate_v_platform_profile_tag_metric_semantics.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/026_validate_v_platform_profile_channel_dimension_features.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/027_validate_v_platform_profile_channel_feature_matrix.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/028_validate_ontobase_pls_platform_tag_mapping_calibration.sql"
```

## 接入注意事项

- 把 `v_subject_pls_feature_matrix` 作为第一版模型特征读取入口。
- 把 `v_profile_tag_observation_semantics` 作为第一版画像解释读取入口。
- 后续三平台真实画像导入优先写入 `platform_profile_tag_metrics`，读取
  `v_platform_profile_channel_feature_matrix` 作为第一版真实渠道画像特征入口。
- 真实主体标签观测必须先写入 `profile_tag_observations`，不要绕过这张事实表。
- 标签映射修正应保留在映射表中，不要散落在下游产品代码里。
- OntoBase 明确确认的平台标签 PLS 分层校准，应同步到
  `pls_tag_type_dimension_mappings` 和 `pls_tag_value_dimension_mappings`；
  当前 2026-07-16 校准通过
  `DataBase/migrations/028_sync_ontobase_pls_platform_tag_mapping_calibration.sql`
  固化。
- 数据库 view 应保持简单、透明、可审计；复杂模型变换应放在 ModelEvol 或后续明确的特征工程层。
