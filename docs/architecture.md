# AgentHarness Architecture

## Positioning

AgentHarness is the governance and infrastructure layer for agent systems. It is
not a single agent application and should not be coupled to one product's task
logic. Its job is to provide a common control plane and durable infrastructure
for many agents, tools, workflows, and domain contexts.

## Architecture Shape

AgentHarness uses a "four bases and one console" structure.

```text
                 +----------------+
                 |    Console     |
                 +--------+-------+
                          |
       +------------------+------------------+
       |                  |                  |
+------+-----+     +------+-----+     +------+------+
| MemoryBase |     | DataBase   |     | KnowledgeBase|
+------+-----+     +------+-----+     +------+------+
       |                  |                  |
       +------------------+------------------+
                          |
                    +-----+-----+
                    | OntoBase  |
                    +-----------+
```

The console orchestrates user and agent workflows. The four bases provide
specialized persistence and meaning:

- Memory records operational experience.
- Data records structured facts about the system's runtime.
- Knowledge stores source material and retrievable references.
- Ontology defines the shared language used to connect the other bases.

## Module Responsibilities

### Console

The console is the entry point for governance. It should eventually contain:

- Agent and subagent registry.
- Command and workflow execution.
- Hook and policy enforcement.
- Prompt and skill lifecycle management.
- Tool-use tracking and permission management.
- LLM provider and model configuration.
- User-facing UI or CLI for inspection and control.

The console should depend on base APIs rather than reaching into storage files
directly.

### MemoryBase

MemoryBase stores reusable experience. It should answer questions like:

- What does this user or project prefer?
- What strategies worked or failed before?
- What facts should an agent carry into future sessions?
- Which memories are trusted, stale, conflicting, or superseded?

Memory entries need provenance, scope, confidence, and lifecycle state.

### DataBase

DataBase stores structured operational state:

- Agents and capabilities.
- Tasks and assignments.
- Runs, steps, events, and artifacts.
- Tool calls and permissions.
- Users, roles, policies, and audit trails.

This is the source of truth for runtime governance.

### KnowledgeBase

KnowledgeBase stores source knowledge:

- Project documentation.
- Product requirements.
- External references.
- Codebase summaries.
- Indexed chunks and retrieval metadata.

Knowledge should remain traceable to original sources.

### OntoBase

OntoBase provides semantic structure:

- Domain terms.
- Entity types.
- Relationship types.
- Schema mappings.
- Cross-base identifiers.

OntoBase prevents the system from becoming a pile of unrelated records.

## First Governance Loop

The first implementation should focus on this minimal loop:

```text
Task -> Run -> Event Log -> Artifact -> Memory Candidate -> Approved Memory
```

This loop is enough to prove the core value of AgentHarness without building
every planned subsystem.

## Design Constraints

- Keep base responsibilities separate.
- Prefer append-only logs for runtime events.
- Keep provenance on every durable record.
- Make memory promotion explicit rather than automatic by default.
- Do not let the console become the only place where domain meaning exists.
- Introduce storage engines after schemas and workflows are clear.
