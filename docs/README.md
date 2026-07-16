# AgentHarness Documentation Index

## 目的

本文是 AgentHarness 架构、契约、域状态和多 agent handoff 的统一入口。

## 首次阅读顺序

1. `AGENTS.md`：项目强制规则、角色路由和结构确认门槛。
2. `CONTEXT.md`：全局术语、域边界、跨域接口和不变量。
3. `Orchestration.md`：Codex 总控与域 agent 的任务生命周期。
4. `docs/four-bases-one-console-contract.md`：四库一台顶层契约。
5. 当前域的 `docs/notes-<domain>.md`。
6. 当前任务 brief、相关 contract 和 ADR。

## 核心架构

- `docs/architecture.md`：AgentHarness 总体架构。
- `docs/domain-model.md`：全局领域模型。
- `docs/four-bases-one-console-contract.md`：四库一台独立性与联合契约。
- `docs/roadmap.md`：阶段路线。

## CDI 控制面

- `CONTEXT.md`：Codex 维护的全局上下文。
- `Orchestration.md`：Task Bus、handoff、review 和集成规则。
- `docs/adr/README.md`：架构决策索引与规则。
- `docs/contracts/README.md`：跨域契约索引与规则。
- `docs/notes-infra.md`：controller 与治理状态。
- `docs/notes-database.md`：DataBase 域状态。
- `docs/notes-ontobase.md`：OntoBase 域状态。
- `docs/notes-knowledgebase.md`：KnowledgeBase 域状态。
- `docs/notes-memorybase.md`：MemoryBase 域状态。
- `docs/notes-console.md`：Console 域状态。

## Handoff 模板

- `docs/templates/DOMAIN_HANDOFF.template.md`
- `docs/templates/HANDOFF_BACK.template.md`
- `docs/templates/CONTRACT_CHANGE_REQUEST.template.md`
- `docs/templates/REVIEW_CHECKLIST.template.md`

## 维护规则

- Codex 维护共享索引、contract、ADR 和 controller notes。
- 域 agent 只在 brief 授权时更新本域 notes。
- 跨域 contract 先写后实现。
- 文档与实现冲突时，停止并由 Codex 判断哪个来源需要修正。
