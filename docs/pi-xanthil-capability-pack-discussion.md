# pi-xanthil 与 Capability Pack 关系讨论

## 目的

本文整理本次关于 `pi-xanthil`、当前 `PLS` 项目、`PLS Capability Pack` 以及 AgentHarness 能力包机制之间关系的讨论结论。

核心问题是：

```text
pi-xanthil 是数据分析平台，它到底消费什么？
PLS 项目是否应该直接被 pi-xanthil 消费？
AgentHarness 的第一个能力包是否一定要做 PLS？
```

## 1. PLS 项目与 PLS Capability Pack 的关系

`PLS 项目`不是要被 pi-xanthil 直接消费的对象。

更合理的关系是：

```text
当前 PLS 项目
= 具体项目 / 真实场景 / 第一条样板线

PLS Capability Pack
= 从 PLS 项目中抽象出来的标准能力包

AgentHarness
= 开发、治理、评估、发布 PLS Capability Pack 的后台

pi-xanthil
= 安装并使用 PLS Capability Pack 的前台产品
```

也就是说：

```text
PLS 项目先作为源头
PLS Capability Pack 作为沉淀结果
AgentHarness 管这个沉淀结果
pi-xanthil 消费这个沉淀结果
```

第一版前端闭环不应该打乱当前正在运行的 PLS 项目，而是先展示这条关系：

```text
PLS Source Project
-> Extracted Capabilities
-> PLS Capability Pack v0.1
-> Eval / Release
-> Install to pi-xanthil
```

这样可以先看清楚“PLS 项目如何变成可销售能力包”，而不是把现有 PLS 项目重做一遍。

## 2. 第一个能力包不一定必须是 PLS

`PLS Capability Pack`不是架构硬要求。

选择 PLS 作为第一条样板线的理由只是：它目前已有真实业务场景、数据资产和语义积累，适合快速验证闭环。

第一个 capability pack 的选择标准应该是：

| 标准 | 原因 |
|---|---|
| 有真实业务场景 | 能验证产品不是空架构 |
| 有现成数据或资产 | 前端闭环可以尽快做出来 |
| 能覆盖多库 | 可以验证四库一台不是只服务单模块 |
| 商业化叙事清楚 | 方便解释客户为什么买 |
| 不会打乱现有产品 | 适合做“沉淀能力包”，不是重做项目 |

可选方向包括：

```text
PLS Reference Pack
Retail Operation Pack
Brand Consumer Insight Pack
Trade Area & Site Selection Pack
Tool Governance Pack
Knowledge Retrieval Pack
Ontology Starter Pack
```

更稳的产品做法是：

```text
第一版前端闭环做 Capability Pack Workbench
默认展示一个 Reference Pack
Reference Pack 可以切换：
- PLS Reference Pack
- Retail Operation Pack
- Tool Governance Pack
```

这样用户看到的是 AgentHarness 的通用能力包机制，而不是一个 PLS 专用后台。

## 3. pi-xanthil 能消费什么

pi-xanthil 是数据分析平台，所以它消费的不是“后台项目”，而是能落在数据分析工作流里的能力。

它能消费的 capability pack 至少应该属于以下几类之一：

| 类型 | pi-xanthil 怎么消费 | 示例 |
|---|---|---|
| 数据接入包 | 帮用户识别、导入、清洗、映射数据 | 淘宝/天猫数据字段映射包、PLS 渠道画像数据包 |
| 语义本体包 | 帮用户理解字段、对象、指标、关系 | 零售指标本体、会员运营本体、渠道画像本体 |
| 分析 Workflow 包 | 给用户一个可运行的分析流程 | 销售下滑诊断、会员复购分析、平台人群匹配 |
| Skill / Tool 包 | 增加可调用的数据分析技能或工具 | RFM 分群、CLV 预测、渠道匹配评分 |
| 知识包 | 给分析过程提供方法论、口径、SOP、案例 | 行业分析 playbook、指标解释库、报告审查规则 |
| Eval / Review 包 | 帮用户判断分析结果是否可信 | 报告评分器、指标口径一致性检查、原始数据泄漏检查 |
| 报告模板包 | 让分析结果形成行业可交付报告 | 零售经营月报模板、品牌消费者洞察模板 |

判断一个包是否适合 pi-xanthil 消费，要看它是否回答这个问题：

```text
这个包能让用户完成哪一种更专业的数据分析？
```

能回答这个问题，就是 pi-xanthil 能消费的包。

如果只是后台资产、项目代码、数据库结构或页面逻辑，就不应该直接给 pi-xanthil 消费。

## 4. PLS 能否被 pi-xanthil 消费

结论：

```text
pi-xanthil 可以消费 PLS，但不能消费“PLS 项目”；
它应该消费从 PLS 中沉淀出来的“渠道画像匹配分析能力包”。
```

如果 PLS 只是这些内容：

```text
PLS 项目代码
PLS 数据库
PLS 页面
PLS 专用逻辑
```

那不适合直接被 pi-xanthil 消费，因为会造成产品耦合。

但如果 PLS 被抽象成这些资产：

```text
渠道画像字段字典
平台 / 渠道 / 人群 / 标签本体
九维特征匹配逻辑
平台标签映射规则
目标人群匹配 workflow
渠道推荐报告模板
匹配结果评估规则
```

那就很适合成为 pi-xanthil 的能力包。

它可以被包装为：

```text
PLS Channel & Audience Matching Pack
```

在 pi-xanthil 中的使用方式可以是：

```text
用户上传品牌 / 人群 / 销售数据
-> 选择“渠道画像匹配分析”
-> pi-xanthil 调用 PLS Pack 的字段映射、本体、评分工具、知识规则
-> 生成平台 / 渠道推荐和解释报告
```

## 5. 推荐结论

第一版不要把产品方向绑定死在 PLS 上。

更合理的设计是：

```text
AgentHarness 做通用 Capability Pack Workbench
PLS 作为第一个 Reference Pack 或样板包
pi-xanthil 作为数据分析平台消费这些能力包
当前 PLS 项目作为真实业务源头和验证场
```

这样既能复用 PLS 的真实积累，又不会把 AgentHarness 变成 PLS 专用平台。
