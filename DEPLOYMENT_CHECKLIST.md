# PetBook Pro release checklist (not yet production-ready)

## Current scope
- `/[locale]/auth`: email sign-up, login, logout, password reset (hy/en/ru).
- `/[locale]/community`: create/list pets, posts and listings.
- `/[locale]/my-pets`: edit owned pet details and record private visits/vaccinations.
- Supabase schema includes further tables for pedigree, comments, follows, conversations and messages; **having a table does not mean the feature has a working user interface**.

## Required deployment sequence
1. In the **correct** Supabase project, back up data, then apply SQL in this exact order:
   - `supabase/migrations/20261030_platform_foundation.sql`
   - `supabase/migrations/20261030_platform_rls.sql`
   - `supabase/migrations/20261030_signup_profile.sql`
2. Verify all tables have RLS enabled and policies applied. Review role-changing trigger and service-role privileges.
3. In Vercel configure `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` in **Preview and Production** as needed. Never place a secret/service-role key in a `NEXT_PUBLIC_` variable.
4. In Supabase Auth configure Site URL, allowed redirect URLs for /hy/auth, /en/auth, /ru/auth and preview URLs used for testing, and email provider/SMTP.
5. Run `npm install`, `npm run lint`, `npm run build` and test preview deployment. CI and Vercel checks must be green.
6. Smoke-test sign-up/email confirmation/login/logout/password recovery, then creating pets/posts/listings, editing pet data, creating health records, and reading them back after refresh.
7. Verify anonymous users cannot create data; account A cannot edit/delete account B's records; account B cannot read account A's health records or private pets.
8. Do **not** merge the draft PR or deploy to production until tests pass and the missing functionality is addressed.

## Not implemented / not verified
- Pet image upload and storage policies; document uploads.
- Pedigree editing and validation UI.
- Comments/follows, chat, notifications and reminders.
- Moderation/admin screens, service provider profiles, advanced search.
- Automated integration/e2e tests, accessibility and security QA.
- End-to-end production sign-up and persistence; no production DB access has been used to verify it.
