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
// Primary: gemini-3.1-flash-lite — stable/GA, exact ID per
// ai.google.dev/gemini-api/docs/models/gemini-3.1-flash-lite.
// Do NOT go back to gemini-2.5-flash-lite: Google 404s it for NEW accounts
// as of July 2026 ("no longer available to new users"), which killed the
// July 14 dry run. Fallback: gemini-3.5-flash (GA; pricier, but it only
// absorbs transient failures, not steady traffic).
const MODEL = process.env.OPENCLAW_MODEL || "google/gemini-3.1-flash-lite";
const FALLBACK = process.env.OPENCLAW_FALLBACK || "google/gemini-3.5-flash";
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

// Self-heal: an earlier revision of this script injected a root-level
// `mcpServers` key, which the schema rejects ("<root>: Invalid input").
// Strip it if it's still there.
delete c.mcpServers;

// Register the workshop MCP tool server (mcp/workshop-tools.js: roll_dice +
// get_weather) under the DOCUMENTED key: mcp.servers.<name> with
// command/args (see docs.openclaw.ai/cli/mcp, "Example config shape").
// Root-level `mcpServers` is NOT valid — that mistake broke the gateway
// config in the July 14 dry run.
const repoRoot = path.resolve(__dirname, "..");
c.mcp = c.mcp || {};
c.mcp.servers = Object.assign({}, c.mcp.servers, {
  "workshop-tools": {
    command: "node",
    args: [path.join(repoRoot, "mcp", "workshop-tools.js")],
  },
});

fs.writeFileSync(cfgPath, JSON.stringify(c, null, 2));
console.log(
  "patch-config: model=" + MODEL +
  " origin=http://localhost:" + PORT + " auth=none" +
  " mcp.servers=workshop-tools"
);
