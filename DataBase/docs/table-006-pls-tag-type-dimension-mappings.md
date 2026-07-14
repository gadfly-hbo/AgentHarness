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

Tmall, Douyin, and JD are included. Xiaohongshu is intentionally excluded.

JD currently has 38 approved tag type mappings imported from
`DataBase/source_files/platform_tags/v0.1/4. 京东_标签类型_标签_20260714.csv`.

The user-supplied Tmall tag type `AI标签_服饰需求特征` is approved into
`L_INNOVATION_BRAND_MIND` because it describes apparel style, fit, material,
temperament expression, and high-spend style groups.

The Douyin tag type `美妆行业特色人群` is approved into
`P_IDENTITY_CLUSTER` because it describes beauty consumer personas such as
拔草、格调、悦己、理性刚需 and 美潮文艺 groups.

## Next Work

Review `review_needed` and `unmapped` rows, then promote reliable mappings to
`approved`. After tag type mappings are stable, create `pls_tag_value_mappings`
for leaf-label-level alignment.
