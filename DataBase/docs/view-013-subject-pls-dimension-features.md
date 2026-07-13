# View 013: `v_subject_pls_dimension_features`

## Purpose

`v_subject_pls_dimension_features` aggregates subject-level tag observations into
PLS dimension features.

It turns detailed tag observations into feature rows:

```text
subject + PLS dimension -> counts and weights
```

## Why This View Exists

PLS and ModelEvol often need feature vectors rather than raw tag details. This
view provides a compact subject-level read surface with:

- observation count
- total, average, and max weight
- platform coverage
- tag type and tag value diversity
- first and latest observed timestamps

## Files

- Migration: `DataBase/migrations/013_create_v_subject_pls_dimension_features.sql`
- Validation: `DataBase/validations/013_validate_v_subject_pls_dimension_features.sql`

## Consumption Guidance

Use this view when a model or product needs PLS dimension-level features. Use
`v_profile_tag_observation_semantics` when it needs tag-level explainability.
