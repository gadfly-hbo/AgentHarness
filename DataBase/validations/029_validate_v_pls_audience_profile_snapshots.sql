.bail on
.headers on
.mode column

PRAGMA foreign_keys = ON;

SELECT
  'view_exists' AS check_name,
  COUNT(*) AS actual,
  1 AS expected,
  CASE WHEN COUNT(*) = 1 THEN 'pass' ELSE 'fail' END AS result
FROM sqlite_master
WHERE type = 'view'
  AND name = 'v_pls_audience_profile_snapshots';

SELECT
  'exact_column_order' AS check_name,
  group_concat(name, ',') AS actual,
  'workspace_id,profile_id,canonical_object_key,data_version,source_batch_id,generated_at,time_window,sample_size,confidence,quality_flags_json' AS expected,
  CASE
    WHEN group_concat(name, ',') = 'workspace_id,profile_id,canonical_object_key,data_version,source_batch_id,generated_at,time_window,sample_size,confidence,quality_flags_json'
    THEN 'pass'
    ELSE 'fail'
  END AS result
FROM pragma_table_info('v_pls_audience_profile_snapshots')
ORDER BY cid;

WITH expected_rows AS (
  SELECT COUNT(*) AS count
  FROM pls_audience_profiles profiles
  JOIN pls_channel_objects objects
    ON objects.workspace_id = profiles.workspace_id
    AND objects.canonical_object_key = profiles.canonical_object_key
    AND objects.data_version = profiles.data_version
    AND objects.status = 'active'
  WHERE profiles.status = 'active'
),
actual_rows AS (
  SELECT COUNT(*) AS count
  FROM v_pls_audience_profile_snapshots
)
SELECT
  'active_profile_snapshot_count' AS check_name,
  actual_rows.count AS actual,
  expected_rows.count AS expected,
  CASE WHEN actual_rows.count = expected_rows.count THEN 'pass' ELSE 'fail' END AS result
FROM actual_rows, expected_rows;

SELECT
  'business_key_duplicates' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM (
  SELECT workspace_id, profile_id, data_version
  FROM v_pls_audience_profile_snapshots
  GROUP BY workspace_id, profile_id, data_version
  HAVING COUNT(*) > 1
);

SELECT
  'invalid_quality_flags_json' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM v_pls_audience_profile_snapshots
WHERE json_valid(quality_flags_json) = 0
  OR json_type(quality_flags_json) <> 'array';

BEGIN;

INSERT INTO pls_channel_objects (
  id,
  workspace_id,
  object_type,
  target_object,
  source_stable_key,
  key_source,
  canonical_object_key,
  object_version_id,
  data_version,
  source_batch_id,
  generated_at,
  time_window,
  display_name,
  source,
  source_type,
  raw_json,
  status
)
VALUES
  (
    'pco_validation_snapshot_active_029',
    'ws_validation_029',
    'account',
    'ChannelEntity',
    'validation_snapshot_active_029',
    'source_system_id',
    'account:validation_snapshot_active_029',
    'ws_validation_029:account:validation_snapshot_active_029:v_validation_029',
    'v_validation_029',
    'validation_v_pls_audience_profile_snapshots_029',
    '2026-07-17T00:00:00Z',
    '2026-07-01/2026-07-17',
    'Validation Snapshot Active Object',
    'validation',
    'validation',
    '{"validation":"v_pls_audience_profile_snapshots"}',
    'active'
  ),
  (
    'pco_validation_snapshot_inactive_029',
    'ws_validation_029',
    'account',
    'ChannelEntity',
    'validation_snapshot_inactive_029',
    'source_system_id',
    'account:validation_snapshot_inactive_029',
    'ws_validation_029:account:validation_snapshot_inactive_029:v_validation_029',
    'v_validation_029',
    'validation_v_pls_audience_profile_snapshots_029',
    '2026-07-17T00:00:00Z',
    '2026-07-01/2026-07-17',
    'Validation Snapshot Inactive Object',
    'validation',
    'validation',
    '{"validation":"v_pls_audience_profile_snapshots"}',
    'inactive'
  );

INSERT INTO pls_audience_profiles (
  id,
  workspace_id,
  profile_id,
  canonical_object_key,
  source,
  source_batch_id,
  data_version,
  generated_at,
  time_window,
  sample_size,
  confidence,
  tags_json,
  unmapped_fields_json,
  quality_flags_json,
  raw_json,
  status
)
VALUES
  (
    'pap_validation_snapshot_active_029',
    'ws_validation_029',
    'audience_validation_active_029',
    'account:validation_snapshot_active_029',
    'validation',
    'validation_v_pls_audience_profile_snapshots_029',
    'v_validation_029',
    '2026-07-17T01:00:00Z',
    '2026-07-01/2026-07-17',
    NULL,
    0.42,
    '[]',
    '[]',
    '["validation_flag"]',
    '{"validation":"active_profile_without_semantics"}',
    'active'
  ),
  (
    'pap_validation_snapshot_inactive_profile_029',
    'ws_validation_029',
    'audience_validation_inactive_profile_029',
    'account:validation_snapshot_active_029',
    'validation',
    'validation_v_pls_audience_profile_snapshots_029',
    'v_validation_029',
    '2026-07-17T01:00:00Z',
    '2026-07-01/2026-07-17',
    9,
    0.91,
    '[]',
    '[]',
    '[]',
    '{"validation":"inactive_profile"}',
    'inactive'
  ),
  (
    'pap_validation_snapshot_inactive_object_029',
    'ws_validation_029',
    'audience_validation_inactive_object_029',
    'account:validation_snapshot_inactive_029',
    'validation',
    'validation_v_pls_audience_profile_snapshots_029',
    'v_validation_029',
    '2026-07-17T01:00:00Z',
    '2026-07-01/2026-07-17',
    8,
    0.81,
    '[]',
    '[]',
    '[]',
    '{"validation":"inactive_object"}',
    'active'
  );

SELECT
  'active_profile_without_semantics_visible' AS check_name,
  COUNT(*) AS actual,
  1 AS expected,
  CASE WHEN COUNT(*) = 1 THEN 'pass' ELSE 'fail' END AS result
FROM v_pls_audience_profile_snapshots snapshots
WHERE snapshots.workspace_id = 'ws_validation_029'
  AND snapshots.profile_id = 'audience_validation_active_029'
  AND snapshots.data_version = 'v_validation_029';

SELECT
  'active_profile_has_no_tag_semantics_but_snapshot_visible' AS check_name,
  SUM(CASE WHEN semantics.profile_id IS NULL THEN 0 ELSE 1 END) AS actual_semantics_rows,
  0 AS expected_semantics_rows,
  CASE
    WHEN COUNT(snapshots.profile_id) = 1
      AND SUM(CASE WHEN semantics.profile_id IS NULL THEN 0 ELSE 1 END) = 0
    THEN 'pass'
    ELSE 'fail'
  END AS result
FROM v_pls_audience_profile_snapshots snapshots
LEFT JOIN v_pls_audience_tag_semantics semantics
  ON semantics.workspace_id = snapshots.workspace_id
  AND semantics.profile_id = snapshots.profile_id
  AND semantics.data_version = snapshots.data_version
WHERE snapshots.workspace_id = 'ws_validation_029'
  AND snapshots.profile_id = 'audience_validation_active_029'
  AND snapshots.data_version = 'v_validation_029';

SELECT
  'inactive_profile_absent' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM v_pls_audience_profile_snapshots
WHERE workspace_id = 'ws_validation_029'
  AND profile_id = 'audience_validation_inactive_profile_029';

SELECT
  'inactive_object_profile_absent' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM v_pls_audience_profile_snapshots
WHERE workspace_id = 'ws_validation_029'
  AND profile_id = 'audience_validation_inactive_object_029';

SELECT
  'source_values_not_defaulted' AS check_name,
  source_batch_id || '|' || generated_at || '|' || time_window || '|' || COALESCE(CAST(sample_size AS TEXT), 'NULL') || '|' || CAST(confidence AS TEXT) || '|' || quality_flags_json AS actual,
  'validation_v_pls_audience_profile_snapshots_029|2026-07-17T01:00:00Z|2026-07-01/2026-07-17|NULL|0.42|["validation_flag"]' AS expected,
  CASE
    WHEN source_batch_id = 'validation_v_pls_audience_profile_snapshots_029'
      AND generated_at = '2026-07-17T01:00:00Z'
      AND time_window = '2026-07-01/2026-07-17'
      AND sample_size IS NULL
      AND confidence = 0.42
      AND quality_flags_json = '["validation_flag"]'
    THEN 'pass'
    ELSE 'fail'
  END AS result
FROM v_pls_audience_profile_snapshots
WHERE workspace_id = 'ws_validation_029'
  AND profile_id = 'audience_validation_active_029'
  AND data_version = 'v_validation_029';

ROLLBACK;

SELECT
  'validation_rows_rolled_back' AS check_name,
  (
    SELECT COUNT(*) FROM pls_audience_profiles
    WHERE source_batch_id = 'validation_v_pls_audience_profile_snapshots_029'
  ) + (
    SELECT COUNT(*) FROM pls_channel_objects
    WHERE source_batch_id = 'validation_v_pls_audience_profile_snapshots_029'
  ) AS actual,
  0 AS expected,
  CASE
    WHEN (
      SELECT COUNT(*) FROM pls_audience_profiles
      WHERE source_batch_id = 'validation_v_pls_audience_profile_snapshots_029'
    ) + (
      SELECT COUNT(*) FROM pls_channel_objects
      WHERE source_batch_id = 'validation_v_pls_audience_profile_snapshots_029'
    ) = 0
    THEN 'pass'
    ELSE 'fail'
  END AS result;
