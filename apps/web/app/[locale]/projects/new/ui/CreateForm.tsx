"use client";
import { useRouter, useParams } from "next/navigation";
import { useState } from "react";

export default function CreateForm(){
  const router = useRouter();
  const { locale } = useParams<{locale: string}>();
  const [name,setName]=useState("");
  const [description,setDescription]=useState("");

  async function submit(e:React.FormEvent){
    e.preventDefault();
    await fetch(`${process.env.NEXT_PUBLIC_API_BASE}/projects`, {
      method:"POST",
      headers:{
        "content-type":"application/json",
        authorization:`Bearer ${process.env.NEXT_PUBLIC_DEMO_ID_TOKEN ?? ""}`
      },
      body: JSON.stringify({ name, description })
    });
    router.push(`/${locale}/projects`);
  }

  return (
    <form onSubmit={submit} style={{ display: "grid", gap: "0.5rem" }}>
      <input value={name} onChange={e=>setName(e.target.value)} placeholder="Name" required />
      <textarea value={description} onChange={e=>setDescription(e.target.value)} placeholder="Description"/>
      <button type="submit">Save</button>
    </form>
  );
}
