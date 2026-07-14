import { execFile, spawn } from "node:child_process";
import { createHash } from "node:crypto";
import path from "node:path";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

export const profileMetricTemplateHeaders = [
  "workspace_id",
  "profile_id",
  "canonical_object_key",
  "channel_object_type",
  "channel_object_name",
  "platform",
  "tag_type",
  "leaf_label",
  "platform_tag_catalog_id",
  "metric_name",
  "metric_value",
  "metric_unit",
  "metric_display_value",
  "profile_time_window",
  "sample_size",
  "source_file",
  "source_row",
  "source_batch_id",
  "raw_json",
];

const requiredFields = [
  "workspace_id",
  "profile_id",
  "canonical_object_key",
  "channel_object_type",
  "channel_object_name",
  "platform",
  "tag_type",
  "leaf_label",
  "metric_name",
  "metric_value",
  "metric_unit",
  "profile_time_window",
  "source_file",
  "source_row",
  "source_batch_id",
];

const allowedObjectTypes = new Set([
  "platform",
  "trade_area",
  "store",
  "account",
  "marketing_event",
  "business_scenario",
]);

export function buildProfileMetricTemplateCsv() {
  const sample = {
    workspace_id: "pls_default",
    profile_id: "profile_douyin_101326115008_2026q2",
    canonical_object_key: "account:douyin:101326115008",
    channel_object_type: "account",
    channel_object_name: "抖音账号 101326115008",
    platform: "抖音",
    tag_type: "性别",
    leaf_label: "女",
    platform_tag_catalog_id: "",
    metric_name: "share",
    metric_value: "47.28",
    metric_unit: "percent",
    metric_display_value: "47.28%",
    profile_time_window: "2026Q2",
    sample_size: "",
    source_file: "101326115008画像数据.csv",
    source_row: "2",
    source_batch_id: "platform_profile_v0.1_20260714",
    raw_json: "",
  };

  return [
    profileMetricTemplateHeaders.join(","),
    profileMetricTemplateHeaders.map((header) => csvCell(sample[header] || "")).join(","),
  ].join("\n");
}

export async function importPlatformProfileTagMetrics({
  csvText,
  sourceFileName = "uploaded.csv",
  dbPath,
  apply = false,
}) {
  return importPlatformProfileTagMetricFiles({
    files: [{ fileName: sourceFileName, csvText }],
    dbPath,
    apply,
  });
}

export async function importPlatformProfileTagMetricFiles({
  files,
  dbPath,
  apply = false,
}) {
  if (!Array.isArray(files) || files.length === 0) {
    throw new Error("CSV 文件为空。");
  }
  if (!dbPath) {
    throw new Error("缺少 dbPath。");
  }

  const catalogIndex = await readCatalogIndex(dbPath);
  const preparedRows = [];
  const errors = [];
  const warnings = [];

  for (const file of files) {
    const sourceFileName = clean(file.fileName) || "uploaded.csv";
    const csvText = file.csvText;
    if (!csvText || typeof csvText !== "string") {
      errors.push({ sourceFile: sourceFileName, sourceRow: "-", message: "CSV 内容为空。" });
      continue;
    }

    const parsedRows = parseCsv(csvText.replace(/^\uFEFF/, ""));
    if (parsedRows.length < 2) {
      errors.push({
        sourceFile: sourceFileName,
        sourceRow: "-",
        message: "CSV 至少需要表头和一行数据。",
      });
      continue;
    }

    const [header, ...records] = parsedRows;
    const normalizedHeader = header.map((value) => clean(value));
    const headerSet = new Set(normalizedHeader);
    const missingHeaders = requiredFields.filter((field) => !headerSet.has(field));
    if (missingHeaders.length > 0) {
      errors.push({
        sourceFile: sourceFileName,
        sourceRow: 1,
        message: `CSV 缺少必填字段：${missingHeaders.join(", ")}`,
      });
      continue;
    }

    for (const [recordIndex, record] of records.entries()) {
      const sourceRowNumber = recordIndex + 2;
      const row = rowObject(normalizedHeader, record);
      if (Object.values(row).every((value) => !clean(value))) {
        continue;
      }

      const normalized = normalizeMetricRow(row, sourceFileName, sourceRowNumber);
      const rowErrors = validateMetricRow(normalized);
      if (rowErrors.length > 0) {
        errors.push(
          ...rowErrors.map((message) => ({
            sourceFile: sourceFileName,
            sourceRow: sourceRowNumber,
            message,
          })),
        );
        continue;
      }

      const catalogResolution = resolveCatalogId(normalized, catalogIndex);
      if (catalogResolution.error) {
        errors.push({
          sourceFile: sourceFileName,
          sourceRow: sourceRowNumber,
          message: catalogResolution.error,
        });
        continue;
      }
      if (catalogResolution.warning) {
        warnings.push({
          sourceFile: sourceFileName,
          sourceRow: sourceRowNumber,
          message: catalogResolution.warning,
        });
      }

      preparedRows.push({
        ...normalized,
        platform_tag_catalog_id: catalogResolution.platformTagCatalogId,
        id: buildMetricId(normalized, catalogResolution.platformTagCatalogId),
      });
    }
  }

  const normalization = normalizeShareMetrics(preparedRows);
  warnings.push(...normalization.warnings);
  const summary = buildSummary(preparedRows, errors, warnings, apply);
  if (errors.length > 0 || !apply) {
    return {
      applied: false,
      summary,
      rows: previewRows(preparedRows),
      errors,
      warnings,
      normalization: normalization.summary,
    };
  }

  await writeRows(dbPath, preparedRows);

  return {
    applied: true,
    summary: {
      ...summary,
      insertedOrUpdatedRows: preparedRows.length,
    },
    rows: previewRows(preparedRows),
    errors,
    warnings,
    normalization: normalization.summary,
  };
}

function normalizeMetricRow(row, sourceFileName, sourceRowNumber) {
  const metricDisplayValue = clean(row.metric_display_value) || clean(row.metric_value);
  return {
    workspace_id: clean(row.workspace_id),
    profile_id: clean(row.profile_id),
    canonical_object_key: clean(row.canonical_object_key),
    channel_object_type: clean(row.channel_object_type),
    channel_object_name: clean(row.channel_object_name),
    platform: clean(row.platform),
    tag_type: clean(row.tag_type),
    leaf_label: clean(row.leaf_label),
    platform_tag_catalog_id: clean(row.platform_tag_catalog_id),
    metric_name: clean(row.metric_name),
    metric_value: parseNumeric(row.metric_value),
    metric_unit: clean(row.metric_unit),
    metric_display_value: metricDisplayValue,
    profile_time_window: clean(row.profile_time_window),
    sample_size: parseOptionalInteger(row.sample_size),
    source_file: clean(row.source_file) || sourceFileName,
    source_row: parseOptionalInteger(row.source_row) ?? sourceRowNumber,
    source_batch_id: clean(row.source_batch_id),
    raw_json: normalizeRawJson(row),
  };
}

function validateMetricRow(row) {
  const errors = [];
  for (const field of requiredFields) {
    if (field === "metric_value" || field === "source_row") {
      continue;
    }
    if (!clean(row[field])) {
      errors.push(`${field} 不能为空。`);
    }
  }
  if (!allowedObjectTypes.has(row.channel_object_type)) {
    errors.push(`channel_object_type 不合法：${row.channel_object_type}`);
  }
  if (row.metric_value === null || Number.isNaN(row.metric_value)) {
    errors.push(`metric_value 不是可计算数值。`);
  }
  if (!Number.isInteger(row.source_row) || row.source_row <= 0) {
    errors.push(`source_row 必须是正整数。`);
  }
  if (row.sample_size !== null && (!Number.isInteger(row.sample_size) || row.sample_size < 0)) {
    errors.push(`sample_size 必须为空或非负整数。`);
  }
  if (!isJson(row.raw_json)) {
    errors.push(`raw_json 不是合法 JSON。`);
  }
  return errors;
}

function resolveCatalogId(row, catalogIndex) {
  if (row.platform_tag_catalog_id) {
    if (!catalogIndex.byId.has(row.platform_tag_catalog_id)) {
      return {
        error: `platform_tag_catalog_id 不存在：${row.platform_tag_catalog_id}`,
      };
    }
    return {
      platformTagCatalogId: row.platform_tag_catalog_id,
    };
  }

  const key = catalogKey(row.platform, row.tag_type, row.leaf_label);
  const matches = catalogIndex.bySemanticKey.get(key) || [];
  if (matches.length === 0) {
    return {
      error: `未匹配到平台标签目录：${row.platform} / ${row.tag_type} / ${row.leaf_label}`,
    };
  }
  if (matches.length > 1) {
    return {
      error:
        `平台标签目录匹配到 ${matches.length} 条记录，请在 CSV 中补充 platform_tag_catalog_id。候选：` +
        matches.map((item) => item.id).join(", "),
    };
  }
  return {
    platformTagCatalogId: matches[0].id,
  };
}

async function readCatalogIndex(dbPath) {
  const rows = await sqliteJson(
    dbPath,
    `
      SELECT id, platform, tag_type, leaf_label
      FROM platform_tag_catalog
      WHERE status = 'active';
    `,
  );
  const byId = new Map();
  const bySemanticKey = new Map();
  for (const row of rows) {
    byId.set(row.id, row);
    const key = catalogKey(row.platform, row.tag_type, row.leaf_label);
    const matches = bySemanticKey.get(key) || [];
    matches.push(row);
    bySemanticKey.set(key, matches);
  }
  return { byId, bySemanticKey };
}

async function writeRows(dbPath, rows) {
  const statements = ["PRAGMA foreign_keys = ON;", "BEGIN;"];
  for (const row of rows) {
    statements.push(`
INSERT INTO platform_profile_tag_metrics (
  id,
  workspace_id,
  profile_id,
  canonical_object_key,
  channel_object_type,
  channel_object_name,
  platform,
  platform_tag_catalog_id,
  tag_type,
  leaf_label,
  metric_name,
  metric_value,
  metric_unit,
  metric_display_value,
  profile_time_window,
  sample_size,
  source_file,
  source_row,
  source_batch_id,
  raw_json,
  status,
  updated_at
)
VALUES (
  ${sqlValue(row.id)},
  ${sqlValue(row.workspace_id)},
  ${sqlValue(row.profile_id)},
  ${sqlValue(row.canonical_object_key)},
  ${sqlValue(row.channel_object_type)},
  ${sqlValue(row.channel_object_name)},
  ${sqlValue(row.platform)},
  ${sqlValue(row.platform_tag_catalog_id)},
  ${sqlValue(row.tag_type)},
  ${sqlValue(row.leaf_label)},
  ${sqlValue(row.metric_name)},
  ${sqlValue(row.metric_value)},
  ${sqlValue(row.metric_unit)},
  ${sqlValue(row.metric_display_value)},
  ${sqlValue(row.profile_time_window)},
  ${sqlValue(row.sample_size)},
  ${sqlValue(row.source_file)},
  ${sqlValue(row.source_row)},
  ${sqlValue(row.source_batch_id)},
  ${sqlValue(row.raw_json)},
  'active',
  strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
)
ON CONFLICT (
  workspace_id,
  profile_id,
  canonical_object_key,
  platform_tag_catalog_id,
  metric_name,
  profile_time_window,
  source_batch_id
) DO UPDATE SET
  channel_object_type = excluded.channel_object_type,
  channel_object_name = excluded.channel_object_name,
  platform = excluded.platform,
  tag_type = excluded.tag_type,
  leaf_label = excluded.leaf_label,
  metric_value = excluded.metric_value,
  metric_unit = excluded.metric_unit,
  metric_display_value = excluded.metric_display_value,
  sample_size = excluded.sample_size,
  source_file = excluded.source_file,
  source_row = excluded.source_row,
  raw_json = excluded.raw_json,
  status = excluded.status,
  updated_at = excluded.updated_at;
`);
  }
  statements.push("COMMIT;");
  await sqliteExec(dbPath, statements.join("\n"));
}

function buildSummary(rows, errors, warnings, apply) {
  const platforms = new Set(rows.map((row) => row.platform));
  const objects = new Set(rows.map((row) => row.canonical_object_key));
  const metrics = new Set(rows.map((row) => `${row.metric_name}:${row.metric_unit}`));
  const batches = new Set(rows.map((row) => row.source_batch_id));
  const files = new Set(rows.map((row) => row.source_file));
  const normalizedRows = rows.filter((row) => row.normalization_applied).length;
  return {
    mode: apply ? "import" : "preview",
    validRows: rows.length,
    errorCount: errors.length,
    warningCount: warnings.length,
    fileCount: files.size,
    platformCount: platforms.size,
    objectCount: objects.size,
    metricKindCount: metrics.size,
    batchCount: batches.size,
    normalizedRows,
  };
}

function previewRows(rows) {
  return rows.slice(0, 20).map((row) => ({
    source_file: row.source_file,
    source_row: row.source_row,
    platform: row.platform,
    tag_type: row.tag_type,
    leaf_label: row.leaf_label,
    platform_tag_catalog_id: row.platform_tag_catalog_id,
    metric_name: row.metric_name,
    raw_metric_value: row.raw_metric_value ?? row.metric_value,
    metric_value: row.metric_value,
    metric_unit: row.metric_unit,
    normalization_group_sum: row.normalization_group_sum ?? "",
    canonical_object_key: row.canonical_object_key,
    source_batch_id: row.source_batch_id,
  }));
}

function normalizeShareMetrics(rows) {
  const groups = new Map();
  for (const row of rows) {
    if (!isNormalizableShare(row)) {
      continue;
    }
    const key = [
      row.workspace_id,
      row.profile_id,
      row.canonical_object_key,
      row.platform,
      row.tag_type,
      row.metric_name,
      normalizeMetricUnit(row.metric_unit),
      row.profile_time_window,
      row.source_batch_id,
    ].join("\u001f");
    const groupRows = groups.get(key) || [];
    groupRows.push(row);
    groups.set(key, groupRows);
  }

  const warnings = [];
  const summary = [];
  for (const groupRows of groups.values()) {
    const total = groupRows.reduce((sum, row) => sum + row.metric_value, 0);
    const target = normalizationTarget(groupRows[0].metric_unit);
    if (!Number.isFinite(total) || total <= 0) {
      warnings.push({
        sourceFile: "归一化",
        sourceRow: "-",
        message: `跳过归一化：${groupRows[0].platform} / ${groupRows[0].tag_type} 的占比合计为 ${total}。`,
      });
      continue;
    }

    let normalizedSum = 0;
    for (const [index, row] of groupRows.entries()) {
      const rawMetricValue = row.metric_value;
      const normalizedValue =
        index === groupRows.length - 1
          ? roundMetric(target - normalizedSum)
          : roundMetric((rawMetricValue / total) * target);
      normalizedSum = roundMetric(normalizedSum + normalizedValue);
      row.raw_metric_value = rawMetricValue;
      row.metric_value = normalizedValue;
      row.normalization_applied = true;
      row.normalization_group_sum = roundMetric(total);
      row.normalization_target_sum = target;
      row.raw_json = addNormalizationToRawJson(row.raw_json, {
        raw_metric_value: rawMetricValue,
        normalized_metric_value: normalizedValue,
        normalization_group_sum: roundMetric(total),
        normalization_target_sum: target,
        normalization_scope:
          "workspace_id + profile_id + canonical_object_key + platform + tag_type + metric_name + metric_unit + profile_time_window + source_batch_id",
      });
    }

    summary.push({
      platform: groupRows[0].platform,
      tag_type: groupRows[0].tag_type,
      metric_name: groupRows[0].metric_name,
      metric_unit: groupRows[0].metric_unit,
      row_count: groupRows.length,
      raw_sum: roundMetric(total),
      normalized_sum: target,
    });
  }

  return { warnings, summary };
}

function isNormalizableShare(row) {
  return (
    clean(row.metric_name).toLowerCase() === "share" &&
    ["percent", "percentage", "ratio"].includes(normalizeMetricUnit(row.metric_unit))
  );
}

function normalizeMetricUnit(unit) {
  return clean(unit).toLowerCase();
}

function normalizationTarget(unit) {
  return normalizeMetricUnit(unit) === "ratio" ? 1 : 100;
}

function roundMetric(value) {
  return Math.round(value * 1_000_000) / 1_000_000;
}

function addNormalizationToRawJson(rawJson, normalization) {
  try {
    const parsed = JSON.parse(rawJson);
    parsed.normalization = normalization;
    return JSON.stringify(parsed);
  } catch {
    return JSON.stringify({ raw_json_parse_error: true, normalization });
  }
}

function buildMetricId(row, platformTagCatalogId) {
  const stable = [
    row.workspace_id,
    row.profile_id,
    row.canonical_object_key,
    platformTagCatalogId,
    row.metric_name,
    row.profile_time_window,
    row.source_batch_id,
  ].join("|");
  return `ppm_${createHash("sha1").update(stable).digest("hex").slice(0, 24)}`;
}

function normalizeRawJson(row) {
  const explicitRawJson = clean(row.raw_json);
  if (explicitRawJson) {
    return explicitRawJson;
  }
  return JSON.stringify(row);
}

function rowObject(header, values) {
  const row = {};
  for (const [index, field] of header.entries()) {
    row[field] = values[index] ?? "";
  }
  return row;
}

export function parseCsv(text) {
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

function csvCell(value) {
  const text = String(value ?? "");
  if (/[",\n\r]/.test(text)) {
    return `"${text.replaceAll('"', '""')}"`;
  }
  return text;
}

function parseNumeric(value) {
  const text = clean(value).replaceAll(",", "").replace(/%$/, "");
  if (!text) {
    return null;
  }
  const number = Number(text);
  return Number.isFinite(number) ? number : Number.NaN;
}

function parseOptionalInteger(value) {
  const text = clean(value).replaceAll(",", "");
  if (!text) {
    return null;
  }
  const number = Number(text);
  return Number.isInteger(number) ? number : Number.NaN;
}

function catalogKey(platform, tagType, leafLabel) {
  return [clean(platform), clean(tagType), clean(leafLabel)].join("\u001f");
}

function isJson(value) {
  try {
    JSON.parse(value);
    return true;
  } catch {
    return false;
  }
}

function clean(value) {
  return String(value ?? "").trim();
}

async function sqliteJson(dbPath, sql) {
  const { stdout } = await execFileAsync("sqlite3", ["-json", dbPath, sql], {
    cwd: path.dirname(dbPath),
    maxBuffer: 20 * 1024 * 1024,
  });
  const trimmed = stdout.trim();
  return trimmed ? JSON.parse(trimmed) : [];
}

async function sqliteExec(dbPath, sql) {
  await new Promise((resolve, reject) => {
    const child = spawn("sqlite3", [dbPath], {
      cwd: path.dirname(dbPath),
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

function sqlValue(value) {
  if (value === null || value === undefined || Number.isNaN(value)) {
    return "NULL";
  }
  if (typeof value === "number") {
    return String(value);
  }
  return `'${String(value).replaceAll("'", "''")}'`;
}
