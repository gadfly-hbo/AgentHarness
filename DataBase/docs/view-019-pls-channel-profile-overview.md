# View 019: `v_pls_channel_profile_overview`

## Purpose

`v_pls_channel_profile_overview` is the product-facing read view for PLS channel
profiles.

It joins:

- `pls_channel_objects`
- `pls_audience_profiles`
- `pls_product_fit_profiles`

## Why This View Exists

PLS products usually need to show one channel profile card, not three separate
tables. This view keeps the source tables normalized while giving product
screens a single read surface for:

- channel object identity
- object governance status
- audience profile summary
- product-fit profile summary
- profile coverage status

## Files

- Migration: `DataBase/migrations/019_create_v_pls_channel_profile_overview.sql`
- Validation: `DataBase/validations/019_validate_v_pls_channel_profile_overview.sql`

## Read Rules

Read from this view when a product needs a channel profile overview.

Write only to the source tables:

- `pls_channel_objects`
- `pls_audience_profiles`
- `pls_product_fit_profiles`

Do not write directly to the view.

## Coverage Status

`profile_coverage_status` can be:

- `complete`: both audience and product-fit profiles exist.
- `audience_only`: only audience profile exists.
- `product_fit_only`: only product-fit profile exists.
- `object_only`: only channel object master data exists.

## Next Work

Create a mapping layer from PLS channel-profile taxonomy tags in
`pls_audience_profiles.tags_json` into the PLS three-layer, nine-dimension
semantic model.
