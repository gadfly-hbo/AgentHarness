.headers on
.mode column

SELECT
  'pls_channel_object_bindings_seed_total' AS check_name,
  COUNT(*) AS actual,
  4 AS expected,
  CASE WHEN COUNT(*) = 4 THEN 'pass' ELSE 'fail' END AS result
FROM pls_channel_object_bindings
WHERE source_batch_id = 'batch_channel_object_library_mock_20260706';

SELECT
  'pls_channel_object_bindings_by_type' AS check_name,
  binding_type,
  COUNT(*) AS actual
FROM pls_channel_object_bindings
WHERE source_batch_id = 'batch_channel_object_library_mock_20260706'
GROUP BY binding_type
ORDER BY binding_type;

SELECT
  'missing_from_objects' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pls_channel_object_bindings bindings
LEFT JOIN pls_channel_objects objects
  ON objects.workspace_id = bindings.workspace_id
  AND objects.canonical_object_key = bindings.from_canonical_object_key
  AND objects.data_version = bindings.data_version
WHERE bindings.status = 'active'
  AND objects.id IS NULL;

SELECT
  'missing_to_objects' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pls_channel_object_bindings bindings
LEFT JOIN pls_channel_objects objects
  ON objects.workspace_id = bindings.workspace_id
  AND objects.canonical_object_key = bindings.to_canonical_object_key
  AND objects.data_version = bindings.data_version
WHERE bindings.status = 'active'
  AND objects.id IS NULL;

SELECT
  'invalid_json_payloads' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pls_channel_object_bindings
WHERE json_valid(quality_flags_json) = 0
  OR json_valid(raw_json) = 0;

SELECT
  bindings.binding_type,
  from_objects.object_type AS from_object_type,
  from_objects.display_name AS from_display_name,
  to_objects.object_type AS to_object_type,
  to_objects.display_name AS to_display_name
FROM pls_channel_object_bindings bindings
JOIN pls_channel_objects from_objects
  ON from_objects.workspace_id = bindings.workspace_id
  AND from_objects.canonical_object_key = bindings.from_canonical_object_key
  AND from_objects.data_version = bindings.data_version
JOIN pls_channel_objects to_objects
  ON to_objects.workspace_id = bindings.workspace_id
  AND to_objects.canonical_object_key = bindings.to_canonical_object_key
  AND to_objects.data_version = bindings.data_version
WHERE bindings.source_batch_id = 'batch_channel_object_library_mock_20260706'
ORDER BY bindings.binding_type, from_objects.object_type, to_objects.object_type;
