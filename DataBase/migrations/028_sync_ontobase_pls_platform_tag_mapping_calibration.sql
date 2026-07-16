PRAGMA foreign_keys = ON;

CREATE TEMP TABLE tmp_ontobase_pls_platform_tag_mapping_calibration (
  platform TEXT NOT NULL,
  tag_type TEXT NOT NULL,
  dimension_id TEXT NOT NULL,
  rationale TEXT NOT NULL,
  PRIMARY KEY (platform, tag_type)
);

INSERT INTO tmp_ontobase_pls_platform_tag_mapping_calibration (
  platform,
  tag_type,
  dimension_id,
  rationale
)
VALUES
  ('天猫', '预测用户身高', 'pls_dim_p_demographics', 'OntoBase业务校准：身高是稳定的生理属性，不是临时转化阻力。'),
  ('天猫', '预测用户体重', 'pls_dim_p_demographics', 'OntoBase业务校准：体重是稳定的生理属性；影响尺码只是后续应用。'),
  ('天猫', '预测是否有车', 'pls_dim_p_purchasing_power', 'OntoBase业务校准：是否有车是资产持有与消费承载能力信号。'),
  ('天猫', '预测住房状态', 'pls_dim_p_purchasing_power', 'OntoBase业务校准：住房状态是家庭资产与耐用品消费能力的重要基础变量。'),
  ('天猫', '天猫通用人群_消费意愿', 'pls_dim_l_innovation_brand_mind', 'OntoBase业务校准：高端、品质、实用和经济取向描述长期消费理念与价值主张，不是平台综合身份。'),
  ('天猫', '预测使用的手机品牌', 'pls_dim_s_environment', 'OntoBase业务校准：当前使用的手机品牌描述硬件与数字触达环境，不等同于品牌忠诚。'),
  ('京东', '学历', 'pls_dim_p_identity_cluster', 'OntoBase业务校准：学历首先描述教育背景和社会身份，不直接等同于实际消费能力。'),
  ('京东', 'PLUS会员', 'pls_dim_p_purchasing_power', 'OntoBase业务校准：PLUS会员身份反映平台高价值会员属性及持续消费能力。'),
  ('抖音', '手机品牌', 'pls_dim_s_environment', 'OntoBase业务校准：当前使用的手机品牌首先描述用户所处数字设备环境和触达条件。');

UPDATE pls_tag_type_dimension_mappings
SET
  dimension_id = (
    SELECT calibration.dimension_id
    FROM tmp_ontobase_pls_platform_tag_mapping_calibration calibration
    WHERE calibration.platform = pls_tag_type_dimension_mappings.platform
      AND calibration.tag_type = pls_tag_type_dimension_mappings.tag_type
  ),
  mapping_status = 'approved',
  mapping_method = 'manual',
  confidence = 1.0,
  rationale = (
    SELECT calibration.rationale
    FROM tmp_ontobase_pls_platform_tag_mapping_calibration calibration
    WHERE calibration.platform = pls_tag_type_dimension_mappings.platform
      AND calibration.tag_type = pls_tag_type_dimension_mappings.tag_type
  ),
  source_ref = 'OntoBase/pls-ontology-business-calibration.md#9',
  updated_at = '2026-07-16T00:00:00.000Z'
WHERE EXISTS (
  SELECT 1
  FROM tmp_ontobase_pls_platform_tag_mapping_calibration calibration
  WHERE calibration.platform = pls_tag_type_dimension_mappings.platform
    AND calibration.tag_type = pls_tag_type_dimension_mappings.tag_type
);

UPDATE pls_tag_value_dimension_mappings
SET
  dimension_id = (
    SELECT type_mapping.dimension_id
    FROM pls_tag_type_dimension_mappings type_mapping
    WHERE type_mapping.id = pls_tag_value_dimension_mappings.inherited_tag_type_mapping_id
  ),
  mapping_status = 'approved',
  mapping_method = 'inherited_tag_type',
  confidence = 1.0,
  rationale = '继承OntoBase业务校准后的标签类型级映射：'
    || platform || ' / ' || tag_type || '。',
  source_ref = 'OntoBase/pls-ontology-business-calibration.md#9',
  status = 'active',
  updated_at = '2026-07-16T00:00:00.000Z'
WHERE EXISTS (
  SELECT 1
  FROM tmp_ontobase_pls_platform_tag_mapping_calibration calibration
  WHERE calibration.platform = pls_tag_value_dimension_mappings.platform
    AND calibration.tag_type = pls_tag_value_dimension_mappings.tag_type
);

DROP TABLE tmp_ontobase_pls_platform_tag_mapping_calibration;
