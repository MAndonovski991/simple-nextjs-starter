import { Hono } from "hono";
import { serve } from "@hono/node-server";
import { cors } from "hono/cors";
import { mountProjects } from "./routes/projects/index.js";

export function buildApp() {
  const app = new Hono();
  app.use("*", cors()); // allow cross-origin for local dev
  app.get("/health", (c) => c.text("ok"));
  mountProjects(app);
  return app;
}

if (typeof require !== "undefined" && require.main === module) {
  const app = buildApp();
  const port = Number(process.env.PORT) || 8787;
  serve({ fetch: app.fetch, port });
  console.log(`API listening on http://localhost:${port}`);
}
