.headers on
.mode column

SELECT
  'pls_channel_objects_seed_total' AS check_name,
  COUNT(*) AS actual,
  6 AS expected,
  CASE WHEN COUNT(*) = 6 THEN 'pass' ELSE 'fail' END AS result
FROM pls_channel_objects
WHERE source_batch_id = 'batch_channel_object_library_mock_20260706';

SELECT
  'pls_channel_objects_by_type' AS check_name,
  object_type,
  COUNT(*) AS actual
FROM pls_channel_objects
WHERE source_batch_id = 'batch_channel_object_library_mock_20260706'
GROUP BY object_type
ORDER BY object_type;

SELECT
  'invalid_json_payloads' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pls_channel_objects
WHERE json_valid(entity_attributes_json) = 0
  OR json_valid(duplicate_candidate_keys_json) = 0
  OR json_valid(quality_flags_json) = 0
  OR json_valid(raw_json) = 0;

SELECT
  'duplicate_candidate_rows' AS check_name,
  COUNT(*) AS actual,
  1 AS expected,
  CASE WHEN COUNT(*) = 1 THEN 'pass' ELSE 'fail' END AS result
FROM pls_channel_objects
WHERE possible_duplicate = 1;

SELECT
  'generated_key_review_rows' AS check_name,
  COUNT(*) AS actual,
  1 AS expected,
  CASE WHEN COUNT(*) = 1 THEN 'pass' ELSE 'fail' END AS result
FROM pls_channel_objects
WHERE manual_review_status = 'needs_more_data';

SELECT
  canonical_object_key,
  object_type,
  target_object,
  display_name,
  platform_type,
  manual_review_status,
  possible_duplicate
FROM pls_channel_objects
WHERE source_batch_id = 'batch_channel_object_library_mock_20260706'
ORDER BY object_type, canonical_object_key;
