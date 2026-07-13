# Phase 1 File Loop

Phase 1 proves the minimum AgentHarness governance loop with local JSONL files.
It intentionally avoids choosing a database engine. The goal is to validate the
records, identifiers, and manual memory approval workflow first.

## Commands

Create one sample loop:

```bash
node Console/commands/agentharness.mjs sample-loop
```

Inspect current records:

```bash
node Console/commands/agentharness.mjs inspect
```

Approve a proposed memory candidate:

```bash
node Console/commands/agentharness.mjs approve-memory <memory-candidate-id> [reviewer]
```

## Storage

Runtime records are stored as JSONL:

```text
DataBase/runs/tasks.jsonl
DataBase/runs/runs.jsonl
DataBase/runs/events.jsonl
DataBase/runs/artifacts.jsonl
MemoryBase/candidates/memory-candidates.jsonl
MemoryBase/memories/memories.jsonl
```

Artifacts are stored under:

```text
DataBase/artifacts/
```

## Proven Loop

```text
Task -> Run -> Event -> Artifact -> MemoryCandidate -> Memory
```

The `MemoryCandidate -> Memory` step is manual. This is intentional: early
AgentHarness memory should be governed, reviewed, and traceable rather than
automatically promoted.
