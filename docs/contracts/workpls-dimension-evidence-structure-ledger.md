# WorkPLS Dimension Evidence 结构确认账本

## 状态

- 日期：2026-07-18
- 请求仓库：`/Users/huangbo/Dev/Projects/workpls`
- 目标仓库：`/Users/huangbo/Dev/AgentHarness`
- Controller：`Codex / AgentHarness Controller`
- 状态：结构确认明细已完成，等待用户整体批准
- 适用 Gate：AgentHarness `Structural Confirmation Gate`

本文记录 WorkPLS 请求 AgentHarness 提供正式 `Dimension Evidence`
read surface 的结构确认结果。在用户整体批准前，不得创建或修改
DataBase migration、view、validation、field comments 或 lineage。

## 范围

目标是在 AgentHarness DataBase 中新增一个可供 WorkPLS 正式
`Comparison Run` 消费的只读 Dimension Evidence 读取面。读取面必须：

- workspace-scoped。
- 绑定到 `v_pls_audience_profile_snapshots` 的来源画像快照。
- 为每个实际存在的 PLS 标准维度提供有限 `value` 和明确 `unit`。
- 保留 source quality flags 与 source evidence refs。
- 缺失、不兼容或绑定失败时 fail closed。

## 权威证据

| 证据 | 约束 |
| --- | --- |
| WorkPLS `docs/contracts/harness-portrait-consumption-contract.md` `0.2.0` | WorkPLS 当前只批准 snapshot metadata 和 overview；Dimension Evidence 继续 fail closed，新增读取面必须升级 contract |
| WorkPLS `docs/contracts/harness-portrait-ccr-decision-ledger.md` S127 | 现有 `v_pls_channel_dimension_features.dimension_score=sum(tag_score)` 没有 unit，不得补造为正式 evidence |
| `DataBase/migrations/024_create_platform_profile_tag_metrics.sql` | 真实平台画像指标长表已有 `metric_name`、`metric_value`、`metric_unit` 和 provenance |
| `DataBase/migrations/025_create_v_platform_profile_tag_metric_semantics.sql` | 真实指标可展开到 PLS 标签值语义 |
| `DataBase/migrations/026_create_v_platform_profile_channel_dimension_features.sql` | 真实指标可按 `metric_name + metric_unit + profile_time_window + source_batch_id + dimension_code` 聚合 |
| `DataBase/migrations/029_create_v_pls_audience_profile_snapshots.sql` | 已有 workspace-scoped snapshot metadata 读取面 |
| `OntoBase/pls-ontology-inventory.md` | 已记录 `Platform Profile Dimension Metric Sum` 与 DataBase 入口绑定 |
| 当前 SQLite 只读检查 | `platform_profile_tag_metrics` 与 `v_platform_profile_channel_dimension_features` 当前均为 0 行 |

## 变更影响清单

| 变更项 | 权威域 | 当前状态 | 本次动作 | contract 是否受影响 | 需要派发的域 | 明确不修改的域 |
| --- | --- | --- | --- | --- | --- | --- |
| WorkPLS 正式 Dimension Evidence read surface | DataBase + shared contract | 缺正式 unit-bearing 读取面 | 新增 additive ReadModel/contract 候选 | 是 | Controller 结构确认后派 `database/opencode` | WorkPLS、Console、MemoryBase、KnowledgeBase |
| 维度语义与 metric comparability | OntoBase/DataBase 边界 | OntoBase 已记录 `Platform Profile Dimension Metric Sum` | 本轮不新增 OntoBase 结构；沿用已记录语义绑定 | 是 | 本轮不派 OntoBase，除非实现发现 drift | DataBase 不自行发明新语义 |
| Snapshot identity binding | DataBase | Snapshot view 有 `data_version`；真实指标聚合 view 无 `data_version` | 新 view 必须通过唯一 snapshot 绑定补足 `data_version` | 是 | `database/opencode` | WorkPLS 不先行适配 |
| 旧 `dimension_score=sum(tag_score)` | DataBase | 已明确无 unit | 保持诊断用途，不进入正式 evidence | 否 | 无 | 无 |
| 真实平台画像指标数据覆盖 | DataBase | 当前真实指标链路 0 行 | 验证 schema/read-surface；不能声称真实数据覆盖 | 是 | `database/opencode` 报告限制 | 不用 mock 或默认值填补 |

## 决策台账

| Sequence | Topic | Recommendation | Reason | User decision | Consistency | Status | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| D001 | 正式 Dimension Evidence 的事实来源范围 | 只基于 `platform_profile_tag_metrics -> v_platform_profile_tag_metric_semantics -> v_platform_profile_channel_dimension_features`；旧 `dimension_score` 继续诊断；snapshot 绑定不上 fail closed | 真实指标链路已有 `metric_name/value/unit` 与 provenance；旧 score 无 unit | A | 一致 | Confirmed | `DataBase/migrations/024-026`、WorkPLS S127 |
| D002 | 读取面粒度与稳定身份 | 一条来源画像快照 × 一个 metric × 一个 PLS 维度；唯一键含 `workspace_id/profile_id/canonical_object_key/data_version/metric_name/metric_unit/profile_time_window/source_batch_id/dimension_key` | WorkPLS 需要 snapshot-grain evidence；`data_version` 必须来自唯一 snapshot 绑定 | A | 一致 | Confirmed | `v_pls_audience_profile_snapshots`、`v_platform_profile_channel_dimension_features` |
| D003 | WorkPLS `value` 口径 | 正式 `value = dimension_metric_sum`；`unit = metric_unit`；`metric_aggregation = 'sum'` | OntoBase 已记录 `Platform Profile Dimension Metric Sum`；现有 view 主聚合为 sum | A | 一致 | Confirmed | `OntoBase/pls-ontology-inventory.md`、migration 026 |
| D004 | 允许进入正式 evidence 的 metric/unit 范围 | 原样支持多 `metric_name + metric_unit`；只允许同 metric/unit/aggregation 内比较 | 导入规格支持多种指标；跨 metric/unit 比较会制造错误 | A | 一致 | Confirmed | `DataBase/docs/platform-profile-extract-spec-v0.1.md` |
| D005 | `sourceQualityFlags` 与 `sourceEvidenceRefs` | 继承 snapshot `quality_flags_json`；聚合 `platform_profile_tag_metric` evidence refs；不输出 raw JSON、rowid 或派生 quality status | 保留质量与来源追溯，同时避免暴露内部 SQL/raw 结构 | A | 一致 | Confirmed | migrations 024、029 |
| D006 | 缺失维度、空值和绑定失败行为 | 只输出合格 evidence 行；缺失维度不补零；绑定失败不输出 | 延续 WorkPLS fail-closed 原则，避免伪造 evidence | A | 一致 | Confirmed | WorkPLS 0.2.0 failure rules |
| D007 | 物理读取面命名与形态 | 新增只读 view `v_workpls_dimension_evidence`；不改现有通用 view；不新增表，不物化数据 | 专用 view 固定 WorkPLS contract shape，保持 additive 和低破坏面 | A | 一致 | Confirmed | DataBase maintenance rules |
| D008 | `v_workpls_dimension_evidence` 字段面 | 使用最小正式 contract 字段面；不输出 avg/max、display/raw 字段 | 覆盖 WorkPLS 必需字段，避免固化诊断和展示字段 | A | 一致 | Confirmed | WorkPLS logical fields |
| D009 | 验证、文档与任务交付范围 | 结构批准后只创建一个 `database/opencode` 任务，授权 migration、validation、view doc、consumption guide 和 lineage sync | 本轮可由 DataBase additive view 承接；真实数据导入和 WorkPLS adapter 升级是后续任务 | A | 一致 | Confirmed | AgentHarness routing and maintenance rules |

## 派生结构方案

### 读取面

新增只读 view：

```text
v_workpls_dimension_evidence
```

### 来源链路

```text
platform_profile_tag_metrics
  -> v_platform_profile_tag_metric_semantics
  -> v_platform_profile_channel_dimension_features
  -> v_workpls_dimension_evidence

v_pls_audience_profile_snapshots
  -> v_workpls_dimension_evidence
```

`v_workpls_dimension_evidence` 必须只输出能唯一绑定到
`v_pls_audience_profile_snapshots` 的行。无法绑定、绑定多条、workspace 不一致、
profile/object 不一致或必要字段不合格时不输出。

### 粒度与唯一身份

一条来源画像快照、一个 metric、一个 PLS 维度一行。

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

### 字段面

字段固定为：

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

### Evidence refs

`source_evidence_refs_json` 为 JSON array。每个元素至少包含：

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

数组必须按稳定键去重排序。不得输出 SQLite `rowid`、原始 `raw_json`、
绝对文件路径正文或 WorkPLS 派生 quality status。

### 空值与 fail-closed

读取面只输出合格行：

- 没有指标或没有 approved PLS 映射的维度不输出。
- 不补零、不补默认 unit、不补默认 quality status。
- `value` 非有限数不输出。
- `unit`、`metric_name`、`dimension_key`、`dimension_label`、`source_evidence_refs_json` 缺失或为空不输出。
- snapshot 绑定失败或多义时不输出。

WorkPLS coverage 只能根据返回的实际维度计算；缺失维度继续由 WorkPLS quality policy
决定 fail closed 或 limited。

### 可比性

AgentHarness 只声明同一 `metric_name + unit + metric_aggregation` 内的 evidence
可用于同类横向或跨周期比较。不同 metric、unit 或 aggregation 不得混比。

### 当前数据覆盖限制

当前 SQLite 检查显示：

| 对象 | 行数 |
| --- | ---: |
| `platform_profile_tag_metrics` | 0 |
| `v_platform_profile_channel_dimension_features` | 0 |
| `v_pls_audience_profile_snapshots` | 3 |
| `v_pls_channel_dimension_features` | 5 |

因此本轮实施后只能声明 schema/read-surface/validation 可用；不能声明真实数据覆盖已经可用于正式 Comparison Run。

## 授权后的实施范围

整体批准后，Controller 创建一个 Task Bus 任务：

- domain：`database`
- assignee：`opencode`
- allowed paths：
  - `DataBase/migrations/030_create_v_workpls_dimension_evidence.sql`
  - `DataBase/validations/030_validate_v_workpls_dimension_evidence.sql`
  - `DataBase/docs/view-030-workpls-dimension-evidence.md`
  - `DataBase/docs/pls-consumption-guide.md`
  - `DataBase/console/app.js`

不得修改：

- WorkPLS repository。
- `OntoBase/**`、`KnowledgeBase/**`、`MemoryBase/**`、`Console/**`。
- 现有 view 语义，除非实现发现必须回到 Controller 决策。

## 最低验证要求

DataBase handoff 必须报告：

- migration/schema validation。
- view 精确字段 shape。
- 业务唯一粒度验证。
- workspace filtering validation。
- snapshot identity binding validation。
- finite `value` validation。
- 非空 `unit/metric_name/dimension_key/dimension_label` validation。
- 缺失、多重或不兼容 snapshot 绑定 fail-closed validation。
- source flags/provenance JSON validation。
- field comments validation。
- `DataBase/docs/pls-consumption-guide.md` sync。
- `DataBase/console/app.js` lineage sync。
- 当前真实指标 0 行时，明确报告 `schema/read-surface validated; real data coverage not validated`。

## 后续依赖

WorkPLS `v0.0-formal-portrait-comparison` sequence 4
`WorkPLS harness contract 0.3.0 + adapter` 以及所有正式 Run tasks
必须继续阻塞，直到：

1. AgentHarness DataBase task handoff approved。
2. Controller 明确发布可消费的 view name、columns、contract/version/path 与验证证据。
3. WorkPLS 自身再升级 consumption contract 和 adapter。

## 待整体批准

本账本目前只完成逐项确认。请用户整体批准后，Controller 才能创建 DataBase
Task Bus 实施任务。
