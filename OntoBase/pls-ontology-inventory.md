# PLS Ontology Inventory v0.1

日期：2026-07-15

## 1. 目的

本文是 OntoBase P1 产物：`PLS 渠道画像匹配本体` 的第一版清单。

它的职责是从 PLS 业务语义出发，定义首批本体对象、读取模型、属性语义、关系、指标、规则和动作，并记录第一期可引用的 DataBase 外部数据源。它不是 DataBase 表结构说明，也不是 DataBase 的字段注释替代品。

业务校准依据：`OntoBase/pls-ontology-business-calibration.md`。

边界：

- OntoBase 独立维护业务语义。
- DataBase 在第一期作为外部事实数据源和特征数据源。
- 本文只记录首期绑定，不表示 OntoBase 依附 DataBase。

## 2. Ontology

| 字段 | 内容 |
| --- | --- |
| ontology_id | `pls_channel_profile_matching` |
| name | PLS 渠道画像匹配本体 |
| domain | PLS / 渠道画像 / 标签语义 / 商品适配 |
| first_joint_scenario | `PLS 渠道画像匹配项目` |
| first_data_source | `DataBase/agentharness.sqlite` |
| status | `draft` |

本体要回答的问题：

- 渠道画像匹配里有哪些业务对象？
- 平台标签如何映射到 PLS 三层九维？
- 渠道对象、人群画像、商品适配画像和真实画像指标之间如何关联？
- 九维特征从哪些标签或指标聚合而来？
- 匹配结果如何解释和复核？

## 3. ObjectType 清单

阶段定位：本节除 `Profile Tag Observation` 外的 17 个 ObjectType 已确认为 PLS 第一阶段主线对象。`Profile Tag Observation` 已确认为后续扩展对象，不进入第一阶段主线，身份键留待扩展阶段确定。详细确认记录见 `OntoBase/pls-ontology-business-calibration.md` 第 8 节。

### 3.1 `PLS Semantic Dimension`

业务定义：PLS 渠道画像匹配使用的标准语义空间，当前为 P/L/S 三层九维。

首期数据源：

- `pls_semantic_dimensions`
- 下游语义 view 中的 `layer_code/layer_name/dimension_code/dimension_name/dimension_definition/business_strategy`

稳定身份：

- 首选：`dimension_code`
- DataBase 当前主键：`id`

核心属性：

| Property | 角色 | 说明 |
| --- | --- | --- |
| `dimension_code` | `semantic_code` | 九维标准编码，例如 `P_DEMOGRAPHICS` |
| `dimension_name` | `business_label` | 维度中文名 |
| `layer_code` | `semantic_code` | P/L/S 层级编码 |
| `layer_name` | `business_label` | 层级中文名 |
| `dimension_definition` | `definition` | 维度业务定义 |
| `business_strategy` | `strategy_text` | 维度相关业务策略 |

首批维度：

| layer | dimension_code | dimension_name |
| --- | --- | --- |
| 静态社会坐标 | `P_DEMOGRAPHICS` | 基础人口学 |
| 静态社会坐标 | `P_PURCHASING_POWER` | 社会资产与购买力 |
| 静态社会坐标 | `P_IDENTITY_CLUSTER` | 综合身份聚类 |
| 动态认知纵深 | `L_CONTENT_VISUAL_MIND` | 内容与视觉心智 |
| 动态认知纵深 | `L_INNOVATION_BRAND_MIND` | 创新与品牌心智 |
| 动态认知纵深 | `L_LIFESTYLE` | 圈层生活方式 |
| 瞬时应激频率 | `S_PRICE_INCENTIVE_RESPONSE` | 价格与利益应激 |
| 瞬时应激频率 | `S_CONVERSION_FRICTION` | 转化决策摩擦 |
| 瞬时应激频率 | `S_ENVIRONMENT` | 物理/数字环境 |

消费场景：

- 作为标签映射、画像特征、匹配解释的共同语义坐标系。

### 3.2 `Platform Tag`

业务定义：平台提供或可提取的原始画像标签值。平台包括天猫、抖音、京东；小红书暂不接入。

首期数据源：

- `platform_tag_catalog`
- `v_pls_platform_tag_value_semantics`

稳定身份：

- 首选：`platform_tag_catalog_id`
- 业务候选键：`platform + tag_type + leaf_label`

核心属性：

| Property | 角色 | 说明 |
| --- | --- | --- |
| `platform` | `source_platform` | 标签来源平台 |
| `tag_type` | `business_label` | 平台标签类型 |
| `leaf_label` | `business_label` | 平台标签值 |
| `label_path` | `hierarchy_path` | 标签层级路径 |
| `source_file/source_row` | `provenance` | 来源文件和行号 |

消费场景：

- 解释某个 PLS 维度由哪些平台标签贡献。
- 作为真实画像指标和标签观测的标准标签目录。

### 3.3 `Platform Tag Mapping`

业务定义：平台标签到 PLS 语义维度的映射关系，包括标签类型级映射和标签值级映射。

首期数据源：

- `pls_tag_type_dimension_mappings`
- `pls_tag_value_dimension_mappings`
- `v_pls_platform_tag_value_semantics`

稳定身份：

- 标签值级映射：`value_mapping_key = platform_tag_catalog_id + dimension_code`
- 标签类型级映射：`type_mapping_key = platform + tag_type + dimension_code`
- DataBase 行身份：`tag_value_mapping_id` / `inherited_tag_type_mapping_id`

核心属性：

| Property | 角色 | 说明 |
| --- | --- | --- |
| `platform_tag_catalog_id` | `identity_key` | 被映射的平台标签 |
| `dimension_id` / `dimension_code` | `semantic_code` | 目标 PLS 维度 |
| `mapping_status` | `workflow_state` | 映射状态 |
| `mapping_method` | `method` | 映射方式 |
| `confidence` / `mapping_confidence` | `confidence` | 映射可信度 |
| `rationale` / `mapping_rationale` | `explanation` | 映射理由 |

消费场景：

- 将平台标签语义展开到 PLS 三层九维。
- 支持匹配解释和人工复核。

### 3.4 `Channel Object`

业务定义：PLS 渠道画像匹配的核心业务对象，可以是平台、账号、店铺、商圈、营销事件、业务场景等。

首期数据源：

- `pls_channel_objects`
- `v_pls_channel_profile_overview`
- `v_pls_channel_feature_matrix`
- `v_platform_profile_channel_feature_matrix`

稳定身份：

- 首选：`canonical_object_key`

当前样例类型：

- `platform`
- `account`
- `store`
- `trade_area`
- `marketing_event`
- `business_scenario`

核心属性：

| Property | 角色 | 说明 |
| --- | --- | --- |
| `canonical_object_key` | `identity_key` | 跨表、跨库对齐的渠道对象稳定身份 |
| `object_type` | `object_type` | 渠道对象类型 |
| `display_name` | `business_label` | 展示名 |
| `platform_name` | `source_platform` | 平台名 |
| `platform_type` | `classification` | 平台/渠道类型 |
| `manual_review_status` | `quality_control` | 人工复核状态 |
| `possible_duplicate` | `quality_control` | 潜在重复标记 |
| `quality_flags_json` | `quality_control` | 质量标记 |

消费场景：

- 渠道匹配候选集。
- 人群画像、商品适配画像、特征矩阵的主对象。

### 3.5 `Channel Object Binding`

业务定义：渠道对象之间的业务关系，例如平台与账号、账号与店铺、场景与活动等关系。

首期数据源：

- `pls_channel_object_bindings`

稳定身份：

- `from_canonical_object_key + binding_type + to_canonical_object_key`
- `binding_id` 作为来源行身份。

核心属性：

| Property | 角色 | 说明 |
| --- | --- | --- |
| `binding_type` | `relationship_type` | 关系类型 |
| `from_canonical_object_key` | `identity_key` | 起点渠道对象 |
| `to_canonical_object_key` | `identity_key` | 终点渠道对象 |
| `source_batch_id/data_version` | `provenance` | 来源批次和版本 |

消费场景：

- 构建渠道对象图谱。
- 支持渠道上下游解释。

### 3.6 `Audience Profile`

业务定义：渠道对象对应的人群画像，包括标签集合、置信度、时间窗和质量信息。

首期数据源：

- `pls_audience_profiles`
- `v_pls_audience_tag_semantics`
- `v_pls_channel_profile_overview`

稳定身份：

- `profile_id`
- 归属对象：`canonical_object_key`
- 版本/来源属性：`time_window + source_batch_id + data_version`
- 版本/时效属性：`time_window + source_batch_id + data_version`

核心属性：

| Property | 角色 | 说明 |
| --- | --- | --- |
| `profile_id` | `identity_key` | 人群画像身份 |
| `canonical_object_key` | `identity_key` | 归属渠道对象 |
| `profile_stage` | `workflow_state` | 画像阶段 |
| `tags_json` | `source_payload` | 画像标签集合 |
| `confidence` | `confidence` | 画像可信度 |
| `time_window` | `time_window` | 画像时间窗 |
| `sample_size` | `sample_size` | 样本量 |
| `unmapped_fields_json` | `quality_control` | 未映射字段 |

消费场景：

- 渠道对象维度特征的样例/人工画像来源。
- 匹配解释中的标签证据来源。

### 3.7 `Audience Tag`

业务定义：人群画像中的单个标签项，以及它到 PLS 维度的映射结果。

首期数据源：

- `pls_audience_tag_dimension_mappings`
- `v_pls_audience_tag_semantics`

稳定身份：

- `profile_id + tag_namespace + tag_id`
- fallback：`profile_id + tag_namespace + tag_label_zh`
- 映射行身份：`audience_tag_mapping_id`

核心属性：

| Property | 角色 | 说明 |
| --- | --- | --- |
| `tag_id` | `identity_key` | 标签身份 |
| `tag_namespace` | `namespace` | 标签命名空间 |
| `tag_label_zh` | `business_label` | 标签中文名 |
| `tag_score` | `feature_value` | 标签分数 |
| `tag_confidence` | `confidence` | 标签可信度 |
| `dimension_code` | `semantic_code` | 映射 PLS 维度 |
| `mapping_confidence` | `confidence` | 映射可信度 |

消费场景：

- 渠道维度行特征的来源。
- 匹配解释中的标签贡献项。

### 3.8 `Audience Tag Taxonomy`

业务定义：约束人群画像标签的类型和值，避免人群画像标签只依赖单个平台目录或自由文本。

首期数据源：

- `platform_tag_catalog`
- `pls_audience_tag_dimension_mappings`
- `v_pls_audience_tag_semantics`

稳定身份：

- `tag_namespace + tag_id`
- fallback：`tag_namespace + tag_label_zh`
- 对齐平台标签目录的来源身份：`platform_tag_catalog_id`

核心属性：

| Property | 角色 | 说明 |
| --- | --- | --- |
| `tag_namespace` | `namespace` | 标签命名空间 |
| `tag_id` | `identity_key` | 标签身份 |
| `tag_label_zh` | `business_label` | 标签中文名 |
| `platform_tag_catalog_id` | `source_identity` | 对齐的平台标签目录身份 |
| `tag_type` | `classification` | 标签类型 |
| `leaf_label` | `business_label` | 平台标签值 |

消费场景：

- 约束 `Audience Tag`。
- 连接平台标签目录、调研标签、模型标签和人工标签。
- 使人群侧与商品侧 taxonomy 建模保持对称。

### 3.9 `Product Fit Profile`

业务定义：渠道对象对应的商品适配画像，包括品类、价格带、风格、场景、上新类型等适配信息。

首期数据源：

- `pls_product_fit_profiles`
- `v_pls_channel_profile_overview`

稳定身份：

- `profile_id`
- 归属对象：`canonical_object_key`

核心属性：

| Property | 角色 | 说明 |
| --- | --- | --- |
| `profile_id` | `identity_key` | 商品适配画像身份 |
| `canonical_object_key` | `identity_key` | 归属渠道对象 |
| `fit_categories_json` | `fit_signal` | 适配品类 |
| `fit_price_bands_json` | `fit_signal` | 适配价格带 |
| `fit_styles_json` | `fit_signal` | 适配风格 |
| `fit_occasions_json` | `fit_signal` | 适配场景 |
| `fit_launch_types_json` | `fit_signal` | 适配上新类型 |
| `evidence_json` | `evidence` | 适配证据 |
| `confidence` | `confidence` | 适配可信度 |

消费场景：

- 商品与渠道匹配。
- 解释某渠道适合哪些商品、价格、风格和场景。

### 3.10 `Product Fit Tag`

业务定义：渠道商品适配画像中的单条适配证据，例如适配品类、价格带、风格、场景、上新类型。

首期数据源：

- `pls_product_fit_profiles.fit_categories_json`
- `pls_product_fit_profiles.fit_price_bands_json`
- `pls_product_fit_profiles.fit_styles_json`
- `pls_product_fit_profiles.fit_occasions_json`
- `pls_product_fit_profiles.fit_launch_types_json`

稳定身份：

- `profile_id + fit_type + fit_value`
- 多条证据进入 `evidence_json`，不进入身份键。

核心属性：

| Property | 角色 | 说明 |
| --- | --- | --- |
| `fit_type` | `semantic_code` | 适配类型，例如 `category/price_band/style/occasion/launch_type` |
| `fit_value` | `business_label` | 适配标签值 |
| `profile_id` | `identity_key` | 所属商品适配画像 |
| `canonical_object_key` | `identity_key` | 归属渠道对象 |
| `evidence_json` | `evidence` | 适配证据 |

消费场景：

- 解释渠道为什么适合某类商品、价格带、风格或场景。
- 为后续商品-渠道匹配提供商品侧证据。

### 3.11 `Product Fit Taxonomy`

业务定义：约束商品适配标签的类型和值，避免商品侧适配画像退化成自由文本。

首期数据源：

- 暂无独立 DataBase 表。
- 首期从 `pls_product_fit_profiles.*_json` 中已有值和业务确认中整理。

稳定身份：

- `fit_type + fit_value_code`
- 展示值：`fit_value`
- 版本属性：`taxonomy_version`

首批适配类型：

| fit_type | 中文名 | 来源字段 |
| --- | --- | --- |
| `category` | 适配品类 | `fit_categories_json` |
| `price_band` | 适配价格带 | `fit_price_bands_json` |
| `style` | 适配风格 | `fit_styles_json` |
| `occasion` | 适配场景 | `fit_occasions_json` |
| `launch_type` | 适配上新/投放类型 | `fit_launch_types_json` |

消费场景：

- 约束 `Product Fit Tag`。
- 后续支持标准化商品侧匹配和解释。

### 3.12 `Product Fit Tag Mapping`

业务定义：商品适配标签到 PLS 语义维度的映射关系，用于定义商品侧适配信号如何进入 PLS 三层九维。

首期数据源：

- 暂无独立 DataBase 表。
- 首期由 OntoBase 业务确认和后续商品适配标签体系整理产生。

稳定身份：

- `fit_type + fit_value_code + dimension_code`

核心属性：

| Property | 角色 | 说明 |
| --- | --- | --- |
| `fit_type` | `semantic_code` | 商品适配标签类型 |
| `fit_value_code` | `semantic_code` | 商品适配标签稳定编码 |
| `dimension_code` | `semantic_code` | 目标 PLS 语义维度 |
| `mapping_method` | `method` | 映射方法 |
| `mapping_confidence` | `confidence` | 映射可信度 |
| `mapping_rationale` | `explanation` | 映射理由 |

消费场景：

- 解释商品适配标签如何贡献到 PLS 维度。
- 让商品侧和人群侧都能进入同一套 PLS 三层九维坐标系。

### 3.13 `Product`

业务定义：PLS 商品-渠道匹配中的商品对象，用于回答“某个商品适合哪些渠道 / 某个渠道适合哪些商品 / 新品应投放哪些渠道”。

首期数据源：

- 当前 DataBase 尚无独立商品主数据表。
- 首期作为 OntoBase 一等业务实体先定义，后续通过联合契约接入产品、文件、API 或 DataBase 新数据源。

稳定身份：

- `canonical_product_key`
- 来源身份候选：`product_id`、`source_product_key`、`sku_id`、`item_id`

核心属性：

| Property | 角色 | 说明 |
| --- | --- | --- |
| `canonical_product_key` | `identity_key` | OntoBase 跨来源统一商品身份 |
| `product_id/source_product_key/sku_id/item_id` | `source_identity` | 来源系统商品身份 |
| `product_name` | `business_label` | 商品名称 |
| `category_id` | `identity_key` | 商品品类 |
| `brand_id` | `identity_key` | 品牌 |
| `price_band` | `classification` | 价格带 |
| `style_tags` | `semantic_tags` | 风格标签 |
| `launch_stage` | `workflow_state` | 新品/成熟品/清仓等状态 |

消费场景：

- 商品到渠道的匹配。
- 渠道到商品的推荐。
- 新品投放场景解释。

### 3.14 `Product Category`

业务定义：商品侧最基础的分类语义，用于连接商品、渠道适配画像和匹配场景。

首期数据源：

- 当前 DataBase 尚无独立商品品类表。
- 首期作为 OntoBase 一等分类对象先定义。

稳定身份：

- `canonical_category_key`
- 来源身份候选：`category_id`、`category_path`、`platform + category_id`、`source_category_key`

核心属性：

| Property | 角色 | 说明 |
| --- | --- | --- |
| `canonical_category_key` | `identity_key` | OntoBase 跨来源统一品类身份 |
| `category_id/source_category_key` | `source_identity` | 来源系统品类身份 |
| `category_name` | `business_label` | 品类名称 |
| `category_path` | `hierarchy_path` | 品类路径 |
| `parent_category_id` | `identity_key` | 父级品类 |

消费场景：

- 商品与渠道适配解释。
- 商品侧标签体系标准化。

### 3.15 `Brand`

业务定义：品牌对象，用于承接品牌调性、价格带、目标人群、历史渠道表现等匹配语义。

首期数据源：

- 当前 DataBase 尚无独立品牌主数据表。
- 首期作为 OntoBase 一等业务实体先定义。

稳定身份：

- `canonical_brand_key`
- 来源身份候选：`brand_id`、`source_brand_key`、`platform + brand_name`

核心属性：

| Property | 角色 | 说明 |
| --- | --- | --- |
| `canonical_brand_key` | `identity_key` | OntoBase 跨来源统一品牌身份 |
| `brand_id/source_brand_key` | `source_identity` | 来源系统品牌身份 |
| `brand_name` | `business_label` | 品牌名称 |
| `brand_positioning` | `definition` | 品牌定位 |
| `target_audience` | `semantic_tags` | 目标人群 |
| `price_positioning` | `classification` | 价格定位 |

消费场景：

- 品牌到渠道的匹配。
- 商品匹配中的品牌调性解释。

### 3.16 `Match Scenario`

业务定义：一次商品-渠道匹配决策发生的业务语境，例如新品首发、618 大促、内容种草、清库存促销等。

首期数据源：

- 当前 DataBase 中 `pls_channel_objects.object_type = business_scenario` 可作为早期来源之一。
- 后续建议从 `Channel Object` 子类型中逐步独立出匹配场景数据源。

稳定身份：

- `scenario_code`
- 说明：场景作为业务标准枚举 / 决策上下文类型；具体一次任务实例后续可另建 `Match Task` 或 `Matching Run`。

核心属性：

| Property | 角色 | 说明 |
| --- | --- | --- |
| `scenario_code` | `identity_key` | 场景稳定编码 |
| `scenario_name` | `business_label` | 场景名称 |
| `scenario_type` | `classification` | 场景类型 |
| `objective` | `definition` | 匹配目标 |
| `priority_dimensions` | `semantic_code` | 场景优先关注的 PLS 维度 |

消费场景：

- 决定商品-渠道匹配的权重和解释口径。
- 区分新品首发、促销转化、内容种草等不同决策上下文。

### 3.17 `Platform Profile Tag Metric`

业务定义：从平台真实画像导入的标签指标长表，承接占比、TGI、人数、指数或分值等指标形态。

首期数据源：

- `platform_profile_tag_metrics`
- `v_platform_profile_tag_metric_semantics`

稳定身份：

- `profile_id + platform_tag_catalog_id + metric_name + profile_time_window + source_batch_id`
- 归属对象：`canonical_object_key`
- 来源行身份：`id` / `metric_id`

核心属性：

| Property | 角色 | 说明 |
| --- | --- | --- |
| `profile_id` | `identity_key` | 真实画像身份 |
| `canonical_object_key` | `identity_key` | 归属渠道对象 |
| `platform_tag_catalog_id` | `identity_key` | 平台标签标准身份 |
| `metric_name` | `metric_name` | 指标名，例如 `share` |
| `metric_value` | `feature_value` | 指标数值 |
| `metric_unit` | `unit` | 指标单位 |
| `profile_time_window` | `time_window` | 画像时间窗 |
| `sample_size` | `sample_size` | 样本量 |
| `source_file/source_row/source_batch_id` | `provenance` | 导入来源 |

消费场景：

- 真实平台画像进入 PLS 九维特征。
- 支持真实画像维度解释和标签级解释。

### 3.18 `Profile Tag Observation`

业务定义：主体命中平台标签的观测事实，用于主体级画像和解释。

业务校准状态：后续扩展对象。第一阶段 PLS 主线优先使用 `Platform Profile Tag Metric`，本对象用于未来承接人工修正、模型推断、非平台报表来源的主体标签命中事实。

首期数据源：

- `profile_tag_observations`
- `v_profile_tag_observation_semantics`
- `v_subject_pls_dimension_features`
- `v_subject_pls_feature_matrix`

稳定身份：

- 暂不确认，进入后续扩展阶段再定。
- 当前 DataBase 行身份：`id`
- 候选业务粒度：`subject_type + subject_id + platform_tag_catalog_id + observed_at`

核心属性：

| Property | 角色 | 说明 |
| --- | --- | --- |
| `subject_type` | `object_type` | 主体类型 |
| `subject_id` | `identity_key` | 主体身份 |
| `platform_tag_catalog_id` | `identity_key` | 命中的平台标签 |
| `observed_value` | `observation_value` | 观测值 |
| `observation_weight` | `feature_value` | 观测权重 |
| `observation_source` | `provenance` | 观测来源 |
| `observed_at` | `event_time` | 观测时间 |
| `evidence_ref` | `evidence` | 证据引用 |

消费场景：

- 主体级标签解释。
- 后续主体级匹配和分群。

## 4. ReadModel 清单

阶段定位：本节两个 ReadModel 均已确认进入第一阶段 P2/P3 的读取 entrypoint / contract，但不作为一等业务对象，不承担事实写入职责。

### 4.1 `Channel Dimension Feature`

定义：渠道对象在单个 PLS 维度上的行式特征，用于解释九维得分来源。

业务校准状态：读取模型 / 特征解释视图，不作为一等业务实体。

首期数据源：

- `v_pls_channel_dimension_features`
- `v_platform_profile_channel_dimension_features`

稳定身份：

- 读取模型粒度区分两类：
  - 样例/人工画像：`canonical_object_key + dimension_code`
  - 真实平台画像：`profile_id + canonical_object_key + metric_name + dimension_code + profile_time_window + source_batch_id`

核心属性：

| Property | 角色 | 说明 |
| --- | --- | --- |
| `canonical_object_key` | `identity_key` | 渠道对象身份 |
| `dimension_code` | `semantic_code` | PLS 维度 |
| `dimension_score` | `feature_value` | 样例/人工画像维度得分 |
| `dimension_metric_sum` | `feature_value` | 真实画像维度指标求和 |
| `avg_mapping_confidence` | `confidence` | 平均映射可信度 |
| `tag_ids/tag_labels_zh` | `evidence` | 标签证据 |
| `tag_types/leaf_labels` | `evidence` | 真实画像标签证据 |

消费场景：

- 行式解释。
- 调试某个九维宽表分数来源。

### 4.2 `Channel Feature Matrix`

定义：渠道对象九维特征宽表，是 PLS 匹配和模型消费的紧凑输入。

业务校准状态：读取模型 / 匹配特征输入，不作为一等业务实体。

首期数据源：

- `v_pls_channel_feature_matrix`
- `v_platform_profile_channel_feature_matrix`

稳定身份：

- 读取模型粒度区分两类：
  - 样例/人工画像：`canonical_object_key`
  - 真实平台画像：`profile_id + canonical_object_key + metric_name + profile_time_window + source_batch_id`

核心属性：

| Property | 角色 | 说明 |
| --- | --- | --- |
| `active_dimension_count` | `feature_summary` | 有效维度数 |
| `total_feature_score` | `feature_summary` | 样例/人工画像总分 |
| `total_metric_sum` | `feature_summary` | 真实画像指标总和 |
| `avg_tag_confidence` | `confidence` | 标签平均可信度 |
| `avg_mapping_confidence` | `confidence` | 映射平均可信度 |
| `p_demographics_score` / `p_demographics_metric_sum` | `feature_value` | 基础人口学维度特征 |
| `p_purchasing_power_score` / `p_purchasing_power_metric_sum` | `feature_value` | 社会资产与购买力维度特征 |
| `p_identity_cluster_score` / `p_identity_cluster_metric_sum` | `feature_value` | 综合身份聚类维度特征 |
| `l_content_visual_mind_score` / `l_content_visual_mind_metric_sum` | `feature_value` | 内容与视觉心智维度特征 |
| `l_innovation_brand_mind_score` / `l_innovation_brand_mind_metric_sum` | `feature_value` | 创新与品牌心智维度特征 |
| `l_lifestyle_score` / `l_lifestyle_metric_sum` | `feature_value` | 圈层生活方式维度特征 |
| `s_price_incentive_response_score` / `s_price_incentive_response_metric_sum` | `feature_value` | 价格与利益应激维度特征 |
| `s_conversion_friction_score` / `s_conversion_friction_metric_sum` | `feature_value` | 转化决策摩擦维度特征 |
| `s_environment_score` / `s_environment_metric_sum` | `feature_value` | 物理/数字环境维度特征 |

消费场景：

- PLS 渠道画像匹配模型输入。
- 报表、评分、排序和候选集筛选。

## 5. PropertyType 角色字典

| Role | 含义 | 典型字段 |
| --- | --- | --- |
| `identity_key` | 稳定身份或跨源对齐键 | `canonical_object_key`、`dimension_code`、`platform_tag_catalog_id`、`profile_id` |
| `business_label` | 面向用户展示的名称 | `display_name`、`dimension_name`、`leaf_label`、`tag_label_zh` |
| `semantic_code` | 标准语义编码 | `layer_code`、`dimension_code` |
| `object_type` | 对象分类 | `object_type`、`subject_type` |
| `feature_value` | 模型或匹配可消费数值 | `dimension_score`、`metric_value`、九维 score/metric_sum |
| `confidence` | 映射、画像、标签或聚合可信度 | `confidence`、`mapping_confidence`、`avg_mapping_confidence` |
| `provenance` | 来源、批次、版本、文件行号 | `source_file`、`source_row`、`source_batch_id`、`data_version` |
| `time_window` | 画像或指标覆盖时间窗 | `time_window`、`profile_time_window` |
| `quality_control` | 质量和人工复核状态 | `quality_flags_json`、`manual_review_status`、`possible_duplicate` |
| `evidence` | 解释证据或引用 | `evidence_json`、`evidence_ref`、`tag_labels_zh`、`leaf_labels` |
| `workflow_state` | 处理状态或阶段 | `mapping_status`、`profile_stage`、`status` |

## 6. LinkType 清单

| LinkType | Source | Target | 首期依据 | 说明 |
| --- | --- | --- | --- | --- |
| `maps_to_dimension` | `Platform Tag` | `PLS Semantic Dimension` | `pls_tag_value_dimension_mappings.dimension_id` | 平台标签值映射到 PLS 维度 |
| `tag_type_maps_to_dimension` | `Platform Tag` | `PLS Semantic Dimension` | `pls_tag_type_dimension_mappings.dimension_id` | 标签类型默认映射到 PLS 维度 |
| `audience_tag_maps_to_dimension` | `Audience Tag` | `PLS Semantic Dimension` | `pls_audience_tag_dimension_mappings.dimension_id` | 渠道人群标签映射到 PLS 维度 |
| `contains_audience_tag` | `Audience Profile` | `Audience Tag` | `profile_id` | 渠道人群画像包含单条人群画像标签 |
| `constrained_by_audience_taxonomy` | `Audience Tag` | `Audience Tag Taxonomy` | `tag_namespace + tag_id` | 人群画像标签受人群画像标签体系约束 |
| `aligns_to_platform_tag` | `Audience Tag Taxonomy` | `Platform Tag` | `platform_tag_catalog_id` | 人群标签体系可选对齐平台画像标签目录 |
| `has_audience_profile` | `Channel Object` | `Audience Profile` | `canonical_object_key` | 渠道对象拥有人群画像 |
| `has_product_fit_profile` | `Channel Object` | `Product Fit Profile` | `canonical_object_key` | 渠道对象拥有商品适配画像 |
| `contains_product_fit_tag` | `Product Fit Profile` | `Product Fit Tag` | `profile_id` + JSON 来源 | 商品适配画像包含单条商品适配标签 |
| `constrained_by_fit_taxonomy` | `Product Fit Tag` | `Product Fit Taxonomy` | `fit_type + fit_value` | 商品适配标签受商品适配标签体系约束 |
| `product_fit_tag_maps_to_dimension` | `Product Fit Tag` | `PLS Semantic Dimension` | `fit_type + fit_value_code + dimension_code` | 商品适配标签映射到 PLS 语义维度 |
| `product_belongs_to_category` | `Product` | `Product Category` | 待接入商品数据源 | 商品属于商品品类 |
| `product_belongs_to_brand` | `Product` | `Brand` | 待接入商品数据源 | 商品属于品牌 |
| `match_uses_scenario` | `Product` / `Channel Object` | `Match Scenario` | 待 P2/P3 定义 | 匹配发生在特定业务场景下 |
| `binds_to_channel_object` | `Channel Object` | `Channel Object` | `pls_channel_object_bindings` | 渠道对象之间的业务关系 |
| `observes_tag` | `Profile Tag Observation` | `Platform Tag` | `platform_tag_catalog_id` | 主体标签观测命中平台标签 |
| `metric_observes_tag` | `Platform Profile Tag Metric` | `Platform Tag` | `platform_tag_catalog_id` | 真实画像指标绑定平台标签 |
| `generates_dimension_feature` | `Audience Profile` / `Platform Profile Tag Metric` | `Channel Dimension Feature` | 下游 view 链路 | 画像或指标生成维度行特征 |
| `pivots_to_feature_matrix` | `Channel Dimension Feature` | `Channel Feature Matrix` | 下游 view 链路 | 维度行特征透视为九维宽表 |
| `uses_dimension_standard` | `Channel Feature Matrix` | `PLS Semantic Dimension` | 九维列命名 | 特征列对应 PLS 标准维度 |

## 7. MetricDefinition 清单

| MetricDefinition | 粒度 | 首期入口 | 业务含义 |
| --- | --- | --- | --- |
| `PLS Dimension Score` | `canonical_object_key + dimension_code` | `v_pls_channel_dimension_features.dimension_score` | 样例/人工画像标签聚合出的单维度得分 |
| `PLS Channel Feature Score` | `canonical_object_key` | `v_pls_channel_feature_matrix` 九维 score 列 | 渠道对象九维宽表特征 |
| `Platform Profile Tag Metric Value` | `profile_id + tag + metric_name` | `platform_profile_tag_metrics.metric_value` | 真实画像标签指标数值 |
| `Platform Profile Dimension Metric Sum` | `profile_id + canonical_object_key + metric_name + dimension_code` | `v_platform_profile_channel_dimension_features.dimension_metric_sum` | 真实画像指标在 PLS 维度上的聚合值 |
| `Platform Profile Channel Metric Matrix` | `profile_id + canonical_object_key + metric_name` | `v_platform_profile_channel_feature_matrix` 九维 metric_sum 列 | 真实画像指标九维宽表特征 |
| `Tag Observation Weight` | `subject_id + platform_tag_catalog_id` | `profile_tag_observations.observation_weight` | 主体标签观测权重 |
| `Mapping Confidence` | `tag/value mapping` | 多个 semantics view | 标签映射到 PLS 维度的可信度 |
| `Profile Confidence` | `profile_id` | `pls_audience_profiles.confidence`、`pls_product_fit_profiles.confidence` | 人群画像/商品适配画像可信度 |

## 8. LogicRule 清单

| LogicRule | 说明 | 首期检查方式 |
| --- | --- | --- |
| `PLS_DIMENSION_SPACE_IS_NINE_DIMENSIONS` | 当前 PLS 标准必须保持 P/L/S 三层九维 | `pls_semantic_dimensions` 应为 9 条 active 标准维度 |
| `CHANNEL_OBJECT_KEY_IS_PRIMARY_MATCH_IDENTITY` | 渠道匹配以 `canonical_object_key` 作为渠道对象稳定身份 | 渠道对象、画像、特征 view 都应携带该字段 |
| `TAG_MAPPING_EXPLAINS_DIMENSION_FEATURES` | 维度特征必须能追溯到标签映射或画像标签映射 | 行式解释 view 必须保留标签证据和映射置信度 |
| `FEATURE_MATRIX_IS_READ_MODEL` | 九维宽表是模型/匹配读取入口，不直接写入 | 只读 view，不作为写入对象 |
| `REAL_PROFILE_METRICS_ARE_LONG_TABLE_INPUT` | 真实平台画像指标先进入长表，再由 view 展开语义和聚合 | 写入 `platform_profile_tag_metrics`，不写入宽表 |
| `UNMAPPED_TAGS_REQUIRE_REVIEW` | 未映射标签不能直接进入可靠特征 | 进入复核或 unmapped 字段记录 |
| `SOURCE_PROVENANCE_MUST_BE_RETAINED` | 真实导入必须保留来源文件、行号、批次和原始 JSON | `source_file/source_row/source_batch_id/raw_json` |
| `PRODUCT_SIDE_NEEDS_STANDARD_FIT_TAXONOMY` | 商品侧适配画像必须受商品适配标签体系约束，不能长期停留在自由文本 JSON | `Product Fit Taxonomy` 后续需标准化 |
| `PRODUCT_FIT_TAGS_SHOULD_MAP_TO_PLS_DIMENSIONS` | 商品适配标签应能映射到 PLS 语义维度，否则商品侧难以进入统一匹配坐标系 | `Product Fit Tag Mapping` |
| `READ_MODELS_ARE_NOT_BUSINESS_ENTITIES` | 渠道维度特征和渠道九维特征矩阵是读取模型，不作为一等业务实体 | P2/P3 中进入 entrypoint/contract，不进入核心 ObjectType |

## 9. ActionType 清单

| ActionType | 触发条件 | 预期动作 | 备注 |
| --- | --- | --- | --- |
| `Import Platform Profile Metrics` | 获得天猫/抖音/京东真实画像 CSV | 预检并写入 `platform_profile_tag_metrics` | 执行由 DataBase 导入器或 Console 工作流承接 |
| `Review Unmapped Tag` | 标签无法映射到 PLS 维度 | 进入人工映射/复核，产出映射修正 | 未来可沉淀到 MemoryBase |
| `Refresh Channel Feature Matrix` | 渠道对象、画像、映射或真实指标更新 | 重新读取特征 view，刷新模型输入 | view 只读，刷新是消费侧动作 |
| `Explain Channel Match` | 需要解释渠道匹配结果 | 沿 OntoBase LinkType 展开维度、标签、指标证据 | P5 图谱与解释层重点 |
| `Promote Mapping Standard` | 某类映射稳定且通过复核 | 将映射提升为标准映射或规则 | 影响 OntoBase 规则和 DataBase 映射数据源 |
| `Flag Low Confidence Feature` | 映射或画像置信度低于阈值 | 标记低可信维度/标签，进入复核 | 阈值待后续 contract 定义 |
| `Standardize Product Fit Taxonomy` | 商品适配标签值开始影响匹配和解释 | 建立或更新商品适配标签体系 | OntoBase 侧语义动作，未来可提出 DataBase 数据源需求 |

## 10. 首期 DataSourceBinding 清单

| Binding | OntoBase 对象 | DataBase 入口 | 读写 | 用途 |
| --- | --- | --- | --- | --- |
| `db.pls_semantic_dimensions` | `PLS Semantic Dimension` | `pls_semantic_dimensions` | read | PLS 九维标准 |
| `db.platform_tag_catalog` | `Platform Tag` | `platform_tag_catalog` | read | 平台标签目录 |
| `db.pls_tag_value_dimension_mappings` | `Platform Tag Mapping` | `pls_tag_value_dimension_mappings` | read/write via DataBase process | 标签值映射 |
| `db.pls_tag_type_dimension_mappings` | `Platform Tag Mapping` | `pls_tag_type_dimension_mappings` | read/write via DataBase process | 标签类型映射 |
| `db.pls_channel_objects` | `Channel Object` | `pls_channel_objects` | read/write via DataBase process | 渠道对象主数据 |
| `db.pls_channel_object_bindings` | `Channel Object Binding` | `pls_channel_object_bindings` | read/write via DataBase process | 渠道对象关系 |
| `db.pls_audience_profiles` | `Audience Profile` | `pls_audience_profiles` | read/write via DataBase process | 渠道人群画像 |
| `db.pls_audience_tag_dimension_mappings` | `Audience Tag` | `pls_audience_tag_dimension_mappings` | read/write via DataBase process | 人群标签维度映射 |
| `db.pls_product_fit_profiles` | `Product Fit Profile` | `pls_product_fit_profiles` | read/write via DataBase process | 商品适配画像 |
| `db.pls_product_fit_profile_json_fields` | `Product Fit Tag` / `Product Fit Taxonomy` | `pls_product_fit_profiles.*_json` | read | 商品适配标签与适配标签体系的首期临时来源 |
| `ontobase.product_fit_tag_mappings` | `Product Fit Tag Mapping` | OntoBase 文档/后续独立存储 | read/write via OntoBase process | 商品适配标签到 PLS 维度的映射 |
| `db.platform_profile_tag_metrics` | `Platform Profile Tag Metric` | `platform_profile_tag_metrics` | read/write via DataBase process | 真实平台画像指标长表 |
| `db.profile_tag_observations` | `Profile Tag Observation` | `profile_tag_observations` | read/write via DataBase process | 主体标签观测 |
| `db.v_pls_channel_profile_overview` | `Channel Object` / profile overview | `v_pls_channel_profile_overview` | read | 渠道对象画像概览 |
| `db.v_pls_audience_tag_semantics` | `Audience Tag` | `v_pls_audience_tag_semantics` | read | 人群标签语义展开 |
| `db.v_pls_channel_dimension_features` | `Channel Dimension Feature` | `v_pls_channel_dimension_features` | read | 样例/人工画像维度行特征 |
| `db.v_pls_channel_feature_matrix` | `Channel Feature Matrix` | `v_pls_channel_feature_matrix` | read | 样例/人工画像九维宽表 |
| `db.v_platform_profile_tag_metric_semantics` | `Platform Profile Tag Metric` | `v_platform_profile_tag_metric_semantics` | read | 真实画像标签指标语义展开 |
| `db.v_platform_profile_channel_dimension_features` | `Channel Dimension Feature` | `v_platform_profile_channel_dimension_features` | read | 真实画像维度行特征 |
| `db.v_platform_profile_channel_feature_matrix` | `Channel Feature Matrix` | `v_platform_profile_channel_feature_matrix` | read | 真实画像九维宽表 |
| `db.v_pls_platform_tag_value_semantics` | `Platform Tag Mapping` | `v_pls_platform_tag_value_semantics` | read | 平台标签值语义展开 |

## 11. DataSource Gap 清单

### 11.1 商品侧标签表缺口

优先级：high

当前状态：

- 人群侧已有 `platform_tag_catalog` 作为平台画像标签目录。
- 人群侧已有 `pls_tag_type_dimension_mappings` 和 `pls_tag_value_dimension_mappings` 作为标签到 PLS 维度的映射。
- 商品侧已经在 OntoBase 定义 `Product Fit Taxonomy`、`Product Fit Tag`、`Product Fit Tag Mapping`。
- 但 DataBase 尚无对应的商品适配标签目录和 PLS 维度映射表。

影响：

- 商品侧暂时只能从 `pls_product_fit_profiles.*_json` 提取适配标签。
- 商品适配标签值缺少稳定目录、复核入口和映射表。
- 商品侧不能像人群侧一样稳定解释“某个商品适配标签为什么贡献到某个 PLS 维度”。

建议后续向 DataBase 提出的数据源需求：

```text
product_fit_tag_catalog
pls_product_fit_tag_type_dimension_mappings
pls_product_fit_tag_value_dimension_mappings
v_pls_product_fit_tag_semantics
```

首批商品适配标签类型：

| fit_type | 中文名 | 当前临时来源 |
| --- | --- | --- |
| `category` | 适配品类 | `pls_product_fit_profiles.fit_categories_json` |
| `price_band` | 适配价格带 | `pls_product_fit_profiles.fit_price_bands_json` |
| `style` | 适配风格 | `pls_product_fit_profiles.fit_styles_json` |
| `occasion` | 适配场景 | `pls_product_fit_profiles.fit_occasions_json` |
| `launch_type` | 适配上新/投放类型 | `pls_product_fit_profiles.fit_launch_types_json` |

## 12. 首期闭环

P1 后续 P2/P3 应优先验证这条闭环：

```text
Channel Object
  --has_audience_profile-->
Audience Profile
  --contains-->
Audience Tag
  --audience_tag_maps_to_dimension-->
PLS Semantic Dimension
  --generates_dimension_feature-->
Channel Dimension Feature
  --pivots_to_feature_matrix-->
Channel Feature Matrix
  --explains-->
Match Explanation
```

首期 DataBase 对应链路：

```text
pls_channel_objects
  -> pls_audience_profiles
  -> pls_audience_tag_dimension_mappings
  -> v_pls_audience_tag_semantics
  -> v_pls_channel_dimension_features
  -> v_pls_channel_feature_matrix
```

## 13. P1 验收状态

| 验收项 | 状态 |
| --- | --- |
| 不打开数据库也能理解 PLS 本体对象 | 已满足 |
| 每个核心对象有业务定义 | 已满足 |
| 每个核心对象有稳定身份策略 | 已满足，部分对象后续可细化复合键 |
| 每个核心对象有首期外部数据源绑定 | 已满足 |
| 已定义 PropertyType 角色字典 | 已满足 |
| 已定义 LinkType 清单 | 已满足 |
| 已定义 MetricDefinition 清单 | 已满足 |
| 已定义 LogicRule 清单 | 已满足 |
| 已定义 ActionType 清单 | 已满足 |
| 已明确 P2/P3 优先闭环 | 已满足 |
| 已完成 P1.1 业务实体校准 | 已满足，见 `OntoBase/pls-ontology-business-calibration.md` |
| 已完成第一阶段对象分层确认 | 已满足：17 个主线对象、1 个后续扩展对象、2 个第一阶段读取模型 |
| 已记录商品侧标签表缺口 | 已满足，标记为 high priority DataSource Gap |

## 14. 下一步

进入 P2：编写 `OntoBase/pls-matching-semantic-entrypoints.md`。

P2 要把本文中的对象和绑定转成产品/模型可执行的读取说明，重点区分：

- 特征读取入口。
- 解释读取入口。
- 标签标准读取入口。
- 真实画像指标读取入口。
