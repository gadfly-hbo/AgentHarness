let schema = null;
let activeTableName = null;
let readme = "";
let activeMode = "table";

const profileMetricTemplateHeaders = [
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

const profileMetricTemplateSample = {
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

const lineageSections = [
  {
    title: "平台标签到主体 PLS 特征",
    summary:
      "用于把天猫、抖音、京东等平台原始标签统一映射到 PLS 三层九维，并形成主体级特征。",
    columns: [
      {
        title: "基础字典",
        nodes: [
          node("platform_tag_catalog", "table", "平台原始标签目录"),
          node("pls_semantic_dimensions", "table", "PLS 三层九维标准维度"),
        ],
      },
      {
        title: "映射治理",
        nodes: [
          node("pls_platform_tag_mappings", "table", "平台级映射规划"),
          node("pls_tag_type_dimension_mappings", "table", "标签类型到 PLS 维度"),
          node("pls_tag_value_dimension_mappings", "table", "标签值到 PLS 维度"),
        ],
      },
      {
        title: "语义读取",
        nodes: [
          node("v_pls_platform_tag_value_semantics", "view", "平台标签值语义展开"),
        ],
      },
      {
        title: "主体事实",
        nodes: [
          node("profile_tag_observations", "table", "主体标签命中事实"),
          node("v_profile_tag_observation_semantics", "view", "主体标签语义展开"),
        ],
      },
      {
        title: "模型特征",
        nodes: [
          node("v_subject_pls_dimension_features", "view", "主体维度行式特征"),
          node("v_subject_pls_feature_matrix", "view", "主体九维宽表"),
        ],
      },
    ],
    edges: [
      ["platform_tag_catalog", "pls_tag_type_dimension_mappings"],
      ["pls_semantic_dimensions", "pls_tag_type_dimension_mappings"],
      ["platform_tag_catalog", "pls_tag_value_dimension_mappings"],
      ["pls_tag_type_dimension_mappings", "pls_tag_value_dimension_mappings"],
      ["pls_semantic_dimensions", "pls_tag_value_dimension_mappings"],
      ["pls_tag_value_dimension_mappings", "v_pls_platform_tag_value_semantics"],
      ["platform_tag_catalog", "v_pls_platform_tag_value_semantics"],
      ["v_pls_platform_tag_value_semantics", "profile_tag_observations"],
      ["profile_tag_observations", "v_profile_tag_observation_semantics"],
      ["v_pls_platform_tag_value_semantics", "v_profile_tag_observation_semantics"],
      ["v_profile_tag_observation_semantics", "v_subject_pls_dimension_features"],
      ["v_subject_pls_dimension_features", "v_subject_pls_feature_matrix"],
    ],
  },
  {
    title: "PLS 渠道画像到渠道特征矩阵",
    summary:
      "用于承接 PLS 渠道画像对象、关系、人群画像、商品适配画像，并形成渠道对象级 PLS 特征。",
    columns: [
      {
        title: "渠道对象库",
        nodes: [
          node("pls_channel_objects", "table", "渠道对象主数据"),
          node("pls_channel_object_bindings", "table", "渠道对象关系"),
        ],
      },
      {
        title: "画像与适配",
        nodes: [
          node("pls_audience_profiles", "table", "渠道人群画像"),
          node("pls_product_fit_profiles", "table", "渠道商品适配画像"),
          node("v_pls_audience_profile_snapshots", "view", "人群画像快照 metadata"),
          node("v_pls_channel_profile_overview", "view", "渠道画像综合概览"),
        ],
      },
      {
        title: "标签映射",
        nodes: [
          node("pls_audience_tag_dimension_mappings", "table", "人群标签到 PLS 维度"),
          node("v_pls_audience_tag_semantics", "view", "人群标签语义展开"),
        ],
      },
      {
        title: "渠道特征",
        nodes: [
          node("v_pls_channel_dimension_features", "view", "渠道维度行式特征"),
          node("v_pls_channel_feature_matrix", "view", "渠道九维宽表"),
        ],
      },
    ],
    edges: [
      ["pls_channel_objects", "pls_channel_object_bindings"],
      ["pls_channel_objects", "pls_audience_profiles"],
      ["pls_channel_objects", "pls_product_fit_profiles"],
      ["pls_channel_objects", "v_pls_audience_profile_snapshots"],
      ["pls_audience_profiles", "v_pls_audience_profile_snapshots"],
      ["pls_channel_objects", "v_pls_channel_profile_overview"],
      ["pls_audience_profiles", "v_pls_channel_profile_overview"],
      ["pls_product_fit_profiles", "v_pls_channel_profile_overview"],
      ["pls_audience_profiles", "v_pls_audience_tag_semantics"],
      ["pls_audience_tag_dimension_mappings", "v_pls_audience_tag_semantics"],
      ["pls_semantic_dimensions", "v_pls_audience_tag_semantics"],
      ["v_pls_audience_tag_semantics", "v_pls_channel_dimension_features"],
      ["v_pls_channel_dimension_features", "v_pls_channel_feature_matrix"],
    ],
  },
  {
    title: "真实平台画像指标到渠道特征矩阵",
    summary:
      "用于承接天猫、抖音、京东真实导出的人群画像指标，并按 PLS 维度形成渠道对象特征。",
    columns: [
      {
        title: "真实导入",
        nodes: [
          node("真实画像导入页", "frontend", "CSV 模板下载、预检与写库"),
          node("POST /api/platform-profile-import", "frontend", "本地导入 API"),
          node("import_platform_profile_tag_metrics.mjs", "frontend", "命令行导入器"),
          node("platform_profile_tag_metrics", "table", "真实画像标签指标"),
          node("platform_tag_catalog", "table", "平台原始标签目录"),
        ],
      },
      {
        title: "语义展开",
        nodes: [
          node("v_pls_platform_tag_value_semantics", "view", "平台标签值语义展开"),
          node("v_platform_profile_tag_metric_semantics", "view", "真实画像指标语义展开"),
        ],
      },
      {
        title: "维度聚合",
        nodes: [
          node(
            "v_platform_profile_channel_dimension_features",
            "view",
            "真实渠道维度行式特征",
          ),
        ],
      },
      {
        title: "模型特征",
        nodes: [
          node("v_platform_profile_channel_feature_matrix", "view", "真实渠道九维宽表"),
        ],
      },
    ],
    edges: [
      ["真实画像导入页", "POST /api/platform-profile-import"],
      ["POST /api/platform-profile-import", "platform_profile_tag_metrics"],
      ["import_platform_profile_tag_metrics.mjs", "platform_profile_tag_metrics"],
      ["platform_tag_catalog", "platform_profile_tag_metrics"],
      ["platform_tag_catalog", "v_pls_platform_tag_value_semantics"],
      ["v_pls_platform_tag_value_semantics", "v_platform_profile_tag_metric_semantics"],
      ["platform_profile_tag_metrics", "v_platform_profile_tag_metric_semantics"],
      [
        "v_platform_profile_tag_metric_semantics",
        "v_platform_profile_channel_dimension_features",
      ],
      [
        "v_platform_profile_channel_dimension_features",
        "v_platform_profile_channel_feature_matrix",
      ],
    ],
  },
  {
    title: "元数据说明层",
    summary:
      "用于给 HTML console 提供中文字段名、业务含义、示例和技术说明，不参与业务数据计算。",
    columns: [
      {
        title: "字段注释",
        nodes: [
          node("database_field_comments", "table", "字段中文注释元数据"),
        ],
      },
      {
        title: "展示位置",
        nodes: [
          node("HTML Fields 面板", "frontend", "前端字段说明展示"),
          node("HTML Explicit Understanding", "frontend", "前端表级业务说明"),
        ],
      },
    ],
    edges: [
      ["database_field_comments", "HTML Fields 面板"],
      ["DataBase/console/server.mjs", "HTML Explicit Understanding"],
    ],
  },
];

const elements = {
  tableCount: document.querySelector("#table-count"),
  generatedAt: document.querySelector("#generated-at"),
  readmeButton: document.querySelector("#readme-button"),
  lineageButton: document.querySelector("#lineage-button"),
  importButton: document.querySelector("#import-button"),
  tableList: document.querySelector("#table-list"),
  activeTableName: document.querySelector("#active-table-name"),
  status: document.querySelector("#status"),
  readmePanel: document.querySelector("#readme-panel"),
  readmeContent: document.querySelector("#readme-content"),
  lineagePanel: document.querySelector("#lineage-panel"),
  lineageContent: document.querySelector("#lineage-content"),
  importPanel: document.querySelector("#import-panel"),
  downloadTemplateButton: document.querySelector("#download-template-button"),
  importFile: document.querySelector("#import-file"),
  importFolder: document.querySelector("#import-folder"),
  previewImportButton: document.querySelector("#preview-import-button"),
  applyImportButton: document.querySelector("#apply-import-button"),
  importResult: document.querySelector("#import-result"),
  summaryGrid: document.querySelector("#summary-grid"),
  understandingPanel: document.querySelector("#understanding-panel"),
  fieldsPanel: document.querySelector("#fields-panel"),
  rowsPanel: document.querySelector("#rows-panel"),
  sqlPanel: document.querySelector("#sql-panel"),
  rowCount: document.querySelector("#row-count"),
  fieldCount: document.querySelector("#field-count"),
  indexCount: document.querySelector("#index-count"),
  tablePurpose: document.querySelector("#table-purpose"),
  productUse: document.querySelector("#product-use"),
  nextLinks: document.querySelector("#next-links"),
  fieldsBody: document.querySelector("#fields-body"),
  rowsWrap: document.querySelector("#rows-wrap"),
  createSql: document.querySelector("#create-sql"),
  refreshButton: document.querySelector("#refresh-button"),
};

elements.refreshButton.addEventListener("click", () => loadSchema());
elements.readmeButton.addEventListener("click", () => {
  activeMode = "readme";
  render();
});
elements.lineageButton.addEventListener("click", () => {
  activeMode = "lineage";
  render();
});
elements.importButton.addEventListener("click", () => {
  activeMode = "import";
  render();
});
elements.downloadTemplateButton.addEventListener("click", () => downloadProfileMetricTemplate());
elements.previewImportButton.addEventListener("click", () => runPlatformProfileImport(false));
elements.applyImportButton.addEventListener("click", () => runPlatformProfileImport(true));

loadSchema();

async function loadSchema() {
  setStatus("Reading DataBase/agentharness.sqlite");

  try {
    const [schemaResponse, readmeResponse] = await Promise.all([
      fetch("/api/schema"),
      fetch("/api/readme"),
    ]);
    if (!schemaResponse.ok) {
      throw new Error(`Schema API failed with ${schemaResponse.status}`);
    }
    if (!readmeResponse.ok) {
      throw new Error(`README API failed with ${readmeResponse.status}`);
    }

    schema = await schemaResponse.json();
    const readmePayload = await readmeResponse.json();
    readme = readmePayload.markdown || "";
    activeTableName = schema.tables[0]?.name || null;
    render();
    setStatus(`Loaded from ${schema.databasePath}`);
  } catch (error) {
    setStatus(error.message, true);
  }
}

function render() {
  elements.tableCount.textContent = `${schema.tables.length} object${schema.tables.length === 1 ? "" : "s"}`;
  elements.generatedAt.textContent = `Generated ${formatDate(schema.generatedAt)}`;
  renderTableList();
  if (activeMode === "readme") {
    renderReadme();
  } else if (activeMode === "lineage") {
    renderLineage();
  } else if (activeMode === "import") {
    renderImport();
  } else {
    renderActiveTable();
  }
}

function renderTableList() {
  elements.tableList.replaceChildren();
  elements.readmeButton.classList.toggle("active", activeMode === "readme");
  elements.lineageButton.classList.toggle("active", activeMode === "lineage");
  elements.importButton.classList.toggle("active", activeMode === "import");

  for (const table of schema.tables) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = `table-button${activeMode === "table" && table.name === activeTableName ? " active" : ""}`;
    button.textContent = table.type === "view" ? `${table.name} (view)` : table.name;
    button.addEventListener("click", () => {
      activeMode = "table";
      activeTableName = table.name;
      render();
    });
    elements.tableList.append(button);
  }
}

function renderReadme() {
  elements.activeTableName.textContent = "PLS 数据库能力接入说明";
  showSpecialView("readme");
  elements.rowCount.textContent = "-";
  elements.fieldCount.textContent = "-";
  elements.indexCount.textContent = "-";
  elements.readmeContent.replaceChildren(renderMarkdown(readme));
}

function renderLineage() {
  elements.activeTableName.textContent = "上下游血缘关系图";
  showSpecialView("lineage");
  elements.rowCount.textContent = "-";
  elements.fieldCount.textContent = "-";
  elements.indexCount.textContent = "-";
  elements.lineageContent.replaceChildren(renderLineageContent());
}

function renderImport() {
  elements.activeTableName.textContent = "真实平台画像 CSV 导入";
  showSpecialView("import");
  elements.rowCount.textContent = "-";
  elements.fieldCount.textContent = "-";
  elements.indexCount.textContent = "-";
  if (!elements.importResult.hasChildNodes()) {
    renderImportEmptyState();
  }
}

function renderActiveTable() {
  const table = schema.tables.find((item) => item.name === activeTableName);
  if (!table) {
    elements.activeTableName.textContent = "No tables";
    return;
  }

  showSpecialView("table");
  elements.activeTableName.textContent = table.name;
  elements.rowCount.textContent = table.rowCount;
  elements.fieldCount.textContent = table.columns.length;
  elements.indexCount.textContent = table.indexes.length;
  elements.tablePurpose.textContent = table.purpose;
  elements.productUse.textContent = table.productUse;
  elements.nextLinks.textContent = table.nextLinks;
  elements.createSql.textContent = table.createSql || "";

  renderFields(table);
  renderRows(table);
}

function showSpecialView(mode) {
  const isReadme = mode === "readme";
  const isLineage = mode === "lineage";
  const isImport = mode === "import";
  elements.readmePanel.hidden = !isReadme;
  elements.lineagePanel.hidden = !isLineage;
  elements.importPanel.hidden = !isImport;
  elements.summaryGrid.hidden = isReadme || isLineage || isImport;
  elements.understandingPanel.hidden = isReadme || isLineage || isImport;
  elements.fieldsPanel.hidden = isReadme || isLineage || isImport;
  elements.rowsPanel.hidden = isReadme || isLineage || isImport;
  elements.sqlPanel.hidden = isReadme || isLineage || isImport;
}

async function runPlatformProfileImport(apply) {
  const selectedFiles = [
    ...Array.from(elements.importFile.files || []),
    ...Array.from(elements.importFolder.files || []),
  ]
    .filter((file) => file.name.toLowerCase().endsWith(".csv"));
  if (selectedFiles.length === 0) {
    setStatus("请选择 CSV 文件。", true);
    return;
  }

  setImportButtonsDisabled(true);
  setStatus(
    apply
      ? `Importing ${selectedFiles.length} platform profile CSV file(s)`
      : `Previewing ${selectedFiles.length} platform profile CSV file(s)`,
  );

  try {
    const files = await Promise.all(
      selectedFiles.map(async (file) => ({
        fileName: file.webkitRelativePath || file.name,
        csvText: await file.text(),
      })),
    );
    const response = await fetch("/api/platform-profile-import", {
      method: "POST",
      headers: {
        "content-type": "application/json",
      },
      body: JSON.stringify({
        files,
        apply,
      }),
    });
    const result = await response.json();
    renderImportResult(result);
    if (!response.ok) {
      setStatus(result.error || "CSV 预检未通过，请查看导入结果。", true);
      return;
    }
    setStatus(apply ? "导入完成，正在刷新数据库结构" : "预检完成，未写入数据库");
    if (apply) {
      await loadSchema();
      activeMode = "import";
      render();
    }
  } catch (error) {
    setStatus(error.message, true);
  } finally {
    setImportButtonsDisabled(false);
  }
}

function setImportButtonsDisabled(disabled) {
  elements.previewImportButton.disabled = disabled;
  elements.applyImportButton.disabled = disabled;
}

function downloadProfileMetricTemplate() {
  const csv = [
    profileMetricTemplateHeaders.join(","),
    profileMetricTemplateHeaders
      .map((header) => csvCell(profileMetricTemplateSample[header] || ""))
      .join(","),
  ].join("\n");
  const blob = new Blob([`\uFEFF${csv}`], { type: "text/csv;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = "platform_profile_tag_metrics_template.csv";
  document.body.append(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
}

function csvCell(value) {
  const text = String(value ?? "");
  if (/[",\n\r]/.test(text)) {
    return `"${text.replaceAll('"', '""')}"`;
  }
  return text;
}

function renderImportEmptyState() {
  elements.importResult.replaceChildren();
  const empty = document.createElement("div");
  empty.className = "empty";
  empty.textContent = "选择按模板整理好的 CSV 后，先点“预检 CSV”，确认无错误再导入数据库。";
  elements.importResult.append(empty);
}

function renderImportResult(result) {
  elements.importResult.replaceChildren();
  if (result.error) {
    const error = document.createElement("div");
    error.className = "import-error";
    error.textContent = result.error;
    elements.importResult.append(error);
    return;
  }

  const summary = result.summary || {};
  const summaryGrid = document.createElement("div");
  summaryGrid.className = "import-summary";
  summaryGrid.append(
    importSummaryCard("模式", result.applied ? "已写库" : "预检"),
    importSummaryCard("文件数", summary.fileCount ?? 0),
    importSummaryCard("有效行", summary.validRows ?? 0),
    importSummaryCard("归一化行", summary.normalizedRows ?? 0),
    importSummaryCard("错误", summary.errorCount ?? 0),
    importSummaryCard("警告", summary.warningCount ?? 0),
    importSummaryCard("平台数", summary.platformCount ?? 0),
    importSummaryCard("对象数", summary.objectCount ?? 0),
    importSummaryCard("指标口径", summary.metricKindCount ?? 0),
    importSummaryCard("批次数", summary.batchCount ?? 0),
  );
  elements.importResult.append(summaryGrid);

  if (result.errors?.length > 0) {
    elements.importResult.append(importMessageList("错误明细", result.errors, "import-error"));
  }
  if (result.warnings?.length > 0) {
    elements.importResult.append(importMessageList("警告明细", result.warnings, "import-warning"));
  }
  if (result.rows?.length > 0) {
    elements.importResult.append(importPreviewTable(result.rows));
  }
  if (result.normalization?.length > 0) {
    elements.importResult.append(importNormalizationTable(result.normalization));
  }
}

function importSummaryCard(label, value) {
  const card = document.createElement("article");
  const span = document.createElement("span");
  span.textContent = label;
  const strong = document.createElement("strong");
  strong.textContent = value;
  card.append(span, strong);
  return card;
}

function importMessageList(title, messages, className) {
  const section = document.createElement("section");
  section.className = `import-messages ${className}`;
  const heading = document.createElement("h4");
  heading.textContent = title;
  const list = document.createElement("ol");
  for (const item of messages.slice(0, 100)) {
    const li = document.createElement("li");
    const file = item.sourceFile ? `${item.sourceFile} ` : "";
    li.textContent = `${file}第 ${item.sourceRow || "-"} 行：${item.message}`;
    list.append(li);
  }
  section.append(heading, list);
  return section;
}

function importPreviewTable(rows) {
  const wrapper = document.createElement("div");
  wrapper.className = "table-wrap import-preview";
  const title = document.createElement("h4");
  title.textContent = "解析预览";
  const table = document.createElement("table");
  const columns = Object.keys(rows[0]);
  const thead = document.createElement("thead");
  const headRow = document.createElement("tr");
  for (const column of columns) {
    const th = document.createElement("th");
    th.textContent = column;
    headRow.append(th);
  }
  thead.append(headRow);
  const tbody = document.createElement("tbody");
  for (const row of rows) {
    const tr = document.createElement("tr");
    for (const column of columns) {
      tr.append(textCell(formatValue(row[column])));
    }
    tbody.append(tr);
  }
  table.append(thead, tbody);
  wrapper.append(title, table);
  return wrapper;
}

function importNormalizationTable(rows) {
  const wrapper = document.createElement("div");
  wrapper.className = "table-wrap import-preview";
  const title = document.createElement("h4");
  title.textContent = "占比归一化摘要";
  const table = document.createElement("table");
  const columns = Object.keys(rows[0]);
  const thead = document.createElement("thead");
  const headRow = document.createElement("tr");
  for (const column of columns) {
    const th = document.createElement("th");
    th.textContent = column;
    headRow.append(th);
  }
  thead.append(headRow);
  const tbody = document.createElement("tbody");
  for (const row of rows) {
    const tr = document.createElement("tr");
    for (const column of columns) {
      tr.append(textCell(formatValue(row[column])));
    }
    tbody.append(tr);
  }
  table.append(thead, tbody);
  wrapper.append(title, table);
  return wrapper;
}

function renderLineageContent() {
  const fragment = document.createDocumentFragment();
  const legend = document.createElement("div");
  legend.className = "lineage-legend";
  legend.append(
    lineageBadge("table", "Table"),
    lineageBadge("view", "View"),
    lineageBadge("frontend", "HTML"),
  );
  fragment.append(legend);

  for (const section of lineageSections) {
    const article = document.createElement("article");
    article.className = "lineage-section";
    const heading = document.createElement("div");
    heading.className = "lineage-section-heading";
    const title = document.createElement("h4");
    title.textContent = section.title;
    const summary = document.createElement("p");
    summary.textContent = section.summary;
    heading.append(title, summary);

    const grid = document.createElement("div");
    grid.className = "lineage-grid";
    for (const column of section.columns) {
      const columnNode = document.createElement("section");
      columnNode.className = "lineage-column";
      const columnTitle = document.createElement("h5");
      columnTitle.textContent = column.title;
      columnNode.append(columnTitle);
      for (const item of column.nodes) {
        columnNode.append(lineageNode(item));
      }
      grid.append(columnNode);
    }

    article.append(heading, grid, lineageEdges(section.edges));
    fragment.append(article);
  }

  return fragment;
}

function node(name, type, description) {
  return { name, type, description };
}

function lineageNode(item) {
  const wrapper = document.createElement("div");
  wrapper.className = `lineage-node ${item.type}`;
  const top = document.createElement("div");
  top.className = "lineage-node-top";
  const name = document.createElement("code");
  name.textContent = item.name;
  const type = document.createElement("span");
  type.textContent = item.type;
  top.append(name, type);
  const description = document.createElement("p");
  description.textContent = item.description;
  wrapper.append(top, description);
  return wrapper;
}

function lineageEdges(edges) {
  const details = document.createElement("details");
  details.className = "lineage-edges";
  const summary = document.createElement("summary");
  summary.textContent = "查看依赖边";
  const list = document.createElement("ol");
  for (const [from, to] of edges) {
    const item = document.createElement("li");
    const fromCode = document.createElement("code");
    fromCode.textContent = from;
    const arrow = document.createElement("span");
    arrow.textContent = " -> ";
    const toCode = document.createElement("code");
    toCode.textContent = to;
    item.append(fromCode, arrow, toCode);
    list.append(item);
  }
  details.append(summary, list);
  return details;
}

function lineageBadge(type, label) {
  const badge = document.createElement("span");
  badge.className = `lineage-badge ${type}`;
  badge.textContent = label;
  return badge;
}

function renderFields(table) {
  elements.fieldsBody.replaceChildren();

  for (const column of table.columns) {
    const row = document.createElement("tr");
    row.append(
      cellWithCode(column.name),
      textCell(column.zhName),
      textCell(column.businessMeaning || column.zhDescription),
      textCell(column.exampleValue),
      textCell(column.type),
      textCell(column.notNull ? "Yes" : "No"),
      textCell(column.primaryKey ? "Primary" : ""),
      cellWithCode(column.defaultValue || ""),
      textCell(column.note),
    );
    elements.fieldsBody.append(row);
  }
}

function renderRows(table) {
  elements.rowsWrap.replaceChildren();

  if (table.sampleRows.length === 0) {
    const empty = document.createElement("div");
    empty.className = "empty";
    empty.textContent = "No rows yet.";
    elements.rowsWrap.append(empty);
    return;
  }

  const sampleColumns = Object.keys(table.sampleRows[0]);
  const sampleTable = document.createElement("table");
  const thead = document.createElement("thead");
  const headRow = document.createElement("tr");
  for (const column of sampleColumns) {
    const th = document.createElement("th");
    th.textContent = column;
    headRow.append(th);
  }
  thead.append(headRow);

  const tbody = document.createElement("tbody");
  for (const sampleRow of table.sampleRows) {
    const tr = document.createElement("tr");
    for (const column of sampleColumns) {
      tr.append(textCell(formatValue(sampleRow[column])));
    }
    tbody.append(tr);
  }

  sampleTable.append(thead, tbody);
  elements.rowsWrap.append(sampleTable);
}

function setStatus(message, isError = false) {
  elements.status.textContent = message;
  elements.status.classList.toggle("error", isError);
}

function textCell(value) {
  const td = document.createElement("td");
  td.textContent = value;
  return td;
}

function cellWithCode(value) {
  const td = document.createElement("td");
  const code = document.createElement("code");
  code.textContent = value;
  td.append(code);
  return td;
}

function formatValue(value) {
  if (value === null || value === undefined) {
    return "";
  }

  if (typeof value === "object") {
    return JSON.stringify(value);
  }

  return String(value);
}

function formatDate(value) {
  if (!value) {
    return "-";
  }

  return new Date(value).toLocaleString();
}

function renderMarkdown(markdown) {
  const fragment = document.createDocumentFragment();
  const lines = markdown.split("\n");
  let index = 0;

  while (index < lines.length) {
    const line = lines[index];

    if (line.trim() === "") {
      index += 1;
      continue;
    }

    if (line.startsWith("```")) {
      const language = line.slice(3).trim();
      const codeLines = [];
      index += 1;
      while (index < lines.length && !lines[index].startsWith("```")) {
        codeLines.push(lines[index]);
        index += 1;
      }
      index += 1;
      const pre = document.createElement("pre");
      const code = document.createElement("code");
      if (language) {
        code.dataset.language = language;
      }
      code.textContent = codeLines.join("\n");
      pre.append(code);
      fragment.append(pre);
      continue;
    }

    if (line.startsWith("|")) {
      const tableLines = [];
      while (index < lines.length && lines[index].startsWith("|")) {
        tableLines.push(lines[index]);
        index += 1;
      }
      fragment.append(renderMarkdownTable(tableLines));
      continue;
    }

    if (line.startsWith("# ")) {
      fragment.append(heading(1, line.slice(2)));
      index += 1;
      continue;
    }

    if (line.startsWith("## ")) {
      fragment.append(heading(2, line.slice(3)));
      index += 1;
      continue;
    }

    if (line.startsWith("### ")) {
      fragment.append(heading(3, line.slice(4)));
      index += 1;
      continue;
    }

    if (line.startsWith("- ")) {
      const ul = document.createElement("ul");
      while (index < lines.length && lines[index].startsWith("- ")) {
        const li = document.createElement("li");
        appendInlineMarkdown(li, lines[index].slice(2));
        ul.append(li);
        index += 1;
      }
      fragment.append(ul);
      continue;
    }

    const paragraphLines = [];
    while (
      index < lines.length &&
      lines[index].trim() !== "" &&
      !lines[index].startsWith("#") &&
      !lines[index].startsWith("```") &&
      !lines[index].startsWith("|") &&
      !lines[index].startsWith("- ")
    ) {
      paragraphLines.push(lines[index]);
      index += 1;
    }
    const p = document.createElement("p");
    appendInlineMarkdown(p, paragraphLines.join(" "));
    fragment.append(p);
  }

  return fragment;
}

function renderMarkdownTable(lines) {
  const wrapper = document.createElement("div");
  wrapper.className = "table-wrap";
  const table = document.createElement("table");
  const headerCells = parseMarkdownRow(lines[0]);
  const bodyLines = lines.slice(2);
  const thead = document.createElement("thead");
  const headRow = document.createElement("tr");
  for (const cell of headerCells) {
    const th = document.createElement("th");
    appendInlineMarkdown(th, cell);
    headRow.append(th);
  }
  thead.append(headRow);
  const tbody = document.createElement("tbody");
  for (const rowLine of bodyLines) {
    const row = document.createElement("tr");
    for (const cell of parseMarkdownRow(rowLine)) {
      const td = document.createElement("td");
      appendInlineMarkdown(td, cell);
      row.append(td);
    }
    tbody.append(row);
  }
  table.append(thead, tbody);
  wrapper.append(table);
  return wrapper;
}

function parseMarkdownRow(line) {
  return line
    .trim()
    .replace(/^\|/, "")
    .replace(/\|$/, "")
    .split("|")
    .map((cell) => cell.trim());
}

function heading(level, text) {
  const node = document.createElement(`h${level}`);
  appendInlineMarkdown(node, text);
  return node;
}

function appendInlineMarkdown(parent, text) {
  const parts = text.split(/(`[^`]+`)/g);
  for (const part of parts) {
    if (part.startsWith("`") && part.endsWith("`")) {
      const code = document.createElement("code");
      code.textContent = part.slice(1, -1);
      parent.append(code);
    } else {
      parent.append(document.createTextNode(part));
    }
  }
}
