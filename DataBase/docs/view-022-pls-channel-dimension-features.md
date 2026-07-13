# View 022: `v_pls_channel_dimension_features`

## Purpose

`v_pls_channel_dimension_features` aggregates PLS audience tag semantics into
channel-object-level PLS dimension features.

It groups by:

```text
canonical_object_key + dimension_code
```

## Why This View Exists

`v_pls_audience_tag_semantics` is tag-level and explainable. Products and models
also need compact dimension-level features for each channel object:

```text
v_pls_audience_tag_semantics
  -> v_pls_channel_dimension_features
```

## Scoring Rule

Current first version:

```text
dimension_score = sum(tag_score)
```

The view also keeps `avg_tag_score`, `max_tag_score`,
`avg_tag_confidence`, and `avg_mapping_confidence` for explainability and future
feature engineering.

## Files

- Migration: `DataBase/migrations/022_create_v_pls_channel_dimension_features.sql`
- Validation: `DataBase/validations/022_validate_v_pls_channel_dimension_features.sql`

## Read Rules

Read from this view when a product or model needs channel-level PLS dimension
features.

Write only to the source tables:

- `pls_audience_profiles`
- `pls_audience_tag_dimension_mappings`

Do not write directly to the view.

## Next Work

Create a wide feature matrix view with one row per `canonical_object_key` and
nine PLS dimension score columns.
