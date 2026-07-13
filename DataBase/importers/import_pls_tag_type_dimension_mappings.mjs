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
      WHERE platform IN ('天猫', '抖音')
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
      WHERE platform IN ('天猫', '抖音')
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
WHERE platform IN ('天猫', '抖音')
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
    const suggestion = suggestDimension(item.tag_type, item.examples || "");
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
  dimension_id = excluded.dimension_id,
  mapping_status = excluded.mapping_status,
  mapping_method = excluded.mapping_method,
  confidence = excluded.confidence,
  rationale = excluded.rationale,
  source_ref = excluded.source_ref,
  status = excluded.status,
  updated_at = excluded.updated_at;
`);
  }

  statements.push("COMMIT;");
  await runSql(statements.join("\n"));
  console.log(`Imported ${tagTypes.length} PLS tag type dimension mappings.`);
}

function suggestDimension(tagType, examples) {
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
