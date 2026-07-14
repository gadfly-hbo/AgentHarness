# Table 005: `platform_tag_catalog`

## Purpose

`platform_tag_catalog` stores the raw platform tag catalogs before they are
mapped into the PLS model. This table is the ingestion foundation for aligning
platform-specific labels into a unified PLS segmentation logic.

The current import includes:

- Tmall
- Douyin
- JD

Xiaohongshu is excluded by current product decision.

## Files

- Migration: `DataBase/migrations/005_create_platform_tag_catalog.sql`
- Importer: `DataBase/importers/import_platform_tag_catalog.mjs`
- Validation: `DataBase/validations/005_validate_platform_tag_catalog.sql`

## Source

```text
DataBase/source_files/platform_tags/v0.1/1. 天猫_标签类型_标签_20260201.csv
DataBase/source_files/platform_tags/v0.1/3. 抖音_标签类型_标签_20260201.csv
DataBase/source_files/platform_tags/v0.1/4. 京东_标签类型_标签_20260714.csv
DataBase/source_files/platform_tags/v0.1/5. 天猫_AI标签_服饰需求特征_20260714.csv
```

## Imported Data

Expected imported rows:

```text
天猫: 3573
抖音: 5902
京东: 227
total: 9702
```

`5. 天猫_AI标签_服饰需求特征_20260714.csv` 是用户补充的 AI 标签源，
只保存标签值，原始占比不进入 `platform_tag_catalog.leaf_label`。

抖音 `美妆行业特色人群` 来自实际可提取画像标签清洗文件：
`DataBase/source_files/platform_profile_extracts/douyin/v0.1/101326115008_实际可提取画像标签_20260714.csv`。

## Role In The PLS Model

This table does not decide the PLS mapping by itself. It preserves raw platform
labels with provenance. Mapping tables should then connect these labels to:

```text
platform_tag_catalog -> pls_semantic_dimensions -> PLS segmentation logic
```

## Next Table Candidate

The next table should be `pls_tag_type_dimension_mappings`, which maps platform
`tag_type` values to standard PLS dimensions.
