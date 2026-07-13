# Table 008: `pls_tag_value_dimension_mappings`

## Purpose

`pls_tag_value_dimension_mappings` maps concrete platform tag values into the PLS
three-layer, nine-dimension semantic model.

This is the next alignment layer after `pls_tag_type_dimension_mappings`:

```text
platform_tag_catalog.leaf_label -> pls_semantic_dimensions
```

## Why This Table Exists

`tag_type` alignment is enough to understand broad platform taxonomy, but product
and model consumption usually happens at tag value level. This table gives PLS,
ModelEvol, and downstream portrait modules a direct way to consume concrete
platform labels while still preserving source traceability.

## Files

- Migration: `DataBase/migrations/008_create_pls_tag_value_dimension_mappings.sql`
- Importer: `DataBase/importers/import_pls_tag_value_dimension_mappings.mjs`
- Validation: `DataBase/validations/008_validate_pls_tag_value_dimension_mappings.sql`

## Current Scope

Only Tmall and Douyin are included. Xiaohongshu is intentionally excluded.
JD will be connected later.

The initial import inherits dimensions from the fully approved
`pls_tag_type_dimension_mappings` table. Future iterations can override specific
tag values with `mapping_method = 'manual'` if a value needs finer treatment than
its parent tag type.

## Next Work

Use this table as the consumption surface for PLS tag matching. If downstream
products find a tag value that should not inherit its parent tag type dimension,
promote that row into a manual override and capture the rationale.
