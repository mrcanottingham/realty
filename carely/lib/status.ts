import type { CaregiverStatus } from '@/lib/mock/caregivers'

interface StatusConfig {
  label: string
  className: string
}

const statusMap: Record<CaregiverStatus, StatusConfig> = {
  not_started: {
    label: 'Not Started',
    className: 'bg-gray-100 text-gray-600 ring-1 ring-gray-200',
  },
  in_progress: {
    label: 'In Progress',
    className: 'bg-amber-50 text-amber-700 ring-1 ring-amber-200',
  },
  complete: {
    label: 'Complete',
    className: 'bg-emerald-50 text-emerald-700 ring-1 ring-emerald-200',
  },
  flagged: {
    label: 'Needs Attention',
    className: 'bg-rose-50 text-rose-700 ring-1 ring-rose-200',
  },
}

export function getStatusConfig(status: CaregiverStatus): StatusConfig {
  return statusMap[status]
}
