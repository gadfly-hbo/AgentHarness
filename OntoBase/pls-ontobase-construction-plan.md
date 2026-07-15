# PLS OntoBase 建设方案

日期：2026-07-15

## 1. 建设目标

PLS 是 OntoBase 的第一根承重梁。第一期目标不是把 OntoBase 做成完整平台，而是用 `PLS 渠道画像匹配项目` 跑通一条可复用的本体建设方法。

核心目标：

1. 把 PLS 渠道画像匹配中的业务对象、维度、标签、画像、指标、规则和动作沉淀为独立本体。
2. 明确 OntoBase 与 DataBase 的首期联合契约，但不把 OntoBase 做成 DataBase 的附属层。
3. 让外部产品或模型可以通过 OntoBase 理解“这些数据代表什么、为什么可以匹配、匹配结果如何解释”。
4. 为后续 `MemoryBase`、`KnowledgeBase`、`Console` 加入 PLS 联合场景预留清晰接口。

一句话：DataBase 给事实和特征，OntoBase 给业务语义和解释框架，二者通过显式联合契约共同服务 PLS。

## 2. 建设原则

### 2.1 独立优先

OntoBase 必须能独立说明自己的对象、关系、指标、规则和动作。DataBase 的表/view 只是第一期外部数据源之一，不是 OntoBase 的宿主。

### 2.2 先确定性，后智能化

第一期不依赖 LLM 自动抽取做主线。先从 PLS 业务语义、现有标准、现有 DataBase view 和字段中确定性生成本体清单。LLM 只能在后期作为草稿生成器。

### 2.3 先一条闭环，后全量扩展

第一条闭环必须小而完整：

```text
Channel Object
  -> Audience Profile
  -> Audience Tag
  -> Platform Tag
  -> PLS Semantic Dimension
  -> Channel Dimension Feature
  -> Channel Feature Matrix
  -> Match Explanation
```

这条链路跑通后，再扩展真实画像指标、商品适配、人工复核、记忆沉淀和控制台流程。

### 2.4 联合契约显式化

任何跨库关系都要写成 contract：

- OntoBase 哪个语义对象引用 DataBase 哪个读取入口。
- 稳定身份键是什么。
- 谁负责维护语义，谁负责维护事实数据。
- 变更时如何判断是否需要双向对齐。

## 3. 阶段方案

### P0：边界与启动文档

状态：已启动。

已有产物：

- `docs/four-bases-one-console-contract.md`
- `OntoBase/ontology-kickoff-research-summary.md`
- `OntoBase/ontobase-domain-model.md`
- `OntoBase/ontobase-pls-build-plan.md`

验收：

- 能明确四库一台独立解耦。
- 能明确 OntoBase 不是 DataBase 上方附属层。
- 能明确 PLS 是第一期联合契约场景。

### P1：PLS 本体清单

状态：已完成 v0.1。

目标：形成第一版 PLS Ontology Inventory。

产物：

```text
OntoBase/pls-ontology-inventory.md
```

内容：

- `Ontology`：`PLS 渠道画像匹配本体`
- `ObjectType`：渠道对象、平台标签、PLS 语义维度、人群画像、商品适配画像、真实画像指标、特征矩阵。
- `PropertyType`：身份键、展示名、语义编码、特征值、置信度、来源、时间窗、质量标记。
- `LinkType`：标签映射维度、渠道对象拥有人群画像、渠道对象拥有商品适配画像、画像生成特征矩阵。
- `MetricDefinition`：九维 score、真实画像 metric sum、标签权重、映射置信度。
- `LogicRule`：九维空间、身份键、特征可追溯、view 只读等约束。
- `ActionType`：导入画像、复核未映射标签、刷新特征、解释匹配。

方法：

1. 先从业务对象出发列本体，不从数据库表名出发。
2. 再把每个对象绑定首期外部数据源。
3. 对每个对象明确“业务定义、稳定身份、主要属性、首期来源、消费场景”。

验收：

- 不打开数据库也能理解 PLS 本体对象。
- 打开 DataBase 时能找到每个对象的首期数据源。
- 每个对象至少有业务定义和稳定身份策略。

### P2：PLS 匹配语义入口

目标：定义 PLS 渠道画像匹配应如何消费 OntoBase + DataBase。

建议产物：

```text
OntoBase/pls-matching-semantic-entrypoints.md
```

必须回答：

- 候选渠道对象从哪里读。
- 样例/人工画像特征从哪里读。
- 真实平台画像特征从哪里读。
- 行式解释从哪里读。
- 标签级解释从哪里读。
- OntoBase 如何解释这些入口的业务含义。

推荐首期入口：

| 场景 | DataBase 首期入口 | OntoBase 解释 |
| --- | --- | --- |
| 渠道对象候选集 | `v_pls_channel_profile_overview` | `Channel Object` 的画像覆盖情况 |
| 样例渠道特征宽表 | `v_pls_channel_feature_matrix` | `PLS Dimension Score` |
| 真实画像特征宽表 | `v_platform_profile_channel_feature_matrix` | `Platform Profile Dimension Metric Sum` |
| 渠道维度解释 | `v_pls_channel_dimension_features` | 渠道对象在某 PLS 维度上的标签贡献 |
| 真实画像维度解释 | `v_platform_profile_channel_dimension_features` | 真实画像指标在某 PLS 维度上的贡献 |
| 标签级语义 | `v_pls_audience_tag_semantics`、`v_platform_profile_tag_metric_semantics` | 标签、指标、维度之间的解释链 |
| 标签标准解释 | `v_pls_platform_tag_value_semantics` | 平台标签值如何映射 PLS 维度 |

验收：

- PLS 产品或 ModelEvol 不需要猜表。
- 每个入口都能说明粒度、身份键、适用场景和限制。
- 读模型特征和读解释证据被清楚区分。

### P3：PLS 联合契约

目标：把 DataBase 和 OntoBase 的协作写成明确 contract。

建议产物：

```text
OntoBase/contracts/pls-channel-matching-contract.md
```

建议结构：

- 消费场景：`PLS 渠道画像匹配`
- 参与部分：`DataBase`、`OntoBase`，后续预留 `MemoryBase`、`KnowledgeBase`、`Console`
- 跨库身份键：`canonical_object_key`、`platform_tag_catalog_id`、`dimension_code`、`profile_id`
- DataBase 负责的读取入口和写入入口
- OntoBase 负责的语义对象、规则和动作
- 变更规则：哪些变化只影响单库，哪些变化影响 contract
- 版本号：从 `v0.1` 开始

验收：

- 任何后来者能通过 contract 知道 PLS 第一阶段怎么消费 Harness。
- DataBase 和 OntoBase 的责任边界不会混淆。
- contract 可以版本化。

### P4：OntoBase 独立存储草案

目标：设计 OntoBase 自己的存储形态，但暂不急于实现。

候选方案：

1. `Markdown-first`：先用文档维护本体，适合早期快速迭代。
2. `SQLite独立库`：例如 `OntoBase/ontobase.sqlite`，适合后续查询、图谱和 Console。
3. `JSON/YAML contract`：适合产品和模型直接消费。
4. `Service API`：适合跨项目共享和权限治理。

建议第一期采用：

```text
Markdown-first + JSON contract 草案
```

不建议第一期直接做完整 UI 或复杂 RDF/OWL 存储。

后续独立 schema 可包含：

- `ontologies`
- `object_types`
- `property_types`
- `link_types`
- `metric_definitions`
- `logic_rules`
- `action_types`
- `source_bindings`
- `contract_versions`

验收：

- schema 不依赖 `DataBase/agentharness.sqlite`。
- `source_bindings` 可以绑定数据库、API、文件、文档、产品服务等来源。
- 存储只承载语义和绑定，不复制事实行数据。

### P5：解释链路与图谱

目标：从本体清单生成第一版可解释图谱。

首批节点：

- `Channel Object`
- `Audience Profile`
- `Platform Tag`
- `PLS Semantic Dimension`
- `Channel Dimension Feature`
- `Channel Feature Matrix`
- `Product Fit Profile`
- `Platform Profile Tag Metric`

首批边：

- `has_audience_profile`
- `maps_to_dimension`
- `observes_tag`
- `generates_feature_matrix`
- `uses_dimension_standard`
- `has_product_fit_profile`

解释问题样例：

- 某渠道对象为什么适合某类商品？
- 某渠道对象在哪些 PLS 维度上强？
- 某个 PLS 维度由哪些平台标签贡献？
- 某个真实平台画像指标如何进入九维特征？

验收：

- 任一渠道对象的九维得分可以追溯到标签/指标证据。
- 解释链路能区分样例画像和真实平台画像。
- 图谱是 OntoBase 语义投影，不是 DataBase 血缘图的复制。

### P6：接入 MemoryBase、KnowledgeBase、Console

目标：当 `DataBase + OntoBase` 的 PLS 小闭环稳定后，再扩展到四库一台。

建议进入顺序：

1. `KnowledgeBase`：收 PLS 业务标准、平台标签资料、导入规范、调研材料。
2. `MemoryBase`：收人工复核经验、映射修正、匹配失败教训、模型迭代经验。
3. `Console`：做导入、预检、复核、刷新、解释、发布的控制入口。

验收：

- 每次新增库参与，都有 contract 更新。
- Console 只编排，不硬编码语义。
- MemoryBase 记录经验，不替代 OntoBase 规则。
- KnowledgeBase 保存来源，不替代 OntoBase 本体。

## 4. 推荐近期执行顺序

### 第 1 步：完成 PLS 本体清单

状态：已完成 v0.1。

输出：

```text
OntoBase/pls-ontology-inventory.md
```

这一步完成后，OntoBase 已经从“架构概念”进入“PLS 业务语义资产”。

### 第 2 步：完成 PLS 匹配语义入口

输出：

```text
OntoBase/pls-matching-semantic-entrypoints.md
```

这一步让产品和模型知道怎么读，不再靠猜。

### 第 3 步：完成 PLS 联合契约

输出：

```text
OntoBase/contracts/pls-channel-matching-contract.md
```

这一步让 DataBase 和 OntoBase 的协作可以版本化和审计。

### 第 4 步：设计 OntoBase 独立 schema

输出：

```text
OntoBase/ontobase-storage-schema-v0.1.md
```

这一步只设计，不急于实现。

### 第 5 步：做解释链路样例

输出：

```text
OntoBase/examples/pls-channel-match-explanation-example.md
```

这一步验证 OntoBase 是否真的能帮助解释 PLS 匹配。

## 5. 第一阶段验收标准

第一阶段可以认为建设稳固，当满足：

1. PLS 的核心业务对象不依赖数据库表名也能被解释。
2. 每个业务对象都有稳定身份策略。
3. 每个核心对象都有首期外部数据源绑定。
4. PLS 特征宽表能被解释到维度、标签、指标来源。
5. DataBase 变更不会自动牵动 OntoBase，除非联合契约受影响。
6. OntoBase 新增规则不会强迫 DataBase 立即改 schema。
7. 后续 MemoryBase、KnowledgeBase、Console 加入时有明确位置。

## 6. 风险与控制

| 风险 | 表现 | 控制方式 |
| --- | --- | --- |
| OntoBase 退化成字段说明 | 只解释表和列，不表达业务对象 | 始终从业务对象建模，再绑定数据源 |
| 与 DataBase 假解耦 | 直接依赖内部表结构，缺少 contract | 所有跨库引用写进联合契约 |
| 第一阶段过大 | 同时做 UI、LLM、RDF、服务化 | 先做 Markdown 清单和小闭环 |
| 身份键不稳定 | 跨库对象无法对齐 | 优先定义 `canonical_object_key`、`dimension_code` 等身份策略 |
| 解释链断裂 | 模型得分无法追溯 | 每个特征必须能回到维度、标签或指标来源 |
| Console 大泥球 | UI 硬编码四库逻辑 | Console 只读取 contract 并编排流程 |

## 7. 当前结论

PLS OntoBase 建设应从“语义资产”开始，而不是从“系统功能”开始。

最小可行路径：

```text
本体清单
  -> 语义读取入口
  -> 联合契约
  -> 独立存储草案
  -> 解释链路样例
  -> 四库一台扩展
```

这条路径能让 OntoBase 既独立，又能和 DataBase 在 PLS 项目中形成真实协作，不会变成空泛架构。
