# AgentHarness Domain Model

This document defines the initial domain vocabulary for AgentHarness.

## Top-Level Boundary

AgentHarness is composed from four independent bases and one independent
console:

- `DataBase`
- `OntoBase`
- `MemoryBase`
- `KnowledgeBase`
- `Console`

They are connected through explicit joint contracts for each external product
or project. No base is modeled as the parent, storage backend, or required
implementation layer of another base.

## Development Actors

| Actor | Role | Owned Domain |
| --- | --- | --- |
| Codex | Controller, contract owner, reviewer, integrator | Global context, Console contract, joint contracts |
| OpenCode | Domain agent | `DataBase` |
| Kilo Code | Domain agent | `OntoBase` |
| Mimo Code | Domain agent | `KnowledgeBase` |
| Kimi Code | Domain agent | `MemoryBase` |
| Antigravity CLI | Domain agent | `Console` |

Domain agents communicate through Codex, Task Bus handoffs, and explicit contracts. They do not directly coordinate cross-domain writes.

## Core Objects

### Agent

An executable actor that can perform tasks. An agent may be a human-operated CLI
agent, a subagent, an automated service, or a model-backed workflow.

Key fields:

- `id`
- `name`
- `type`
- `capabilities`
- `owner`
- `status`

### Capability

A declared ability of an agent, tool, model, or workflow.

Examples:

- Code editing.
- Document generation.
- Web research.
- Data extraction.
- Memory review.

### Task

A unit of work accepted by the system.

Key fields:

- `id`
- `title`
- `description`
- `requester`
- `assignee`
- `status`
- `priority`
- `created_at`

### Run

One execution attempt for a task.

A task may have many runs. A run contains steps, events, tool calls, decisions,
and artifacts.

### Event

An append-only record of something that happened during a run.

Examples:

- Agent started.
- Tool called.
- File changed.
- Test failed.
- User interrupted.
- Memory candidate created.

### Tool

An external or internal capability invoked by an agent.

Key fields:

- `id`
- `name`
- `type`
- `permissions`
- `input_schema`
- `output_schema`

### Artifact

A durable output produced during a task or run.

Examples:

- Code diff.
- Document.
- Report.
- Dataset.
- Screenshot.
- Model output.

### Memory

A reusable statement, pattern, preference, or operational lesson.

Key fields:

- `id`
- `scope`
- `content`
- `source`
- `confidence`
- `status`
- `created_at`
- `supersedes`

Memory should usually be created as a candidate first, then approved before it
becomes active.

### Knowledge Source

Original material that can be referenced or retrieved.

Examples:

- Markdown documents.
- Product requirements.
- API docs.
- Codebase notes.
- External research.

### Ontology Entity

A named concept or entity in the domain model.

Examples:

- Agent.
- Task.
- Tool.
- Memory.
- Product.
- User.
- Capability.

### Policy

A governance rule that affects behavior.

Examples:

- Which tools require approval.
- Which agents can write to which bases.
- Which memories can be auto-applied.
- Which models are allowed for a task class.

## Initial Relationships

```text
Agent has Capability
Agent performs Run
Task has Run
Run emits Event
Run invokes Tool
Run produces Artifact
Artifact may create MemoryCandidate
MemoryCandidate may become Memory
KnowledgeSource supports Memory
OntologyEntity classifies Task, Tool, Memory, Artifact, and KnowledgeSource
Policy constrains Agent, Tool, Run, and Memory
```

## Early Modeling Rules

- Every durable record should have provenance.
- Every run should be traceable back to a task.
- Every memory should be traceable back to evidence.
- Every knowledge item should be traceable back to a source.
- Ontology should describe shared meaning, not duplicate operational data.
