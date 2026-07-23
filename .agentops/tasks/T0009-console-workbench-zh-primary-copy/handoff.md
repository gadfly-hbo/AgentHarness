# Handoff: T0009 Console Workbench Chinese-Primary Copy

## What Changed

- Updated `Console/workbench-prototype/index.html` so the visible UI is Simplified Chinese-first while preserving product and technical terms such as `AgentHarness`, `pi-xanthil`, `DataBase`, `OntoBase`, `KnowledgeBase`, `MemoryBase`, `Console`, `Host`, `adapter/client`, and `Capability Pack` where appropriate.
- Localized the main operational workflow copy:
  - Sidebar navigation: `能力工作台`, `工具 / Skills`, `能力包`, `实验评估`, `发布管理`, `Host 接入`, `审计`.
  - Topbar: `能力工作台`, `管理能力就绪度`, `主机分发`, `本地静态原型`, `未连接后端`.
  - Capability list, current capability details, status cards, lifecycle checklist, migration boundary, action rail, dependency inspector, and audit trail.
- Updated `Console/workbench-prototype/js/app.js` dynamic state and interaction feedback to Chinese-first copy:
  - `运行评估` feedback transitions to `评估成功...`.
  - `准备发布` feedback transitions to `发布准备完成...`.
  - `分发到 pi-xanthil` feedback reports `分发受阻...`.
  - `打开审计` feedback reports `审计已打开...`.
- Kept T0008 operational UI structure intact: app shell, capability table, selected object, action rail, dependency inspector, and audit panel remain in place.
- Made a small responsive copy-support CSS adjustment in `Console/workbench-prototype/css/styles.css` so Chinese navigation labels can wrap at narrow widths.
- Regenerated `desktop-screenshot.png` and `mobile-screenshot.png`.

## Files Changed

- `Console/workbench-prototype/index.html`
- `Console/workbench-prototype/css/styles.css`
- `Console/workbench-prototype/js/app.js`
- `Console/workbench-prototype/desktop-screenshot.png`
- `Console/workbench-prototype/mobile-screenshot.png`

`Console/workbench-prototype/start.command` remains unchanged and was syntax-checked.

## Validation

- Static copy grep:
  - Core Chinese terms found in source: `能力工作台`, `能力列表`, `当前能力`, `运行评估`, `准备发布`, `分发到 pi-xanthil`, `打开审计`, `四库依赖`, `迁移边界`, `未连接后端`.
  - Forbidden English primary-heading leftovers not found: `Manage capability readiness`, `Selected workspace`, `Four-base dependencies`, `Ready for prototype action`.
- Browser smoke via Google Chrome headless and DevTools Protocol against `http://127.0.0.1:4178/index.html`:
  - `desktop-1440x1100 PASS`
  - `mobile-layout-390x844 PASS`
  - Verified Chinese core copy is present and forbidden English primary headings are absent.
  - Verified interaction feedback in Chinese:
    - `运行评估` -> `评估成功：PLS Capability Pack 已满足准备发布条件。此状态仅为原型模拟。`
    - `准备发布` -> `发布准备完成：分发仍需确认 Host adapter 检查点。`
    - `分发到 pi-xanthil` -> `分发受阻：pi-xanthil Host 消费仍是模拟状态，未连接真实 Host adapter。`
    - `打开审计` -> `审计已打开：下方显示紧凑的演示证据。`
  - Verified no collected `Runtime.exceptionThrown` or Chrome error log entries.
  - Verified desktop `documentScrollWidth=1440`, `bodyScrollWidth=1440`, `viewportWidth=1440`.
  - Verified mobile `documentScrollWidth=390`, `bodyScrollWidth=390`, `viewportWidth=390`.
  - Verified screenshot-visible containers fit in mobile viewport: `.sidebar`, `.topbar`, `.capability-list-panel`, `.selected-object`, and `.action-panel` all fit within `0..390`.
- Screenshot generation:
  - Desktop: Chrome headless wrote `267303 bytes` to `Console/workbench-prototype/desktop-screenshot.png`.
  - Mobile: Chrome headless wrote `50203 bytes` to `Console/workbench-prototype/mobile-screenshot.png`.
- Technical checks:
  - `git diff --check -- "Console/workbench-prototype/index.html" "Console/workbench-prototype/css/styles.css" "Console/workbench-prototype/js/app.js" "Console/workbench-prototype/start.command"` passed with no output.
  - `zsh -n "Console/workbench-prototype/start.command"` passed with no output.

## Risks

- This remains a static prototype with demo data only. The Chinese copy does not imply real backend, real registry, real migration scan, or real Host adapter connectivity.
- Validation used port `4178` because port `4177` was already occupied by an external process not tracked as an active Kilo background process. `start.command` still defaults to `4177` and supports `AGENTHARNESS_WORKBENCH_PORT=4178` per its existing output.
- English remains where it is a product name or technical term, by brief design.

## Open Questions

- None for this scoped UI copy task.

## Copy Policy Applied

- Simplified Chinese is now the primary reading language for user-facing UI copy.
- English was retained only for:
  - Product and project names: `AgentHarness`, `pi-xanthil`.
  - Four-base names: `DataBase`, `OntoBase`, `KnowledgeBase`, `MemoryBase`, `Console`.
  - Technical surface terms where the English identifier is meaningful in product discussions: `Host`, `adapter/client`, `Registry`, `Skill`, `Capability Pack`.
  - Existing capability names: `PLS Capability Pack`, `SQL Generator`, `Doc Searcher`, `Code Architect`.
- Prototype boundaries remain explicit in Chinese: `本地静态原型`, `原型演示数据`, `不会调用真实后端`, `未连接后端`, `未连接真实 Host adapter`.
- Copy was kept concise and operational; the page did not revert to long-form explanatory prose.

## Evidence Map

- 是否已改为简体中文主语言: `index.html` contains Chinese-first navigation, topbar, table, detail, action, dependency, migration, and audit copy; `js/app.js` contains Chinese dynamic feedback.
- 英文保留范围是否合理: retained English is limited to product names, four-base names, capability names, and technical terms listed under Copy Policy Applied.
- T0008 operational UI 是否保留: `index.html` still contains `.workspace`, `.capability-table`, `.selected-object`, `.action-rail`, dependency inspector, and audit panel.
- 核心按钮和反馈是否中文化: `index.html` buttons contain `运行评估`, `准备发布`, `分发到 pi-xanthil`, `打开审计`; `js/app.js` feedback contains `评估成功`, `发布准备完成`, `分发受阻`, `审计已打开`.
- desktop 截图是否完成: `Console/workbench-prototype/desktop-screenshot.png`, Chrome output `267303 bytes written`.
- mobile 截图是否完成且无裁切: `Console/workbench-prototype/mobile-screenshot.png`, Chrome output `50203 bytes written`; mobile smoke verified `documentScrollWidth=390`, `bodyScrollWidth=390`, and visible containers fit within viewport.
- `start.command` 是否仍可用: `zsh -n "Console/workbench-prototype/start.command"` passed; file content unchanged.
- allowed paths 是否合规: changed prototype implementation/screenshot files are under `Console/workbench-prototype/**`; Task Bus handoff metadata is under `.agentops/tasks/T0009-console-workbench-zh-primary-copy/`.

## Screenshots

- Desktop: `Console/workbench-prototype/desktop-screenshot.png`
- Mobile: `Console/workbench-prototype/mobile-screenshot.png`

## Constraint Matrix

| Brief bullet | Invariant family | Authority | Implementation path | Positive evidence | Negative evidence | Waiver/blocker |
| --- | --- | --- | --- | --- | --- | --- |
| Work only inside allowed frontend scope | Scope | `brief.md` allowed_paths | `Console/workbench-prototype/**` | `git status --short` shows changed prototype files plus Task Bus dirs | No changes to `DataBase/**`, `OntoBase/**`, `docs/**`, `Console/commands/**` | None |
| No contract/persistence/API/read model/concurrency/audit work | Scope | `brief.md` non-goals | Static HTML/CSS/JS copy and screenshots only | Changed files are static prototype assets | No backend/API/schema files changed | None |
| Chinese-first visible UI copy | Copy | `brief.md` Required Changes / Copy Rules | `index.html`, `js/app.js` | Static grep found required Chinese terms | Static grep found no forbidden English primary-heading leftovers | None |
| Preserve operational UI | UI structure | T0008 approved structure and T0009 non-goals | `index.html` | Browser smoke found capability workflow and action labels | No redesign beyond copy and small responsive nav wrapping | None |
| Responsive and no clipping/overflow | Responsive UI | `brief.md` validation / memory guardrail | `styles.css` and screenshots | CDP mobile 390 scrollWidth checks and visible container checks passed | No collected Chrome errors | None |

## Memory Used

- `Match visual assertions to screenshot-visible containers`: affected validation choice. I checked both `documentElement.scrollWidth` and `body.scrollWidth`, and also asserted screenshot-visible containers (`.sidebar`, `.topbar`, `.capability-list-panel`, `.selected-object`, `.action-panel`) fit in the 390px viewport after Chinese copy changes.
- `Pre-submission whitespace check for text-heavy files`: affected validation choice. I ran `git diff --check` on changed HTML/CSS/JS and `start.command` before handoff.

## Handoff Self-Audit PASS Evidence

- `handoff-self-audit: T0009 .agentops/tasks/T0009-console-workbench-zh-primary-copy/handoff.md`
- 1. Contract version everywhere: not applicable. This task changed static UI copy and screenshots only; no contracts or versioned JSON examples changed.
- 2. Notes history retired: not applicable. This task did not modify docs or predecessor notes.
- 3. Real fixture for each null/invalid case: not applicable. No DB fixtures or validator tests are in this frontend copy scope.
- 4. Distinct validator failure codes: not applicable. No parser/mapper validators changed.
- 5. Contract drift scan: not applicable. No Approved Contract Delta or contract files are involved.
- 6. Smoke executed if brief demands: PASS. Visual/copy smoke ran via Chrome headless and CDP; screenshots were regenerated; Chinese core copy, forbidden English leftovers, action feedback, no console errors, and 390px overflow/container checks were verified.
- 7. Memory honesty: PASS. `Memory Used` names only entries that shaped validation decisions: screenshot-visible container checks and `git diff --check`.
- G. Worker Delivery Governance: PASS. Constraint Matrix and Evidence Map are included above; every brief validation bullet has source, grep, command, screenshot, or browser-smoke evidence.
- Result: PASS - submit.
