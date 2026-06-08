'use client'

import { useState } from 'react'
import { Sidebar } from '@/components/dashboard/Sidebar'
import { Header } from '@/components/dashboard/Header'
import { usePathname } from 'next/navigation'

function getPageTitle(pathname: string): string {
  if (pathname.includes('/caregivers/') && pathname.split('/').length > 3) return 'Caregiver'
  if (pathname.includes('/caregivers')) return 'Caregivers'
  if (pathname.includes('/settings')) return 'Settings'
  if (pathname.includes('/help')) return 'Help'
  if (pathname.includes('/invite')) return 'Invite Caregiver'
  return 'Dashboard'
}

// TODO: wire to real session — redirect unauthenticated users to /login
function useAuthGuard() {
  // Stub: assume authenticated. Replace with real Supabase session check.
  return { authenticated: true }
}

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const [mobileOpen, setMobileOpen] = useState(false)
  const pathname = usePathname()
  useAuthGuard()

  return (
    <div className="flex h-screen bg-gray-50">
      <Sidebar mobileOpen={mobileOpen} onClose={() => setMobileOpen(false)} />

      <div className="flex flex-col flex-1 min-w-0 overflow-hidden">
        <Header
          title={getPageTitle(pathname)}
          onMenuClick={() => setMobileOpen(true)}
        />
        <main className="flex-1 overflow-y-auto p-6">
          {children}
        </main>
      </div>
    </div>
  )
}
