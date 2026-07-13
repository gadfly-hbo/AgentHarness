# Table 002: `pls_semantic_dimensions`

## Purpose

`pls_semantic_dimensions` stores the standard PLS semantic dimensions from the
PLS business semantics and master data standard workbook.

This table is the semantic foundation for:

- PLS profile modules.
- PLS audience segmentation models.
- Future platform tag mappings from Douyin, JD, and Tmall.

## Files

- Migration: `DataBase/migrations/002_create_pls_semantic_dimensions.sql`
- Seed data: `DataBase/seeds/002_seed_pls_semantic_dimensions.sql`
- Validation: `DataBase/validations/002_validate_pls_semantic_dimensions.sql`

## Source

Workbook:

```text
/Users/huangbo/Desktop/PLS业务语义及主数据标准-v0.1.xlsx
```

Rows used:

- `工作表 1!A4:F4`
- `工作表 1!A8:F8`
- `工作表 1!A12:F12`
- `工作表 1!A16:F16`
- `工作表 1!A20:F20`
- `工作表 1!A24:F24`
- `工作表 1!A28:F28`
- `工作表 1!A32:F32`
- `工作表 1!A36:F36`

These are the nine `通用 (映射标准)` rows.

## Seed Records

P layer:

- `P_DEMOGRAPHICS`
- `P_PURCHASING_POWER`
- `P_IDENTITY_CLUSTER`

L layer:

- `L_CONTENT_VISUAL_MIND`
- `L_LIFESTYLE`
- `L_INNOVATION_BRAND_MIND`

S layer:

- `S_PRICE_INCENTIVE_RESPONSE`
- `S_CONVERSION_FRICTION`
- `S_ENVIRONMENT`

## Validation Result

Expected checks:

```text
pls_dimensions_total: 9 / 9 pass
pls_dimensions_by_layer: P = 3, L = 3, S = 3
business_strategy_present: 0 / 0 pass
source_refs_present: 0 / 0 pass
```

## Next Table Candidate

The next natural table is `pls_platform_tag_mappings`, using the remaining 27
platform rows from the workbook.
