---
id: "T0009"
slug: "console-workbench-zh-primary-copy"
status: "queued"
assignee: "kilo"
domain: "console-ui"
controller: "codex"
base_ref: "87a7fa7babdf41f205064385db6f450f01be76ac"
batch: "agentharness-console-workbench-product-ui-redesign"
sequence: "2"
depends_on: 
  - "T0008"
domain_memory: "agentops/memory/kilo-frontend.md"
allowed_paths: 
  - "Console/workbench-prototype/**"
validation: 
  - "Visual/copy smoke: open Console/workbench-prototype/index.html, verify the UI copy is Simplified Chinese-first with English only as auxiliary technical terms, capture desktop and mobile screenshots, verify no layout overflow or title clipping after copy changes."
---

## Objective

将 `Console/workbench-prototype` 的界面文案从“全英文为主”调整为“简体中文为主、英文为辅”的产品前端。

用户反馈：当前页面虽然已经像 operational Console，但界面几乎全英文，不符合 AgentHarness 当前产品讨论、业务验收和中文用户阅读习惯。

完成后，用户打开页面时应首先读到简体中文界面，例如：

- `能力工作台`
- `管理能力就绪度与主机分发`
- `能力列表`
- `当前能力`
- `运行评估`
- `准备发布`
- `分发到 pi-xanthil`
- `打开审计`
- `四库依赖`
- `迁移边界`

英文仅作为辅助出现：

- 专有产品名：`AgentHarness`、`pi-xanthil`、`DataBase`、`OntoBase`、`KnowledgeBase`、`MemoryBase`、`Console`。
- 技术对象名：`Capability`、`Package`、`Host`、`Audit`、`Release`、`Registry`、`adapter/client`。
- 必要时使用括号或短标签辅助，例如 `能力（Capability）`，但不能让英文成为主阅读语言。

本任务是 UI copy / localization 任务，不改变产品功能、后端、schema、contract 或真实数据。

## Context

- T0008 已 approved，页面已从说明书式页面重构为 operational Console 工作台。
- 当前剩余问题是语言风格：页面几乎全英文，中文用户打开后仍不像面向当前产品负责人的前端。
- AgentHarness 项目规则要求：面向非技术用户的说明、文档、前端展示文案、字段业务解释和工作汇报，应尽量使用简体中文。
- 本任务必须保留 T0008 的 operational UI 结构，不能退回说明书形态。

## Non-goals

- Do not broaden scope beyond allowed_paths.
- Do not commit, push, install dependencies, or run destructive cleanup.
- 不修改 `AGENTS.md`、`Orchestration.md`、`CONTEXT.md`、`docs/**`、`DataBase/**`、`OntoBase/**`、`KnowledgeBase/**`、`MemoryBase/**`、`Console/commands/**`。
- 不新增后端、API、schema、migration、contract、真实 registry、真实 package manifest、真实 license state machine 或真实 pi-xanthil integration。
- 不引入新依赖，不新增构建系统。
- 不做大规模 layout redesign；只允许为中文文案可读性做必要的行高、宽度、换行、badge、按钮和卡片微调。
- 不把中文文案变成长篇说明书；仍要保持 operational Console 工作台形态。
- 不删除 `start.command`，必须保持一键启动可用。

## Required Changes

- 将用户可见文案改为简体中文优先，至少覆盖：
  - sidebar navigation。
  - topbar title / subtitle / environment。
  - filters / search / select labels。
  - capability table headers、状态、host 状态。
  - selected capability detail。
  - status cards。
  - action buttons 与 disabled reason。
  - action feedback。
  - lifecycle checklist。
  - migration boundary。
  - four-base dependency inspector。
  - audit trail。
- 保留英文专有名词，但降低英文阅读占比。
- 中文状态表达要产品化，不要直译腔：
  - `Ready to evaluate` 建议改为 `可评估` 或 `待评估`。
  - `No backend connected` 建议改为 `未连接后端`。
  - `Blocked until ...` 建议改为 `需先完成...`。
  - `Prototype demo data` 建议改为 `原型演示数据`。
- 保留 prototype/demo 边界表达，避免用户误以为是真实数据或真实分发：
  - `静态原型`
  - `演示数据`
  - `不会调用真实后端`
  - `未连接真实 Host adapter`
- 更新 `desktop-screenshot.png` 和 `mobile-screenshot.png`。
- 如中文变长导致布局风险，必须修复响应式换行，尤其是：
  - sidebar navigation。
  - topbar title。
  - action buttons。
  - table/list rows。
  - badges。
  - mobile 390px viewport。

## Copy Rules

- 简体中文是主语言。
- 英文仅保留为：
  - 产品名。
  - 模块名。
  - 技术术语。
  - 括号辅助。
- 不使用机器翻译腔；优先使用中文产品界面常见表达。
- 不把所有英文强行翻译：
  - `AgentHarness` 不翻译。
  - `pi-xanthil` 不翻译。
  - `DataBase/OntoBase/KnowledgeBase/MemoryBase` 保留。
  - `Capability Pack` 可写为 `能力包（Capability Pack）`。
- 页面中英文比例应明显偏中文。worker handoff 需要说明仍保留的英文类别。

## Validation Requirements

- 静态文案检查：
  - grep 页面源码，确认核心中文词存在：`能力工作台`、`能力列表`、`当前能力`、`运行评估`、`准备发布`、`分发到 pi-xanthil`、`打开审计`、`四库依赖`、`迁移边界`、`未连接后端`。
  - grep 页面源码，确认没有明显全英文主标题遗留，例如 `Manage capability readiness` 作为唯一主标题、`Selected workspace`、`Four-base dependencies`、`Ready for prototype action` 等。
- 视觉验证：
  - 打开 `Console/workbench-prototype/index.html`。
  - 生成 desktop 截图。
  - 生成 mobile/narrow 截图。
  - 确认中文文案没有导致重叠、裁切、非预期横向溢出。
- 交互验证：
  - 点击 `运行评估`，看到中文 pending/success 反馈。
  - 点击 `准备发布`，看到中文成功反馈并启用分发。
  - 点击 `分发到 pi-xanthil`，看到中文 blocked 反馈。
  - 点击 `打开审计` 或审计详情，看到中文审计内容。
- 技术检查：
  - `git diff --check -- Console/workbench-prototype/index.html Console/workbench-prototype/css/styles.css Console/workbench-prototype/js/app.js Console/workbench-prototype/start.command`
  - `zsh -n Console/workbench-prototype/start.command`

## Handoff Format

Write handoff.md with these sections:

- What Changed
- Files Changed
- Validation
- Risks
- Open Questions
- Copy Policy Applied
- Evidence Map
- Screenshots

`Evidence Map` 必须逐条映射：

- 是否已改为简体中文主语言。
- 英文保留范围是否合理。
- T0008 operational UI 是否保留。
- 核心按钮和反馈是否中文化。
- desktop 截图是否完成。
- mobile 截图是否完成且无裁切。
- `start.command` 是否仍可用。
- allowed paths 是否合规。

## Worker Delivery Governance

Read and follow `/Users/huangbo/Dev/AgentOps/coding-system/policies/WORKER_DELIVERY_GOVERNANCE.md`.

- 本任务按当前 brief 不触及 contract、persistence、API、read model、concurrency 或 audit；因此不要求完整 pre-coding constraint matrix。
- 但 worker 必须先列出简短约束清单：允许动作、禁止动作、回退触发条件。
- Map every brief bullet to at least one verifiable evidence item: positive test, negative test, command output, source path, or explicit waiver.
- Put grep-able evidence for every completed/covered claim in `handoff.md`.

## 专业记忆

- domain_memory: `agentops/memory/kilo-frontend.md`
- canonical_source: `/Users/huangbo/Dev/AgentOps/coding-system/agentops/memory/kilo-frontend.md`
- Worker 必须先读取对应 CLI 配置目录下的这份 domain memory，再开始实现。若文件缺失，在 `handoff.md` 的 Risks 或 Open Questions 中说明。

## 执行顺序与依赖

- 批次：agentharness-console-workbench-product-ui-redesign
- 顺序：2
- 依赖：T0008
- 只有依赖任务全部 approved 后才可领取。
