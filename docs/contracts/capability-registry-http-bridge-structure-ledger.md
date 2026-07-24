# Capability Registry Local HTTP Bridge 结构确认台账

## 状态

- 日期：2026-07-24
- 仓库：`/Users/huangbo/Dev/AgentHarness`
- Controller：`Codex / AgentHarness Controller`
- 状态：结构确认明细已完成，用户已整体批准
- 适用 Gate：AgentHarness `Structural Confirmation Gate`

本文记录 AgentHarness `Capability Registry` 本地 read-only HTTP bridge 的结构确认结果。
该 bridge 的目的，是把已批准的 T0012 CLI read-only seam 接到浏览器前端，结束 `Console/workbench-prototype` 只能消费静态 snapshot 的状态。

用户已于 2026-07-24 整体批准 H001-H007。后续实现只能覆盖本台账授权的范围；
实施中出现新的结构决定时必须暂停并回到结构确认。

## 范围

本期只实现本地开发用 read-only HTTP bridge：

- 不新增持久化。
- 不新增 registry JSON data file。
- 不新增 SQLite、package manifest、license state machine、audit event store 或 pi-xanthil adapter。
- 不新增新的 `CapabilityPack` 字段、枚举、`packId`、四库内部引用或跨库对象身份。
- HTTP 输出 shape 必须镜像 T0012 CLI seam。
- 前端默认使用 HTTP API；snapshot 只作为显式开发入口。

## 当前证据

| 证据 | 约束 |
| --- | --- |
| `docs/prd-agentharness-four-bases-one-console-buildout.md` | 前端批准后，下一阶段是最小 `Capability Registry` read path |
| `docs/contracts/capability-registry-structure-ledger.md` | 已批准 T0012 CLI read-only seam、对象 shape、枚举、fail-closed 语义 |
| `Console/commands/agentharness.mjs` | 已实现 `capability-packs:list` 和 `capability-packs:get <packId>` |
| `Console/workbench-prototype/js/registry-client.js` | 当前前端仍以静态 snapshot / adapter 桥接 registry shape |
| `.agentops/tasks/T0012-capability-registry-readonly-cli-seam/review.md` | T0012 已 approved |
| `.agentops/tasks/T0013-console-workbench-connect-readonly-registry/review.md` | T0013 已 approved；snapshot 与 CLI 对齐，但仍非真实后端连接 |

## 变更影响清单

| 变更项 | 权威域 | 当前状态 | 本次动作 | contract 是否受影响 | 需要派发的域 | 明确不修改的域 |
| --- | --- | --- | --- | --- | --- | --- |
| Local HTTP bridge | Console contract / Console backend | 不存在 HTTP bridge | 新增本地 read-only HTTP endpoint 与静态文件服务入口 | 是 | `console-backend/mimo` | DataBase、OntoBase、KnowledgeBase、MemoryBase、pi-xanthil |
| Frontend registry client 默认数据源 | Console UI | 默认使用静态 snapshot | 后续改为默认 fetch HTTP API，snapshot 仅显式开发模式 | 是 | `console-ui/kilo` | Console backend 之外其他域 |
| 独立验证 | Validation | T0013 已验证静态 snapshot | 后续验证真实 HTTP API、UI fail-closed、无写入越界 | 否，验证 contract 符合性 | `validation/qwen` | 产品实现文件 |

## 决策台账

| Sequence | Topic | Recommendation | Reason | User decision | Consistency | Status | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| H001 | HTTP bridge 范围 | 只做本地开发用 read-only HTTP bridge，镜像 T0012 CLI 输出；不新增字段、不新增持久化、不做 pi-xanthil adapter、不做发布/安装/授权/审计 | 解决“前端仍是本地静态、未连接后端”的问题，同时避免扩大到 production API 或 pi-xanthil 集成 | A | 一致 | Confirmed | 用户确认 2026-07-24；T0012/T0013 approved |
| H002 | HTTP bridge 读入口 | 提供 `GET /api/capability-packs` 与 `GET /api/capability-packs/:packId` 两个只读 endpoint | 与已批准的 CLI seam `list/get` 粒度一致，能支持当前能力列表与详情区 | A | 一致 | Confirmed | 用户确认 2026-07-24；D002/D008 |
| H003 | HTTP bridge 数据来源 | HTTP bridge 直接复用 T0012 的同一份 in-memory registry / command module 逻辑作为单一权威数据源；不新增 JSON、SQLite 或 manifest | 避免 CLI、HTTP、frontend snapshot 三份数据 drift；T0013 snapshot 不能反向成为后端权威 | A | 一致 | Confirmed | 用户确认 2026-07-24；T0013 review |
| H004 | HTTP 错误与 fail-closed 语义 | HTTP bridge 严格镜像 CLI fail-closed：unknown pack 为 404；invalid shape 为 500；registry unavailable 为 500；method not allowed 为 405；前端非 2xx 或 shape 不合法必须 fail closed | 避免 Host 或 Console 在错误时误消费默认包；与 T0012 fail-closed 一致 | A | 一致 | Confirmed | 用户确认 2026-07-24；D008 |
| H005 | 本地启动方式 | 在 `Console/commands/**` 内实现本地 dev server 启动入口，例如 `node Console/commands/agentharness.mjs console-server --port 4177`，同时服务静态前端与 `/api/**` | 最小一键启动体验；不新增后端目录边界；符合 `console-backend` allowed path | A | 一致 | Confirmed | 用户确认 2026-07-24；AgentHarness domain routing |
| H006 | 前端 fallback 策略 | 前端主数据源改为 HTTP API；仅 `?registryMode=snapshot` 显式开发参数允许使用 snapshot；默认 API 失败必须 fail closed | 保证真实后端优先，同时保留离线调试入口；避免自动 fallback 掩盖后端失败 | A | 一致 | Confirmed | 用户确认 2026-07-24；T0013 fail-closed 验证 |
| H007 | 实施拆分 | 串行三张任务：`console-backend/mimo` 实现 HTTP bridge；`console-ui/kilo` 接 HTTP API；`validation/qwen` 独立验证 | 后端 endpoint contract 先稳定，前端再接，最后独立验证；符合域隔离与串行 worktree 原则 | A | 一致 | Confirmed | 用户确认 2026-07-24；AgentHarness AGENTS |

## 派生结构方案

### 本地启动入口

建议命令形态：

```text
node Console/commands/agentharness.mjs console-server --port 4177
```

允许服务范围：

```text
Console/workbench-prototype/index.html
Console/workbench-prototype/css/**
Console/workbench-prototype/js/**
Console/workbench-prototype/*.png
/api/capability-packs
/api/capability-packs/:packId
```

不得服务仓库任意路径；静态文件服务必须限制在 `Console/workbench-prototype` 下。

### HTTP 读取面

```text
GET /api/capability-packs
GET /api/capability-packs/:packId
```

响应 shape 必须镜像：

```text
node Console/commands/agentharness.mjs capability-packs:list
node Console/commands/agentharness.mjs capability-packs:get <packId>
```

不得新增 HTTP-only 字段。若需要 envelope，必须保持可验证且不改变 `CapabilityPack` 业务对象 shape；实现任务应优先选择最小 envelope 或直接 body，并在 handoff 中说明。

### HTTP 错误语义

```text
unknown packId
  -> HTTP 404
  -> { error: "not_found", packId }

invalid registry shape
  -> HTTP 500
  -> { error: "validation_failed", details }

backend/registry unavailable
  -> HTTP 500
  -> { error: "registry_unavailable" }

method not allowed
  -> HTTP 405
  -> { error: "method_not_allowed" }
```

前端收到任何非 2xx、非 JSON、缺字段或 shape 不合法结果，必须进入 fail-closed 状态，不得自动 fallback 到 snapshot。

### 前端 fallback 策略

默认：

```text
HTTP API -> 正常渲染
HTTP API failure -> fail closed
```

显式开发模式：

```text
?registryMode=snapshot
```

只有在该参数存在时，前端才允许使用 T0013 的静态 snapshot。

### 非目标

- 不实现 production API。
- 不建立 pi-xanthil consumption contract。
- 不修改 pi-xanthil。
- 不实现真实 install、release、distribution、license、audit、evaluation backend。
- 不新增 `DataBase`、`OntoBase`、`KnowledgeBase`、`MemoryBase` 结构或读取。
- 不把四库内部 table、file、schema、endpoint 硬编码到 Console。

## 验证要求

### 后端任务验证

至少验证：

```bash
node Console/commands/agentharness.mjs capability-packs:list
node Console/commands/agentharness.mjs capability-packs:get agentharness.pack.pls-reference
node Console/commands/agentharness.mjs console-server --port 4177
curl -sS http://127.0.0.1:4177/api/capability-packs
curl -sS http://127.0.0.1:4177/api/capability-packs/agentharness.pack.pls-reference
curl -sS -i http://127.0.0.1:4177/api/capability-packs/missing.pack
```

并证明 CLI 与 HTTP 在关键字段上一致：

- `identity.packId`
- `status.lifecycle`
- `dependencies`
- `hostConsumer`
- `provenance.sourceKind`
- `provenance.dataBoundary`

### 前端任务验证

至少验证：

- 默认页面从 HTTP API 加载，不再默认使用 snapshot。
- `?registryMode=snapshot` 可以显式进入 snapshot 模式。
- API 失败、404、invalid JSON 或 shape 缺失时 fail closed。
- fail-closed 不展示旧默认 PLS 数据。
- 桌面与移动端无横向溢出。

### 独立验证任务

Qwen 独立验证：

- 一键启动是否可用。
- API 正常态、404、405、后端不可用路径是否符合台账。
- 前端默认是否真实连接 HTTP。
- 前端是否禁止自动 fallback。
- 是否无写入、无发布、无安装、无授权、无审计、无 pi-xanthil 修改。

## 任务拆分计划

| Sequence | Task | Domain | Assignee | Allowed paths | Objective |
| --- | --- | --- | --- | --- | --- |
| 1 | Local HTTP bridge | `console-backend` | `mimo` | `Console/commands/**` | 实现本地 read-only HTTP bridge 与静态文件服务入口 |
| 2 | Frontend HTTP client | `console-ui` | `kilo` | `Console/workbench-prototype/**` | 前端默认 fetch HTTP API，snapshot 仅显式开发模式 |
| 3 | Independent validation | `validation` | `qwen` | 只读 | 验证 API、UI、fail-closed、无写入越界 |

## 完整性复核

- 业务目的与 owner：已确认，Console 本地 read-only bridge。
- 对象粒度：沿用 `CapabilityPack`，不新增对象。
- 稳定身份：沿用 `packId = agentharness.pack.pls-reference`，不新增身份规则。
- 字段与枚举：沿用 T0012 台账，不新增字段或枚举。
- 关系与基数：沿用 `CapabilityPack` list/get；第一期样板一条，shape 支持未来多包。
- 生命周期：沿用 T0012 `status` / `readiness`。
- provenance：沿用 T0012 `provenance`。
- 读入口：新增本地 HTTP read-only endpoint；CLI 保持。
- 写入口：无。
- 验证、错误、降级：已定义 HTTP status 与 fail-closed。
- 兼容与 rollback：可回退到 CLI seam；前端保留显式 snapshot 开发模式。
- 跨域影响：仅 Console backend、Console UI、validation；不修改四库或 pi-xanthil。
- Phase 分类：本地 read-only bridge / ReadModel delivery，不是 production API。

## 批次收口规则

本批次三项任务全部 approved 后，Controller 必须自动回到产品 PRD：

- 对照 `docs/prd-agentharness-four-bases-one-console-buildout.md` 复核本批次交付解决了哪些 PRD 目标。
- 明确仍未覆盖的 PRD 目标、商业化路径缺口和下一阶段推进方向。
- 向用户输出下一步推进计划，而不是只报告任务完成。

该规则来自用户在 2026-07-24 的补充要求：“一组任务完成后，自动对焦产品prd，告诉用户下一步推进计划，作为实施开发的规则”。

## 已整体批准

本台账记录的是用户逐项确认后的结构方案，并已获得整体批准。

整体批准后，Controller 可以创建第一张实现任务：

```text
T0014 / console-backend / mimo / Local HTTP bridge
```

如实施中出现新的 endpoint、field、enum、身份、持久化、写入、pi-xanthil adapter 或 production contract 决策，必须暂停并回到结构确认。
