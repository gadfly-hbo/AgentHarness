.headers on
.mode column

SELECT
  'subject_feature_matrix_total' AS check_name,
  COUNT(*) AS actual,
  (
    SELECT COUNT(DISTINCT subject_type || '|' || subject_id || '|' || COALESCE(subject_entity_id, ''))
    FROM v_subject_pls_dimension_features
  ) AS expected,
  CASE
    WHEN COUNT(*) = (
      SELECT COUNT(DISTINCT subject_type || '|' || subject_id || '|' || COALESCE(subject_entity_id, ''))
      FROM v_subject_pls_dimension_features
    ) THEN 'pass'
    ELSE 'fail'
  END AS result
FROM v_subject_pls_feature_matrix;

SELECT
  'subject_feature_matrix_negative_scores' AS check_name,
  COUNT(*) AS actual,
  0 AS expected,
  CASE WHEN COUNT(*) = 0 THEN 'pass' ELSE 'fail' END AS result
FROM v_subject_pls_feature_matrix
WHERE p_demographics_score < 0
   OR p_purchasing_power_score < 0
   OR p_identity_cluster_score < 0
   OR l_content_visual_mind_score < 0
   OR l_innovation_brand_mind_score < 0
   OR l_lifestyle_score < 0
   OR s_price_incentive_response_score < 0
   OR s_conversion_friction_score < 0
   OR s_environment_score < 0;

SELECT
  subject_id,
  active_dimension_count,
  total_observation_count,
  total_feature_weight,
  p_demographics_score,
  p_purchasing_power_score,
  p_identity_cluster_score,
  l_content_visual_mind_score,
  l_innovation_brand_mind_score,
  l_lifestyle_score,
  s_price_incentive_response_score,
  s_conversion_friction_score,
  s_environment_score
FROM v_subject_pls_feature_matrix
ORDER BY subject_id;
