.headers on
.mode column

SELECT
  'profile_tag_observations_seed_total' AS check_name,
  COUNT(*) AS actual,
  12 AS expected,
  CASE WHEN COUNT(*) = 12 THEN 'pass' ELSE 'fail' END AS result
FROM profile_tag_observations
WHERE observation_source = 'seed:pls_demo_observations';

SELECT
  'profile_tag_observations_by_platform' AS check_name,
  platform,
  COUNT(*) AS actual
FROM profile_tag_observations
WHERE observation_source = 'seed:pls_demo_observations'
GROUP BY platform
ORDER BY platform;

SELECT
  'orphan_catalog_refs' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM profile_tag_observations observations
LEFT JOIN platform_tag_catalog catalog
  ON catalog.id = observations.platform_tag_catalog_id
WHERE observations.status = 'active'
  AND catalog.id IS NULL;

SELECT
  'semantic_join_missing' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM profile_tag_observations observations
LEFT JOIN v_pls_platform_tag_value_semantics semantics
  ON semantics.platform_tag_catalog_id = observations.platform_tag_catalog_id
WHERE observations.status = 'active'
  AND semantics.platform_tag_catalog_id IS NULL;

SELECT
  semantics.layer_code,
  semantics.dimension_name,
  COUNT(*) AS observation_count
FROM profile_tag_observations observations
JOIN v_pls_platform_tag_value_semantics semantics
  ON semantics.platform_tag_catalog_id = observations.platform_tag_catalog_id
WHERE observations.observation_source = 'seed:pls_demo_observations'
GROUP BY semantics.layer_code, semantics.dimension_name
ORDER BY semantics.layer_code, semantics.dimension_name;
