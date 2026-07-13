# AgentHarness DataBase

DataBase is the structured data foundation for AgentHarness. It serves product
systems and model iteration systems that need durable, queryable, and
traceable records.

The first implementation uses SQLite and grows one table at a time. Each new
table must include:

- A clear purpose.
- A migration.
- Seed or imported real data.
- A validation query.
- Notes about which product need it serves.

## Current Scope

The first consumers are:

- ModelEvol model and algorithm iteration.
- PLS profile modules.
- PLS audience segmentation models.

## Build Rule

Do not create a large schema upfront. Add one table, load real records, validate
the result, then decide the next table from an actual product need.

## SQLite Database

Default local database path:

```text
DataBase/agentharness.sqlite
```

Apply the current migration and seed:

```bash
sqlite3 DataBase/agentharness.sqlite ".read DataBase/migrations/001_create_entities.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/seeds/001_seed_entities.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/001_validate_entities.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/migrations/002_create_pls_semantic_dimensions.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/seeds/002_seed_pls_semantic_dimensions.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/002_validate_pls_semantic_dimensions.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/migrations/003_create_database_field_comments.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/seeds/003_seed_database_field_comments.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/003_validate_database_field_comments.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/migrations/004_create_pls_platform_tag_mappings.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/seeds/004_seed_pls_platform_tag_mappings.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/seeds/003_seed_database_field_comments.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/004_validate_pls_platform_tag_mappings.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/003_validate_database_field_comments.sql"
node DataBase/importers/import_platform_tag_catalog.mjs
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/005_validate_platform_tag_catalog.sql"
node DataBase/importers/import_pls_tag_type_dimension_mappings.mjs
sqlite3 DataBase/agentharness.sqlite ".read DataBase/seeds/006_seed_pls_tag_type_dimension_mappings_approved.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/006_validate_pls_tag_type_dimension_mappings.sql"
node DataBase/importers/import_pls_tag_value_dimension_mappings.mjs
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/008_validate_pls_tag_value_dimension_mappings.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/migrations/009_drop_v_pls_tag_type_mapping_review_queue.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/migrations/010_create_v_pls_platform_tag_value_semantics.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/010_validate_v_pls_platform_tag_value_semantics.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/migrations/011_create_profile_tag_observations.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/seeds/011_seed_profile_tag_observations.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/011_validate_profile_tag_observations.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/migrations/012_create_v_profile_tag_observation_semantics.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/012_validate_v_profile_tag_observation_semantics.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/migrations/013_create_v_subject_pls_dimension_features.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/013_validate_v_subject_pls_dimension_features.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/migrations/014_create_v_subject_pls_feature_matrix.sql"
sqlite3 DataBase/agentharness.sqlite ".read DataBase/validations/014_validate_v_subject_pls_feature_matrix.sql"
```

Current table notes:

- `DataBase/docs/pls-consumption-guide.md`
- `DataBase/docs/table-001-entities.md`
- `DataBase/docs/table-002-pls-semantic-dimensions.md`
- `DataBase/docs/table-003-database-field-comments.md`
- `DataBase/docs/table-004-pls-platform-tag-mappings.md`
- `DataBase/docs/table-005-platform-tag-catalog.md`
- `DataBase/docs/table-006-pls-tag-type-dimension-mappings.md`
- `DataBase/docs/table-008-pls-tag-value-dimension-mappings.md`
- `DataBase/docs/view-010-pls-platform-tag-value-semantics.md`
- `DataBase/docs/table-011-profile-tag-observations.md`
- `DataBase/docs/view-012-profile-tag-observation-semantics.md`
- `DataBase/docs/view-013-subject-pls-dimension-features.md`
- `DataBase/docs/view-014-subject-pls-feature-matrix.md`

## Schema Console

Run a local HTML console for inspecting the SQLite database:

```bash
node DataBase/console/server.mjs
```

Then open:

```text
http://127.0.0.1:8788
```
