# OntoBase 领域模型与 PLS 首期协作契约

日期：2026-07-15

## 1. 定位

OntoBase 是独立的业务语义层项目。它不属于 `DataBase/agentharness.sqlite`，也不是数据库的上层封装、字段注释扩展或附属知识库。

AgentHarness 的顶层结构是“四库一台”：`DataBase`、`OntoBase`、`MemoryBase`、`KnowledgeBase`、`Console`。它们彼此独立解耦，通过联合契约共同构成 Harness，供外部产品或项目消费。本文遵守 `docs/four-bases-one-console-contract.md` 中的边界。

OntoBase 负责沉淀跨项目可复用的业务对象、属性语义、关系、指标口径、规则、动作和治理语义。DataBase 负责结构化数据承接、导入、校验和查询能力。两者完全解耦，可以独立演进。

当前第一期选择与 DataBase 联合支持 PLS 渠道画像匹配项目。因此本文只定义首期协作边界：OntoBase 如何表达 PLS 业务语义，DataBase 如何作为其中一个外部数据源提供 PLS 事实数据和特征 view。

核心关系：

```text
OntoBase = 独立业务语义层 / 决策语义层 / AI 上下文入口
DataBase = 独立数据承接项目 / 首期 PLS 事实数据源之一
PLS 渠道画像匹配 = OntoBase 与 DataBase 第一阶段联合交付场景
```

## 2. 与 DataBase 的首期协作分工

| 项目 | 负责什么 | 首期承载 |
| --- | --- | --- |
| OntoBase | PLS 业务对象、语义属性、业务关系、指标口径、规则、动作、解释语义、上下文入口 | `OntoBase/*.md`，后续独立选择自己的存储与服务形态 |
| DataBase | PLS 相关表、view、字段、行数据、导入链路、校验 SQL | `DataBase/agentharness.sqlite`、migrations、seeds、validations、docs |
| 产品/模型 | 渠道匹配、画像解释、商品适配、实验特征读取 | PLS 产品模块、ModelEvol |

协作原则：

- OntoBase 不依赖 DataBase 的存储实现；DataBase 也不依赖 OntoBase 才能完成数据导入和查询。
- 首期 PLS 中，DataBase 暴露表/view 作为 OntoBase 的一个数据源绑定对象。
- OntoBase 不复制 DataBase 行数据，只引用外部数据源入口并维护业务语义。
- 如果未来 PLS 数据来自 API、文件、其他数据库或产品服务，OntoBase 仍应能用同一套语义模型表达。

## 3. 第一版核心概念

### 3.1 Ontology

一个业务语义容器。第一版建议只有一个主本体：

```text
PLS 渠道画像匹配本体
```

首期协作数据源包括 `DataBase/agentharness.sqlite` 中的 PLS 相关表/view，但该数据源只是本体实例的外部来源之一，不是 OntoBase 的宿主。

### 3.2 ObjectType

业务对象类型。第一阶段从 PLS 渠道画像匹配需求出发识别这些对象，并参考当前 DataBase 已有数据源作为首批落地来源：

| ObjectType | 类型 | 首期外部数据源 | 业务含义 |
| --- | --- | --- | --- |
| `PLS Semantic Dimension` | concept + dataset | `pls_semantic_dimensions` | PLS 三层九维标准语义空间 |
| `Platform Tag` | dataset | `platform_tag_catalog` | 平台原始标签目录，来自天猫、抖音、京东等 |
| `Platform Tag Mapping` | dataset | `pls_tag_value_dimension_mappings`、`pls_tag_type_dimension_mappings` | 平台标签到 PLS 维度的映射 |
| `Channel Object` | dataset | `pls_channel_objects` | 渠道画像匹配的核心业务对象，如平台、账号、店铺、场景等 |
| `Channel Object Binding` | dataset | `pls_channel_object_bindings` | 渠道对象之间的业务关系 |
| `Audience Profile` | dataset | `pls_audience_profiles` | 渠道人群画像 |
| `Product Fit Profile` | dataset | `pls_product_fit_profiles` | 渠道对象的商品适配画像 |
| `Profile Tag Observation` | dataset | `profile_tag_observations` | 主体命中的标签观测事实 |
| `Platform Profile Tag Metric` | dataset | `platform_profile_tag_metrics` | 三平台真实画像标签指标长表 |
| `Channel Feature Matrix` | view-backed dataset | `v_pls_channel_feature_matrix`、`v_platform_profile_channel_feature_matrix` | 渠道对象九维特征宽表，供匹配和模型消费 |

### 3.3 PropertyType

属性语义。PropertyType 不等同于数据库列名；数据库字段只是首期数据源绑定的一种载体。OntoBase 要补齐业务解释、数据角色和消费方式。

第一阶段建议至少给字段打这些语义角色：

| 角色 | 含义 | 示例字段 |
| --- | --- | --- |
| `identity_key` | 稳定身份键 | `canonical_object_key`、`platform_tag_catalog_id`、`dimension_id` |
| `business_label` | 面向用户展示的名称 | `display_name`、`dimension_name`、`leaf_label` |
| `semantic_code` | 标准语义编码 | `layer_code`、`dimension_code` |
| `feature_value` | 模型或匹配可用的特征值 | `p_demographics_score`、`dimension_metric_sum`、`metric_value` |
| `confidence` | 映射、画像或抽取置信度 | `confidence`、`mapping_confidence`、`avg_mapping_confidence` |
| `provenance` | 来源与批次追溯 | `source_file`、`source_row`、`source_batch_id`、`data_version` |
| `time_window` | 画像或指标时间窗 | `time_window`、`profile_time_window` |
| `quality_control` | 质量和人工复核状态 | `quality_flags_json`、`manual_review_status`、`possible_duplicate` |

### 3.4 LinkType

LinkType 描述业务对象之间的关系。第一阶段不要过度推理，先表达 PLS 渠道画像匹配中已经稳定的业务关系，并记录当前可用的数据源依据。

| LinkType | 起点 | 终点 | 首期数据源依据 | 用途 |
| --- | --- | --- | --- | --- |
| `maps_to_dimension` | `Platform Tag` | `PLS Semantic Dimension` | `pls_tag_value_dimension_mappings.dimension_id` | 解释平台标签如何贡献 PLS 维度 |
| `observes_tag` | `Profile Tag Observation` | `Platform Tag` | `profile_tag_observations.platform_tag_catalog_id` | 解释主体命中了哪些平台标签 |
| `has_audience_profile` | `Channel Object` | `Audience Profile` | `canonical_object_key` | 渠道人群画像归属 |
| `has_product_fit_profile` | `Channel Object` | `Product Fit Profile` | `canonical_object_key` | 渠道商品适配画像归属 |
| `binds_to_channel_object` | `Channel Object` | `Channel Object` | `pls_channel_object_bindings` | 渠道对象关系 |
| `generates_feature_matrix` | `Audience Profile` / `Platform Profile Tag Metric` | `Channel Feature Matrix` | 下游 view 链路 | 说明特征宽表来源 |
| `uses_dimension_standard` | `Channel Feature Matrix` | `PLS Semantic Dimension` | 九维 score / metric_sum 列 | 说明特征列对应的 PLS 维度 |

### 3.5 MetricDefinition

MetricDefinition 是 OntoBase 与 PLS 匹配模型之间的关键接口。首期 DataBase 数据源里已经出现两类指标形态：

1. 画像标签指标长表中的 `metric_name`、`metric_value`、`metric_unit`。
2. PLS 九维特征宽表中的九个 score / metric_sum 列。

第一阶段应把这些定义为语义指标，而不是只当字段：

| MetricDefinition | 首期数据源入口 | 粒度 | 说明 |
| --- | --- | --- | --- |
| `PLS Dimension Score` | `v_pls_channel_feature_matrix` | `canonical_object_key + dimension_code` | 样例渠道画像标签聚合出的九维得分 |
| `Platform Profile Dimension Metric Sum` | `v_platform_profile_channel_feature_matrix` | `canonical_object_key + metric_name + dimension_code` | 真实平台画像指标按 PLS 维度聚合后的数值 |
| `Tag Observation Weight` | `profile_tag_observations.observation_weight` | `subject_id + tag` | 主体命中标签的权重 |
| `Mapping Confidence` | 多个语义 view | `tag/value mapping` | 标签映射到 PLS 维度的可信度 |
| `Audience/Profile Confidence` | `pls_audience_profiles`、`pls_product_fit_profiles` | `profile_id` | 画像生成或导入的可信度 |

### 3.6 LogicRule

LogicRule 表达业务约束和匹配前提。第一阶段建议先沉淀为文档规则，后续再落表。

建议初始规则：

| LogicRule | 说明 |
| --- | --- |
| `PLS_DIMENSION_SPACE_IS_NINE_DIMENSIONS` | PLS 当前标准维度必须是 P/L/S 三层九维。 |
| `CHANNEL_OBJECT_KEY_IS_MATCHING_IDENTITY` | 渠道匹配以 `canonical_object_key` 作为渠道对象稳定身份。 |
| `TAG_VALUE_MAPPING_EXPLAINS_FEATURES` | 任何 PLS 维度特征都应能追溯到平台标签映射或画像标签映射。 |
| `FEATURE_MATRIX_IS_READ_MODEL` | 首期 DataBase 中的 `v_pls_channel_feature_matrix` 和 `v_platform_profile_channel_feature_matrix` 是匹配/模型消费入口，不直接写入。 |
| `REAL_PROFILE_METRICS_ARE_LONG_TABLE_INPUT` | 首期 DataBase 中真实平台画像导入只写 `platform_profile_tag_metrics` 长表，下游语义展开由 view 生成。 |

### 3.7 ActionType

ActionType 先描述业务动作，不急于执行代码。

| ActionType | 触发条件 | 预期动作 |
| --- | --- | --- |
| `Import Platform Profile Metrics` | 获得天猫/抖音/京东真实画像 CSV | 预检并写入 `platform_profile_tag_metrics` |
| `Review Unmapped Tag` | 标签无法映射到 PLS 维度 | 进入人工映射/复核流程 |
| `Refresh Channel Feature Matrix` | 渠道对象、人群画像、真实画像指标更新 | 重新读取下游 view，刷新模型输入 |
| `Explain Channel Match` | 需要解释渠道与商品/人群匹配原因 | 从语义 view 和 OntoBase 关系追溯标签、维度、指标 |
| `Promote Mapping Standard` | 某类标签映射稳定且通过复核 | 更新映射标准和字段注释，纳入后续导入 |

### 3.8 SecurityPolicy

第一阶段不建设完整权限系统，但要在语义层预留治理语义：

- 哪些对象可以写入，哪些只读。
- 哪些 action 需要人工确认。
- 哪些字段含来源、批次、质量标记，必须在解释和模型输入中保留。
- 哪些真实画像数据只能通过导入器写库，不能手工直接改 view。

## 4. OntoBase 与数据库对象的首批绑定

这里的“绑定”是首期项目协作中的外部数据源绑定，不表示 OntoBase 隶属于 DataBase。

| OntoBase 语义对象 | 首期绑定方式 | DataBase 读取入口 |
| --- | --- | --- |
| 渠道对象总览 | view-backed object | `v_pls_channel_profile_overview` |
| 渠道人群标签语义 | view-backed object | `v_pls_audience_tag_semantics` |
| 渠道维度行特征 | view-backed object | `v_pls_channel_dimension_features` |
| 渠道九维特征宽表 | view-backed object | `v_pls_channel_feature_matrix` |
| 真实画像标签指标语义 | view-backed object | `v_platform_profile_tag_metric_semantics` |
| 真实画像维度行特征 | view-backed object | `v_platform_profile_channel_dimension_features` |
| 真实画像九维特征宽表 | view-backed object | `v_platform_profile_channel_feature_matrix` |
| 平台标签值语义 | view-backed object | `v_pls_platform_tag_value_semantics` |

## 5. 首期协作变更规则

OntoBase 与 DataBase 解耦演进，但第一期共同服务 PLS 渠道画像匹配。凡是影响 PLS 协作契约的变化，需要由对应项目维护自己的材料，并在必要时更新跨项目绑定说明：

1. DataBase 新增或调整 PLS table/view/字段时，DataBase 维护自己的数据库文档、字段注释和血缘图。
2. 如果这些变化影响 OntoBase 的 PLS 语义对象、属性、关系、指标或动作，OntoBase 再更新对应语义文档。
3. OntoBase 新增业务概念、规则、动作或指标口径时，不要求 DataBase 立即改 schema；只有当需要结构化承接事实数据时，再向 DataBase 提出数据源需求。
4. 跨项目只维护“PLS 首期协作绑定”：哪些 OntoBase 语义对象当前读取哪些 DataBase 入口。

因此，OntoBase 的更新不是 DataBase 变更的机械附属步骤；只有协作契约受影响时才需要双向对齐。
