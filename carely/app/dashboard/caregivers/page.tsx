import { CaregiverTable } from '@/components/dashboard/CaregiverTable'
import { mockCaregivers } from '@/lib/mock/caregivers'

export default function CaregiversPage() {
  return <CaregiverTable caregivers={mockCaregivers} />
}
