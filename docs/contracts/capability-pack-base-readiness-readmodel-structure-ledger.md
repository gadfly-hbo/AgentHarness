# Capability Pack Base Readiness ReadModel 结构确认台账

## 状态

- 日期：2026-07-24
- 仓库：`/Users/huangbo/Dev/AgentHarness`
- Controller：`Codex / AgentHarness Controller`
- 状态：结构确认明细已完成，用户已整体批准
- 适用 Gate：AgentHarness `Structural Confirmation Gate`

本文记录 AgentHarness 下一阶段 `Capability Pack Base Readiness ReadModel` 的结构确认结果。
该 ReadModel 的目的，是把当前 `Capability Registry` 中静态的 `dependencies.bases[]`
升级为可验证、可聚合、保持四库独立的 Base-level readiness 读取 seam。

用户已于 2026-07-24 整体批准 R001-R012。后续实现只能覆盖本台账授权的范围；
实施中出现新的结构决定时必须暂停并回到结构确认。

## 范围

本期只做 read-only readiness seam：

- 不新增 DataBase、OntoBase、KnowledgeBase、MemoryBase 的持久 schema、表、索引、文件结构或对象结构。
- 不新增 HTTP endpoint 或前端消费 shape。
- 不新增 Console 写入、自动刷新、审批、审计或回写四库。
- 不把四库内部 table、view、file、schema、object ID、runtime endpoint 或私有路径写入联合契约。
- 先在 Console backend 内置只读 ReadModel 中表达四库 readiness observation。
- 后续再逐个 Base 替换为各域真实 owner 输出。

## 当前证据

| 证据 | 约束 |
| --- | --- |
| `docs/prd-agentharness-four-bases-one-console-buildout.md` | 前端批准后先引入最小真实后端 seam；当前下一缺口是四库真实状态接入 |
| `docs/four-bases-one-console-contract.md` | 四库彼此独立，Console 是控制平面，不应硬编码四库内部事实 |
| `docs/contracts/capability-registry-structure-ledger.md` | 已批准 `CapabilityPack.dependencies.bases[]` 为 Base-level 依赖，不引用四库内部结构 |
| `docs/contracts/capability-registry-http-bridge-structure-ledger.md` | 已批准 HTTP shape 镜像 Capability Registry CLI seam，前端默认 HTTP API，fail closed |
| `.agentops/tasks/T0016-capability-registry-http-bridge-independent-validation/handoff.md` | 当前批次完成最小 HTTP bridge；剩余缺口包括四库真实状态接入 |
| `Console/commands/agentharness.mjs` | 当前 `dependencies.bases[]` 仍来自内置 pack 数据 |

## 变更影响清单

| 变更项 | 权威域 | 当前状态 | 本次动作 | contract 是否受影响 | 需要派发的域 | 明确不修改的域 |
| --- | --- | --- | --- | --- | --- | --- |
| Capability Pack Base Readiness ReadModel | Console contract / Controller | 不存在显式 ReadModel | 定义 Base-level readiness observation，并由 Console backend 只读聚合 | 是 | 结构批准后先派 `console-backend/mimo` | DataBase、OntoBase、KnowledgeBase、MemoryBase |
| `dependencies.bases[]` 来源 | Console backend | 直接写在内置 Capability Pack 中 | 改为由 `getCapabilityPackBaseReadiness(packId)` 派生 | 是 | `console-backend/mimo` | 不新增 HTTP endpoint，不改前端协议 |
| UI 文案表达 | Console UI | 展示四库依赖，但用户难以区分静态说明与 readiness seam | 最小调整为“来自 readiness read model”的表达 | 否，消费现有 shape | `console-ui/kilo` | 不改四库、不改 backend shape |
| 独立验证 | Validation | T0016 已验证 HTTP bridge | 验证 CLI/HTTP/UI 字段一致、无新增 endpoint、无四库 diff、fail-closed 仍成立 | 否，验证 contract 符合性 | `validation/qwen` | 产品实现文件 |

## 决策台账

| Sequence | Topic | Recommendation | Reason | User decision | Consistency | Status | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| R001 | 下一阶段结构范围 | 定义为 `Capability Pack Base Readiness ReadModel`，Console 只读取四库对某个 Capability Pack 的 Base-level 就绪状态 | 补上当前 `dependencies.bases[]` 静态描述缺口，同时不把 Console 变成四库内部事实宿主 | A | 一致 | Confirmed | 用户确认 2026-07-24；T0016 PRD refocus |
| R002 | ReadModel 业务 owner | contract 归 Console/Controller；每个 Base 的 readiness 事实 owner 仍归各自四库 | ReadModel 是联合视图，不是第五个事实库；保持四库独立和 owner 清晰 | A | 一致 | Confirmed | 用户确认 2026-07-24；`docs/four-bases-one-console-contract.md` |
| R003 | ReadModel 粒度 | `Capability Pack × Base × readiness observation` | 能表达“某个能力包依赖某个 Base 是否就绪”，比 pack 总状态更可审计，又不下钻到四库内部对象 | A | 一致 | Confirmed | 用户确认 2026-07-24 |
| R004 | 稳定身份 | 稳定业务键为 `packId + base`；实现层可另有 `observationId`，但不作为业务稳定身份 | `packId + base` 是最小、稳定、可读、可对齐的业务键；时间和内部对象不应进入稳定身份 | A | 一致 | Confirmed | 用户确认 2026-07-24；Capability Registry `packId` 已批准 |
| R005 | readiness 状态枚举 | 沿用 `ready / pending / blocked / not_applicable` | 兼容现有 `dependencies.bases[].state`，避免引入复杂状态机；pack 级 warning 仍保留在 `readiness.evaluationStatus` | A | 一致 | Confirmed | 用户确认 2026-07-24；`docs/contracts/capability-registry-structure-ledger.md` |
| R006 | ReadModel 字段组 | `packId / base / state / reason / observedAt / evidenceRefs[] / ownerDomain` | 足够支撑 Console 展示可验证四库状态，不提前引入评分、SLA、审批、审计、运行端点或内部对象绑定 | A | 一致 | Confirmed | 用户确认 2026-07-24 |
| R007 | 证据引用边界 | `evidenceRefs[]` 只允许 repo-relative 可复核引用，结构为 `label/path/note` | 允许 Console 展示原因和证据，但不把本机绝对路径、私有 endpoint 或四库内部结构变成联合契约事实 | A | 一致 | Confirmed | 用户确认 2026-07-24 |
| R008 | 写入边界 | 第一期严格 read-only；Console 不写、不刷新、不回写四库 | 避免过早触发权限、审批、审计、冲突解决和跨库回写问题 | A | 一致 | Confirmed | 用户确认 2026-07-24 |
| R009 | 读取入口形态 | 新增 backend 内部读取入口 `getCapabilityPackBaseReadiness(packId)`，并派生现有 `dependencies.bases[]` | 前端无需立即大改协议；backend 内部已从静态依赖升级为 readiness ReadModel | A | 一致 | Confirmed | 用户确认 2026-07-24 |
| R010 | 本期 HTTP API shape | 不新增 HTTP endpoint；只改变 `dependencies.bases[]` 的后端来源 | 避免同时扩 API 和 UI；保持 T0014/T0015/T0016 已验证的 HTTP shape | A | 一致 | Confirmed | 用户确认 2026-07-24 |
| R011 | 落地位置 | 第一期落在 Console backend 内置只读 ReadModel；不改四库持久结构 | 四库尚无统一 readiness 输出；先建显式 seam，再逐个 Base 替换为真实 owner 输出 | A | 一致 | Confirmed | 用户确认 2026-07-24 |
| R012 | 实施任务拆分 | 结构整体批准后，串行创建 `console-backend/mimo`、`console-ui/kilo`、`validation/qwen` 三张任务 | 后端 seam 先稳定，前端再表达，最后独立验证；符合域隔离和串行 worktree 规则 | A | 一致 | Confirmed | 用户确认 2026-07-24；AgentHarness routing |

## 派生结构方案

### 业务对象

本期新增的逻辑 ReadModel 记录为：

```text
CapabilityPackBaseReadinessObservation
```

业务含义：

```text
某个 Capability Pack 对某个 Base 的当前 readiness 观察结果。
```

第一期样板记录：

```text
agentharness.pack.pls-reference × DataBase
agentharness.pack.pls-reference × OntoBase
agentharness.pack.pls-reference × KnowledgeBase
agentharness.pack.pls-reference × MemoryBase
```

### 稳定身份与粒度

稳定业务键：

```text
packId + base
```

粒度：

```text
一个 Capability Pack × 一个 Base × 一个当前 readiness observation
```

`observationId` 可作为实现层生成值，但不作为业务稳定身份，也不得替代 `packId + base`。

### 最小字段 shape

```text
CapabilityPackBaseReadinessObservation
  packId
  base
  state
  reason
  observedAt
  evidenceRefs[]
    label
    path
    note
  ownerDomain
```

### 字段语义

| 字段 | 含义 | 约束 |
| --- | --- | --- |
| `packId` | Capability Pack 稳定身份 | 必须引用已批准 Capability Registry `packId` |
| `base` | 四库之一 | `DataBase / OntoBase / KnowledgeBase / MemoryBase` |
| `state` | Base-level readiness 状态 | `ready / pending / blocked / not_applicable` |
| `reason` | 面向 Console 和用户的简短业务原因 | 字符串；不得包含私有路径、连接串或内部对象泄露 |
| `observedAt` | 状态观察时间 | ISO 8601 字符串 |
| `evidenceRefs[]` | 可复核证据引用 | 只允许 repo-relative `label/path/note` |
| `ownerDomain` | readiness 事实 owner | `database / ontobase / knowledgebase / memorybase` |

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

### 读取入口

Console backend 内部新增 read-only 入口：

```text
getCapabilityPackBaseReadiness(packId)
```

返回：

```text
CapabilityPackBaseReadinessObservation[]
```

随后现有 `CapabilityPack.dependencies.bases[]` 由 observation 派生：

```text
dependencies.bases[]
  base   <- observation.base
  state  <- observation.state
  note   <- observation.reason
```

### HTTP/API 边界

本期不新增 HTTP endpoint。

保持现有 endpoint：

```text
GET /api/capability-packs
GET /api/capability-packs/:packId
```

HTTP response shape 仍镜像已批准的 Capability Pack shape；变化只在后端数据来源：

```text
dependencies.bases[] 从 ReadModel 派生，而不是直接写在内置 pack 对象里。
```

### 写入与刷新边界

本期无写入入口：

```text
create/update/delete readiness: 不做
Console override readiness: 不做
Console auto refresh and write-back: 不做
approval/audit write: 不做
```

四库 readiness 事实后续由各域任务在各自 allowed paths 内产出或维护；Console 只读聚合。

### Evidence refs 边界

允许：

```text
docs/**
.agentops/tasks/<task>/handoff.md
.agentops/tasks/<task>/review.md
DataBase/docs/**
OntoBase/*.md
KnowledgeBase/**
MemoryBase/schema/**
```

前提是 repo-relative、可复核、不会泄露私有路径或内部未公开运行端点。

禁止：

```text
/Users/... 绝对路径
~/Desktop/... 本机路径
数据库连接串
私有 runtime endpoint
四库内部未公开 table/view/file/schema/object ID 作为联合契约字段
pi-xanthil 私有 adapter endpoint
```

## 非目标

- 不新增四库持久结构。
- 不新增 HTTP endpoint。
- 不新增生产 API。
- 不新增 pi-xanthil consumption contract。
- 不修改 pi-xanthil。
- 不实现 release、distribution、license、audit、evaluation backend。
- 不允许 Console 写入、覆盖、刷新或回写四库 readiness。
- 不把四库内部实现细节硬编码进 Console。

## 验证要求

### 后端任务验证

至少验证：

```bash
node --check Console/commands/agentharness.mjs
node Console/commands/agentharness.mjs capability-packs:list
node Console/commands/agentharness.mjs capability-packs:get agentharness.pack.pls-reference
node Console/commands/agentharness.mjs console-server --port 4177
curl -sS http://127.0.0.1:4177/api/capability-packs
curl -sS http://127.0.0.1:4177/api/capability-packs/agentharness.pack.pls-reference
```

并证明：

- `dependencies.bases[]` 由 `getCapabilityPackBaseReadiness(packId)` 派生。
- CLI 与 HTTP 关键字段一致。
- 未新增 HTTP endpoint。
- 未新增写入、刷新、审批、审计或回写。
- 未修改 DataBase、OntoBase、KnowledgeBase、MemoryBase。

### 前端任务验证

至少验证：

- 页面仍默认从 HTTP API 加载。
- 页面能表达四库依赖来自 readiness read model，而不是静态说明。
- `?registryMode=snapshot` 显式开发模式仍可用。
- API 404、network error、invalid JSON、invalid shape 仍 fail closed。
- 桌面与移动端无横向溢出。

### 独立验证任务

Qwen 只读验证：

- CLI/HTTP/UI 字段一致。
- 无新增 endpoint。
- 无四库 diff。
- 无 pi-xanthil diff。
- fail-closed 语义未退化。
- task diff 符合 allowed paths。

## 任务拆分计划

| Sequence | Task | Domain | Assignee | Allowed paths | Objective |
| --- | --- | --- | --- | --- | --- |
| 1 | Capability Pack Base Readiness backend seam | `console-backend` | `mimo` | `Console/commands/**` | 实现 `getCapabilityPackBaseReadiness(packId)`，并由其派生 `dependencies.bases[]` |
| 2 | Console Readiness ReadModel UI expression | `console-ui` | `kilo` | `Console/workbench-prototype/**` | 最小调整 UI 文案和展示，让用户看出四库依赖来自 readiness read model |
| 3 | Independent validation | `validation` | `qwen` | 只读 | 验证 CLI/HTTP/UI、无新增 endpoint、无四库 diff、fail-closed |

## 完整性复核

- 业务目的与 owner：已确认；contract 归 Console/Controller，各 Base 拥有自己的 readiness 事实。
- 对象粒度：已确认；`Capability Pack × Base × readiness observation`。
- 稳定身份：已确认；`packId + base`。
- 字段与枚举：已确认；最小字段组和 `ready/pending/blocked/not_applicable`。
- 关系与基数：已确认；每个 pack 对每个 Base 一条当前 observation。
- 生命周期：本期不做状态机；只表达当前 observation。
- provenance：通过 repo-relative `evidenceRefs[]` 表达。
- 读入口：已确认；内部 `getCapabilityPackBaseReadiness(packId)`。
- 写入口：无。
- 验证、错误、降级：沿用 Capability Registry HTTP bridge 的 fail-closed 语义。
- 兼容与 rollback：不新增 HTTP shape；可回退到前一版内置 dependencies。
- 跨域影响：本期实现只落 Console backend/UI/validation；四库不改。
- Phase 分类：ReadModel seam / supporting structure，不是生产 API，不是四库持久结构。

## 已整体批准

本台账记录的是用户逐项确认后的结构方案，并已获得整体批准。

整体批准后，Controller 可以创建第一张实现任务：

```text
console-backend / mimo / Capability Pack Base Readiness backend seam
```

如实施中出现新的 endpoint、field、enum、身份、持久化、四库内部引用、写入、刷新、审批、审计、pi-xanthil adapter 或 production contract 决策，必须暂停并回到结构确认。
