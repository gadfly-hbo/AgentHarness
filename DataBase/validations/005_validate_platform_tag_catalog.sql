.headers on
.mode column

SELECT
  'platform_tag_catalog_total' AS check_name,
  COUNT(*) AS actual,
  9433 AS expected,
  CASE WHEN COUNT(*) = 9433 THEN 'pass' ELSE 'fail' END AS result
FROM platform_tag_catalog
WHERE platform IN ('天猫', '抖音');

SELECT
  'platform_tag_catalog_by_platform' AS check_name,
  platform,
  COUNT(*) AS actual,
  CASE platform
    WHEN '天猫' THEN 3538
    WHEN '抖音' THEN 5895
  END AS expected,
  CASE
    WHEN platform = '天猫' AND COUNT(*) = 3538 THEN 'pass'
    WHEN platform = '抖音' AND COUNT(*) = 5895 THEN 'pass'
    ELSE 'fail'
  END AS result
FROM platform_tag_catalog
WHERE platform IN ('天猫', '抖音')
GROUP BY platform
ORDER BY platform;

SELECT
  'excluded_xiaohongshu' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM platform_tag_catalog
WHERE platform = '小红书';

SELECT
  'tag_type_count_by_platform' AS check_name,
  platform,
  COUNT(DISTINCT tag_type) AS tag_type_count
FROM platform_tag_catalog
WHERE platform IN ('天猫', '抖音')
GROUP BY platform
ORDER BY platform;

SELECT
  'blank_leaf_labels' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM platform_tag_catalog
WHERE trim(leaf_label) = '';

SELECT
  platform,
  tag_type,
  COUNT(*) AS tag_count
FROM platform_tag_catalog
WHERE platform IN ('天猫', '抖音')
GROUP BY platform, tag_type
ORDER BY platform, tag_count DESC, tag_type
LIMIT 40;
