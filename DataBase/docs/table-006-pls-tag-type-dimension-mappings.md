# Table 006: `pls_tag_type_dimension_mappings`

## Purpose

`pls_tag_type_dimension_mappings` maps platform `tag_type` values into the PLS
three-layer, nine-dimension semantic model.

This is the first real alignment table for turning raw platform catalogs into a
unified PLS model:

```text
platform_tag_catalog.tag_type -> pls_semantic_dimensions
```

## Files

- Migration: `DataBase/migrations/006_create_pls_tag_type_dimension_mappings.sql`
- Importer: `DataBase/importers/import_pls_tag_type_dimension_mappings.mjs`
- Validation: `DataBase/validations/006_validate_pls_tag_type_dimension_mappings.sql`

## Mapping Status

- `proposed`: rule-based suggestion is reasonably confident.
- `review_needed`: rule-based suggestion exists but needs manual review.
- `unmapped`: no reliable rule-based suggestion exists yet.
- `approved`: human-approved mapping.
- `rejected`: reviewed and rejected mapping.

## Current Scope

Only Tmall and Douyin are included. Xiaohongshu is intentionally excluded.
JD will be connected later.

## Next Work

Review `review_needed` and `unmapped` rows, then promote reliable mappings to
`approved`. After tag type mappings are stable, create `pls_tag_value_mappings`
for leaf-label-level alignment.
