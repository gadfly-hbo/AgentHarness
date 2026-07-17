# Handoff: T0001 create v_pls_audience_profile_snapshots

## What Changed

- 新增 additive migration `029_create_v_pls_audience_profile_snapshots.sql`。
- 新增只读 view `v_pls_audience_profile_snapshots`，每个 active 来源画像快照一行。
- 实际 migration 编号：`029`。
- View 最终 SQL 摘要：
  - 粒度：`pls_audience_profiles` 每个来源画像快照一行。
  - 字段顺序：`workspace_id`, `profile_id`, `canonical_object_key`, `data_version`, `source_batch_id`, `generated_at`, `time_window`, `sample_size`, `confidence`, `quality_flags_json`。
  - 来源：主来源 `pls_audience_profiles`。
  - Join：inner join `pls_channel_objects`，条件为同 `workspace_id`、`canonical_object_key`、`data_version`。
  - 过滤：`profiles.status = 'active'` 且 `objects.status = 'active'`。
  - 投影：忠实投影来源字段，不补默认值，不投影 `tags_json`、`unmapped_fields_json`、`raw_json`、对象展示字段或 WorkPLS quality status。
- Migration 中为 view 全部 10 个字段写入 `database_field_comments`。
- 新增 029 validation，覆盖 view 存在、字段顺序、active 双侧过滤、业务唯一键、无 tag semantics 仍可读、来源空值保留、quality flags JSON 数组和验证数据回滚。
- 新增 view 文档，并同步维护 `pls-consumption-guide.md`、HTML console 静态血缘关系图和 `DataBase/README.md` 文档入口。
- 已实际应用到 `DataBase/agentharness.sqlite`。

## Files Changed

- `DataBase/migrations/029_create_v_pls_audience_profile_snapshots.sql`
- `DataBase/validations/029_validate_v_pls_audience_profile_snapshots.sql`
- `DataBase/docs/view-029-pls-audience-profile-snapshots.md`
- `DataBase/docs/pls-consumption-guide.md`
- `DataBase/console/app.js`
- `DataBase/README.md`
- `DataBase/agentharness.sqlite`：已应用 additive migration；当前 git status 未显示该 SQLite 文件为 tracked diff。

## Validation

- 应用 migration 前：
  - `v_pls_audience_profile_snapshots` view count：`0`。
  - `database_field_comments` 中该 view 注释 count：`0`。
  - `pls_audience_profiles` 行数：`3`。
  - `pls_channel_objects` 行数：`6`。
  - `PRAGMA integrity_check`：`ok`。
- 应用 migration：
  - `sqlite3 DataBase/agentharness.sqlite ".read DataBase/migrations/029_create_v_pls_audience_profile_snapshots.sql"`：成功，无输出。
- 应用 migration 后：
  - `v_pls_audience_profile_snapshots` view count：`1`。
  - `database_field_comments` 中该 view 注释 count：`10`。
  - `v_pls_audience_profile_snapshots` 行数：`3`。
  - `pls_audience_profiles` 行数：`3`。
  - `pls_channel_objects` 行数：`6`。
  - `PRAGMA table_info(v_pls_audience_profile_snapshots)` 显示 10 个字段，顺序符合 brief。
  - `PRAGMA integrity_check`：`ok`。
- `sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/029_validate_v_pls_audience_profile_snapshots.sql"`：全部 `pass`。
- `sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/015_validate_pls_channel_objects.sql"`：关键检查全部 `pass`，明细查询正常输出。
- `sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/017_validate_pls_audience_profiles.sql"`：关键检查全部 `pass`，明细查询正常输出。
- `sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/019_validate_v_pls_channel_profile_overview.sql"`：关键检查全部 `pass`，明细查询正常输出。
- `sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/021_validate_v_pls_audience_tag_semantics.sql"`：关键检查全部 `pass`，明细查询正常输出。
- `sqlite3 DataBase/agentharness.sqlite "PRAGMA foreign_key_check; PRAGMA integrity_check;"`：`foreign_key_check` 无输出，`integrity_check` 返回 `ok`。
- 未执行验证：无。

## Risks

- 现有底表 `pls_audience_profiles.source_batch_id` 和 `pls_audience_profiles.confidence` 为 `NOT NULL`，所以 validation 不能构造这两个字段为 `NULL` 的来源样例；本任务未改变底表结构，view 对实际可空字段 `sample_size` 验证了 `NULL` 不被补默认值。
- Rollback/恢复风险低：本次是 additive view + field comments。若需回滚，可删除 `v_pls_audience_profile_snapshots` 及其 `database_field_comments` 记录；未修改底表、旧 view 或业务事实行。
- 工作树领取前已有未提交 `AGENTS.md` 修改，未触碰。

## Open Questions

- Controller decisions needed：无。
- Contract drift：无，实施保持 S127-S136 批准结构；未修改共享 consumption contract。
- 跨域影响：本任务只提供 AgentHarness DataBase 上游读取面。WorkPLS `Harness Portrait Consumption Contract/adapter 0.2.0` 仍需在本 handoff 获批后由 WorkPLS Controller 独立推进。

## Memory Used

- `docs/notes-database.md`：其中“schema 或链路变化后更新 `DataBase/docs/pls-consumption-guide.md`、`DataBase/console/app.js` 血缘及字段中文注释”的要求影响了本次实现范围，促成同步更新消费说明、血缘图和 `database_field_comments`。
