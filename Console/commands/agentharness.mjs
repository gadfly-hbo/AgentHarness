#!/usr/bin/env node

import { mkdir, readFile, rename, writeFile } from "node:fs/promises";
import { existsSync } from "node:fs";
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
