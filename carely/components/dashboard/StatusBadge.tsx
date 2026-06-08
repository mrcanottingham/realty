import { getStatusConfig } from '@/lib/status'
import type { CaregiverStatus } from '@/lib/mock/caregivers'

interface StatusBadgeProps {
  status: CaregiverStatus
}

export function StatusBadge({ status }: StatusBadgeProps) {
  const { label, className } = getStatusConfig(status)
  return (
    <span
      className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${className}`}
    >
      {label}
    </span>
  )
}
