.headers on
.mode column

SELECT
  'review_queue_view_retired' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM sqlite_schema
WHERE type = 'view'
  AND name = 'v_pls_tag_type_mapping_review_queue';
