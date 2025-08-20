import Link from "next/link";

async function fetchProjects() {
  const res = await fetch(`${process.env.NEXT_PUBLIC_API_BASE}/projects`, {
    headers: { authorization: `Bearer ${process.env.DEMO_ID_TOKEN ?? ""}` },
    next: { tags: ["projects"], revalidate: 60 }
  });
  return res.json();
}

export default async function ProjectsPage({ params }: { params: { locale: string } }) {
  const { data } = await fetchProjects();
  return (
    <main>
      <h1>Projects</h1>
      <p><Link href={`/${params.locale}/projects/new`}>Create</Link></p>
      <ul>
        {data?.map((p: any) => (
          <li key={p.id}>
            <Link href={`/${params.locale}/projects/${p.id}`}>{p.name}</Link>
          </li>
        ))}
      </ul>
    </main>
  );
}
