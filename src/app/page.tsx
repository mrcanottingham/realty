import { redirect } from 'next/navigation';
import { createClient, getUserRole } from '@/lib/supabase/server';

export default async function Home() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  const role = await getUserRole(user.id);
  redirect(role === 'caregiver' ? '/portal' : '/dashboard');
}
