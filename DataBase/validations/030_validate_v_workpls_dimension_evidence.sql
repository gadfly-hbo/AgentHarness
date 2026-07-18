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
  AND name = 'v_workpls_dimension_evidence';

SELECT
  'exact_column_order' AS check_name,
  group_concat(name, ',') AS actual,
  'workspace_id,snapshot_id,profile_id,canonical_object_key,data_version,metric_name,metric_aggregation,dimension_key,dimension_label,value,unit,profile_time_window,source_batch_id,source_quality_flags_json,source_evidence_refs_json,metric_row_count,tag_type_count,tag_value_count,avg_mapping_confidence,latest_metric_updated_at,latest_mapping_updated_at' AS expected,
  CASE
    WHEN group_concat(name, ',') = 'workspace_id,snapshot_id,profile_id,canonical_object_key,data_version,metric_name,metric_aggregation,dimension_key,dimension_label,value,unit,profile_time_window,source_batch_id,source_quality_flags_json,source_evidence_refs_json,metric_row_count,tag_type_count,tag_value_count,avg_mapping_confidence,latest_metric_updated_at,latest_mapping_updated_at'
    THEN 'pass'
    ELSE 'fail'
  END AS result
FROM pragma_table_info('v_workpls_dimension_evidence')
ORDER BY cid;

SELECT
  'business_key_duplicates' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM (
  SELECT
    workspace_id,
    profile_id,
    canonical_object_key,
    data_version,
    metric_name,
    unit,
    profile_time_window,
    source_batch_id,
    dimension_key
  FROM v_workpls_dimension_evidence
  GROUP BY
    workspace_id,
    profile_id,
    canonical_object_key,
    data_version,
    metric_name,
    unit,
    profile_time_window,
    source_batch_id,
    dimension_key
  HAVING COUNT(*) > 1
);

SELECT
  'snapshot_binding_unique' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM v_workpls_dimension_evidence evidence
WHERE (
  SELECT COUNT(*)
  FROM v_pls_audience_profile_snapshots snapshots
  WHERE snapshots.workspace_id = evidence.workspace_id
    AND snapshots.profile_id = evidence.profile_id
    AND snapshots.canonical_object_key = evidence.canonical_object_key
    AND snapshots.data_version = evidence.data_version
    AND snapshots.source_batch_id = evidence.source_batch_id
    AND snapshots.time_window = evidence.profile_time_window
) != 1;

SELECT
  'finite_value' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM v_workpls_dimension_evidence
WHERE value IS NULL
  OR value != value
  OR value <= -1.0e308
  OR value >= 1.0e308;

SELECT
  'required_text_not_empty' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM v_workpls_dimension_evidence
WHERE metric_name IS NULL OR metric_name = ''
  OR unit IS NULL OR unit = ''
  OR dimension_key IS NULL OR dimension_key = ''
  OR dimension_label IS NULL OR dimension_label = '';

SELECT
  'metric_aggregation_sum' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM v_workpls_dimension_evidence
WHERE metric_aggregation != 'sum';

SELECT
  'source_quality_flags_json_array' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM v_workpls_dimension_evidence
WHERE json_valid(source_quality_flags_json) = 0
  OR json_type(source_quality_flags_json) <> 'array';

SELECT
  'source_evidence_refs_json_array' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM v_workpls_dimension_evidence
WHERE json_valid(source_evidence_refs_json) = 0
  OR json_type(source_evidence_refs_json) <> 'array'
  OR json_array_length(source_evidence_refs_json) = 0;

SELECT
  'source_evidence_refs_required_fields' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM v_workpls_dimension_evidence evidence
JOIN json_each(evidence.source_evidence_refs_json) refs
WHERE json_extract(refs.value, '$.sourceSystem') != 'agentharness'
  OR json_extract(refs.value, '$.sourceRecordType') != 'platform_profile_tag_metric'
  OR COALESCE(json_extract(refs.value, '$.sourceRecordId'), '') = ''
  OR COALESCE(json_extract(refs.value, '$.sourceBatchId'), '') = ''
  OR COALESCE(json_extract(refs.value, '$.sourceFile'), '') = ''
  OR json_extract(refs.value, '$.sourceRow') IS NULL
  OR COALESCE(json_extract(refs.value, '$.platformTagCatalogId'), '') = '';

SELECT
  'forbidden_columns_absent' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pragma_table_info('v_workpls_dimension_evidence')
WHERE name IN (
  'dimension_metric_avg',
  'dimension_metric_max',
  'dimension_score',
  'raw_json',
  'rowid',
  'quality_status',
  'source_view_name'
);

SELECT
  'field_comments_complete' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pragma_table_info('v_workpls_dimension_evidence') fields
LEFT JOIN database_field_comments comments
  ON comments.table_name = 'v_workpls_dimension_evidence'
  AND comments.field_name = fields.name
  AND comments.status = 'active'
WHERE comments.id IS NULL;

BEGIN;

INSERT INTO platform_tag_catalog (
  id,
  platform,
  tag_type,
  leaf_label,
  label_path,
  source_file,
  source_row,
  status
)
VALUES
  ('ptag_validation_workpls_030_valid', 'validation_platform_030', 'validation_tag_type_030', 'validation_leaf_030', 'validation_tag_type_030 > validation_leaf_030', 'validation_workpls_dimension_evidence_030.csv', 1, 'active'),
  ('ptag_validation_workpls_030_no_snapshot', 'validation_platform_030', 'validation_tag_type_030', 'validation_leaf_no_snapshot_030', 'validation_tag_type_030 > validation_leaf_no_snapshot_030', 'validation_workpls_dimension_evidence_030.csv', 2, 'active'),
  ('ptag_validation_workpls_030_multi_snapshot', 'validation_platform_030', 'validation_tag_type_030', 'validation_leaf_multi_snapshot_030', 'validation_tag_type_030 > validation_leaf_multi_snapshot_030', 'validation_workpls_dimension_evidence_030.csv', 3, 'active');

INSERT INTO pls_tag_type_dimension_mappings (
  id,
  platform,
  tag_type,
  dimension_id,
  mapping_status,
  mapping_method,
  confidence,
  rationale,
  source_ref,
  status
)
SELECT
  'ptypemap_validation_workpls_030',
  'validation_platform_030',
  'validation_tag_type_030',
  id,
  'approved',
  'manual',
  1.0,
  'validation mapping for v_workpls_dimension_evidence',
  'DataBase/validations/030_validate_v_workpls_dimension_evidence.sql',
  'active'
FROM pls_semantic_dimensions
WHERE dimension_code = 'P_DEMOGRAPHICS';

INSERT INTO pls_tag_value_dimension_mappings (
  id,
  platform_tag_catalog_id,
  platform,
  tag_type,
  leaf_label,
  label_path,
  dimension_id,
  inherited_tag_type_mapping_id,
  mapping_status,
  mapping_method,
  confidence,
  rationale,
  source_ref,
  status
)
SELECT
  'pvalmap_validation_workpls_030_valid',
  'ptag_validation_workpls_030_valid',
  'validation_platform_030',
  'validation_tag_type_030',
  'validation_leaf_030',
  'validation_tag_type_030 > validation_leaf_030',
  id,
  'ptypemap_validation_workpls_030',
  'approved',
  'manual',
  1.0,
  'validation mapping for valid evidence',
  'DataBase/validations/030_validate_v_workpls_dimension_evidence.sql',
  'active'
FROM pls_semantic_dimensions
WHERE dimension_code = 'P_DEMOGRAPHICS';

INSERT INTO pls_tag_value_dimension_mappings (
  id,
  platform_tag_catalog_id,
  platform,
  tag_type,
  leaf_label,
  label_path,
  dimension_id,
  inherited_tag_type_mapping_id,
  mapping_status,
  mapping_method,
  confidence,
  rationale,
  source_ref,
  status
)
SELECT
  'pvalmap_validation_workpls_030_no_snapshot',
  'ptag_validation_workpls_030_no_snapshot',
  'validation_platform_030',
  'validation_tag_type_030',
  'validation_leaf_no_snapshot_030',
  'validation_tag_type_030 > validation_leaf_no_snapshot_030',
  id,
  'ptypemap_validation_workpls_030',
  'approved',
  'manual',
  1.0,
  'validation mapping for missing snapshot fail closed',
  'DataBase/validations/030_validate_v_workpls_dimension_evidence.sql',
  'active'
FROM pls_semantic_dimensions
WHERE dimension_code = 'P_DEMOGRAPHICS';

INSERT INTO pls_tag_value_dimension_mappings (
  id,
  platform_tag_catalog_id,
  platform,
  tag_type,
  leaf_label,
  label_path,
  dimension_id,
  inherited_tag_type_mapping_id,
  mapping_status,
  mapping_method,
  confidence,
  rationale,
  source_ref,
  status
)
SELECT
  'pvalmap_validation_workpls_030_multi_snapshot',
  'ptag_validation_workpls_030_multi_snapshot',
  'validation_platform_030',
  'validation_tag_type_030',
  'validation_leaf_multi_snapshot_030',
  'validation_tag_type_030 > validation_leaf_multi_snapshot_030',
  id,
  'ptypemap_validation_workpls_030',
  'approved',
  'manual',
  1.0,
  'validation mapping for ambiguous snapshot fail closed',
  'DataBase/validations/030_validate_v_workpls_dimension_evidence.sql',
  'active'
FROM pls_semantic_dimensions
WHERE dimension_code = 'P_DEMOGRAPHICS';

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
  ('pco_validation_workpls_030_valid', 'ws_validation_workpls_030', 'account', 'ChannelEntity', 'valid_030', 'source_system_id', 'account:validation_workpls_030_valid', 'ws_validation_workpls_030:account:validation_workpls_030_valid:v_validation_030', 'v_validation_030', 'batch_validation_workpls_030', '2026-07-18T00:00:00Z', '2026-07-01/2026-07-18', 'Validation WorkPLS Valid Object', 'validation', 'validation', '{"validation":"v_workpls_dimension_evidence"}', 'active'),
  ('pco_validation_workpls_030_multi_v1', 'ws_validation_workpls_030', 'account', 'ChannelEntity', 'multi_030', 'source_system_id', 'account:validation_workpls_030_multi', 'ws_validation_workpls_030:account:validation_workpls_030_multi:v_validation_030_a', 'v_validation_030_a', 'batch_validation_workpls_030_multi', '2026-07-18T00:00:00Z', '2026-07-01/2026-07-18', 'Validation WorkPLS Multi Object A', 'validation', 'validation', '{"validation":"v_workpls_dimension_evidence"}', 'active'),
  ('pco_validation_workpls_030_multi_v2', 'ws_validation_workpls_030', 'account', 'ChannelEntity', 'multi_030', 'source_system_id', 'account:validation_workpls_030_multi', 'ws_validation_workpls_030:account:validation_workpls_030_multi:v_validation_030_b', 'v_validation_030_b', 'batch_validation_workpls_030_multi', '2026-07-18T00:00:00Z', '2026-07-01/2026-07-18', 'Validation WorkPLS Multi Object B', 'validation', 'validation', '{"validation":"v_workpls_dimension_evidence"}', 'active'),
  ('pco_validation_workpls_030_cross_workspace', 'ws_validation_workpls_030_other', 'account', 'ChannelEntity', 'cross_workspace_030', 'source_system_id', 'account:validation_workpls_030_no_snapshot', 'ws_validation_workpls_030_other:account:validation_workpls_030_no_snapshot:v_validation_030', 'v_validation_030', 'batch_validation_workpls_030_no_snapshot', '2026-07-18T00:00:00Z', '2026-07-01/2026-07-18', 'Validation WorkPLS Cross Workspace Object', 'validation', 'validation', '{"validation":"v_workpls_dimension_evidence"}', 'active');

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
  ('pap_validation_workpls_030_valid', 'ws_validation_workpls_030', 'profile_validation_workpls_030_valid', 'account:validation_workpls_030_valid', 'validation', 'batch_validation_workpls_030', 'v_validation_030', '2026-07-18T01:00:00Z', '2026-07-01/2026-07-18', 100, 0.9, '[]', '[]', '["validation_flag"]', '{"validation":"v_workpls_dimension_evidence"}', 'active'),
  ('pap_validation_workpls_030_multi_v1', 'ws_validation_workpls_030', 'profile_validation_workpls_030_multi', 'account:validation_workpls_030_multi', 'validation', 'batch_validation_workpls_030_multi', 'v_validation_030_a', '2026-07-18T01:00:00Z', '2026-07-01/2026-07-18', 100, 0.9, '[]', '[]', '[]', '{"validation":"v_workpls_dimension_evidence"}', 'active'),
  ('pap_validation_workpls_030_multi_v2', 'ws_validation_workpls_030', 'profile_validation_workpls_030_multi', 'account:validation_workpls_030_multi', 'validation', 'batch_validation_workpls_030_multi', 'v_validation_030_b', '2026-07-18T01:00:00Z', '2026-07-01/2026-07-18', 100, 0.9, '[]', '[]', '[]', '{"validation":"v_workpls_dimension_evidence"}', 'active'),
  ('pap_validation_workpls_030_cross_workspace', 'ws_validation_workpls_030_other', 'profile_validation_workpls_030_no_snapshot', 'account:validation_workpls_030_no_snapshot', 'validation', 'batch_validation_workpls_030_no_snapshot', 'v_validation_030', '2026-07-18T01:00:00Z', '2026-07-01/2026-07-18', 100, 0.9, '[]', '[]', '[]', '{"validation":"v_workpls_dimension_evidence"}', 'active');

INSERT INTO platform_profile_tag_metrics (
  id,
  workspace_id,
  profile_id,
  canonical_object_key,
  channel_object_type,
  channel_object_name,
  platform,
  platform_tag_catalog_id,
  tag_type,
  leaf_label,
  metric_name,
  metric_value,
  metric_unit,
  metric_display_value,
  profile_time_window,
  sample_size,
  source_file,
  source_row,
  source_batch_id,
  raw_json,
  status
)
VALUES
  ('pptm_validation_workpls_030_valid', 'ws_validation_workpls_030', 'profile_validation_workpls_030_valid', 'account:validation_workpls_030_valid', 'account', 'Validation WorkPLS Valid Object', 'validation_platform_030', 'ptag_validation_workpls_030_valid', 'validation_tag_type_030', 'validation_leaf_030', 'share', 12.5, 'percent', '12.5%', '2026-07-01/2026-07-18', 100, 'validation_workpls_dimension_evidence_030.csv', 1, 'batch_validation_workpls_030', '{"validation":"valid"}', 'active'),
  ('pptm_validation_workpls_030_no_snapshot', 'ws_validation_workpls_030', 'profile_validation_workpls_030_no_snapshot', 'account:validation_workpls_030_no_snapshot', 'account', 'Validation WorkPLS No Snapshot Object', 'validation_platform_030', 'ptag_validation_workpls_030_no_snapshot', 'validation_tag_type_030', 'validation_leaf_no_snapshot_030', 'share', 8.0, 'percent', '8.0%', '2026-07-01/2026-07-18', 100, 'validation_workpls_dimension_evidence_030.csv', 2, 'batch_validation_workpls_030_no_snapshot', '{"validation":"no_snapshot"}', 'active'),
  ('pptm_validation_workpls_030_multi_snapshot', 'ws_validation_workpls_030', 'profile_validation_workpls_030_multi', 'account:validation_workpls_030_multi', 'account', 'Validation WorkPLS Multi Snapshot Object', 'validation_platform_030', 'ptag_validation_workpls_030_multi_snapshot', 'validation_tag_type_030', 'validation_leaf_multi_snapshot_030', 'share', 9.0, 'percent', '9.0%', '2026-07-01/2026-07-18', 100, 'validation_workpls_dimension_evidence_030.csv', 3, 'batch_validation_workpls_030_multi', '{"validation":"multi_snapshot"}', 'active');

SELECT
  'validation_valid_evidence_visible' AS check_name,
  COUNT(*) AS actual,
  1 AS expected,
  CASE WHEN COUNT(*) = 1 THEN 'pass' ELSE 'fail' END AS result
FROM v_workpls_dimension_evidence
WHERE workspace_id = 'ws_validation_workpls_030'
  AND profile_id = 'profile_validation_workpls_030_valid'
  AND canonical_object_key = 'account:validation_workpls_030_valid'
  AND data_version = 'v_validation_030'
  AND metric_name = 'share'
  AND unit = 'percent'
  AND metric_aggregation = 'sum'
  AND dimension_key = 'P_DEMOGRAPHICS'
  AND value = 12.5
  AND source_quality_flags_json = '["validation_flag"]'
  AND json_array_length(source_evidence_refs_json) = 1;

SELECT
  'workspace_filtering_no_cross_workspace_bind' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM v_workpls_dimension_evidence
WHERE profile_id = 'profile_validation_workpls_030_no_snapshot';

SELECT
  'multi_snapshot_binding_fail_closed' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM v_workpls_dimension_evidence
WHERE profile_id = 'profile_validation_workpls_030_multi';

SELECT
  'old_dimension_score_source_not_used' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM v_workpls_dimension_evidence evidence
WHERE NOT EXISTS (
  SELECT 1
  FROM platform_profile_tag_metrics metrics
  WHERE metrics.workspace_id = evidence.workspace_id
    AND metrics.profile_id = evidence.profile_id
    AND metrics.canonical_object_key = evidence.canonical_object_key
    AND metrics.metric_name = evidence.metric_name
    AND metrics.metric_unit = evidence.unit
    AND metrics.profile_time_window = evidence.profile_time_window
    AND metrics.source_batch_id = evidence.source_batch_id
);

SELECT
  'source_evidence_refs_no_forbidden_payload' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM v_workpls_dimension_evidence evidence
JOIN json_each(evidence.source_evidence_refs_json) refs
WHERE json_extract(refs.value, '$.rowid') IS NOT NULL
  OR json_extract(refs.value, '$.raw_json') IS NOT NULL
  OR json_extract(refs.value, '$.qualityStatus') IS NOT NULL
  OR json_extract(refs.value, '$.sourceView') IS NOT NULL
  OR json_extract(refs.value, '$.sourceSql') IS NOT NULL
  OR json_extract(refs.value, '$.sourceFile') LIKE '/%';

ROLLBACK;

SELECT
  'validation_rows_rolled_back' AS check_name,
  (
    SELECT COUNT(*) FROM platform_profile_tag_metrics
    WHERE source_batch_id LIKE 'batch_validation_workpls_030%'
  ) + (
    SELECT COUNT(*) FROM pls_audience_profiles
    WHERE source_batch_id LIKE 'batch_validation_workpls_030%'
  ) + (
    SELECT COUNT(*) FROM pls_channel_objects
    WHERE source_batch_id LIKE 'batch_validation_workpls_030%'
  ) + (
    SELECT COUNT(*) FROM platform_tag_catalog
    WHERE id LIKE 'ptag_validation_workpls_030%'
  ) + (
    SELECT COUNT(*) FROM pls_tag_type_dimension_mappings
    WHERE id = 'ptypemap_validation_workpls_030'
  ) + (
    SELECT COUNT(*) FROM pls_tag_value_dimension_mappings
    WHERE id LIKE 'pvalmap_validation_workpls_030%'
  ) AS actual,
  0 AS expected,
  CASE
    WHEN (
      SELECT COUNT(*) FROM platform_profile_tag_metrics
      WHERE source_batch_id LIKE 'batch_validation_workpls_030%'
    ) + (
      SELECT COUNT(*) FROM pls_audience_profiles
      WHERE source_batch_id LIKE 'batch_validation_workpls_030%'
    ) + (
      SELECT COUNT(*) FROM pls_channel_objects
      WHERE source_batch_id LIKE 'batch_validation_workpls_030%'
    ) + (
      SELECT COUNT(*) FROM platform_tag_catalog
      WHERE id LIKE 'ptag_validation_workpls_030%'
    ) + (
      SELECT COUNT(*) FROM pls_tag_type_dimension_mappings
      WHERE id = 'ptypemap_validation_workpls_030'
    ) + (
      SELECT COUNT(*) FROM pls_tag_value_dimension_mappings
      WHERE id LIKE 'pvalmap_validation_workpls_030%'
    ) = 0
    THEN 'pass'
    ELSE 'fail'
  END AS result;
