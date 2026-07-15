# OntoBase x PLS 渠道画像匹配启动计划

日期：2026-07-15

## 1. 启动判断

OntoBase 是独立项目。第一期选择与 DataBase 联合推进 PLS 渠道画像匹配项目。

这个判断服从 AgentHarness 的“四库一台”顶层契约：`DataBase`、`OntoBase`、`MemoryBase`、`KnowledgeBase`、`Console` 彼此独立解耦，通过联合契约共同组成 Harness。PLS 渠道画像匹配只是第一期联合场景，不改变任何一库一台的独立性。

当前 DataBase 已经具备一批 PLS 相关事实数据与查询能力，可作为 OntoBase 首期 PLS 本体的数据源之一：

- PLS 三层九维标准：`pls_semantic_dimensions`
- 平台标签目录：`platform_tag_catalog`
- 平台标签到 PLS 维度映射：`pls_tag_value_dimension_mappings`
- 渠道对象库：`pls_channel_objects`
- 渠道对象关系：`pls_channel_object_bindings`
- 渠道人群画像：`pls_audience_profiles`
- 渠道商品适配画像：`pls_product_fit_profiles`
- 真实画像标签指标长表：`platform_profile_tag_metrics`
- 渠道对象和真实画像的九维特征 view：`v_pls_channel_feature_matrix`、`v_platform_profile_channel_feature_matrix`

首期协作缺口是：DataBase 已经能回答“表和字段怎么查”，但 PLS 项目还需要一个独立业务语义层回答“这些对象在业务世界里是什么、它们如何关联、哪个数据源入口可供模型使用、哪个字段承担身份键或指标角色、哪个链路用于解释匹配结果”。

OntoBase 因此应独立启动，并在第一期与 DataBase 建立 PLS 项目协作契约。第一目标不是做通用本体平台，而是先把 PLS 渠道画像匹配的业务语义跑通。

## 2. 第一阶段目标

第一阶段交付物是“可维护的 PLS 语义层规格”，而不是先做复杂 UI。

目标：

1. 定义 PLS 本体的对象、属性、关系、指标、规则、动作。
2. 明确每个语义对象在第一期可引用哪些 DataBase table/view 作为外部数据源。
3. 明确 PLS 匹配模型和产品优先读取哪些首期数据源入口。
4. 明确 OntoBase 与 DataBase 的解耦边界和协作变更规则。
5. 为后续 OntoBase 独立存储、服务或前端图谱留出稳定契约。

## 3. 分期计划

### P0：文档启动

状态：进行中。

产物：

- `ontology-kickoff-research-summary.md`
- `ontobase-domain-model.md`
- `ontobase-pls-build-plan.md`
- `pls-ontobase-construction-plan.md`

验收：

- 能清楚回答 OntoBase 和 DataBase 的解耦边界与首期协作分工。
- 能列出 PLS 首批 ObjectType、LinkType、MetricDefinition、LogicRule、ActionType。
- 能指出首批引用的 DataBase table/view 外部数据源。

### P1：确定性本体清单

状态：已完成 v0.1，已完成业务实体、身份键、对象关系、DataSource Gap 和第一阶段对象分层确认；见 `OntoBase/pls-ontology-inventory.md` 与 `OntoBase/pls-ontology-business-calibration.md`。

目标：从 PLS 业务语义出发生成一份本体清单，并把现有 DataBase 文档和 SQLite schema 作为首期事实校准来源。

建议产物：

```text
OntoBase/pls-ontology-inventory.md
```

内容：

- ObjectType 清单：每个对象的业务定义、首期数据源、主键/身份键、展示名、用途。
- PropertyType 清单：每个关键字段的语义角色。
- LinkType 清单：对象间关系和数据库依据。
- MetricDefinition 清单：九维 score、真实画像 metric、置信度和权重。

注意：P1 不依赖 LLM 抽取。业务概念由 OntoBase 定义，首期字段和数据入口用确定性数据库结构和现有文档校准。

### P2：PLS 匹配语义入口

目标：定义 PLS 渠道画像匹配的“首期数据源读取入口”。

建议产物：

```text
OntoBase/pls-matching-semantic-entrypoints.md
```

需要明确：

- 渠道对象候选集读 `v_pls_channel_profile_overview`。
- 样例/人工画像特征读 `v_pls_channel_feature_matrix`。
- 真实平台画像特征读 `v_platform_profile_channel_feature_matrix`。
- 行式解释读 `v_pls_channel_dimension_features` 和 `v_platform_profile_channel_dimension_features`。
- 标签级解释读 `v_pls_audience_tag_semantics` 和 `v_platform_profile_tag_metric_semantics`。
- 平台标签标准解释读 `v_pls_platform_tag_value_semantics`。

验收：

- 产品和 ModelEvol 不需要猜“该读哪张表”。
- 每个入口都能说明业务粒度、主键、维度、适用场景。

### P3：OntoBase 独立存储草案

目标：在不急于落库的前提下，先设计 OntoBase 后续可独立落库或服务化的 schema。该 schema 不默认落入 `DataBase/agentharness.sqlite`。

候选表：

- `ontobase_ontologies`
- `ontobase_object_types`
- `ontobase_property_types`
- `ontobase_link_types`
- `ontobase_metric_definitions`
- `ontobase_logic_rules`
- `ontobase_action_types`
- `ontobase_source_bindings`

关键点：

- `source_binding` 必须能绑定到 `database/table/view/column/sql_query/doc_path/api_endpoint/file` 等外部来源。
- OntoBase 记录语义，不复制事实数据。
- 首期绑定到 DataBase 的对象要能追溯到 `DataBase/docs/*` 和 SQLite schema；未来绑定其他来源时按对应来源记录。

### P4：跨项目协作变更机制

目标：让 OntoBase 与 DataBase 在 PLS 首期协作中保持清晰边界，避免互相变成附属模块。

需要明确：

- DataBase 的表、view、字段、导入、校验仍由 DataBase 文档体系维护。
- OntoBase 的对象、属性语义、关系、指标、规则、动作仍由 OntoBase 文档体系维护。
- 只有当 PLS 首期协作的数据源绑定受影响时，双方才更新跨项目绑定说明。
- OntoBase 新增业务概念不自动要求 DataBase 改 schema；DataBase 新增字段也不自动要求 OntoBase 纳入语义层。

注意：当前只新增/修正 OntoBase 文档，未修改数据库结构，因此不触发数据库概览材料强制维护。

### P5：图谱与解释层

目标：把 PLS 语义层投影成图谱，用于后续控制台展示和匹配解释。

首批节点：

- PLS 三层九维
- 平台标签类型/标签值
- 渠道对象
- 人群画像
- 商品适配画像
- 真实画像指标
- 九维特征宽表

首批边：

- 标签值 -> PLS 维度
- 渠道对象 -> 人群画像
- 渠道对象 -> 商品适配画像
- 真实画像指标 -> 标签值
- 标签/指标 -> 维度特征
- 维度特征 -> 九维宽表

### P6：LLM 草稿抽取

目标：在确定性本体稳定后，再让 LLM 从业务文档中抽取概念、规则、动作草稿。

原则：

- LLM 只生成草稿。
- 必须经过 validator 和人工确认。
- 不允许把 LLM 草稿当成 DataBase 真实结构或事实数据。
- 抽取结果优先补充 `concept`、`logic_rule`、`action_type`，不要自动改数据库 schema。

## 4. 首批 PLS 本体切片

建议先做一个小闭环：

```text
Channel Object
  -> Audience Profile
  -> Audience Tag
  -> Platform Tag
  -> PLS Semantic Dimension
  -> Channel Dimension Feature
  -> Channel Feature Matrix
```

这条链路首期可引用的 DataBase 入口：

```text
pls_channel_objects
  -> pls_audience_profiles
  -> pls_audience_tag_dimension_mappings
  -> platform_tag_catalog / pls_tag_value_dimension_mappings
  -> pls_semantic_dimensions
  -> v_pls_channel_dimension_features
  -> v_pls_channel_feature_matrix
```

业务价值：

- 可以解释一个渠道对象为什么在某些 PLS 维度上得分。
- 可以给 PLS 渠道画像匹配提供第一版语义特征。
- 可以为后续真实平台画像导入接入同一套 PLS 维度语义。

## 5. 近期行动清单

1. 已完成 `pls-ontology-inventory.md`，形成 PLS 本体 v0.1 清单。
2. 下一步补 `pls-matching-semantic-entrypoints.md`，固定 PLS 匹配读取入口。
3. 随后补 `OntoBase/contracts/pls-channel-matching-contract.md`，把 DataBase 与 OntoBase 的首期协作版本化。
4. 再评估 OntoBase 是否需要独立 schema / 独立 SQLite / 独立服务；不默认落入 `DataBase/agentharness.sqlite`。
5. 当真实画像指标开始有数据后，优先更新真实画像指标相关 MetricDefinition。
6. 下一次 DataBase 新增 PLS 表/view/字段时，只在影响 PLS 首期协作绑定或语义解释时更新 OntoBase 文档。
