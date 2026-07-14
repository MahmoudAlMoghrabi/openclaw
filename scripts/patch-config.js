#!/usr/bin/env node
// Applies the workshop's settings to OpenClaw's REAL config file, run right
// after `openclaw onboard`.
//
// WHY THIS EXISTS (all confirmed on OpenClaw 2026.6.11 during the dry run):
//   1. OpenClaw reads ~/.openclaw/openclaw.json. The repo's .openclaw/config.json5
//      is IGNORED, so pinning the model there did nothing.
//   2. `openclaw onboard` writes a default model of gemini-3.1-pro-preview, an
//      expensive, paid-only Pro model. We overwrite it with the cheap workshop
//      model so 50 attendees stay inside the budget.
//   3. The GitHub Codespaces proxy rewrites every browser origin to
//      http://localhost:18789, so THAT is the origin the gateway must allow.
//      It is identical for every Codespace (no per-attendee value needed).
//   4. auth=none removes token juggling for 50 people; the Codespace port is
//      already private to the signed-in GitHub user.
"use strict";
const fs = require("fs");
const os = require("os");
const path = require("path");

// Single source of truth for the workshop model. Override with OPENCLAW_MODEL.
// Primary: gemini-2.5-flash-lite ($0.10/$0.40). Overflow: gemini-3.1-flash-lite.
const MODEL = process.env.OPENCLAW_MODEL || "google/gemini-2.5-flash-lite";
const FALLBACK = process.env.OPENCLAW_FALLBACK || "google/gemini-3.1-flash-lite";
const PORT = process.env.OPENCLAW_PORT || "18789";

const cfgPath = os.homedir() + "/.openclaw/openclaw.json";
if (!fs.existsSync(cfgPath)) {
  console.error("patch-config: " + cfgPath + " not found. Run `openclaw onboard` first.");
  process.exit(1);
}

const c = JSON.parse(fs.readFileSync(cfgPath, "utf8"));

c.agents = c.agents || {};
c.agents.defaults = c.agents.defaults || {};
c.agents.defaults.model = { primary: MODEL, fallbacks: [FALLBACK] };
c.agents.defaults.models = { [MODEL]: {}, [FALLBACK]: {} };

c.gateway = c.gateway || {};
c.gateway.controlUi = Object.assign({}, c.gateway.controlUi, {
  allowedOrigins: ["http://localhost:" + PORT, "http://127.0.0.1:" + PORT],
});
c.gateway.auth = { mode: "none" };

// Register the workshop's MCP tool server (mcp/workshop-tools.js: dice +
// live weather) so the agent has real tools beyond the chat.
// DRY-RUN CHECK: the key below follows the common `mcpServers` convention.
// Confirm this OpenClaw version picks it up (ask the agent to roll dice, or
// look for the tools in the Control UI). If it doesn't, find the right
// registration in `openclaw mcp --help` / docs.openclaw.ai and adjust here.
const repoRoot = path.resolve(__dirname, "..");
c.mcpServers = Object.assign({}, c.mcpServers, {
  "workshop-tools": {
    command: "node",
    args: [path.join(repoRoot, "mcp", "workshop-tools.js")],
  },
});

fs.writeFileSync(cfgPath, JSON.stringify(c, null, 2));
console.log(
  "patch-config: model=" + MODEL +
  " origin=http://localhost:" + PORT + " auth=none" +
  " mcp=workshop-tools"
);
