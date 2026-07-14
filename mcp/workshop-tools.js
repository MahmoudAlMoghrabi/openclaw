#!/usr/bin/env node
// A tiny MCP (Model Context Protocol) server for the workshop: two real tools
// the agent can call. Zero dependencies — Node 22's built-in fetch is enough.
//
// Why these two tools:
//   - roll_dice  : works instantly, even with no internet. Guaranteed demo.
//   - get_weather: live data the model cannot know from training. When the
//     agent answers with the real current temperature, attendees see it
//     reached OUTSIDE the chat. That is the point of tools.
//
// Speaks MCP over stdio (newline-delimited JSON-RPC 2.0). Registered with the
// agent in scripts/patch-config.js.
"use strict";

const TOOLS = [
  {
    name: "roll_dice",
    description:
      "Roll real dice and return the results. Use whenever the user asks to " +
      "roll dice, flip for it, or wants a random number from dice.",
    inputSchema: {
      type: "object",
      properties: {
        sides: { type: "integer", description: "Sides per die (default 6)" },
        count: { type: "integer", description: "How many dice (default 1, max 20)" },
      },
    },
  },
  {
    name: "get_weather",
    description:
      "Get the CURRENT, live weather for a city (via the free Open-Meteo " +
      "API, no key needed). Use whenever the user asks about weather right now.",
    inputSchema: {
      type: "object",
      properties: {
        city: { type: "string", description: "City name, e.g. 'St. John\\'s'" },
      },
      required: ["city"],
    },
  },
];

function rollDice(args) {
  const sides = Math.max(2, Math.min(1000, Math.trunc(args.sides || 6)));
  const count = Math.max(1, Math.min(20, Math.trunc(args.count || 1)));
  const rolls = Array.from({ length: count }, () => 1 + Math.floor(Math.random() * sides));
  const total = rolls.reduce((a, b) => a + b, 0);
  return `Rolled ${count}d${sides}: [${rolls.join(", ")}] (total ${total})`;
}

async function getWeather(args) {
  const city = String(args.city || "").trim();
  if (!city) return "No city given. Ask the user which city they mean.";
  const geoUrl =
    "https://geocoding-api.open-meteo.com/v1/search?count=1&name=" +
    encodeURIComponent(city);
  const geo = await (await fetchWithTimeout(geoUrl)).json();
  const place = geo && geo.results && geo.results[0];
  if (!place) return `Could not find a city called "${city}".`;
  const wxUrl =
    "https://api.open-meteo.com/v1/forecast?current_weather=true" +
    `&latitude=${place.latitude}&longitude=${place.longitude}`;
  const wx = await (await fetchWithTimeout(wxUrl)).json();
  const cur = wx && wx.current_weather;
  if (!cur) return `Found ${place.name}, but no weather came back. Try again.`;
  return (
    `Current weather in ${place.name}, ${place.country_code || ""}: ` +
    `${cur.temperature}°C, wind ${cur.windspeed} km/h ` +
    `(live from open-meteo.com at ${cur.time})`
  );
}

function fetchWithTimeout(url) {
  return fetch(url, { signal: AbortSignal.timeout(6000) });
}

// ---- minimal MCP-over-stdio plumbing --------------------------------------

function send(msg) {
  process.stdout.write(JSON.stringify(msg) + "\n");
}

async function handle(req) {
  const { id, method, params } = req;
  if (method === "initialize") {
    send({
      jsonrpc: "2.0",
      id,
      result: {
        // Echo the client's protocol version; this server's surface is tiny
        // and stable across MCP revisions.
        protocolVersion: (params && params.protocolVersion) || "2025-06-18",
        capabilities: { tools: {} },
        serverInfo: { name: "workshop-tools", version: "1.0.0" },
      },
    });
  } else if (method === "tools/list") {
    send({ jsonrpc: "2.0", id, result: { tools: TOOLS } });
  } else if (method === "tools/call") {
    const name = params && params.name;
    const args = (params && params.arguments) || {};
    let text, isError = false;
    try {
      if (name === "roll_dice") text = rollDice(args);
      else if (name === "get_weather") text = await getWeather(args);
      else { text = `Unknown tool: ${name}`; isError = true; }
    } catch (e) {
      text = `Tool failed (this is fine, tell the user): ${e.message}`;
      isError = true;
    }
    send({
      jsonrpc: "2.0",
      id,
      result: { content: [{ type: "text", text }], isError },
    });
  } else if (id !== undefined && id !== null) {
    // Any other *request* gets a polite "not supported" (notifications are
    // simply ignored, per JSON-RPC).
    send({
      jsonrpc: "2.0",
      id,
      error: { code: -32601, message: `Method not supported: ${method}` },
    });
  }
}

let buffer = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => {
  buffer += chunk;
  let nl;
  while ((nl = buffer.indexOf("\n")) !== -1) {
    const line = buffer.slice(0, nl).trim();
    buffer = buffer.slice(nl + 1);
    if (!line) continue;
    let req;
    try { req = JSON.parse(line); } catch { continue; }
    handle(req).catch(() => {});
  }
});
// No explicit exit: when the MCP client closes stdin, any in-flight tool call
// finishes (its response may land in the void), the event loop drains, and
// the process ends on its own. Forcing process.exit() here loses in-flight
// replies and trips a libuv assertion on Windows.
