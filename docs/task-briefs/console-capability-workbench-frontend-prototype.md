# Task Brief：AgentHarness Console - Capability Workbench 前端原型

## Objective

实现一个可打开、可视觉验收的 `AgentHarness Console - Capability Workbench` 前端原型，让用户先看见 AgentHarness 四库一台作为后台能力中台的产品形态。

## Non-Goals

- 不创建或修改持久化 schema、migration、database、view、contract。
- 不迁移 pi-xanthil 真实代码或资产。
- 不接入真实后端 API。
- 不实现 license enforcement、release approval、package installation。
- 不修改 `DataBase/**`、`OntoBase/**`、`KnowledgeBase/**`、`MemoryBase/**` 的内部结构。

## Allowed Scope

- 优先修改或新增 `Console/**`。
- 如现有前端入口需要最小索引文档，可修改 `docs/**` 中与本任务直接相关的说明。
- 不允许改动四库内部实现。

## Required Product Shape

页面必须能表达以下六个区域：

- 四库一台能力地图：`DataBase`、`OntoBase`、`KnowledgeBase`、`MemoryBase`、`Console`。
- 当前 capability 列表：包含 lifecycle、module、commercial tier、source。
- `PLS Capability Pack` 示例详情：展示 DataBase / OntoBase / KnowledgeBase 的组合价值。
- 实验与评估状态：展示 tool / skill / ontology / knowledge / memory 的治理入口。
- 发布与分发状态：展示 release、distribution、version、audit 信号。
- pi-xanthil 消费状态：展示 installed、available upgrade、not purchased、feedback loop。

## UI Direction

本任务的 UI 风格必须先服务“后台能力治理控制台”，不是营销官网、概念海报或普通 dashboard。

- 产品气质：企业级、克制、工程化、可治理、可审计；视觉上要像能力控制台，而不是 landing page。
- 信息密度：中高密度，适合反复查看 capability 状态、生命周期、依赖、风险和分发情况。
- 页面结构：优先采用左侧/顶部导航 + 主工作区 + 详情/状态面板；不要做大 hero、宣传式首屏或装饰性卡片堆叠。
- 视觉语言：浅色为主，使用中性底色、细边框、状态色和少量强调色；避免大面积紫色/蓝紫渐变、深色赛博风、玻璃拟态和过度阴影。
- 状态表达：必须清晰区分 `prototype`、`draft`、`evaluating`、`released`、`distributed`、`installed`、`upgrade_required`、`not_purchased`、`blocked`。
- 模块表达：四库一台应以能力地图或架构关系呈现，不能只是五张孤立卡片。
- 商业化表达：Core、paid module、enterprise enhancement 要可扫描，但不要做成价格页。
- pi-xanthil 表达：pi-xanthil 是消费 Host，不是 AgentHarness 的下级模块；页面要体现“发布/分发到 pi-xanthil”的关系。
- Demo 标识：所有静态数据、示例 pack、示例状态必须有明确 `Prototype data` 或等价标识。
- 交互预期：按钮、tab、筛选、详情入口可以先是前端原型，但禁用态和不可用原因要可见。
- 响应式：桌面优先，同时窄屏不能出现文字、按钮、卡片或工具栏重叠。
- 文案：使用简体中文说明业务含义，保留 `Capability`、`Package`、`Release`、`Distribution`、`License`、`Audit` 等英文技术术语。

推荐视觉方向：

```text
Operational Console
浅色工作台 + 中性灰/墨绿/琥珀状态色 + 紧凑表格/状态条/能力地图
```

明确禁止：

- 不做营销页式 hero。
- 不做“AI 产品官网”式大标题 + 渐变卡片。
- 不把每个概念都做成大圆角浮动卡片。
- 不使用未标注的假数据冒充真实能力。
- 不把 Console 画成四库的父级存储或上层实现。

## Constraints

- 前端先行：本任务交付可见界面，不做真实后端。
- 所有 demo/static 数据必须显式标注为 prototype 或 demo，不得伪装成正式 contract。
- 不得发明最终持久化 ID、枚举、价格、客户授权规则或数据库字段。
- UI 应体现 Console 是控制平面，不是四库宿主。
- 页面应能支持后续接入真实 `Capability Registry`，但本任务不得提前固化后端 schema。
- 如果实现过程中发现必须新增持久化结构或正式 contract，立即停止并上报 blocker，等待 `agentharness-structure-grill`。

## Existing Asset Governance

- `DataBase` 已有 PLS SQLite 资产，可展示为已有事实数据基础，但不得改动 `DataBase/**`。
- 当前 `platform_profile_tag_metrics` 和 `v_workpls_dimension_evidence` 为 0 行，不得展示为真实平台画像指标链路已完成。
- `OntoBase` 已有 PLS 语义资产，可展示为已有语义沉淀，但 Console 不得硬编码 `OntoBase/**` 内部语义或把 OntoBase 当作 Console 私有数据。
- `Console/commands/agentharness.mjs` 是早期 file-loop 治理原型，只可作为历史治理闭环参考，不作为 Capability Workbench 的主架构。
- `MemoryBase` 和 `KnowledgeBase` 当前按规划中 / 待接入 / 可迁移 pi-xanthil 能力核展示，不得伪装为已完成模块。
- 本任务不得修改 `DataBase/**`、`OntoBase/**`、`MemoryBase/**`、`KnowledgeBase/**`。

## Validation Requirements

- 提供桌面视口截图或等价视觉证据。
- 提供窄屏/移动视口截图或等价视觉证据。
- 验证页面无明显重叠、溢出、空白主界面或无法阅读的问题。
- 验证六个 required product shape 区域均可见。
- 验证 UI 符合 `UI Direction`：控制台气质、信息密度、状态表达、demo 标识、pi-xanthil 消费关系均清晰。
- 验证 demo/static 数据有明确 prototype 标识。
- 若新增运行命令，说明真实命令、端口和访问方式。

## Handoff Format

Worker handoff 必须包含：

- What Changed
- Files Changed
- Validation
- Risks
- Open Questions
- 是否触发结构确认 gate；如果没有，说明原因是本任务未引入持久化结构或正式 contract。
