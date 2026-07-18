# Handoff: T0002 create v_workpls_dimension_evidence

## What Changed

- 新增 `DataBase/migrations/030_create_v_workpls_dimension_evidence.sql`，创建只读 view `v_workpls_dimension_evidence` 并写入 21 个字段的 `database_field_comments`。
- 新增 `DataBase/validations/030_validate_v_workpls_dimension_evidence.sql`，覆盖字段顺序、业务唯一键、唯一 snapshot 绑定、workspace fail closed、有限 value、非空必需字段、JSON array、evidence refs 必需字段、禁止字段、field comments、旧 `dimension_score` 不进入正式 evidence、validation rollback。
- 新增 `DataBase/docs/view-030-workpls-dimension-evidence.md`，记录 view 粒度、来源链路、字段顺序、口径、evidence refs 和 fail-closed 规则。
- 更新 `DataBase/docs/pls-consumption-guide.md`，增加 `v_workpls_dimension_evidence` 对象、推荐读取入口、链路、字段语义、validation 命令和接入注意事项。
- 更新 `DataBase/console/app.js` 静态血缘图，在真实平台画像指标链路中新增 `v_workpls_dimension_evidence`，并连接 `v_platform_profile_channel_dimension_features` 与 `v_pls_audience_profile_snapshots`。
- 实际 migration 编号：`030`。
- 已实际应用到 `DataBase/agentharness.sqlite`：是，执行 `sqlite3 DataBase/agentharness.sqlite ".read DataBase/migrations/030_create_v_workpls_dimension_evidence.sql"`。
- 应用后 schema/行数：`v_workpls_dimension_evidence` 存在，21 个字段，`database_field_comments` active 记录 21 条；`v_workpls_dimension_evidence` 当前 0 行，`platform_profile_tag_metrics` 当前 0 行，`v_platform_profile_channel_dimension_features` 当前 0 行，`v_pls_audience_profile_snapshots` 当前 3 行。

## Files Changed

- `DataBase/migrations/030_create_v_workpls_dimension_evidence.sql`
- `DataBase/validations/030_validate_v_workpls_dimension_evidence.sql`
- `DataBase/docs/view-030-workpls-dimension-evidence.md`
- `DataBase/docs/pls-consumption-guide.md`
- `DataBase/console/app.js`
- `.agentops/tasks/T0002-create-v-workpls-dimension-evidence/handoff.md`

## View SQL Summary

- 粒度：一条来源画像快照、一个 `metric_name + unit + metric_aggregation`、一个 PLS 维度一行。
- 字段顺序：严格按 D008 的 21 个字段输出，未使用 `SELECT *`。
- 来源：`v_platform_profile_channel_dimension_features` 提供 `dimension_metric_sum`、metric/unit、维度、计数和更新时间；`v_platform_profile_tag_metric_semantics` 聚合 `platform_profile_tag_metric` evidence refs；`v_pls_audience_profile_snapshots` 提供唯一 snapshot 的 `data_version` 与 `quality_flags_json`。
- Join / 绑定：按 `workspace_id + profile_id + canonical_object_key + source_batch_id + profile_time_window` 绑定 snapshot，其中 `profile_time_window = snapshots.time_window`；候选 snapshot 分组 `COUNT(*) = 1` 才输出，多重绑定和缺失绑定 fail closed。
- 过滤：要求 `metric_name`、`metric_unit`、`dimension_code`、`dimension_name` 非空；`dimension_metric_sum` 有限且在 `(-1.0e308, 1.0e308)`；`source_quality_flags_json` 是 JSON array；`source_evidence_refs_json` 是非空 JSON array。
- Evidence refs：从真实指标语义行按稳定 JSON 字符串去重排序，元素包含 `sourceSystem`、`sourceRecordType`、`sourceRecordId`、`sourceBatchId`、`sourceFile`、`sourceRow`、`platformTagCatalogId`；不输出 `rowid`、`raw_json`、SQL/view 名、绝对路径或 WorkPLS 派生 quality status。
- 旧 `v_pls_channel_dimension_features.dimension_score=sum(tag_score)` 未参与该 view。

## Validation

- `sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/030_validate_v_workpls_dimension_evidence.sql"`：pass。覆盖 view exists、exact column order、business key duplicates、unique snapshot binding、finite value、required text fields、aggregation fixed `sum`、quality flags JSON array、evidence refs JSON array、evidence refs required fields、forbidden columns absent、field comments complete、valid evidence visible、workspace cross-bind fail closed、multi-snapshot fail closed、old dimension score source not used、forbidden payload absent、validation rows rolled back。
- `sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/024_validate_platform_profile_tag_metrics.sql"`：pass。`platform_profile_tag_metrics_total = 0`，comments/orphan/raw JSON checks pass。
- `sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/025_validate_v_platform_profile_tag_metric_semantics.sql"`：pass。`semantic_view_total = 0`，missing dimension/comments checks pass。
- `sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/026_validate_v_platform_profile_channel_dimension_features.sql"`：pass。`dimension_features_grouping = 0`，sum matching/comments checks pass。
- `sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/029_validate_v_pls_audience_profile_snapshots.sql"`：pass。view shape, active profile count, unique key, JSON flags, active/inactive filtering, no-semantics snapshot visibility, rollback checks pass。
- `sqlite3 DataBase/agentharness.sqlite "PRAGMA foreign_key_check; PRAGMA integrity_check;"`：`integrity_check = ok`，`foreign_key_check` 无输出。
- 额外状态检查：`v_workpls_dimension_evidence_rows = 0`，`platform_profile_tag_metrics_rows = 0`，`v_platform_profile_channel_dimension_features_rows = 0`，`v_pls_audience_profile_snapshots_rows = 3`，`field_comments = 21`。
- 未执行验证：无。

## Risks

- 当前真实指标链路为 0 行：schema/read-surface validated; real data coverage not validated。
- `DataBase/agentharness.sqlite` 已应用 migration，但 SQLite 文件本身未在当前 git status 中显示为 tracked diff；审查时应以 migration 文件和 live SQLite schema 双重核对。
- Snapshot 绑定使用 `source_batch_id` 和 `profile_time_window = snapshots.time_window` 严格匹配；如果后续真实导入的指标批次或时间窗口与 audience profile snapshot 口径不一致，view 会 fail closed 输出 0 行。这符合本任务 fail-closed 原则，但可能需要后续 Controller 决定是否调整 contract 或导入规范。
- Rollback/恢复风险低：本次为 additive view + field comments；恢复方式是执行 `DROP VIEW IF EXISTS v_workpls_dimension_evidence;` 并删除 `database_field_comments.table_name = 'v_workpls_dimension_evidence'` 的记录。未删除或重建现有 table，未 backfill 业务事实。
- 工作树中领取任务前/期间存在未跟踪 `docs/contracts/workpls-dimension-evidence-structure-ledger.md`，本任务只读使用，未修改该文件。

## Open Questions

- Controller decisions needed：无。
- Contract drift：无。实现保持 D001-D009 字段面、来源范围、value/unit 口径、evidence refs、fail-closed 行为和 DataBase-only 范围。
- 跨项目影响：WorkPLS 后续 `Harness Portrait Consumption Contract 0.3.0 + adapter` 仍需等待本 handoff 被 AgentHarness Controller approved；所有正式 Run tasks 继续阻塞，不能把当前 0 行 read surface 视为真实数据覆盖完成。

## Memory Used

- 无。已按要求读取 `docs/notes-database.md`，但没有某条 durable memory 直接影响实现或验证决策。
