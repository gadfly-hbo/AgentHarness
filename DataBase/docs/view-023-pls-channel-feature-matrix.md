# View 023: `v_pls_channel_feature_matrix`

## Purpose

`v_pls_channel_feature_matrix` pivots channel-level PLS dimension features into
one row per channel object with nine PLS score columns.

## Why This View Exists

PLS products and ModelEvol usually need compact feature rows:

```text
one channel object -> nine PLS dimension scores
```

This view is the wide feature matrix built from:

```text
v_pls_channel_dimension_features
  -> v_pls_channel_feature_matrix
```

## Scoring Rule

Current first version:

```text
dimension score = sum(tag_score)
total_feature_score = sum(all dimension scores)
```

The view does not normalize, decay, or model-transform scores. Those operations
should live in a separate feature engineering or ModelEvol layer.

## Files

- Migration: `DataBase/migrations/023_create_v_pls_channel_feature_matrix.sql`
- Validation: `DataBase/validations/023_validate_v_pls_channel_feature_matrix.sql`

## Read Rules

Read from this view when PLS or ModelEvol needs one-row-per-channel-object
features.

Use `v_pls_channel_dimension_features` for row-level explainability.

Do not write directly to this view.

## Next Work

Use this view as the first database-backed feature input for PLS channel
matching and ModelEvol experiments.
