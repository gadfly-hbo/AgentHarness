#!/usr/bin/env node

import { mkdir, readFile, rename, rm, stat, writeFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import http from "node:http";
import path from "node:path";
import { fileURLToPath } from "node:url";
import crypto from "node:crypto";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, "../..");

const paths = {
  dataRuns: path.join(repoRoot, "DataBase", "runs"),
  artifacts: path.join(repoRoot, "DataBase", "artifacts"),
  memoryCandidates: path.join(repoRoot, "MemoryBase", "candidates"),
  memories: path.join(repoRoot, "MemoryBase", "memories"),
};

const files = {
  tasks: path.join(paths.dataRuns, "tasks.jsonl"),
  runs: path.join(paths.dataRuns, "runs.jsonl"),
  events: path.join(paths.dataRuns, "events.jsonl"),
  artifacts: path.join(paths.dataRuns, "artifacts.jsonl"),
  memoryCandidates: path.join(paths.memoryCandidates, "memory-candidates.jsonl"),
  memories: path.join(paths.memories, "memories.jsonl"),
};

// --- Capability Registry enums ---

const ENUMS = {
  lifecycle: ["draft", "evaluable", "released", "deprecated"],
  readiness: ["blocked", "ready", "not_applicable"],
  evaluationStatus: ["not_run", "warning", "passed", "failed"],
  baseState: ["ready", "pending", "blocked", "not_applicable"],
  baseName: ["DataBase", "OntoBase", "KnowledgeBase", "MemoryBase"],
  hostInstallState: ["not_connected", "simulated", "installable", "installed", "blocked"],
  hostUsageState: ["not_connected", "simulated", "usable", "blocked"],
  hostFeedbackState: ["not_connected", "simulated", "receiving", "blocked"],
  hostAdapterState: ["not_connected", "simulated", "connected", "blocked"],
  sourceKind: ["prototype", "reference_pack", "migrated_asset", "released_pack"],
  dataBoundary: ["demo_only", "read_only_reference", "production_ready"],
  ownerDomain: ["database", "ontobase", "knowledgebase", "memorybase"],
};

function validateEnumValue(value, allowedValues) {
  return allowedValues.includes(value);
}

// --- Per-Base Readiness Owner Output Reader ---

const BASE_READINESS_FILES = {
  DataBase: path.join(repoRoot, "DataBase", "readiness", "capability-pack-readiness.json"),
  OntoBase: path.join(repoRoot, "OntoBase", "readiness", "capability-pack-readiness.json"),
  KnowledgeBase: path.join(repoRoot, "KnowledgeBase", "readiness", "capability-pack-readiness.json"),
  MemoryBase: path.join(repoRoot, "MemoryBase", "readiness", "capability-pack-readiness.json"),
};

function validateBaseReadinessFact(fact, index, expectedBase) {
  const errors = [];
  const prefix = `${expectedBase} readiness[${index}]`;

  if (!fact || typeof fact !== "object") {
    return [`${prefix}: must be a non-null object`];
  }

  if (typeof fact.base !== "string" || !fact.base) errors.push(`${prefix}.base must be non-empty string`);
  else if (fact.base !== expectedBase) errors.push(`${prefix}.base "${fact.base}" does not match expected "${expectedBase}"`);

  if (typeof fact.packId !== "string" || !fact.packId) errors.push(`${prefix}.packId must be non-empty string`);
  if (!validateEnumValue(fact.state, ENUMS.baseState)) errors.push(`${prefix}.invalid state: ${fact.state}`);
  if (typeof fact.reason !== "string" || !fact.reason) errors.push(`${prefix}.reason must be non-empty string`);
  if (typeof fact.checkedAt !== "string" || !fact.checkedAt) errors.push(`${prefix}.checkedAt must be non-empty string`);
  if (typeof fact.producer !== "string" || !fact.producer) errors.push(`${prefix}.producer must be non-empty string`);
  else if (fact.producer !== ENUMS.ownerDomain[ENUMS.baseName.indexOf(expectedBase)]) {
    errors.push(`${prefix}.producer "${fact.producer}" does not match expected domain for ${expectedBase}`);
  }

  if (!Array.isArray(fact.evidenceRefs)) {
    errors.push(`${prefix}.evidenceRefs must be array`);
  } else if (fact.evidenceRefs.length === 0) {
    errors.push(`${prefix}.evidenceRefs must not be empty`);
  } else {
    for (let i = 0; i < fact.evidenceRefs.length; i++) {
      const ref = fact.evidenceRefs[i];
      const refPrefix = `${prefix}.evidenceRefs[${i}]`;
      if (!ref || typeof ref !== "object") { errors.push(`${refPrefix}: must be object`); continue; }
      if (typeof ref.label !== "string") errors.push(`${refPrefix}.label must be string`);
      if (typeof ref.path !== "string" || !ref.path) errors.push(`${refPrefix}.path must be non-empty string`);
      else if (ref.path.startsWith("/") || ref.path.startsWith("\\")) errors.push(`${refPrefix}.path must be repo-relative, not absolute: ${ref.path}`);
      else if (/^[a-zA-Z]+:\/\//.test(ref.path)) errors.push(`${refPrefix}.path must be repo-relative, not URL: ${ref.path}`);
      else if (!existsSync(path.join(repoRoot, ref.path))) errors.push(`${refPrefix}.path does not exist: ${ref.path}`);
      if (typeof ref.note !== "string") errors.push(`${refPrefix}.note must be string`);
    }
  }

  return errors;
}

async function readBaseReadinessFacts(packId) {
  if (!packId || typeof packId !== "string") {
    return { error: "missing_argument", reason: "packId is required" };
  }

  const allFacts = [];

  for (const baseName of ENUMS.baseName) {
    const filePath = BASE_READINESS_FILES[baseName];

    let content;
    try {
      content = await readFile(filePath, "utf8");
    } catch {
      return { error: "validation_failed", reason: `Readiness file missing for ${baseName}: ${path.relative(repoRoot, filePath)}` };
    }

    let facts;
    try {
      facts = JSON.parse(content);
    } catch {
      return { error: "validation_failed", reason: `Invalid JSON in ${baseName} readiness file` };
    }

    if (!Array.isArray(facts)) {
      return { error: "validation_failed", reason: `${baseName} readiness file content must be an array` };
    }

    const fileErrors = [];
    const seenKeys = new Set();

    for (let i = 0; i < facts.length; i++) {
      const errs = validateBaseReadinessFact(facts[i], i, baseName);
      fileErrors.push(...errs);

      if (!errs.length && facts[i].base === baseName) {
        const key = `${facts[i].base}:${facts[i].packId}`;
        if (seenKeys.has(key)) {
          fileErrors.push(`${baseName} readiness: duplicate base+packId: ${key}`);
        }
        seenKeys.add(key);
      }
    }

    if (fileErrors.length > 0) {
      return { error: "validation_failed", reason: `${baseName} readiness validation failed`, details: fileErrors };
    }

    for (const fact of facts) {
      if (fact.base === baseName) {
        allFacts.push(fact);
      }
    }
  }

  const targetFacts = allFacts.filter((f) => f.packId === packId);
  if (targetFacts.length < 4) {
    const found = targetFacts.map((f) => f.base);
    const missing = ENUMS.baseName.filter((b) => !found.includes(b));
    return { error: "validation_failed", reason: `Missing readiness facts for packId "${packId}": ${missing.join(", ")}` };
  }

  return targetFacts.map((fact) => ({
    packId: fact.packId,
    base: fact.base,
    state: fact.state,
    reason: fact.reason,
    observedAt: fact.checkedAt,
    evidenceRefs: fact.evidenceRefs,
    ownerDomain: fact.producer,
  }));
}

// Legacy validator kept for backward compatibility with selftest injection tests
function validateReadinessObservation(obs, index) {
  const errors = [];
  const prefix = `readiness_observations[${index}]`;

  if (!obs || typeof obs !== "object") {
    return [`${prefix}: must be a non-null object`];
  }

  if (typeof obs.packId !== "string" || !obs.packId) errors.push(`${prefix}.packId must be non-empty string`);
  if (!validateEnumValue(obs.base, ENUMS.baseName)) errors.push(`${prefix}.invalid base: ${obs.base}`);
  if (!validateEnumValue(obs.state, ENUMS.baseState)) errors.push(`${prefix}.invalid state: ${obs.state}`);
  if (typeof obs.reason !== "string") errors.push(`${prefix}.reason must be string`);
  if (typeof obs.observedAt !== "string" || !obs.observedAt) errors.push(`${prefix}.observedAt must be non-empty string`);
  if (!validateEnumValue(obs.ownerDomain, ENUMS.ownerDomain)) errors.push(`${prefix}.invalid ownerDomain: ${obs.ownerDomain}`);

  if (!Array.isArray(obs.evidenceRefs)) {
    errors.push(`${prefix}.evidenceRefs must be array`);
  } else {
    for (let i = 0; i < obs.evidenceRefs.length; i++) {
      const ref = obs.evidenceRefs[i];
      const refPrefix = `${prefix}.evidenceRefs[${i}]`;
      if (typeof ref.label !== "string") errors.push(`${refPrefix}.label must be string`);
      if (typeof ref.path !== "string" || !ref.path) errors.push(`${refPrefix}.path must be non-empty string`);
      else if (ref.path.startsWith("/") || ref.path.startsWith("\\")) errors.push(`${refPrefix}.path must be repo-relative, not absolute: ${ref.path}`);
      else if (/^[a-zA-Z]+:\/\//.test(ref.path)) errors.push(`${refPrefix}.path must be repo-relative, not URL: ${ref.path}`);
      if (typeof ref.note !== "string") errors.push(`${refPrefix}.note must be string`);
    }
  }

  return errors;
}

async function getCapabilityPackBaseReadiness(packId) {
  if (!packId || typeof packId !== "string") {
    return { error: "missing_argument", reason: "packId is required" };
  }
  const result = await readBaseReadinessFacts(packId);
  if (result.error) return result;

  const allErrors = [];
  for (let i = 0; i < result.length; i++) {
    const errors = validateReadinessObservation(result[i], i);
    allErrors.push(...errors);
  }
  if (allErrors.length > 0) {
    return { error: "validation_failed", reason: "Readiness observations invalid", details: allErrors };
  }
  return result;
}

async function deriveBasesFromReadiness(packId) {
  const result = await getCapabilityPackBaseReadiness(packId);
  if (result.error) return result; // propagate error, do not swallow
  return result.map((obs) => ({
    base: obs.base,
    state: obs.state,
    note: obs.reason,
  }));
}

async function packWithDerivedBases(pack) {
  const bases = await deriveBasesFromReadiness(pack.identity.packId);
  if (bases.error) return bases; // propagate error
  const copy = JSON.parse(JSON.stringify(pack));
  copy.dependencies.bases = bases;
  return copy;
}

function validateCapabilityPackShape(pack) {
  const errors = [];

  if (!pack || typeof pack !== "object") {
    return ["Pack must be a non-null object"];
  }

  // identity
  if (!pack.identity || typeof pack.identity !== "object") errors.push("Missing identity");
  else {
    if (typeof pack.identity.packId !== "string" || !pack.identity.packId) errors.push("Missing identity.packId");
    if (typeof pack.identity.displayName !== "string" || !pack.identity.displayName) errors.push("Missing identity.displayName");
    if (typeof pack.identity.shortName !== "string" || !pack.identity.shortName) errors.push("Missing identity.shortName");
    if (typeof pack.identity.version !== "string" || !pack.identity.version) errors.push("Missing identity.version");
  }

  // status
  if (!pack.status || typeof pack.status !== "object") errors.push("Missing status");
  else {
    if (!validateEnumValue(pack.status.lifecycle, ENUMS.lifecycle)) errors.push(`Invalid status.lifecycle: ${pack.status.lifecycle}`);
    if (!validateEnumValue(pack.status.releaseReadiness, ENUMS.readiness)) errors.push(`Invalid status.releaseReadiness: ${pack.status.releaseReadiness}`);
    if (!validateEnumValue(pack.status.distributionReadiness, ENUMS.readiness)) errors.push(`Invalid status.distributionReadiness: ${pack.status.distributionReadiness}`);
  }

  // summary
  if (!pack.summary || typeof pack.summary !== "object") errors.push("Missing summary");
  else {
    if (typeof pack.summary.description !== "string") errors.push("Missing summary.description");
    if (typeof pack.summary.authority !== "string") errors.push("Missing summary.authority");
    if (typeof pack.summary.consumer !== "string") errors.push("Missing summary.consumer");
  }

  // readiness
  if (!pack.readiness || typeof pack.readiness !== "object") errors.push("Missing readiness");
  else {
    if (!validateEnumValue(pack.readiness.evaluationStatus, ENUMS.evaluationStatus)) errors.push(`Invalid readiness.evaluationStatus: ${pack.readiness.evaluationStatus}`);
    if (typeof pack.readiness.blockingReason !== "string") errors.push("Missing readiness.blockingReason");
    if (typeof pack.readiness.lastCheckedAt !== "string") errors.push("Missing readiness.lastCheckedAt");
  }

  // dependencies
  if (!pack.dependencies || typeof pack.dependencies !== "object") errors.push("Missing dependencies");
  else if (!Array.isArray(pack.dependencies.bases)) errors.push("Missing dependencies.bases");
  else {
    for (let i = 0; i < pack.dependencies.bases.length; i++) {
      const base = pack.dependencies.bases[i];
      if (!validateEnumValue(base.base, ENUMS.baseName)) errors.push(`Invalid dependencies.bases[${i}].base: ${base.base}`);
      if (!validateEnumValue(base.state, ENUMS.baseState)) errors.push(`Invalid dependencies.bases[${i}].state: ${base.state}`);
      if (typeof base.note !== "string") errors.push(`dependencies.bases[${i}].note must be string`);
    }
  }

  // hostConsumer
  if (!pack.hostConsumer || typeof pack.hostConsumer !== "object") errors.push("Missing hostConsumer");
  else {
    if (typeof pack.hostConsumer.hostId !== "string") errors.push("Missing hostConsumer.hostId");
    if (typeof pack.hostConsumer.hostName !== "string") errors.push("Missing hostConsumer.hostName");
    if (!validateEnumValue(pack.hostConsumer.installState, ENUMS.hostInstallState)) errors.push(`Invalid hostConsumer.installState: ${pack.hostConsumer.installState}`);
    if (!validateEnumValue(pack.hostConsumer.usageState, ENUMS.hostUsageState)) errors.push(`Invalid hostConsumer.usageState: ${pack.hostConsumer.usageState}`);
    if (!validateEnumValue(pack.hostConsumer.feedbackState, ENUMS.hostFeedbackState)) errors.push(`Invalid hostConsumer.feedbackState: ${pack.hostConsumer.feedbackState}`);
    if (!validateEnumValue(pack.hostConsumer.adapterState, ENUMS.hostAdapterState)) errors.push(`Invalid hostConsumer.adapterState: ${pack.hostConsumer.adapterState}`);
  }

  // provenance
  if (!pack.provenance || typeof pack.provenance !== "object") errors.push("Missing provenance");
  else {
    if (!validateEnumValue(pack.provenance.sourceKind, ENUMS.sourceKind)) errors.push(`Invalid provenance.sourceKind: ${pack.provenance.sourceKind}`);
    if (!Array.isArray(pack.provenance.sourceRefs)) errors.push("Missing provenance.sourceRefs");
    else {
      for (let i = 0; i < pack.provenance.sourceRefs.length; i++) {
        const ref = pack.provenance.sourceRefs[i];
        if (typeof ref.label !== "string") errors.push(`provenance.sourceRefs[${i}].label must be string`);
        if (typeof ref.path !== "string" || !ref.path) errors.push(`provenance.sourceRefs[${i}].path must be non-empty string`);
        else if (ref.path.startsWith("/") || ref.path.startsWith("\\")) errors.push(`provenance.sourceRefs[${i}].path must be repo-relative, not absolute: ${ref.path}`);
        else if (/^[a-zA-Z]+:\/\//.test(ref.path)) errors.push(`provenance.sourceRefs[${i}].path must be repo-relative, not URL: ${ref.path}`);
        if (typeof ref.note !== "string") errors.push(`provenance.sourceRefs[${i}].note must be string`);
      }
    }
    if (!validateEnumValue(pack.provenance.dataBoundary, ENUMS.dataBoundary)) errors.push(`Invalid provenance.dataBoundary: ${pack.provenance.dataBoundary}`);
  }

  return errors;
}

// --- Built-in registry ---

const BUILTIN_REGISTRY = [
  {
    identity: {
      packId: "agentharness.pack.pls-reference",
      displayName: "PLS Capability Pack",
      shortName: "PLS Reference Pack",
      version: "0.1.0",
    },
    status: {
      lifecycle: "evaluable",
      releaseReadiness: "blocked",
      distributionReadiness: "blocked",
    },
    summary: {
      description: "Reference capability pack derived from the PLS project. Demonstrates AgentHarness capability registry seam.",
      authority: "AgentHarness",
      consumer: "pi-xanthil Host",
    },
    readiness: {
      evaluationStatus: "warning",
      blockingReason: "KnowledgeBase and MemoryBase integration pending",
      lastCheckedAt: "2026-07-24T00:00:00Z",
    },
    dependencies: {
      bases: [],
    },
    hostConsumer: {
      hostId: "pi-xanthil",
      hostName: "pi-xanthil Host",
      installState: "simulated",
      usageState: "simulated",
      feedbackState: "not_connected",
      adapterState: "simulated",
    },
    provenance: {
      sourceKind: "reference_pack",
      sourceRefs: [
        { label: "PRD", path: "docs/prd-agentharness-four-bases-one-console-buildout.md", note: "Product requirements" },
        { label: "Discussion", path: "docs/pi-xanthil-capability-pack-discussion.md", note: "Capability pack design discussion" },
        { label: "Prototype", path: "Console/workbench-prototype/index.html", note: "Frontend prototype" },
      ],
      dataBoundary: "demo_only",
    },
  },
];

async function main() {
  const [command, ...args] = process.argv.slice(2);

  switch (command) {
    case "sample-loop":
      await createSampleLoop();
      break;
    case "inspect":
      await inspect();
      break;
    case "approve-memory":
      await approveMemory(args[0], { reviewer: args[1] || "manual-reviewer" });
      break;
    case "capability-packs:list":
      await capabilityPacksList();
      break;
    case "capability-packs:get":
      await capabilityPacksGet(args[0]);
      break;
    case "console-server":
      await consoleServer(args);
      break;
    case "_selftest":
      await selfTest();
      break;
    case "help":
    case undefined:
      printHelp();
      break;
    default:
      fail(`Unknown command: ${command}`);
  }
}

async function createSampleLoop() {
  await ensureStore();

  const now = new Date();
  const startedAt = now.toISOString();
  const endedAt = new Date(now.getTime() + 1000).toISOString();

  const taskId = makeId("task");
  const runId = makeId("run");
  const artifactId = makeId("artifact");
  const memoryCandidateId = makeId("memcand");

  const task = {
    id: taskId,
    title: "Create AgentHarness minimal governance loop",
    description:
      "Sample task used to prove Task -> Run -> Event -> Artifact -> MemoryCandidate.",
    status: "completed",
    priority: "normal",
    requester: "agentharness-console",
    assignee: "codex",
    scope: "agentharness.phase1",
    created_at: startedAt,
    updated_at: endedAt,
    metadata: {
      source: "Console/commands/agentharness.mjs sample-loop",
    },
  };

  const run = {
    id: runId,
    task_id: taskId,
    agent_id: "codex",
    status: "completed",
    started_at: startedAt,
    ended_at: endedAt,
    summary:
      "Generated one sample governance loop and proposed one memory candidate.",
    metadata: {
      mode: "file-jsonl-prototype",
    },
  };

  const artifactUri = path.join(
    "DataBase",
    "artifacts",
    `${artifactId}.txt`,
  );
  const artifactPath = path.join(repoRoot, artifactUri);
  const artifactContent = [
    "AgentHarness Phase 1 sample artifact",
    "",
    `Task: ${taskId}`,
    `Run: ${runId}`,
    "Outcome: the file JSONL governance loop can produce durable records.",
    "",
  ].join("\n");
  await writeFile(artifactPath, artifactContent, "utf8");

  const artifact = {
    id: artifactId,
    run_id: runId,
    type: "report",
    title: "Phase 1 sample loop artifact",
    uri: artifactUri,
    checksum: sha256(artifactContent),
    created_at: endedAt,
    metadata: {
      format: "text/plain",
    },
  };

  const memoryCandidate = {
    id: memoryCandidateId,
    source_run_id: runId,
    source_artifact_id: artifactId,
    scope: "agentharness.phase1",
    content:
      "AgentHarness should keep task, run, event, artifact, and memory-candidate records connected by stable IDs before choosing a database engine.",
    rationale:
      "The sample loop proves the central governance chain with simple JSONL storage.",
    confidence: 0.8,
    status: "proposed",
    created_at: endedAt,
  };

  const events = [
    {
      id: makeId("event"),
      run_id: runId,
      type: "agent.started",
      created_at: startedAt,
      actor: "codex",
      payload: {
        task_id: taskId,
      },
    },
    {
      id: makeId("event"),
      run_id: runId,
      type: "artifact.created",
      created_at: endedAt,
      actor: "codex",
      payload: {
        artifact_id: artifactId,
      },
    },
    {
      id: makeId("event"),
      run_id: runId,
      type: "memory.candidate_created",
      created_at: endedAt,
      actor: "codex",
      payload: {
        memory_candidate_id: memoryCandidateId,
      },
    },
    {
      id: makeId("event"),
      run_id: runId,
      type: "run.completed",
      created_at: endedAt,
      actor: "codex",
      payload: {
        summary: run.summary,
      },
    },
  ];

  await appendJsonl(files.tasks, task);
  await appendJsonl(files.runs, run);
  for (const event of events) {
    await appendJsonl(files.events, event);
  }
  await appendJsonl(files.artifacts, artifact);
  await appendJsonl(files.memoryCandidates, memoryCandidate);

  console.log("Created sample AgentHarness governance loop.");
  console.log(`Task: ${taskId}`);
  console.log(`Run: ${runId}`);
  console.log(`Artifact: ${artifactId}`);
  console.log(`MemoryCandidate: ${memoryCandidateId}`);
}

async function inspect() {
  await ensureStore();

  const [tasks, runs, events, artifacts, candidates, memories] =
    await Promise.all([
      readJsonl(files.tasks),
      readJsonl(files.runs),
      readJsonl(files.events),
      readJsonl(files.artifacts),
      readJsonl(files.memoryCandidates),
      readJsonl(files.memories),
    ]);

  const pendingCandidates = candidates.filter(
    (candidate) => candidate.status === "proposed",
  );

  console.log("AgentHarness Phase 1 file store");
  console.log(`Tasks: ${tasks.length}`);
  console.log(`Runs: ${runs.length}`);
  console.log(`Events: ${events.length}`);
  console.log(`Artifacts: ${artifacts.length}`);
  console.log(`Memory candidates: ${candidates.length}`);
  console.log(`Pending memory candidates: ${pendingCandidates.length}`);
  console.log(`Approved memories: ${memories.length}`);

  if (pendingCandidates.length > 0) {
    console.log("");
    console.log("Pending memory candidates:");
    for (const candidate of pendingCandidates) {
      console.log(`- ${candidate.id} [${candidate.scope}] ${candidate.content}`);
    }
  }
}

async function approveMemory(candidateId, { reviewer }) {
  if (!candidateId) {
    fail("Usage: approve-memory <memory-candidate-id> [reviewer]");
  }

  await ensureStore();

  const candidates = await readJsonl(files.memoryCandidates);
  const candidate = candidates.find((item) => item.id === candidateId);
  if (!candidate) {
    fail(`Memory candidate not found: ${candidateId}`);
  }
  if (candidate.status !== "proposed") {
    fail(`Memory candidate is not proposed: ${candidateId} (${candidate.status})`);
  }

  const reviewedAt = new Date().toISOString();
  const memory = {
    id: makeId("mem"),
    source_candidate_id: candidate.id,
    scope: candidate.scope,
    content: candidate.content,
    confidence: candidate.confidence,
    status: "active",
    created_at: reviewedAt,
    supersedes: [],
    tags: ["phase1"],
  };

  const updatedCandidates = candidates.map((item) =>
    item.id === candidateId
      ? {
          ...item,
          status: "approved",
          reviewed_at: reviewedAt,
          reviewer,
        }
      : item,
  );

  await writeJsonlAtomic(files.memoryCandidates, updatedCandidates);
  await appendJsonl(files.memories, memory);

  console.log("Approved memory candidate.");
  console.log(`MemoryCandidate: ${candidateId}`);
  console.log(`Memory: ${memory.id}`);
}

// --- Capability Registry commands ---

async function capabilityPacksList() {
  const packs = [];
  for (const pack of BUILTIN_REGISTRY) {
    const derived = await packWithDerivedBases(pack);
    if (derived.error) {
      fail(JSON.stringify({ error: "validation_failed", reason: "Readiness derivation failed", details: derived }));
    }
    const errors = validateCapabilityPackShape(derived);
    if (errors.length > 0) {
      fail(JSON.stringify({ error: "validation_failed", reason: "Built-in pack shape invalid", details: errors }));
    }
    packs.push(derived);
  }
  console.log(JSON.stringify(packs, null, 2));
}

async function capabilityPacksGet(packId) {
  if (!packId) {
    fail(JSON.stringify({ error: "missing_argument", reason: "packId is required. Usage: capability-packs:get <packId>" }));
  }

  const pack = BUILTIN_REGISTRY.find((p) => p.identity.packId === packId);
  if (!pack) {
    fail(JSON.stringify({ error: "not_found", reason: `Unknown packId: ${packId}` }));
  }

  const derived = await packWithDerivedBases(pack);
  if (derived.error) {
    fail(JSON.stringify({ error: "validation_failed", reason: "Readiness derivation failed", details: derived }));
  }
  const errors = validateCapabilityPackShape(derived);
  if (errors.length > 0) {
    fail(JSON.stringify({ error: "validation_failed", reason: "Pack shape invalid", details: errors }));
  }

  console.log(JSON.stringify(derived, null, 2));
}

// --- Console local HTTP server ---

const STATIC_ROOT = path.join(repoRoot, "Console", "workbench-prototype");
const STATIC_MIME = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".png": "image/png",
};

const STATIC_WHITELIST = new Set(["index.html"]);

function isStaticAllowed(requestPath) {
  const normalized = path.normalize(requestPath).replace(/^[/\\]+/, "");
  if (STATIC_WHITELIST.has(normalized)) return true;
  const segments = normalized.split(/[\\/]/);
  if (segments.length === 2) {
    const [dir, file] = segments;
    if ((dir === "css" || dir === "js") && file && !file.startsWith(".")) return true;
  }
  if (segments.length === 1 && normalized.endsWith(".png") && !normalized.startsWith(".")) return true;
  return false;
}

function sendJson(res, statusCode, body) {
  const payload = JSON.stringify(body);
  res.writeHead(statusCode, {
    "Content-Type": "application/json; charset=utf-8",
    "Content-Length": Buffer.byteLength(payload),
  });
  res.end(payload);
}

async function handleStaticFile(req, res) {
  const url = new URL(req.url, `http://${req.headers.host || "localhost"}`);
  let requestPath = decodeURIComponent(url.pathname);
  if (requestPath === "/") requestPath = "/index.html";

  if (!isStaticAllowed(requestPath)) {
    sendJson(res, 404, { error: "not_found", path: requestPath });
    return;
  }

  const filePath = path.join(STATIC_ROOT, path.normalize(requestPath));

  if (!filePath.startsWith(STATIC_ROOT)) {
    sendJson(res, 404, { error: "not_found", path: requestPath });
    return;
  }

  try {
    const fileStat = await stat(filePath);
    if (!fileStat.isFile()) {
      sendJson(res, 404, { error: "not_found", path: requestPath });
      return;
    }
  } catch {
    sendJson(res, 404, { error: "not_found", path: requestPath });
    return;
  }

  const ext = path.extname(filePath).toLowerCase();
  const contentType = STATIC_MIME[ext] || "application/octet-stream";
  const content = await readFile(filePath);
  res.writeHead(200, {
    "Content-Type": contentType,
    "Content-Length": content.length,
  });
  res.end(content);
}

async function handleCapabilityPacksList(res) {
  const packs = [];
  for (const pack of BUILTIN_REGISTRY) {
    const derived = await packWithDerivedBases(pack);
    if (derived.error) {
      sendJson(res, 500, { error: "validation_failed", reason: "Readiness derivation failed", details: derived });
      return;
    }
    const errors = validateCapabilityPackShape(derived);
    if (errors.length > 0) {
      sendJson(res, 500, { error: "validation_failed", reason: "Built-in pack shape invalid", details: errors });
      return;
    }
    packs.push(derived);
  }
  sendJson(res, 200, packs);
}

async function handleCapabilityPackGet(res, packId) {
  if (!packId) {
    sendJson(res, 404, { error: "not_found", packId: "" });
    return;
  }

  const pack = BUILTIN_REGISTRY.find((p) => p.identity.packId === packId);
  if (!pack) {
    sendJson(res, 404, { error: "not_found", packId });
    return;
  }

  const derived = await packWithDerivedBases(pack);
  if (derived.error) {
    sendJson(res, 500, { error: "validation_failed", reason: "Readiness derivation failed", details: derived });
    return;
  }
  const errors = validateCapabilityPackShape(derived);
  if (errors.length > 0) {
    sendJson(res, 500, { error: "validation_failed", reason: "Pack shape invalid", details: errors });
    return;
  }

  sendJson(res, 200, derived);
}

async function handleApiRequest(req, res) {
  const url = new URL(req.url, `http://${req.headers.host || "localhost"}`);
  const pathname = url.pathname;

  if (req.method !== "GET") {
    sendJson(res, 405, { error: "method_not_allowed", method: req.method });
    return;
  }

  if (pathname === "/api/capability-packs") {
    await handleCapabilityPacksList(res);
    return;
  }

  const getMatch = pathname.match(/^\/api\/capability-packs\/([^/]+)$/);
  if (getMatch) {
    await handleCapabilityPackGet(res, decodeURIComponent(getMatch[1]));
    return;
  }

  sendJson(res, 404, { error: "not_found", path: pathname });
}

async function consoleServer(args) {
  let port = 4177;
  for (let i = 0; i < args.length; i++) {
    if (args[i] === "--port" && args[i + 1]) {
      port = parseInt(args[i + 1], 10);
      if (isNaN(port) || port < 1 || port > 65535) {
        fail("Invalid port number");
      }
      break;
    }
  }

  const server = http.createServer(async (req, res) => {
    try {
      const url = new URL(req.url, `http://${req.headers.host || "localhost"}`);
      if (url.pathname.startsWith("/api/")) {
        await handleApiRequest(req, res);
      } else {
        await handleStaticFile(req, res);
      }
    } catch {
      if (!res.headersSent) {
        sendJson(res, 500, { error: "registry_unavailable" });
      }
    }
  });

  server.on("error", (err) => {
    if (err.code === "EADDRINUSE") {
      console.error(JSON.stringify({ error: "listen_failed", reason: `Port ${port} already in use` }));
    } else if (err.code === "EACCES" || err.code === "EPERM") {
      console.error(JSON.stringify({ error: "listen_failed", reason: `Permission denied binding to 127.0.0.1:${port}` }));
    } else {
      console.error(JSON.stringify({ error: "listen_failed", reason: err.message }));
    }
    process.exit(1);
  });

  server.listen(port, "127.0.0.1", () => {
    console.log(`AgentHarness Console server listening on http://127.0.0.1:${port}`);
    console.log(`Static root: ${STATIC_ROOT}`);
    console.log(`API: GET /api/capability-packs`);
    console.log(`API: GET /api/capability-packs/:packId`);
  });
}

// --- Internal self-test for validator negative paths ---

async function selfTest() {
  const results = [];

  // --- Capability pack shape validator tests (sync) ---

  // Test 1: invalid lifecycle enum
  const badLifecycle = JSON.parse(JSON.stringify(BUILTIN_REGISTRY[0]));
  badLifecycle.status.lifecycle = "experimental";
  const r1 = validateCapabilityPackShape(badLifecycle);
  results.push({ test: "reject invalid lifecycle enum", passed: r1.some((e) => e.includes("Invalid status.lifecycle")), errors: r1.filter((e) => e.includes("lifecycle")) });

  // Test 2: missing required field (identity)
  const noIdentity = { ...JSON.parse(JSON.stringify(BUILTIN_REGISTRY[0])), identity: undefined };
  const r2 = validateCapabilityPackShape(noIdentity);
  results.push({ test: "reject missing identity", passed: r2.some((e) => e.includes("Missing identity")), errors: r2.filter((e) => e.includes("identity")) });

  // Test 3: invalid base name (B1)
  const badBase = JSON.parse(JSON.stringify(BUILTIN_REGISTRY[0]));
  badBase.dependencies.bases = [{ base: "FooBase", state: "ready", note: "test" }];
  const r3 = validateCapabilityPackShape(badBase);
  results.push({ test: "reject invalid base name FooBase", passed: r3.some((e) => e.includes("Invalid dependencies.bases[0].base")), errors: r3.filter((e) => e.includes("base")) });

  // Test 4: absolute provenance path (B2)
  const absPath = JSON.parse(JSON.stringify(BUILTIN_REGISTRY[0]));
  absPath.provenance.sourceRefs[0].path = "/Users/foo/bar.md";
  const r4 = validateCapabilityPackShape(absPath);
  results.push({ test: "reject absolute provenance path", passed: r4.some((e) => e.includes("must be repo-relative, not absolute")), errors: r4.filter((e) => e.includes("repo-relative")) });

  // Test 5: URL provenance path (B2)
  const urlPath = JSON.parse(JSON.stringify(BUILTIN_REGISTRY[0]));
  urlPath.provenance.sourceRefs[0].path = "https://example.com/doc.md";
  const r5 = validateCapabilityPackShape(urlPath);
  results.push({ test: "reject URL provenance path", passed: r5.some((e) => e.includes("must be repo-relative, not URL")), errors: r5.filter((e) => e.includes("repo-relative")) });

  // Test 6: empty provenance path (B2)
  const emptyPath = JSON.parse(JSON.stringify(BUILTIN_REGISTRY[0]));
  emptyPath.provenance.sourceRefs[0].path = "";
  const r6 = validateCapabilityPackShape(emptyPath);
  results.push({ test: "reject empty provenance path", passed: r6.some((e) => e.includes("must be non-empty string")), errors: r6.filter((e) => e.includes("non-empty")) });

  // --- Readiness observation validator tests (sync, direct object validation) ---

  // Test 7: readiness observation invalid base
  const badObsBase = { packId: "test", base: "FooBase", state: "ready", reason: "x", observedAt: "2026-07-24T00:00:00Z", evidenceRefs: [], ownerDomain: "database" };
  const r7 = validateReadinessObservation(badObsBase, 0);
  results.push({ test: "reject invalid observation base", passed: r7.some((e) => e.includes("invalid base")), errors: r7.filter((e) => e.includes("base")) });

  // Test 8: readiness observation invalid state
  const badObsState = { packId: "test", base: "DataBase", state: "unknown", reason: "x", observedAt: "2026-07-24T00:00:00Z", evidenceRefs: [], ownerDomain: "database" };
  const r8 = validateReadinessObservation(badObsState, 0);
  results.push({ test: "reject invalid observation state", passed: r8.some((e) => e.includes("invalid state")), errors: r8.filter((e) => e.includes("state")) });

  // Test 9: readiness observation invalid ownerDomain
  const badObsOwner = { packId: "test", base: "DataBase", state: "ready", reason: "x", observedAt: "2026-07-24T00:00:00Z", evidenceRefs: [], ownerDomain: "invalid" };
  const r9 = validateReadinessObservation(badObsOwner, 0);
  results.push({ test: "reject invalid observation ownerDomain", passed: r9.some((e) => e.includes("invalid ownerDomain")), errors: r9.filter((e) => e.includes("ownerDomain")) });

  // Test 10: readiness observation absolute evidenceRef path
  const badObsAbsPath = { packId: "test", base: "DataBase", state: "ready", reason: "x", observedAt: "2026-07-24T00:00:00Z", evidenceRefs: [{ label: "x", path: "/Users/foo/bar.md", note: "n" }], ownerDomain: "database" };
  const r10 = validateReadinessObservation(badObsAbsPath, 0);
  results.push({ test: "reject absolute evidenceRef path in observation", passed: r10.some((e) => e.includes("repo-relative, not absolute")), errors: r10.filter((e) => e.includes("repo-relative")) });

  // Test 11: readiness observation URL evidenceRef path
  const badObsUrlPath = { packId: "test", base: "DataBase", state: "ready", reason: "x", observedAt: "2026-07-24T00:00:00Z", evidenceRefs: [{ label: "x", path: "https://example.com/doc.md", note: "n" }], ownerDomain: "database" };
  const r11 = validateReadinessObservation(badObsUrlPath, 0);
  results.push({ test: "reject URL evidenceRef path in observation", passed: r11.some((e) => e.includes("repo-relative, not URL")), errors: r11.filter((e) => e.includes("repo-relative")) });

  // Test 12: readiness observation empty evidenceRef path
  const badObsEmptyPath = { packId: "test", base: "DataBase", state: "ready", reason: "x", observedAt: "2026-07-24T00:00:00Z", evidenceRefs: [{ label: "x", path: "", note: "n" }], ownerDomain: "database" };
  const r12 = validateReadinessObservation(badObsEmptyPath, 0);
  results.push({ test: "reject empty evidenceRef path in observation", passed: r12.some((e) => e.includes("non-empty")), errors: r12.filter((e) => e.includes("non-empty")) });

  // Test 13: readiness observation missing required fields
  const badObsMissing = { packId: "test" };
  const r13 = validateReadinessObservation(badObsMissing, 0);
  results.push({ test: "reject observation missing required fields", passed: r13.length >= 4, errors: r13 });

  // Test 14: readiness observation missing packId
  const badObsNoPackId = { base: "DataBase", state: "ready", reason: "x", observedAt: "2026-07-24T00:00:00Z", evidenceRefs: [], ownerDomain: "database" };
  const r14 = validateReadinessObservation(badObsNoPackId, 0);
  results.push({ test: "reject observation missing packId", passed: r14.some((e) => e.includes("packId")), errors: r14.filter((e) => e.includes("packId")) });

  // --- File-based reader tests (async, temporary fixtures) ---

  const tmpDir = path.join(__dirname, "_selftest_fixtures");
  const tmpFiles = {
    DataBase: path.join(tmpDir, "db.json"),
    OntoBase: path.join(tmpDir, "onto.json"),
    KnowledgeBase: path.join(tmpDir, "kb.json"),
    MemoryBase: path.join(tmpDir, "mem.json"),
  };
  const realFiles = { ...BASE_READINESS_FILES };
  let tmpDirCreated = false;

  async function setupFixtures(baseFacts) {
    await mkdir(tmpDir, { recursive: true });
    tmpDirCreated = true;
    Object.assign(BASE_READINESS_FILES, tmpFiles);
    for (const [base, facts] of Object.entries(baseFacts)) {
      await writeFile(tmpFiles[base], JSON.stringify(facts), "utf8");
    }
  }

  async function cleanupFixtures() {
    Object.assign(BASE_READINESS_FILES, realFiles);
    if (tmpDirCreated) {
      await rm(tmpDir, { recursive: true, force: true });
      tmpDirCreated = false;
    }
  }

  const validFact = (base, overrides = {}) => ({
    base,
    packId: "agentharness.pack.pls-reference",
    state: base === "DataBase" || base === "OntoBase" ? "ready" : "pending",
    reason: `${base} test fact`,
    checkedAt: "2026-07-24T00:00:00Z",
    evidenceRefs: [{ label: "test", path: "docs/four-bases-one-console-contract.md", note: "test" }],
    producer: ENUMS.ownerDomain[ENUMS.baseName.indexOf(base)],
    ...overrides,
  });

  const allValidFixtures = {
    DataBase: [validFact("DataBase")],
    OntoBase: [validFact("OntoBase")],
    KnowledgeBase: [validFact("KnowledgeBase")],
    MemoryBase: [validFact("MemoryBase")],
  };

  // Test 15: valid fixtures produce 4 observations
  try {
    await setupFixtures(allValidFixtures);
    const r15 = await readBaseReadinessFacts("agentharness.pack.pls-reference");
    const r15ok = Array.isArray(r15) && r15.length === 4 && !r15.error;
    results.push({ test: "reader: valid fixtures produce 4 observations", passed: r15ok, errors: r15ok ? [] : [JSON.stringify(r15)] });
  } catch (e) {
    results.push({ test: "reader: valid fixtures produce 4 observations", passed: false, errors: [e.message] });
  }

  // Test 16: field mapping from fact to observation
  try {
    await setupFixtures(allValidFixtures);
    const r16 = await readBaseReadinessFacts("agentharness.pack.pls-reference");
    const r16ok = !r16.error && r16[0].observedAt === "2026-07-24T00:00:00Z" && r16[0].ownerDomain === "database";
    results.push({ test: "reader: field mapping (checkedAt->observedAt, producer->ownerDomain)", passed: r16ok, errors: r16ok ? [] : [JSON.stringify(r16[0])] });
  } catch (e) {
    results.push({ test: "reader: field mapping (checkedAt->observedAt, producer->ownerDomain)", passed: false, errors: [e.message] });
  }

  // Test 17: missing file fail closed
  try {
    Object.assign(BASE_READINESS_FILES, realFiles);
    const missingDir = path.join(tmpDir, "missing");
    BASE_READINESS_FILES.DataBase = path.join(missingDir, "db.json");
    const r17 = await readBaseReadinessFacts("agentharness.pack.pls-reference");
    results.push({ test: "reader: missing file fails closed", passed: r17.error === "validation_failed" && r17.reason.includes("missing"), errors: r17.error === "validation_failed" ? [] : [JSON.stringify(r17)] });
  } catch (e) {
    results.push({ test: "reader: missing file fails closed", passed: false, errors: [e.message] });
  }

  // Test 18: invalid JSON fail closed
  try {
    await setupFixtures({ DataBase: [], OntoBase: [], KnowledgeBase: [], MemoryBase: [] });
    await writeFile(tmpFiles.DataBase, "not json{{{", "utf8");
    const r18 = await readBaseReadinessFacts("agentharness.pack.pls-reference");
    results.push({ test: "reader: invalid JSON fails closed", passed: r18.error === "validation_failed" && r18.reason.includes("Invalid JSON"), errors: r18.error === "validation_failed" ? [] : [JSON.stringify(r18)] });
  } catch (e) {
    results.push({ test: "reader: invalid JSON fails closed", passed: false, errors: [e.message] });
  }

  // Test 19: non-array fail closed
  try {
    await setupFixtures({ DataBase: [], OntoBase: [], KnowledgeBase: [], MemoryBase: [] });
    await writeFile(tmpFiles.DataBase, '{"not":"array"}', "utf8");
    const r19 = await readBaseReadinessFacts("agentharness.pack.pls-reference");
    results.push({ test: "reader: non-array fails closed", passed: r19.error === "validation_failed" && r19.reason.includes("must be an array"), errors: r19.error === "validation_failed" ? [] : [JSON.stringify(r19)] });
  } catch (e) {
    results.push({ test: "reader: non-array fails closed", passed: false, errors: [e.message] });
  }

  // Test 20: missing base fact fail closed
  try {
    const noKb = { ...allValidFixtures, KnowledgeBase: [] };
    await setupFixtures(noKb);
    const r20 = await readBaseReadinessFacts("agentharness.pack.pls-reference");
    results.push({ test: "reader: missing base fact fails closed", passed: r20.error === "validation_failed" && r20.reason.includes("Missing readiness facts"), errors: r20.error === "validation_failed" ? [] : [JSON.stringify(r20)] });
  } catch (e) {
    results.push({ test: "reader: missing base fact fails closed", passed: false, errors: [e.message] });
  }

  // Test 21: bad state fails closed
  try {
    const badState = { ...allValidFixtures, DataBase: [validFact("DataBase", { state: "bad_state" })] };
    await setupFixtures(badState);
    const r21 = await readBaseReadinessFacts("agentharness.pack.pls-reference");
    results.push({ test: "reader: bad state fails closed", passed: r21.error === "validation_failed" && r21.reason.includes("DataBase"), errors: r21.error === "validation_failed" ? [] : [JSON.stringify(r21)] });
  } catch (e) {
    results.push({ test: "reader: bad state fails closed", passed: false, errors: [e.message] });
  }

  // Test 22: bad base in file fails closed
  try {
    const badBaseF = { ...allValidFixtures, DataBase: [validFact("OntoBase")] };
    await setupFixtures(badBaseF);
    const r22 = await readBaseReadinessFacts("agentharness.pack.pls-reference");
    results.push({ test: "reader: wrong base in file fails closed", passed: r22.error === "validation_failed", errors: r22.error === "validation_failed" ? [] : [JSON.stringify(r22)] });
  } catch (e) {
    results.push({ test: "reader: wrong base in file fails closed", passed: false, errors: [e.message] });
  }

  // Test 23: duplicate base+packId fails closed
  try {
    const dup = { ...allValidFixtures, DataBase: [validFact("DataBase"), validFact("DataBase")] };
    await setupFixtures(dup);
    const r23 = await readBaseReadinessFacts("agentharness.pack.pls-reference");
    results.push({ test: "reader: duplicate base+packId fails closed", passed: r23.error === "validation_failed" && r23.reason.includes("DataBase"), errors: r23.error === "validation_failed" ? [] : [JSON.stringify(r23)] });
  } catch (e) {
    results.push({ test: "reader: duplicate base+packId fails closed", passed: false, errors: [e.message] });
  }

  // Test 24: bad producer fails closed
  try {
    const badProducer = { ...allValidFixtures, DataBase: [validFact("DataBase", { producer: "wrong" })] };
    await setupFixtures(badProducer);
    const r24 = await readBaseReadinessFacts("agentharness.pack.pls-reference");
    results.push({ test: "reader: bad producer fails closed", passed: r24.error === "validation_failed", errors: r24.error === "validation_failed" ? [] : [JSON.stringify(r24)] });
  } catch (e) {
    results.push({ test: "reader: bad producer fails closed", passed: false, errors: [e.message] });
  }

  // Test 25: absolute evidence path fails closed
  try {
    const absEvidence = { ...allValidFixtures, DataBase: [validFact("DataBase", { evidenceRefs: [{ label: "x", path: "/abs/path.md", note: "n" }] })] };
    await setupFixtures(absEvidence);
    const r25 = await readBaseReadinessFacts("agentharness.pack.pls-reference");
    results.push({ test: "reader: absolute evidence path fails closed", passed: r25.error === "validation_failed", errors: r25.error === "validation_failed" ? [] : [JSON.stringify(r25)] });
  } catch (e) {
    results.push({ test: "reader: absolute evidence path fails closed", passed: false, errors: [e.message] });
  }

  // Test 26: URL evidence path fails closed
  try {
    const urlEvidence = { ...allValidFixtures, DataBase: [validFact("DataBase", { evidenceRefs: [{ label: "x", path: "https://example.com/doc.md", note: "n" }] })] };
    await setupFixtures(urlEvidence);
    const r26 = await readBaseReadinessFacts("agentharness.pack.pls-reference");
    results.push({ test: "reader: URL evidence path fails closed", passed: r26.error === "validation_failed", errors: r26.error === "validation_failed" ? [] : [JSON.stringify(r26)] });
  } catch (e) {
    results.push({ test: "reader: URL evidence path fails closed", passed: false, errors: [e.message] });
  }

  // Test 27: non-existent evidence path fails closed
  try {
    const noExistEvidence = { ...allValidFixtures, DataBase: [validFact("DataBase", { evidenceRefs: [{ label: "x", path: "no/such/file.md", note: "n" }] })] };
    await setupFixtures(noExistEvidence);
    const r27 = await readBaseReadinessFacts("agentharness.pack.pls-reference");
    results.push({ test: "reader: non-existent evidence path fails closed", passed: r27.error === "validation_failed", errors: r27.error === "validation_failed" ? [] : [JSON.stringify(r27)] });
  } catch (e) {
    results.push({ test: "reader: non-existent evidence path fails closed", passed: false, errors: [e.message] });
  }

  // Test 28: empty evidenceRefs fails closed
  try {
    const emptyRefs = { ...allValidFixtures, DataBase: [validFact("DataBase", { evidenceRefs: [] })] };
    await setupFixtures(emptyRefs);
    const r28 = await readBaseReadinessFacts("agentharness.pack.pls-reference");
    results.push({ test: "reader: empty evidenceRefs fails closed", passed: r28.error === "validation_failed", errors: r28.error === "validation_failed" ? [] : [JSON.stringify(r28)] });
  } catch (e) {
    results.push({ test: "reader: empty evidenceRefs fails closed", passed: false, errors: [e.message] });
  }

  // --- Integration tests with real owner files ---

  // Test 29: getCapabilityPackBaseReadiness reads real owner files
  try {
    Object.assign(BASE_READINESS_FILES, realFiles);
    const r29 = await getCapabilityPackBaseReadiness("agentharness.pack.pls-reference");
    const r29ok = Array.isArray(r29) && r29.length === 4 && !r29.error && r29[0].base === "DataBase";
    results.push({ test: "integration: reads real owner files", passed: r29ok, errors: r29ok ? [] : [JSON.stringify(r29)] });
  } catch (e) {
    results.push({ test: "integration: reads real owner files", passed: false, errors: [e.message] });
  }

  // Test 30: deriveBasesFromReadiness propagates errors
  try {
    Object.assign(BASE_READINESS_FILES, realFiles);
    const r30 = await deriveBasesFromReadiness("unknown.pack");
    results.push({ test: "deriveBases propagates validation_failed (missing pack)", passed: r30.error === "validation_failed", errors: r30.error === "validation_failed" ? [] : [JSON.stringify(r30)] });
  } catch (e) {
    results.push({ test: "deriveBases propagates validation_failed (missing pack)", passed: false, errors: [e.message] });
  }

  // Test 31: packWithDerivedBases with real files
  try {
    Object.assign(BASE_READINESS_FILES, realFiles);
    const r31 = await packWithDerivedBases(BUILTIN_REGISTRY[0]);
    const r31ok = !r31.error && r31.dependencies.bases.length === 4 && r31.dependencies.bases[0].base === "DataBase";
    results.push({ test: "packWithDerivedBases: real files return derived bases", passed: r31ok, errors: r31ok ? [] : [`Got: ${JSON.stringify(r31.dependencies?.bases?.length)}`] });
  } catch (e) {
    results.push({ test: "packWithDerivedBases: real files return derived bases", passed: false, errors: [e.message] });
  }

  // Test 32: DataBase/OntoBase state=ready, KnowledgeBase/MemoryBase state=pending
  try {
    Object.assign(BASE_READINESS_FILES, realFiles);
    const r32 = await deriveBasesFromReadiness("agentharness.pack.pls-reference");
    const db = r32.find((b) => b.base === "DataBase");
    const onto = r32.find((b) => b.base === "OntoBase");
    const kb = r32.find((b) => b.base === "KnowledgeBase");
    const mem = r32.find((b) => b.base === "MemoryBase");
    const r32ok = !r32.error && db?.state === "ready" && onto?.state === "ready" && kb?.state === "pending" && mem?.state === "pending";
    results.push({ test: "integration: DB/Onto=ready, KB/Mem=pending", passed: r32ok, errors: r32ok ? [] : [`DB=${db?.state} Onto=${onto?.state} KB=${kb?.state} Mem=${mem?.state}`] });
  } catch (e) {
    results.push({ test: "integration: DB/Onto=ready, KB/Mem=pending", passed: false, errors: [e.message] });
  }

  // Test 33: dependencies.bases[].note comes from owner JSON reason
  try {
    Object.assign(BASE_READINESS_FILES, realFiles);
    const r33 = await deriveBasesFromReadiness("agentharness.pack.pls-reference");
    const r33ok = !r33.error && r33.every((b) => typeof b.note === "string" && b.note.length > 0);
    results.push({ test: "integration: bases[].note from owner reason", passed: r33ok, errors: r33ok ? [] : [JSON.stringify(r33.map((b) => ({ base: b.base, note: b.note })))] });
  } catch (e) {
    results.push({ test: "integration: bases[].note from owner reason", passed: false, errors: [e.message] });
  }

  // Cleanup
  await cleanupFixtures();

  const allPassed = results.every((r) => r.passed);
  console.log(JSON.stringify({ selftest: allPassed ? "PASS" : "FAIL", results }, null, 2));
  if (!allPassed) process.exit(1);
}

async function ensureStore() {
  await Promise.all([
    mkdir(paths.dataRuns, { recursive: true }),
    mkdir(paths.artifacts, { recursive: true }),
    mkdir(paths.memoryCandidates, { recursive: true }),
    mkdir(paths.memories, { recursive: true }),
  ]);

  await Promise.all(Object.values(files).map(ensureFile));
}

async function ensureFile(filePath) {
  if (!existsSync(filePath)) {
    await writeFile(filePath, "", "utf8");
  }
}

async function appendJsonl(filePath, value) {
  await writeFile(filePath, `${JSON.stringify(value)}\n`, {
    encoding: "utf8",
    flag: "a",
  });
}

async function readJsonl(filePath) {
  if (!existsSync(filePath)) {
    return [];
  }

  const content = await readFile(filePath, "utf8");
  return content
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => JSON.parse(line));
}

async function writeJsonlAtomic(filePath, values) {
  const tmpPath = `${filePath}.${process.pid}.tmp`;
  const content = values.map((value) => JSON.stringify(value)).join("\n");
  await writeFile(tmpPath, content.length > 0 ? `${content}\n` : "", "utf8");
  await rename(tmpPath, filePath);
}

function makeId(prefix) {
  const timestamp = new Date()
    .toISOString()
    .replace(/[-:.TZ]/g, "")
    .slice(0, 14);
  const suffix = crypto.randomBytes(4).toString("hex");
  return `${prefix}_${timestamp}_${suffix}`;
}

function sha256(content) {
  return crypto.createHash("sha256").update(content).digest("hex");
}

function printHelp() {
  console.log(`AgentHarness Console

Usage:
  node Console/commands/agentharness.mjs sample-loop
  node Console/commands/agentharness.mjs inspect
  node Console/commands/agentharness.mjs approve-memory <memory-candidate-id> [reviewer]
  node Console/commands/agentharness.mjs capability-packs:list
  node Console/commands/agentharness.mjs capability-packs:get <packId>
  node Console/commands/agentharness.mjs console-server [--port <port>]
`);
}

function fail(message) {
  console.error(message);
  process.exit(1);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
