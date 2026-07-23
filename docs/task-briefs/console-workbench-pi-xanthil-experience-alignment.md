# AgentHarness Console 前端迭代方案：对齐 pi-xanthil 产品体验

## 目的

在保持 AgentHarness “后台能力中台 / capability 治理台”定位不变的前提下，让 Console Workbench 的视觉密度、交互语言和信息组织更接近 pi-xanthil 现有产品生态，避免用户感觉它是另一个陌生产品。

## 当前判断

pi-xanthil 的四库一台已经是产品内真实运行底座，服务于分析工单、工具调用、知识/记忆/本体管理和报告闭环。AgentHarness Console 不应照抄 pi-xanthil 的用户分析工作台，而应成为 pi-xanthil 生态里的后台能力控制台。

因此本轮前端迭代目标是：

- 保留 AgentHarness 的能力治理定位。
- 借鉴 pi-xanthil 的内部工具风格、中文界面、紧凑布局和真实工作区心智。
- 明确 pi-xanthil 是 Host consumer，AgentHarness 是 capability authority。
- 让页面看起来像 pi-xanthil 生态的后台控制台，而不是独立架构说明页。

## 设计方向

### 体验对齐原则

- 中文为主，英文只作为产品名、模块名和技术术语辅助。
- 保持内部工具风格：紧凑、冷静、可扫描、少装饰。
- 页面结构沿用 T0008/T0009 的 operational Console，不退回说明书形态。
- 强化工作区心智：当前能力、当前状态、下一步动作、阻塞原因、审计证据。
- 弱化营销化卡片，避免大段解释和孤立展示。

### 与 pi-xanthil 的分工表达

AgentHarness Console 应展示：

- 能力包（Capability Pack）生命周期治理。
- 工具 / Skill / Package / Eval / Release / Distribution 的后台状态。
- 四库依赖状态：DataBase、OntoBase、KnowledgeBase、MemoryBase。
- Host 消费状态：pi-xanthil 是否可安装、可使用、需升级或受阻。
- 审计线索：评估、发布、分发、Host 接入的事件记录。

pi-xanthil 应继续承接：

- 分析工单、workspace、session、报告、用户操作流。
- 能力安装后的使用入口。
- 用户反馈、业务动作和产品体验。

## 本轮任务范围

只做前端原型迭代：

- `Console/workbench-prototype/index.html`
- `Console/workbench-prototype/css/styles.css`
- `Console/workbench-prototype/js/app.js`
- `Console/workbench-prototype/desktop-screenshot.png`
- `Console/workbench-prototype/mobile-screenshot.png`
- `Console/workbench-prototype/start.command` 仅允许保持或修正一键启动用途

不做：

- 后端。
- API。
- schema / migration / persistence。
- AgentHarness consumption contract。
- pi-xanthil 仓库改动。
- 真实 registry / package / install / distribution。

## 验收标准

- 打开页面后，第一感受是“pi-xanthil 生态里的后台能力控制台”，不是说明书页面，也不是独立营销页。
- 首屏能看到：
  - 当前能力包。
  - 生命周期状态。
  - 四库依赖。
  - Host 接入状态。
  - 主要操作。
- 文案中文为主。
- T0009 已完成的中文化不回退。
- desktop 和 mobile 截图都可读，无标题裁切、卡片重叠或非预期横向溢出。
- `start.command` 仍可一键启动。

## 后续衔接

本轮通过后，才进入下一阶段：最小真实 `Capability Registry` read-only backend seam。该后端阶段必须先走结构确认，不在本轮实施。
