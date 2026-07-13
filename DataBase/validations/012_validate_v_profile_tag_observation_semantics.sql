.headers on
.mode column

SELECT
  'observation_semantics_total' AS check_name,
  COUNT(*) AS actual,
  (
    SELECT COUNT(*)
    FROM profile_tag_observations
    WHERE status = 'active'
  ) AS expected,
  CASE
    WHEN COUNT(*) = (
      SELECT COUNT(*)
      FROM profile_tag_observations
      WHERE status = 'active'
    ) THEN 'pass'
    ELSE 'fail'
  END AS result
FROM v_profile_tag_observation_semantics;

SELECT
  'observation_semantics_missing_dimension' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM v_profile_tag_observation_semantics
WHERE dimension_name IS NULL OR dimension_name = '';

SELECT
  subject_id,
  COUNT(*) AS observation_count,
  ROUND(SUM(observation_weight), 4) AS total_weight
FROM v_profile_tag_observation_semantics
GROUP BY subject_id
ORDER BY subject_id;

SELECT
  layer_code,
  dimension_name,
  COUNT(*) AS observation_count,
  ROUND(SUM(observation_weight), 4) AS total_weight
FROM v_profile_tag_observation_semantics
GROUP BY layer_code, dimension_name
ORDER BY layer_code, dimension_name;
