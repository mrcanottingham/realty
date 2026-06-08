import Link from 'next/link'
import { StatusBadge } from './StatusBadge'
import type { Caregiver } from '@/lib/mock/caregivers'

interface CaregiverRowProps {
  caregiver: Caregiver
}

function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  })
}

export function CaregiverRow({ caregiver }: CaregiverRowProps) {
  const { id, firstName, lastName, role, invitedAt, status } = caregiver

  return (
    <>
      {/* Desktop row */}
      <Link
        href={`/dashboard/caregivers/${id}`}
        className="hidden sm:grid grid-cols-[2fr_2fr_1.5fr_1.5fr_auto] items-center px-4 py-3.5 border-b border-gray-100 hover:bg-gray-50 transition-colors cursor-pointer group"
      >
        <span className="text-sm font-medium text-gray-900">
          {firstName} {lastName}
        </span>
        <span className="text-sm text-gray-500">{role}</span>
        <span className="text-sm text-gray-500">{formatDate(invitedAt)}</span>
        <span>
          <StatusBadge status={status} />
        </span>
        <span className="text-gray-400 group-hover:text-gray-600 transition-colors pl-4">
          <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" strokeWidth={2} stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" d="M8.25 4.5l7.5 7.5-7.5 7.5" />
          </svg>
        </span>
      </Link>

      {/* Mobile card */}
      <Link
        href={`/dashboard/caregivers/${id}`}
        className="flex sm:hidden flex-col gap-1.5 px-4 py-4 border-b border-gray-100 hover:bg-gray-50 transition-colors"
      >
        <div className="flex items-center justify-between">
          <span className="text-sm font-medium text-gray-900">
            {firstName} {lastName}
          </span>
          <StatusBadge status={status} />
        </div>
        <div className="flex items-center justify-between">
          <span className="text-xs text-gray-500">{role}</span>
          <span className="text-xs text-gray-400">Invited {formatDate(invitedAt)}</span>
        </div>
      </Link>
    </>
  )
}
