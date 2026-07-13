# Table 005: `platform_tag_catalog`

## Purpose

`platform_tag_catalog` stores the raw platform tag catalogs before they are
mapped into the PLS model. This table is the ingestion foundation for aligning
platform-specific labels into a unified PLS segmentation logic.

The first import intentionally includes only:

- Tmall
- Douyin

Xiaohongshu is excluded by current product decision. JD will be connected later.

## Files

- Migration: `DataBase/migrations/005_create_platform_tag_catalog.sql`
- Importer: `DataBase/importers/import_platform_tag_catalog.mjs`
- Validation: `DataBase/validations/005_validate_platform_tag_catalog.sql`

## Source

```text
/Users/huangbo/Downloads/三大平台标签/1. 天猫_标签类型_标签_20260201.csv
/Users/huangbo/Downloads/三大平台标签/3. 抖音_标签类型_标签_20260201.csv
```

## Imported Data

Expected imported rows:

```text
天猫: 3538
抖音: 5895
total: 9433
```

## Role In The PLS Model

This table does not decide the PLS mapping by itself. It preserves raw platform
labels with provenance. Mapping tables should then connect these labels to:

```text
platform_tag_catalog -> pls_semantic_dimensions -> PLS segmentation logic
```

## Next Table Candidate

The next table should be `pls_tag_type_dimension_mappings`, which maps platform
`tag_type` values to standard PLS dimensions.
