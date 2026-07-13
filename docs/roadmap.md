# AgentHarness Roadmap

## Phase 0: Project Foundation

Goal: make the project understandable and ready for incremental buildout.

Deliverables:

- Project README.
- Architecture document.
- Domain model.
- Roadmap.
- Basic repository hygiene.

## Phase 1: Minimal Governance Loop

Goal: prove the core AgentHarness loop without building the full platform.

Status: complete as a file-based prototype.

Deliverables:

- Task record schema.
- Run event schema.
- Artifact record schema.
- Memory candidate schema.
- Manual memory approval workflow.
- Console command or script to inspect the loop.

Implemented in:

- `Console/commands/agentharness.mjs`
- `docs/phase-1-file-loop.md`

Primary loop:

```text
Task -> Run -> Event -> Artifact -> MemoryCandidate -> Memory
```

## Phase 2: Console Skeleton

Goal: make the console the main operational entry point.

Deliverables:

- Agent registry.
- Tool registry.
- Command registry.
- Hook lifecycle.
- Prompt and skill inventory.
- Basic model configuration.

## Phase 3: Base APIs

Goal: prevent the console from coupling directly to storage details.

Deliverables:

- MemoryBase API.
- DataBase API.
- KnowledgeBase API.
- OntoBase API.
- Shared identifier and provenance conventions.

## Phase 4: Knowledge and Ontology Integration

Goal: connect retrieved knowledge and domain meaning to runtime governance.

Deliverables:

- Knowledge ingestion flow.
- Source metadata schema.
- Ontology entity schema.
- Cross-base mapping rules.
- Retrieval provenance in runs and memories.

## Phase 5: Policy and Audit

Goal: make governance explicit and inspectable.

Deliverables:

- Policy model.
- Tool permission rules.
- Memory application rules.
- Audit views.
- Run review workflow.

## Near-Term Build Order

1. Define schemas for task, run, event, artifact, and memory candidate.
2. Store them as simple files before choosing a database engine.
3. Add a console command to create and inspect task runs.
4. Add a manual memory promotion command.
5. Only then decide whether the first storage backend should be SQLite,
   filesystem JSONL, or another engine.
