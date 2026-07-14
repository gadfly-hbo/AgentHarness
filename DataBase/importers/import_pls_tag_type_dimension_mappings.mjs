#!/usr/bin/env node

import { spawn } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { readFile } from "node:fs/promises";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const databaseRoot = path.resolve(__dirname, "..");
const repoRoot = path.resolve(databaseRoot, "..");
const dbPath = path.join(databaseRoot, "agentharness.sqlite");

const now = "2026-07-13T00:00:00.000Z";
const targetPlatforms = ["天猫", "抖音", "京东"];

const approvedMappingsByPlatform = new Map([
  [
    "天猫::AI标签_服饰需求特征",
    [
      "pls_dim_l_innovation_brand_mind",
      "用户补充的AI服饰需求特征描述服饰风格、版型诉求、材质偏好、气质表达与高消费风格人群，归入L层创新与品牌心智。",
    ],
  ],
]);

const jdApprovedMappings = new Map([
  ["PLUS会员", ["pls_dim_p_identity_cluster", "京东会员身份标签，归入P层综合身份聚类。"]],
  ["京享值", ["pls_dim_p_purchasing_power", "京享值反映平台会员价值与消费资产水位，归入P层社会资产与购买力。"]],
  ["促销敏感度", ["pls_dim_s_price_incentive_response", "促销敏感度直接描述价格与权益刺激反应，归入S层价格与利益应激。"]],
  ["健身爱好者", ["pls_dim_l_lifestyle", "兴趣爱好类生活方式标签，归入L层圈层生活方式。"]],
  ["全站新品偏好", ["pls_dim_l_innovation_brand_mind", "新品偏好描述创新接受度，归入L层创新与品牌心智。"]],
  ["冲动购买", ["pls_dim_s_conversion_friction", "冲动购买描述临门转化行为特征，归入S层转化决策摩擦。"]],
  ["十大靶群", ["pls_dim_p_identity_cluster", "京东靶群是平台人群簇标签，归入P层综合身份聚类。"]],
  ["城市线级", ["pls_dim_p_demographics", "城市线级是基础地域人口属性，归入P层基础人口学。"]],
  ["女装用户", ["pls_dim_l_lifestyle", "女装品类用户标签描述品类生活偏好，归入L层圈层生活方式。"]],
  ["婚姻状况", ["pls_dim_p_identity_cluster", "婚姻状况描述家庭与身份阶段，归入P层综合身份聚类。"]],
  ["学历", ["pls_dim_p_purchasing_power", "学历可作为社会资产和购买力判断的基础变量，归入P层社会资产与购买力。"]],
  ["孩子预测年龄", ["pls_dim_p_identity_cluster", "孩子年龄描述家庭生命周期和育儿阶段，归入P层综合身份聚类。"]],
  ["客户当前使用手机品牌", ["pls_dim_s_environment", "手机品牌是数字设备环境标签，归入S层物理/数字环境。"]],
  ["宠物爱好者", ["pls_dim_l_lifestyle", "宠物兴趣描述生活方式圈层，归入L层圈层生活方式。"]],
  ["常用收货省份", ["pls_dim_p_demographics", "常用收货省份是基础地域属性，归入P层基础人口学。"]],
  ["年龄", ["pls_dim_p_demographics", "年龄是基础人口学变量，归入P层基础人口学。"]],
  ["性别", ["pls_dim_p_demographics", "性别是基础人口学变量，归入P层基础人口学。"]],
  ["户外运动爱好者", ["pls_dim_l_lifestyle", "户外运动兴趣描述生活方式圈层，归入L层圈层生活方式。"]],
  ["无线端操作系统", ["pls_dim_s_environment", "操作系统是数字设备环境标签，归入S层物理/数字环境。"]],
  ["无线端购物活跃时段-近7天", ["pls_dim_s_environment", "购物活跃时段描述数字触达环境，归入S层物理/数字环境。"]],
  ["日均订单数量-近30天", ["pls_dim_s_conversion_friction", "订单频次描述购买转化行为强度，归入S层转化决策摩擦。"]],
  ["日均订单数量-近7天", ["pls_dim_s_conversion_friction", "订单频次描述近期购买转化行为强度，归入S层转化决策摩擦。"]],
  ["旅游爱好者", ["pls_dim_l_lifestyle", "旅游兴趣描述生活方式圈层，归入L层圈层生活方式。"]],
  ["有房人群", ["pls_dim_p_purchasing_power", "有房属性反映资产水位，归入P层社会资产与购买力。"]],
  ["有车一族", ["pls_dim_p_purchasing_power", "有车属性反映资产水位，归入P层社会资产与购买力。"]],
  ["用户年代", ["pls_dim_p_demographics", "用户年代是基础年龄代际属性，归入P层基础人口学。"]],
  ["用户月平均支付订单总额", ["pls_dim_p_purchasing_power", "月均支付订单总额直接描述消费金额，归入P层社会资产与购买力。"]],
  ["用户月支付订单数量", ["pls_dim_s_conversion_friction", "月支付订单数量描述购买频次和转化行为，归入S层转化决策摩擦。"]],
  ["用户消费月份偏好", ["pls_dim_s_environment", "消费月份偏好描述消费发生时间环境，归入S层物理/数字环境。"]],
  ["热衷使用优惠券用户", ["pls_dim_s_price_incentive_response", "优惠券使用偏好直接描述权益刺激反应，归入S层价格与利益应激。"]],
  ["游戏爱好者", ["pls_dim_l_lifestyle", "游戏兴趣描述生活方式圈层，归入L层圈层生活方式。"]],
  ["科技产品爱好者", ["pls_dim_l_lifestyle", "科技产品兴趣描述品类与生活方式偏好，归入L层圈层生活方式。"]],
  ["秒杀商品偏好", ["pls_dim_s_price_incentive_response", "秒杀偏好描述促销机制响应，归入S层价格与利益应激。"]],
  ["职业", ["pls_dim_p_identity_cluster", "职业描述社会身份和人群角色，归入P层综合身份聚类。"]],
  ["评价敏感度", ["pls_dim_s_conversion_friction", "评价敏感度描述购买前决策阻力，归入S层转化决策摩擦。"]],
  ["购买力", ["pls_dim_p_purchasing_power", "购买力是消费资产水位标签，归入P层社会资产与购买力。"]],
  ["体育运动爱好者", ["pls_dim_l_lifestyle", "体育运动兴趣描述生活方式圈层，归入L层圈层生活方式。"]],
  ["商品折扣率偏好", ["pls_dim_s_price_incentive_response", "折扣率偏好直接描述价格刺激反应，归入S层价格与利益应激。"]],
]);

const rules = [
  {
    dimensionId: "pls_dim_p_demographics",
    confidence: 0.92,
    typePatterns: ["性别", "年龄", "年代", "地域分布", "省份", "城市", "星座"],
    valuePatterns: ["岁", "北京", "上海", "广东", "白羊", "金牛", "双子"],
    rationale: "标签类型或标签值描述性别、年龄、地域、星座等基础人口学坐标，映射到P层基础人口学。",
  },
  {
    dimensionId: "pls_dim_s_conversion_friction",
    confidence: 0.9,
    typePatterns: ["行业场景人群"],
    valuePatterns: ["痛点", "破价", "显腿长", "不好看", "烦恼", "降温"],
    rationale: "标签类型或标签值描述用户痛点、即时诉求或临门转化触发点，映射到S层转化决策摩擦。",
  },
  {
    dimensionId: "pls_dim_p_identity_cluster",
    confidence: 0.88,
    typePatterns: ["八大消费群体", "人群包", "人生阶段", "母婴阶段", "宝宝年龄", "子女年龄", "会员", "靶群", "重点人群", "策略人群", "特色人群", "职业", "婚恋阶段", "住房状态", "是否有车", "在校大学生", "家有老幼"],
    valuePatterns: ["人群", "妈妈", "白领", "银发", "青年", "中年", "老年", "中产", "蓝领", "职场", "校园", "主妇", "达人", "玩家"],
    rationale: "标签类型或标签值描述身份、家庭阶段、职业圈层或平台人群簇，映射到P层综合身份聚类。",
  },
  {
    dimensionId: "pls_dim_p_purchasing_power",
    confidence: 0.86,
    typePatterns: ["购买力", "消费能力", "消费金额", "中高ARPU", "高ARPU", "月均消费金额", "年消费金额", "手机价格"],
    valuePatterns: ["高消费", "中消费", "低消费", "高ARPU", "高端"],
    rationale: "标签类型或标签值描述消费力、消费金额或资产水位，映射到P层社会资产与购买力。",
  },
  {
    dimensionId: "pls_dim_l_content_visual_mind",
    confidence: 0.9,
    typePatterns: ["视频观看", "阅读兴趣", "内容类型", "影视", "电影", "电视剧", "综艺", "时尚兴趣", "美学", "视觉", "视频类型"],
    valuePatterns: ["影视", "娱乐", "社会", "搞笑", "综艺", "言情", "都市", "悬疑", "科幻", "潮流", "时尚"],
    rationale: "标签类型或标签值描述内容兴趣、媒体偏好、审美风格或视觉心智，映射到L层内容与视觉心智。",
  },
  {
    dimensionId: "pls_dim_l_innovation_brand_mind",
    confidence: 0.88,
    typePatterns: ["品牌", "新品", "新款", "消费理念", "品质", "潮奢", "包装", "换机", "功能偏好", "特色人群", "应用人群"],
    valuePatterns: ["品牌", "品质", "质感", "轻奢", "奢美", "精选", "数码发烧", "DIY", "实用生活", "功能", "包装", "防晒抗老", "防晒美白", "KANS", "韩束", "三只松鼠", "盐津铺子"],
    rationale: "标签类型或标签值描述品牌、新品、功能诉求、品质偏好或价值主张，映射到L层创新与品牌心智。",
  },
  {
    dimensionId: "pls_dim_l_lifestyle",
    confidence: 0.88,
    typePatterns: ["类目", "品类", "兴趣偏好", "运动兴趣", "生活方式", "购买人群", "成交偏好", "搜索行为", "行业词", "到访偏好", "宠物", "母婴用品", "美食兴趣", "生活兴趣", "产地偏好"],
    valuePatterns: ["户外", "露营", "旅行", "美食", "饮料", "啤酒", "咖啡", "宠物", "猫", "狗", "绿植", "装修", "女装", "男装", "箱包", "鞋", "食品", "手机", "汽车", "美妆"],
    rationale: "标签类型或标签值描述品类、兴趣、生活场景或生活方式偏好，映射到L层圈层生活方式。",
  },
  {
    dimensionId: "pls_dim_s_price_incentive_response",
    confidence: 0.88,
    typePatterns: ["折扣", "促销", "优惠", "券", "价格敏感", "低价", "满减", "价格段"],
    valuePatterns: ["折", "低价", "实惠", "平价", "价格敏感", "元以下"],
    rationale: "标签类型或标签值描述促销、折扣、价格段或利益刺激反应，映射到S层价格与利益应激。",
  },
  {
    dimensionId: "pls_dim_s_conversion_friction",
    confidence: 0.9,
    typePatterns: ["触点互动", "评价敏感", "冲动购买", "点击", "加购", "购买行为", "订单频次", "订单天数", "活跃人群", "直播观看", "消费频次", "购物频次", "尺码偏好", "颜色偏好", "色号偏好", "功效需求", "功效偏好", "产品偏好", "类型偏好", "肤质", "体重", "身高"],
    valuePatterns: ["L", "M", "S", "XL", "XS", "均码", "红", "蓝", "黑", "白", "保湿", "修护", "控油", "防晒", "美白", "去屑", "清洁", "护理", "点击", "加购"],
    rationale: "标签类型或标签值描述尺码、颜色、功效、产品选择、点击加购或购买频次等临门转化摩擦，映射到S层转化决策摩擦。",
  },
  {
    dimensionId: "pls_dim_s_environment",
    confidence: 0.86,
    typePatterns: ["手机品牌", "活跃时段", "购物时间", "设备", "环境", "线下到访", "上网设备"],
    valuePatterns: ["苹果", "华为", "小米", "三星", "0-1", "晚8点", "设备"],
    rationale: "标签类型或标签值描述设备、时段或物理/数字触达环境，映射到S层物理/数字环境。",
  },
];

async function main() {
  const migrationPath = path.join(
    databaseRoot,
    "migrations",
    "006_create_pls_tag_type_dimension_mappings.sql",
  );
  await runSql(await readFile(migrationPath, "utf8"));

  const tagTypes = await sqliteJson(`
    WITH tag_counts AS (
      SELECT
        platform,
        tag_type,
        COUNT(*) AS tag_count
      FROM platform_tag_catalog
        WHERE platform IN (${targetPlatforms.map(sqlValue).join(", ")})
        AND status = 'active'
      GROUP BY platform, tag_type
    ),
    ranked AS (
      SELECT
        platform,
        tag_type,
        leaf_label,
        ROW_NUMBER() OVER (
          PARTITION BY platform, tag_type
          ORDER BY source_row
        ) AS rn
      FROM platform_tag_catalog
      WHERE platform IN (${targetPlatforms.map(sqlValue).join(", ")})
        AND status = 'active'
    ),
    examples AS (
      SELECT
        platform,
        tag_type,
        GROUP_CONCAT(leaf_label, '、') AS examples
      FROM ranked
      WHERE rn <= 8
      GROUP BY platform, tag_type
    )
    SELECT
      tag_counts.platform,
      tag_counts.tag_type,
      tag_counts.tag_count,
      examples.examples
    FROM tag_counts
    LEFT JOIN examples
      ON examples.platform = tag_counts.platform
      AND examples.tag_type = tag_counts.tag_type
    ORDER BY tag_counts.platform, tag_counts.tag_type;
  `);

  const statements = [
    "PRAGMA foreign_keys = ON;",
    "BEGIN;",
    `
DELETE FROM pls_tag_type_dimension_mappings
WHERE platform IN (${targetPlatforms.map(sqlValue).join(", ")})
  AND NOT EXISTS (
    SELECT 1
    FROM platform_tag_catalog catalog
    WHERE catalog.platform = pls_tag_type_dimension_mappings.platform
      AND catalog.tag_type = pls_tag_type_dimension_mappings.tag_type
      AND catalog.status = 'active'
  );
`,
  ];

  for (const item of tagTypes) {
    const suggestion = suggestDimension(item.platform, item.tag_type, item.examples || "");
    const id = makeId(item.platform, item.tag_type);
    const values = [
      id,
      item.platform,
      item.tag_type,
      suggestion.dimensionId,
      suggestion.mappingStatus,
      "rule",
      suggestion.confidence,
      suggestion.rationale,
      `platform_tag_catalog:${item.platform}:${item.tag_type}`,
      "active",
      now,
      now,
    ];

    statements.push(`
INSERT INTO pls_tag_type_dimension_mappings (
  id,
  platform,
  tag_type,
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
VALUES (${values.map(sqlValue).join(", ")})
ON CONFLICT(platform, tag_type) DO UPDATE SET
  dimension_id = CASE
    WHEN pls_tag_type_dimension_mappings.mapping_status = 'approved'
    THEN pls_tag_type_dimension_mappings.dimension_id
    ELSE excluded.dimension_id
  END,
  mapping_status = CASE
    WHEN pls_tag_type_dimension_mappings.mapping_status = 'approved'
    THEN pls_tag_type_dimension_mappings.mapping_status
    ELSE excluded.mapping_status
  END,
  mapping_method = CASE
    WHEN pls_tag_type_dimension_mappings.mapping_status = 'approved'
    THEN pls_tag_type_dimension_mappings.mapping_method
    ELSE excluded.mapping_method
  END,
  confidence = CASE
    WHEN pls_tag_type_dimension_mappings.mapping_status = 'approved'
    THEN pls_tag_type_dimension_mappings.confidence
    ELSE excluded.confidence
  END,
  rationale = CASE
    WHEN pls_tag_type_dimension_mappings.mapping_status = 'approved'
    THEN pls_tag_type_dimension_mappings.rationale
    ELSE excluded.rationale
  END,
  source_ref = excluded.source_ref,
  status = excluded.status,
  updated_at = excluded.updated_at;
`);
  }

  statements.push("COMMIT;");
  await runSql(statements.join("\n"));
  console.log(`Imported ${tagTypes.length} PLS tag type dimension mappings.`);
}

function suggestDimension(platform, tagType, examples) {
  const approvedKey = `${platform}::${tagType}`;
  if (approvedMappingsByPlatform.has(approvedKey)) {
    const [dimensionId, rationale] = approvedMappingsByPlatform.get(approvedKey);
    return {
      dimensionId,
      mappingStatus: "approved",
      confidence: 1,
      rationale: `${rationale} 判断依据：平台="${platform}"；标签类型="${tagType}"；代表标签值="${examples || "无"}"。`,
    };
  }

  if (platform === "京东" && jdApprovedMappings.has(tagType)) {
    const [dimensionId, rationale] = jdApprovedMappings.get(tagType);
    return {
      dimensionId,
      mappingStatus: "approved",
      confidence: 1,
      rationale: `${rationale} 判断依据：京东标签类型="${tagType}"；代表标签值="${examples || "无"}"。`,
    };
  }

  const evidence = `${tagType} ${examples}`;
  for (const rule of rules) {
    const matchedByType = rule.typePatterns.some((pattern) =>
      tagType.includes(pattern),
    );
    const matchedByValue = rule.valuePatterns.some((pattern) =>
      evidence.includes(pattern),
    );
    if (matchedByType || matchedByValue) {
      const confidence = matchedByType && matchedByValue
        ? Math.min(1, rule.confidence + 0.04)
        : rule.confidence;
      return {
        dimensionId: rule.dimensionId,
        mappingStatus: confidence >= 0.88 ? "proposed" : "review_needed",
        confidence,
        rationale: `${rule.rationale} 判断依据：标签类型="${tagType}"；代表标签值="${examples || "无"}"。`,
      };
    }
  }

  return {
    dimensionId: null,
    mappingStatus: "unmapped",
    confidence: 0,
    rationale: "当前规则无法可靠判断该标签类型所属PLS维度，需要人工复核。",
  };
}

async function sqliteJson(sql) {
  const output = await runSql(sql, ["-json"]);
  const trimmed = output.trim();
  return trimmed ? JSON.parse(trimmed) : [];
}

async function runSql(sql, extraArgs = []) {
  return new Promise((resolve, reject) => {
    const child = spawn("sqlite3", [...extraArgs, dbPath], {
      cwd: repoRoot,
      stdio: ["pipe", "pipe", "pipe"],
    });

    let stdout = "";
    let stderr = "";
    child.stdout.on("data", (chunk) => {
      stdout += chunk;
    });
    child.stderr.on("data", (chunk) => {
      stderr += chunk;
    });
    child.on("error", reject);
    child.on("close", (code) => {
      if (code === 0) {
        resolve(stdout);
      } else {
        reject(new Error(stderr || `sqlite3 exited with ${code}`));
      }
    });
    child.stdin.end(sql);
  });
}

function makeId(platform, tagType) {
  const normalized = `${platform}_${tagType}`
    .normalize("NFKD")
    .replace(/[^\p{Letter}\p{Number}]+/gu, "_")
    .replace(/^_+|_+$/g, "")
    .toLowerCase();
  return `ptypemap_${normalized}`;
}

function sqlValue(value) {
  if (value === null || value === undefined) {
    return "NULL";
  }
  if (typeof value === "number") {
    return String(value);
  }
  return `'${String(value).replaceAll("'", "''")}'`;
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
