'use server';

import { redirect } from 'next/navigation';
import { createClient, getUserRole } from '@/lib/supabase/server';

export async function signIn(email: string, password: string) {
  const supabase = await createClient();

  const { data, error } = await supabase.auth.signInWithPassword({ email, password });

  if (error) {
    if (error.message.toLowerCase().includes('email not confirmed')) {
      return { error: 'Please confirm your email before logging in.' };
    }
    return { error: error.message };
  }

  const role = await getUserRole(data.user.id);
  redirect(role === 'caregiver' ? '/portal' : '/dashboard');
}

export async function signUp(email: string, password: string, fullName: string) {
  const supabase = await createClient();

  const { error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: { full_name: fullName },
    },
  });

  if (error) return { error: error.message };

  return { success: true };
}

export async function signOut() {
  const supabase = await createClient();
  await supabase.auth.signOut();
  redirect('/login');
}
