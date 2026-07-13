PRAGMA foreign_keys = ON;

DELETE FROM profile_tag_observations
WHERE observation_source = 'seed:pls_demo_observations';

INSERT INTO profile_tag_observations (
  id,
  subject_type,
  subject_id,
  subject_entity_id,
  platform_tag_catalog_id,
  platform,
  tag_type,
  leaf_label,
  observed_value,
  observation_weight,
  observation_source,
  observed_at,
  evidence_ref,
  context_json,
  status,
  created_at,
  updated_at
)
SELECT
  'ptobs_demo_001',
  'sample_subject',
  'pls_demo_beauty_sensitive_audience',
  'ent_module_pls_profile',
  catalog.id,
  catalog.platform,
  catalog.tag_type,
  catalog.leaf_label,
  'matched',
  0.92,
  'seed:pls_demo_observations',
  '2026-07-13T00:00:00.000Z',
  'seed:demo:beauty:hydration',
  '{"demo":true,"scenario":"beauty_profile"}',
  'active',
  '2026-07-13T00:00:00.000Z',
  '2026-07-13T00:00:00.000Z'
FROM platform_tag_catalog catalog
WHERE catalog.platform = '天猫'
  AND catalog.tag_type = '美妆行业-护肤品功效需求'
  AND catalog.leaf_label = '保湿补水';

INSERT INTO profile_tag_observations SELECT
  'ptobs_demo_002', 'sample_subject', 'pls_demo_beauty_sensitive_audience', 'ent_module_pls_profile',
  catalog.id, catalog.platform, catalog.tag_type, catalog.leaf_label, 'matched', 0.88,
  'seed:pls_demo_observations', '2026-07-13T00:00:00.000Z', 'seed:demo:beauty:oil_control',
  '{"demo":true,"scenario":"beauty_profile"}', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'
FROM platform_tag_catalog catalog
WHERE catalog.platform = '天猫' AND catalog.tag_type = '美妆行业-护肤品功效需求' AND catalog.leaf_label = '控油';

INSERT INTO profile_tag_observations SELECT
  'ptobs_demo_003', 'sample_subject', 'pls_demo_price_sensitive_audience', 'ent_model_pls_audience_segmentation',
  catalog.id, catalog.platform, catalog.tag_type, catalog.leaf_label, 'high', 0.95,
  'seed:pls_demo_observations', '2026-07-13T00:00:00.000Z', 'seed:demo:price:discount',
  '{"demo":true,"scenario":"price_response"}', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'
FROM platform_tag_catalog catalog
WHERE catalog.platform = '天猫' AND catalog.tag_type = '折扣敏感度' AND catalog.leaf_label = '高';

INSERT INTO profile_tag_observations SELECT
  'ptobs_demo_004', 'sample_subject', 'pls_demo_high_value_member', 'ent_model_pls_audience_segmentation',
  catalog.id, catalog.platform, catalog.tag_type, catalog.leaf_label, 'member', 1.0,
  'seed:pls_demo_observations', '2026-07-13T00:00:00.000Z', 'seed:demo:member:88vip',
  '{"demo":true,"scenario":"member_value"}', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'
FROM platform_tag_catalog catalog
WHERE catalog.platform = '天猫' AND catalog.tag_type = '88会员等级' AND catalog.leaf_label = '超级会员';

INSERT INTO profile_tag_observations SELECT
  'ptobs_demo_005', 'sample_subject', 'pls_demo_lifestyle_food_audience', 'ent_module_pls_profile',
  catalog.id, catalog.platform, catalog.tag_type, catalog.leaf_label, 'matched', 0.81,
  'seed:pls_demo_observations', '2026-07-13T00:00:00.000Z', 'seed:demo:lifestyle:coffee',
  '{"demo":true,"scenario":"lifestyle_preference"}', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'
FROM platform_tag_catalog catalog
WHERE catalog.platform = '天猫' AND catalog.tag_type = '一级类目高偏好' AND catalog.leaf_label = '咖啡/麦片/冲饮';

INSERT INTO profile_tag_observations SELECT
  'ptobs_demo_006', 'sample_subject', 'pls_demo_home_appliance_audience', 'ent_module_pls_profile',
  catalog.id, catalog.platform, catalog.tag_type, catalog.leaf_label, 'matched', 0.77,
  'seed:pls_demo_observations', '2026-07-13T00:00:00.000Z', 'seed:demo:lifestyle:appliance',
  '{"demo":true,"scenario":"lifestyle_preference"}', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'
FROM platform_tag_catalog catalog
WHERE catalog.platform = '天猫' AND catalog.tag_type = '一级类目高偏好' AND catalog.leaf_label = '大家电';

INSERT INTO profile_tag_observations SELECT
  'ptobs_demo_007', 'sample_subject', 'pls_demo_douyin_high_value_user', 'ent_model_pls_audience_segmentation',
  catalog.id, catalog.platform, catalog.tag_type, catalog.leaf_label, 'high', 0.91,
  'seed:pls_demo_observations', '2026-07-13T00:00:00.000Z', 'seed:demo:douyin:consumption',
  '{"demo":true,"scenario":"douyin_profile"}', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'
FROM platform_tag_catalog catalog
WHERE catalog.platform = '抖音' AND catalog.tag_type = '预测消费能力' AND catalog.leaf_label = '高消费';

INSERT INTO profile_tag_observations SELECT
  'ptobs_demo_008', 'sample_subject', 'pls_demo_douyin_content_food', 'ent_module_pls_profile',
  catalog.id, catalog.platform, catalog.tag_type, catalog.leaf_label, 'matched', 0.84,
  'seed:pls_demo_observations', '2026-07-13T00:00:00.000Z', 'seed:demo:douyin:food_content',
  '{"demo":true,"scenario":"content_interest"}', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'
FROM platform_tag_catalog catalog
WHERE catalog.platform = '抖音' AND catalog.tag_type = '抖音视频观看兴趣分类v2' AND catalog.leaf_label = '美食';

INSERT INTO profile_tag_observations SELECT
  'ptobs_demo_009', 'sample_subject', 'pls_demo_douyin_content_tech', 'ent_module_pls_profile',
  catalog.id, catalog.platform, catalog.tag_type, catalog.leaf_label, 'matched', 0.86,
  'seed:pls_demo_observations', '2026-07-13T00:00:00.000Z', 'seed:demo:douyin:tech_content',
  '{"demo":true,"scenario":"content_interest"}', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'
FROM platform_tag_catalog catalog
WHERE catalog.platform = '抖音' AND catalog.tag_type = '抖音视频观看兴趣分类v2' AND catalog.leaf_label = '科技';

INSERT INTO profile_tag_observations SELECT
  'ptobs_demo_010', 'sample_subject', 'pls_demo_douyin_ios_user', 'ent_module_pls_profile',
  catalog.id, catalog.platform, catalog.tag_type, catalog.leaf_label, 'device', 0.8,
  'seed:pls_demo_observations', '2026-07-13T00:00:00.000Z', 'seed:demo:douyin:ios',
  '{"demo":true,"scenario":"digital_environment"}', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'
FROM platform_tag_catalog catalog
WHERE catalog.platform = '抖音' AND catalog.tag_type = '手机系统' AND catalog.leaf_label = 'IOS';

INSERT INTO profile_tag_observations SELECT
  'ptobs_demo_011', 'sample_subject', 'pls_demo_douyin_female_user', 'ent_module_pls_profile',
  catalog.id, catalog.platform, catalog.tag_type, catalog.leaf_label, 'female', 0.73,
  'seed:pls_demo_observations', '2026-07-13T00:00:00.000Z', 'seed:demo:douyin:gender',
  '{"demo":true,"scenario":"demographic_profile"}', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'
FROM platform_tag_catalog catalog
WHERE catalog.platform = '抖音' AND catalog.tag_type = '预测性别' AND catalog.leaf_label = '女';

INSERT INTO profile_tag_observations SELECT
  'ptobs_demo_012', 'sample_subject', 'pls_demo_douyin_content_music', 'ent_module_pls_profile',
  catalog.id, catalog.platform, catalog.tag_type, catalog.leaf_label, 'matched', 0.82,
  'seed:pls_demo_observations', '2026-07-13T00:00:00.000Z', 'seed:demo:douyin:music_content',
  '{"demo":true,"scenario":"content_interest"}', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'
FROM platform_tag_catalog catalog
WHERE catalog.platform = '抖音' AND catalog.tag_type = '抖音视频观看兴趣分类v2' AND catalog.leaf_label = '音乐';
