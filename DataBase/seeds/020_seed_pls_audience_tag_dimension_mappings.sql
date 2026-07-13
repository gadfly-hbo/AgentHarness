PRAGMA foreign_keys = ON;

DELETE FROM pls_audience_tag_dimension_mappings
WHERE source_ref = 'pls:channel_profile_object_library_sample';

INSERT INTO pls_audience_tag_dimension_mappings (
  id,
  tag_id,
  tag_namespace,
  tag_label_zh,
  dimension_id,
  mapping_status,
  mapping_method,
  confidence,
  rationale,
  source_ref,
  status,
  created_at,
  updated_at
)
VALUES
  (
    'patdim_demo_age_25_34',
    'demo.age_25_34',
    'demo',
    '25-34岁',
    'pls_dim_p_demographics',
    'approved',
    'manual_seed',
    0.95,
    '年龄段标签描述基础生理和年龄基底，归入 P 层基础人口学。',
    'pls:channel_profile_object_library_sample',
    'active',
    '2026-07-13T00:00:00.000Z',
    '2026-07-13T00:00:00.000Z'
  ),
  (
    'patdim_channel_short_video',
    'channel.short_video',
    'channel',
    '短视频触点',
    'pls_dim_s_environment',
    'approved',
    'manual_seed',
    0.86,
    '短视频是数字触点和渠道环境信号，主要决定在什么媒介环境中触达。',
    'pls:channel_profile_object_library_sample',
    'active',
    '2026-07-13T00:00:00.000Z',
    '2026-07-13T00:00:00.000Z'
  ),
  (
    'patdim_style_minimal',
    'style.minimal',
    'style',
    '简约风格',
    'pls_dim_l_content_visual_mind',
    'approved',
    'manual_seed',
    0.9,
    '风格标签描述受众审美和视觉心智，归入 L 层内容与视觉心智。',
    'pls:channel_profile_object_library_sample',
    'active',
    '2026-07-13T00:00:00.000Z',
    '2026-07-13T00:00:00.000Z'
  ),
  (
    'patdim_occasion_work',
    'occasion.work',
    'occasion',
    '职场/通勤场景',
    'pls_dim_l_lifestyle',
    'approved',
    'manual_seed',
    0.9,
    '使用场景标签描述受众生活方式和商品使用场景，归入 L 层圈层生活方式。',
    'pls:channel_profile_object_library_sample',
    'active',
    '2026-07-13T00:00:00.000Z',
    '2026-07-13T00:00:00.000Z'
  ),
  (
    'patdim_price_mid',
    'price.mid',
    'price',
    '中端价格带',
    'pls_dim_p_purchasing_power',
    'approved',
    'manual_seed',
    0.88,
    '价格带标签表达受众可接受客单价和消费能力，归入 P 层社会资产与购买力；促销敏感度类标签才进入价格与利益应激。',
    'pls:channel_profile_object_library_sample',
    'active',
    '2026-07-13T00:00:00.000Z',
    '2026-07-13T00:00:00.000Z'
  );
