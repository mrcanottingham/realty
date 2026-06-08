import { redirect } from 'next/navigation';
import { createClient, getUserRole } from '@/lib/supabase/server';
import { signOut } from '@/app/actions/auth';

export default async function PortalPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  const role = await getUserRole(user.id);
  if (role !== 'caregiver') {
    redirect(role === 'agency_owner' ? '/dashboard' : '/login');
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex items-center justify-between">
          <h1 className="text-2xl font-bold" style={{ color: '#5B2C91' }}>Luv N Home Care</h1>
          <form action={signOut}>
            <button
              type="submit"
              className="text-sm font-medium px-4 py-2 rounded-lg text-white"
              style={{ backgroundColor: '#5B2C91' }}
            >
              Sign Out
            </button>
          </form>
        </div>
      </header>
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
        <div className="bg-white rounded-2xl shadow p-8">
          <h2 className="text-xl font-semibold text-gray-800 mb-2">Portal</h2>
          <p className="text-gray-500 text-sm">Welcome, {user.email}.</p>
        </div>
      </main>
    </div>
  );
}
