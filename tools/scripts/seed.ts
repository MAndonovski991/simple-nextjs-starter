#!/usr/bin/env tsx
import admin from "firebase-admin";

if (!admin.apps.length) {
  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    const svc = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    admin.initializeApp({ credential: admin.credential.cert(svc) });
  } else {
    admin.initializeApp({ credential: admin.credential.applicationDefault() });
  }
}

const db = admin.firestore();

async function main() {
  const batch = db.batch();
  const col = db.collection("projects");
  for (let i = 1; i <= 5; i++) {
    const ref = col.doc();
    batch.set(ref, {
      name: `Project ${i}`,
      description: `Demo ${i}`,
      createdAt: new Date().toISOString()
    });
  }
  await batch.commit();
  console.log("Seeded projects ✓");
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
