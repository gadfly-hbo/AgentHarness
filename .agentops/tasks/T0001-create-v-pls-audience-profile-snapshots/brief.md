---
id: "T0001"
slug: "create-v-pls-audience-profile-snapshots"
status: "queued"
assignee: "opencode"
domain: "database"
controller: "codex"
base_ref: "5bcd29bfe1240cd5905f2b70bd7c6af02b273d36"
batch: "workpls-harness-portrait-0.2.0"
sequence: "1"
depends_on: []
domain_memory: "docs/notes-database.md"
allowed_paths: 
  - "DataBase/**"
validation: 
  - "sqlite3 DataBase/agentharness.sqlite \".read DataBase/validations/029_validate_v_pls_audience_profile_snapshots.sql\""
  - "sqlite3 DataBase/agentharness.sqlite \".read DataBase/validations/015_validate_pls_channel_objects.sql\""
  - "sqlite3 DataBase/agentharness.sqlite \".read DataBase/validations/017_validate_pls_audience_profiles.sql\""
  - "sqlite3 DataBase/agentharness.sqlite \".read DataBase/validations/019_validate_v_pls_channel_profile_overview.sql\""
  - "sqlite3 DataBase/agentharness.sqlite \".read DataBase/validations/021_validate_v_pls_audience_tag_semantics.sql\""
  - "sqlite3 DataBase/agentharness.sqlite \"PRAGMA foreign_key_check; PRAGMA integrity_check;\""
---

## 目标

在 AgentHarness 的 `DataBase` 域实施已由 Controller 完成结构裁决并整体批准的 additive migration：新增只读 view `v_pls_audience_profile_snapshots`，为后续 WorkPLS `Harness Portrait Consumption Contract/adapter 0.2.0` 提供稳定、最小、版本化的画像快照 metadata 读取面。

本任务只解决 AgentHarness 上游读取面。S127–S136 已于 2026-07-17 获用户整体批准，不得重新发明、扩大或改变已批准结构。

## 路由与边界

- domain：`database`
- assignee：`opencode`
- allowed root：`DataBase/**`
- 当前预计 migration 编号：`029`
- 若开始实施时 `029` 已被占用，使用实际下一个连续编号并在 handoff 中说明，不得覆盖已有 migration。
- 只允许修改 `DataBase/**`。
- 不得修改 WorkPLS、`OntoBase/**`、`MemoryBase/**`、`KnowledgeBase/**`、`Console/**`、`AGENTS.md`、`CONTEXT.md`、`Orchestration.md`、AgentHarness 共享 contract/docs 或 `.agentops/**` 中除本任务 handoff/state 之外的内容。
- 不得启动其他 CLI。使用 `/agentops-task-next` 领取本任务，完成后使用 `/agentops-task-handoff` 提交。

## 开始前必须完整读取

1. `AGENTS.md`
2. `CONTEXT.md`
3. `Orchestration.md`
4. `docs/notes-database.md`
5. `/Users/huangbo/Dev/Projects/workpls/docs/contracts/harness-portrait-ccr-decision-ledger.md`
6. `DataBase/migrations/015_create_pls_channel_objects.sql`
7. `DataBase/migrations/017_create_pls_audience_profiles.sql`
8. `DataBase/migrations/019_create_v_pls_channel_profile_overview.sql`
9. `DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql`
10. `DataBase/validations/017_validate_pls_audience_profiles.sql`
11. `DataBase/validations/019_validate_v_pls_channel_profile_overview.sql`
12. `DataBase/validations/021_validate_v_pls_audience_tag_semantics.sql`
13. `DataBase/docs/pls-consumption-guide.md`
14. `DataBase/console/app.js`

开始编辑前检查工作树，保留并避开他人的未提交改动。当前任务创建时已发现工作树非干净状态，`AGENTS.md` 有未提交修改；不得覆盖、回滚或顺手整理。

## 已批准结构：S127–S136

### View 与粒度

- 新增只读 view：`v_pls_audience_profile_snapshots`。
- 每个来源画像快照一行。
- 业务唯一键：`workspace_id + profile_id + data_version`。
- `canonical_object_key` 仅作为画像所属对象的不透明引用。
- 不得按 object 折叠，不得选择 latest。

### 精确字段面与顺序

只允许以下字段，且 view 字段顺序必须精确一致；禁止 `SELECT *`：

1. `workspace_id`
2. `profile_id`
3. `canonical_object_key`
4. `data_version`
5. `source_batch_id`
6. `generated_at`
7. `time_window`
8. `sample_size`
9. `confidence`
10. `quality_flags_json`

### 来源、关联与过滤

- 主来源为 `pls_audience_profiles`。
- 只返回 `status = 'active'` 的 profile。
- 必须关联同 `workspace_id`、`canonical_object_key`、`data_version` 且 `status = 'active'` 的 `pls_channel_objects`。
- 忠实投影来源值，不得用空字符串、`0`、固定置信度或其他默认值补缺失。
- 不得写入或派生 WorkPLS quality status。
- 不得投影 `tags_json`、`unmapped_fields_json`、`raw_json`、对象展示字段或其他未批准字段。

### 兼容边界

- 这是 additive migration。
- 不修改底表、旧 view 或现有业务数据，无需 backfill。
- 不修改 `v_pls_audience_tag_semantics`。
- 不修改 `v_pls_channel_profile_overview`。
- 不修改 observation 表/view。
- 不给 `dimension_score` 添加或虚构 `unit`。
- 不借本任务修改共享 consumption contract；该 contract 由 Controller 在后续 WorkPLS `0.2.0` 独立任务中升级。

若已批准结构与 AgentHarness 真实 schema 冲突，立即停止实施并在 handoff 中提交 `CONTRACT_CHANGE_REQUEST`；不得自行改变 grain、字段、过滤、身份、空值或版本规则。

## 预期改动

若 `029` 仍可用：

- `DataBase/migrations/029_create_v_pls_audience_profile_snapshots.sql`
- `DataBase/validations/029_validate_v_pls_audience_profile_snapshots.sql`
- `DataBase/docs/view-029-pls-audience-profile-snapshots.md`

同时维护：

- `DataBase/docs/pls-consumption-guide.md`
- `DataBase/console/app.js` 中的静态血缘关系图
- 如现有维护方式要求，更新 `DataBase/README.md`
- migration 中为 view 全部 10 个字段写入 `database_field_comments`

不得安装依赖，不得删除或重建现有 table/view，不得 commit 或 push。

## 变更影响清单

| 变更项 | 权威域 | 当前状态 | 本次动作 | contract 是否受影响 | 需要派发的域 | 明确不修改的域 |
| --- | --- | --- | --- | --- | --- | --- |
| audience profile snapshot metadata 只读读取面 | AgentHarness DataBase | `pls_audience_profiles` 已有事实；现有 semantics view 会丢失无 tag semantics 的 profile | 新增 additive view、字段注释、validation、文档与血缘 | 不在本任务修改 shared contract；为后续 WorkPLS `0.2.0` 提供上游前提 | `database/opencode` | OntoBase、MemoryBase、KnowledgeBase、Console、WorkPLS |
| WorkPLS consumption contract/adapter 0.2.0 | WorkPLS | 尚未在本批次实施 | 本任务不做；等待上游 handoff 获批后另建任务 | 后续任务会升级 | 后续由 WorkPLS Controller 单独派发 | 本任务内所有 AgentHarness 非 DataBase 域 |

## 验证要求

必须使用仓库现有 `sqlite3` 工作流验证真实 SQLite 行为，不得以 typecheck 代替。至少覆盖：

1. view 存在，字段名与字段顺序精确一致，无额外字段。
2. 每个符合条件的 active profile snapshot 恰好出现一行。
3. `(workspace_id, profile_id, data_version)` 无重复。
4. inactive/archived profile 不出现。
5. 版本匹配 object 非 active 时不出现。
6. profile 没有 tag semantics 行时，metadata 仍可从新 view 读取。
7. `source_batch_id`、`sample_size`、`confidence` 等来源值不被补默认。
8. `quality_flags_json` 保持有效 JSON 数组。
9. `PRAGMA foreign_key_check` 无异常。
10. `PRAGMA integrity_check` 返回 `ok`。
11. validation 本身不留下测试数据或修改业务事实。
12. 现有相关 validations `015`、`017`、`019`、`021` 继续通过。
13. 如项目流程要求将 migration 应用到 `DataBase/agentharness.sqlite`，应用前先核对目标和备份/恢复方式；只应用本 additive migration，并报告应用前后 schema、行数和完整性结果。

至少实际执行并逐条记录结果：

```bash
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/029_validate_v_pls_audience_profile_snapshots.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/015_validate_pls_channel_objects.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/017_validate_pls_audience_profiles.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/019_validate_v_pls_channel_profile_overview.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/021_validate_v_pls_audience_tag_semantics.sql"
sqlite3 DataBase/agentharness.sqlite "PRAGMA foreign_key_check; PRAGMA integrity_check;"
```

如果实际 migration 编号不是 `029`，相应调整新 validation 命令。若未将 migration 应用到 `DataBase/agentharness.sqlite`，必须在隔离副本或等价临时数据库中完成 migration + validation 的 SQLite 行为验证，并说明原因与方法。validation 应使用 transaction/rollback 或其他仓库既有安全方式，确保不留下测试数据。

## Handoff Back 格式

`handoff.md` 必须包含：

- 完成项。
- 实际 changed files。
- 实际 migration 编号。
- view 最终 SQL 的粒度、字段顺序、来源、join 与过滤摘要。
- 实际执行的每条验证命令及结果。
- 未执行验证及原因。
- 对现有数据库的数据兼容性和 rollback/恢复风险。
- contract drift；无则明确写无。
- 跨域影响。
- 风险与未验证项。
- `Controller decisions needed`；无则明确写无。
- 明确说明是否实际应用到 `DataBase/agentharness.sqlite`，以及应用前后 schema、行数和完整性结果（如适用）。
- 如发现结构冲突，附 `CONTRACT_CHANGE_REQUEST`，不得自行偏离 S127–S136。

## 执行顺序

- 跨项目批次：`workpls-harness-portrait-0.2.0`
- 本任务顺序：`1`
- 前置依赖：无。
- 后续条件：只有本任务 handoff 经 AgentHarness Controller `approved` 后，才可由 WorkPLS Controller 创建并推进 WorkPLS consumption contract/schema gate/adapter `0.2.0` 独立任务。

## 专业记忆

- domain_memory: `docs/notes-database.md`
- canonical_source: `/Users/huangbo/Dev/AgentOps/coding-system/docs/notes-database.md`
- Worker 必须先读取对应 CLI 配置目录下的这份 domain memory，再开始实现。若文件缺失，在 `handoff.md` 的 Risks 或 Open Questions 中说明。

## 执行顺序与依赖

- 批次：workpls-harness-portrait-0.2.0
- 顺序：1
- 依赖：无
