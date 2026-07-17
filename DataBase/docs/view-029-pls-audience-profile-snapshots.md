# View 029: `v_pls_audience_profile_snapshots`

## Purpose

`v_pls_audience_profile_snapshots` is the minimal read surface for PLS audience
profile snapshot metadata.

It exposes one row per active source audience profile snapshot, keyed by
`workspace_id`, `profile_id`, and `data_version`.

## Why This View Exists

`v_pls_audience_tag_semantics` is tag-semantics row grain. It intentionally drops
profiles that have no tags or no approved tag mapping. Products that only need
snapshot metadata should not infer snapshot existence from tag semantics rows.

This view reads directly from `pls_audience_profiles` and only requires a
version-matched active `pls_channel_objects` row:

```text
pls_channel_objects
  -> pls_audience_profiles
  -> v_pls_audience_profile_snapshots
```

## Files

- Migration: `DataBase/migrations/029_create_v_pls_audience_profile_snapshots.sql`
- Validation: `DataBase/validations/029_validate_v_pls_audience_profile_snapshots.sql`

## Read Rules

Read from this view when a product needs stable audience profile snapshot
metadata without tag-level evidence.

Write only to the source tables:

- `pls_channel_objects`
- `pls_audience_profiles`

Do not write directly to the view.

## Columns

The view exposes only these columns, in this order:

1. `workspace_id`
2. `profile_id`
3. `canonical_object_key`
4. `data_version`
5. `source_batch_id`
6. `generated_at`
7. `time_window`
8. `sample_size`
9. `confidence`
10. `quality_flags_json`

It does not expose `tags_json`, `unmapped_fields_json`, `raw_json`, display
fields, object fields, or derived quality status.

## Filters

- `pls_audience_profiles.status = 'active'`.
- The version-matched `pls_channel_objects` row must have `status = 'active'`.
- Source values are projected as-is; missing nullable values remain `NULL`.
