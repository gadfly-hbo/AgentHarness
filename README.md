# AgentHarness

AgentHarness is a centralized infrastructure layer for governing agent systems.
It is positioned alongside AgentOps and ModelOps, but serves a more foundational
user group: teams that need a practical control plane for agents, tools,
memories, knowledge, data, and ontology before they scale into heavier
operations.

The long-term architecture is "four bases and one console":

- `MemoryBase`: reusable agent memory, preferences, lessons, and operational
  experience.
- `DataBase`: structured runtime data, tasks, runs, audit records, permissions,
  and configuration.
- `KnowledgeBase`: documents, specifications, external references, and indexed
  retrieval sources.
- `OntoBase`: domain concepts, entities, relationships, schemas, and semantic
  mappings across the system.
- `Console`: the control plane for users, agents, tools, commands, hooks,
  prompts, subagents, model management, and governance workflows.

## Current Strategy

AgentHarness should be built incrementally. The first milestone is not the full
four-base system. It is a minimal governance loop:

1. Register an agent or agent capability.
2. Dispatch or record a task.
3. Capture the run, tool calls, decisions, and artifacts.
4. Promote useful outcomes into memory.
5. Reuse memory in the next task.

This keeps the first version small while proving the central value of the
system: agent execution becomes observable, reusable, and governable.

## Repository Layout

```text
AgentHarness/
  Console/
    commands/
    extension/
    hooks/
    library/
    llm-manage/
    prompts/
    skill-evol/
    subagents/
    tool-use/
  DataBase/
  KnowledgeBase/
  MemoryBase/
  OntoBase/
  docs/
```

See the documents under `docs/` for the architecture, domain model, and roadmap.

## Current Artifacts

Phase 0 foundation documents:

- `docs/architecture.md`
- `docs/domain-model.md`
- `docs/roadmap.md`

Phase 1 initial schemas:

- `DataBase/schema/task.schema.json`
- `DataBase/schema/run.schema.json`
- `DataBase/schema/event.schema.json`
- `DataBase/schema/artifact.schema.json`
- `MemoryBase/schema/memory-candidate.schema.json`
- `MemoryBase/schema/memory.schema.json`

Phase 1 file-loop prototype:

- `Console/commands/agentharness.mjs`
- `docs/phase-1-file-loop.md`

Run the sample governance loop:

```bash
node Console/commands/agentharness.mjs sample-loop
node Console/commands/agentharness.mjs inspect
```

DataBase SQLite start:

- `DataBase/README.md`
- `DataBase/docs/design.md`
- `DataBase/migrations/001_create_entities.sql`
- `DataBase/migrations/002_create_pls_semantic_dimensions.sql`
- `DataBase/migrations/003_create_database_field_comments.sql`
- `DataBase/migrations/004_create_pls_platform_tag_mappings.sql`
- `DataBase/migrations/005_create_platform_tag_catalog.sql`
- `DataBase/migrations/006_create_pls_tag_type_dimension_mappings.sql`
- `DataBase/migrations/007_create_v_pls_tag_type_mapping_review_queue.sql`
- `DataBase/seeds/001_seed_entities.sql`
- `DataBase/seeds/002_seed_pls_semantic_dimensions.sql`
- `DataBase/seeds/003_seed_database_field_comments.sql`
- `DataBase/seeds/004_seed_pls_platform_tag_mappings.sql`
- `DataBase/validations/001_validate_entities.sql`
- `DataBase/validations/002_validate_pls_semantic_dimensions.sql`
- `DataBase/validations/003_validate_database_field_comments.sql`
- `DataBase/validations/004_validate_pls_platform_tag_mappings.sql`
- `DataBase/validations/005_validate_platform_tag_catalog.sql`
- `DataBase/validations/006_validate_pls_tag_type_dimension_mappings.sql`
- `DataBase/validations/007_validate_v_pls_tag_type_mapping_review_queue.sql`
- `DataBase/importers/import_platform_tag_catalog.mjs`
- `DataBase/importers/import_pls_tag_type_dimension_mappings.mjs`
- `DataBase/console/`

macOS one-click start:

```bash
./启动AgentHarness.command
```
