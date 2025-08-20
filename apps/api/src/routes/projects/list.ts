import type { Context } from "hono";
import { firestore } from "../../lib/firebaseAdmin.js";

export async function listProjects(c: Context) {
  const snap = await firestore
    .collection("projects")
    .orderBy("createdAt", "desc")
    .limit(50)
    .get();

  return c.json({ data: snap.docs.map((d) => ({ id: d.id, ...d.data() })) });
}
