.headers on
.mode column

SELECT
  'subject_dimension_features_total' AS check_name,
  COUNT(*) AS actual,
  (
    SELECT COUNT(*)
    FROM (
      SELECT subject_type, subject_id, subject_entity_id, dimension_code
      FROM v_profile_tag_observation_semantics
      GROUP BY subject_type, subject_id, subject_entity_id, dimension_code
    )
  ) AS expected,
  CASE
    WHEN COUNT(*) = (
      SELECT COUNT(*)
      FROM (
        SELECT subject_type, subject_id, subject_entity_id, dimension_code
        FROM v_profile_tag_observation_semantics
        GROUP BY subject_type, subject_id, subject_entity_id, dimension_code
      )
    ) THEN 'pass'
    ELSE 'fail'
  END AS result
FROM v_subject_pls_dimension_features;

SELECT
  'subject_dimension_features_missing_dimension' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM v_subject_pls_dimension_features
WHERE dimension_name IS NULL OR dimension_name = '';

SELECT
  subject_id,
  dimension_name,
  observation_count,
  total_weight,
  avg_weight,
  max_weight
FROM v_subject_pls_dimension_features
ORDER BY subject_id, dimension_name;

SELECT
  layer_code,
  dimension_name,
  COUNT(*) AS subject_dimension_count,
  ROUND(SUM(total_weight), 6) AS total_weight
FROM v_subject_pls_dimension_features
GROUP BY layer_code, dimension_name
ORDER BY layer_code, dimension_name;
