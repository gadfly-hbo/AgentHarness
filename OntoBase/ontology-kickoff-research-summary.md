# OntoBase 本体库建设启动调研摘要

日期：2026-07-15

## 1. 调研范围

本次只做启动前的轻量调研，覆盖两类信息：

1. Palantir Foundry / AIP 语境下的 Ontology，一手资料以 Palantir 官方文档为主，补充一篇 Palantir 参与的 concept-centric software development 论文。
2. `/Users/huangbo/Dev/Projects/pi-xanthil` 中已经落地的本体库模块 `onto-xanthil`，重点看设计文档、数据库表、后端路由、抽取/校验/导出和前端说明。

## 2. Palantir Ontology 要点

Palantir 把 Ontology 定义为组织的 digital twin：它不是抽象 ER 图，而是把组织的数据集、模型、对象、关系和可执行动作组织成一个面向业务操作的整体。官方文档中，Ontology 的核心元素包括：

- `Object type`：组织中的实体或事件类型，例如 Employee、Flight。
- `Object`：某个 object type 的实例，对应真实世界中的单个实体或事件。
- `Property`：对象特征，对应数据集中的列。
- `Link type`：两个 object types 之间的关系，类似数据集之间的 join，但语义上表达真实世界关系。
- `Action type`：用户一次性修改对象、属性值、链接的事务定义，可带参数、校验、权限和 side effects。
- `Role`：Ontology 的核心权限模型，可在 ontology 或单个资源层级授权。
- `Function`：可读取对象、对象集合和属性，也可被 action type 与应用复用的代码逻辑。

它的关键心智不是“先建一套概念词典”，而是“把数据映射成可操作的业务世界”：

- 数据集约等于 object type。
- 行约等于 object。
- 列约等于 property。
- join 约等于 link type。
- 业务修改入口约等于 action type。

Palantir Action 的价值在于把“编辑数据”提升为“执行业务动作”。一个 action 可以修改多个对象和链接，带参数、规则、权限校验、通知等 side effects，并把结果写回，使多个前端应用共享同一套动作语义。

Palantir 官方的 `Why create an Ontology?` 进一步把 Ontology 放到“决策系统”里理解：Ontology 表示企业中的决策，而不只是数据；每个运营决策由 `Data`、`Logic`、`Action`、`Security` 四部分组成。这里的含义是：

- `Data`：做决策需要的数据，包括企业数据、实时数据、边缘数据、非结构化数据，以及用户/agent 在决策过程中产生的 decision data。
- `Logic`：评估决策的启发式规则、计算过程、模型、优化算法、业务系统逻辑。
- `Action`：对已选择决策的编排、执行、写回和后续闭环。
- `Security`：保证数据、逻辑和动作在权限、策略、审计和操作边界内执行。

这点对 OntoBase 很关键：本体库如果只建 `object/property/link`，仍然偏静态；如果同时建 `metric/logic/action/security` 的治理语义，才更接近“分析到行动”的操作系统。

Palantir 参与的 2023 年论文 `Concept-Centric Software Development` 还有一个值得借鉴的观点：复杂系统需要显式管理“概念”。Palantir 内部把 concept 作为本体中的一种对象，连接到功能、应用、团队、bug、文档等实体，用来降低概念熵、减少同名异义/异名同义、支持跨团队协作。这对 OntoBase 的启发是：本体库不应只收表结构，还应收“用户理解系统所需的概念、动作和约束”。

## 3. pi-xanthil 本体模块摘要

`pi-xanthil` 的 `onto-xanthil` 已经是一个较完整的轻量本体库实现。它明确借 Palantir 的 `object/link/action` 心智，但做成本地优先、数据分析导向的“数据语义层”。

### 3.1 产品定位

设计文档 `/Users/huangbo/Dev/Projects/pi-xanthil/docs/onto-xanthil-design.md` 给出的定位很清晰：

- `onto-xanthil` 回答“数据是什么”。
- 规则记忆 / 知识图谱回答“我们怎么分析”。
- 两层并立，但共用图谱展示底座。

前端说明页也保持同样表述：本体库把零散的数据集、字段、业务规则组织成机器可理解的领域本体。

### 3.2 数据模型

后端实际表结构位于 `/Users/huangbo/Dev/Projects/pi-xanthil/server/src/db/viz.ts`，核心表包括：

- `ontologies`：本体容器，含 workspace、名称、领域、版本、状态。
- `object_types`：对象类型，分为 `dataset` 和 `concept`；`dataset` 可绑定聚合数据集 `bound_path_id`。
- `property_types`：对象属性，可绑定数据列 `bound_column`，并标注 `semantic_type`。
- `link_types`：对象关系，支持 `join`、`fk`、`is-a`、`part-of`、`related`，其中 `join/fk` 可带 `join_keys`。
- `metric_definitions`：指标口径唯一真源，记录公式、口径、单位、绑定对象和绑定列。
- `logic_rules`：形式化业务约束，可关联对象。
- `onto_actions`：可执行动作层，含触发条件、`function_code`、关联对象和关联逻辑规则。
- `onto_prompts`：文档抽取 prompt 模板，支持版本化复用。
- `extract_jobs`：分块抽取任务进度。

这个模型比 Palantir 官方核心概念多了 `MetricDefinition` 和 `LogicRule`，这是面向数据分析场景的合理扩展：指标解决“怎么算”，逻辑规则解决“什么必然成立”，action 解决“状态满足条件后做什么”。

### 3.3 API 与前端能力

前端 API 封装在 `/Users/huangbo/Dev/Projects/pi-xanthil/web/src/lib/api/viz.ts`，后端路由在 `/Users/huangbo/Dev/Projects/pi-xanthil/server/src/routes/viz.ts`。主要能力包括：

- 本体 CRUD：`/api/workspaces/:id/ontologies` 与 `/api/ontologies/:oid`。
- 对象 CRUD：`/api/ontologies/:oid/objects`。
- 从聚合数据集生成对象与属性：`/api/ontologies/:oid/objects/from-aggregation`。
- 属性 CRUD：`/api/objects/:objId/properties`。
- 关系 CRUD：`/api/ontologies/:oid/links`。
- 图谱投影：`/api/ontologies/:oid/graph`，输出统一 `GraphNode/GraphEdge`。
- 文档抽取：`/api/ontologies/:oid/extract`。
- 分块抽取：`/api/ontologies/:oid/extract-chunked`，进度存 `extract_jobs`。
- 多格式导出：`/api/ontologies/:oid/export?format=json|yaml|csv|html|ttl`。
- 指标口径：`/api/workspaces/:id/metrics`。
- 逻辑规则：`/api/ontologies/:oid/logic-rules`。
- 动作：`/api/ontologies/:oid/actions`。
- 抽取 prompt 管理：`/api/workspaces/:id/onto-prompts`。

前端主组件 `/Users/huangbo/Dev/Projects/pi-xanthil/web/src/components/OntologyPane.tsx` 把本体库拆为“说明、对象、关系、指标、逻辑、动作、图谱、导入”几个子页，适合作为 OntoBase 的初始产品信息架构参考。

### 3.4 抽取、校验与导出

`/Users/huangbo/Dev/Projects/pi-xanthil/server/src/onto-extract.ts` 负责文档抽取：

- 经 `pi CLI` 调模型，不直接调模型 API。
- 抽取四类内容：实体、关系、逻辑规则、动作。
- 支持超长文档分块，CSV 保留 header 分块，文本按窗口和重叠切分。
- 抽取后做归一化、名称模糊解析、同名实体 richness 去重。
- 对实体、逻辑、动作做置信度校准。

`/Users/huangbo/Dev/Projects/pi-xanthil/server/src/onto-validator.ts` 负责质检：

- 校验结构、字段、引用完整性、重复项、关系 kind 白名单。
- 对 action 的 `function_code` 做轻量启发式检查。
- 校验 logic/action 的对象引用与逻辑引用。
- 只有 fatal 阻断落库，error/warning/info 用于提示。

`/Users/huangbo/Dev/Projects/pi-xanthil/server/src/onto-export.ts` 支持 JSON、YAML、CSV、HTML、Turtle 五种导出格式，并且保持零新依赖。Turtle 导出是轻量 OWL/RDF 表达，适合与外部语义工具初步互通，但目前对 action/logic 的 RDF 映射仍较浅。

## 4. 对 OntoBase 的建设建议

OntoBase 可以直接吸收 `pi-xanthil` 的成熟经验，但不要照搬全部产品功能。建议先把它定义为独立的业务语义层项目，优先沉淀业务对象、指标口径、分析动作、规则约束和 AI 上下文入口。数据库、API、文件或产品服务都可以作为 OntoBase 的外部数据源，而不是 OntoBase 的宿主。

### 4.1 初始本体对象

建议第一版核心概念保持 7 类：

1. `Ontology`：领域容器。
2. `ObjectType`：对象类型，支持 `dataset` 和 `concept`。
3. `PropertyType`：属性/字段语义。
4. `LinkType`：对象间关系，区分数据关系 `join/fk` 与语义关系 `is-a/part-of/related`。
5. `MetricDefinition`：指标口径唯一真源。
6. `LogicRule`：领域约束和业务铁律。
7. `ActionType`：可执行动作定义，先记录触发条件和代码/伪码，不急于执行。

后续进入执行闭环时，还应补一层 `SecurityPolicy` 或等价治理模型，至少记录 action 是否可执行、谁可执行、需要哪些数据/对象权限、是否允许写回、是否需要人工确认、是否记录审计日志。第一期可以不做完整权限系统，但字段和文档语义要预留。

### 4.2 工程顺序

建议 OntoBase 按以下顺序启动：

1. 先建立 Markdown 规格：定义本体术语、字段、命名、关系类型和导出格式。
2. 再建立 SQLite schema：优先做 `ontologies/object_types/property_types/link_types/metric_definitions`。
3. 接着做确定性 source binding：把首期外部数据源注册为 dataset object 和 properties，例如 DataBase 的 PLS 表/view、未来 API 或文件来源。
4. 再做图谱投影：输出统一 `nodes/edges`，方便后续前端或报告消费。
5. 最后再接 LLM 抽取：先用文档生成 concept/link/logic/action 草稿，必须经过 validator 和人工确认后落库。

### 4.3 需要避免的坑

- 不要把本体库做成纯知识图谱。知识图谱记录“资料之间怎么关联”，本体库要回答“业务世界里有哪些对象、字段、关系、口径、约束和动作”。
- 不要只建抽象概念。dataset object 必须能绑定真实外部来源，例如数据库表/view/字段、API、文件或产品服务，否则后续指标、解释和分析工作流无法复用。
- 指标口径要有唯一真源。否则“同一个指标在不同模块各算各的”会很快造成维护问题。
- action 初期应先作为语义和操作记录，不要急于执行代码。执行层需要权限、审计、幂等、回滚和安全沙箱。
- LLM 抽取只能作为草稿生成，不应绕过校验和人工治理。

## 5. 建议的下一份文件

建议在 `OntoBase` 下继续新增：

- `ontobase-domain-model.md`：定义 OntoBase 的独立领域模型、首期 PLS 协作数据源、字段语义和关系类型。
- `ontobase-pls-build-plan.md`：分期计划，先 PLS 语义清单 + source binding，再 graph/export，最后 LLM extraction。

## 6. 参考来源

线上来源：

- Palantir 官方文档：Ontology core concepts  
  https://www.palantir.com/docs/foundry/ontology/core-concepts/
- Palantir 官方文档：Why create an Ontology?  
  https://www.palantir.com/docs/foundry/ontology/why-ontology/
- Palantir 官方文档：Object and link types / Types reference  
  https://www.palantir.com/docs/foundry/object-link-types/type-reference/
- Palantir 官方文档：Object types overview  
  https://www.palantir.com/docs/foundry/object-link-types/object-types-overview/
- Palantir 官方文档：Link types overview  
  https://www.palantir.com/docs/foundry/object-link-types/link-types-overview/
- Palantir 官方文档：Action types overview  
  https://www.palantir.com/docs/foundry/action-types/overview/
- Peter Wilczynski, Taylor Gregoire-Wright, Daniel Jackson, `Concept-Centric Software Development`, 2023  
  https://arxiv.org/abs/2304.14975

本地来源：

- `/Users/huangbo/Dev/Projects/pi-xanthil/docs/onto-xanthil-design.md`
- `/Users/huangbo/Dev/Projects/pi-xanthil/server/src/db/viz.ts`
- `/Users/huangbo/Dev/Projects/pi-xanthil/server/src/routes/viz.ts`
- `/Users/huangbo/Dev/Projects/pi-xanthil/server/src/onto-extract.ts`
- `/Users/huangbo/Dev/Projects/pi-xanthil/server/src/onto-validator.ts`
- `/Users/huangbo/Dev/Projects/pi-xanthil/server/src/onto-export.ts`
- `/Users/huangbo/Dev/Projects/pi-xanthil/web/src/lib/api/viz.ts`
- `/Users/huangbo/Dev/Projects/pi-xanthil/web/src/components/OntologyPane.tsx`
