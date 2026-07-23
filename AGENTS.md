# AgentHarness Project Instructions

## 目的与语言

- AgentHarness 由独立的 `DataBase`、`OntoBase`、`MemoryBase`、`KnowledgeBase` 和 `Console` 组成，通过显式联合契约形成 Harness。
- 可用简体中文清晰表达的文档、UI 文案、字段业务解释和汇报优先使用简体中文；代码、命令、schema、标识符、产品名和协议名保持原写法。

## 架构边界

- 四库一台彼此独立，不互为宿主、上下层、附属模块，也不默认共享存储、身份或生命周期。
- 每个域独立维护 schema、数据、导入、校验、发布、审计和治理；内部变化不会自动要求其他域同步。
- 跨域身份、读写、刷新、回写、审批和审计必须通过 `docs/four-bases-one-console-contract.md` 或 `docs/contracts/` 的显式联合契约表达。
- `Console` 是控制平面，不得把四库内部 table、文件路径或语义硬编码为自己的事实。
- 外部产品消费 AgentHarness 时必须声明 consumption contract；当前 PLS 场景不改变四库一台的独立性。

## 控制面与路由

- Codex 是唯一 Controller，持有共享术语、跨域 contract、任务拆解、批准、集成、最终验证和用户回复。
- domain、assignee、allowed paths 和禁用项以 AgentOps 中央 `development-framework.json` 生成区块为机器权威；详细生命周期以 `Orchestration.md` 为准。
- AgentHarness 禁用 Antigravity。CodeBuddy 只处理批准的 coordination 任务且无产品写路径；Qwen 只处理批准的 validation 任务且默认只读。
- Task Bus 任务必须显式填写 domain、assignee、allowed paths、contract、validation 和 handoff；不得依赖工具猜测路由。
- Codex 默认不代替域 agent 实现库内任务；只读诊断、controller-owned 文档或用户明确授权的 hotfix 例外。

## 域 agent 边界

- 只领取分配给自身 CLI 的任务，只修改 `allowed_paths`；其他域保持只读，通过 contract、adapter、API、文件或 view 消费。
- 开工前读取本文件、brief、相关 contract 和本域 notes；只有任务确实涉及全局术语或编排时才读取完整 `CONTEXT.md` / `Orchestration.md`。
- 不修改共享 `AGENTS.md`、`CONTEXT.md`、`Orchestration.md`、ADR、联合 contract 或另一域文件，除非 brief 精确授权。
- 不自行改变共享术语、稳定身份、API/schema/event shape 或 consumption contract；发现缺口提交 `CONTRACT_CHANGE_REQUEST`。
- 完成后提交结构化 handoff：完成项、文件、验证、contract drift、跨域影响、风险、未验证项和 Controller decisions needed。
- 域 agent 不启动另一 CLI、不批准自己的任务、不提交或推送未经授权的改动。

## 跨域变更判定

创建任务前，把每个要求分类为事实数据/结构、业务语义、本体映射、知识、记忆、Console 或联合契约，并确认：

- 权威域及各域当前状态。
- 本次是新增、修改、删除还是重新分类。
- 稳定身份、source binding、输入输出和 contract 是否受影响。
- 需要派发与明确不修改的域。

涉及两个以上域或权威来源不清时，先形成包含“变更项、权威域、当前状态、动作、contract 影响、涉及域、不修改域”的影响清单。每个域使用独立 Task Bus 任务；不得让一个域顺手修改另一域。

## Structural Confirmation Gate

新建或实质调整任何持久化结构前，必须使用 `$agentharness-structure-grill` 逐项确认并获得整体批准。范围包括：

- DataBase table/view/column/key/index/constraint/migration/import/aggregation。
- OntoBase object/property/link/identity/rule/action/source binding。
- MemoryBase、KnowledgeBase 的持久对象、粒度、版本、来源、生命周期和检索结构。
- Console 持久状态、编排、审批、审计和跨库联合契约。

最低门槛：

1. 先读现有 contract、schema、migration、真实样例和消费入口，不发明字段、枚举、默认值、身份或关系。
2. 先确认业务目的、对象、粒度和稳定身份，再确认物理字段；按适用性覆盖 null/default、taxonomy、基数、生命周期、版本、来源、读写、校验、索引、审计、迁移、兼容和回滚。
3. 默认一次确认一个决策，记录 agent 建议、原因、用户选择和一致性。
4. 全部问题完成后输出明细与最终方案；未获整体批准不得实施持久结构。
5. 实施中出现新结构决定时暂停并回到确认；完成后按台账逐项验收。

只读调研、现状扫描和草案可在批准前进行。紧急、简单或时间有限不构成跳过理由；只有用户针对明确变更授权例外时才能缩短。

## DataBase 维护触发器

修改 `DataBase/**` 时还要遵守 `DataBase/AGENTS.md`。数据库结构、导入、血缘或消费入口变化必须同步维护消费指南、字段说明和血缘入口，不能只改 SQLite 实现。

## 集成与完成

- 同一 worktree 默认串行；仅在 contract 明确且写入范围不重叠时并行，必要时使用独立 branch/worktree。
- Codex review 必须核对 diff/allowed paths、contract、测试证据和隐式跨域耦合；typecheck 不能替代运行行为验证。
- 只有获批 handoff 才能进入依赖任务或集成。最终报告说明各域改动、验证、contract 变化、风险和未完成项。

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


This section does not replace the rules above. Existing product rules remain authoritative for local product behavior.

## AgentOps 中央政策触发器

详细规则不在本文件重复。命中条件时，计划或实施前读取对应权威文件；多个条件同时命中时全部适用。

- 跨项目持久化变更：`/Users/huangbo/Dev/AgentOps/coding-system/policies/CROSS_PROJECT_COORDINATION.md`。请求项目不得代替目标项目实施或批准；下游保持阻塞，直至目标 handoff 与 contract gate 获批。
- 本轮产生临时代码或进入最终验证：`/Users/huangbo/Dev/AgentOps/coding-system/policies/TOMBSTONE_CODE_GOVERNANCE.md`。盘点墓碑代码；删除前确认；清理后重跑验证。
- 具有用户界面的产品功能：`/Users/huangbo/Dev/AgentOps/coding-system/policies/FRONTEND_FIRST_PRODUCT_DEVELOPMENT.md`。默认先做可操作前端，再打通最小真实后端；后端先行例外需要证据和批准。
- AgentOps worker 开工、验证或 handoff：`/Users/huangbo/Dev/AgentOps/coding-system/policies/WORKER_DELIVERY_GOVERNANCE.md`。高风险 contract/API/persistence/read-model/concurrency/audit 任务先建 constraint matrix；claim 映射正负向证据；失败或 drift 时 fail closed。

目标项目更严格的规则优先。读取其他仓库不授予写权限；证据缺失、规则冲突、请求越界或自动化失败时停止相关分支并交回 Controller。
<!-- AGENTOPS:END -->
