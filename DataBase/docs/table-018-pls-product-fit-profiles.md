# Table 018: `pls_product_fit_profiles`

## Purpose

`pls_product_fit_profiles` stores product-fit profile snapshots for PLS channel
objects.

It is the fourth landing table for the PLS “渠道画像” module in AgentHarness:

```text
PLS channel object library
  -> pls_channel_objects
  -> pls_channel_object_bindings
  -> pls_audience_profiles
  -> pls_product_fit_profiles
```

## Why This Table Exists

渠道画像的第一阶段另一个核心问题是：

```text
这个渠道对象适合卖什么商品？
```

This table preserves the product-fit profile as imported from PLS, including
fit categories, price bands, styles, occasions, launch types, evidence,
confidence, quality flags, and raw JSON.

## Files

- Migration: `DataBase/migrations/018_create_pls_product_fit_profiles.sql`
- Seed: `DataBase/seeds/018_seed_pls_product_fit_profiles.sql`
- Validation: `DataBase/validations/018_validate_pls_product_fit_profiles.sql`

## Current Scope

The seed data uses two mock product-fit profiles from the PLS channel profile
2.0 sample package:

- account product-fit profile
- store product-fit profile

The table enforces a foreign key back to `pls_channel_objects` using
`workspace_id`, `canonical_object_key`, and `data_version`.

## Important Note

Manual configuration rows may have `sample_size` and `time_window` set to
`NULL`. Do not fabricate statistical evidence for manually configured
product-fit profiles.

## Next Work

Create a read view that joins channel objects, audience profiles, and product
fit profiles into one product-facing channel profile surface.
