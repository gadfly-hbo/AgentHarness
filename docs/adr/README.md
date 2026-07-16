# Architecture Decision Records

## 目的

ADR 记录会长期影响 AgentHarness 域边界、联合契约、身份、存储、生命周期、Console seam 或 agent 路由的决策。

## 何时创建

- 四库一台职责发生变化。
- 共享身份或跨域 contract 发生不兼容变化。
- 新增长期存储、协议、服务或治理机制。
- 固定 CLI owner 或总控权限发生变化。
- 某项重要取舍无法仅靠 contract 描述。

## 命名

```text
NNNN-short-kebab-title.md
```

状态使用 `proposed`、`accepted`、`superseded` 或 `rejected`。Codex 是 ADR 状态和索引的 owner。

## 最低内容

- Context
- Decision
- Alternatives
- Consequences
- Affected Domains
- Migration / Compatibility
- Validation
- Status

域 agent 可以在 handoff 中建议 ADR，但不能自行把 ADR 标记为 `accepted`。
