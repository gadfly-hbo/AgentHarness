# Table 016: `pls_channel_object_bindings`

## Purpose

`pls_channel_object_bindings` stores relationships between PLS channel profile
objects.

It is the second landing table for the PLS “渠道画像” module in AgentHarness:

```text
PLS channel object library -> pls_channel_objects -> pls_channel_object_bindings
```

## Why This Table Exists

渠道画像需要表达对象之间的业务结构，而不只是保存对象清单。

典型关系包括：

- `platform -> account`
- `trade_area -> store`
- `marketing_event -> channel entity`
- `business_scenario -> channel entity`

These relationships are required before downstream audience profiles and product
fit profiles can be interpreted in the correct channel context.

## Files

- Migration: `DataBase/migrations/016_create_pls_channel_object_bindings.sql`
- Seed: `DataBase/seeds/016_seed_pls_channel_object_bindings.sql`
- Validation: `DataBase/validations/016_validate_pls_channel_object_bindings.sql`

## Current Scope

The seed data uses the four mock bindings from the PLS channel profile 2.0
sample package:

- trade area contains store
- platform contains account
- marketing event applies to account
- business scenario applies to store

The table enforces foreign keys back to `pls_channel_objects` using
`workspace_id`, `canonical_object_key`, and `data_version`.

## Next Work

Create `pls_audience_profiles` to carry channel audience tags, sample size,
confidence, time window, unmapped fields, and quality flags.
