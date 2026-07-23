---
id: "T0008"
slug: "console-workbench-operational-ui-redesign"
status: "queued"
assignee: "kilo"
domain: "console-ui"
controller: "codex"
base_ref: "87a7fa7babdf41f205064385db6f450f01be76ac"
batch: "agentharness-console-workbench-product-ui-redesign"
sequence: "1"
depends_on: 
  - "T0007"
domain_memory: "agentops/memory/kilo-frontend.md"
allowed_paths: 
  - "Console/workbench-prototype/**"
validation: 
  - "Visual/product smoke: open Console/workbench-prototype/index.html via local static server, capture desktop and mobile screenshots, verify primary workflow is interactive and operational rather than explanatory, no console errors, no layout overlap or unintended horizontal overflow."
---

## Objective

将当前 `Console/workbench-prototype` 从“产品说明书式页面”重构为“可操作的 AgentHarness Console 工作台”。

当前 T0005-T0007 已经把四库一台、pi-xanthil 分工、迁移边界讲清楚，但页面更像产品架构说明书，不像真实前端产品。T0008 的目标不是换颜色，也不是继续补说明文字，而是让用户进入页面后能直接看到并操作一个 capability 管理流程。

完成后，用户应能在一个页面里完成以下前端模拟路径：

1. 从左侧或顶部导航进入 `Capabilities` 工作区。
2. 在 capability 列表中选择 `PLS Capability Pack`。
3. 在主工作区看到该 capability 的当前状态、依赖四库、实验状态、release 状态和 Host consumption 状态。
4. 在操作面板中看到可执行动作及其状态：
   - `Run Evaluation`
   - `Prepare Release`
   - `Distribute to pi-xanthil`
   - `Open Audit`
5. 操作按钮必须有清晰的 enabled / disabled / pending / blocked / success 表达，哪怕只是前端模拟状态。
6. 页面仍保留四库一台、pi-xanthil migration boundary 信息，但它们应服务于操作工作流，不再作为大段说明书主体。

本任务是前端原型重构任务，不做后端、持久化结构、API、schema、contract、真实迁移或真实安装分发。

## Product UI Direction

按 `product-ui-redesign` 规则，本次 UI 原则如下：

- 优先工作流，不优先概念说明：首屏必须让用户知道“我现在能管理什么、下一步能点什么”。
- 内部工具风格：dense、calm、scannable、utilitarian；避免 landing page / marketing page 风格。
- 信息层级必须产品化：当前对象、当前状态、主操作、阻塞原因、审计证据要一眼可扫。
- 保留商业化和中台语义，但通过 lifecycle、module dependency、release/distribution、host consumption 状态体现，不用长篇解释。
- 响应式必须可用：desktop 适合三栏工作台；narrow/mobile 改为单列或折叠式布局，不能重叠。

建议界面结构：

```text
AgentHarness Console
├── App shell
│   ├── Sidebar / primary nav
│   │   ├── Capabilities
│   │   ├── Tools / Skills
│   │   ├── Packages
│   │   ├── Experiments
│   │   ├── Releases
│   │   ├── Hosts
│   │   └── Audit
│   └── Topbar: environment, prototype status, quick action
│
├── Capability workspace
│   ├── Toolbar: search, module filter, lifecycle filter
│   ├── Capability list/table
│   └── Selected object: PLS Capability Pack
│
└── Inspector / action rail
    ├── Status summary
    ├── Four-base dependencies
    ├── Evaluation result
    ├── Release readiness
    ├── pi-xanthil distribution state
    └── Audit trail
```

可继续使用静态 prototype 数据，但必须显式标注为 prototype/demo，且不能伪装成真实 registry、真实迁移扫描或真实 contract。

## Current Evidence

- T0007 已 approved，当前页面已覆盖 `Migrate to AgentHarness` / `Remain in pi-xanthil` / `Contract / adapter boundary`。
- 用户最新反馈：当前页面“看上去不像前端，像个产品说明书”。
- 因此 T0008 的设计验收重点是 UI 是否像一个 operational product，而不是说明是否完整。
- 当前有一键启动脚本 `Console/workbench-prototype/start.command`，应保留并可继续用于打开原型。

## Non-goals

- Do not broaden scope beyond allowed_paths.
- Do not commit, push, install dependencies, or run destructive cleanup.
- 不修改 `AGENTS.md`、`Orchestration.md`、`CONTEXT.md`、`docs/**`、`DataBase/**`、`OntoBase/**`、`KnowledgeBase/**`、`MemoryBase/**`、`Console/commands/**`。
- 不新增后端服务、API、数据库、schema、migration、contract、adapter、真实 package manifest、真实 license state machine 或真实 pi-xanthil integration。
- 不新增外部依赖，不引入 bundler，不把静态原型升级成复杂前端工程。
- 不删除 `Console/workbench-prototype/start.command`；如需调整，只能让它继续保持“一键启动并打开页面”的用途。
- 不做纯视觉装饰改造：禁止只换色、加渐变、大 hero、大卡片堆叠，而不改善操作工作流。
- 不把所有 PRD 内容一次性塞进页面；说明性文字应被压缩为状态、标签、tooltip、audit note 或帮助区域。

## Required Changes

- 重构 `index.html` 的信息架构，使首屏像 Console 工作台：
  - 明确当前 workspace/page。
  - 明确当前 selected capability。
  - 明确主要操作路径。
- 将现有大段说明内容改造成操作型 UI：
  - capability list / table。
  - selected capability detail。
  - action rail / inspector。
  - lifecycle timeline 或 status checklist。
  - experiment/evaluation summary。
  - release/distribution readiness。
  - pi-xanthil host consumption state。
  - compact audit trail。
- 新增最小前端交互，不需要后端：
  - 选择 capability 后右侧详情变化；如果只保留一个重点 capability，也必须通过 UI 状态表达“已选中”。
  - 至少 2 个操作按钮有前端模拟反馈，例如 pending/success/blocked 文案或 disabled reason。
  - filter/search 控件可以是 prototype-only，但必须视觉上像真实工作台控件。
- 保留并压缩迁移边界信息：
  - `Migrate to AgentHarness`
  - `Remain in pi-xanthil`
  - `Contract / adapter boundary`
  这些内容不应占据页面主体，而应成为 selected capability 的 planning / boundary panel 或 audit/context 区。
- 更新 `desktop-screenshot.png` 和 `mobile-screenshot.png`。
- 保持 `start.command` 可用。

## UI Quality Rubric

worker 必须在 handoff 中按以下维度给出自检结论：

- Information Architecture：主工作流是否不用读长说明就可见。
- Visual Hierarchy：当前对象、状态、主操作是否突出。
- Layout And Spacing：desktop/mobile 是否对齐、无重叠、无非预期横向溢出。
- Component Consistency：按钮、状态、badge、table/list、inspector 是否一致。
- Operational Product Fit：是否像 SaaS/internal tooling，而不是产品说明书或 marketing page。
- Accessibility：按钮/输入/状态是否有可读 label；focus/contrast 是否没有明显问题。
- Responsive Behavior：narrow/mobile 是否有刻意布局，而不是压缩桌面布局。

## Handoff Format

Write handoff.md with these sections:

- What Changed
- Files Changed
- Validation
- Risks
- Open Questions
- Product UI Audit
- Design Principles Applied
- Evidence Map
- Screenshots

`Evidence Map` 必须逐条映射：

- 页面是否从说明书转为 operational console。
- 主工作流是否首屏可见。
- `PLS Capability Pack` 是否可作为 selected object 被管理。
- 至少 2 个操作按钮是否有 prototype feedback。
- migration boundary 是否保留但不喧宾夺主。
- desktop screenshot 是否完成。
- mobile/narrow screenshot 是否完成。
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
- 顺序：1
- 依赖：T0007
- 只有依赖任务全部 approved 后才可领取。
