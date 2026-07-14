#!/usr/bin/env node

import { readdir, readFile, stat } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import {
  importPlatformProfileTagMetricFiles,
} from "./platform_profile_tag_metrics_importer.mjs";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const databaseRoot = path.resolve(__dirname, "..");
const dbPath = path.join(databaseRoot, "agentharness.sqlite");

async function main() {
  const args = new Set(process.argv.slice(2));
  const inputPaths = process.argv.slice(2).filter((arg) => !arg.startsWith("--"));
  const apply = args.has("--apply");

  if (inputPaths.length === 0) {
    throw new Error(
      "用法：node DataBase/importers/import_platform_profile_tag_metrics.mjs <csv_path_or_dir> [...more_paths] [--apply]",
    );
  }

  const csvPaths = [];
  for (const inputPath of inputPaths) {
    csvPaths.push(...(await listCsvPaths(inputPath)));
  }
  if (csvPaths.length === 0) {
    throw new Error("没有找到 CSV 文件。");
  }

  const files = await Promise.all(
    csvPaths.map(async (filePath) => ({
      fileName: path.basename(filePath),
      csvText: await readFile(filePath, "utf8"),
    })),
  );

  const result = await importPlatformProfileTagMetricFiles({
    files,
    dbPath,
    apply,
  });

  console.log(JSON.stringify(result, null, 2));
  if (result.errors.length > 0) {
    process.exitCode = 1;
  }
}

async function listCsvPaths(inputPath) {
  const stats = await stat(inputPath);
  if (stats.isDirectory()) {
    const entries = await readdir(inputPath, { withFileTypes: true });
    const nested = await Promise.all(
      entries.map((entry) => listCsvPaths(path.join(inputPath, entry.name))),
    );
    return nested.flat();
  }
  if (stats.isFile() && inputPath.toLowerCase().endsWith(".csv")) {
    return [inputPath];
  }
  return [];
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
