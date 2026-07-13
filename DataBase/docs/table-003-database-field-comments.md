# Table 003: `database_field_comments`

## Purpose

`database_field_comments` stores Simplified Chinese field comments for database
tables. It makes the DataBase console easier for non-IT users to understand.

Instead of hard-coding Chinese notes in the HTML frontend, comments are stored
as governed SQLite records. This keeps field explanations queryable,
auditable, and extendable as more tables are added.

## Files

- Migration: `DataBase/migrations/003_create_database_field_comments.sql`
- Seed data: `DataBase/seeds/003_seed_database_field_comments.sql`
- Validation: `DataBase/validations/003_validate_database_field_comments.sql`

## Seed Coverage

The first seed covers all fields in:

- `entities`
- `pls_semantic_dimensions`

## Validation Result

Expected checks:

```text
field_comments_total: 69 / 69 pass
field_comments_self_comments: 11 / 11 pass
entities_field_comments: 9 / 9 pass
pls_dimensions_field_comments: 12 / 12 pass
pls_platform_mappings_field_comments: 11 / 11 pass
platform_tag_catalog_field_comments: 14 / 14 pass
pls_tag_type_mappings_field_comments: 12 / 12 pass
missing_active_comments_for_existing_fields: 0 / 0 pass
```

## Frontend Usage

The DataBase HTML console reads this table and merges comments into the schema
view. The field table can show:

- Technical field name.
- Simplified Chinese name.
- Business meaning.
- Example value.
- Technical type and constraints.
