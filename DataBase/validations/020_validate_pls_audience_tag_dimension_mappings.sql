.headers on
.mode column

SELECT
  'pls_audience_tag_dimension_mappings_seed_total' AS check_name,
  COUNT(*) AS actual,
  5 AS expected,
  CASE WHEN COUNT(*) = 5 THEN 'pass' ELSE 'fail' END AS result
FROM pls_audience_tag_dimension_mappings
WHERE source_ref = 'pls:channel_profile_object_library_sample';

WITH audience_tags AS (
  SELECT DISTINCT json_extract(tag.value, '$.tagId') AS tag_id
  FROM pls_audience_profiles profiles,
       json_each(profiles.tags_json) tag
  WHERE profiles.status = 'active'
)
SELECT
  'unmapped_active_audience_tags' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM audience_tags tags
LEFT JOIN pls_audience_tag_dimension_mappings mappings
  ON mappings.tag_id = tags.tag_id
  AND mappings.status = 'active'
  AND mappings.mapping_status = 'approved'
WHERE mappings.id IS NULL;

SELECT
  'orphan_dimension_refs' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pls_audience_tag_dimension_mappings mappings
LEFT JOIN pls_semantic_dimensions dimensions
  ON dimensions.id = mappings.dimension_id
WHERE mappings.status = 'active'
  AND dimensions.id IS NULL;

SELECT
  mappings.tag_id,
  mappings.tag_label_zh,
  mappings.confidence,
  dimensions.layer_code,
  dimensions.dimension_name,
  mappings.rationale
FROM pls_audience_tag_dimension_mappings mappings
JOIN pls_semantic_dimensions dimensions
  ON dimensions.id = mappings.dimension_id
WHERE mappings.source_ref = 'pls:channel_profile_object_library_sample'
ORDER BY mappings.tag_namespace, mappings.tag_id;
