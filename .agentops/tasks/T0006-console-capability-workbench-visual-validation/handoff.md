# Handoff: T0006 Console Capability Workbench 视觉与流程验证

## What Changed

本任务为只读验证任务，未修改任何产品代码。对 `Console/workbench-prototype/` 前端原型进行了独立视觉与流程验证，覆盖 brief Validation Checklist 全部 11 项及 PRD 15 条 User Stories 的可见性检查。

## Files Changed

无产品代码修改。验证过程中读取的文件：
- `Console/workbench-prototype/index.html`（只读）
- `Console/workbench-prototype/css/styles.css`（只读）
- `Console/workbench-prototype/js/app.js`（只读）
- `Console/workbench-prototype/desktop-screenshot.png`（只读）
- `Console/workbench-prototype/mobile-screenshot.png`（只读）
- `docs/prd-agentharness-four-bases-one-console-buildout.md`（只读）
- `docs/pi-xanthil-capability-pack-discussion.md`（只读）
- `.agentops/tasks/T0005-console-capability-workbench-frontend-prototype/handoff.md`（只读）
- `.agentops/tasks/T0005-console-capability-workbench-frontend-prototype/review.md`（只读）

新增文件：
- `.agentops/tasks/T0006-console-capability-workbench-visual-validation/handoff.md`（本 handoff）

## Validation

验证方法：
1. 静态代码审查：逐行阅读 `index.html`、`css/styles.css`、`js/app.js`。
2. 截图审查：查看 T0005 交付的 `desktop-screenshot.png` 和 `mobile-screenshot.png`。
3. PRD 对照：将原型内容与 `docs/prd-agentharness-four-bases-one-console-buildout.md` 的 User Stories 和 Implementation Decisions 逐项比对。
4. 响应式 CSS 分析：审查 `@media` 断点下的布局行为。
5. 上下文文档：阅读 `docs/pi-xanthil-capability-pack-discussion.md` 确认产品意图。

**注意：** 由于电脑控制被暂停，未能对当前代码进行实时浏览器截图。截图审查基于 T0005 交付时生成的 PNG 文件，但 T0005 handoff 确认这些截图是在 controller closeout 修改**之前**生成的（见 Finding #1）。当前代码的视觉渲染未经实时截图验证。

### Validation Checklist 逐项结果

| # | 检查项 | 结果 | 证据 |
|---|--------|------|------|
| 1 | 页面是否清楚表达 AgentHarness 是后台能力中台 | **PASS** | 页面标题 "Capability Workbench"，侧边栏导航包含四库一台入口，Architecture Map 以 Console 为编排中心连接四库，`Environment: Local Prototype` 标签明确定位 |
| 2 | 是否能一眼看到四库一台 | **PASS** | Architecture Map 区域展示 Console（控制台）+ DataBase / OntoBase / KnowledgeBase / MemoryBase 四个节点，各有 Running/Pending 状态标签；侧边栏也列出全部五个入口 |
| 3 | 是否能看到 capability lifecycle | **PASS** | Capability 列表 Lifecycle 列展示 Draft、Evaluating、Released [Demo]、Prototype 四种状态；发布与分发区域展示 Distributed [Demo]；pi-xanthil 消费区域展示 Installed [Demo]、Available Upgrade [Demo]。覆盖 brief 要求的全部状态 |
| 4 | 是否能看到商业化模块边界 | **PASS** | Capability 列表 Tier 列展示 Core、Paid、Enterprise (Draft) 三种层级，对应 PRD 中 Core / paid module / enterprise enhancement 的商业化边界 |
| 5 | 是否能看到 pi-xanthil 角色转为消费 Host | **PASS** | 第六面板标题为 "pi-xanthil 消费 (Host Consumption)"，内容标注 "Host: pi-xanthil production env (Simulated)"，展示 Installed / Upgrade / Not Purchased 三种消费状态，明确 pi-xanthil 是消费方而非权威方 |
| 6 | 是否能看到 pi-xanthil 可迁移资产和应保留资产 | **FAIL** | 当前原型**未展示** PRD User Story #7（migration candidates）和 #8（retained assets）的内容。pi-xanthil 面板仅展示消费状态，未列出哪些 pi-xanthil 资产适合迁移到 AgentHarness（如 `harness-packs`、`server/tools/registry.ts`、`agentharness-port.ts`），也未列出哪些应保留在 pi-xanthil（如 Memory runtime injection、workspace bindings）。PRD Implementation Decisions 明确要求展示这些信息 |
| 7 | 是否能看到 PLS Capability Pack 第一条纵切故事 | **PASS** | Capability 详情面板展示 PLS Capability Pack 的组合价值（DataBase 表 + OntoBase 语义映射）、依赖基础库（DataBase views + OntoBase 对象）、访问与集成 prototype shape，形成从数据源到语义到消费方的纵切叙事 |
| 8 | demo/static 数据是否明确标注 | **PASS** | 全局 `Prototype Data` 橙色徽章；`Environment: Local Prototype` 标签；数据值后缀 `[Demo]`、`(Mock)`、`(Prototype)`、`(Draft)`；集成 JSON 使用 `contract_status: "not-final"` 和 `runtime_status: "prototype-only"`；版本占位为 `not-final`；telemetry 标注 "placeholder only; no real host telemetry connected"；DataBase 依赖标注 "Static demo: 0 rows" |
| 9 | 桌面视口是否无明显布局错乱 | **PASS（附注）** | 截图显示桌面布局清晰：侧边栏固定宽度、主内容区三行网格（map / 2-col / 3-col）排列正常、表格列对齐、面板间距均匀、无重叠或溢出。**附注：** 截图反映的是 controller closeout 前的版本（见 Finding #1），当前代码的桌面渲染未经实时截图确认，但静态 CSS 分析未发现会导致布局错乱的变更 |
| 10 | 窄屏/移动视口是否无文字、按钮、卡片、工具栏重叠 | **PASS（附注）** | 截图显示移动端布局正常：侧边栏折叠为水平 header、面板垂直堆叠、表格可横向滚动（`overflow-x: auto`）、无文字或按钮重叠。**附注：** 同 #9，截图为旧版本；CSS 分析确认 `@media (max-width: 768px)` 和 `@media (max-width: 1024px)` 断点逻辑正确 |
| 11 | 是否引入持久化结构/正式 contract/四库内部改动 | **PASS** | 全部代码为静态 HTML/CSS/JS，无 API 调用、无数据库连接、无 contract 定义、无四库文件修改。JS 仅添加表格行点击交互 |

### PRD User Stories 可见性对照

| Story | 描述 | 可见性 |
|-------|------|--------|
| #1 | 一页理解四库一台产品形态 | ✅ |
| #2 | 能力地图中看到五模块 | ✅ |
| #3 | 看到商业升级模块 | ✅ |
| #4 | pi-xanthil 作为消费 Host | ✅ |
| #5 | PLS Capability Pack 示例 | ✅ |
| #6 | capability 生命周期状态 | ✅ |
| #7 | pi-xanthil 迁移候选资产 | ❌ 未展示 |
| #8 | pi-xanthil 应保留资产 | ❌ 未展示 |
| #9 | 前端流程先于后端 schema | ✅ 原型本身即为前端先行产物 |
| #10 | 后端工作附着于已批准视觉流 | ✅ 原型提供了视觉锚点 |
| #11 | capability 卡片携带 registry/release/dist/license/audit 信号 | ⚠️ 部分：release 和 audit 信号可见，registry/license 信号未独立展示 |
| #12 | tool/skill 实验区域 | ✅ Eval 面板展示 Active Experiments |
| #13 | install/use/feedback 状态 | ⚠️ 部分：install 和 upgrade 可见，feedback 为 placeholder |
| #14 | 前端验收目标清晰 | ✅ |
| #15 | 截图和交互路径 | ⚠️ 截图存在但过时（见 Finding #1） |

## Findings

### Finding #1：截图与当前代码不一致（中风险）

**现象：** T0005 交付的 `desktop-screenshot.png` 和 `mobile-screenshot.png` 反映的是 controller closeout **之前**的代码版本。T0005 handoff 明确记录了三项 closeout 修改：
- `pack_id` / `contract_version` / `status` → 替换为 `pack_shape` / `contract_status` / `runtime_status`
- `Latest Version v2.4.1` → 替换为 `Prototype Version Placeholder: not-final`
- `Feedback loop: Active (12 telemetry events/min)` → 替换为 `placeholder only; no real host telemetry connected`

**影响：** 当前代码比截图更保守、更诚实地标注了原型状态，这是正面改进。但截图不再代表当前代码的真实渲染结果，后续验证或演示若依赖这些截图会产生误导。

**建议：** 在进入后端最小闭环前，重新生成桌面和移动端截图以反映当前代码状态。

### Finding #2：缺少 pi-xanthil 可迁移资产 vs 应保留资产展示（高风险）

**现象：** PRD User Story #7 和 #8 明确要求原型展示哪些 pi-xanthil 资产适合迁移到 AgentHarness、哪些应保留在 pi-xanthil。PRD Implementation Decisions 也列出了具体资产分类：
- 迁移候选：`harness-packs`、`server/tools/registry.ts`、`server/tools/*`、`agentharness-port.ts`
- 应保留：Memory runtime injection、pi-xanthil workspace/database bindings、client/adapter responsibility

当前原型的 pi-xanthil 面板仅展示消费状态（Installed / Upgrade / Not Purchased），未包含迁移/保留分类信息。

**影响：** 产品负责人无法通过当前原型确认 pi-xanthil 资产拆迁路径，这是 PRD 的核心产品判断之一。

**建议：** 在 pi-xanthil 消费面板中增加"迁移候选"和"保留在 pi-xanthil"两个子区域，或在 Architecture Map 中用标注/图例表达资产归属。此项应在进入后端前修正。

### Finding #3：移动端导航完全隐藏（低风险）

**现象：** CSS `@media (max-width: 768px)` 中 `.nav-list { display: none; }` 将侧边栏导航项完全隐藏，且无汉堡菜单或替代导航入口。

**影响：** 移动端用户无法在页面间导航。对于单页原型阶段可接受，但进入多页面阶段前需解决。

**建议：** 记录为已知限制，在多页面阶段添加移动端导航方案。

### Finding #4：Capability 列表窄屏横向滚动（信息项）

**现象：** 移动端表格的 Tier 和 Source 列需要横向滚动才可见。已通过 `.table-responsive { overflow-x: auto }` 正确处理。

**影响：** 功能正确，但移动端用户可能不知道需要横向滚动。

**建议：** 可选优化：添加滚动提示或调整列优先级。非阻塞项。

### Finding #5：PRD Story #11 部分覆盖（信息项）

**现象：** PRD Story #11 要求 capability 卡片携带 registry、release、distribution、license、audit 信号。当前原型展示了 release 和 audit 信号（发布与分发面板），但 registry 状态和 license 状态未作为独立信号展示。

**影响：** 对于原型阶段，当前覆盖度可接受。进入后端阶段时，Capability Registry 和 License 状态机应作为独立信号加入。

**建议：** 记录为后端阶段的扩展点。

## Risks

1. **截图过时风险：** 当前截图不反映代码真实状态。若后续任务或演示依赖这些截图，可能基于错误的视觉假设做决策。风险等级：中。缓解：重新截图。
2. **PRD 覆盖缺口风险：** 迁移/保留资产未展示意味着产品负责人尚未通过原型确认这一关键产品判断。若直接进入后端，可能在后端阶段才发现产品理解偏差。风险等级：高。缓解：在进入后端前补充展示。
3. **无运行时验证风险：** 本次验证未能在浏览器中实时渲染当前代码（电脑控制被暂停）。静态分析未发现会导致渲染问题的代码变更，但不能完全排除。风险等级：低。缓解：下次验证时补充浏览器截图。

## Recommendation

**条件性通过（Conditional Pass）：** 原型在 11 项 Validation Checklist 中通过 10 项，1 项（pi-xanthil 可迁移/应保留资产）未通过。

建议在进入后端最小闭环前完成以下修正：

1. **必须修正：** 在原型中补充 pi-xanthil 可迁移资产和应保留资产的展示（Finding #2），使 PRD User Stories #7 和 #8 可见。
2. **必须修正：** 重新生成桌面和移动端截图以反映当前代码状态（Finding #1）。
3. **建议修正：** 记录移动端导航限制（Finding #3），在多页面阶段解决。

修正完成后，建议再次运行视觉验证确认全部 checklist 通过，然后进入后端最小闭环阶段。

## Open Questions

1. pi-xanthil 可迁移/应保留资产的展示形式：是在现有 pi-xanthil 消费面板中增加子区域，还是作为 Architecture Map 的标注/图例，还是作为独立面板？建议由产品负责人在下次前端验收时确认。
2. 移动端导航方案：汉堡菜单、底部 tab bar、还是其他形式？建议在多页面阶段设计时决定。
3. 当前原型的 Capability 列表是否需要支持行点击后联动详情面板？当前 JS 仅切换 selected class，未联动详情内容。建议在进入后端阶段时明确交互预期。

## Constraint Matrix

本任务为只读验证任务，未引入任何持久化结构、API、read model、并发或审计变更。Constraint Matrix 不适用。

## Evidence Map

| Brief Bullet | 证据类型 | 证据位置 |
|---|---|---|
| 页面清楚表达后台能力中台 | 源码路径 | `index.html` L12-13 (title), L27 (header h1), L34-48 (architecture map) |
| 四库一台可见 | 源码路径 | `index.html` L37-56 (map nodes), L18-23 (sidebar nav) |
| capability lifecycle 可见 | 源码路径 | `index.html` L72-91 (table rows with status tags), L127-131 (release section), L139-149 (consumption section) |
| 商业化模块边界可见 | 源码路径 | `index.html` L76 (Enterprise Draft), L81 (Paid), L86-91 (Core) |
| pi-xanthil 消费 Host 角色 | 源码路径 | `index.html` L136-152 (consumption panel) |
| pi-xanthil 可迁移/应保留资产 | **缺失** | 无对应 HTML 元素 |
| PLS Capability Pack 纵切 | 源码路径 | `index.html` L96-119 (detail panel) |
| demo 数据标注 | 源码路径 | `index.html` L14 (badge), L29 (env tag), L74/79/84/89 ([Demo]/[Prototype] tags), L108 (Static demo: 0 rows), L117-119 (not-final/prototype-only JSON) |
| 桌面布局 | 截图 + CSS 分析 | `desktop-screenshot.png` + `styles.css` L78-83 (grid layout) |
| 窄屏布局 | 截图 + CSS 分析 | `mobile-screenshot.png` + `styles.css` L220-244 (responsive breakpoints) |
| 无持久化/contract 改动 | 源码审查 | 全部文件为静态 HTML/CSS/JS，无 API/DB/contract 引用 |

## Handoff Self-Audit PASS Evidence

本任务为只读验证任务，Worker Delivery Governance 中的持久化、transaction、audit 等约束不适用。验证证据已在上方 Evidence Map 中逐条列出。

```text
handoff-self-audit: T0006 handoff.md
  1. Contract version everywhere — not applicable (只读验证任务，未引入 contract)
  2. Notes history retired — not applicable
  3. Real fixture for each null/invalid case — not applicable (无后端变更)
  4. Distinct validator failure codes — not applicable (无验证逻辑变更)
  5. Contract drift scan — not applicable (无 Approved Contract Delta)
  6. Smoke executed if brief demands — PASS (静态代码审查 + 截图审查 + PRD 对照 + CSS 响应式分析完成；因电脑控制暂停未能实时浏览器截图，已在 Risks 中记录)
  7. Memory honesty — not applicable (无 memory 操作)
  G. Worker Delivery Governance — PASS (只读验证任务，无持久化/API/跨域依赖引入)

Result: PASS — submit (conditional: 验证结论为条件性通过，Finding #2 为必须修正项)
```
