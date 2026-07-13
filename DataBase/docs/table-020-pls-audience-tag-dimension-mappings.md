# Table 020: `pls_audience_tag_dimension_mappings`

## Purpose

`pls_audience_tag_dimension_mappings` maps PLS channel-profile audience tags to
the PLS three-layer, nine-dimension semantic model.

Example:

```text
demo.age_25_34 -> 基础人口学
style.minimal -> 内容与视觉心智
price.mid -> 社会资产与购买力
```

## Why This Table Exists

`pls_audience_profiles.tags_json` stores channel-profile taxonomy tags. These
tags are not raw Tmall/Douyin platform tags, so they should not be forced into
`platform_tag_catalog`.

This mapping table provides a separate bridge:

```text
pls_audience_profiles.tags_json
  -> pls_audience_tag_dimension_mappings
  -> pls_semantic_dimensions
```

## Files

- Migration: `DataBase/migrations/020_create_pls_audience_tag_dimension_mappings.sql`
- Seed: `DataBase/seeds/020_seed_pls_audience_tag_dimension_mappings.sql`
- Validation: `DataBase/validations/020_validate_pls_audience_tag_dimension_mappings.sql`

## Current Scope

The seed covers the five tag IDs currently present in the PLS channel profile
sample package:

- `demo.age_25_34`
- `channel.short_video`
- `style.minimal`
- `occasion.work`
- `price.mid`

## Next Work

Create a read view that expands each audience profile tag into its PLS layer and
dimension, then aggregate those mapped tags into channel-level PLS feature
scores.
