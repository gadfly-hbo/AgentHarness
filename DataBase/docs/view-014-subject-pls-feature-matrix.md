# View 014: `v_subject_pls_feature_matrix`

## Purpose

`v_subject_pls_feature_matrix` pivots subject-level PLS dimension features into
a model- and report-friendly wide matrix.

Each row is one subject. The nine PLS dimensions are exposed as score columns.

## Why This View Exists

ModelEvol, reports, and profile cards usually prefer one row per subject rather
than one row per subject-dimension pair. This view provides stable feature
columns for direct consumption:

```text
subject_id -> nine PLS dimension scores
```

## Files

- Migration: `DataBase/migrations/014_create_v_subject_pls_feature_matrix.sql`
- Validation: `DataBase/validations/014_validate_v_subject_pls_feature_matrix.sql`

## Consumption Guidance

Use this view when a downstream consumer needs compact feature vectors. Use
`v_subject_pls_dimension_features` for dimension-row analytics and
`v_profile_tag_observation_semantics` for tag-level explainability.
