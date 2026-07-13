.headers on
.mode column

SELECT
  'entities_total' AS check_name,
  COUNT(*) AS actual,
  5 AS expected,
  CASE WHEN COUNT(*) = 5 THEN 'pass' ELSE 'fail' END AS result
FROM entities;

SELECT
  'required_consumers_present' AS check_name,
  COUNT(*) AS actual,
  3 AS expected,
  CASE WHEN COUNT(*) = 3 THEN 'pass' ELSE 'fail' END AS result
FROM entities
WHERE external_ref IN (
  'project:modelevol',
  'project:pls',
  'model:pls-audience-segmentation'
);

SELECT
  'json_attributes_valid' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM entities
WHERE NOT json_valid(attributes_json);

SELECT
  id,
  entity_type,
  canonical_name,
  source_system,
  external_ref,
  status
FROM entities
ORDER BY entity_type, id;
