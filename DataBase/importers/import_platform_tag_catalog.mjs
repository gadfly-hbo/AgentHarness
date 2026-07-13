#!/usr/bin/env node

import { createReadStream } from "node:fs";
import { readFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { spawn } from "node:child_process";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const databaseRoot = path.resolve(__dirname, "..");
const repoRoot = path.resolve(databaseRoot, "..");
const dbPath = path.join(databaseRoot, "agentharness.sqlite");
const sourceDir = "/Users/huangbo/Downloads/三大平台标签";

const sources = [
  {
    platform: "天猫",
    fileName: "1. 天猫_标签类型_标签_20260201.csv",
  },
  {
    platform: "抖音",
    fileName: "3. 抖音_标签类型_标签_20260201.csv",
  },
];

async function main() {
  const migrationPath = path.join(
    databaseRoot,
    "migrations",
    "005_create_platform_tag_catalog.sql",
  );
  await runSql(await readFile(migrationPath, "utf8"));

  const statements = ["PRAGMA foreign_keys = ON;", "BEGIN;"];
  let imported = 0;

  for (const source of sources) {
    const filePath = path.join(sourceDir, source.fileName);
    const rows = await readCsv(filePath);
    const [header, ...records] = rows;
    const tagTypeIndex = header.indexOf("标签类型");
    const valueHeaders = header.slice(1);

    if (tagTypeIndex !== 0 || valueHeaders.length === 0) {
      throw new Error(`Unsupported CSV shape: ${source.fileName}`);
    }

    for (const [index, row] of records.entries()) {
      const sourceRow = index + 2;
      const tagType = clean(row[0]);
      if (!tagType) {
        continue;
      }

      const levels = valueHeaders.map((_, levelIndex) => clean(row[levelIndex + 1]));
      const nonEmptyLevels = levels.filter(Boolean);
      const leafLabel = nonEmptyLevels.at(-1);
      if (!leafLabel) {
        continue;
      }

      const id = makeId(source.platform, source.fileName, sourceRow);
      const labelPath = [tagType, ...nonEmptyLevels].join(" > ");
      const values = [
        id,
        source.platform,
        tagType,
        levels[0] || null,
        levels[1] || null,
        levels[2] || null,
        levels[3] || null,
        leafLabel,
        labelPath,
        path.join("三大平台标签", source.fileName),
        sourceRow,
        "active",
        "2026-07-13T00:00:00.000Z",
        "2026-07-13T00:00:00.000Z",
      ];

      statements.push(`
INSERT INTO platform_tag_catalog (
  id,
  platform,
  tag_type,
  level_1,
  level_2,
  level_3,
  level_4,
  leaf_label,
  label_path,
  source_file,
  source_row,
  status,
  created_at,
  updated_at
)
VALUES (${values.map(sqlValue).join(", ")})
ON CONFLICT(platform, source_file, source_row) DO UPDATE SET
  tag_type = excluded.tag_type,
  level_1 = excluded.level_1,
  level_2 = excluded.level_2,
  level_3 = excluded.level_3,
  level_4 = excluded.level_4,
  leaf_label = excluded.leaf_label,
  label_path = excluded.label_path,
  status = excluded.status,
  updated_at = excluded.updated_at;
`);
      imported += 1;
    }
  }

  statements.push("COMMIT;");
  await runSql(statements.join("\n"));
  console.log(`Imported ${imported} platform tag catalog rows.`);
}

async function readCsv(filePath) {
  const text = await readFile(filePath, "utf8");
  return parseCsv(text.replace(/^\uFEFF/, ""));
}

function parseCsv(text) {
  const rows = [];
  let row = [];
  let cell = "";
  let inQuotes = false;

  for (let index = 0; index < text.length; index += 1) {
    const char = text[index];
    const next = text[index + 1];

    if (inQuotes) {
      if (char === '"' && next === '"') {
        cell += '"';
        index += 1;
      } else if (char === '"') {
        inQuotes = false;
      } else {
        cell += char;
      }
      continue;
    }

    if (char === '"') {
      inQuotes = true;
    } else if (char === ",") {
      row.push(cell);
      cell = "";
    } else if (char === "\n") {
      row.push(cell.replace(/\r$/, ""));
      rows.push(row);
      row = [];
      cell = "";
    } else {
      cell += char;
    }
  }

  if (cell.length > 0 || row.length > 0) {
    row.push(cell.replace(/\r$/, ""));
    rows.push(row);
  }

  return rows.filter((items) => items.some((item) => clean(item)));
}

async function runSql(sql) {
  await new Promise((resolve, reject) => {
    const child = spawn("sqlite3", [dbPath], {
      cwd: repoRoot,
      stdio: ["pipe", "pipe", "pipe"],
    });

    let stderr = "";
    child.stderr.on("data", (chunk) => {
      stderr += chunk;
    });
    child.on("error", reject);
    child.on("close", (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(stderr || `sqlite3 exited with ${code}`));
      }
    });
    child.stdin.end(sql);
  });
}

function clean(value) {
  return String(value ?? "").trim();
}

function makeId(platform, fileName, sourceRow) {
  const normalized = `${platform}_${fileName}_${sourceRow}`
    .normalize("NFKD")
    .replace(/[^\p{Letter}\p{Number}]+/gu, "_")
    .replace(/^_+|_+$/g, "")
    .toLowerCase();
  return `ptag_${normalized}`;
}

function sqlValue(value) {
  if (value === null || value === undefined) {
    return "NULL";
  }
  return `'${String(value).replaceAll("'", "''")}'`;
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
