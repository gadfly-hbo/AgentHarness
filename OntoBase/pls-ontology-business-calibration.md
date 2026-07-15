# PLS Ontology Business Calibration v0.1

日期：2026-07-15

## 1. 目的

本文记录 `PLS 渠道画像匹配本体` 的 P1.1 业务实体校准结果。

背景：`pls-ontology-inventory.md` v0.1 是基于现有 DataBase PLS 资产和项目文档推导出的技术校准版。经过逐项确认后，本文把对象处理结论沉淀为业务确认记录，用于回写 P1 清单，并作为进入 P2 前的依据。

## 2. 校准结论

| # | 原对象 / 新对象 | 中文名 | 类别 | 处理结论 | 说明 |
| ---: | --- | --- | --- | --- | --- |
| 1 | `PLS Semantic Dimension` | PLS 语义维度 | 语义对象 | 保留 | PLS 三层九维标准语义空间。 |
| 2 | `Platform Tag` | 平台画像标签 | 语义对象 | 保留 | 平台侧原始画像标签值。 |
| 3 | `Platform Tag Mapping` | 平台标签维度映射 | 语义对象 / 关系对象 | 保留 | 平台画像标签到 PLS 语义维度的映射。 |
| 4 | `Channel Object` | 渠道画像对象 | 业务实体总类 | 保留为总类 | 下设 `platform/account/store/trade_area/marketing_event/business_scenario` 等子类型。 |
| 5 | `Channel Object Binding` | 渠道对象关系 | 关系对象 | 保留 | 渠道画像对象之间的业务关系。 |
| 6 | `Audience Profile` | 渠道人群画像 | 业务实体 / 画像对象 | 保留 | 某个渠道画像对象在时间窗、来源批次下的一组人群画像标签集合。 |
| 7 | `Audience Tag` | 人群画像标签 | 语义证据对象 | 保留 | 渠道人群画像中的单条标签证据。 |
| 7a | `Audience Tag Taxonomy` | 人群画像标签体系 | 语义标准对象 | 新增 | 约束人群画像标签的类型和值。 |
| 8 | `Product Fit Profile` | 渠道商品适配画像 | 业务实体 / 画像对象 | 保留 | 渠道对象的商品适配画像。 |
| 8a | `Product Fit Tag` | 商品适配标签 | 语义证据对象 | 新增 | 商品适配画像中的单条适配证据。 |
| 8b | `Product Fit Taxonomy` | 商品适配标签体系 | 语义标准对象 | 新增 | 约束商品适配标签的类型和值。 |
| 8c | `Product Fit Tag Mapping` | 商品适配标签维度映射 | 语义对象 / 关系对象 | 新增 | 商品适配标签如何映射到 PLS 语义维度。 |
| 9 | `Platform Profile Tag Metric` | 平台画像标签指标 | 指标观测对象 / 事实对象 | 保留 | 平台真实画像导入后的标签指标观测。 |
| 10 | `Profile Tag Observation` | 画像标签观测 | 通用标签观测事实对象 | 保留为后续扩展对象 | 用于承接人工修正、模型推断、非平台报表来源的主体标签命中事实。 |
| 11 | `Channel Dimension Feature` | 渠道维度特征 | 读取模型 / 特征解释视图 | 降级为读取模型 | 不作为一等业务实体，保留为解释读取入口。 |
| 12 | `Channel Feature Matrix` | 渠道九维特征矩阵 | 读取模型 / 匹配特征输入 | 降级为读取模型 | 不作为一等业务实体，保留为模型/匹配读取入口。 |
| 13 | `Product` | 商品 | 业务实体 | 新增为一等业务实体 | 承接商品到渠道、渠道到商品的匹配问题。 |
| 14 | `Product Category` | 商品品类 | 业务实体 / 分类对象 | 新增为一等对象 | 商品侧最基础的分类语义。 |
| 15 | `Brand` | 品牌 | 业务实体 | 新增为一等对象 | 承接品牌调性、价格带、目标人群、历史渠道表现等匹配语义。 |
| 16 | `Match Scenario` | 匹配场景 | 业务实体 / 决策上下文对象 | 新增为一等对象 | 一次商品-渠道匹配决策发生的业务语境。 |

## 3. 对 P1 清单的回写要求

`pls-ontology-inventory.md` 需要按以下方式调整：

1. `Channel Dimension Feature` 与 `Channel Feature Matrix` 从一等 `ObjectType` 语义中降级为 `ReadModel`，保留在读取入口、解释链路和 DataSourceBinding 中。
2. 新增一等业务实体：`Product`、`Product Category`、`Brand`、`Match Scenario`。
3. 新增人群侧语义支撑对象：`Audience Tag Taxonomy`。
4. 新增商品侧语义支撑对象：`Product Fit Tag`、`Product Fit Taxonomy`、`Product Fit Tag Mapping`。
5. `Profile Tag Observation` 保留，但标注为后续扩展对象，不进入 PLS 第一阶段主线闭环。
6. 后续 P2 只能基于本业务确认版 P1 推进，不能直接使用技术校准版对象边界。

## 4. 校准推进顺序

1. 核心身份键确认：已完成。
2. 对象关系确认：已完成。
3. DataSource Gap 识别：已完成首批确认。
4. PLS 第一阶段对象分层：进行中。

## 5. 核心身份键确认

| 对象 | 中文名 | OntoBase 稳定身份 | 确认状态 | 说明 |
| --- | --- | --- | --- | --- |
| `PLS Semantic Dimension` | PLS 语义维度 | `dimension_code` | 已确认 | DataBase 内部 `id` 只作为数据源内部主键，不作为 OntoBase 首选业务身份。 |
| `Platform Tag` | 平台画像标签 | `platform_tag_catalog_id` | 已确认 | `platform + tag_type + leaf_label` 作为业务候选键和展示排查信息。 |
| `Platform Tag Mapping` | 平台标签维度映射 | `value_mapping_key` / `type_mapping_key` | 已确认 | 标签值级映射：`platform_tag_catalog_id + dimension_code`；标签类型级映射：`platform + tag_type + dimension_code`。 |
| `Channel Object` | 渠道画像对象 | `canonical_object_key` | 已确认 | 覆盖 `platform/account/store/trade_area/marketing_event/business_scenario` 等渠道对象子类型。 |
| `Channel Object Binding` | 渠道对象关系 | `from_canonical_object_key + binding_type + to_canonical_object_key` | 已确认 | `binding_id` 可作为来源行身份；关系业务身份由“谁通过什么关系连到谁”决定。 |
| `Audience Profile` | 渠道人群画像 | `profile_id` | 已确认 | `canonical_object_key` 为业务归属键；`time_window/source_batch_id/data_version` 为版本和时效属性。 |
| `Audience Tag` | 人群画像标签 | `profile_id + tag_namespace + tag_id` | 已确认 | 缺少 `tag_id` 的来源可临时 fallback 到 `profile_id + tag_namespace + tag_label_zh`。 |
| `Audience Tag Taxonomy` | 人群画像标签体系 | `tag_namespace + tag_id` | 已确认 | `platform_tag_catalog_id` 作为对齐平台标签目录的来源身份；缺少 `tag_id` 时 fallback 到 `tag_namespace + tag_label_zh`。 |
| `Product Fit Profile` | 渠道商品适配画像 | `profile_id` | 已确认 | `canonical_object_key` 为业务归属键；`time_window/source_batch_id/data_version` 为版本和来源属性。 |
| `Product Fit Tag` | 商品适配标签 | `profile_id + fit_type + fit_value` | 已确认 | 同一标签值的多条证据进入 `evidence_json`，不进入身份键。 |
| `Product Fit Taxonomy` | 商品适配标签体系 | `fit_type + fit_value_code` | 已确认 | `fit_value` 作为展示值；`taxonomy_version` 作为版本属性，不进入首选身份键。 |
| `Product Fit Tag Mapping` | 商品适配标签维度映射 | `fit_type + fit_value_code + dimension_code` | 已确认 | 对应人群侧 `Platform Tag Mapping`；定义商品适配标签如何贡献到 PLS 语义维度。 |
| `Product` | 商品 | `canonical_product_key` | 已确认 | 跨来源统一商品身份；`product_id/sku_id/source_product_key/item_id` 等作为来源身份映射到它。 |
| `Product Category` | 商品品类 | `canonical_category_key` | 已确认 | 跨来源统一品类身份；`category_id/category_path/platform+category_id/source_category_key` 等作为来源身份或展示信息。 |
| `Brand` | 品牌 | `canonical_brand_key` | 已确认 | 跨来源统一品牌身份；`brand_name/brand_id/source_brand_key/platform+brand_name` 等作为展示或来源身份。 |
| `Match Scenario` | 匹配场景 | `scenario_code` | 已确认 | 场景作为业务标准枚举 / 决策上下文类型；具体一次任务实例后续可另建 `Match Task` 或 `Matching Run`。 |
| `Platform Profile Tag Metric` | 平台画像标签指标 | `profile_id + platform_tag_catalog_id + metric_name + profile_time_window + source_batch_id` | 已确认 | `canonical_object_key` 为归属对象；`metric_id/id` 作为来源行身份。 |
| `Profile Tag Observation` | 画像标签观测 | 暂不确认 | 后续扩展阶段再定 | 该对象已标记为后续扩展对象，当前不固化稳定身份。 |
| `Channel Dimension Feature` | 渠道维度特征 | 区分两类读取粒度 | 已确认 | 样例/人工画像：`canonical_object_key + dimension_code`；真实平台画像：`profile_id + canonical_object_key + metric_name + dimension_code + profile_time_window + source_batch_id`。 |
| `Channel Feature Matrix` | 渠道九维特征矩阵 | 区分两类读取粒度 | 已确认 | 样例/人工画像：`canonical_object_key`；真实平台画像：`profile_id + canonical_object_key + metric_name + profile_time_window + source_batch_id`。 |

## 6. 对象关系确认

| 关系 | 中文名 | Source | Target | 处理结论 | 说明 |
| --- | --- | --- | --- | --- | --- |
| `has_audience_profile` | 拥有人群画像 | `Channel Object` | `Audience Profile` | 保留 | 依据 `canonical_object_key`，这是 PLS 渠道画像匹配的核心关系。 |
| `contains_audience_tag` | 包含人群画像标签 | `Audience Profile` | `Audience Tag` | 保留 | 依据 `profile_id`，用于从画像包追溯到单条标签证据。 |
| `constrained_by_audience_taxonomy` | 受人群画像标签体系约束 | `Audience Tag` | `Audience Tag Taxonomy` | 保留 | 依据 `tag_namespace + tag_id`，用于人群侧标签标准化。 |
| `aligns_to_platform_tag` | 对齐平台画像标签 | `Audience Tag Taxonomy` | `Platform Tag` | 保留 | 可选关系，依据 `platform_tag_catalog_id`；不是所有人群标签体系项都必须来自平台标签。 |
| `maps_to_dimension` | 映射到 PLS 语义维度 | `Platform Tag` | `PLS Semantic Dimension` | 保留 | 经 `Platform Tag Mapping`，支持 `value_mapping_key` 和 `type_mapping_key` 两类身份。 |
| `has_product_fit_profile` | 拥有商品适配画像 | `Channel Object` | `Product Fit Profile` | 保留 | 依据 `canonical_object_key`，用于商品侧匹配解释。 |
| `contains_product_fit_tag` | 包含商品适配标签 | `Product Fit Profile` | `Product Fit Tag` | 保留 | 依据 `profile_id`，用于从商品适配画像追溯到单条适配证据。 |
| `constrained_by_fit_taxonomy` | 受商品适配标签体系约束 | `Product Fit Tag` | `Product Fit Taxonomy` | 保留 | 依据 `fit_type + fit_value_code`，用于商品侧标签标准化。 |
| `product_fit_tag_maps_to_dimension` | 商品适配标签映射到 PLS 语义维度 | `Product Fit Tag` | `PLS Semantic Dimension` | 保留 | 经 `Product Fit Tag Mapping`，依据 `fit_type + fit_value_code + dimension_code`。 |
| `product_belongs_to_category` | 商品属于商品品类 | `Product` | `Product Category` | 保留 | 依据 `canonical_product_key + canonical_category_key`，用于商品侧基础分类语义。 |
| `product_belongs_to_brand` | 商品属于品牌 | `Product` | `Brand` | 保留 | 依据 `canonical_product_key + canonical_brand_key`，用于商品侧品牌语义和匹配解释。 |
| `match_uses_scenario` | 匹配使用场景 | `Product` / `Channel Object` | `Match Scenario` | 保留轻量关系 | 当前 P1 保留轻量关系；后续 P2/P3 评估是否新增 `Match Task`。 |
| `binds_to_channel_object` | 渠道画像对象关联渠道画像对象 | `Channel Object` | `Channel Object` | 保留 | 经 `Channel Object Binding`，依据 `from_canonical_object_key + binding_type + to_canonical_object_key`。 |
| `metric_observes_tag` | 平台画像标签指标观测平台画像标签 | `Platform Profile Tag Metric` | `Platform Tag` | 保留 | 依据 `platform_tag_catalog_id`，真实平台画像指标通过该关系进入标签语义和 PLS 维度映射。 |
| `generates_dimension_feature` | 生成渠道维度特征 | `Audience Profile` / `Platform Profile Tag Metric` | `Channel Dimension Feature` | 保留，标记为读取模型生成关系 | 用于解释链路和特征生成链路，不是一等业务对象关系。 |
| `pivots_to_feature_matrix` | 透视为渠道九维特征矩阵 | `Channel Dimension Feature` | `Channel Feature Matrix` | 保留，标记为读取模型转换关系 | 用于说明行式特征如何变成九维宽表。 |

## 7. DataSource Gap

| Gap | 优先级 | 当前状态 | 影响 | 建议 |
| --- | --- | --- | --- | --- |
| 商品侧标签表缺口 | high | 人群侧已有 `platform_tag_catalog`、`pls_tag_type_dimension_mappings`、`pls_tag_value_dimension_mappings`；商品侧尚无对应的商品适配标签目录和 PLS 维度映射表。 | `Product Fit Taxonomy`、`Product Fit Tag`、`Product Fit Tag Mapping` 已在 OntoBase 定义，但首期 DataBase 只能从 `pls_product_fit_profiles.*_json` 临时读取，无法像人群侧一样稳定复核、映射和解释。 | OntoBase 先记录语义需求；后续向 DataBase 提出 `product_fit_tag_catalog`、`pls_product_fit_tag_type_dimension_mappings`、`pls_product_fit_tag_value_dimension_mappings`、`v_pls_product_fit_tag_semantics` 等数据源需求。 |

商品侧标签表建议命名：

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

## 8. PLS 第一阶段对象分层确认

本节只确认对象是否进入 PLS 第一阶段主线，以及后续是否进入 P2/P3 的核心 entrypoint / contract 范围；不重新讨论对象是否存在。

| 对象 | 中文名 | 分层结论 | 确认状态 | 说明 |
| --- | --- | --- | --- | --- |
| `PLS Semantic Dimension` | PLS 语义维度 | 第一阶段主线 | 已确认 | 作为平台标签、人群画像、商品适配、特征和匹配解释的共同语义坐标系。 |
| `Platform Tag` | 平台画像标签 | 第一阶段主线 | 已确认 | 承接平台原始画像语义，使实际标签指标能够连接到 PLS 维度并进入匹配解释链路。 |
| `Platform Tag Mapping` | 平台标签维度映射 | 第一阶段主线 | 已确认 | 定义平台标签到 PLS 语义维度的值级或类型级映射，支撑统一特征生成与可追溯解释。 |
| `Channel Object` | 渠道画像对象 | 第一阶段主线 | 已确认 | 作为各类渠道对象的统一业务身份，并作为画像归属和商品—渠道匹配的核心锚点。 |
| `Channel Object Binding` | 渠道对象关系 | 第一阶段主线 | 已确认 | 显式表达渠道对象之间的业务关系，支撑画像沿关系聚合、关联和解释。 |
| `Audience Profile` | 渠道人群画像 | 第一阶段主线 | 已确认 | 承载渠道对象在特定时间窗和来源批次下的人群画像集合，是渠道受众特征进入匹配流程的核心入口。 |
| `Audience Tag` | 人群画像标签 | 第一阶段主线 | 已确认 | 作为人群画像中可追溯的单条语义证据，使匹配结果能够解释到具体标签。 |
| `Audience Tag Taxonomy` | 人群画像标签体系 | 第一阶段主线 | 已确认 | 约束人群标签的类型和值，支撑跨来源标准化，避免标签退化为不可治理的自由文本。 |
| `Product Fit Profile` | 渠道商品适配画像 | 第一阶段主线 | 已确认 | 结构化描述渠道适合销售的商品，与人群画像共同支撑商品—渠道匹配。 |
| `Product Fit Tag` | 商品适配标签 | 第一阶段主线 | 已确认 | 将品类、价格带、风格、场景和投放类型等适配信息拆成可追溯、可映射的单条证据。 |
| `Product Fit Taxonomy` | 商品适配标签体系 | 第一阶段主线 | 已确认 | 定义商品适配标签允许使用的类型和标准值，是治理商品侧自由文本与补齐标签体系的语义基础。 |
| `Product Fit Tag Mapping` | 商品适配标签维度映射 | 第一阶段主线 | 已确认 | 将商品适配标签映射到 PLS 语义维度，使商品侧与渠道侧进入统一匹配坐标系。 |
| `Platform Profile Tag Metric` | 平台画像标签指标 | 第一阶段主线 | 已确认 | 承载真实平台画像在特定时间窗和来源批次下的标签指标，是事实数据进入语义映射和匹配流程的关键入口。 |
| `Product` | 商品 | 第一阶段主线 | 已确认 | 作为商品—渠道匹配的一端，稳定关联品类、品牌、商品特征、匹配场景及后续匹配结果。 |
| `Product Category` | 商品品类 | 第一阶段主线 | 已确认 | 作为商品适配语义中基础且稳定的分类轴，连接商品与渠道适配品类标签。 |
| `Brand` | 品牌 | 第一阶段主线 | 已确认 | 承载品牌调性、价格带、目标人群和历史渠道表现等商品—渠道匹配解释语义。 |
| `Match Scenario` | 匹配场景 | 第一阶段主线 | 已确认 | 显式表达匹配发生的业务语境；第一阶段只定义轻量场景标准，不扩展为任务或运行实例。 |
| `Profile Tag Observation` | 画像标签观测 | 后续扩展对象 | 已确认 | 为人工修正、模型推断和非平台报表来源预留；不进入第一阶段主线，当前不固化稳定身份。 |
| `Channel Dimension Feature` | 渠道维度特征 | 第一阶段读取模型 | 已确认 | 进入 P2/P3 的读取 entrypoint / contract，提供按 PLS 维度展开的行式特征与解释，但不作为一等业务对象。 |
| `Channel Feature Matrix` | 渠道九维特征矩阵 | 第一阶段读取模型 | 已确认 | 作为模型和匹配流程的九维宽表输入进入 P2/P3 contract；保持只读且可重新生成，不承担业务身份或事实写入职责。 |

分层确认汇总：

- 第一阶段主线对象：17 个。
- 后续扩展对象：1 个，`Profile Tag Observation`。
- 第一阶段读取模型：2 个，`Channel Dimension Feature`、`Channel Feature Matrix`。
- 本轮对象分层已全部确认，可作为 P2 语义读取入口和 P3 联合契约范围设计的直接依据。
