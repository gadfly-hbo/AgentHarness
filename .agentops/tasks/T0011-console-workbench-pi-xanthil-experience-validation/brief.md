---
id: "T0011"
slug: "console-workbench-pi-xanthil-experience-validation"
status: "queued"
assignee: "qwen"
domain: "validation"
controller: "codex"
base_ref: "87a7fa7babdf41f205064385db6f450f01be76ac"
batch: "agentharness-console-workbench-product-ui-redesign"
sequence: "4"
depends_on: 
  - "T0010"
domain_memory: ""
allowed_paths: []
validation: 
  - "Independent validation: inspect T0010 handoff, source, desktop/mobile screenshots, and local page; verify AgentHarness Console reads as a pi-xanthil ecosystem backend capability console, not a product explanation page; verify Chinese-first copy, operational workflow, host/authority boundary, and responsive layout. No product implementation writes."
---

## Objective

在 T0010 完成并 handoff 后，作为独立验证 agent，对 `Console/workbench-prototype` 做产品体验与前端质量验收。

本验证重点不是重新设计页面，而是判断 T0010 是否真正达到控制面目标：

- AgentHarness Console 看起来像 pi-xanthil 生态里的后台能力控制台。
- AgentHarness 仍然是 capability authority / 后台治理面。
- pi-xanthil 仍然是 Host / consumer / 安装使用方。
- 页面不是说明书页、营销页，也不是照抄 pi-xanthil 的用户分析工单页。
- 中文为主、英文为辅，且操作流程仍然可用。

参考材料：

- T0010 brief 与 handoff。
- `docs/task-briefs/console-workbench-pi-xanthil-experience-alignment.md`，只读参考。
- `Console/workbench-prototype/index.html`
- `Console/workbench-prototype/css/styles.css`
- `Console/workbench-prototype/js/app.js`
- `Console/workbench-prototype/desktop-screenshot.png`
- `Console/workbench-prototype/mobile-screenshot.png`
- `Console/workbench-prototype/start.command`

如需对照 pi-xanthil，只读参考以下文件，不得修改 pi-xanthil 仓库：

- `/Users/huangbo/Dev/Projects/pi-xanthil/web/src/components/analysis-projects/AnalysisProjectsPane.tsx`
- `/Users/huangbo/Dev/Projects/pi-xanthil/web/src/components/analysis-projects/CapabilitiesPanel.tsx`
- `/Users/huangbo/Dev/Projects/pi-xanthil/server/src/analysis-projects/contracts/agentharness-port.ts`
- `/Users/huangbo/Dev/Projects/pi-xanthil/server/src/analysis-projects/routes/handlers/capabilities.ts`
- `/Users/huangbo/Dev/Projects/pi-xanthil/server/tools/registry.ts`

## Non-goals

- Do not broaden scope beyond allowed_paths.
- Do not commit, push, install dependencies, or run destructive cleanup.
- 不修改任何产品实现文件。
- 不修改 `docs/**`、`AGENTS.md`、`Orchestration.md`、`CONTEXT.md`。
- 不修改 `.agentops/tasks/T0010-*/**`。
- 不修改 pi-xanthil 仓库。
- 不新增后端、API、schema、contract、registry、adapter 或真实分发逻辑。
- 不把验证意见直接改进到页面；所有问题通过 `handoff.md` 报告给 controller。

## Validation Scope

### Source Review

- 检查 T0010 handoff 是否逐项回应 brief。
- 检查 T0010 变更是否只落在 `Console/workbench-prototype/**` 与自身任务目录。
- 检查页面核心文案是否仍为简体中文。
- 检查是否清楚表达：
  - AgentHarness 负责能力生产、治理、评估、发布、分发、审计。
  - pi-xanthil 是 Host / consumer / install target。
  - 四库依赖是能力治理上下文，不是页面里的后端实现承诺。

### Product Experience Review

从业务负责人视角判断：

- 页面第一屏是否像“后台能力控制台”，而不是产品说明书。
- 页面是否形成可操作工作区：当前能力、状态、动作、Host 状态、四库依赖、审计记录。
- 是否避免照抄 pi-xanthil 用户分析工单流：
  - 不应把“新建分析工单 / 上传资料 / 报告生成”作为主流程。
  - 不应把 AgentHarness 伪装成 pi-xanthil 的前台用户页。
- 与 pi-xanthil 生态是否有连续感：
  - 信息密度接近内部工具。
  - 分区清晰。
  - 操作优先。
  - 装饰不过度。

### Visual / Responsive Review

- 查看或重新生成 desktop 截图。
- 查看或重新生成 mobile/narrow 截图。
- 检查无标题裁切、卡片重叠、按钮挤压、非预期横向溢出。
- 检查长中文文本、模块标签、状态 pill 在窄屏下可读。

### Interaction Review

如环境允许，启动本地静态页并验证：

- `Console/workbench-prototype/start.command` 可用，或使用等效 `python3 -m http.server` 静态服务。
- `运行评估` 有中文 pending/success 反馈。
- `准备发布` 的启用条件和反馈合理。
- `分发到 pi-xanthil` 表达 Host 受阻或模拟状态。
- 审计详情可展开。

### Required Commands / Evidence

至少提供以下证据，若无法执行必须说明原因：

- `git status --short`
- `git diff --check -- Console/workbench-prototype/index.html Console/workbench-prototype/css/styles.css Console/workbench-prototype/js/app.js Console/workbench-prototype/start.command`
- `zsh -n Console/workbench-prototype/start.command`
- 一项源码 grep 证据，证明中文核心词或 Host/authority 边界存在。
- desktop/mobile 截图检查结论，最好引用截图文件路径和观察结果。

## Handoff Format

Write handoff.md with these sections:

- Findings
- Evidence
- Screenshots Reviewed
- Pass/Fail Matrix
- Risks
- Open Questions
- Recommendation

`Pass/Fail Matrix` 至少包含：

| Check | Result | Evidence |
| --- | --- | --- |
| AgentHarness authority positioning | PASS/FAIL | path / command / screenshot observation |
| pi-xanthil Host consumer boundary | PASS/FAIL | path / command / screenshot observation |
| Not copied from pi-xanthil analysis workflow | PASS/FAIL | path / screenshot observation |
| Chinese-first copy | PASS/FAIL | path / grep evidence |
| Operational Console, not explanation page | PASS/FAIL | screenshot observation |
| Desktop layout | PASS/FAIL | screenshot observation |
| Mobile layout | PASS/FAIL | screenshot observation |
| Interaction flow | PASS/FAIL | command / manual observation |
| allowed_paths respected | PASS/FAIL | git status / diff evidence |

`Recommendation` 必须明确给出：

- `approve`
- `changes_requested`
- `blocked`

并说明对应理由。

## Worker Delivery Governance

Read and follow `/Users/huangbo/Dev/AgentOps/coding-system/policies/WORKER_DELIVERY_GOVERNANCE.md`.

- If the task touches contract, persistence, API, read model, concurrency, or audit, write a constraint matrix before coding.
- Map every brief bullet to at least one verifiable evidence item: positive test, negative test, command output, source path, or explicit waiver.
- Put grep-able evidence for every completed/covered claim in `handoff.md`.

## 执行顺序与依赖

- 批次：agentharness-console-workbench-product-ui-redesign
- 顺序：4
- 依赖：T0010
- 只有依赖任务全部 approved 后才可领取。
