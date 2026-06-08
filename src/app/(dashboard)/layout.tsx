import { redirect } from 'next/navigation';
import { createClient, getUserRole } from '@/lib/supabase/server';

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  const role = await getUserRole(user.id);
  if (role !== 'agency_owner') {
    redirect(role === 'caregiver' ? '/portal' : '/login');
  }

  return <>{children}</>;
}
