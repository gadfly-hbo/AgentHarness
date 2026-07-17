# AgentHarness Project Instructions

## Language

本项目内，凡是可以用简体中文清晰表达的内容，优先使用简体中文。

保持以下内容的原始技术写法，不强行翻译：

- 代码、命令、SQL、JSON、配置项。
- 文件名、目录名、表名、字段名、view 名、函数名、变量名。
- 产品名、系统名、协议名、模型名等专有名词，例如 `AgentHarness`、`ModelEvol`、`PLS`。

面向非技术用户的说明、文档、前端展示文案、字段业务解释和工作汇报，应尽量使用简体中文。

## AgentHarness Architecture

AgentHarness 的长期架构是“四库一台”：

- `DataBase`：数据库。
- `OntoBase`：本体库。
- `MemoryBase`：记忆库。
- `KnowledgeBase`：知识库。
- `Console`：控制台。

这五个部分彼此独立、解耦，不互为上下层实现，不互相附属，也不默认共享同一个存储。它们通过显式联合契约共同组成 `Harness`，供外部产品或项目消费。

架构边界以 `docs/four-bases-one-console-contract.md` 为准。后续 agent 在涉及任意一库一台或跨库协作时，必须先遵守以下原则：

- 不要把某一库理解为另一库的宿主、上层、下层、附属模块或字段扩展。
- 不要因为一个库发生内部变化，就自动要求其他库同步变化；只有联合契约受影响时才需要跨库对齐。
- 每一库和一台都独立维护自己的领域边界、文档、schema、数据结构、生命周期、导入、校验、发布、审计和治理流程。
- `Console` 是控制平面和编排入口，不应把四库的语义和数据隐式硬编码进 UI 或命令逻辑；跨库行为应通过联合契约表达。
- 外部产品或项目消费 AgentHarness 时，应声明自己的 Harness consumption contract：消费哪些库、读取/写入哪些入口、跨库身份如何对齐、哪些操作需要审批/刷新/回写/审计。

当前第一期联合场景是 `PLS 渠道画像匹配项目`。该场景中，`DataBase` 可提供 PLS 表、view、真实画像指标和九维特征矩阵作为事实数据源；`OntoBase` 可提供 PLS 业务对象、维度语义、指标口径、匹配解释规则等业务语义。但这只是第一期联合契约，不改变四库一台的独立性。后续 `MemoryBase`、`KnowledgeBase`、`Console` 进入该场景时，也应通过显式联合契约加入。

## Controller-Domain Development Architecture

AgentHarness 采用 CDI（Controller-Domain Isolation，总控域隔离工程法）的“总控 + 域 agent”开发架构。

### 固定角色路由

| 角色 | CLI | 默认所有权 | 默认允许修改 |
| --- | --- | --- | --- |
| 总控 Controller | Codex | 全局上下文、任务拆解、联合契约、跨域身份、Console contract、审批、集成、验收、最终用户回复 | `AGENTS.md`、`CONTEXT.md`、`Orchestration.md`、`docs/` 中的共享索引/contract/ADR/controller notes，以及经审核后的集成改动 |
| OntoBase 域 agent | Kilo Code | 业务对象、属性语义、关系、指标、规则、动作、语义映射和 source binding | `OntoBase/**` 及任务 brief 明确授权的 OntoBase 域文档 |
| DataBase 域 agent | OpenCode | 事实数据、table/view、字段、migration、seed、importer、validation、数据库文档和血缘 | `DataBase/**` 及任务 brief 明确授权的 DataBase 域文档 |
| KnowledgeBase 域 agent | Mimo Code | 文档、规范、外部资料、来源追溯、切片、索引和检索结构 | `KnowledgeBase/**` 及任务 brief 明确授权的 KnowledgeBase 域文档 |
| MemoryBase 域 agent | Kimi Code | 经验、偏好、教训、记忆候选、可信度、冲突、晋升和生命周期 | `MemoryBase/**` 及任务 brief 明确授权的 MemoryBase 域文档 |
| Console 域 agent | Antigravity CLI | 控制平面、用户界面、查看、触发、审批、治理、审计和跨库编排入口 | `Console/**` 及任务 brief 明确授权的 Console 域文档 |

Antigravity CLI 是 `Console` 的固定域开发者，但不拥有四库语义或联合契约。Codex 继续作为 Console contract owner、跨域编排审批者和最终集成者。

以上路由覆盖 AgentOps 的通用 domain→CLI 默认路由。AgentHarness Task Bus 任务必须显式设置 `assignee`，不得依赖工具自动猜测。

### 总控权限

Codex 负责：

- 读取用户目标与现有证据，维护 `CONTEXT.md` 中的全局术语、域图、接口和不变量。
- 把工作拆成有用户价值、可独立验收的域任务，并通过 `.agentops/tasks/` Task Bus 派发。
- 编写或批准跨域 contract、稳定身份、数据流、错误与降级规则、兼容与迁移方案。
- 审核域 agent handoff，确认范围、契约、验证、风险和跨域影响。
- 只在 handoff 获批后组织集成；最终测试结论和用户回复只能由 Codex 给出。

Codex 默认不代替域 agent 实现库内任务。只读诊断、controller-owned 文档、紧急且经用户授权的 hotfix 例外不受此限。

### 域 agent 边界

域 agent 必须：

- 只领取分配给本 CLI 的 Task Bus 任务，只修改 `allowed_paths`。
- 开始前读取 `AGENTS.md`、`CONTEXT.md`、`Orchestration.md`、本域 notes、任务 brief 和相关 contract。
- 保持其他库为只读外部系统，通过 contract、adapter、API、文件或 view 消费，不直接耦合其内部存储。
- 完成后提交结构化 handoff：完成项、文件、验证、contract drift、跨域影响、风险、未验证项和需要总控决定的问题。

域 agent 不得：

- 修改 `AGENTS.md`、`CONTEXT.md`、`Orchestration.md`、联合契约或 ADR，除非 controller brief 精确授权。
- 修改另一库或其他域文件，或因为本域变化自动要求其他域同步实现。
- 自行改变共享术语、跨库身份、API/schema/event shape 或产品消费契约。
- 绕过 Codex 直接协调另一域实施；跨域诉求必须提交 `CONTRACT_CHANGE_REQUEST`。

### 标准任务生命周期

```text
用户目标
  -> Codex intake / structural confirmation
  -> Codex 写 contract（跨域时必需）
  -> Codex 创建 Task Bus 域任务
  -> 域 agent claim / implement / validate
  -> 域 agent handoff back
  -> Codex review
     -> approved：进入依赖任务或最终集成
     -> changes_requested：原域 agent 修订
     -> blocked：Codex 或用户处理阻塞
  -> Codex integration validation
  -> Codex 最终回复
```

跨域工作必须按依赖顺序分批。只有 contract 已明确、文件范围不重叠时才允许并行；同一 worktree 中默认串行，必要时为并行任务使用独立 branch/worktree。

详细执行规则以 `CONTEXT.md`、`Orchestration.md`、`docs/contracts/` 和 `docs/templates/` 为准。

### 跨域变更判定门槛

Codex 在派发任务前，必须先把用户要求逐项分类为事实数据或数据结构、业务语义或本体映射、知识来源、经验记忆、Console 展示或编排、联合契约中的一种或多种变更。

当同名标签、字段、对象或展示项出现在多个域时，必须分别检查各域现状并明确：

- 哪个域是该内容的权威来源。
- 各域中该内容当前是已存在、缺失，还是仅有展示但未建立权威记录。
- 用户要求是新增、修改、删除，还是重新分类。
- 稳定身份、source binding、输入输出字段或其他联合契约是否受影响。
- 哪些域需要派发任务，哪些域明确不需要修改。

不得仅因为 HTML 或报表变化、多个域存在同名字段或标签、一个域新增数据、一个域调整语义，或者用户使用“新增”“删除”“同步”等未明确域边界的表述，就自动推断其他域需要同步。

涉及两个及以上域，或者权威来源不能立即确定时，Codex 必须先形成变更影响清单，再创建任务：

| 变更项 | 权威域 | 当前状态 | 本次动作 | contract 是否受影响 | 需要派发的域 | 明确不修改的域 |
| --- | --- | --- | --- | --- | --- | --- |

每个受影响域必须创建独立 Task Bus 任务，不得通过一个域任务顺手修改另一个域。只有展示层单域变更且权威来源、读取契约和其他域不受影响时，才可省略完整清单，但仍须在 brief 中记录该判断。

## Structural Confirmation Gate

AgentHarness 新建或实质调整持久化结构前，必须先完成与用户逐项交互的结构确认。该规则适用于四库一台各自的内部结构和跨库联合契约，特别包括：

- `DataBase` 的 schema、table、view、column、identity、key、index、constraint、migration、导入与聚合结构。
- `OntoBase` 的 ObjectType、PropertyType、LinkType、身份策略、规则、动作和 source binding。
- `MemoryBase`、`KnowledgeBase` 的持久化对象、记录粒度、版本、来源、生命周期和检索结构。
- `Console` 的持久化状态、编排结构、审批或审计记录及联合契约入口。
- 跨库身份对齐、读写入口、刷新、回写、审批、审计和兼容性契约。

执行要求：

1. 实施前先读取现有契约、schema、migration、数据样例和消费入口，不能凭空发明字段、枚举、默认值、身份键或关系。
2. 先确认业务目的、对象、数据粒度和稳定身份，再确认字段类型等物理结构。
3. 默认一次只向用户确认一个决策；只有用户明确同意时，才能把相关字段或问题合并成一组确认。
4. 每个问题必须给出 agent 的明确建议、建议原因和可选择结论，不能只把开放问题抛给用户。
5. 适用时必须覆盖：字段业务含义、必填与空值、默认值、枚举或 taxonomy、关系方向与基数、生命周期、时间与版本、来源与血缘、读写入口、校验、索引、审计、迁移、兼容、回滚和阶段范围。
6. 每次用户选择后都要维护确认台账，记录确认项、agent 建议、原因、用户选择和一致性。选择相同写“一致”；不同则简要记录差异及影响。
7. 全部适用问题完成后，先输出明细汇总和最终结构方案，请用户整体批准。未获整体批准，不得创建或实质修改 migration、table、view、字段或其他持久化结构。
8. 实施中发现新的结构决策时必须暂停，回到逐项确认；不得以实现细节为由自行补充未确认结构。
9. 实施完成后按确认台账逐项验收，任何偏差都必须说明并取得批准。

优先使用中央 AgentOps 管理的 `$agentharness-structure-grill` skill 执行完整流程。skill 不可用时，也必须遵守本节的最低门槛。

只读调研、现状扫描和草案编写可以在整体批准前进行。只有用户针对明确变更显式授权例外时才能缩短或跳过确认门槛；紧急、简单或时间有限本身不构成例外。

## Database Maintenance

后续真实数据会逐步导入 `DataBase/agentharness.sqlite`。前期创建的库表、字段和 view 只是当前阶段的承接结构，真实导入时可以也应该根据实际数据表、字段含义和消费方式继续调整。

每次涉及以下变更时，必须同步维护数据库概览材料：

- 新建、删除或重命名 table / view。
- 新增、删除、重命名或调整字段含义。
- 修改字段中文注释、业务含义、示例值或技术说明。
- 修改数据导入链路、上下游依赖、特征聚合逻辑或产品读取入口。
- 新增真实数据源导入后，发现现有表结构与真实数据不匹配并进行调整。

同步维护要求：

- 更新 `DataBase/docs/pls-consumption-guide.md`，让后续维护者能快速理解当前 SQLite 数据库能力、推荐读取入口、写入入口、字段语义、校验命令和注意事项。
- 更新 `DataBase/console/app.js` 中的前端静态血缘关系图，确保“血缘关系图”能反映最新 table / view 的上下游关系。
- 如新增表或字段，应同步写入或更新 `database_field_comments`，保证 HTML 前端能展示简体中文字段解释。
- 如新增 migration / seed / validation / docs 文件，应保持现有编号和命名风格连续。

这两份概览材料的定位是数据库维护入口，不是一次性文档。任何数据库结构或链路变更完成后，都要把它们更新到可继续接手维护的状态。

<!-- AGENTOPS:BEGIN -->
## AgentOps Product Entry

This product is registered in the multi-agent coding system.

- System root: `/Users/huangbo/Dev/AgentOps/coding-system`
- Product overlay: `/Users/huangbo/Dev/AgentOps/coding-system/products/agentharness/AGENTS.overlay.md`
- Routing guide: `/Users/huangbo/Dev/AgentOps/coding-system/docs/agent-routing.md`
- Domain memory guide: `/Users/huangbo/Dev/AgentOps/coding-system/docs/agent-domain-memory.md`
- Cross-project prompt template: `/Users/huangbo/Dev/AgentOps/coding-system/templates/CROSS_PROJECT_IMPLEMENTATION_PROMPT.template.md`

This section does not replace the rules above. Existing product rules remain authoritative for local product behavior. The standard below defines the minimum handoff and approval gates for changes requested across repository boundaries.

## AgentOps 跨项目协调标准

### 目的

当一个项目依赖另一个仓库的持久化变更时，保留目标项目的自治权，同时提供一份可以直接交给目标项目、且不丢失证据、范围、契约、验证和依赖 gate 的实施 brief。

### 强制规则

- 当请求项目需要另一个项目实施代码、配置、schema、模型、contract 或其他持久化变更时，请求项目 Controller 不得代替目标项目直接实施，也不得只给出口头摘要。
- 请求项目 Controller 必须使用 AgentOps 跨项目实施 prompt 模板，输出一段可直接转发给目标项目 Controller 或开发者 agent 的完整 prompt。Prompt 至少包含请求仓库与目标仓库、建议的目标 `domain` 与 `assignee`、权威证据与已批准决定、目标与 non-goals、建议的 `allowed_paths`、约束与执行顺序、验证要求、handoff 格式、contract gate、依赖关系和阻塞处理。
- 请求项目可以建议目标 `domain`、`assignee` 和 `allowed_paths`，但无权替目标项目批准。目标项目 Controller 必须根据目标仓库自身的 `AGENTS.md`、`Orchestration.md`、contracts、路由规则和当前仓库证据确认或调整。
- 目标项目必须使用自身的 Controller 与 worker 生命周期。适用 AgentOps Task Bus 时，任务创建、领取、handoff 和 review 必须发生在目标仓库的 Task Bus。ModelEvol experiment state machine 等项目专属生命周期保持权威，不得被通用 Task Bus 流程替代。
- 请求项目不得把目标项目尚未批准的输出视为可消费 contract。依赖目标变更的下游任务必须保持显式阻塞，直到目标项目 Controller 批准上游 handoff，并明确可供下游消费的 contract、artifact、version、path 或其他证据。
- 如果证据缺失、项目规则冲突、请求超出批准范围、出现 contract drift、验证失败，或目标项目无法采用建议路由，目标 agent 必须停止扩张范围，并把 blocker 交回目标项目与请求项目 Controller 决策。

### 使用方式

1. 确认当前仓库之外确实需要实施变更；建议路由或路径前先读取目标仓库规则。
2. 使用 `templates/CROSS_PROJECT_IMPLEMENTATION_PROMPT.template.md`，填写已验证证据，并显式标记未知项。
3. 通过目标项目 Controller intake 交付 prompt。最终任务拆解、路由、批准和 handoff review 由目标项目 Controller 负责。
4. 把跨项目执行顺序记录为显式依赖。只有目标 handoff 与 contract gate 获批后，请求项目的下游工作才能开始。

### 示例

某产品需要 AgentHarness 新增字段。产品 Controller 引用现有 consumption contract，提出 AgentHarness 目标 domain 与路径建议，并阻塞产品集成任务。AgentHarness Controller 按本项目规则确认路由，完成实施与验证并批准 handoff。产品 Controller 随后记录已批准的 contract 证据，再释放下游集成任务。

### 注意事项

- 读取其他仓库获取证据，不等于获得该仓库的写权限。
- 可转发 prompt 是 intake artifact，不是绕过目标项目 Controller 的授权。
- 项目规则可以设置更严格的 gate；目标仓库规则和项目专属生命周期对其实施保持权威。
<!-- AGENTOPS:END -->
