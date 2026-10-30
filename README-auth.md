# PetBook Pro email authentication

The localized route `/{locale}/auth` supports email/password sign-up, email confirmation, login, sign-out and password reset email initiation using Supabase Auth.

Set these Vercel environment variables and redeploy:
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` (or legacy `NEXT_PUBLIC_SUPABASE_ANON_KEY`)

Use the **publishable** key only. Never expose a Supabase secret/service_role key with `NEXT_PUBLIC_`.

In Supabase Auth URL Configuration set Site URL to `https://petbook-pro.vercel.app`, and add `https://petbook-pro.vercel.app/**` to allowed redirect URLs (or explicitly add /en/auth, /hy/auth, /ru/auth). Email provider must be enabled.

Test: create a new account, confirm email, log in, sign out, request password reset. A password-reset completion UI is not implemented yet; do not advertise end-to-end password reset until it is added. RLS policies will be needed before introducing pet profiles and user data tables.
