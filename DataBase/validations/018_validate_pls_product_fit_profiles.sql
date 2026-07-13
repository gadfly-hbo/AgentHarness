.headers on
.mode column

SELECT
  'pls_product_fit_profiles_seed_total' AS check_name,
  COUNT(*) AS actual,
  2 AS expected,
  CASE WHEN COUNT(*) = 2 THEN 'pass' ELSE 'fail' END AS result
FROM pls_product_fit_profiles
WHERE source_batch_id = 'batch_channel_object_library_mock_20260706';

SELECT
  'missing_channel_objects' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pls_product_fit_profiles profiles
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
FROM pls_product_fit_profiles profiles
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
FROM pls_product_fit_profiles
WHERE json_valid(fit_categories_json) = 0
  OR json_valid(fit_price_bands_json) = 0
  OR json_valid(fit_styles_json) = 0
  OR json_valid(fit_occasions_json) = 0
  OR json_valid(fit_launch_types_json) = 0
  OR json_valid(evidence_json) = 0
  OR json_valid(quality_flags_json) = 0
  OR json_valid(raw_json) = 0;

SELECT
  'manual_config_without_sample' AS check_name,
  COUNT(*) AS actual,
  1 AS expected,
  CASE WHEN COUNT(*) = 1 THEN 'pass' ELSE 'fail' END AS result
FROM pls_product_fit_profiles
WHERE source = 'manual_config'
  AND sample_size IS NULL
  AND time_window IS NULL;

SELECT
  'evidence_count_total' AS check_name,
  SUM(json_array_length(evidence_json)) AS actual,
  2 AS expected,
  CASE WHEN SUM(json_array_length(evidence_json)) = 2 THEN 'pass' ELSE 'fail' END AS result
FROM pls_product_fit_profiles
WHERE source_batch_id = 'batch_channel_object_library_mock_20260706';

SELECT
  profiles.profile_id,
  objects.object_type,
  objects.display_name,
  profiles.source,
  profiles.sample_size,
  profiles.confidence,
  json_array_length(profiles.fit_categories_json) AS fit_category_count,
  json_array_length(profiles.fit_launch_types_json) AS fit_launch_type_count,
  json_array_length(profiles.evidence_json) AS evidence_count
FROM pls_product_fit_profiles profiles
JOIN pls_channel_objects objects
  ON objects.workspace_id = profiles.workspace_id
  AND objects.canonical_object_key = profiles.canonical_object_key
  AND objects.data_version = profiles.data_version
WHERE profiles.source_batch_id = 'batch_channel_object_library_mock_20260706'
ORDER BY objects.object_type, profiles.profile_id;
