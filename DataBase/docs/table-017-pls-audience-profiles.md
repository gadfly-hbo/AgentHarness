# Table 017: `pls_audience_profiles`

## Purpose

`pls_audience_profiles` stores audience profile snapshots for PLS channel
objects.

It is the third landing table for the PLS “渠道画像” module in AgentHarness:

```text
PLS channel object library
  -> pls_channel_objects
  -> pls_channel_object_bindings
  -> pls_audience_profiles
```

## Why This Table Exists

渠道画像的第一阶段核心问题之一是：

```text
这个渠道对象面对什么样的人群？
```

This table preserves the audience profile as imported from PLS, including tag
scores, sample size, confidence, time window, unmapped fields, quality flags, and
raw JSON.

## Files

- Migration: `DataBase/migrations/017_create_pls_audience_profiles.sql`
- Seed: `DataBase/seeds/017_seed_pls_audience_profiles.sql`
- Validation: `DataBase/validations/017_validate_pls_audience_profiles.sql`

## Current Scope

The seed data uses three mock audience profiles from the PLS channel profile 2.0
sample package:

- account audience profile
- store audience profile
- trade area audience profile

The table enforces a foreign key back to `pls_channel_objects` using
`workspace_id`, `canonical_object_key`, and `data_version`.

## Important Note

`tags_json` contains PLS channel-profile taxonomy tags such as
`demo.age_25_34`, `channel.short_video`, `style.minimal`, and `price.mid`.

These are not the same as the raw Tmall/Douyin platform tag values in
`platform_tag_catalog`. A later mapping layer should decide how these
channel-profile taxonomy tags contribute to the PLS three-layer, nine-dimension
model.

## Next Work

Create `pls_product_fit_profiles` to carry product fit categories, price bands,
styles, occasions, launch types, evidence, confidence, and quality flags.
