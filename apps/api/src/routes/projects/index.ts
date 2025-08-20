import { Hono } from "hono";
import { requireAuth } from "../../middleware/auth.js";
import { listProjects } from "./list.js";
import { createProject } from "./create.js";
import { getProject } from "./get.js";
import { updateProject } from "./update.js";
import { removeProject } from "./remove.js";

export function mountProjects(app: Hono) {
  const r = new Hono();
  r.get("/", requireAuth, listProjects);
  r.post("/", requireAuth, createProject);
  r.get("/:id", requireAuth, getProject);
  r.patch("/:id", requireAuth, updateProject);
  r.delete("/:id", requireAuth, removeProject);
  app.route("/projects", r);
}
