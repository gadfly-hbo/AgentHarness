# AgentHarness Orchestration

## 目的

本文定义 CDI（Controller-Domain Isolation，总控域隔离工程法）在 AgentHarness 中的执行方式。Codex 是总控；OpenCode、Kilo Code、Mimo Code、Kimi Code 是实现域 worker，CodeBuddy 是受限辅助总控，Qwen Code 是独立验证 agent。AgentHarness 禁用 Antigravity CLI 作为开发 assignee。

## 路由表

| domain | assignee | allowed root | domain notes |
| --- | --- | --- | --- |
| `database` | `opencode` | `DataBase/**` | `docs/notes-database.md` |
| `ontobase` | `kilo` | `OntoBase/**` | `docs/notes-ontobase.md` |
| `knowledgebase` | `mimo` | `KnowledgeBase/**` | `docs/notes-knowledgebase.md` |
| `memorybase` | `kimi` | `MemoryBase/**` | `docs/notes-memorybase.md` |
| `console-ui` | `kilo` | `Console/workbench-prototype/**` | `docs/notes-console.md` |
| `console-backend` | `mimo` | `Console/commands/**` | `docs/notes-console.md` |
| `coordination` | `codebuddy` | 无产品实现写入路径 | `docs/notes-infra.md` |
| `validation` | `qwen` | 默认只读 | `docs/notes-infra.md` |
| `governance` | `codex` | 共享 docs、contract、ADR | `docs/notes-infra.md` |

这张表覆盖 AgentOps 通用路由。Task Bus 不自动由 domain 推断 assignee，Codex 创建任务时必须同时显式填写两者。

## 权威控制面

- 全局上下文：`CONTEXT.md`
- 角色与强制规则：`AGENTS.md`
- 编排流程：`Orchestration.md`
- 架构边界：`docs/four-bases-one-console-contract.md`
- 跨域契约：`docs/contracts/`
- 架构决策：`docs/adr/`
- 域状态：`docs/notes-*.md`
- 任务状态：`.agentops/tasks/*/status.json`
- 生命周期事件：`.agentops/tasks/*/events.ndjson`

聊天记录不是任务或 contract 的唯一事实来源。

## Intake 与任务拆解

Codex 在创建任务前必须：

1. 读取用户目标、项目规则、相关域 notes、现有实现和 contract。
2. 判断是否触发 `Structural Confirmation Gate`；触发时先逐项确认并取得整体批准。
3. 判断任务是单域还是跨域。
4. 单域任务只创建一个域 brief；不得顺手要求其他域同步。
5. 跨域任务先写 joint contract 或 contract change request，再按依赖拆成多个域任务。
6. 明确完成标准、验证命令、风险和不做事项。

任务应按用户价值切片，不按“先把某一层全部做完”机械拆分。每个任务必须能独立审核。

## Task Bus Brief

每个任务必须包含：

- `slug`、`domain`、`assignee`、`allowed_paths`。
- 一个具体目标和明确 non-goals。
- 输入证据和权威 contract 路径。
- 预期输出及消费者。
- 共享术语子集和稳定身份。
- validation 命令或人工复核方法。
- handoff back 格式。
- 跨域批次的 `batch`、`sequence`、`depends_on`。

依赖 ID 使用短 Task Bus ID，例如 `T0002`。下游任务只有在所有依赖达到 `approved` 后才能领取。

## Controller 到域 Agent

Codex 使用 `docs/templates/DOMAIN_HANDOFF.template.md` 编写 brief，并通过 Task Bus 创建任务。

域 agent 开始前必须：

1. 使用 `/agentops-task-next` 领取与自身 CLI identity 匹配的任务。
2. 读取 `AGENTS.md`、`CONTEXT.md`、本文、本域 notes、brief 和相关 contract。
3. 检查 `allowed_paths`、依赖状态和工作树重叠风险。
4. 发现关键歧义时停止并在 handoff 中请求 Codex 决策，不自行扩大范围。

## 域内实施

- OpenCode 只写 `DataBase/**`。
- Kilo Code 只写 `OntoBase/**`。
- Mimo Code 只写 `KnowledgeBase/**`。
- Kimi Code 只写 `MemoryBase/**`。
- Kilo Code 在 `console-ui` 任务中只写 `Console/workbench-prototype/**`。
- Mimo Code 在 `console-backend` 任务中只写 `Console/commands/**`。
- CodeBuddy 不写产品实现，只能处理 Codex 创建或明确批准的 coordination 任务。
- Qwen Code 默认只读，只能处理 Codex 创建或明确批准的 validation 任务；验证产物路径必须由 brief 精确批准。
- 读取其他域允许，写入其他域禁止，除非 brief 列出精确文件并说明临时授权。
- shared docs、contract、ADR 和 Console contract 默认由 Codex 修改。
- 域 agent 不得启动另一个 CLI；所有跨域协作经 Task Bus 和 Codex 中转。
- 同一 worktree 下默认串行；并行时必须确保 `allowed_paths` 不重叠，风险较高时使用独立 branch/worktree。

## Contract Change

实现发现 contract 不足时，域 agent 不直接修改共享接口，而是在 handoff 中附 `CONTRACT_CHANGE_REQUEST`：

1. 写明当前 contract、建议形态、原因和受影响域。
2. 说明兼容、migration、fallback 和验证影响。
3. Codex 决定 `accepted`、`rejected` 或 `deferred`。
4. accepted 后由 Codex 更新 contract，并创建受影响域的新任务或 revision。

禁止通过“先把另一域也改了”来消除 contract drift。

## Handoff Back

域 agent 使用 `docs/templates/HANDOFF_BACK.template.md`，至少报告：

- 完成项与 changed files。
- 实际运行的验证及结果。
- 未运行验证及原因。
- contract drift、术语变更请求和跨域影响。
- 风险、未验证区域和 controller decisions needed。

完成后使用 `/agentops-task-handoff` 将任务置为待审核状态。域 agent 在审核前不得跳到同 assignee 的下一项任务。

## Controller Review

Codex 使用 `docs/templates/REVIEW_CHECKLIST.template.md`：

1. 比较实际 diff 与 `allowed_paths`。
2. 验证项目规则、术语、contract 和四库一台边界。
3. 检查测试证据，不以 typecheck 代替运行行为验证。
4. 判断是否引入隐式跨域耦合。
5. 作出 `approved`、`changes_requested`、`rejected` 或 `cancelled` 决定。

`changes_requested` 必须由原 assignee 恢复任务并修订。未获批准的 handoff 不得作为下游任务依赖完成条件。

## 集成与完成

只有 Codex 可以：

- 更新共享 contract、`CONTEXT.md`、ADR 和 controller notes。
- 将多个已批准 handoff 组合为集成结果。
- 运行跨域 contract test、端到端 smoke 和最终验收。
- 向用户声明任务完成。

完成报告必须包含：做了什么、每个域改了什么、验证证据、contract 变化、风险和未完成项。

## Console 域规则

Console 是控制平面，开发责任拆为 `console-ui -> kilo` 与 `console-backend -> mimo`。Codex 持有 Console contract、跨域审批和集成所有权。Antigravity CLI 在 AgentHarness 中被禁用，不能通过 task brief 或 override 恢复。Console 任务必须：

- 只修改中央框架与 brief 同时授权的精确 Console 域路径。
- 使用 Codex 已批准的四库输入输出 contract。
- 禁止把库内语义、table 或文件路径硬编码成 Console 私有事实。
- 要求权限、审批、审计、错误和降级验证。

## 中断与恢复

- 用户中断：Codex 停止派发新任务，记录已批准与未批准状态。
- 域阻塞：域 agent handoff 阻塞证据，Codex 决定补 contract、改 brief 或请求用户。
- 会话切换：以 Task Bus、contract、notes 和 handoff 为恢复依据，不依赖聊天记忆。
- 工作树存在他人改动：域 agent 不覆盖、不回滚；报告重叠并等待 Codex 决定。

<!-- AGENTOPS:DEVELOPMENT-FRAMEWORK:BEGIN -->
## AgentOps 中央开发者框架

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
<!-- AGENTOPS:DEVELOPMENT-FRAMEWORK:END -->
