import type { Context, Next } from "hono";
import { auth } from "../lib/firebaseAdmin.js";

export async function requireAuth(c: Context, next: Next) {
  const h = c.req.header("authorization");
  if (!h?.startsWith("Bearer ")) return c.text("Unauthorized", 401);
  const token = h.slice(7);
  try {
    const decoded = await auth.verifyIdToken(token);
    c.set("uid", decoded.uid);
    await next();
  } catch {
    return c.text("Unauthorized", 401);
  }
}
