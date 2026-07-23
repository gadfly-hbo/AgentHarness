---
id: "T0010"
slug: "console-workbench-pi-xanthil-experience-alignment"
status: "queued"
assignee: "kilo"
domain: "console-ui"
controller: "codex"
base_ref: "87a7fa7babdf41f205064385db6f450f01be76ac"
batch: "agentharness-console-workbench-product-ui-redesign"
sequence: "3"
depends_on: 
  - "T0009"
domain_memory: "agentops/memory/kilo-frontend.md"
allowed_paths: 
  - "Console/workbench-prototype/**"
validation: 
  - "Visual/product smoke: open Console/workbench-prototype/index.html, verify it feels like a pi-xanthil ecosystem backend capability console while preserving AgentHarness authority positioning; capture desktop and mobile screenshots; verify Chinese-first copy remains, operational workflow remains, and no layout clipping/overflow."
---

## Objective

进一步迭代 `Console/workbench-prototype`，让 AgentHarness Console 看起来像 pi-xanthil 生态里的后台能力控制台，而不是一个与 pi-xanthil 体验割裂的新产品。

这不是照抄 pi-xanthil 的分析工单页面。AgentHarness 的定位仍然是后台能力中台 / capability authority；pi-xanthil 的定位仍然是前台产品 Host / 用户工作台 / 能力消费方。

本任务要做的是体验对齐：

- 保留 T0008/T0009 的 operational Console 与中文为主。
- 借鉴 pi-xanthil 的内部工具风格：紧凑、真实工作区、状态清晰、操作直接、少装饰。
- 强化 Host / authority 分工：AgentHarness 管理能力生产、治理、评估、发布、分发；pi-xanthil 安装、使用、反馈。
- 让页面打开后的第一感受是“pi-xanthil 产品生态里的后台能力控制台”，不是说明书页、营销页或孤立中台。

参考方案文档：`docs/task-briefs/console-workbench-pi-xanthil-experience-alignment.md`。该文档只读参考，worker 不得修改。

## Context

控制面已只读核对 pi-xanthil 相关工程：

- pi-xanthil 前端 `web/src/components/analysis-projects/AnalysisProjectsPane.tsx` 是真实用户分析工单工作台，包含项目列表、使用说明、能力面板、详情、闭环等产品入口。
- pi-xanthil 前端 `web/src/components/analysis-projects/CapabilitiesPanel.tsx` 是消费侧系统能力面板，展示分析引擎、上传限制、用户数据来源、AgentHarness 能力。
- pi-xanthil 后端 `server/src/analysis-projects/contracts/agentharness-port.ts` 定义 AgentHarness read-only adapter port：`describeCapability / checkSource / readSource`。
- pi-xanthil 后端 `server/src/analysis-projects/routes/handlers/capabilities.ts` 明确默认不伪造 AgentHarness 能力，真实 registry 为空时返回空。
- pi-xanthil 后端 `server/tools/registry.ts` 和 `server/tools/**/tool.json` 已经是产品内真实 tool registry / tool manifest 体系。

因此本轮 UI 不能把 AgentHarness 做成 pi-xanthil 的另一个分析页；它应该更像“后台能力治理页”，但视觉语言要与 pi-xanthil 生态连续。

## Non-goals

- Do not broaden scope beyond allowed_paths.
- Do not commit, push, install dependencies, or run destructive cleanup.
- 不修改 `docs/**`，包括参考方案文档。
- 不修改 `AGENTS.md`、`Orchestration.md`、`CONTEXT.md`。
- 不修改 `DataBase/**`、`OntoBase/**`、`KnowledgeBase/**`、`MemoryBase/**`、`Console/commands/**`。
- 不修改 pi-xanthil 仓库。
- 不新增后端、API、schema、migration、contract、真实 registry、真实 install/distribution 或真实 Host adapter。
- 不引入新依赖，不新增构建系统。
- 不把页面变回说明书，不新增大段解释文字。
- 不做纯视觉换皮；必须改善“生态连续感”和“后台能力控制台心智”。

## Required Changes

- 调整信息组织，使页面更接近 pi-xanthil 的真实产品工作区心智：
  - 当前工作区。
  - 当前能力包。
  - 状态 / 就绪度 / 阻塞原因。
  - 主要操作。
  - Host 消费状态。
  - 审计记录。
- 强化 pi-xanthil 作为 Host consumer 的呈现：
  - 展示 `pi-xanthil Host` 的安装 / 使用 / 反馈 / 升级或受阻状态。
  - 明确 AgentHarness 只负责能力后台治理，不负责 pi-xanthil 的用户分析流程。
- 强化 AgentHarness authority 呈现：
  - 能力包 lifecycle。
  - eval / release / distribution readiness。
  - tool / skill / package / registry / audit 信号。
- 保留并改善 T0009 中文化：
  - 简体中文仍为主语言。
  - 英文只保留产品名、模块名、技术术语。
- 视觉风格应更接近 pi-xanthil：
  - 内部工具型。
  - 紧凑。
  - 清晰分区。
  - 操作优先。
  - 避免营销化大卡片。
- 更新 `desktop-screenshot.png` 和 `mobile-screenshot.png`。
- 保持 `start.command` 可用。

## Design Guardrails

- AgentHarness 不是 pi-xanthil 的“用户分析工单页”；不要加入新建分析工单、上传资料、报告生成等 pi-xanthil 用户流。
- AgentHarness 是“能力后台治理页”；应围绕 capability lifecycle、registry、eval、release、distribution、audit。
- pi-xanthil 在本页面里只是 Host / consumer / install target。
- 当前页面仍是静态原型；所有真实状态必须标注为原型或演示。

## Validation Requirements

- 静态检查：
  - 确认变更只在 `Console/workbench-prototype/**` 与当前 Task Bus 目录。
  - 确认页面仍包含中文核心词：`能力工作台`、`当前能力`、`运行评估`、`准备发布`、`分发到 pi-xanthil`、`四库依赖`、`迁移边界`、`审计记录`。
  - 确认页面明确表达 `pi-xanthil` 是 Host / consumer，而不是 AgentHarness 的内部页。
- 视觉检查：
  - 生成 desktop 截图。
  - 生成 mobile/narrow 截图。
  - 检查无标题裁切、卡片重叠、非预期横向溢出。
  - 检查页面第一感受是“后台能力控制台”，不是说明书或营销页。
- 交互检查：
  - `运行评估` 有中文 pending/success 反馈。
  - `准备发布` 能在演示流程中启用并反馈。
  - `分发到 pi-xanthil` 能表达 Host 受阻或模拟状态。
  - 审计详情能展开。
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
- Experience Alignment Notes
- Evidence Map
- Screenshots

`Evidence Map` 必须逐条映射：

- 是否仍保持 AgentHarness capability authority 定位。
- 是否更接近 pi-xanthil 生态体验。
- 是否没有照抄 pi-xanthil 分析工单用户流。
- 是否保留中文为主。
- 是否保留 operational UI。
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
- 顺序：3
- 依赖：T0009
- 只有依赖任务全部 approved 后才可领取。
