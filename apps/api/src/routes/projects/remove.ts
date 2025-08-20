import type { Context } from "hono";
import { firestore } from "../../lib/firebaseAdmin.js";

export async function removeProject(c: Context) {
  const id = c.req.param("id");
  await firestore.collection("projects").doc(id).delete();
  return c.json({ ok: true });
}
