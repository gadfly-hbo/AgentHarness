# View 021: `v_pls_audience_tag_semantics`

## Purpose

`v_pls_audience_tag_semantics` expands `pls_audience_profiles.tags_json` into
one row per audience tag and joins each tag to the PLS three-layer,
nine-dimension semantic model.

## Why This View Exists

PLS channel-profile audience tags are stored as JSON arrays because they arrive
from PLS import packages as nested profile snapshots. Products and models need a
row-based surface for analysis and aggregation:

```text
pls_audience_profiles.tags_json
  -> pls_audience_tag_dimension_mappings
  -> pls_semantic_dimensions
  -> v_pls_audience_tag_semantics
```

## Files

- Migration: `DataBase/migrations/021_create_v_pls_audience_tag_semantics.sql`
- Validation: `DataBase/validations/021_validate_v_pls_audience_tag_semantics.sql`

## Read Rules

Read from this view when a product or model needs tag-level explainability for
channel audience profiles.

Write only to the source tables:

- `pls_audience_profiles`
- `pls_audience_tag_dimension_mappings`
- `pls_semantic_dimensions`

Do not write directly to the view.

## Next Work

Create a channel-level PLS feature aggregation view that groups this view by
`canonical_object_key` and `dimension_code`.
