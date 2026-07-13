# View 007: `v_pls_tag_type_mapping_review_queue`

## Purpose

`v_pls_tag_type_mapping_review_queue` is a SQLite view for reviewing platform
tag type to PLS dimension mappings.

It does not copy data. It orders existing mappings from
`pls_tag_type_dimension_mappings` by review urgency and joins tag counts from
`platform_tag_catalog`.

## Files

- Migration: `DataBase/migrations/007_create_v_pls_tag_type_mapping_review_queue.sql`
- Validation: `DataBase/validations/007_validate_v_pls_tag_type_mapping_review_queue.sql`

## Review Priority

```text
1 = unmapped
2 = review_needed
3 = proposed
9 = not in normal review flow
```

## Review Actions

- `unmapped`: choose a PLS dimension manually.
- `review_needed`: confirm or correct the suggested dimension.
- `proposed`: spot-check, then approve in batches.

## Next Step

Use this view to review high-impact unmapped tag types first. High-impact means
large `tag_count`, because one tag type can cover many platform label values.
