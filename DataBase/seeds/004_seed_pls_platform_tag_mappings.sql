PRAGMA foreign_keys = ON;

INSERT INTO pls_platform_tag_mappings (
  id,
  dimension_id,
  platform,
  raw_tag_fields,
  raw_enum_examples,
  data_availability,
  mapping_strategy,
  source_ref,
  status,
  created_at,
  updated_at
)
VALUES
  ('pls_map_douyin_p_demographics', 'pls_dim_p_demographics', '抖音', '预测性别、预测年龄段', '18-19、男、女', 'direct', '粗颗粒度圈定基础受众圈层。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A5:F5', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('pls_map_jd_p_demographics', 'pls_dim_p_demographics', '京东', '性别、年龄、用户年代', '80后、26-35岁', 'direct', '同上，作为底层数据双向对齐的基础。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A6:F6', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('pls_map_tmall_p_demographics', 'pls_dim_p_demographics', '天猫', '预测性别、预测年龄', '[25,29]、女', 'direct', '标准化年龄段并集映射，充实全域人口基底。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A7:F7', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),

  ('pls_map_douyin_p_purchasing_power', 'pls_dim_p_purchasing_power', '抖音', '预测职业、预测消费能力', '蓝领、高消费、中消费', 'direct', '计算渠道的基础消费力水位。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A9:F9', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('pls_map_jd_p_purchasing_power', 'pls_dim_p_purchasing_power', '京东', '职业、学历、有房、有车、购买力', '金融从业者、有车一族', 'direct', '高价值资产交叉验证，精准锚定中高客单价。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A10:F10', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('pls_map_tmall_p_purchasing_power', 'pls_dim_p_purchasing_power', '天猫', '预测职业、预测教育程度、城市等级、常驻城市', '个体经营、本科、一线城市', 'direct', '环境基底补充：结合地域与教育程度建立更严密的购买力风控。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A11:F11', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),

  ('pls_map_douyin_p_identity_cluster', 'pls_dim_p_identity_cluster', '抖音', '八大消费群体', '精致妈妈、小镇青年', 'direct', '系统底层映射为统一身份ID。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A13:F13', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('pls_map_jd_p_identity_cluster', 'pls_dim_p_identity_cluster', '京东', '十大靶群、PLUS会员', '小镇中产、都市Z世代', 'direct', '结合会员属性强化高净值人群置信度。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A14:F14', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('pls_map_tmall_p_identity_cluster', 'pls_dim_p_identity_cluster', '天猫', '大快消策略人群、预测人生阶段', '新锐白领、养育期、已婚未育期', 'direct', '生命周期锚定：“养育期”直接触发亲子/家庭型商品的关联推荐。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A15:F15', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),

  ('pls_map_douyin_l_content_visual_mind', 'pls_dim_l_content_visual_mind', '抖音', '视频观看/阅读兴趣分类', '时尚_穿搭、二次元', 'direct', '视觉审美对齐：决定投放素材风格。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A17:F17', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('pls_map_jd_l_content_visual_mind', 'pls_dim_l_content_visual_mind', '京东', '(偏交易平台，此维度缺失)', '-', 'missing', '依赖内容平台数据的反哺。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A18:F18', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('pls_map_tmall_l_content_visual_mind', 'pls_dim_l_content_visual_mind', '天猫', '行业策略人群 (美学审美向)', '潮流人群、高阶时尚', 'direct', '设计语言匹配：直接对齐服装DNA中的“款式/版型”前沿度。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A19:F19', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),

  ('pls_map_douyin_l_lifestyle', 'pls_dim_l_lifestyle', '抖音', '电商品类成交偏好', '户外运动、设计师潮牌', 'direct', '将数百个品类偏好折叠为生活方式向量。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A21:F21', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('pls_map_jd_l_lifestyle', 'pls_dim_l_lifestyle', '京东', 'xx爱好者人群包', '户外运动爱好者', 'direct', '强交易属性兴趣，直接匹配商品功能。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A22:F22', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('pls_map_tmall_l_lifestyle', 'pls_dim_l_lifestyle', '天猫', '生活方式、一/二级类目高偏好', '数码玩家、养身保健族、羽绒服', 'direct', '品类连带预测：依据类目偏好设计连带购买（如买衬衫搭西裤）方案。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A23:F23', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),

  ('pls_map_douyin_l_innovation_brand_mind', 'pls_dim_l_innovation_brand_mind', '抖音', '电商品牌成交偏好', '苹果、波司登', 'direct', '评估人群对品牌的迷信或包容度。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A25:F25', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('pls_map_jd_l_innovation_brand_mind', 'pls_dim_l_innovation_brand_mind', '京东', '全站新品偏好', '高偏好、中偏好', 'direct', '极高价值：创新款商品首发必匹人群。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A26:F26', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('pls_map_tmall_l_innovation_brand_mind', 'pls_dim_l_innovation_brand_mind', '天猫', '行业策略人群 (消费理念向)', '品质生活、大众实用、低价实惠', 'direct', '价值主张匹配：决定商品详情页是侧重“匠心工艺”还是“性价比”。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A27:F27', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),

  ('pls_map_douyin_s_price_incentive_response', 'pls_dim_s_price_incentive_response', '抖音', '(平台未直接输出，需运营人工打标)', '发福袋、倒计时秒杀', 'manual', '人工输入，动态增加匹配权重。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A29:F29', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('pls_map_jd_s_price_incentive_response', 'pls_dim_s_price_incentive_response', '京东', '促销敏感度、折扣率偏好', '极度敏感、7-8折偏好', 'direct', '系统自动输出发售定价策略（如大额券）。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A30:F30', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('pls_map_tmall_s_price_incentive_response', 'pls_dim_s_price_incentive_response', '天猫', '折扣敏感度', '高、中、低', 'direct', '辅助判定发售价格机制（高敏感人群配发大额满减）。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A31:F31', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),

  ('pls_map_douyin_s_conversion_friction', 'pls_dim_s_conversion_friction', '抖音', '触点互动偏好', '习惯点赞、习惯加购', 'direct', '决定广告是视频挂车还是直播间直投。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A33:F33', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('pls_map_jd_s_conversion_friction', 'pls_dim_s_conversion_friction', '京东', '评价敏感度、冲动购买', '高度敏感、冲动型', 'direct', '高敏感人群需先做种草和好评铺垫再收割。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A34:F34', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('pls_map_tmall_s_conversion_friction', 'pls_dim_s_conversion_friction', '天猫', '(平台未直接输出)', '-', 'manual', '依赖人工补充转化阻力标签。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A35:F35', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),

  ('pls_map_douyin_s_environment', 'pls_dim_s_environment', '抖音', '手机品牌、活跃用户', '苹果、华为', 'direct', '苹果用户推高客单现货，降低流失率。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A37:F37', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('pls_map_jd_s_environment', 'pls_dim_s_environment', '京东', '活跃时段、手机品牌', '晚8点-10点', 'direct', '精准定时：根据活跃时段调整出价权重。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A38:F38', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z'),
  ('pls_map_tmall_s_environment', 'pls_dim_s_environment', '天猫', '(平台未直接输出)', '-', 'inferred', '结合全域数据平滑推测环境特征。', 'PLS业务语义及主数据标准-v0.1.xlsx#工作表 1!A39:F39', 'active', '2026-07-13T00:00:00.000Z', '2026-07-13T00:00:00.000Z')
ON CONFLICT(dimension_id, platform) DO UPDATE SET
  raw_tag_fields = excluded.raw_tag_fields,
  raw_enum_examples = excluded.raw_enum_examples,
  data_availability = excluded.data_availability,
  mapping_strategy = excluded.mapping_strategy,
  source_ref = excluded.source_ref,
  status = excluded.status,
  updated_at = excluded.updated_at;
