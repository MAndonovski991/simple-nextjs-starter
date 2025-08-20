import type { Context } from "hono";
import { firestore } from "../../lib/firebaseAdmin.js";
import { ProjectCreate } from "../../schemas/project.js";

export async function createProject(c: Context) {
  const body = await c.req.json();
  const parsed = ProjectCreate.parse(body);
  const createdAt = new Date().toISOString();
  const ref = await firestore.collection("projects").add({ ...parsed, createdAt });
  return c.json({ id: ref.id }, 201);
}
