.headers on
.mode column

SELECT
  'pls_audience_profiles_seed_total' AS check_name,
  COUNT(*) AS actual,
  3 AS expected,
  CASE WHEN COUNT(*) = 3 THEN 'pass' ELSE 'fail' END AS result
FROM pls_audience_profiles
WHERE source_batch_id = 'batch_channel_object_library_mock_20260706';

SELECT
  'missing_channel_objects' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pls_audience_profiles profiles
LEFT JOIN pls_channel_objects objects
  ON objects.workspace_id = profiles.workspace_id
  AND objects.canonical_object_key = profiles.canonical_object_key
  AND objects.data_version = profiles.data_version
WHERE profiles.status = 'active'
  AND objects.id IS NULL;

SELECT
  'non_channel_entity_profiles' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pls_audience_profiles profiles
JOIN pls_channel_objects objects
  ON objects.workspace_id = profiles.workspace_id
  AND objects.canonical_object_key = profiles.canonical_object_key
  AND objects.data_version = profiles.data_version
WHERE objects.object_type NOT IN ('platform', 'trade_area', 'store', 'account');

SELECT
  'invalid_json_payloads' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pls_audience_profiles
WHERE json_valid(tags_json) = 0
  OR json_valid(unmapped_fields_json) = 0
  OR json_valid(quality_flags_json) = 0
  OR json_valid(raw_json) = 0;

SELECT
  'tag_count_total' AS check_name,
  SUM(json_array_length(tags_json)) AS actual,
  5 AS expected,
  CASE WHEN SUM(json_array_length(tags_json)) = 5 THEN 'pass' ELSE 'fail' END AS result
FROM pls_audience_profiles
WHERE source_batch_id = 'batch_channel_object_library_mock_20260706';

SELECT
  'unmapped_field_profile_count' AS check_name,
  COUNT(*) AS actual,
  1 AS expected,
  CASE WHEN COUNT(*) = 1 THEN 'pass' ELSE 'fail' END AS result
FROM pls_audience_profiles
WHERE json_array_length(unmapped_fields_json) > 0;

SELECT
  profiles.profile_id,
  objects.object_type,
  objects.display_name,
  profiles.sample_size,
  profiles.confidence,
  json_array_length(profiles.tags_json) AS tag_count,
  json_array_length(profiles.unmapped_fields_json) AS unmapped_field_count
FROM pls_audience_profiles profiles
JOIN pls_channel_objects objects
  ON objects.workspace_id = profiles.workspace_id
  AND objects.canonical_object_key = profiles.canonical_object_key
  AND objects.data_version = profiles.data_version
WHERE profiles.source_batch_id = 'batch_channel_object_library_mock_20260706'
ORDER BY objects.object_type, profiles.profile_id;
