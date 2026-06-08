import Link from 'next/link'
import { mockCaregivers } from '@/lib/mock/caregivers'
import { notFound } from 'next/navigation'

interface Props {
  params: Promise<{ id: string }>
}

export default async function CaregiverDetailPage({ params }: Props) {
  const { id } = await params
  const caregiver = mockCaregivers.find((c) => c.id === id)

  if (!caregiver) notFound()

  return (
    <div className="max-w-2xl">
      <Link
        href="/dashboard/caregivers"
        className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-gray-900 transition-colors mb-6"
      >
        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" strokeWidth={2} stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 19.5L8.25 12l7.5-7.5" />
        </svg>
        Back to Caregivers
      </Link>

      <h2 className="text-2xl font-bold text-gray-900">
        {caregiver.firstName} {caregiver.lastName}
      </h2>

      <p className="mt-6 text-sm text-gray-500 bg-white border border-gray-200 rounded-xl px-5 py-4">
        Full caregiver record — coming in a later phase.
      </p>
    </div>
  )
}
