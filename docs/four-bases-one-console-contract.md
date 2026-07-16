# Four Bases and One Console Contract

日期：2026-07-15

## 1. 顶层声明

AgentHarness 由“四库一台”构成：

- `DataBase`：数据库。
- `OntoBase`：本体库。
- `MemoryBase`：记忆库。
- `KnowledgeBase`：知识库。
- `Console`：控制台。

这五个部分彼此独立、解耦，不互为上下层实现，不互相附属，也不默认共享同一个存储。它们通过联合契约共同组成 Harness，供外部产品或项目消费。

## 2. 独立性原则

每一库和一台都可以独立演进：

- 独立的领域边界。
- 独立的文档、schema、数据结构和生命周期。
- 独立选择存储形态，例如文件、SQLite、服务、索引或其他后端。
- 独立决定自己的导入、校验、发布、审计和治理流程。

任何一个库的变化都不自动要求其他库同步改动。只有当某个外部产品或项目使用了多个库的联合能力，且联合契约受影响时，才需要跨库对齐。

## 3. 责任边界

| 部分 | 独立职责 | 不负责 |
| --- | --- | --- |
| `DataBase` | 结构化事实数据、运行数据、导入链路、SQL/view、校验、字段注释、数据血缘 | 不负责定义全部业务语义，不作为 OntoBase 的宿主 |
| `OntoBase` | 业务对象、概念、属性语义、关系、指标口径、规则、动作、语义映射、决策语义 | 不复制 DataBase 行数据，不依附数据库 schema |
| `MemoryBase` | 经验、偏好、教训、可复用操作记忆、记忆候选、可信度和生命周期 | 不承载事实数据库，不替代知识来源 |
| `KnowledgeBase` | 文档、规范、外部资料、引用材料、检索索引、来源追溯 | 不沉淀个人/项目经验记忆，不替代本体建模 |
| `Console` | 用户和 agent 的控制平面、查看、触发、审批、治理、跨库编排入口 | 不把四库的语义和数据硬编码进控制台 |

## 4. 联合契约

联合契约是四库一台协作的唯一耦合点。它描述：

- 一个外部产品/项目要消费哪些库。
- 每个库暴露哪些对象、读取入口、写入入口或能力。
- 跨库如何引用同一个业务对象。
- 哪些字段或对象承担稳定身份。
- 哪些操作需要审批、审计、刷新或回写。
- 哪些解释链路要跨库展开。

联合契约可以是 Markdown、JSON schema、SQLite 表、API contract 或控制台配置。形式可以演进，但原则是：契约显式化，库之间不隐式依赖。

## 5. 对外消费方式

外部产品或项目不应直接假设某一库是“总库”。正确方式是声明自己的 Harness consumption contract：

```text
Product / Project
  -> consumes DataBase capability A
  -> consumes OntoBase capability B
  -> consumes MemoryBase capability C
  -> consumes KnowledgeBase capability D
  -> is operated through Console workflow E
```

例如第一期 PLS 渠道画像匹配：

```text
PLS Channel Profile Matching
  -> DataBase: PLS 表、view、真实画像指标、九维特征矩阵
  -> OntoBase: PLS 业务对象、维度语义、指标口径、匹配解释规则
  -> MemoryBase: 匹配经验、人工修正、模型迭代教训
  -> KnowledgeBase: PLS 业务标准、平台标签资料、导入规范、研究资料
  -> Console: 导入、预检、复核、刷新、解释、发布的控制入口
```

## 6. 变更规则

1. 单库内部变更，只维护该库自己的文档、schema、校验和发布说明。
2. 联合契约受影响时，维护对应项目的 contract 文档。
3. 一个库新增能力，不自动要求其他库同步。
4. 一个外部项目新增消费路径，必须声明使用哪些库、读取/写入哪些入口、跨库身份如何对齐。
5. 控制台只能编排和展示联合契约，不应把契约隐式写死在 UI 逻辑里。

## 7. 当前第一期

当前第一期联合场景是：

```text
PLS 渠道画像匹配项目
```

首期重点是让 `DataBase` 与 `OntoBase` 建立清晰协作，但这不改变四库一台的独立性。后续 `MemoryBase`、`KnowledgeBase`、`Console` 进入该场景时，也应通过显式联合契约加入，而不是变成某个库的附属模块。

### PLS 的权威边界

`PLS 渠道画像匹配项目`是 AgentHarness 第一个正式验证 `DataBase` 与 `OntoBase` 联合工作的项目。PLS 是外部消费项目和联合场景，不是第五个库，也不是 `DataBase` 与 `OntoBase` 的共享存储。

- `DataBase` 是 PLS 事实数据、平台提取清单、实际提取结果和数据读取入口的权威来源。
- `OntoBase` 是 PLS 业务对象、标签语义、PLS 分层、指标口径、映射关系和解释规则的权威来源。
- `DataBase` 新增提取标签，不等于 `OntoBase` 新增语义对象；必须先检查 OntoBase 中该标签是否已经存在。
- `OntoBase` 调整标签分层或解释语义，不自动要求 `DataBase` 修改表结构或事实数据。
- HTML、报表和 Console 页面是消费或展示产物，除非联合契约另有明确声明，否则不成为事实数据或业务语义的权威来源。
- 只有稳定身份、source binding、输入输出字段、读写入口或其他联合契约发生变化时，才需要 DataBase 与 OntoBase 跨域联动。
- `KnowledgeBase`、`MemoryBase` 和 `Console` 后续加入 PLS 时，必须分别声明消费入口、权威边界和跨域身份对齐方式。

当一个 PLS 变更同时提到标签、分层、提取表、HTML 或 Console 时，Codex 必须先按 `AGENTS.md` 的“跨域变更判定门槛”形成影响判断，再分别向受影响域派发任务。

## 8. 开发控制权

四库一台的运行架构与开发 agent 架构相互对应，但不混为一体：

| 范围 | 开发 owner | 规则 |
| --- | --- | --- |
| 全局上下文、联合契约、Console contract、集成与验收 | Codex | 作为唯一总控维护共享语义和跨域变更顺序 |
| `DataBase` | OpenCode | 只在 DataBase 域内实现事实数据和数据工程能力 |
| `OntoBase` | Kilo Code | 只在 OntoBase 域内实现权威业务语义 |
| `KnowledgeBase` | Mimo Code | 只在 KnowledgeBase 域内实现来源知识和检索能力 |
| `MemoryBase` | Kimi Code | 只在 MemoryBase 域内实现经验记忆和生命周期 |
| `Console` | Antigravity CLI | 只在 Console 域内实现控制平面、用户界面和编排入口 |

一个域 agent 发现其他域需要变化时，只能向 Codex 提交 contract change request。Codex 先更新或批准联合契约，再创建受影响域的独立 Task Bus 任务。任何域都不能用直接修改另一域文件的方式完成跨域同步。
