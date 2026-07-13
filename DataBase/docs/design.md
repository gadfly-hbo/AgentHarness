# DataBase Design

## Direction

DataBase will be built incrementally with SQLite. The goal is not to design a
large abstract platform first. The goal is to let real product needs enter the
database early, validate them, and then grow the schema from observed pressure.

## First Consumers

### ModelEvol

ModelEvol needs durable records for model iteration:

- Models.
- Datasets.
- Experiments.
- Evaluation results.
- Released or locked model versions.

### PLS Profile Modules

PLS needs durable profile records for business objects:

- Products.
- Accounts.
- Channels.
- Audience groups.
- Profile dimensions.
- Profile scores and evidence.

### PLS Audience Segmentation Model

The PLS segmentation model should be built on DataBase rather than hidden
inside only PLS code. It will eventually need:

- Audience segment entities.
- Segment rules.
- Segment assignments.
- Versioned scoring outputs.
- Evidence links.

## Incremental Rule

Only one table should be introduced at a time. A table is not complete until it
has real data and a validation query.

## First Table: `entities`

The first table is `entities`.

Purpose:

- Give every important business, model, dataset, and segment object a stable
  database identity.
- Support both ModelEvol and PLS before their specialized tables exist.
- Keep provenance for where each entity came from.

Examples:

- `project:model-evol`
- `project:pls`
- `model:pls-audience-segmentation`
- `module:pls-profile`
- `database:agentharness`

Specialized tables should reference `entities.id` later instead of inventing
their own identity conventions.
