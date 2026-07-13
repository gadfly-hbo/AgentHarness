# Table 004: `pls_platform_tag_mappings`

## Purpose

`pls_platform_tag_mappings` stores platform-specific tag mappings from Douyin,
JD, and Tmall into the standard PLS semantic dimensions.

This table connects raw platform labels to the PLS semantic foundation:

```text
platform raw tags -> pls_semantic_dimensions
```

## Files

- Migration: `DataBase/migrations/004_create_pls_platform_tag_mappings.sql`
- Seed data: `DataBase/seeds/004_seed_pls_platform_tag_mappings.sql`
- Validation: `DataBase/validations/004_validate_pls_platform_tag_mappings.sql`

## Source

Workbook:

```text
/Users/huangbo/Desktop/PLS业务语义及主数据标准-v0.1.xlsx
```

Rows used:

- `工作表 1!A5:F7`
- `工作表 1!A9:F11`
- `工作表 1!A13:F15`
- `工作表 1!A17:F19`
- `工作表 1!A21:F23`
- `工作表 1!A25:F27`
- `工作表 1!A29:F31`
- `工作表 1!A33:F35`
- `工作表 1!A37:F39`

These are the 27 platform rows for `抖音`, `京东`, and `天猫`.

## Data Availability

`data_availability` describes how directly each platform exposes the needed
field:

- `direct`: platform directly provides usable tags.
- `manual`: requires manual operations or manual supplemental tagging.
- `missing`: platform lacks this dimension and needs data from another source.
- `inferred`: platform lacks direct output, but the value can be inferred from
  other data.

## Validation Result

Expected checks:

```text
pls_platform_mappings_total: 27 / 27 pass
抖音: 9 / 9 pass
京东: 9 / 9 pass
天猫: 9 / 9 pass
each PLS dimension: 3 platform mappings
orphan_dimension_refs: 0 / 0 pass
```

## Next Table Candidate

The next natural table is `pls_profile_observations` if the next need is to
store actual profile outputs. If the next need is the segmentation model first,
create `pls_segment_definitions`.
