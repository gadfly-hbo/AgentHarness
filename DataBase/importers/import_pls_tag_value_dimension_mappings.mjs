#!/usr/bin/env node

import { spawn } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { readFile } from "node:fs/promises";
import { createHash } from "node:crypto";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const databaseRoot = path.resolve(__dirname, "..");
const repoRoot = path.resolve(databaseRoot, "..");
const dbPath = path.join(databaseRoot, "agentharness.sqlite");

const now = "2026-07-13T00:00:00.000Z";
const targetPlatforms = ["天猫", "抖音", "京东"];

async function main() {
  const migrationPath = path.join(
    databaseRoot,
    "migrations",
    "008_create_pls_tag_value_dimension_mappings.sql",
  );
  await runSql(await readFile(migrationPath, "utf8"));

  const rows = await sqliteJson(`
    SELECT id
    FROM platform_tag_catalog
    WHERE platform IN (${targetPlatforms.map(sqlValue).join(", ")})
      AND status = 'active'
    ORDER BY platform, source_row;
  `);

  const idRows = rows.map((row) => ({
    catalogId: row.id,
    mappingId: makeId(row.id),
  }));

  const statements = [
    "PRAGMA foreign_keys = ON;",
    "BEGIN;",
    "CREATE TEMP TABLE IF NOT EXISTS tmp_pls_tag_value_mapping_ids (platform_tag_catalog_id TEXT PRIMARY KEY, mapping_id TEXT NOT NULL);",
    "DELETE FROM tmp_pls_tag_value_mapping_ids;",
    ...idRows.map((row) => `
INSERT INTO tmp_pls_tag_value_mapping_ids (
  platform_tag_catalog_id,
  mapping_id
)
VALUES (${sqlValue(row.catalogId)}, ${sqlValue(row.mappingId)});
`),
    `
DELETE FROM pls_tag_value_dimension_mappings
WHERE platform IN (${targetPlatforms.map(sqlValue).join(", ")})
  AND NOT EXISTS (
    SELECT 1
    FROM platform_tag_catalog catalog
    WHERE catalog.id = pls_tag_value_dimension_mappings.platform_tag_catalog_id
      AND catalog.status = 'active'
  );
`,
    `
INSERT INTO pls_tag_value_dimension_mappings (
  id,
  platform_tag_catalog_id,
  platform,
  tag_type,
  leaf_label,
  label_path,
  dimension_id,
  inherited_tag_type_mapping_id,
  mapping_status,
  mapping_method,
  confidence,
  rationale,
  source_ref,
  status,
  created_at,
  updated_at
)
SELECT
  tmp_ids.mapping_id,
  catalog.id,
  catalog.platform,
  catalog.tag_type,
  catalog.leaf_label,
  catalog.label_path,
  type_mapping.dimension_id,
  type_mapping.id,
  'approved',
  'inherited_tag_type',
  MIN(1, type_mapping.confidence),
  '继承已批准的标签类型级映射：' || catalog.platform || ' / ' || catalog.tag_type || ' -> ' || type_mapping.dimension_id || '。',
  'platform_tag_catalog:' || catalog.id,
  'active',
  ${sqlValue(now)},
  ${sqlValue(now)}
FROM platform_tag_catalog catalog
JOIN tmp_pls_tag_value_mapping_ids tmp_ids
  ON tmp_ids.platform_tag_catalog_id = catalog.id
JOIN pls_tag_type_dimension_mappings type_mapping
  ON type_mapping.platform = catalog.platform
  AND type_mapping.tag_type = catalog.tag_type
WHERE catalog.platform IN (${targetPlatforms.map(sqlValue).join(", ")})
  AND catalog.status = 'active'
  AND type_mapping.status = 'active'
  AND type_mapping.mapping_status = 'approved'
  AND type_mapping.dimension_id IS NOT NULL
ON CONFLICT(platform_tag_catalog_id) DO UPDATE SET
  platform = excluded.platform,
  tag_type = excluded.tag_type,
  leaf_label = excluded.leaf_label,
  label_path = excluded.label_path,
  dimension_id = excluded.dimension_id,
  inherited_tag_type_mapping_id = excluded.inherited_tag_type_mapping_id,
  mapping_status = excluded.mapping_status,
  mapping_method = excluded.mapping_method,
  confidence = excluded.confidence,
  rationale = excluded.rationale,
  source_ref = excluded.source_ref,
  status = excluded.status,
  updated_at = excluded.updated_at;
`,
    "DROP TABLE tmp_pls_tag_value_mapping_ids;",
    "COMMIT;",
  ];
  await runSql(statements.join("\n"));
  console.log(`Imported ${idRows.length} PLS tag value dimension mappings.`);
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

function makeId(platformTagCatalogId) {
  const digest = createHash("sha1")
    .update(platformTagCatalogId)
    .digest("hex")
    .slice(0, 16);
  return `pvalmap_${digest}`;
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
