# T0003 Handoff: WorkPLS Preview Data Readiness Evidence

## What Changed

- 完成只读数据就绪诊断；未修改 `DataBase/**` schema、migration、seed、importer、validation、docs 或 SQLite 数据。
- 读取并核对了 brief 要求的项目规则、DataBase notes、结构账本、view/migration/validation 文件和 WorkPLS cross-project prompt。
- 预检现有真实 CSV：`DataBase/source_files/platform_profile_extracts/douyin/v0.1/101326115008_实际可提取画像标签_20260714.csv` 不是 `platform_profile_tag_metrics` 标准长表，缺少 workspace/object/profile、metric value、unit、source batch 等必填字段，因此不能作为正式 Dimension Evidence 来源导入。
- 结论为 `blocked`，不提供 WorkPLS 可消费预览证据。

## Files Changed

- `.agentops/tasks/T0003-workpls-preview-data-readiness-evidence/handoff.md`
- 未修改任务 allowed scope 内的产品文件。

## Data Readiness Result

- Result: `blocked`。
- 当前可见 workspace：`ws_demo`。
- `ws_demo` 中有 snapshot 的对象：
  - `account:mock_account_douyin_style`，snapshot `audience_account_mock_001`，`data_version=v_channel_object_library_mock_20260706`，`time_window=2026-06-01/2026-06-30`，`sample_size=1000`，`quality_flags_json=["mock_sample"]`。
  - `store:mock_store_city_walk_001`，snapshot `audience_store_mock_001`，`data_version=v_channel_object_library_mock_20260706`，`time_window=2026-06-01/2026-06-30`，`sample_size=450`，`quality_flags_json=["mock_sample"]`。
  - `trade_area:mock_trade_area_city_walk`，snapshot `audience_trade_area_mock_001`，`data_version=v_channel_object_library_mock_20260706`，`time_window=2026-06-01/2026-06-30`，`sample_size=600`，`quality_flags_json=["mock_sample"]`。
- 合法同类横向对象对：未找到。每个有 snapshot 的 object type 当前各只有 1 个对象。
- 同对象跨周期对象路径：未找到。`v_pls_audience_profile_snapshots` 中没有任何 `workspace_id + canonical_object_key` 具有多个 `data_version`。
- 真实 unit-bearing 指标链路：未就绪。
  - `platform_profile_tag_metrics`: 0 行。
  - `v_platform_profile_tag_metric_semantics`: 0 行。
  - `v_platform_profile_channel_dimension_features`: 0 行。
  - `v_workpls_dimension_evidence`: 0 行。
- 现有 `v_workpls_dimension_evidence` view 的 schema/read-surface 和 fail-closed validation 通过，但真实数据覆盖未通过。

## Consumable Evidence For WorkPLS

- 无可释放给 WorkPLS 的消费证据。
- 不建议 WorkPLS 使用 `ws_demo` 释放 Step 3 readiness、persisted Run detail 或 quality policy release gate，因为：
  - 该 workspace 只有 mock snapshot，`quality_flags_json` 为 `mock_sample`。
  - 不存在合法同类对象对或同对象跨周期路径。
  - 与 snapshot 对齐的 `v_workpls_dimension_evidence` 行数为 0。
- 当前可交付的 artifact 仅限诊断证据：AgentHarness `v_workpls_dimension_evidence` 读取面可用且 validation 通过；真实覆盖仍缺失。

## Validation

- `sqlite3 DataBase/agentharness.sqlite ".schema v_workpls_dimension_evidence"`: pass，view 存在，字段与 fail-closed SQL 可读取。
- `sqlite3 DataBase/agentharness.sqlite "select count(*) from v_workpls_dimension_evidence;"`: `0`。
- `sqlite3 DataBase/agentharness.sqlite "select workspace_id, snapshot_id, canonical_object_key, data_version, metric_name, unit, count(*) as row_count from v_workpls_dimension_evidence group by 1,2,3,4,5,6 order by row_count desc limit 20;"`: no rows。
- `sqlite3 DataBase/agentharness.sqlite < DataBase/validations/030_validate_v_workpls_dimension_evidence.sql`: pass。所有检查返回 `pass`，包括 column order、business key、snapshot binding、finite value、required text、JSON arrays、field comments、validation fixture 可见、workspace filtering、multi-snapshot fail-closed、old score source not used、forbidden payload absent、rollback。
- 数据覆盖计数查询：
  - `platform_profile_tag_metrics=0`。
  - `v_platform_profile_tag_metric_semantics=0`。
  - `v_platform_profile_channel_dimension_features=0`。
  - `v_pls_audience_profile_snapshots=3`。
  - `v_workpls_dimension_evidence=0`。
  - `pls_channel_objects=6`。
- 对象/snapshot 分布查询：`ws_demo` 中 `account/store/trade_area` 各 1 个对象带 snapshot；`platform/marketing_event/business_scenario` 没有 snapshot。
- 跨周期查询：没有任何对象拥有多个 snapshot `data_version`。
- CSV 导入预检：`node DataBase/importers/import_platform_profile_tag_metrics.mjs DataBase/source_files/platform_profile_extracts/douyin/v0.1/101326115008_实际可提取画像标签_20260714.csv` 返回 `applied=false`、`validRows=0`、`errorCount=1`；错误为缺少 `workspace_id, profile_id, canonical_object_key, channel_object_type, channel_object_name, platform, tag_type, leaf_label, metric_name, metric_value, metric_unit, profile_time_window, source_file, source_row, source_batch_id`。
- 未运行 WorkPLS 仓库验证；本任务禁止修改或验证 WorkPLS 下游 release gate。

## Contract Drift / Change Requests

- 无 `CONTRACT_CHANGE_REQUEST`。
- 未发现 `v_workpls_dimension_evidence` 字段面或 fail-closed 语义需要改变。
- 阻塞原因是数据覆盖与可比对象路径缺失，不是现有 view contract drift。

## Cross-project Impact

- WorkPLS UI Step 3 readiness / persisted Run detail / quality policy release gate 必须继续 blocked。
- WorkPLS 不应把本 handoff 当作可消费 preview evidence；必须等待 AgentHarness Controller 后续批准真实数据导入或可比 preview dataset，并返回非 0 `v_workpls_dimension_evidence` 证据。
- 若后续要释放 gate，AgentHarness 需要先获得或生成可追溯的真实 `platform_profile_tag_metrics` 标准长表数据，并确保它能绑定到 workspace-scoped channel object 与 `v_pls_audience_profile_snapshots`。

## Risks

- `docs/contracts/workpls-dimension-evidence-structure-ledger.md` 历史状态仍写着“等待用户整体批准”，但当前仓库已存在 migration/view/validation。此处没有修改 shared contract，建议 Controller 复核是否需要单独治理该状态记录。
- `ws_demo` 当前数据带 `mock_sample` 标记，即便将来补齐 evidence 行，也可能仍不满足 WorkPLS “不 mock”预览 gate，除非 Controller 明确批准这是 internal preview fixture 而非正式数据。
- 如果要新增真实 preview workspace、真实对象/snapshot seed 或调整导入结构，可能触发 AgentHarness `Structural Confirmation Gate`，需要 Controller 另行确认。

## Open Questions

- AgentHarness Controller 是否已有可授权的真实平台画像 metric 长表来源，包含 `metric_value`、`metric_unit`、workspace、profile、object、time window 和 source batch？
- WorkPLS 内部预览应消费 `ws_demo`、`ws_pls_real_001`，还是一个新的 non-production preview workspace？当前证据不足以建议可消费 workspace。
- 如果只能使用现有 `101326115008_实际可提取画像标签_20260714.csv`，谁负责把它转换为带真实指标值和单位的 `platform_profile_tag_metrics` 标准长表，并确认这些值的来源合法性？

## Memory Used / Memory Candidates

- Memory Used: none。已读取 `/Users/huangbo/Dev/AgentOps/coding-system/agentops/memory/opencode-algorithm.md`，但其中 checksum/algorithm 经验未影响本次数据库就绪诊断或实现决策。
- Memory Candidates: none。
