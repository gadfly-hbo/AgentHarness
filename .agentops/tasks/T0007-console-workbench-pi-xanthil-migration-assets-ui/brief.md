---
id: "T0007"
slug: "console-workbench-pi-xanthil-migration-assets-ui"
status: "queued"
assignee: "kilo"
domain: "console-ui"
controller: "codex"
base_ref: "ede3ec4919c2a54b14e11e2553a74dacd5a7bf8e"
batch: "agentharness-console-capability-workbench"
sequence: "3"
depends_on:
  - "T0006"
domain_memory: "agentops/memory/kilo-frontend.md"
allowed_paths:
  - "Console/workbench-prototype/**"
validation:
  - "Visual smoke: serve Console/workbench-prototype/index.html locally, capture desktop and mobile screenshots, verify pi-xanthil migration/retention assets are visible and no layout overlap at desktop and narrow widths."
---

## Objective

补齐 `Console/workbench-prototype` 中 `AgentHarness Console - Capability Workbench` 的 pi-xanthil 资产迁移视图，让业务负责人能在前端直接看到：

- 哪些 pi-xanthil 现有能力适合迁移到 AgentHarness。
- 哪些能力应继续保留在 pi-xanthil 产品侧。
- 迁移后 AgentHarness 与 pi-xanthil 的分工：Harness 负责后台开发、治理、实验、注册、分发；pi-xanthil 负责上层产品应用、安装、使用和用户反馈。
- 更新后的页面在 desktop 与 narrow/mobile 宽度下可视觉验收，无明显重叠、遮挡或溢出。

本任务是前端原型补齐任务，不做后端、持久化结构、API 或 contract 修改。

## Context

- AgentHarness 当前长期架构是“四库一台”：`DataBase`、`OntoBase`、`MemoryBase`、`KnowledgeBase`、`Console`，各自独立，通过显式联合契约协作。
- 当前开发者框架已更新：`console-ui` 域由 `kilo` 承接，允许修改路径为 `Console/workbench-prototype/**`；`antigravity` 已被 AgentHarness 禁用，不能再作为开发 assignee。
- `T0005` 已完成 Console Workbench 前端原型，`T0006` 已完成 Qwen 视觉验证。
- `T0006` 的主要 follow-up 结论：当前原型缺少 “pi-xanthil 可迁移资产 / 保留资产” 的明确展示；现有截图已因 Codex 后续文案收口而可能过期，需要重新生成。

建议呈现内容：

- 迁移到 AgentHarness 的候选资产：
  - `harness-packs/` → AgentHarness Packages / Capability Packs。
  - `server/tools/registry.ts` 与相关 tools → Console Tool Registry / Tool Lifecycle。
  - tool / skill 的实验对比、治理、审计、策略 → AgentHarness Console 后台能力治理。
  - `onto-prompts`、`onto-validator`、`onto-export`、`onto-extract` → OntoBase。
  - `knowledge-retrieval.ts` 等知识检索能力 → KnowledgeBase。
  - memory 维护、老化、去重、沉淀逻辑 → MemoryBase。
  - `agentharness-port.ts` 的 canonical contract 应逐步由 AgentHarness 侧权威维护，pi-xanthil 保留 adapter/client。
- 保留在 pi-xanthil 的产品侧能力：
  - 面向最终用户的产品 UI。
  - workspace、session、业务流程、安装和使用入口。
  - skill 生成、tool 使用和前端反馈闭环。
  - 与 pi-xanthil 产品体验强绑定的交互、配置和运行时编排。

注意：以上是前端原型文案和信息架构表达，不要求创建真实迁移逻辑或后端接口。

## Non-goals

- Do not broaden scope beyond allowed_paths.
- Do not commit, push, install dependencies, or run destructive cleanup.
- 不修改 `AGENTS.md`、`Orchestration.md`、`CONTEXT.md`、`docs/**`、`DataBase/**`、`OntoBase/**`、`KnowledgeBase/**`、`MemoryBase/**`、`Console/commands/**`。
- 不新增后端服务、API、数据库、schema、migration、contract、adapter 或运行时分发逻辑。
- 不把 mock/prototype 文案伪装成真实迁移状态、真实数据、真实 ID 或已完成能力。
- 不引入新的包管理依赖；保持当前静态 HTML/CSS/JS 原型可直接打开或通过临时静态服务查看。

## Required Changes

- 在现有 Workbench UI 中新增或整合一个清晰区域，展示 “pi-xanthil 资产迁移候选 / pi-xanthil 保留能力”。
- UI 必须明确区分：
  - `Migrate to AgentHarness`
  - `Remain in pi-xanthil`
  - `Contract / adapter boundary`
- 页面文案应使用简体中文为主，技术名词保留英文。
- 页面必须能表达 Harness 与 pi-xanthil 的产品分工，不把 Console 简化为 pi-xanthil 的内部页面。
- 保持现有视觉风格，不做大范围 redesign。
- 更新或重新生成当前原型截图，至少包含：
  - desktop 截图。
  - narrow/mobile 截图。

## Constraints

- 严格遵守 AgentHarness `AGENTS.md` 中的 `console-ui` 域边界。
- 只允许修改 `Console/workbench-prototype/**`。
- 这是 UI 原型补齐任务，不触发 `agentharness-structure-grill`。如果实现过程中发现必须新增持久化结构、API、schema、contract 或跨库联合契约，立即停止并在 `handoff.md` 中上报 blocker，不得自行实现。
- mock/prototype 数据必须明确可识别为设计表达，不得声称来自真实扫描结果。
- 响应式布局必须防御性处理：
  - `max-width: 100%`
  - `box-sizing: border-box`
  - 长文本可换行
  - `flex` / `grid` 场景避免窄屏重叠
- 不允许删除已有原型核心区域，除非能说明该区域与本次任务直接冲突并提供替代表达。

## Validation Requirements

- 静态检查：
  - 确认修改文件全部位于 `Console/workbench-prototype/**`。
  - 确认页面中能搜索到 pi-xanthil 迁移与保留能力相关文案。
  - 确认没有新增 package 依赖。
- 视觉验证：
  - 启动或打开静态原型。
  - 截取 desktop 视图。
  - 截取 narrow/mobile 视图。
  - 检查新增迁移区域可见、可读，无明显遮挡、重叠、横向溢出。
- 回归检查：
  - 原有六个核心区域仍应存在或有等价替代表达：
    - Capability Overview
    - Experiment Pipeline
    - Evaluation Matrix
    - Distribution / Install Flow
    - Governance / Audit
    - Four Bases + Console Boundary

如因本地环境缺少浏览器或截图工具无法完成截图，必须在 `handoff.md` 中说明原因，并至少提供可复现的手动验证步骤和源码证据。

## Handoff Format

Write handoff.md with these sections:

- What Changed
- Files Changed
- Validation
- Risks
- Open Questions
- Evidence Map
- Screenshots

`Evidence Map` 必须逐条映射：

- pi-xanthil 迁移候选资产是否已展示。
- pi-xanthil 保留资产是否已展示。
- Harness / pi-xanthil 分工是否已展示。
- desktop 截图是否完成。
- narrow/mobile 截图是否完成。
- allowed paths 是否合规。

## Worker Delivery Governance

Read and follow `/Users/huangbo/Dev/AgentOps/coding-system/policies/WORKER_DELIVERY_GOVERNANCE.md`.

- 本任务按当前 brief 不触及 contract、persistence、API、read model、concurrency 或 audit；因此不要求完整 pre-coding constraint matrix。
- 但 worker 仍必须先列出简短约束清单：允许动作、禁止动作、回退触发条件。
- Map every brief bullet to at least one verifiable evidence item: positive test, negative test, command output, source path, or explicit waiver.
- Put grep-able evidence for every completed/covered claim in `handoff.md`.

## 专业记忆

- domain_memory: `agentops/memory/kilo-frontend.md`
- canonical_source: `/Users/huangbo/Dev/AgentOps/coding-system/agentops/memory/kilo-frontend.md`
- Worker 必须先读取对应 CLI 配置目录下的这份 domain memory，再开始实现。若文件缺失，在 `handoff.md` 的 Risks 或 Open Questions 中说明。

## 执行顺序与依赖

- 批次：agentharness-console-capability-workbench
- 顺序：3
- 依赖：T0006
- 只有依赖任务全部 approved 后才可领取。
