---
id: "T0004"
slug: "workpls-platform-profile-metric-source-decision"
status: "queued"
assignee: "opencode"
domain: "database"
controller: "codex"
base_ref: "24af68929f6186d574cf0dd2e340ce35e031c3af"
batch: "workpls-platform-profile-metric-source-decision"
sequence: "1"
depends_on: 
  - "T0003"
domain_memory: "agentops/memory/opencode-algorithm.md"
allowed_paths: 
  - "DataBase/source_files/**"
  - "DataBase/importers/**"
  - "DataBase/seeds/**"
  - "DataBase/validations/**"
  - "DataBase/docs/**"
  - "DataBase/console/app.js"
  - "docs/notes-database.md"
validation: 
  - "sqlite3 DataBase/agentharness.sqlite \"select count(*) from platform_profile_tag_metrics;\""
  - "sqlite3 DataBase/agentharness.sqlite \"select count(*) from v_workpls_dimension_evidence;\""
---

# T0004 WorkPLS Platform Profile Metric Source Decision

## Objective

接续 AgentHarness `T0003-workpls-preview-data-readiness-evidence` 的 approved blocked 结论，确认真实 `platform_profile_tag_metrics` 标准 metric 长表来源、导入责任、preview workspace 和可能的 `Structural Confirmation Gate`。

本任务必须输出 AgentHarness Controller 可 review 的明确结论：

- `ready`: 已有授权真实 metric source，可形成 non-zero `v_workpls_dimension_evidence` 和合法 WorkPLS preview comparison path。
- `needs_structural_confirmation`: 需要新增或实质调整 preview workspace、durable source、seed/import shape、identity、view、field、contract 或 workspace policy，必须先交回 AgentHarness Controller 执行结构确认。
- `blocked`: 当前缺少授权数据源、字段映射、业务审批、来源版本、时间窗口、workspace/object/profile binding 或其他必要证据。

## Required Reading

- `AGENTS.md`
- `CONTEXT.md`
- `Orchestration.md`
- `docs/notes-database.md`
- `DataBase/docs/pls-consumption-guide.md`
- `DataBase/docs/view-030-workpls-dimension-evidence.md`
- `DataBase/importers/platform_profile_tag_metrics_importer.mjs`
- `DataBase/migrations/024_create_platform_profile_tag_metrics.sql`
- `.agentops/tasks/T0003-workpls-preview-data-readiness-evidence/handoff.md`
- `.agentops/tasks/T0003-workpls-preview-data-readiness-evidence/review.md`
- WorkPLS prompt for context only: `/Users/huangbo/Dev/Projects/workpls/docs/cross-project/agentharness-platform-profile-metric-source-decision-prompt.md`

## Authoritative Evidence

- AgentHarness `T0003` was approved as blocked diagnosis.
- `v_workpls_dimension_evidence` schema/read-surface validation passed, but real row count is `0`.
- `platform_profile_tag_metrics` real row count is `0`.
- `ws_demo` only has mock snapshots and no legal same-type object pair or same-object cross-period path.
- Existing candidate CSV `DataBase/source_files/platform_profile_extracts/douyin/v0.1/101326115008_实际可提取画像标签_20260714.csv` is not a formal metric long table because it lacks required `metric_value`, `metric_unit`, workspace/object/profile/source batch fields; it must not be imported as formal evidence.
- DataBase owns AgentHarness facts, table/view, importer, validation, database docs and lineage.

## Allowed Paths

You may modify only:

- `DataBase/source_files/**`
- `DataBase/importers/**`
- `DataBase/seeds/**`
- `DataBase/validations/**`
- `DataBase/docs/**`
- `DataBase/console/app.js`
- `docs/notes-database.md`

Do not modify WorkPLS files, `OntoBase/**`, `KnowledgeBase/**`, `MemoryBase/**`, `Console/**`, shared contracts, ADRs, generated artifacts, or any path outside this list. If a contract or durable structure change is needed, stop and return `needs_structural_confirmation` or a contract change request instead of expanding scope.

## Non-Goals

- Do not modify `/Users/huangbo/Dev/Projects/workpls/**`.
- Do not create WorkPLS `comparison_runs`.
- Do not open WorkPLS production formal `Comparison Run` creation gate.
- Do not use mock snapshots, zero-filled metrics, default `metric_unit`, default quality status, artificial indicators, or UI bypasses to create readiness.
- Do not import the current non-standard CSV as formal evidence.
- Do not change `v_workpls_dimension_evidence` field shape or fail-closed semantics unless AgentHarness Controller explicitly approves a contract change.

## Constraints and Execution Order

1. Read all required context and confirm `database/opencode` ownership is still valid.
2. Inspect whether an authorized real `platform_profile_tag_metrics` standard long-table source exists.
3. If a usable source exists within approved paths, validate required columns, numeric values, units, source batch, provenance, workspace/object/profile binding and time window before any import.
4. If importing or seeding is in scope without structural drift, preserve source, batch, workspace, object, snapshot, time window and provenance.
5. If any new durable source shape, preview workspace, import contract, schema, view, identity or workspace policy is required, stop before implementation and return `needs_structural_confirmation`.
6. If no authorized source exists, return `blocked` with the exact missing evidence and required owner/decision.

## Contract Gate

This task does not by itself release WorkPLS. WorkPLS can only resume downstream UI Step 3 / persisted Run detail / quality policy / formal creation work after AgentHarness Controller approves a target handoff that includes:

- metric source/artifact/version/path and source batch evidence.
- target workspace.
- object IDs and snapshot IDs.
- data_version and time_window.
- non-zero `platform_profile_tag_metrics` row count.
- non-zero `v_workpls_dimension_evidence` row count.
- at least one legal same-type object pair or same-object cross-period comparison path.

Unapproved output, blocked handoff, and queued target tasks are not consumable WorkPLS contract evidence.

## Validation

Run and report at minimum:

- `sqlite3 DataBase/agentharness.sqlite "select count(*) from platform_profile_tag_metrics;"`
- `sqlite3 DataBase/agentharness.sqlite "select count(*) from v_workpls_dimension_evidence;"`
- If a candidate source is used: validate required columns, finite `metric_value`, non-empty `metric_unit`, workspace/object/profile binding, time window, source batch and provenance.
- If data is imported or seeded: report row count by workspace/object/snapshot/metric/unit from `v_workpls_dimension_evidence`.
- Validate and report at least one legal comparison path, or explicitly report why none exists.
- Run relevant importer/docs/lineage validation if any importer, seed, validation, docs, or console lineage file is modified.

Report any skipped validation and reason. Do not claim readiness without validation evidence or an explicit AgentHarness Controller waiver.

## Handoff Format

Your handoff must include:

- What Changed
- Files Changed
- Data Source Decision: `ready` / `needs_structural_confirmation` / `blocked`
- Validation
- Contract Drift / Change Requests
- Cross-project Impact
- Approved Consumption Evidence, if any
- Risks
- Open Questions
- Controller Decisions Needed

## 专业记忆

- domain_memory: `agentops/memory/opencode-algorithm.md`
- canonical_source: `/Users/huangbo/Dev/AgentOps/coding-system/agentops/memory/opencode-algorithm.md`
- Worker 必须先读取对应 CLI 配置目录下的这份 domain memory，再开始实现。若文件缺失，在 `handoff.md` 的 Risks 或 Open Questions 中说明。

## 执行顺序与依赖

- 批次：workpls-platform-profile-metric-source-decision
- 顺序：1
- 依赖：T0003
- 只有依赖任务全部 approved 后才可领取。
