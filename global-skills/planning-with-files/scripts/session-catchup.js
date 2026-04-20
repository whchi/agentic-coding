#!/usr/bin/env node
/**
 * Session Catchup Script for planning-with-files
 *
 * Analyzes the previous session to find unsynced context after the last
 * planning file update. Designed to run on SessionStart.
 *
 * Usage: node session-catchup.js [project-path]
 */

const fs = require("fs");
const path = require("path");
const os = require("os");

const PLANNING_FILES = ["task_plan.md", "progress.md", "findings.md"];

function getProjectDir(projectPath) {
  const resolvedStr = path.resolve(projectPath);

  const sanitized = resolvedStr
    .replace(/\//g, "-")
    .replace(/:/g, "");

  const sanitizedName = sanitized.startsWith("-")
    ? sanitized.replace(/_/g, "-")
    : ("-" + sanitized).replace(/_/g, "-");

  const legacyDir = path.join(os.homedir(), ".opencode", "sessions", sanitizedName);
  if (fs.existsSync(legacyDir) && fs.statSync(legacyDir).isDirectory()) {
    return legacyDir;
  }

  const dataRootEnv = process.env.OPENCODE_DATA_DIR;
  let dataRoot;
  if (dataRootEnv) {
    dataRoot = dataRootEnv;
  } else {
    const xdgRoot = process.env.XDG_DATA_HOME;
    if (xdgRoot) {
      dataRoot = path.join(xdgRoot, "opencode", "storage");
    } else {
      dataRoot = path.join(os.homedir(), ".local", "share", "opencode", "storage");
    }
  }

  return path.join(dataRoot, "session", sanitizedName);
}

function getSessionsSorted(projectDir) {
  let sessions = [];
  try {
    const entries = fs.readdirSync(projectDir);
    for (const entry of entries) {
      if (entry.endsWith(".jsonl") || entry.endsWith(".json")) {
        if (!entry.startsWith("agent-")) {
          sessions.push(path.join(projectDir, entry));
        }
      }
    }
  } catch (e) {
    return [];
  }

  const uniqueSessions = [...new Set(sessions)];
  return uniqueSessions
    .map((s) => ({ path: s, mtime: fs.statSync(s).mtimeMs }))
    .sort((a, b) => b.mtime - a.mtime)
    .map((s) => s.path);
}

function parseSessionMessages(sessionFile) {
  const messages = [];

  try {
    const content = fs.readFileSync(sessionFile, "utf-8");
    if (!content.trim()) return messages;

    try {
      const data = JSON.parse(content);
      if (Array.isArray(data)) {
        for (let idx = 0; idx < data.length; idx++) {
          const item = data[idx];
          if (typeof item === "object" && item !== null) {
            item._line_num = idx;
            messages.push(item);
          }
        }
      } else if (typeof data === "object" && data !== null) {
        const msgList = data.messages;
        if (Array.isArray(msgList)) {
          for (let idx = 0; idx < msgList.length; idx++) {
            const item = msgList[idx];
            if (typeof item === "object" && item !== null) {
              item._line_num = idx;
              messages.push(item);
            }
          }
        }
      }
      if (messages.length > 0) return messages;
    } catch (parseErr) {
      // Fall through to JSONL parsing
    }

    // Fallback: JSONL parsing
    const lines = content.split("\n");
    for (let lineNum = 0; lineNum < lines.length; lineNum++) {
      const line = lines[lineNum];
      if (!line.trim()) continue;
      try {
        const data = JSON.parse(line);
        if (typeof data === "object" && data !== null) {
          data._line_num = lineNum;
          messages.push(data);
        }
      } catch (e) {
        // Ignore malformed lines
      }
    }
  } catch (e) {
    // File read error
  }

  return messages;
}

function findLastPlanningUpdate(messages) {
  let lastUpdateLine = -1;
  let lastUpdateFile = null;

  for (const msg of messages) {
    const msgType = msg.type;

    if (msgType === "assistant") {
      const content = (msg.message && msg.message.content) || [];
      if (Array.isArray(content)) {
        for (const item of content) {
          if (item.type === "tool_use") {
            const toolName = item.name || "";
            const toolInput = item.input || {};

            if (toolName === "write" || toolName === "edit") {
              const filePath = toolInput.filePath || "";
              for (const pf of PLANNING_FILES) {
                if (filePath.endsWith(pf)) {
                  lastUpdateLine = msg._line_num;
                  lastUpdateFile = pf;
                }
              }
            }
          }
        }
      }
    }
  }

  return { lastUpdateLine, lastUpdateFile };
}

function extractMessagesAfter(messages, afterLine) {
  const result = [];

  for (const msg of messages) {
    if (msg._line_num <= afterLine) continue;

    const msgType = msg.type;
    const isMeta = msg.isMeta || false;

    if (msgType === "user" && !isMeta) {
      let content = (msg.message && msg.message.content) || "";
      if (Array.isArray(content)) {
        let extracted = "";
        for (const item of content) {
          if (typeof item === "object" && item.type === "text") {
            extracted = item.text || "";
            break;
          }
        }
        content = extracted;
      }

      if (content && typeof content === "string") {
        if (
          content.startsWith("<local-command") ||
          content.startsWith("<command-") ||
          content.startsWith("<task-notification")
        ) {
          continue;
        }
        if (content.length > 20) {
          result.push({ role: "user", content, line: msg._line_num });
        }
      }
    } else if (msgType === "assistant") {
      const msgContent = (msg.message && msg.message.content) || "";
      let textContent = "";
      const toolUses = [];

      if (typeof msgContent === "string") {
        textContent = msgContent;
      } else if (Array.isArray(msgContent)) {
        for (const item of msgContent) {
          if (item.type === "text") {
            textContent = item.text || "";
          } else if (item.type === "tool_use") {
            const toolName = item.name || "";
            const toolInput = item.input || {};
            if (toolName === "edit") {
              toolUses.push(`edit: ${toolInput.filePath || "unknown"}`);
            } else if (toolName === "write") {
              toolUses.push(`write: ${toolInput.filePath || "unknown"}`);
            } else if (toolName === "bash") {
              const cmd = (toolInput.command || "").slice(0, 80);
              toolUses.push(`bash: ${cmd}`);
            } else {
              toolUses.push(toolName);
            }
          }
        }
      }

      if (textContent || toolUses.length > 0) {
        result.push({
          role: "assistant",
          content: textContent.slice(0, 600),
          tools: toolUses,
          line: msg._line_num,
        });
      }
    }
  }

  return result;
}

function main() {
  const projectPath = process.argv[2] || process.cwd();
  const projectDir = getProjectDir(projectPath);

  const hasPlanningFiles = PLANNING_FILES.some((f) =>
    fs.existsSync(path.join(projectPath, f))
  );
  if (!hasPlanningFiles) {
    return;
  }

  if (!fs.existsSync(projectDir)) {
    return;
  }

  const sessions = getSessionsSorted(projectDir);
  if (sessions.length < 1) {
    return;
  }

  let targetSession = null;
  for (const session of sessions) {
    if (fs.statSync(session).size > 5000) {
      targetSession = session;
      break;
    }
  }

  if (!targetSession) {
    return;
  }

  const messages = parseSessionMessages(targetSession);
  const { lastUpdateLine, lastUpdateFile } = findLastPlanningUpdate(messages);

  if (lastUpdateLine < 0) {
    return;
  }

  const messagesAfter = extractMessagesAfter(messages, lastUpdateLine);

  if (!messagesAfter.length) {
    return;
  }

  const targetSessionStem = path.basename(targetSession, path.extname(targetSession));

  console.log("\n[planning-with-files] SESSION CATCHUP DETECTED");
  console.log(`Previous session: ${targetSessionStem}`);
  console.log(
    `Last planning update: ${lastUpdateFile} at message #${lastUpdateLine}`
  );
  console.log(`Unsynced messages: ${messagesAfter.length}`);

  console.log("\n--- UNSYNCED CONTEXT ---");
  const last15 = messagesAfter.slice(-15);
  for (const msg of last15) {
    if (msg.role === "user") {
      console.log(`USER: ${msg.content.slice(0, 300)}`);
    } else {
      if (msg.content) {
        console.log(`OPENCODE: ${msg.content.slice(0, 300)}`);
      }
      if (msg.tools) {
        console.log(`  Tools: ${msg.tools.slice(0, 4).join(", ")}`);
      }
    }
  }

  console.log("\n--- RECOMMENDED ---");
  console.log("1. Run: git diff --stat");
  console.log("2. Read: task_plan.md, progress.md, findings.md");
  console.log("3. Update planning files based on above context");
  console.log("4. Continue with task");
}

main();
