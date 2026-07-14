# View 027: `v_platform_profile_channel_feature_matrix`

## Purpose

`v_platform_profile_channel_feature_matrix` pivots real platform profile metrics
into a PLS nine-dimension wide table.

Rows are separated by channel object, `metric_name`, `metric_unit`,
`profile_time_window`, and `source_batch_id`.

## Files

- Migration: `DataBase/migrations/027_create_v_platform_profile_channel_feature_matrix.sql`
- Validation: `DataBase/validations/027_validate_v_platform_profile_channel_feature_matrix.sql`
