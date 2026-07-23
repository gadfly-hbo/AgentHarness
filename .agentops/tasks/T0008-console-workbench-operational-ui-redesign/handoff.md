# Handoff: T0008 Console Workbench Operational UI Redesign

## What Changed

- Rebuilt `Console/workbench-prototype/index.html` from a product-explanation page into an operational AgentHarness Console workspace.
- Added a dense internal-tool app shell with primary navigation, topbar environment status, capability toolbar, capability table, selected-object detail view, lifecycle checklist, action rail, four-base dependency inspector, and compact audit trail.
- Preserved the `Migrate to AgentHarness`, `Remain in pi-xanthil`, and `Contract / adapter boundary` content as a compact planning panel inside the selected capability workflow instead of a standalone documentation block.
- Added prototype-only frontend interactions in `Console/workbench-prototype/js/app.js`:
  - Capability row selection changes the selected object details and checklist.
  - `Run Evaluation` shows pending then success feedback and enables `Prepare Release`.
  - `Prepare Release` shows success feedback and enables `Distribute to pi-xanthil`.
  - `Distribute to pi-xanthil` shows blocked feedback because no real host adapter is connected.
  - `Open Audit` and `Show details` expose compact audit evidence.
- Reworked responsive CSS in `Console/workbench-prototype/css/styles.css` for desktop three-column workbench behavior and 390px single-column behavior without unintended horizontal overflow.
- Revision 1: fixed narrow/mobile topbar title wrapping so `Manage capability readiness and host distribution` remains fully readable at 390px instead of being visually clipped.
- Revision 1: added a data favicon in `index.html` to prevent Chrome's automatic `/favicon.ico` request from producing a 404 console error during smoke validation.
- Revision 2: replaced the mobile-sensitive long topbar heading with deterministic split text: primary heading `Manage capability readiness` and secondary subtitle `Host distribution`, so the mobile screenshot shows both short strings fully instead of a single clipped long string.
- Updated `desktop-screenshot.png` and `mobile-screenshot.png` with the redesigned prototype.

## Files Changed

- `Console/workbench-prototype/index.html`
- `Console/workbench-prototype/css/styles.css`
- `Console/workbench-prototype/js/app.js`
- `Console/workbench-prototype/desktop-screenshot.png`
- `Console/workbench-prototype/mobile-screenshot.png`

`Console/workbench-prototype/start.command` was checked for syntax and remains unchanged. It appears as untracked in the current working tree, but I did not edit it.

## Validation

- Browser smoke via Google Chrome headless and DevTools Protocol against `http://127.0.0.1:4177/index.html`:
  - `desktop-1440x1100 PASS`
  - `mobile-layout-390x844 PASS`
  - Verified key operational text exists: `Manage capability readiness`, `PLS Capability Pack`, action labels, and all migration boundary labels.
  - Verified interaction feedback: `Run Evaluation` -> `Evaluation success`, `Prepare Release` enabled -> `Release prepared`, `Distribute to pi-xanthil` enabled -> `Distribution blocked`.
  - Verified no collected `Runtime.exceptionThrown` or Chrome error log entries.
  - Verified desktop `documentScrollWidth=1440`, `bodyScrollWidth=1440`, `viewportWidth=1440`.
  - Verified mobile layout `documentScrollWidth=390`, `bodyScrollWidth=390`, `viewportWidth=390`.
  - Revision 1 mobile title evidence: full `titleText="Manage capability readiness and host distribution"`; `titleRect={"x":14,"width":362,"right":376}` within `viewportWidth=390`; `topbarRect={"x":0,"width":390,"right":390}`; `titleWhiteSpace="normal"`; `titleOverflowWrap="anywhere"`.
  - Revision 1 desktop title evidence: full `titleText="Manage capability readiness and host distribution"`; `titleRect.right=730.875` within `viewportWidth=1440`; `titleWhiteSpace="normal"`; no collected Chrome error log entries after adding the data favicon.
  - Revision 2 mobile screenshot-visible heading evidence: `primaryText="Manage capability readiness"`, `secondaryText="Host distribution"`; primary rect `x=14,width=229.53125,right=243.53125`; secondary rect `x=14,width=229.53125,right=243.53125`; both are visible and fit within `viewportWidth=390`.
  - Revision 2 desktop heading evidence: `primaryText="Manage capability readiness"`, `secondaryText="Host distribution"`; desktop keeps both heading parts on the topbar with no console errors and no overflow.
- Screenshot generation:
  - Desktop: Chrome headless wrote `255562 bytes` to `Console/workbench-prototype/desktop-screenshot.png`.
  - Mobile: Chrome headless wrote `53188 bytes` to `Console/workbench-prototype/mobile-screenshot.png`.
- Static checks:
  - `git diff --check -- "Console/workbench-prototype/index.html" "Console/workbench-prototype/css/styles.css" "Console/workbench-prototype/js/app.js" "Console/workbench-prototype/start.command"` passed with no output.
  - `zsh -n "Console/workbench-prototype/start.command"` passed with no output.

## Risks

- This remains a static prototype with demo data only. No real registry, migration scan, contract validation, backend API, host adapter, or distribution state is connected.
- `desktop-screenshot.png` and `mobile-screenshot.png` are generated through Chrome headless CLI and browser smoke uses Chrome DevTools Protocol because local `playwright` / `@playwright/test` packages are not installed and dependency installation is forbidden by the brief.
- `start.command` is currently untracked in git status, but it is within allowed scope and was left unchanged.

## Open Questions

- None for this scoped frontend prototype task.

## Product UI Audit

- Information Architecture: PASS. The first screen presents a capability workspace with navigation, filters, selected capability, status cards, and action rail before any explanatory content.
- Visual Hierarchy: PASS. The current object `PLS Capability Pack`, lifecycle state, four status dimensions, and primary actions are visually prominent.
- Layout And Spacing: PASS. Desktop uses app shell plus workspace/action rail; mobile collapses to a single column. Browser smoke confirmed no unintended horizontal overflow at 390px.
- Component Consistency: PASS. Badges, table rows, status cards, action buttons, dependency items, and audit list share consistent density, borders, and state language.
- Operational Product Fit: PASS. The UI now behaves like an internal SaaS/admin workbench for lifecycle management rather than a landing page or long product note.
- Accessibility: PASS for prototype scope. Buttons and inputs have readable labels or visible text; disabled actions include visible reasons; action feedback uses `role="status"`.
- Responsive Behavior: PASS. Narrow layout intentionally collapses toolbar, table rows, status cards, boundary panel, and action rail; CDP smoke confirmed both `documentElement.scrollWidth` and `body.scrollWidth` equal 390 at a 390px viewport.
- Revision 1 topbar readability: PASS. CDP smoke confirmed the screenshot-visible mobile title rect fits within both viewport and topbar, and the full title text remains present without ellipsis/clipping.
- Revision 2 topbar readability: PASS. Mobile now uses two deterministic short visible strings, `Manage capability readiness` and `Host distribution`; CDP smoke verified both text nodes are visible and each right edge is `243.53125`, well inside the 390px viewport.

## Design Principles Applied

- Workflow first: capability selection, status, and next actions are visible before context notes.
- Dense and scannable: compact table/list, status cards, action rail, and audit trail replace large prose panels.
- Explicit prototype boundary: topbar, badges, action feedback, and migration panel mark demo/static state and avoid implying real registry or host distribution.
- Defensive responsive CSS: `min-width: 0`, `max-width: 100%`, wrapping badges, and single-column media queries prevent overflow and overlap.
- Screenshot-visible validation: title/topbar rect assertions were added after review found that scrollWidth alone missed title clipping.
- Deterministic mobile copy: after the second review found the screenshot still clipped a long title, mobile-sensitive heading copy was split into short primary/subtitle elements instead of relying on long-text wrapping.
- Migration context as operational support: migration boundary information is retained as selected-object planning context, not the page's main subject.

## Evidence Map

- 页面是否从说明书转为 operational console: `index.html` now defines `.workspace`, `.capability-table`, `.selected-object`, `.action-rail`; browser smoke found `Manage capability readiness` and action labels.
- 主工作流是否首屏可见: `index.html` topbar plus capability table and action rail are first workspace content; screenshot files updated.
- `PLS Capability Pack` 是否可作为 selected object 被管理: `index.html` includes selected PLS row and selected-object panel; `js/app.js` `renderCapability('pls')` state drives details and actions.
- 至少 2 个操作按钮是否有 prototype feedback: `js/app.js` handlers for `run-eval`, `prepare-release`, and `distribute`; browser smoke verified success, release, and blocked feedback strings.
- migration boundary 是否保留但不喧宾夺主: `index.html` `.boundary-panel` contains `Migrate to AgentHarness`, `Remain in pi-xanthil`, and `Contract / adapter boundary` inside selected-object detail.
- desktop screenshot 是否完成: `Console/workbench-prototype/desktop-screenshot.png`, revision 2 Chrome output `255562 bytes written`.
- mobile/narrow screenshot 是否完成: `Console/workbench-prototype/mobile-screenshot.png`, revision 2 Chrome output `53188 bytes written`; CDP smoke verified `Manage capability readiness` and `Host distribution` are separate visible text nodes within 390px viewport.
- `start.command` 是否仍可用: `zsh -n "Console/workbench-prototype/start.command"` passed; file content unchanged.
- allowed paths 是否合规: all changed implementation/screenshot files are under `Console/workbench-prototype/**`; Task Bus metadata/handoff files are under `.agentops/tasks/T0008-console-workbench-operational-ui-redesign/`.

## Screenshots

- Desktop: `Console/workbench-prototype/desktop-screenshot.png`
- Mobile: `Console/workbench-prototype/mobile-screenshot.png`

## Constraint Matrix

| Brief bullet | Invariant family | Authority | Implementation path | Positive evidence | Negative evidence | Waiver/blocker |
| --- | --- | --- | --- | --- | --- | --- |
| Work only inside allowed frontend scope | Scope | `brief.md` allowed_paths | `Console/workbench-prototype/**` | `git status --short` changed only prototype files plus Task Bus handoff dir | No changes to `DataBase/**`, `OntoBase/**`, `docs/**`, `Console/commands/**` | None |
| No contract/persistence/API/read model/concurrency/audit work | Scope | `brief.md` non-goals | Static HTML/CSS/JS only | Files changed are static prototype assets | No backend/API/schema files changed | None |
| Turn page into operational console | UI | `brief.md` Objective / Required Changes | `index.html`, `styles.css` | Browser smoke found operational title and action labels | Visual smoke checks no JS errors | None |
| Add prototype interactions | UI state | `brief.md` Required Changes | `js/app.js` | CDP click smoke verified eval/release/distribution feedback | Disabled states preserved before action progression | None |
| Responsive and no overlap/overflow | Responsive UI | `brief.md` validation / memory guardrail | `styles.css` media queries | CDP mobile 390 scrollWidth checks passed; Revision 2 title primary/subtitle text nodes fit viewport | Initial 728px overflow and repeated mobile title clipping were fixed before re-handoff | None |

## Memory Used

- `Match visual assertions to screenshot-visible containers`: affected validation choice. I checked both `documentElement.scrollWidth` and `body.scrollWidth` at 390px and reran after fixing the initial 728px overflow.
- `Match visual assertions to screenshot-visible containers`: affected Revision 1 validation choice. After review found mobile title clipping despite scrollWidth checks, I added title/topbar rect assertions and verified the full topbar title fits within the 390px screenshot-visible viewport.
- `Match visual assertions to screenshot-visible containers`: affected Revision 2 implementation and validation. After the second review rejected rect-only evidence because the screenshot still showed ellipsis, I changed the actual screenshot-visible content to short primary/subtitle text and asserted both visible text-node rects.
- `Pre-submission whitespace check for text-heavy files`: affected validation choice. I ran `git diff --check` on changed HTML/CSS/JS before handoff.

## Handoff Self-Audit PASS Evidence

- `handoff-self-audit: T0008 .agentops/tasks/T0008-console-workbench-operational-ui-redesign/handoff.md`
- 1. Contract version everywhere: not applicable. This task did not change contracts or versioned JSON examples; handoff states no contract/API/schema work at lines 46 and 94.
- 2. Notes history retired: not applicable. This task did not modify predecessor notes or docs; changed files are listed at lines 19-23.
- 3. Real fixture for each null/invalid case: not applicable. No DB fixtures or null/invalid validator tests were in scope; task is static frontend prototype only per lines 46 and 94.
- 4. Distinct validator failure codes: not applicable. No parser/mapper validators changed; implementation paths are static HTML/CSS/JS per lines 19-21.
- 5. Contract drift scan: not applicable. There was no Approved Contract Delta in the brief and no contract files changed; scope evidence is lines 46, 82, and 94.
- 6. Smoke executed if brief demands: PASS. The brief required visual/product smoke rather than an `npm run ... smoke`; browser smoke and screenshot evidence are recorded at lines 29-42 and screenshot paths at lines 86-87.
- 7. Memory honesty: PASS. `Memory Used` names only entries that affected validation decisions: mobile overflow checks and `git diff --check`, recorded at lines 99-102.
- G. Worker Delivery Governance: PASS. Constraint Matrix exists at lines 89-97; Evidence Map covers each brief evidence item at lines 72-82; grep-able source evidence includes `index.html:46` `.workspace`, `index.html:195` `.action-rail`, `index.html:178-186` migration boundary labels, `js/app.js:142-170` action feedback handlers, and `css/styles.css:620` / `css/styles.css:692` responsive min-width/wrapping fixes.
- Result: PASS - submit.

## Revision 1 Blocker Checklist

- Mobile screenshot topbar title clipped: fixed in `Console/workbench-prototype/css/styles.css` by adding explicit topbar child `min-width: 0`, normal wrapping, `overflow-wrap: anywhere`, title line-height, and narrower mobile font size.
- Need screenshot-visible title evidence beyond scrollWidth: covered by CDP smoke title/topbar rect assertions recorded in Validation.
- Regenerate screenshots: completed for both `desktop-screenshot.png` and `mobile-screenshot.png`.
- Rerun action feedback checks: completed in CDP smoke for `Run Evaluation`, `Prepare Release`, and `Distribute to pi-xanthil`.
- Rerun 390px document/body scrollWidth checks: completed, both equal `390`.
- Rerun `git diff --check`: completed with no output.

## Revision 1 Handoff Self-Audit PASS Evidence

- `handoff-self-audit: T0008 revision 1 .agentops/tasks/T0008-console-workbench-operational-ui-redesign/handoff.md`
- 1. Contract version everywhere: not applicable. Revision 1 changed only static frontend prototype files and screenshots; no contracts or versioned JSON examples changed.
- 2. Notes history retired: not applicable. Revision 1 did not modify docs or predecessor notes.
- 3. Real fixture for each null/invalid case: not applicable. No DB fixtures or validator tests are in this frontend prototype scope.
- 4. Distinct validator failure codes: not applicable. No parser/mapper validators changed.
- 5. Contract drift scan: not applicable. No Approved Contract Delta or contract files are involved.
- 6. Smoke executed if brief demands: PASS. Revision smoke reran desktop/mobile browser checks, action feedback, no console errors, 390px document/body scrollWidth, and title/topbar rect assertions; screenshot files were regenerated.
- 7. Memory honesty: PASS. `Match visual assertions to screenshot-visible containers` directly shaped Revision 1 validation by adding screenshot-visible title/topbar rect assertions; `Pre-submission whitespace check for text-heavy files` shaped the `git diff --check` rerun.
- G. Worker Delivery Governance: PASS. Revision remained bounded to review-requested mobile topbar wrapping, screenshots, smoke, and handoff evidence; no backend, API, schema, contract, persistence, read model, concurrency, or audit work was introduced.
- Result: PASS - submit.

## Revision 2 Blocker Checklist

- Mobile screenshot still clipped long topbar title: fixed by splitting the heading into two deterministic short text elements, `Manage capability readiness` and `Host distribution`, in `Console/workbench-prototype/index.html`.
- Do not rely only on `scrollWidth` or title rect: addressed by changing the visible content/layout itself and recording text-node evidence for both short strings.
- Regenerate screenshots: completed for both `desktop-screenshot.png` and `mobile-screenshot.png` after the split-heading fix.
- Rerun action feedback checks: completed in CDP smoke for `Run Evaluation`, `Prepare Release`, and `Distribute to pi-xanthil`.
- Rerun 390px document/body scrollWidth checks: completed, both equal `390`.
- Rerun `git diff --check`: completed with no output.

## Revision 2 Handoff Self-Audit PASS Evidence

- `handoff-self-audit: T0008 revision 2 .agentops/tasks/T0008-console-workbench-operational-ui-redesign/handoff.md`
- 1. Contract version everywhere: not applicable. Revision 2 changed only static frontend prototype files and screenshots; no contracts or versioned JSON examples changed.
- 2. Notes history retired: not applicable. Revision 2 did not modify docs or predecessor notes.
- 3. Real fixture for each null/invalid case: not applicable. No DB fixtures or validator tests are in this frontend prototype scope.
- 4. Distinct validator failure codes: not applicable. No parser/mapper validators changed.
- 5. Contract drift scan: not applicable. No Approved Contract Delta or contract files are involved.
- 6. Smoke executed if brief demands: PASS. Revision 2 smoke reran desktop/mobile browser checks, action feedback, no console errors, 390px document/body scrollWidth, and screenshot-visible text-node assertions for both `Manage capability readiness` and `Host distribution`; screenshot files were regenerated.
- 7. Memory honesty: PASS. `Match visual assertions to screenshot-visible containers` directly shaped Revision 2 implementation and validation; `Pre-submission whitespace check for text-heavy files` shaped the `git diff --check` rerun.
- G. Worker Delivery Governance: PASS. Revision remained bounded to review-requested mobile heading readability, screenshots, smoke, and handoff evidence; no backend, API, schema, contract, persistence, read model, concurrency, or audit work was introduced.
- Result: PASS - submit.
