---
id: "T0002"
slug: "create-v-workpls-dimension-evidence"
status: "queued"
assignee: "opencode"
domain: "database"
controller: "codex"
base_ref: "e0944a0a40071e4ca9e5a8e7357b5208133b77d6"
batch: "workpls-harness-portrait-0.3.0"
sequence: "1"
depends_on: []
domain_memory: "docs/notes-database.md"
allowed_paths: 
  - "DataBase/migrations/030_create_v_workpls_dimension_evidence.sql"
  - "DataBase/validations/030_validate_v_workpls_dimension_evidence.sql"
  - "DataBase/docs/view-030-workpls-dimension-evidence.md"
  - "DataBase/docs/pls-consumption-guide.md"
  - "DataBase/console/app.js"
validation: 
  - "sqlite3 DataBase/agentharness.sqlite \".read DataBase/validations/030_validate_v_workpls_dimension_evidence.sql\""
  - "sqlite3 DataBase/agentharness.sqlite \".read DataBase/validations/024_validate_platform_profile_tag_metrics.sql\""
  - "sqlite3 DataBase/agentharness.sqlite \".read DataBase/validations/025_validate_v_platform_profile_tag_metric_semantics.sql\""
  - "sqlite3 DataBase/agentharness.sqlite \".read DataBase/validations/026_validate_v_platform_profile_channel_dimension_features.sql\""
  - "sqlite3 DataBase/agentharness.sqlite \".read DataBase/validations/029_validate_v_pls_audience_profile_snapshots.sql\""
  - "sqlite3 DataBase/agentharness.sqlite \"PRAGMA foreign_key_check; PRAGMA integrity_check;\""
---

## 目标

在 AgentHarness 的 `DataBase` 域实施已由 Controller 完成结构确认并由用户整体批准的 additive read surface：新增只读 view `v_workpls_dimension_evidence`，为 WorkPLS 后续 `Harness Portrait Consumption Contract 0.3.0 + adapter` 提供正式 Dimension Evidence 上游读取面。

本任务只解决 AgentHarness 上游 DataBase 读取面。结构确认账本已于 2026-07-18 获用户整体批准：

- `docs/contracts/workpls-dimension-evidence-structure-ledger.md`

不得重新发明、扩大或改变已批准结构。若实现发现账本与真实 schema 冲突，立即停止并在 handoff 中提交 `CONTRACT_CHANGE_REQUEST`。

## 路由与边界

- domain：`database`
- assignee：`opencode`
- allowed root：`DataBase/**`
- 当前预计 migration 编号：`030`
- 若开始实施时 `030` 已被占用，使用实际下一个连续编号并在 handoff 中说明，不得覆盖已有 migration。
- 只允许修改本任务授权的 `DataBase/**` 文件。
- 不得修改 WorkPLS、`OntoBase/**`、`MemoryBase/**`、`KnowledgeBase/**`、`Console/**`、`AGENTS.md`、`CONTEXT.md`、`Orchestration.md`、AgentHarness 共享 contract/docs 或 `.agentops/**` 中除本任务 handoff/state 之外的内容。
- 不得启动其他 CLI。使用 `/agentops-task-next` 领取本任务，完成后使用 `/agentops-task-handoff` 提交。

## 开始前必须完整读取

1. `AGENTS.md`
2. `CONTEXT.md`
3. `Orchestration.md`
4. `docs/notes-database.md`
5. `docs/contracts/workpls-dimension-evidence-structure-ledger.md`
6. `docs/four-bases-one-console-contract.md`
7. `DataBase/migrations/024_create_platform_profile_tag_metrics.sql`
8. `DataBase/migrations/025_create_v_platform_profile_tag_metric_semantics.sql`
9. `DataBase/migrations/026_create_v_platform_profile_channel_dimension_features.sql`
10. `DataBase/migrations/029_create_v_pls_audience_profile_snapshots.sql`
11. `DataBase/validations/024_validate_platform_profile_tag_metrics.sql`
12. `DataBase/validations/025_validate_v_platform_profile_tag_metric_semantics.sql`
13. `DataBase/validations/026_validate_v_platform_profile_channel_dimension_features.sql`
14. `DataBase/validations/029_validate_v_pls_audience_profile_snapshots.sql`
15. `DataBase/docs/pls-consumption-guide.md`
16. `DataBase/console/app.js`
17. `/Users/huangbo/Dev/Projects/workpls/docs/contracts/harness-portrait-consumption-contract.md`
18. `/Users/huangbo/Dev/Projects/workpls/docs/contracts/harness-portrait-ccr-decision-ledger.md`

开始编辑前检查工作树，保留并避开他人的未提交改动。不得覆盖、回滚或顺手整理与本任务无关的改动。

## 已批准结构：D001-D009

### 事实来源范围

正式 Dimension Evidence 只基于以下真实平台画像指标链路：

```text
platform_profile_tag_metrics
  -> v_platform_profile_tag_metric_semantics
  -> v_platform_profile_channel_dimension_features
  -> v_workpls_dimension_evidence

v_pls_audience_profile_snapshots
  -> v_workpls_dimension_evidence
```

旧 `v_pls_channel_dimension_features.dimension_score=sum(tag_score)` 继续仅作诊断，不得补造 unit，不得进入正式 evidence。

### View 与粒度

- 新增只读 view：`v_workpls_dimension_evidence`。
- 一条来源画像快照、一个 metric、一个 PLS 维度一行。
- 必须只输出能唯一绑定到 `v_pls_audience_profile_snapshots` 的行。
- 绑定不上、绑定多条、workspace 不一致、profile/object 不一致或必要字段不合格时不输出。

业务唯一键：

```text
workspace_id
+ profile_id
+ canonical_object_key
+ data_version
+ metric_name
+ metric_unit
+ profile_time_window
+ source_batch_id
+ dimension_key
```

### 精确字段面与顺序

只允许以下字段，且 view 字段顺序必须精确一致；禁止 `SELECT *`：

1. `workspace_id`
2. `snapshot_id`
3. `profile_id`
4. `canonical_object_key`
5. `data_version`
6. `metric_name`
7. `metric_aggregation`
8. `dimension_key`
9. `dimension_label`
10. `value`
11. `unit`
12. `profile_time_window`
13. `source_batch_id`
14. `source_quality_flags_json`
15. `source_evidence_refs_json`
16. `metric_row_count`
17. `tag_type_count`
18. `tag_value_count`
19. `avg_mapping_confidence`
20. `latest_metric_updated_at`
21. `latest_mapping_updated_at`

字段映射：

| 输出字段 | 来源或规则 |
| --- | --- |
| `snapshot_id` | `profile_id` |
| `data_version` | 来自唯一绑定的 `v_pls_audience_profile_snapshots.data_version` |
| `metric_aggregation` | 固定字符串 `sum` |
| `dimension_key` | `dimension_code` |
| `dimension_label` | `dimension_name` |
| `value` | `dimension_metric_sum` |
| `unit` | `metric_unit` |
| `source_quality_flags_json` | 绑定 snapshot 的 `quality_flags_json` |
| `source_evidence_refs_json` | 聚合真实指标来源记录 |

不得输出 `dimension_metric_avg`、`dimension_metric_max`、display fields、raw JSON、SQL/view 名、SQLite `rowid`、绝对文件路径正文或 WorkPLS 派生 quality status。

### Evidence refs

`source_evidence_refs_json` 必须是 JSON array。每个元素至少包含：

```json
{
  "sourceSystem": "agentharness",
  "sourceRecordType": "platform_profile_tag_metric",
  "sourceRecordId": "metric_id",
  "sourceBatchId": "source_batch_id",
  "sourceFile": "source_file",
  "sourceRow": 1,
  "platformTagCatalogId": "platform_tag_catalog_id"
}
```

数组必须按稳定键去重排序。不得输出 SQLite `rowid`、原始 `raw_json`、绝对文件路径正文或 WorkPLS 派生 quality status。

### Value、unit 与可比性

- 正式 `value = dimension_metric_sum`。
- `unit = metric_unit`。
- `metric_aggregation = 'sum'`。
- 原样支持多 `metric_name + metric_unit`。
- AgentHarness 只声明同一 `metric_name + unit + metric_aggregation` 内的 evidence 可用于同类横向或跨周期比较。
- 不同 metric、unit 或 aggregation 不得混比。

### 空值与 fail-closed

读取面只输出合格行：

- 没有指标或没有 approved PLS 映射的维度不输出。
- 不补零、不补默认 unit、不补默认 quality status。
- `value` 非有限数不输出。
- `unit`、`metric_name`、`dimension_key`、`dimension_label`、`source_evidence_refs_json` 缺失或为空不输出。
- snapshot 绑定失败或多义时不输出。

WorkPLS coverage 只能根据返回的实际维度计算；缺失维度继续由 WorkPLS quality policy 决定 fail closed 或 limited。

## 预期改动

若 `030` 仍可用：

- `DataBase/migrations/030_create_v_workpls_dimension_evidence.sql`
- `DataBase/validations/030_validate_v_workpls_dimension_evidence.sql`
- `DataBase/docs/view-030-workpls-dimension-evidence.md`

同时维护：

- `DataBase/docs/pls-consumption-guide.md`
- `DataBase/console/app.js` 中的静态血缘关系图
- migration 中为 view 全部 21 个字段写入 `database_field_comments`

不得安装依赖，不得删除或重建现有 table，不得 commit 或 push。

## 变更影响清单

| 变更项 | 权威域 | 当前状态 | 本次动作 | contract 是否受影响 | 需要派发的域 | 明确不修改的域 |
| --- | --- | --- | --- | --- | --- | --- |
| WorkPLS 正式 Dimension Evidence read surface | DataBase + shared contract | 缺正式 unit-bearing 读取面 | 新增 additive ReadModel/contract 候选 | 是 | `database/opencode` | WorkPLS、Console、MemoryBase、KnowledgeBase |
| 维度语义与 metric comparability | OntoBase/DataBase 边界 | OntoBase 已记录 `Platform Profile Dimension Metric Sum` | 本轮不新增 OntoBase 结构；沿用已记录语义绑定 | 是 | 本轮不派 OntoBase，除非实现发现 drift | DataBase 不自行发明新语义 |
| Snapshot identity binding | DataBase | Snapshot view 有 `data_version`；真实指标聚合 view 无 `data_version` | 新 view 必须通过唯一 snapshot 绑定补足 `data_version` | 是 | `database/opencode` | WorkPLS 不先行适配 |
| 旧 `dimension_score=sum(tag_score)` | DataBase | 已明确无 unit | 保持诊断用途，不进入正式 evidence | 否 | 无 | 无 |
| 真实平台画像指标数据覆盖 | DataBase | 当前真实指标链路 0 行 | 验证 schema/read-surface；不能声称真实数据覆盖 | 是 | `database/opencode` 报告限制 | 不用 mock 或默认值填补 |

## 验证要求

必须使用仓库现有 `sqlite3` 工作流验证真实 SQLite 行为，不得以 typecheck 代替。至少覆盖：

1. view 存在，字段名与字段顺序精确一致，无额外字段。
2. 业务唯一键无重复。
3. 每一行都绑定到唯一 `v_pls_audience_profile_snapshots` snapshot。
4. workspace filtering 生效，不能跨 workspace 绑定。
5. `value` 为有限数。
6. `metric_name`、`unit`、`dimension_key`、`dimension_label` 非空。
7. `metric_aggregation` 固定为 `sum`。
8. `source_quality_flags_json` 为有效 JSON array。
9. `source_evidence_refs_json` 为非空有效 JSON array，元素包含必需字段。
10. 缺失或多重 snapshot 绑定 fail closed。
11. 不输出旧 `dimension_score` 来源行。
12. 不输出 raw JSON、SQLite `rowid` 或 WorkPLS 派生 quality status。
13. `database_field_comments` 覆盖全部 21 个字段。
14. `DataBase/docs/pls-consumption-guide.md` 已同步。
15. `DataBase/console/app.js` 血缘图已同步。
16. `PRAGMA foreign_key_check` 无异常。
17. `PRAGMA integrity_check` 返回 `ok`。
18. validation 本身不留下测试数据或修改业务事实。
19. 现有相关 validations `024`、`025`、`026`、`029` 继续通过。

至少实际执行并逐条记录结果：

```bash
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/030_validate_v_workpls_dimension_evidence.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/024_validate_platform_profile_tag_metrics.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/025_validate_v_platform_profile_tag_metric_semantics.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/026_validate_v_platform_profile_channel_dimension_features.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/029_validate_v_pls_audience_profile_snapshots.sql"
sqlite3 DataBase/agentharness.sqlite "PRAGMA foreign_key_check; PRAGMA integrity_check;"
```

如果实际 migration 编号不是 `030`，相应调整新 validation 命令。若未将 migration 应用到 `DataBase/agentharness.sqlite`，必须在隔离副本或等价临时数据库中完成 migration + validation 的 SQLite 行为验证，并说明原因与方法。

当前真实指标链路为 0 行。handoff 必须明确报告：

```text
schema/read-surface validated; real data coverage not validated
```

不得声称正式 Comparison Run 数据覆盖已经可用。

## Handoff Back 格式

`handoff.md` 必须包含：

- 完成项。
- 实际 changed files。
- 实际 migration 编号。
- view 最终 SQL 的粒度、字段顺序、来源、join、过滤与 evidence refs 摘要。
- 实际执行的每条验证命令及结果。
- 未执行验证及原因。
- 当前真实指标 0 行导致的覆盖限制。
- 对现有数据库的数据兼容性和 rollback/恢复风险。
- contract drift；无则明确写无。
- 跨项目影响。
- 风险与未验证项。
- `Controller decisions needed`；无则明确写无。
- 明确说明是否实际应用到 `DataBase/agentharness.sqlite`，以及应用前后 schema、行数和完整性结果（如适用）。
- 如发现结构冲突，附 `CONTRACT_CHANGE_REQUEST`，不得自行偏离 D001-D009。

## 执行顺序

- 跨项目批次：`workpls-harness-portrait-0.3.0`
- 本任务顺序：`1`
- 前置依赖：无。
- 后续条件：只有本任务 handoff 经 AgentHarness Controller `approved` 后，WorkPLS Controller 才能创建并推进 WorkPLS `harness contract 0.3.0 + adapter` 独立任务；所有正式 Run tasks 继续阻塞。

## 专业记忆

- domain_memory: `docs/notes-database.md`
- Worker 必须先读取本 domain memory，再开始实现。若文件缺失，在 `handoff.md` 的 Risks 或 Open Questions 中说明。

## 专业记忆

- domain_memory: `docs/notes-database.md`
- canonical_source: `/Users/huangbo/Dev/AgentOps/coding-system/docs/notes-database.md`
- Worker 必须先读取对应 CLI 配置目录下的这份 domain memory，再开始实现。若文件缺失，在 `handoff.md` 的 Risks 或 Open Questions 中说明。

## 执行顺序与依赖

- 批次：workpls-harness-portrait-0.3.0
- 顺序：1
- 依赖：无
