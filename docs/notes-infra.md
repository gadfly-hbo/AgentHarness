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

## 下一步

下一项真实跨域需求使用本 CDI 流程创建首批 Task Bus 任务，并以 handoff/review 验证规则可执行性。
