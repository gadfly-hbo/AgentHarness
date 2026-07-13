# Table 001: `entities`

## Purpose

`entities` is the first DataBase table. It provides stable identities for
projects, modules, models, databases, and later business objects such as
products, accounts, channels, and audience segments.

This table was chosen first because both immediate consumers need shared
identity before specialized tables exist:

- ModelEvol needs model, dataset, experiment, and version identities.
- PLS needs product, profile-module, audience, and segmentation-model
  identities.

## Files

- Migration: `DataBase/migrations/001_create_entities.sql`
- Seed data: `DataBase/seeds/001_seed_entities.sql`
- Validation: `DataBase/validations/001_validate_entities.sql`

## Seed Records

The first real records entered from current project needs are:

- `ent_project_modelevol`
- `ent_project_pls`
- `ent_model_pls_audience_segmentation`
- `ent_module_pls_profile`
- `ent_database_agentharness`

## Validation Result

Last verified on 2026-07-13:

```text
entities_total: 5 / 5 pass
required_consumers_present: 3 / 3 pass
json_attributes_valid: 0 / 0 pass
```

## Next Table Candidates

Choose the next table based on the nearest real product pressure:

- `datasets`: if ModelEvol model iteration needs data lineage first.
- `profile_dimensions`: if PLS profile output needs structured storage first.
- `segment_definitions`: if the PLS audience segmentation model needs to be
  formalized first.
