import type { Context } from "hono";
import { firestore } from "../../lib/firebaseAdmin.js";

export async function getProject(c: Context) {
  const id = c.req.param("id");
  const doc = await firestore.collection("projects").doc(id).get();
  if (!doc.exists) return c.text("Not found", 404);
  return c.json({ id: doc.id, ...doc.data() });
}
