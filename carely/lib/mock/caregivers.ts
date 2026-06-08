export type CaregiverStatus = 'not_started' | 'in_progress' | 'complete' | 'flagged'

export interface Caregiver {
  id: string
  firstName: string
  lastName: string
  role: string
  invitedAt: string // ISO date string
  status: CaregiverStatus
}

export const mockCaregivers: Caregiver[] = [
  {
    id: '1',
    firstName: 'Maria',
    lastName: 'Santos',
    role: 'Home Health Aide',
    invitedAt: '2025-05-12T10:00:00Z',
    status: 'complete',
  },
  {
    id: '2',
    firstName: 'James',
    lastName: 'Okafor',
    role: 'Certified Nursing Assistant',
    invitedAt: '2025-05-18T14:30:00Z',
    status: 'in_progress',
  },
  {
    id: '3',
    firstName: 'Priya',
    lastName: 'Nair',
    role: 'Home Health Aide',
    invitedAt: '2025-05-22T09:15:00Z',
    status: 'flagged',
  },
  {
    id: '4',
    firstName: 'Derek',
    lastName: 'Washington',
    role: 'Personal Care Aide',
    invitedAt: '2025-05-28T11:00:00Z',
    status: 'not_started',
  },
  {
    id: '5',
    firstName: 'Lena',
    lastName: 'Kowalski',
    role: 'Home Health Aide',
    invitedAt: '2025-06-01T16:00:00Z',
    status: 'in_progress',
  },
  {
    id: '6',
    firstName: 'Tomás',
    lastName: 'Rivera',
    role: 'Certified Nursing Assistant',
    invitedAt: '2025-06-03T08:45:00Z',
    status: 'not_started',
  },
  {
    id: '7',
    firstName: 'Angela',
    lastName: 'Fitzpatrick',
    role: 'Personal Care Aide',
    invitedAt: '2025-06-05T13:20:00Z',
    status: 'flagged',
  },
]
