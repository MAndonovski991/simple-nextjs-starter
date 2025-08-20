import type { Context } from "hono";
import { firestore } from "../../lib/firebaseAdmin.js";

export async function updateProject(c: Context) {
  const id = c.req.param("id");
  const payload = await c.req.json();
  await firestore.collection("projects").doc(id).set(payload, { merge: true });
  return c.json({ ok: true });
}
