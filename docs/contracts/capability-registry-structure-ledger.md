# Capability Registry Read-only Seam 结构确认台账

## 状态

- 日期：2026-07-24
- 仓库：`/Users/huangbo/Dev/AgentHarness`
- Controller：`Codex / AgentHarness Controller`
- 状态：结构确认明细已完成，用户已整体批准
- 适用 Gate：AgentHarness `Structural Confirmation Gate`

本文记录 AgentHarness `Capability Registry` 第一期 read-only seam 的结构确认结果。
用户已于 2026-07-24 整体批准 D001-D010。后续实现只能覆盖本台账授权的范围；
实施中出现新的结构决定时必须暂停并回到结构确认。

## 范围

目标是在 AgentHarness 中定义一个最小只读 `Capability Registry` seam，
让 Console backend 能描述一条样板能力包，并为后续 pi-xanthil Host 消费契约提供权威基础。

第一期不实现真实发布、安装、license、distribution、Host adapter 或跨项目 pi-xanthil 修改。

## 当前证据

| 证据 | 约束 |
| --- | --- |
| `docs/prd-agentharness-four-bases-one-console-buildout.md` | 前端通过后，下一阶段是最小 `Capability Registry` read-only backend seam |
| `docs/task-briefs/console-workbench-pi-xanthil-experience-alignment.md` | AgentHarness 是 capability authority；pi-xanthil 是 Host consumer |
| `docs/pi-xanthil-capability-pack-discussion.md` | pi-xanthil 消费 capability pack，不直接消费 PLS 项目 |
| `docs/agentharness-four-bases-one-console-product-direction.html` | Stage 0 是 `Console + Capability Registry + Package / Release / License / Audit` 最小平台骨架 |
| `docs/contracts/README.md` | contract 必须说明对象、稳定身份、粒度、读写入口、错误、降级、兼容和验证 |
| `Console/commands/agentharness.mjs` | 当前 Console backend 只有 sample governance loop，不存在 Capability Registry seam |
| `Console/workbench-prototype/index.html` | 当前前端主对象为 `PLS Capability Pack`，并标注 `authority: AgentHarness · consumer: pi-xanthil Host` |

## 变更影响清单

| 变更项 | 权威域 | 当前状态 | 本次动作 | contract 是否受影响 | 需要派发的域 | 明确不修改的域 |
| --- | --- | --- | --- | --- | --- | --- |
| Capability Registry read-only seam | Console contract / Console backend | 不存在正式 seam | 先结构确认，再创建 backend read-only 任务 | 是 | 结构批准后派 `console-backend/mimo` | DataBase、OntoBase、KnowledgeBase、MemoryBase、pi-xanthil |
| 第一条样板能力包 | Console contract | 前端静态展示 `PLS Capability Pack` | 定义 registry 中的样板 pack 对象边界 | 是 | `console-backend/mimo` | 不迁移 PLS 项目或 pi-xanthil |
| Host consumer 状态 | Console contract / future consumption contract | 前端仅静态模拟 | 第一期只读描述，不建立真实 adapter | 是 | 本轮仅 Console backend | pi-xanthil 不修改 |

## 决策台账

| Sequence | Topic | Recommendation | Reason | User decision | Consistency | Status | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| D001 | Capability Registry 第一期业务对象边界 | 以 `Capability Pack` 为核心对象；第一条样板为 `PLS Capability Pack / PLS Reference Pack`；不直接暴露 PLS 项目、单个 tool、skill 或 database table | 与前端和商业化对象一致；pi-xanthil 消费能力包，不消费 AgentHarness 内部项目或表；后续可在 pack 内挂接 tool/skill/四库依赖 | A | 一致 | Confirmed | `Console/workbench-prototype/index.html`、`docs/pi-xanthil-capability-pack-discussion.md`、用户确认 2026-07-24 |
| D002 | 第一期读取面粒度与返回集合范围 | 支持 `listCapabilityPacks()` 与 `getCapabilityPack(packId)`；返回粒度都是 `Capability Pack`；第一期只内置/暴露一条样板包，但 shape 支持未来多包 | 正好支撑当前前端的能力列表和当前能力详情；比单条 `getPLSPack()` 更可扩展；避免过早展开 tool/skill/database/ontology 多域明细 | A | 一致 | Confirmed | `Console/workbench-prototype/index.html` 能力列表与详情区、用户确认 2026-07-24 |
| D003 | Capability Pack 稳定身份与命名策略 | 使用稳定机器身份 `packId = agentharness.pack.pls-reference`；展示名独立为 `displayName = PLS Capability Pack`，短名为 `shortName = PLS Reference Pack`；版本不进入 `packId` | 稳定身份不能依赖展示名；展示名未来可能商业化调整；`agentharness.pack.*` 明确表示 AgentHarness registry 权威身份，避免与 pi-xanthil 项目 ID 或四库内部对象 ID 混用 | A | 一致 | Confirmed | `docs/pi-xanthil-capability-pack-discussion.md`、当前前端展示名、用户确认 2026-07-24 |
| D004 | 第一期最小字段组 | `Capability Pack` 以 6 个最小业务字段组为主：`identity`、`status`、`summary`、`readiness`、`dependencies`、`hostConsumer`；第一期不纳入 `price/license/customerEntitlement/realInstallPath/realRuntimeEndpoint/toolManifest/skillManifest/packageArtifactUri/auditEvents[]` | 满足当前 UI 的能力包名称、状态、四库依赖、Host 状态和阻塞原因；避免过早触发 license、artifact、tool/skill manifest、audit event 等复杂商业化和跨域结构 | A | 一致 | Confirmed | `Console/workbench-prototype/index.html` 状态卡、四库依赖与 Host 面板、用户确认 2026-07-24 |
| D005 | 第一期状态枚举 | 采用最小保守枚举：`lifecycle=draft/evaluable/released/deprecated`；`releaseReadiness` 和 `distributionReadiness` 为 `blocked/ready/not_applicable`；`evaluationStatus=not_run/warning/passed/failed`；base dependency 为 `ready/pending/blocked/not_applicable`；Host 四类状态分别支持 `not_connected/simulated/.../blocked` 的最小集合 | 覆盖当前 UI，同时不承诺真实发布、安装或 adapter 已存在；区分 `not_connected` 与 `simulated`，避免原型状态被误读为真实接入；暂不固化复杂 state machine | A | 一致 | Confirmed | T0010/T0011 前端与验证 handoff、用户确认 2026-07-24 |
| D006 | 四库依赖引用方式 | `dependencies.bases[]` 只记录 Base 级依赖：`base`、`state`、`note`；不记录四库内部对象 ID、table、文件路径、schema 名或查询入口 | Console 不应把四库内部结构硬编码为自己的事实；Base 级依赖足够支撑当前 UI；具体 DataBase/OntoBase/KnowledgeBase/MemoryBase 引用后续需单独 contract 和结构确认 | A | 一致 | Confirmed | `docs/four-bases-one-console-contract.md`、`Console/workbench-prototype/index.html` 四库依赖面板、用户确认 2026-07-24 |
| D007 | 来源、provenance 与 demo/真实状态边界 | 增加轻量 `provenance` 字段组：`sourceKind=prototype/reference_pack/migrated_asset/released_pack`、`sourceRefs[]`、`dataBoundary=demo_only/read_only_reference/production_ready`；第一期样板为 `sourceKind=reference_pack`、`dataBoundary=demo_only` | 明确当前 pack 是样板/原型而非生产发布包；保留证据来源；避免把 provenance 扩张成完整 audit/lineage 系统 | A | 一致 | Confirmed | PRD、Capability Pack discussion、Console prototype、用户确认 2026-07-24 |
| D008 | 读入口、错误、空数据与 fail-closed 行为 | 第一期采用 CLI/command module read-only seam：`listCapabilityPacks()` 与 `getCapabilityPack(packId)`，命令形态为 `capability-packs:list` 和 `capability-packs:get <packId>`；registry 不可读失败，空 registry 返回空列表，未知 `packId` 返回 `not_found`，shape 无效返回 `validation_failed`，不 fallback 到默认包 | 当前 Console backend 是 command 形态，CLI seam 最小可验证；HTTP/API 待 pi-xanthil consumption contract 明确后再做；未知 pack 必须 fail closed，避免 Host 误消费 | A | 一致 | Confirmed | `Console/commands/agentharness.mjs` 当前命令形态、用户确认 2026-07-24 |
| D009 | 写入、发布、安装、license、audit 的本期排除边界 | 第一期严格只读；排除 `create/update/deleteCapabilityPack`、`runEvaluation`、`prepareRelease`、`publishRelease`、`installToHost`、`distributeToHost`、`syncHostFeedback`、`licenseCheck`、`entitlementCheck`、`auditEventWrite`、`packageArtifactBuild`、`toolManifestImport`、`skillManifestImport` 和 pi-xanthil adapter update | 当前目标是最小真实 read seam；写入、发布、安装、授权、审计都会触发状态机、权限、审计和跨项目 contract；前端操作按钮继续保持 prototype/simulated/blocked | A | 一致 | Confirmed | PRD 后续衔接、T0010/T0011 验证 handoff、用户确认 2026-07-24 |
| D010 | 实施授权范围、验证要求和后续任务拆分 | 结构整体批准后，串行拆成三项：`console-backend/mimo` 实现 read-only CLI seam；`console-ui/kilo` 接入 read seam；`validation/qwen` 独立验证 fail-closed、UI、边界和非写入范围 | 后端 contract 先稳定，再接前端，最后验证闭环；同一 worktree 默认串行，避免 UI/backend 同时修改造成 review 混乱 | A | 一致 | Confirmed | AgentHarness 路由表、前端先行 PRD、用户确认 2026-07-24 |

## 待确认项

无。全部适用确认项已完成，用户已整体批准。

## 派生结构方案

### 业务对象

第一期 `Capability Registry` 的核心业务对象是：

```text
Capability Pack
```

第一条样板记录：

```text
packId: agentharness.pack.pls-reference
displayName: PLS Capability Pack
shortName: PLS Reference Pack
```

该记录表示从 PLS 项目沉淀出的 reference capability pack，不表示 pi-xanthil 直接消费 PLS 项目，也不表示 AgentHarness 已经具备真实发布、安装或 Host adapter。

### 读取面

第一期只定义 read-only seam：

```text
listCapabilityPacks()
getCapabilityPack(packId)
```

命令形态：

```text
node Console/commands/agentharness.mjs capability-packs:list
node Console/commands/agentharness.mjs capability-packs:get agentharness.pack.pls-reference
```

### 最小字段 shape

```text
CapabilityPack
  identity
    packId
    displayName
    shortName
    version

  status
    lifecycle
    releaseReadiness
    distributionReadiness

  summary
    description
    authority
    consumer

  readiness
    evaluationStatus
    blockingReason
    lastCheckedAt

  dependencies
    bases[]
      base
      state
      note

  hostConsumer
    hostId
    hostName
    installState
    usageState
    feedbackState
    adapterState

  provenance
    sourceKind
    sourceRefs[]
      label
      path
      note
    dataBoundary
```

### 状态枚举

```text
lifecycle:
  draft
  evaluable
  released
  deprecated

releaseReadiness:
  blocked
  ready
  not_applicable

distributionReadiness:
  blocked
  ready
  not_applicable

evaluationStatus:
  not_run
  warning
  passed
  failed

base dependency state:
  ready
  pending
  blocked
  not_applicable

host installState:
  not_connected
  simulated
  installable
  installed
  blocked

host usageState:
  not_connected
  simulated
  usable
  blocked

host feedbackState:
  not_connected
  simulated
  receiving
  blocked

host adapterState:
  not_connected
  simulated
  connected
  blocked
```

第一期样板状态：

```text
lifecycle: evaluable
releaseReadiness: blocked
distributionReadiness: blocked
evaluationStatus: warning

DataBase: ready
OntoBase: ready
KnowledgeBase: pending
MemoryBase: pending

host adapterState: simulated
host installState: simulated
host usageState: simulated
host feedbackState: not_connected
```

### Provenance 边界

第一期样板：

```text
sourceKind: reference_pack
dataBoundary: demo_only
sourceRefs:
  - docs/prd-agentharness-four-bases-one-console-buildout.md
  - docs/pi-xanthil-capability-pack-discussion.md
  - Console/workbench-prototype/index.html
```

### Fail-closed 规则

```text
listCapabilityPacks()
  - registry 不存在或不可读：失败退出
  - registry 存在但为空：返回空列表
  - 单条 pack 无效：失败退出，reason = validation_failed

getCapabilityPack(packId)
  - packId 缺失：失败退出
  - packId 未知：失败退出，reason = not_found
  - pack shape 无效：失败退出，reason = validation_failed
  - 不 fallback 到默认 PLS pack
```

### 本期明确排除

```text
createCapabilityPack
updateCapabilityPack
deleteCapabilityPack
runEvaluation
prepareRelease
publishRelease
installToHost
distributeToHost
syncHostFeedback
licenseCheck
entitlementCheck
auditEventWrite
packageArtifactBuild
toolManifestImport
skillManifestImport
pi-xanthil adapter update
```

## 授权后的任务计划

整体批准后，Controller 按顺序创建 Task Bus 任务：

| Sequence | Task | Domain | Assignee | Allowed paths | 目标 |
| --- | --- | --- | --- | --- | --- |
| 1 | Capability Registry read-only backend seam | `console-backend` | `mimo` | `Console/commands/**` | 实现 `capability-packs:list/get`、样板包、shape validation 与 fail-closed |
| 2 | Console UI 接入 read-only seam | `console-ui` | `kilo` | `Console/workbench-prototype/**` | 从 registry seam 读取 pack 数据，保留操作模拟/受阻边界 |
| 3 | 独立验证 | `validation` | `qwen` | 无产品实现写入路径 | 验证 CLI fail-closed、UI、Host/authority 边界、响应式和非写入范围 |

## 未经新增结构确认不得实施

除本台账授权的 read-only CLI seam 外，不得：

- 在 `Console/commands/**` 之外实现 Capability Registry。
- 在 `Console/commands/**` 内实现超出 read-only CLI seam 的写入、发布、安装、授权或审计能力。
- 创建 registry data file、package manifest、HTTP API 或持久 store。
- 修改 `Console/workbench-prototype/**` 接入真实读取。
- 修改 pi-xanthil 仓库或创建跨项目 consumption contract。
