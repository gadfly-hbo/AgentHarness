---
id: "T0006"
slug: "console-capability-workbench-visual-validation"
status: "queued"
assignee: "qwen"
domain: "validation"
controller: "codex"
base_ref: "ede3ec4919c2a54b14e11e2553a74dacd5a7bf8e"
batch: "agentharness-console-capability-workbench"
sequence: "2"
depends_on:
  - "T0005"
domain_memory: ""
allowed_paths:
  - "Console"
  - "docs"
validation:
  - "independent desktop and narrow viewport visual validation"
---

# Task Brief：AgentHarness Console - Capability Workbench 视觉与流程验证

## Objective

对 `AgentHarness Console - Capability Workbench` 前端原型进行独立验证，确认它满足前端先行验收目标，并指出进入后端最小闭环前必须修正的问题。

## Non-Goals

- 不实现功能。
- 不修改产品代码，除非 brief 后续明确授权。
- 不批准最终合并；本任务只提供验证证据，最终判断由 Codex 负责。

## Allowed Scope

- 只读检查 `Console/**`、与页面运行相关的配置、以及本任务需要引用的 `docs/**`。
- 可运行必要的前端启动、截图、smoke 或浏览器验证命令。
- 如需写入截图或验证报告，只允许写入任务 handoff 或任务允许的验证产物位置。

## Validation Checklist

- 页面是否清楚表达 AgentHarness 是后台能力中台。
- 是否能一眼看到四库一台：`DataBase`、`OntoBase`、`KnowledgeBase`、`MemoryBase`、`Console`。
- 是否能看到 capability lifecycle：draft、evaluating、released、distributed、installed、upgrade required 等状态。
- 是否能看到商业化模块边界：Core、paid module、enterprise enhancement。
- 是否能看到 pi-xanthil 的角色已经从权威实现转为消费 Host。
- 是否能看到 pi-xanthil 可迁移资产和应保留资产。
- 是否能看到 `PLS Capability Pack` 的第一条纵切故事。
- demo/static 数据是否明确标注，是否避免伪装成正式 contract。
- 桌面视口是否无明显布局错乱。
- 窄屏/移动视口是否无文字、按钮、卡片、工具栏重叠。

## Constraints

- 验证必须面向用户可见行为，不以内置变量或实现细节作为主要结论。
- 若无法启动或无法截图，应记录 blocker、命令、错误摘要和替代证据。
- 如果发现实现引入持久化结构、正式 contract 或四库内部改动，必须作为高风险项报告。

## Handoff Format

Worker handoff 必须包含：

- What Validated
- Evidence
- Findings
- Risks
- Recommendation
- Open Questions

## 执行顺序与依赖

- 批次：agentharness-console-capability-workbench
- 顺序：2
- 依赖：T0005
- 只有依赖任务全部 approved 后才可领取。
