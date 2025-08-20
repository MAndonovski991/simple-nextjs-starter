import Link from "next/link";

export default function Home({ params }: { params: { locale: string } }) {
  return (
    <main>
      <h1>Starter</h1>
      <p>This is the Next.js + Hono + Firebase starter.</p>
      <ul>
        <li><Link href={`/${params.locale}/projects`}>Projects</Link></li>
      </ul>
    </main>
  );
}
