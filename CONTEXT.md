# AgentHarness Context

## 目的

本文维护 AgentHarness 的全局术语、域边界、跨域接口和所有 agent 必须保持的不变量。Codex 是唯一维护者；域 agent 只能通过 handoff 提交术语或 contract change request。

## 术语

| 术语 | 精确定义 | 避免混用 |
| --- | --- | --- |
| Harness | 四库一台通过显式联合契约形成的能力集合 | 单一总库、共享 schema |
| Base | `DataBase`、`OntoBase`、`MemoryBase`、`KnowledgeBase` 中任一独立领域 | 上下层、宿主或附属模块 |
| Console | 用户与 agent 的控制平面和跨库编排入口 | 四库语义的隐式实现层 |
| Joint Contract | 明确跨库身份、输入输出、读写入口、审批、刷新、回写和审计的契约 | 口头约定、UI 硬编码 |
| Controller | 维护全局上下文、合同、任务编排、审核与集成的 Codex | 任一域的默认实现者 |
| Domain Agent | 在单个库的 bounded context 内实现任务的指定 CLI | 可跨库自由修改的通用 agent |
| Domain Handoff | Controller 写给域 agent 的有边界任务 brief | 模糊聊天指令 |
| Handoff Back | 域 agent 返回的变更、验证、风险和 contract drift 记录 | 只说“已完成” |
| Contract Change Request | 域 agent 对共享接口或跨域语义提出的正式变更请求 | 直接修改其他域 |
| ReadModel | 为消费或解释生成、可重新构建的只读模型 | 一等业务实体或事实写入入口 |

## 域与固定 Owner

| 域 | Owner | 负责 | 不负责 |
| --- | --- | --- | --- |
| Controller | Codex | 全局上下文、联合契约、Console contract、Task Bus、审批、集成与最终验收 | 默认代替各域实现内部任务 |
| DataBase | OpenCode | 结构化事实、运行数据、table/view、导入、校验、数据血缘 | 定义 OntoBase 权威语义 |
| OntoBase | Kilo Code | 业务对象、属性、关系、指标、规则、动作、语义映射、source binding | 复制 DataBase 事实行或修改其 schema |
| KnowledgeBase | Mimo Code | 原始文档、规范、外部资料、引用、切片、索引与检索 | 沉淀经验记忆或决定本体语义 |
| MemoryBase | Kimi Code | 经验、偏好、教训、候选记忆、可信度、冲突和生命周期 | 替代事实数据库或知识来源 |
| Console | Antigravity CLI | 控制平面、用户界面、查看、触发、审批、治理、审计和跨库编排入口 | 定义四库权威语义或擅自修改联合契约 |

## 跨域接口

| Upstream | Downstream | Contract | 权威来源 |
| --- | --- | --- | --- |
| DataBase | OntoBase | 外部事实与 source binding；OntoBase 通过 table/view/API/file 引用 | `docs/contracts/` 中的项目 contract |
| OntoBase | DataBase / Console / 产品 | 对象、稳定身份、语义维度、指标口径、规则和解释语义 | `OntoBase/**` 与已批准 contract |
| KnowledgeBase | OntoBase / MemoryBase / Console | 可引用、可追溯的知识来源与检索结果 | `KnowledgeBase/**` 与来源 metadata |
| MemoryBase | Controller / Console / 产品 | 经批准的经验、偏好、置信度和生命周期状态 | `MemoryBase/**` 与记忆治理 contract |
| 四库 | Console | 显式 API、adapter、文件或 contract view | 对应联合契约；Console 不直接猜内部结构 |
| 外部产品 | Harness | Harness consumption contract | `docs/contracts/` 下对应项目文件 |

## 全局不变量

- 四库一台彼此独立，不共享默认存储，不形成上下层或宿主关系。
- 单域变化不自动触发其他域变化；只有联合契约受影响时才创建跨域任务。
- DataBase 保存事实和运行数据；OntoBase 保存权威业务语义，两者不得因同名字段而互相替代。
- KnowledgeBase 保存来源知识；MemoryBase 保存经证据支持的经验记忆，两者不可混用。
- Console 只通过 contract 编排，不把四库语义或表结构隐式硬编码为自身事实。
- 稳定身份、时间窗、来源、版本、置信度、审批和审计语义必须在 contract 中显式说明。
- 跨域 contract 必须先于实现；contract drift 必须由 Codex 接受、拒绝或延期。
- 持久化结构变更必须通过 `Structural Confirmation Gate`。
- 只有 Codex 可以批准域 handoff、联合契约、全局术语和最终集成结果。

## 共享数据规则

- 所有 durable record 必须保留 provenance；导入或聚合不得丢失来源与批次。
- 域 agent 可只读检查其他域证据，但不得写入其他域路径或存储。
- 未经用户或 contract 授权，不向外部模型/API 发送敏感数据。
- ReadModel 必须可追溯到权威事实与语义，不作为独立写入事实。
- 示例、枚举、默认值、标签、ID 和 schema 必须来自用户确认或真实项目证据。

## 验证基线

| 变更类型 | 最低验证 |
| --- | --- |
| DataBase schema/data pipeline | migration、validation、schema check、文档与血缘同步 |
| OntoBase 语义 | 术语、身份、关系、映射、source binding 与 contract 对照 |
| KnowledgeBase | 来源可追溯、切片/索引完整性、检索 smoke |
| MemoryBase | provenance、冲突、状态、过期和晋升规则验证 |
| Console | contract adapter、权限/审批、浏览器或 CLI 端到端验证 |
| 跨域变更 | 每个域验证 + contract test + Codex 集成复核 |

## 变更控制

- 全局术语和域边界：Codex 批准并更新本文或 ADR。
- 联合契约：使用 `docs/templates/CONTRACT_CHANGE_REQUEST.template.md`。
- 域内私有实现：在 Task Bus `allowed_paths` 内由域 agent 决定。
- 域 owner 或 CLI 路由变化：必须更新 `AGENTS.md`、本文和 `Orchestration.md`。
