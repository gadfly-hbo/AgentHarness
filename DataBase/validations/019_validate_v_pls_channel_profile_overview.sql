.headers on
.mode column

SELECT
  'v_pls_channel_profile_overview_total' AS check_name,
  COUNT(*) AS actual,
  6 AS expected,
  CASE WHEN COUNT(*) = 6 THEN 'pass' ELSE 'fail' END AS result
FROM v_pls_channel_profile_overview
WHERE source_batch_id = 'batch_channel_object_library_mock_20260706';

SELECT
  'coverage_status_distribution' AS check_name,
  profile_coverage_status,
  COUNT(*) AS actual
FROM v_pls_channel_profile_overview
WHERE source_batch_id = 'batch_channel_object_library_mock_20260706'
GROUP BY profile_coverage_status
ORDER BY profile_coverage_status;

SELECT
  'complete_profile_count' AS check_name,
  COUNT(*) AS actual,
  2 AS expected,
  CASE WHEN COUNT(*) = 2 THEN 'pass' ELSE 'fail' END AS result
FROM v_pls_channel_profile_overview
WHERE profile_coverage_status = 'complete'
  AND source_batch_id = 'batch_channel_object_library_mock_20260706';

SELECT
  'audience_only_count' AS check_name,
  COUNT(*) AS actual,
  1 AS expected,
  CASE WHEN COUNT(*) = 1 THEN 'pass' ELSE 'fail' END AS result
FROM v_pls_channel_profile_overview
WHERE profile_coverage_status = 'audience_only'
  AND source_batch_id = 'batch_channel_object_library_mock_20260706';

SELECT
  'object_only_count' AS check_name,
  COUNT(*) AS actual,
  3 AS expected,
  CASE WHEN COUNT(*) = 3 THEN 'pass' ELSE 'fail' END AS result
FROM v_pls_channel_profile_overview
WHERE profile_coverage_status = 'object_only'
  AND source_batch_id = 'batch_channel_object_library_mock_20260706';

SELECT
  display_name,
  object_type,
  profile_coverage_status,
  audience_tag_count,
  audience_sample_size,
  audience_confidence,
  fit_category_count,
  product_fit_sample_size,
  product_fit_confidence
FROM v_pls_channel_profile_overview
WHERE source_batch_id = 'batch_channel_object_library_mock_20260706'
ORDER BY object_type, display_name;
