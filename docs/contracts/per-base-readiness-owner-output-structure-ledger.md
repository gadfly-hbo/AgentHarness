# Per-Base Readiness Owner Output 结构确认台账

## 状态

- 日期：2026-07-24
- 仓库：`/Users/huangbo/Dev/AgentHarness`
- Controller：`Codex / AgentHarness Controller`
- 状态：结构确认明细已完成，用户已整体批准
- 适用 Gate：AgentHarness `Structural Confirmation Gate`

本文记录 AgentHarness 下一阶段 `Per-Base Readiness Owner Output` 的结构确认结果。
该阶段目标，是把当前 Console backend 内置的 `READINESS_OBSERVATIONS`，逐步替换为四库各自 owner 产出的真实 readiness fact。

用户已于 2026-07-24 整体批准 O001-O013。后续实现只能覆盖本台账授权的范围；
实施中出现新的结构决定时必须暂停并回到结构确认。

## 范围

本期定义四库各自输出 `BaseReadinessFact` 的联合契约：

- `DataBase`、`OntoBase`、`KnowledgeBase`、`MemoryBase` 全部纳入首期 contract。
- 每个 Base 在本域内维护自己的 readiness 输出文件。
- Console 只读读取固定路径、校验并聚合。
- Console 不写入、不刷新、不审批、不审计、不回写四库。
- 缺失、重复或损坏 readiness fact 必须 fail closed。

## 当前证据

| 证据 | 约束 |
| --- | --- |
| `docs/four-bases-one-console-contract.md` | 四库彼此独立，Console 是控制平面，不应成为四库事实宿主 |
| `docs/contracts/capability-pack-base-readiness-readmodel-structure-ledger.md` | 已批准 Console 内部 ReadModel seam：`CapabilityPackBaseReadinessObservation` |
| `.agentops/tasks/T0017-capability-pack-base-readiness-backend-seam/review.md` | T0017 已批准，当前 `dependencies.bases[]` 由内置 readiness observations 派生 |
| `.agentops/tasks/T0018-console-readiness-readmodel-ui-expression/review.md` | T0018 已批准，UI 已表达 Readiness ReadModel / Base-level observation |
| `.agentops/tasks/T0019-readiness-readmodel-validation/review.md` | T0019 已批准，批次验证指出下一步是替换内置 observations 为 per-base real owner outputs |

## 变更影响清单

| 变更项 | 权威域 | 当前状态 | 本次动作 | contract 是否受影响 | 需要派发的域 | 明确不修改的域 |
| --- | --- | --- | --- | --- | --- | --- |
| BaseReadinessFact | 各 Base | 不存在四库统一输出 | 各 Base 在本域内输出自身 readiness fact | 是 | database、ontobase、knowledgebase、memorybase | Console 不写入 |
| Console 聚合读取 | Console backend | 当前读取内置 `READINESS_OBSERVATIONS` | 改为只读读取四个固定 JSON 文件，校验后聚合 | 是 | console-backend | Console UI 暂不改 |
| 独立验证 | validation | T0019 已验证内置 ReadModel seam | 验证四库输出、Console 聚合、fail closed、无回写 | 否，验证 contract 符合性 | validation | 产品实现文件 |

## 决策台账

| Sequence | Topic | Recommendation | Reason | User decision | Consistency | Status | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| O001 | 下一阶段结构范围 | `Per-Base Readiness Owner Output`：各 Base 产出自身 readiness fact，Console 只读聚合 | 把观察结果权威来源迁回各 Base，避免 Console 成为四库 readiness 事实宿主 | A | 一致 | Confirmed | 用户确认 2026-07-24 |
| O002 | 首期覆盖 Base | 四个 Base 全部纳入首期 contract，实施可串行 | 保持完整四库语义，避免部分真实、部分 Console 填补 | A | 一致 | Confirmed | 用户确认 2026-07-24 |
| O003 | 每个 Base 输出的业务对象 | 各 Base 输出 `BaseReadinessFact`，Console 聚合为 `CapabilityPackBaseReadinessObservation` | 区分 Base 的事实声明与 Console 的只读观察结果 | A | 一致 | Confirmed | 用户确认 2026-07-24 |
| O004 | BaseReadinessFact 粒度 | `Base × Capability Pack × current readiness fact`，稳定键 `base + packId` | 当前 Console 只需要当前状态；不引入历史、版本和冲突合并复杂度 | A | 一致 | Confirmed | 用户确认 2026-07-24 |
| O005 | BaseReadinessFact 最小字段组 | `base / packId / state / reason / checkedAt / evidenceRefs[] / producer` | 足够支撑 Console 聚合和证据追溯，避免过早引入评分、审批、审计或内部对象暴露 | A | 一致 | Confirmed | 用户确认 2026-07-24 |
| O006 | 状态枚举 | 沿用 `ready / pending / blocked / not_applicable` | 直接映射现有 `dependencies.bases[].state`，不扩展 UI/API shape | A | 一致 | Confirmed | 用户确认 2026-07-24 |
| O007 | 证据引用边界 | evidenceRefs 只允许 repo-relative `label/path/note` | 证据可复核、可版本化，避免本机路径或私有 endpoint 成为 contract 事实 | A | 一致 | Confirmed | 用户确认 2026-07-24 |
| O008 | 各 Base 落地位置 | 每个 Base 在本域内落地 `<Base>/readiness/capability-pack-readiness.json`，内容为 `BaseReadinessFact[]` | JSON 输出轻量、可审查、适合首期跨四库统一 contract；各 Base 仍在本域 allowed paths 内维护 | A | 一致 | Confirmed | 用户确认 2026-07-24 |
| O009 | Console 聚合读取方式 | Console 读取四个固定 JSON 路径，校验后聚合；缺失/损坏 fail closed | 固定路径让 contract 明确、可测试、可 grep；fail closed 防止误判 ready | A | 一致 | Confirmed | 用户确认 2026-07-24 |
| O010 | 缺失 Base fact 语义 | 缺少目标 `packId` 的 Base fact 时 Console fail closed | `pending` 必须是 Base 自己的事实声明，不应由 Console 代填 | A | 一致 | Confirmed | 用户确认 2026-07-24 |
| O011 | 重复 Base fact 语义 | 重复 `base + packId` 直接 `validation_failed` | 重复当前 fact 会造成聚合不确定；首期不做隐式合并或按时间取最新 | A | 一致 | Confirmed | 用户确认 2026-07-24 |
| O012 | 写入与刷新边界 | 本期无 Console 写入/刷新/回写；各 Base 自己维护 readiness 文件 | 避免突破 Console 控制平面边界和引入跨域写入治理 | A | 一致 | Confirmed | 用户确认 2026-07-24 |
| O013 | 实施任务拆分 | 整体批准后按 6 张串行任务推进：四库各自产出 fact、Console 聚合、Qwen 验证 | 符合 owner 边界和串行 worktree 原则，每个 Base 单独审核 | A | 一致 | Confirmed | 用户确认 2026-07-24 |

## 派生结构方案

### 业务对象

每个 Base 输出：

```text
BaseReadinessFact
```

业务含义：

```text
某个 Base 针对某个 Capability Pack 的当前 readiness 事实声明。
```

Console 聚合为现有：

```text
CapabilityPackBaseReadinessObservation
```

并继续派生：

```text
CapabilityPack.dependencies.bases[]
```

### 粒度与身份

粒度：

```text
一个 Base × 一个 Capability Pack × 一个当前 readiness fact
```

稳定业务键：

```text
base + packId
```

首期不保留历史；如需历史，后续另行结构确认。

### 最小字段 shape

```text
BaseReadinessFact
  base
  packId
  state
  reason
  checkedAt
  evidenceRefs[]
    label
    path
    note
  producer
```

### 字段语义

| 字段 | 含义 | 约束 |
| --- | --- | --- |
| `base` | 产出 fact 的 Base | `DataBase / OntoBase / KnowledgeBase / MemoryBase` |
| `packId` | Capability Pack 稳定身份 | 必须引用已批准 Capability Registry `packId` |
| `state` | Base-level readiness 状态 | `ready / pending / blocked / not_applicable` |
| `reason` | Base 自己给出的业务原因 | 字符串；不得包含私有路径、连接串或未公开 runtime endpoint |
| `checkedAt` | Base 最后检查时间 | ISO 8601 字符串 |
| `evidenceRefs[]` | repo-relative 可复核证据引用 | 结构为 `label/path/note` |
| `producer` | 产出该 fact 的域或工具标识 | 建议为 `database / ontobase / knowledgebase / memorybase` |

### 状态枚举

```text
ready
  该 Base 对当前 Capability Pack 的最低消费条件已满足。

pending
  该 Base 需要接入或验证，但当前尚未完成。

blocked
  该 Base 存在明确阻塞，不能被视为可用。

not_applicable
  该 Capability Pack 当前不依赖该 Base。
```

### 文件落地位置

首期固定路径：

```text
DataBase/readiness/capability-pack-readiness.json
OntoBase/readiness/capability-pack-readiness.json
KnowledgeBase/readiness/capability-pack-readiness.json
MemoryBase/readiness/capability-pack-readiness.json
```

每个文件内容：

```text
BaseReadinessFact[]
```

### Console 聚合规则

Console backend 只读读取四个固定文件：

```text
DataBase/readiness/capability-pack-readiness.json
OntoBase/readiness/capability-pack-readiness.json
KnowledgeBase/readiness/capability-pack-readiness.json
MemoryBase/readiness/capability-pack-readiness.json
```

聚合步骤：

1. 读取四个文件。
2. 校验每条 `BaseReadinessFact`。
3. 检查 `base + packId` 在单文件内不得重复。
4. 对目标 `packId`，四个 Base 都必须有 fact。
5. 映射为 `CapabilityPackBaseReadinessObservation`。
6. 派生现有 `dependencies.bases[]`。

fail closed：

```text
文件缺失 -> validation_failed
JSON 非法 -> validation_failed
shape 损坏 -> validation_failed
目标 packId 缺 Base fact -> validation_failed
重复 base + packId -> validation_failed
```

不得用 Console 内置默认值兜底。

### 写入与刷新边界

本期无 Console 写入：

```text
Console create/update/delete readiness fact: 不做
Console refresh readiness: 不做
Console approve readiness: 不做
Console audit write: 不做
Console write back to bases: 不做
```

各 Base readiness 文件由本域 agent 在本域任务中生成或维护。

## 非目标

- 不新增 Console 写入、刷新、审批、审计或回写四库。
- 不新增 HTTP endpoint。
- 不新增 `CapabilityPack` 对外字段。
- 不新增 DataBase SQLite 表或 view。
- 不新增服务 API。
- 不实现历史 readiness 事件或版本。
- 不引入 score、confidence、severity、sla、auditEvents、internalObjectRefs 或 runtimeEndpoint。
- 不修改 pi-xanthil consumption contract。

## 验证要求

### Base 输出任务验证

每个 Base 任务至少验证：

- JSON 语法合法。
- 内容为数组。
- 每条 fact 包含最小字段组。
- `base` 与所在 Base 一致。
- `packId` 合法。
- `state` 在允许枚举内。
- `evidenceRefs[].path` 为 repo-relative，拒绝绝对路径、URL、空路径。
- 同一文件内无重复 `base + packId`。
- 不修改其他 Base。

### Console 聚合任务验证

至少验证：

- 成功读取四个固定文件。
- 缺文件 fail closed。
- 非法 JSON fail closed。
- shape 损坏 fail closed。
- 缺目标 `packId` fact fail closed。
- 重复 `base + packId` fail closed。
- 正常路径下 CLI/HTTP 返回四个 Base 派生结果。
- `/api/base-readiness` 仍不新增，除非另走结构确认。
- Console 不写入四库 readiness 文件。

### 独立验证任务

Qwen 独立验证：

- 四库文件存在且 shape 符合 contract。
- Console 聚合真实读取四库文件，而不是继续使用内置 `READINESS_OBSERVATIONS`。
- fail closed 路径覆盖完整。
- 无 Console 写入、刷新、回写。
- 无 contract drift。

## 任务拆分计划

整体批准后，按以下串行任务创建：

| Sequence | Task | Domain | Assignee | Allowed paths | Objective |
| --- | --- | --- | --- | --- | --- |
| 1 | DataBase readiness fact output | `database` | `opencode` | `DataBase/**` | 创建 `DataBase/readiness/capability-pack-readiness.json` |
| 2 | OntoBase readiness fact output | `ontobase` | `kilo` | `OntoBase/**` | 创建 `OntoBase/readiness/capability-pack-readiness.json` |
| 3 | KnowledgeBase readiness fact output | `knowledgebase` | `mimo` | `KnowledgeBase/**` | 创建 `KnowledgeBase/readiness/capability-pack-readiness.json` |
| 4 | MemoryBase readiness fact output | `memorybase` | `kimi` | `MemoryBase/**` | 创建 `MemoryBase/readiness/capability-pack-readiness.json` |
| 5 | Console per-base readiness aggregation | `console-backend` | `mimo` | `Console/commands/**` | Console 读取四个固定 JSON 文件并聚合，替换内置 observations |
| 6 | Independent validation | `validation` | `qwen` | 只读 | 验证四库输出、Console 聚合、fail closed、无回写、contract drift |

## 完整性复核

- 业务目的与 owner：已确认；各 Base 拥有自己的 readiness fact，Console 只读聚合。
- 对象粒度：已确认；`Base × Capability Pack × current readiness fact`。
- 稳定身份：已确认；`base + packId`。
- 字段与枚举：已确认；最小字段组和 `ready/pending/blocked/not_applicable`。
- 关系与基数：已确认；每个 Base 对每个目标 packId 一条当前 fact。
- 生命周期：首期不做历史和版本，只表达当前 fact。
- provenance：通过 repo-relative `evidenceRefs[]` 表达。
- 读入口：Console 读取四个固定 JSON 路径。
- 写入口：无 Console 写入，各 Base 自己维护。
- 验证、错误、降级：已确认；缺失、重复、损坏全部 fail closed。
- 兼容与 rollback：Console 可在后续任务中从四库文件聚合；若失败，任务不应落地而不是 silent fallback。
- 跨域影响：四库各自输出，Console 只读聚合；通过显式 contract 管理。
- Phase 分类：Per-base owner output / ReadModel source replacement，不是生产 API，不是历史事件系统。

## 已整体批准

本台账记录的是用户逐项确认后的结构方案，并已获得整体批准。

整体批准后，Controller 可以创建第一张实现任务：

```text
database / opencode / DataBase readiness fact output
```

如实施中出现新的字段、枚举、身份、持久化形态、历史结构、内部对象引用、Console 写入、刷新、审批、审计、回写或 HTTP endpoint 决策，必须暂停并回到结构确认。
