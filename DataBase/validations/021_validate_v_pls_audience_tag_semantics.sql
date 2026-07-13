.headers on
.mode column

SELECT
  'v_pls_audience_tag_semantics_total' AS check_name,
  COUNT(*) AS actual,
  5 AS expected,
  CASE WHEN COUNT(*) = 5 THEN 'pass' ELSE 'fail' END AS result
FROM v_pls_audience_tag_semantics
WHERE source_batch_id = 'batch_channel_object_library_mock_20260706';

SELECT
  'dimension_distribution' AS check_name,
  layer_code,
  dimension_name,
  COUNT(*) AS actual
FROM v_pls_audience_tag_semantics
WHERE source_batch_id = 'batch_channel_object_library_mock_20260706'
GROUP BY layer_code, dimension_name
ORDER BY layer_code, dimension_name;

WITH raw_tags AS (
  SELECT COUNT(*) AS count
  FROM pls_audience_profiles profiles,
       json_each(profiles.tags_json) tag
  WHERE profiles.status = 'active'
),
semantic_tags AS (
  SELECT COUNT(*) AS count
  FROM v_pls_audience_tag_semantics
)
SELECT
  'semantic_rows_match_raw_tags' AS check_name,
  semantic_tags.count AS actual,
  raw_tags.count AS expected,
  CASE WHEN semantic_tags.count = raw_tags.count THEN 'pass' ELSE 'fail' END AS result
FROM raw_tags, semantic_tags;

SELECT
  canonical_object_key,
  display_name,
  tag_id,
  tag_label_zh,
  tag_score,
  tag_confidence,
  layer_code,
  dimension_name,
  mapping_confidence
FROM v_pls_audience_tag_semantics
WHERE source_batch_id = 'batch_channel_object_library_mock_20260706'
ORDER BY canonical_object_key, tag_id;
