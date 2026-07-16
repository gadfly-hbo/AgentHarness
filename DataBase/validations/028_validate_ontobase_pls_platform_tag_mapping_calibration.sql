.headers on
.mode column

WITH expected(platform, tag_type, dimension_code) AS (
  VALUES
    ('天猫', '预测用户身高', 'P_DEMOGRAPHICS'),
    ('天猫', '预测用户体重', 'P_DEMOGRAPHICS'),
    ('天猫', '预测是否有车', 'P_PURCHASING_POWER'),
    ('天猫', '预测住房状态', 'P_PURCHASING_POWER'),
    ('天猫', '天猫通用人群_消费意愿', 'L_INNOVATION_BRAND_MIND'),
    ('天猫', '预测使用的手机品牌', 'S_ENVIRONMENT'),
    ('京东', '学历', 'P_IDENTITY_CLUSTER'),
    ('京东', 'PLUS会员', 'P_PURCHASING_POWER'),
    ('抖音', '手机品牌', 'S_ENVIRONMENT')
)
SELECT
  'ontobase_tag_type_calibration' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM expected
LEFT JOIN pls_tag_type_dimension_mappings type_mapping
  ON type_mapping.platform = expected.platform
  AND type_mapping.tag_type = expected.tag_type
  AND type_mapping.status = 'active'
LEFT JOIN pls_semantic_dimensions dimensions
  ON dimensions.id = type_mapping.dimension_id
WHERE dimensions.dimension_code IS NOT expected.dimension_code;

WITH expected(platform, tag_type, dimension_code) AS (
  VALUES
    ('天猫', '预测用户身高', 'P_DEMOGRAPHICS'),
    ('天猫', '预测用户体重', 'P_DEMOGRAPHICS'),
    ('天猫', '预测是否有车', 'P_PURCHASING_POWER'),
    ('天猫', '预测住房状态', 'P_PURCHASING_POWER'),
    ('天猫', '天猫通用人群_消费意愿', 'L_INNOVATION_BRAND_MIND'),
    ('天猫', '预测使用的手机品牌', 'S_ENVIRONMENT'),
    ('京东', '学历', 'P_IDENTITY_CLUSTER'),
    ('京东', 'PLUS会员', 'P_PURCHASING_POWER'),
    ('抖音', '手机品牌', 'S_ENVIRONMENT')
)
SELECT
  'ontobase_tag_value_calibration' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM pls_tag_value_dimension_mappings value_mapping
JOIN expected
  ON expected.platform = value_mapping.platform
  AND expected.tag_type = value_mapping.tag_type
JOIN pls_semantic_dimensions dimensions
  ON dimensions.id = value_mapping.dimension_id
WHERE dimensions.dimension_code IS NOT expected.dimension_code;

SELECT
  'platform_tag_summary_html_synced' AS check_name,
  CASE
    WHEN EXISTS (
      SELECT 1
      FROM platform_tag_catalog
      WHERE platform = '天猫'
        AND tag_type = '预测用户身高'
        AND status = 'active'
    ) THEN 1
    ELSE 0
  END AS actual,
  1 AS expected,
  CASE
    WHEN EXISTS (
      SELECT 1
      FROM platform_tag_catalog
      WHERE platform = '天猫'
        AND tag_type = '预测用户身高'
        AND status = 'active'
    ) THEN 'pass'
    ELSE 'fail'
  END AS result;
