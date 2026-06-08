import Link from 'next/link'

export function EmptyState() {
  return (
    <div className="flex flex-col items-center justify-center py-24 px-6">
      {/* Implied table skeleton */}
      <div className="w-full max-w-md mb-10 space-y-2 opacity-20 pointer-events-none select-none" aria-hidden>
        {[...Array(4)].map((_, i) => (
          <div key={i} className="h-10 rounded-lg bg-gray-200 w-full" />
        ))}
      </div>

      <div className="text-center max-w-sm">
        <h2 className="text-lg font-semibold text-gray-900">No caregivers yet</h2>
        <p className="mt-1.5 text-sm text-gray-500">
          Invite your first caregiver to start their onboarding.
        </p>
        <div className="mt-6">
          <Link
            href="/dashboard/invite"
            className="inline-flex items-center rounded-lg bg-indigo-600 px-4 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 transition-colors"
          >
            Invite a Caregiver
          </Link>
        </div>
      </div>
    </div>
  )
}
