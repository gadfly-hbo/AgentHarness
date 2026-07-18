# Controller and Governance Notes

## Owner

Codex。

## 当前决策

- 采用 CDI（Controller-Domain Isolation，总控域隔离工程法）。
- Codex 是唯一总控、共享 contract owner 和最终审批者。
- Task Bus 使用 `.agentops/tasks/`，任务必须显式指定 `domain` 与 `assignee`。
- AgentHarness 项目路由覆盖 AgentOps 通用路由。
- Console 的固定域 worker 为 Antigravity CLI；Codex 保留 contract、审批和集成权。

## 固定路由

- `database` → OpenCode
- `ontobase` → Kilo Code
- `knowledgebase` → Mimo Code
- `memorybase` → Kimi Code
- `console` → Antigravity CLI

## 当前风险

- 现有历史变更可能同时修改 DataBase 与 OntoBase，后续必须按 contract change 拆分。
- `.agentops/tasks/` 是否加入 `.gitignore` 尚未在本轮决定；Codex 不应静默修改。
- 各 CLI 新会话必须重新读取项目控制面文件。
- WorkPLS 正式画像对比的 AgentHarness 上游状态已分成两个 gate：`T0002` 已批准并释放
  `v_workpls_dimension_evidence` schema/read-surface；`T0003` 已复核批准为数据 readiness
  blocker，结论是当前真实 evidence 行数为 0、`platform_profile_tag_metrics` 为 0、`ws_demo`
  只有 mock snapshot 且没有合法对比路径，现有 CSV 也不满足正式 metric 长表字段要求。这不是
  WorkPLS formal Run gate release。

## 下一步

- WorkPLS 已通过自身 `T0023-controller-record-agentharness-data-readiness-blocker`
  记录 AgentHarness 数据 readiness blocker；AgentHarness 当前不需要再产出 WorkPLS 回执。
- 后续如要释放正式 Run gate，必须先解决真实平台画像 metric 长表数据来源、导入与 readiness 验证，
  不得使用 mock、旧 `dimension_score`、默认 unit/value 或不合规 CSV 绕过。
