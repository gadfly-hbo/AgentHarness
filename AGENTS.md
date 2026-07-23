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
| Console UI 域 agent | Kilo Code | Console 前端页面、交互、视觉和响应式实现 | `Console/workbench-prototype/**` |
| Console backend 域 agent | Mimo Code | Console command adapter、后端入口、API 和运行时集成 | `Console/commands/**` |
| 辅助总控 agent | CodeBuddy | Codex 批准的上下文整理、Task Bus 状态盘点、brief/review 草稿和证据缺口检查 | 无产品实现写入路径 |
| 独立验证 agent | Qwen Code | Codex 创建或批准的测试、截图、smoke、contract/API 验证 | 默认只读；验证产物路径须由 brief 精确批准 |

AgentHarness 禁用 Antigravity CLI 作为开发 assignee，task brief 或 override 均不得恢复。Codex 继续作为 Console contract owner、跨域编排审批者和最终集成者；CodeBuddy 与 Qwen 的 handoff 只提供辅助材料或验证证据，不具备批准权。

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

- Development framework: `/Users/huangbo/Dev/AgentOps/coding-system/products/agentharness/development-framework.json`
- Registration mode: `structured`
- Framework version: `1`

中央开发者框架：`agentharness` v1（`active`）

本区块由 AgentOps 中央注册源生成。项目内其他说明不得覆盖这里的 domain、assignee、写入范围或禁用项。

| domain | assignee | mode | allowed paths |
| --- | --- | --- | --- |
| `governance` | `codex` | `governance` | 无产品实现写入路径 |
| `database` | `opencode` | `implementation` | `DataBase/**` |
| `ontobase` | `kilo` | `implementation` | `OntoBase/**` |
| `knowledgebase` | `mimo` | `implementation` | `KnowledgeBase/**` |
| `memorybase` | `kimi` | `implementation` | `MemoryBase/**` |
| `console-ui` | `kilo` | `implementation` | `Console/workbench-prototype/**` |
| `console-backend` | `mimo` | `implementation` | `Console/commands/**` |
| `coordination` | `codebuddy` | `coordination` | 无产品实现写入路径 |
| `validation` | `qwen` | `validation` | 无产品实现写入路径 |

- Controller：`codex`。
- 禁用 assignee：`antigravity`。
- 跨域 contract、共享身份、集成范围和最终批准权归 Controller。


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

## AgentOps 墓碑代码治理标准

### 目的

防止已经完成短期使命的临时代码进入长期维护或正式交付，同时保护正式回归测试、生产诊断能力和可复用工程资产。

### 强制规则

- “墓碑代码”是已经完成短期使命、但仍遗留在项目中的临时代码，包括一次性测试、调试打印、临时测试接口、写死的假数据和一次性脚本。
- 功能实现并通过正式验证后，必须盘点本轮新增的临时代码，列出所在文件、原用途和删留建议；清理动作必须等待用户确认，并继续遵守目标项目的操作安全规则。
- 应清理已经失去用途的临时代码，但不得误删正式回归测试、生产诊断日志、审计日志，以及具有长期复用价值且用途明确的工具脚本。
- 临时测试接口、绕过权限或校验的入口、可能写入假数据的逻辑，必须作为高风险项优先报告，不得带入正式交付。
- 无法确认代码用途、调用关系或生命周期时，不得猜测或擅自删除；应提供文件、引用或运行证据，说明风险并请求确认。
- 默认只盘点和清理当前任务产生的墓碑代码；历史遗留内容必须作为独立范围进行全局扫描、列清单并单独确认。
- 清理完成后，必须重新运行相关正式测试、typecheck、lint 或最小 smoke 验证，并报告结果和未验证项。

### 使用方式

1. 在功能实现和正式验证完成后，检查本轮 diff、未跟踪文件和运行产物。
2. 按“删除、保留、待确认”分类列出临时代码及证据。
3. 获得用户确认后执行清理，不扩大到未授权的历史遗留范围。
4. 重跑相关正式验证，并在 handoff 或最终回复中报告清理与验证结果。

### 示例

为排查接口问题新增的无鉴权调试路由在问题解决后属于高风险墓碑代码，应先列出文件、用途和删除建议，获得确认后移除并重跑接口回归测试。覆盖该问题的正式回归测试应保留。

### 注意事项

- 目标项目可以设置更严格的删除、验证和审批 gate；更严格的项目规则优先。
- 测试、日志或脚本不能仅凭名称判定为墓碑代码，应根据用途、调用关系、生命周期和维护价值判断。
- 读取其他仓库进行排查不等于获得该仓库的清理权限。

# AgentOps 产品功能前端先行开发标准

## 目的

让业务负责人通过可操作、可视觉验收的前端尽早澄清产品功能，再用真实后端验证数据、规则和技术链路，降低先完成后端后才发现业务理解偏差的返工风险。

核心准则：前端帮助业务负责人想清楚，真实后端帮助证明产品成立；先用前端表达，但不要长时间停留在假数据阶段。

## 强制规则

- 产品功能开发默认先实现可操作、可视觉验收的前端流程，再开发对应后端；不得仅因工程习惯默认后端先行。
- 前端先行阶段必须覆盖核心用户任务、关键页面状态、操作反馈和异常表现，使业务负责人能够通过实际操作确认功能含义与流程。
- 前端流程确认后，必须优先打通一条最小真实数据闭环，不得在真实数据链路尚未验证时继续大范围扩展 mock 页面。
- mock 数据必须明确标注，并遵守目标项目的数据与契约规则；不得捏造业务 ID、枚举值、指标口径、标签或默认值。
- 开发前可以先澄清业务对象、字段语义、输入输出、错误状态和最小 contract；这些是前端开发所需的契约澄清，不视为后端先行。
- 纯后端、基础设施、安全修复、数据迁移或其他没有用户界面的任务，可以不执行前端先行。
- 当数据可得性、算法可行性、性能上限或外部集成是产品能否成立的首要风险时，可以建议后端先行；计划必须列出证据、原因和验证方式，并在实施前获得业务负责人确认。
- 用户或已批准的任务 brief 明确指定后端先行时，按已批准顺序执行。

## 使用方式

1. 在功能计划中先描述可操作的前端验收路径，并列出支撑页面所需的数据、状态和操作。
2. 实现最小前端流程，使用已确认或明确标注的临时数据完成业务验收。
3. 前端流程获确认后，立即实现对应的最小真实后端链路，并用真实数据重新验收。
4. 按同一节奏逐个扩展功能闭环，避免先完成整套前端或整套后端。
5. 如需后端先行，在计划中显式记录适用例外及批准证据。

## 示例

开发运营分析功能时，先提供可操作的筛选、指标卡片、列表、详情和异常状态，让业务负责人确认信息结构与操作路径；确认后立即接入一个真实指标和一条真实查询链路，核对数据来源与计算结果，再扩展其他指标。若首要问题是外部数据源能否访问，则先提交后端可行性验证计划并获得业务负责人确认。

## 注意事项

- 前端先行不是前端全部完成后再启动后端，而是以前端确认业务、以最小真实闭环验证成立。
- 页面展示正确不代表数据正确；接入真实后端后必须抽样核对来源、口径、权限和状态流转。
- 页面字段不要求与数据库字段一一对应；业务负责人确认业务语义，工程实现仍应遵守目标项目的架构和数据契约。
- 目标项目更严格的安全、数据、contract 和审批规则继续生效。

# Worker Delivery Governance

目的：定义所有 AgentOps worker 在开工、实现、验证、handoff 前必须满足的交付硬规则。该策略适用于所有 assignee，不替代产品仓库自己的 `AGENTS.md`、contract、schema 或 domain memory；产品规则更严格时按更严格规则执行。

## 开工前约束矩阵

- 任务涉及 contract、persistence、API、read model、并发或审计时，worker 必须先在工作记录或 `handoff.md` 草稿中写出 constraint matrix，再开始编码。
- constraint matrix 至少包含：brief bullet、invariant family、权威来源、实现位置、正向证据、负向证据、waiver 或 blocker。
- 如果任务同时跨越 schema、application、read model、HTTP、audit、concurrency、UI 等多个 invariant family，worker 必须先反馈“建议拆分”或列出分阶段 acceptance；不得直接把大范围交付合并成一个不可审查 handoff。
- 任务开始前提交“约束清单”：本次允许动作、禁止动作、回退触发条件。若关键证据不足，必须在此阶段提出明确 blocker 并停止该分支继续执行，不得用猜测补齐约束。

## 证据映射

- 每个 brief bullet 必须对应至少一个可验证证据：正向测试、负向测试、命令输出、源码路径或明确 waiver。
- `handoff.md` 中每个“已完成”“已覆盖”“已验证” claim 都必须能 grep 到 test name、源码实现、命令输出或 waiver；grep 不到就不要 claim。
- changes_requested 后，worker 必须先整理完整 blocker checklist，再统一闭环；不得一轮只补一个 reviewer 点名项就重新 handoff。
- 对关键决策要给出简明理由：为何采用当前路径、为何不采用替代方案，并在 brief 或 handoff 的决策记录中落地。
- 当关键证据不足以支撑安全执行时，必须先终止该分支并给出缺口说明，等待上游批准后恢复。

## Durable Read Model

- Durable read model 必须写 corruption tests，覆盖缺行、多行、错 FK、错 workspace、错 sequence、错 checksum、错数值、非法 JSON。
- read model corruption 必须 fail closed；不得用 fallback、过滤、默认值或 best-effort 映射掩盖 contract drift。
- corruption test 的 fixture 必须真实触发目标 validator 或 mapper；不得被上游 guard 短路后仍宣称覆盖。

## Transaction 与 Idempotency

- transaction、idempotency、retry、locking 或 queue claim 相关任务必须包含 rollback tests。
- 并发相关任务必须包含真实 race-window tests；不得用顺序可见性测试冒充并发测试。
- 外部数据、持久化、HTTP、模型、跨域 adapter 边界默认 fail closed；contract drift 必须作为 blocker 或 `CONTRACT_CHANGE_REQUEST` 暴露。

## Audit 与 Logging

- audit/logging 证据必须断言 exactly-one、`reason_code`、workspace、actor、request、run 以及脱敏字段。
- 只断言“有 audit”“有 log”“写入成功”不算覆盖审计要求。
- audit/logging 的负向路径必须证明失败事务不会留下误导性成功审计；若产品 contract 要求失败审计，则必须断言失败审计的 reason 和上下文。

## Handoff Gate

- `/agentops-handoff-self-audit` 是交付 gate，不是文案步骤；要求执行时，worker 必须把 PASS 证据写进 `handoff.md`。
- self-audit PASS 必须引用可复查证据：test name、文件路径、命令输出摘录或明确 waiver。
- blocked 或 failed handoff 也必须列出已验证项、未验证项、blocker checklist 和下一步所需决策。
- 自动化失败或关键假设失效时，不要继续执行下游动作；保持状态可恢复，优先冻结可读中间状态并等待控制面明确批准后再继续。

## Waiver

- waiver 必须明确说明：对应 brief bullet、无法验证原因、风险、替代证据、谁可以解除 waiver。
- “时间不够”“未执行”“待后续”不是有效 waiver，除非同时给出可复现 blocker 和可执行下一步。
<!-- AGENTOPS:END -->
