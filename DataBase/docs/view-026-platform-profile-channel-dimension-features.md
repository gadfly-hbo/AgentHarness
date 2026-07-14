# View 026: `v_platform_profile_channel_dimension_features`

## Purpose

`v_platform_profile_channel_dimension_features` aggregates real profile metrics
by channel object, metric name, and PLS dimension.

It intentionally keeps `metric_name`, `metric_unit`, `profile_time_window`, and
`source_batch_id` in the grouping so that share, TGI, count, index, score, and
different import batches are not mixed.

## Files

- Migration: `DataBase/migrations/026_create_v_platform_profile_channel_dimension_features.sql`
- Validation: `DataBase/validations/026_validate_v_platform_profile_channel_dimension_features.sql`
