async function fetchProject(id: string){
  const res = await fetch(`${process.env.NEXT_PUBLIC_API_BASE}/projects/${id}`, {
    headers: { authorization: `Bearer ${process.env.DEMO_ID_TOKEN ?? ""}` },
    cache: "no-store"
  });
  if (!res.ok) return null;
  return res.json();
}

export default async function ProjectPage({ params }: { params: { id: string, locale: string } }){
  const p = await fetchProject(params.id);
  if(!p) return <div>Not found</div>;

  async function remove() {
    "use server";
    await fetch(`${process.env.NEXT_PUBLIC_API_BASE}/projects/${p.id}`, {
      method: "DELETE",
      headers: { authorization: `Bearer ${process.env.DEMO_ID_TOKEN ?? ""}` }
    });
  }

  return (
    <div>
      <h2>{p.name}</h2>
      <p>{p.description}</p>
      <form action={remove}><button>Delete</button></form>
    </div>
  );
}
