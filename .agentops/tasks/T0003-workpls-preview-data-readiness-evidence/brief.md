---
id: "T0003"
slug: "workpls-preview-data-readiness-evidence"
status: "queued"
assignee: "opencode"
domain: "database"
controller: "codex"
base_ref: "24af68929f6186d574cf0dd2e340ce35e031c3af"
batch: "workpls-preview-data-readiness"
sequence: "1"
depends_on: []
domain_memory: "agentops/memory/opencode-algorithm.md"
allowed_paths: 
  - "DataBase"
  - "docs/notes-database.md"
validation: 
  - "sqlite3 DataBase/agentharness.sqlite \".schema v_workpls_dimension_evidence\""
  - "sqlite3 DataBase/agentharness.sqlite \"select count(*) from v_workpls_dimension_evidence;\""
  - "sqlite3 DataBase/agentharness.sqlite < DataBase/validations/030_validate_v_workpls_dimension_evidence.sql"
---

## Objective

接收 WorkPLS T0021 跨项目 intake，请 DataBase 域评估并实施 WorkPLS 画像查询与对比内部预览所需的真实数据覆盖就绪能力。

目标是让 WorkPLS 后续可以在不 mock、不放宽合法性、不修改 AgentHarness 产品文件的前提下，获得 AgentHarness Controller 可批准的消费证据：

- 至少一个合法同类横向对象对，或一个同对象跨周期对象路径。
- 相关对象均有可读取的 `Portrait Snapshot`。
- 与上述 snapshot 对齐的真实 `v_workpls_dimension_evidence` 行，行数不是 0。
- 如果真实来源不存在或需要未批准结构变更，提交 blocker handoff，不得用 mock、补零、默认 unit 或默认 quality status 填补。

## Requesting Project

- 请求仓库：`/Users/huangbo/Dev/Projects/workpls`
- 请求任务：WorkPLS `T0021-controller-agentharness-preview-data-readiness-prompt`
- 请求 artifact：`/Users/huangbo/Dev/Projects/workpls/docs/cross-project/agentharness-preview-data-readiness-prompt.md`
- 请求方 gate：WorkPLS UI Step 3 readiness / persisted Run detail / quality policy release 均 blocked，直到 AgentHarness Controller approved handoff 返回可消费 contract/artifact/version/path/DB evidence。

## Required Reading

开始前必须读取并在 handoff 中记录：

- `AGENTS.md`
- `CONTEXT.md`
- `Orchestration.md`
- `docs/notes-database.md`
- `docs/contracts/workpls-dimension-evidence-structure-ledger.md`
- `DataBase/docs/view-030-workpls-dimension-evidence.md`
- `DataBase/migrations/024_create_platform_profile_tag_metrics.sql`
- `DataBase/migrations/025_create_v_platform_profile_tag_metric_semantics.sql`
- `DataBase/migrations/026_create_v_platform_profile_channel_dimension_features.sql`
- `DataBase/migrations/029_create_v_pls_audience_profile_snapshots.sql`
- `DataBase/migrations/030_create_v_workpls_dimension_evidence.sql`
- `DataBase/validations/030_validate_v_workpls_dimension_evidence.sql`
- WorkPLS intake prompt：`/Users/huangbo/Dev/Projects/workpls/docs/cross-project/agentharness-preview-data-readiness-prompt.md`

## Scope

允许修改：

- `DataBase/**`
- `docs/notes-database.md`

如果实现发现需要修改 `docs/contracts/**`、`CONTEXT.md`、`Orchestration.md`、`OntoBase/**`、`KnowledgeBase/**`、`MemoryBase/**` 或 `Console/**`，不要直接修改；在 handoff 中提交 `CONTRACT_CHANGE_REQUEST` 或 blocker，由 AgentHarness Controller 决定后续任务。

## Non-goals

- 不修改 WorkPLS 仓库。
- 不创建或修改 WorkPLS DB 中的 `comparison_runs`。
- 不打开 WorkPLS production formal creation gate。
- 不伪造真实数据覆盖，不用 mock、补零、默认 unit、默认 quality status 或客户端绕过方式达成验收。
- 不改变 `v_workpls_dimension_evidence` fail-closed 语义。
- 不顺手修改 `OntoBase/**`、`KnowledgeBase/**`、`MemoryBase/**`、`Console/**` 或共享 contract。

## Constraints

- 遵守 AgentHarness `Structural Confirmation Gate`。如需新增或实质调整 table/view/column/identity/import structure/contract，先停止并提交 blocker 或请求 Controller 结构确认；只读诊断和现有结构内的数据覆盖验证可以继续。
- DataBase 是事实数据、view、migration、seed、importer、validation、数据库文档和血缘权威；不得定义 OntoBase 权威语义。
- 数据必须 workspace-scoped。WorkPLS 当前内部预览使用 `WORKPLS_WORKSPACE_ID=ws_demo`，但 DataBase handoff 必须明确可消费 workspace；如建议使用 `ws_pls_real_001` 或新 preview workspace，说明原因和验证证据。
- `v_workpls_dimension_evidence` 必须保持 fail-closed：缺失、不兼容、绑定失败、非有限值、空 `unit/metric_name/dimension_key/dimension_label`、空 evidence refs 不输出。
- 任何数据导入或 seed 必须可追溯，包含来源、批次、时间窗口、workspace、对象身份、snapshot identity 和验证命令。

## Expected Output

handoff 必须明确以下之一：

- `ready`: 给出可供 WorkPLS 内部预览消费的 workspace、合法对象对或跨周期对象路径、snapshot IDs、data_version、time_window、sample/quality 信息、`v_workpls_dimension_evidence` row counts、view/contract version 或 artifact path，以及验证命令摘要。
- `blocked`: 给出缺失的真实来源、结构确认、导入路径、审批、合同变化或数据质量问题；不要声称 WorkPLS 可消费。

## Validation

必须运行并在 handoff 中记录：

- `sqlite3 DataBase/agentharness.sqlite ".schema v_workpls_dimension_evidence"`
- `sqlite3 DataBase/agentharness.sqlite "select count(*) from v_workpls_dimension_evidence;"`
- `sqlite3 DataBase/agentharness.sqlite "select workspace_id, snapshot_id, canonical_object_key, data_version, metric_name, unit, count(*) as row_count from v_workpls_dimension_evidence group by 1,2,3,4,5,6 order by row_count desc limit 20;"`
- `sqlite3 DataBase/agentharness.sqlite < DataBase/validations/030_validate_v_workpls_dimension_evidence.sql`
- 针对推荐对象对或跨周期对象路径，报告对象类型合法性、snapshot 绑定、dimension evidence 行数非 0、workspace filtering、finite value、非空 unit/metric/dimension/evidence refs。

如变更 schema/import/data chain，还必须同步验证：

- `DataBase/docs/pls-consumption-guide.md` 已更新。
- `DataBase/console/app.js` 血缘已更新。
- `database_field_comments` 已同步或无需同步的原因。

## Handoff Format

Write `handoff.md` with these sections:

- What Changed
- Files Changed
- Data Readiness Result
- Consumable Evidence For WorkPLS
- Validation
- Contract Drift / Change Requests
- Cross-project Impact
- Risks
- Open Questions
- Memory Used / Memory Candidates

## Dependency

本任务接收 WorkPLS T0021 approved prompt。WorkPLS 下游任务不得开始，直到本任务 handoff 经 AgentHarness Controller approved，并明确返回可消费证据。

## 专业记忆

- domain_memory: `agentops/memory/opencode-algorithm.md`
- canonical_source: `/Users/huangbo/Dev/AgentOps/coding-system/agentops/memory/opencode-algorithm.md`
- Worker 必须先读取对应 CLI 配置目录下的这份 domain memory，再开始实现。若文件缺失，在 `handoff.md` 的 Risks 或 Open Questions 中说明。

## 执行顺序与依赖

- 批次：workpls-preview-data-readiness
- 顺序：1
- 依赖：无
