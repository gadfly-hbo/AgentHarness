#!/usr/bin/env node

import { createServer } from "node:http";
import { readFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const databaseRoot = path.resolve(__dirname, "..");
const dbPath = path.join(databaseRoot, "agentharness.sqlite");
const port = Number(process.env.AGENTHARNESS_DATABASE_CONSOLE_PORT || 8788);

const semanticNotes = {
  entities: {
    purpose:
      "Stable identity registry for projects, models, modules, databases, and later business objects.",
    productUse:
      "Used by ModelEvol and PLS as the shared identity layer before specialized tables are added.",
    nextLinks:
      "Future tables should reference entities.id instead of inventing separate identifiers.",
  },
  pls_semantic_dimensions: {
    purpose:
      "Standard PLS semantic dimension table for the P, L, and S layer model.",
    productUse:
      "Used by the PLS profile module and audience segmentation model as the shared semantic foundation.",
    nextLinks:
      "Platform tag mappings, profile observations, segment rules, and segment assignments should reference these dimensions.",
  },
  pls_platform_tag_mappings: {
    purpose:
      "Platform-specific mapping table from Douyin, JD, and Tmall raw tags into standard PLS semantic dimensions.",
    productUse:
      "Used by PLS profiles and the audience segmentation model to normalize platform labels before scoring or grouping.",
    nextLinks:
      "Profile observations should consume these mappings when transforming platform-side tags into PLS dimension values.",
  },
  platform_tag_catalog: {
    purpose:
      "Raw platform tag catalog for platform label ingestion before PLS alignment.",
    productUse:
      "Used to preserve Tmall and Douyin tag types and tag values before mapping them into the PLS model.",
    nextLinks:
      "Tag type and tag value mapping tables should reference this catalog when aligning platform labels to PLS dimensions.",
  },
  pls_tag_type_dimension_mappings: {
    purpose:
      "Maps platform tag types from Tmall and Douyin into the standard PLS dimensions.",
    productUse:
      "Used as the first alignment layer before detailed tag values are normalized into PLS profile and segmentation logic.",
    nextLinks:
      "Reviewed mappings should feed tag value mappings, profile observations, and later segment rules.",
  },
  pls_tag_value_dimension_mappings: {
    purpose:
      "Maps concrete Tmall and Douyin tag values into standard PLS dimensions.",
    productUse:
      "Used by PLS profile modules and ModelEvol when consuming actual platform tag values rather than broad tag types.",
    nextLinks:
      "Manual overrides should be made here when a tag value needs finer treatment than its parent tag type.",
  },
  v_pls_platform_tag_value_semantics: {
    purpose:
      "Product-facing read view that expands each platform tag value with PLS layer, dimension, definition, strategy, and traceability.",
    productUse:
      "Used as the default read surface for PLS portrait modules, audience segmentation, and ModelEvol feature consumption.",
    nextLinks:
      "Read from this view; write corrections to pls_tag_value_dimension_mappings.",
  },
  profile_tag_observations: {
    purpose:
      "Fact table recording that a user, account, audience segment, product, or sample subject matched a concrete platform tag value.",
    productUse:
      "Used by PLS profile modules and ModelEvol to turn platform tag hits into PLS semantic features.",
    nextLinks:
      "Join platform_tag_catalog_id to v_pls_platform_tag_value_semantics to expand each observation into PLS layer and dimension fields.",
  },
  v_profile_tag_observation_semantics: {
    purpose:
      "Read view combining subject tag observations with PLS semantic layer and dimension fields.",
    productUse:
      "Used by PLS and ModelEvol to read subject-level PLS features with one query.",
    nextLinks:
      "Write observations to profile_tag_observations; correct mapping semantics in pls_tag_value_dimension_mappings.",
  },
  v_subject_pls_dimension_features: {
    purpose:
      "Aggregates subject tag observations into PLS dimension-level feature rows.",
    productUse:
      "Used by PLS and ModelEvol when they need compact subject-level feature vectors instead of raw tag details.",
    nextLinks:
      "Use v_profile_tag_observation_semantics for tag-level explainability and this view for model-ready dimension features.",
  },
  v_subject_pls_feature_matrix: {
    purpose:
      "Pivots subject-level PLS dimension features into one row per subject with nine score columns.",
    productUse:
      "Used by ModelEvol, reports, and profile cards that need compact PLS feature vectors.",
    nextLinks:
      "Use v_subject_pls_dimension_features for dimension-row analytics and this view for wide feature input.",
  },
  pls_channel_objects: {
    purpose:
      "承接 PLS 渠道画像对象库的主数据，包括平台、商圈、店铺、账号、活动和业务场景。",
    productUse:
      "用于把 PLS 的渠道对象身份、来源批次、数据版本、质量标记和人工复核状态纳入 AgentHarness 数据治理。",
    nextLinks:
      "下一步创建 pls_channel_object_bindings，再继续接入 audience_profile 和 product_fit_profile。",
  },
  pls_channel_object_bindings: {
    purpose:
      "承接 PLS 渠道画像对象之间的关系，包括平台到账号、商圈到店铺、活动到渠道对象、业务场景到渠道对象。",
    productUse:
      "用于恢复渠道画像的上下文结构，让后续人群画像和商品适配画像能够知道自己属于哪个平台、店铺、活动或场景。",
    nextLinks:
      "下一步创建 pls_audience_profiles，承接渠道对象的人群画像标签、样本量、置信度和质量标记。",
  },
  pls_audience_profiles: {
    purpose:
      "承接 PLS 渠道对象的人群画像快照，包括画像标签、样本量、置信度、时间窗口、未映射字段和质量标记。",
    productUse:
      "用于回答某个渠道对象面对什么样的人群，并为后续 PLS 分层映射、商品适配和渠道匹配提供人群侧依据。",
    nextLinks:
      "下一步创建 pls_product_fit_profiles，承接渠道对象适合销售的品类、价格带、风格、场景和证据。",
  },
  pls_product_fit_profiles: {
    purpose:
      "承接 PLS 渠道对象的商品适配画像，包括适合品类、价格带、风格、使用场景、上新类型、证据、置信度和质量标记。",
    productUse:
      "用于回答某个渠道对象适合卖什么商品，并为货渠匹配、新品预测和经营飞轮提供商品侧依据。",
    nextLinks:
      "下一步创建渠道画像综合 read view，把对象、关系、人群画像和商品适配画像合并成产品可直接读取的表面。",
  },
  v_pls_channel_profile_overview: {
    purpose:
      "产品读取用的 PLS 渠道画像综合视图，把渠道对象、人群画像和商品适配画像汇总到一张概览表。",
    productUse:
      "用于渠道画像列表、详情卡片、画像完整度检查，以及后续货渠匹配前的基础读取面。",
    nextLinks:
      "后续不要直接写入该 view；新增或修正数据应写入 pls_channel_objects、pls_audience_profiles 和 pls_product_fit_profiles。",
  },
  pls_audience_tag_dimension_mappings: {
    purpose:
      "把 PLS 渠道画像标签映射到 PLS 三层九维标准维度，例如 demo.age_25_34、style.minimal、price.mid。",
    productUse:
      "用于把渠道对象的人群画像标签转成统一 PLS 维度特征，服务分层模型、货渠匹配和画像解释。",
    nextLinks:
      "下一步创建 audience tag 语义展开 view，再聚合为渠道对象级 PLS 维度特征。",
  },
  v_pls_audience_tag_semantics: {
    purpose:
      "把 pls_audience_profiles.tags_json 展开为一行一个人群标签，并连接到 PLS 三层九维语义维度。",
    productUse:
      "用于渠道画像标签解释、按渠道对象聚合 PLS 维度特征，以及后续货渠匹配模型读取。",
    nextLinks:
      "下一步创建渠道对象级 PLS 维度特征聚合 view，按 canonical_object_key 和 dimension_code 汇总 tag_score。",
  },
  v_pls_channel_dimension_features: {
    purpose:
      "按渠道对象和 PLS 维度聚合人群标签分数，形成渠道对象级 PLS 维度特征。",
    productUse:
      "用于货渠匹配、渠道画像特征卡片、ModelEvol 特征输入，以及后续一行九维宽表构建。",
    nextLinks:
      "下一步创建 v_pls_channel_feature_matrix，把维度特征透视成一渠道对象一行的九维分数字段。",
  },
  v_pls_channel_feature_matrix: {
    purpose:
      "把渠道对象级 PLS 维度特征透视成一渠道对象一行的九维特征宽表。",
    productUse:
      "作为 PLS 产品和 ModelEvol 消费渠道画像能力的第一版模型特征读取入口。",
    nextLinks:
      "后续真实数据导入后，优先用这张 view 做渠道匹配、模型实验和画像卡片特征读取。",
  },
};

const fieldNotes = {
  entities: {
    id: "Stable primary key used by other tables.",
    entity_type: "Object category such as project, model, module, database, product, account, or segment.",
    canonical_name: "Human-readable standard name.",
    source_system: "Where the entity was first registered or imported from.",
    external_ref: "Optional source-facing identifier. Unique within source_system when present.",
    status: "Lifecycle state for governance and filtering.",
    attributes_json: "Flexible JSON metadata kept valid by SQLite json_valid().",
    created_at: "Creation timestamp in UTC-like ISO format.",
    updated_at: "Last update timestamp in UTC-like ISO format.",
  },
  pls_semantic_dimensions: {
    id: "Stable primary key for the PLS semantic dimension.",
    layer_code: "PLS layer code: P, L, or S.",
    layer_name: "Human-readable layer name.",
    dimension_code: "Stable machine-readable dimension code.",
    dimension_name: "Standard PLS dimension name.",
    dimension_definition: "Compact definition or semantic scope of the dimension.",
    business_strategy: "Business strategy from the PLS master data standard.",
    source_platform: "Source platform for this record. For this table it is the common mapping standard.",
    source_ref: "Workbook and range provenance.",
    status: "Lifecycle state for governance and filtering.",
    created_at: "Creation timestamp in UTC-like ISO format.",
    updated_at: "Last update timestamp in UTC-like ISO format.",
  },
};

async function main() {
  const server = createServer(async (request, response) => {
    try {
      const url = new URL(request.url || "/", `http://${request.headers.host}`);

      if (url.pathname === "/" || url.pathname === "/index.html") {
        await sendFile(response, path.join(__dirname, "index.html"), "text/html; charset=utf-8");
        return;
      }

      if (url.pathname === "/styles.css") {
        await sendFile(response, path.join(__dirname, "styles.css"), "text/css; charset=utf-8");
        return;
      }

      if (url.pathname === "/app.js") {
        await sendFile(response, path.join(__dirname, "app.js"), "text/javascript; charset=utf-8");
        return;
      }

      if (url.pathname === "/api/schema") {
        await sendJson(response, await readDatabaseSchema());
        return;
      }

      if (url.pathname === "/api/readme") {
        await sendJson(response, await readReadme());
        return;
      }

      sendJson(response, { error: "Not found" }, 404);
    } catch (error) {
      sendJson(response, { error: error.message }, 500);
    }
  });

  server.listen(port, "127.0.0.1", () => {
    console.log(`AgentHarness DataBase console: http://127.0.0.1:${port}`);
    console.log(`SQLite database: ${dbPath}`);
  });
}

async function readReadme() {
  const readmePath = path.join(databaseRoot, "docs", "pls-consumption-guide.md");
  return {
    path: readmePath,
    markdown: await readFile(readmePath, "utf8"),
  };
}

async function readDatabaseSchema() {
  const tables = await sqliteJson(`
    SELECT name, type, sql
    FROM sqlite_master
    WHERE type IN ('table', 'view') AND name NOT LIKE 'sqlite_%'
    ORDER BY name;
  `);

  const enrichedTables = [];

  for (const table of tables) {
    const quotedName = quoteIdentifier(table.name);
    const columns = await sqliteJson(`PRAGMA table_info(${quotedName});`);
    const indexes = await sqliteJson(`PRAGMA index_list(${quotedName});`);
    const rowCount = await sqliteJson(`SELECT COUNT(*) AS count FROM ${quotedName};`);
    const sampleRows = await sqliteJson(`SELECT * FROM ${quotedName} LIMIT 20;`);
    const comments = await readFieldComments(table.name);
    const commentsByField = new Map(
      comments.map((comment) => [comment.field_name, comment]),
    );

    enrichedTables.push({
      name: table.name,
      type: table.type,
      createSql: table.sql,
      rowCount: rowCount[0]?.count || 0,
      purpose: semanticNotes[table.name]?.purpose || "No table purpose note has been recorded yet.",
      productUse: semanticNotes[table.name]?.productUse || "No product usage note has been recorded yet.",
      nextLinks: semanticNotes[table.name]?.nextLinks || "No relationship note has been recorded yet.",
      columns: columns.map((column) => ({
        cid: column.cid,
        name: column.name,
        zhName: commentsByField.get(column.name)?.zh_name || "",
        zhDescription: commentsByField.get(column.name)?.zh_description || "",
        businessMeaning: commentsByField.get(column.name)?.business_meaning || "",
        exampleValue: commentsByField.get(column.name)?.example_value || "",
        type: column.type || "ANY",
        notNull: column.notnull === 1,
        defaultValue: column.dflt_value,
        primaryKey: column.pk === 1,
        note:
          fieldNotes[table.name]?.[column.name] ||
          commentsByField.get(column.name)?.zh_description ||
          "",
      })),
      indexes: indexes.map((index) => ({
        name: index.name,
        unique: index.unique === 1,
        origin: index.origin,
        partial: index.partial === 1,
      })),
      sampleRows,
    });
  }

  return {
    databasePath: dbPath,
    generatedAt: new Date().toISOString(),
    tables: enrichedTables,
  };
}

async function readFieldComments(tableName) {
  const hasCommentsTable = await sqliteJson(`
    SELECT name
    FROM sqlite_master
    WHERE type = 'table' AND name = 'database_field_comments';
  `);

  if (hasCommentsTable.length === 0) {
    return [];
  }

  return sqliteJson(
    `
      SELECT
        field_name,
        zh_name,
        zh_description,
        business_meaning,
        example_value
      FROM database_field_comments
      WHERE table_name = ${quoteSqlString(tableName)}
        AND status = 'active'
      ORDER BY field_name;
    `,
  );
}

async function sqliteJson(sql) {
  const { stdout } = await execFileAsync("sqlite3", [
    "-json",
    dbPath,
    sql,
  ]);

  const trimmed = stdout.trim();
  return trimmed ? JSON.parse(trimmed) : [];
}

async function sendFile(response, filePath, contentType) {
  const content = await readFile(filePath);
  response.writeHead(200, {
    "content-type": contentType,
    "cache-control": "no-store",
  });
  response.end(content);
}

function sendJson(response, payload, status = 200) {
  response.writeHead(status, {
    "content-type": "application/json; charset=utf-8",
    "cache-control": "no-store",
  });
  response.end(JSON.stringify(payload));
}

function quoteIdentifier(value) {
  return `"${String(value).replaceAll('"', '""')}"`;
}

function quoteSqlString(value) {
  return `'${String(value).replaceAll("'", "''")}'`;
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
