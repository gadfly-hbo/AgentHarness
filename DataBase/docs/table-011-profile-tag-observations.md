# Table 011: `profile_tag_observations`

## Purpose

`profile_tag_observations` records that a subject has matched a concrete
platform tag value.

This is the first product-consumption fact table for PLS-aligned tags:

```text
subject -> platform_tag_catalog -> v_pls_platform_tag_value_semantics
```

## Why This Table Exists

PLS and ModelEvol need more than a tag dictionary. They need observations: which
user, account, audience segment, product, or sample subject has which platform
tag value, at what strength, from which source, and at what time.

## Files

- Migration: `DataBase/migrations/011_create_profile_tag_observations.sql`
- Seed: `DataBase/seeds/011_seed_profile_tag_observations.sql`
- Validation: `DataBase/validations/011_validate_profile_tag_observations.sql`

## Current Scope

The seed data uses real Tmall and Douyin tag values from `platform_tag_catalog`,
but the subjects are sample subjects. When PLS provides real profile or audience
records, insert them into this table with the same structure.

## Next Work

Create a read view that joins observations to
`v_pls_platform_tag_value_semantics`, so downstream products can read subject
tags and PLS dimensions from one surface.
