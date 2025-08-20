import { Hono } from "hono";
import { handle } from "hono/vercel";
import { mountProjects } from "../../src/routes/projects/index.js";

export const config = { runtime: "nodejs18.x" };

const app = new Hono();
mountProjects(app);
export default handle(app);
