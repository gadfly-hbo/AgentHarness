# AgentHarness Architecture

## Positioning

AgentHarness is the governance and infrastructure layer for agent systems. It is
not a single agent application and should not be coupled to one product's task
logic. Its job is to provide a common control plane and durable infrastructure
for many agents, tools, workflows, and domain contexts.

## Architecture Shape

AgentHarness uses a "four bases and one console" structure. The four bases and
the console are independent and decoupled. They do not form a storage hierarchy;
they form Harness by publishing and consuming explicit joint contracts.

```text
             +----------------+
             |    Console     |
             +-------+--------+
                     |
              joint contracts
                     |
+------------+ +------------+ +---------------+ +-----------+
| DataBase   | | OntoBase   | | MemoryBase    | |KnowledgeBase|
+------------+ +------------+ +---------------+ +-----------+
```

The console orchestrates user and agent workflows through contracts rather than
by reaching into one base as the owner of the others. The four bases provide
specialized capabilities:

- Memory records operational experience.
- Data records structured facts about the system's runtime.
- Knowledge stores source material and retrievable references.
- Ontology defines business semantics, concepts, relationships, metrics, rules,
  actions, and mappings.

No base is the global parent of another base. Cross-base behavior must be
declared through a joint contract for a specific product or project.

## Controller-Domain Development

AgentHarness 的开发控制面采用 CDI（Controller-Domain Isolation，总控域隔离工程法）：

```text
                         Codex Controller
                context / contracts / review / integration
                                  |
              +-------------------+-------------------+
              |                   |                   |
       OpenCode              Kilo Code           Mimo Code          Kimi Code
       DataBase              OntoBase            KnowledgeBase      MemoryBase
              \                   |                   |                   /
               +------------------+-------------------+------------------+
                                  |
                      explicit joint contracts
                                  |
                         Antigravity CLI
                              Console
                                  |
                               products
```

Codex owns global terminology, joint contracts, Task Bus dispatch, Console contracts,
integration review, and final acceptance. Domain agents own only their assigned
domain and may not edit another domain or a shared contract without a
controller-approved brief. Detailed rules live in `CONTEXT.md` and
`Orchestration.md`.

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

DataBase is not the host for OntoBase, MemoryBase, or KnowledgeBase. It may
serve as a data source in a joint contract, but each base remains independently
owned.

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
- Metric definitions.
- Logic rules.
- Action semantics.

OntoBase prevents the system from becoming a pile of unrelated records.

OntoBase is independent from DataBase. It may bind to database tables, views,
APIs, files, documents, or product services as external sources, but those
bindings do not make OntoBase a database extension.

## Joint Contracts

External products and projects consume Harness through explicit joint contracts.
A joint contract states which bases and console workflows are used, which
objects or APIs are exposed, how identities align, and which operations need
approval, refresh, writeback, or audit.

For example, the first PLS channel profile matching phase can consume:

- `DataBase`: PLS tables, views, imports, and feature matrices.
- `OntoBase`: PLS business objects, semantic dimensions, metrics, rules, and
  explanation relationships.
- `MemoryBase`: matching lessons, review outcomes, and model iteration memory.
- `KnowledgeBase`: PLS standards, platform tag documentation, and import specs.
- `Console`: import, review, refresh, explanation, and publishing workflows.

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
