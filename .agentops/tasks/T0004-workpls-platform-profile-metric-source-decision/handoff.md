# T0004 Handoff: WorkPLS Platform Profile Metric Source Decision

## What Changed

- 完成只读真实 metric source 可用性判断；未导入数据，未修改 `DataBase/**` schema、migration、view、importer、seed、validation、docs 或 SQLite 数据。
- 复核 `database/opencode` ownership：`AGENTS.md`、`CONTEXT.md`、`Orchestration.md` 和 `docs/notes-database.md` 均确认 DataBase 负责事实数据、table/view、importer、validation、数据库文档和血缘，本任务路由有效。
- 检查 `DataBase/source_files/**`，当前仅有一个平台画像候选 CSV：`DataBase/source_files/platform_profile_extracts/douyin/v0.1/101326115008_实际可提取画像标签_20260714.csv`。
- 该 CSV 及同目录 README 只保留 `标签类型` 和 `标签`；README 明确原始 `占比` 和 `tgi` 不进入留存文件，因此它不是授权的 `platform_profile_tag_metrics` 标准 metric 长表。
- 结论：`blocked`。当前没有可授权、可直接导入的真实标准 metric 长表来源，也没有合法 WorkPLS preview comparison path。

## Files Changed

- `.agentops/tasks/T0004-workpls-platform-profile-metric-source-decision/handoff.md`
- 未修改任务 allowed scope 内的产品文件。

## Data Source Decision

- Decision: `blocked`。
- 不是 `ready`：没有非 0 `platform_profile_tag_metrics`，没有非 0 `v_workpls_dimension_evidence`，没有合法同类对象对或同对象跨周期 comparison path。
- 不是 `needs_structural_confirmation`：本轮未发现已有授权来源但需要新增或调整持久化结构才能导入；当前首要阻塞是缺少授权真实 metric source 与可比 preview 数据证据。若 Controller 后续决定新增 preview workspace、durable source、seed/import shape、identity、view、field、contract 或 workspace policy，则应另行触发 `Structural Confirmation Gate`。

## Validation

- `sqlite3 DataBase/agentharness.sqlite "select 'platform_profile_tag_metrics', count(*) from platform_profile_tag_metrics union all select 'v_workpls_dimension_evidence', count(*) from v_workpls_dimension_evidence union all select 'v_platform_profile_tag_metric_semantics', count(*) from v_platform_profile_tag_metric_semantics union all select 'v_platform_profile_channel_dimension_features', count(*) from v_platform_profile_channel_dimension_features union all select 'v_pls_audience_profile_snapshots', count(*) from v_pls_audience_profile_snapshots;"`
  - `platform_profile_tag_metrics|0`
  - `v_workpls_dimension_evidence|0`
  - `v_platform_profile_tag_metric_semantics|0`
  - `v_platform_profile_channel_dimension_features|0`
  - `v_pls_audience_profile_snapshots|3`
- `sqlite3 DataBase/agentharness.sqlite "select workspace_id, canonical_object_key, profile_id, data_version, source_batch_id, time_window, sample_size, quality_flags_json from v_pls_audience_profile_snapshots order by workspace_id, canonical_object_key;"`
  - `ws_demo|account:mock_account_douyin_style|audience_account_mock_001|v_channel_object_library_mock_20260706|batch_channel_object_library_mock_20260706|2026-06-01/2026-06-30|1000|["mock_sample"]`
  - `ws_demo|store:mock_store_city_walk_001|audience_store_mock_001|v_channel_object_library_mock_20260706|batch_channel_object_library_mock_20260706|2026-06-01/2026-06-30|450|["mock_sample"]`
  - `ws_demo|trade_area:mock_trade_area_city_walk|audience_trade_area_mock_001|v_channel_object_library_mock_20260706|batch_channel_object_library_mock_20260706|2026-06-01/2026-06-30|600|["mock_sample"]`
- Legal comparison path validation:
  - same-type object pairs: `0`。
  - same-object cross-period paths: `0`。
- Candidate source validation:
  - `node DataBase/importers/import_platform_profile_tag_metrics.mjs "DataBase/source_files/platform_profile_extracts/douyin/v0.1/101326115008_实际可提取画像标签_20260714.csv"`
  - Result: `applied=false`、`validRows=0`、`errorCount=1`。
  - Error: `CSV 缺少必填字段：workspace_id, profile_id, canonical_object_key, channel_object_type, channel_object_name, platform, tag_type, leaf_label, metric_name, metric_value, metric_unit, profile_time_window, source_file, source_row, source_batch_id`。
- `sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/030_validate_v_workpls_dimension_evidence.sql"`: pass；所有检查返回 `pass`，包括 view 存在、字段顺序、business key、snapshot binding、finite value、required text、JSON arrays、field comments、validation fixture、workspace filtering、multi-snapshot fail-closed、old score source not used、forbidden payload absent、rollback。
- 未运行 importer/docs/lineage 变更验证，因为本任务未修改 importer、seed、validation、docs 或 console lineage。

## Contract Drift / Change Requests

- 无 `CONTRACT_CHANGE_REQUEST`。
- 未发现 `v_workpls_dimension_evidence` 字段面或 fail-closed 语义需要改变。
- 阻塞原因是授权真实 metric source 与可比 preview data 缺失，不是当前 DataBase contract/view drift。

## Cross-project Impact

- WorkPLS UI Step 3 readiness、persisted Run detail、quality policy release 和 production formal Run creation gate 必须继续 blocked。
- 本 handoff 不提供 WorkPLS 可消费 contract evidence；只有 AgentHarness Controller 批准后续 ready handoff，并给出非 0 evidence 与合法 comparison path，WorkPLS 才能创建下游消费验证任务。
- WorkPLS 不应使用 `ws_demo` 作为“不 mock” preview gate 证据；现有 snapshot 均带 `mock_sample`，且没有同类对象对或跨周期路径。

## Approved Consumption Evidence, if any

- 无。
- 当前无可批准给 WorkPLS 消费的 source/artifact/version/path/workspace/object/snapshot/evidence 组合。

## Risks

- `DataBase/source_files/platform_profile_extracts/douyin/v0.1/README.md` 指向的原始文件 `/Users/huangbo/Downloads/26Q2-73款/101326115008画像数据.csv` 不在仓库内，且不属于本任务授权 source artifact；即便本机可能存在，也不能作为 AgentHarness approved durable source 直接消费。
- 如果后续要基于原始下载文件恢复 `占比` 或 `tgi`，仍需确认来源授权、字段含义、metric_unit、workspace/object/profile binding、time_window、source_batch_id 和 provenance；可能触发结构确认或新的 DataBase 导入任务。
- 当前 `.agentops/tasks/T0003-workpls-preview-data-readiness-evidence/` 与 `.agentops/tasks/T0004-workpls-platform-profile-metric-source-decision/` 在 `git status` 中为未跟踪目录，`docs/notes-infra.md` 有既有修改；本任务未改动这些既有产品文件。

## Open Questions

- AgentHarness Controller 是否能取得并批准真实平台画像 metric 长表 source artifact，包含 `metric_value`、`metric_unit`、workspace、profile、object、time window、source batch 和 provenance？
- 若要释放 WorkPLS internal preview gate，目标 workspace 应使用既有 `ws_demo` 之外的新 non-production preview workspace，还是未来真实业务 workspace？该决策当前没有批准证据。
- 是否需要 Controller 另行发起 `Structural Confirmation Gate`，用于新增 preview workspace、真实对象/snapshot seed、durable source policy 或 import source contract？

## Controller Decisions Needed

- 决定是否向数据 owner 请求授权的标准 metric 长表 source artifact，或授权一个新的 DataBase 任务从原始平台导出文件生成标准长表。
- 决定 WorkPLS preview 是否需要新 workspace/object/snapshot fixture；若需要，先执行 AgentHarness `Structural Confirmation Gate`，再派发 DataBase 任务。
- 决定是否继续保持 WorkPLS 依赖任务 blocked，直到 AgentHarness 产生 approved ready handoff；当前证据建议继续 blocked。

## Memory Used / Memory Candidates

- Memory Used: none。已读取 `/Users/huangbo/Dev/AgentOps/coding-system/agentops/memory/opencode-algorithm.md`，但其中 algorithm checksum 经验未影响本次数据库 source decision 或验证选择。
- Memory Candidates: none。
