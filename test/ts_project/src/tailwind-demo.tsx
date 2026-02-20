export function Card({ title, body }: { title: string; body: string }) {
  return (
    <div className="bg-white rounded-lg shadow-md p-6 max-w-sm">
      <h2 className="text-xl font-bold text-gray-900 mb-2">{title}</h2>
      <p className="text-gray-600 text-sm leading-relaxed">{body}</p>
      <button className="mt-4 px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors">
        Read more
      </button>
    </div>
  );
}
