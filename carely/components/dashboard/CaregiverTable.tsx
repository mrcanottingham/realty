import { CaregiverRow } from './CaregiverRow'
import { EmptyState } from './EmptyState'
import type { Caregiver } from '@/lib/mock/caregivers'

interface CaregiverTableProps {
  caregivers: Caregiver[]
}

export function CaregiverTable({ caregivers }: CaregiverTableProps) {
  if (caregivers.length === 0) {
    return <EmptyState />
  }

  return (
    <div className="rounded-xl border border-gray-200 overflow-hidden bg-white">
      {/* Desktop header */}
      <div className="hidden sm:grid grid-cols-[2fr_2fr_1.5fr_1.5fr_auto] px-4 py-3 bg-gray-50 border-b border-gray-200">
        <span className="text-xs font-semibold text-gray-500 uppercase tracking-wider">Name</span>
        <span className="text-xs font-semibold text-gray-500 uppercase tracking-wider">Role</span>
        <span className="text-xs font-semibold text-gray-500 uppercase tracking-wider">Invited</span>
        <span className="text-xs font-semibold text-gray-500 uppercase tracking-wider">Status</span>
        <span className="sr-only">View</span>
      </div>

      <div>
        {caregivers.map((caregiver) => (
          <CaregiverRow key={caregiver.id} caregiver={caregiver} />
        ))}
      </div>
    </div>
  )
}
