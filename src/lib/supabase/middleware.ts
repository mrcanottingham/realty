import { createServerClient } from '@supabase/ssr';
import { NextResponse, type NextRequest } from 'next/server';
import { SUPABASE_URL, SUPABASE_ANON_KEY } from './config';

export async function updateSession(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request });

  const supabase = createServerClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    cookies: {
      getAll() {
        return request.cookies.getAll();
      },
      setAll(cookiesToSet) {
        cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
        supabaseResponse = NextResponse.next({ request });
        cookiesToSet.forEach(({ name, value, options }) =>
          supabaseResponse.cookies.set(name, value, options)
        );
      },
    },
  });

  const { data: { user } } = await supabase.auth.getUser();

  const pathname = request.nextUrl.pathname;
  const isAuthRoute = pathname.startsWith('/login') || pathname.startsWith('/signup');
  const isDashboardRoute = pathname.startsWith('/dashboard');
  const isPortalRoute = pathname.startsWith('/portal');

  if (!user && (isDashboardRoute || isPortalRoute)) {
    const url = request.nextUrl.clone();
    url.pathname = '/login';
    return NextResponse.redirect(url);
  }

  if (user) {
    const { data: profile } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single();

    const role = profile?.role as string | undefined;

    if (isDashboardRoute && role !== 'agency_owner') {
      const url = request.nextUrl.clone();
      url.pathname = role === 'caregiver' ? '/portal' : '/login';
      return NextResponse.redirect(url);
    }

    if (isPortalRoute && role !== 'caregiver') {
      const url = request.nextUrl.clone();
      url.pathname = role === 'agency_owner' ? '/dashboard' : '/login';
      return NextResponse.redirect(url);
    }

    if (isAuthRoute) {
      const url = request.nextUrl.clone();
      url.pathname = role === 'caregiver' ? '/portal' : '/dashboard';
      return NextResponse.redirect(url);
    }
  }

  return supabaseResponse;
}
