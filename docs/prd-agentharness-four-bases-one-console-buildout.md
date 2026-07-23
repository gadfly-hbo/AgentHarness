# PRD：AgentHarness 四库一台前端先行建设

## Problem Statement

AgentHarness 的长期方向已经明确为“四库一台”：`DataBase`、`OntoBase`、`MemoryBase`、`KnowledgeBase`、`Console`。这些能力原本来自 `pi-xanthil` 产品内部，后续需要独立成为后台能力中台，并让 `pi-xanthil` 弱化为产品 Host、工作区 Host、用户交互 Host 和 capability 安装运行 Host。

当前风险是：如果直接从后端 schema、目录拆迁或各库实现开工，容易出现五个模块各自生长、产品形态不可见、商业化边界不清、后续阶段失去推进顺序的问题。

## Solution

采用前端先行的产品开发原则：先建设一个可视化的 `AgentHarness Console - Capability Workbench`，让用户先看见 AgentHarness 作为后台能力中台的产品形态，再逐步接入最小真实后端闭环。

第一阶段不创建新的持久化 schema，不迁移真实生产资产，不接入复杂后端。先用明确标注的静态/临时展示数据表达以下产品判断：

- 四库一台如何被组织。
- `Capability Registry`、`Package`、`Release`、`Distribution`、`License`、`Audit` 如何支撑商业化。
- `pi-xanthil` 如何从能力权威方转为消费方。
- 哪些 pi-xanthil 资产适合迁移到 AgentHarness，哪些应保留在 pi-xanthil。
- `DataBase`、`OntoBase`、`KnowledgeBase` 如何优先商业化，`MemoryBase` 如何作为反馈与治理闭环逐步进入。

## User Stories

1. As a product owner, I want to open one AgentHarness Console page, so that I can immediately understand the four bases and one console product shape.
2. As a product owner, I want to see DataBase, OntoBase, KnowledgeBase, MemoryBase, and Console in one capability map, so that I can confirm their boundaries before implementation.
3. As a product owner, I want to see which modules are commercial upgrade modules, so that I can reason about packaging and pricing.
4. As a product owner, I want to see `pi-xanthil` as a consuming Host, so that I can verify that AgentHarness is not just another product tab.
5. As a product owner, I want to see a `PLS Capability Pack` example, so that I can evaluate the first vertical slice.
6. As a product owner, I want to see capability status such as draft, evaluating, released, installed, and upgrade required, so that the lifecycle is concrete.
7. As a product owner, I want to see which pi-xanthil assets are migration candidates, so that the extraction path is explicit.
8. As a product owner, I want to see which pi-xanthil assets remain product-side, so that the product does not lose user experience.
9. As a product owner, I want to review frontend flow before backend schema work, so that we avoid building invisible structures too early.
10. As a product owner, I want later backend work to attach to an approved visual flow, so that each phase has a clear target.
11. As a Console maintainer, I want capability cards to carry registry, release, distribution, license, and audit signals, so that the Console is a governance plane rather than a static dashboard.
12. As a Console maintainer, I want tool/skill experiment areas represented in the workbench, so that pi-xanthil runtime use can be separated from AgentHarness capability governance.
13. As a future pi-xanthil integrator, I want the workbench to show install/use/feedback states, so that pi-xanthil consumption responsibilities are clear.
14. As a future backend implementer, I want a clear frontend acceptance target, so that the first real API can be scoped to the minimum useful contract.
15. As a future validator, I want screenshots and interaction paths, so that visual and workflow validation can happen before deeper backend implementation.

## Implementation Decisions

- The first implementation surface is `AgentHarness Console - Capability Workbench`.
- The first implementation is frontend-only or frontend-dominant and must not introduce durable schema, migrations, persistent contracts, or cross-base storage changes.
- The workbench should show six main areas: four-bases-one-console capability map, capability list, PLS pack detail, experiment/eval status, release/distribution status, and pi-xanthil consumption status.
- Static data is allowed only if visibly scoped as prototype/demo data and does not invent final persistent IDs, enums, pricing, database fields, or irreversible contracts.
- The first real backend after frontend approval should be a minimum `Capability Registry` read path, not a full implementation of all five modules.
- `harness-packs` from pi-xanthil is treated as the first major migration candidate for AgentHarness packages.
- `server/tools/registry.ts` and `server/tools/*` from pi-xanthil are treated as Tool Registry / Console governance migration candidates.
- `agentharness-port.ts` from pi-xanthil is treated as a candidate for AgentHarness-owned canonical consumption contract, with pi-xanthil retaining client/adapter responsibility.
- Memory runtime injection remains product-side in pi-xanthil; MemoryBase owns governance, aging, deduplication, consolidation, promotion, and evaluation.
- Knowledge retrieval and ontology validation/export/extraction can be reused as capability cores, but pi-xanthil workspace/database bindings must not be hard-copied into AgentHarness.
- Any future persistent structure, schema, contract, license state machine, package manifest, or cross-base identity change must go through `agentharness-structure-grill` and user approval before implementation.

## Testing Decisions

- The first task should be tested through the user-visible interface, not internal implementation details.
- Frontend validation should include desktop and narrow viewport checks.
- Validation should confirm that the workbench communicates module boundaries, capability lifecycle, pi-xanthil consumption, and migration candidates without requiring backend data.
- Validation should check that prototype/demo data is visibly marked and does not appear to be a committed contract.
- No backend tests are required for the first frontend-only task unless the worker introduces runtime logic that needs a smoke check.
- When a real backend capability registry is later introduced, contract tests must validate allowed states, failure modes, unknown capability behavior, and fail-closed handling.

## Out of Scope

- Building real DataBase, OntoBase, KnowledgeBase, MemoryBase, or Console persistence.
- Migrating pi-xanthil assets in this first frontend workbench task.
- Implementing license enforcement, release approvals, package installation, or pi-xanthil runtime integration.
- Creating final package manifest schema or canonical AgentHarness consumption contract.
- Removing or weakening pi-xanthil existing modules.
- Connecting paid module purchase flows.
- Launching external CLI workers directly from Codex.

## Further Notes

The first visible milestone is not “AgentHarness backend is done.” The first milestone is: the user can open the Console workbench and decide whether the product shape, lifecycle, module boundaries, and pi-xanthil migration story are correct.

After that milestone is approved, the next phase should introduce the smallest real backend seam: a read-only capability registry that can describe one `PLS Capability Pack` and later be consumed by pi-xanthil.
