# View 012: `v_profile_tag_observation_semantics`

## Purpose

`v_profile_tag_observation_semantics` is the read surface for consuming subject
tag observations as PLS semantic features.

It joins:

```text
profile_tag_observations -> v_pls_platform_tag_value_semantics
```

## Why This View Exists

PLS and ModelEvol should not need to join the observation fact table, platform
catalog, tag value mappings, and semantic dimension tables for every read. This
view gives them one query surface with:

- subject identity
- observed platform tag value
- observation weight and source
- PLS layer and dimension
- mapping confidence and rationale

## Files

- Migration: `DataBase/migrations/012_create_v_profile_tag_observation_semantics.sql`
- Validation: `DataBase/validations/012_validate_v_profile_tag_observation_semantics.sql`

## Consumption Guidance

Use this view for read-only profile and feature consumption. Write new raw
observations to `profile_tag_observations`. Correct tag semantics in
`pls_tag_value_dimension_mappings`.
