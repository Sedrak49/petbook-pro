# PetBook Pro

A Next.js App Router website with Armenian, English and Russian pages. The default entry point is `/hy`.

## Current status

The homepage is public. Routes exist for account access (`/hy/auth`), pets, community, feed, friends, messages and information pages. **The existence of a route does not mean its backend is ready.** Account registration and user-generated content require a configured Supabase project, database tables, storage buckets and appropriate row-level security policies. Do not invite real users to enter personal information until these have been verified.

## Run locally

```bash
npm install
npm run dev
npm run lint
npm run build
```

## Authentication configuration

Set these in Vercel Project Settings → Environment Variables for the relevant environments:

- `NEXT_PUBLIC_SUPABASE_URL` — Supabase project URL.
- `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` — Supabase publishable key, or `NEXT_PUBLIC_SUPABASE_ANON_KEY` for a legacy anon key.

These are browser-exposed keys; **never** put a Supabase service-role key, database password or other private secret into a `NEXT_PUBLIC_` variable. Configure the Supabase Auth site URL and allowed redirect URLs for the deployed domain (including `/hy/auth`, `/en/auth`, and `/ru/auth`). After changing environment variables, a new Vercel deployment is needed.

The application expects these Supabase resources (which must be created and secured separately):

| Resource | Used for |
| --- | --- |
| `pets`, `health_records`, `pet_friendships` | Pet profiles, health history, friend requests |
| `posts`, `comments`, `post_likes` | Social feed |
| `listings` | Community listings |
| `profiles`, `conversations`, `messages` | Messaging |
| `pet-images`, `post-photos` storage buckets | User-uploaded photos |

**Before public launch:** apply and test row-level security on every user-data table and storage bucket. Verify that anonymous users cannot change private records, and that authenticated users can modify only their own records. Test registration, confirmation emails, password reset, pet creation, posts, image uploads, and messaging end-to-end.

## Deployment troubleshooting

The Vercel build-rate limit is an account/deployment quota issue, not a Next.js 404. When Vercel blocks builds, GitHub changes do **not** reach the public website, even if GitHub Actions checks pass. Once builds are available again, deploy the current `main` branch and verify `/hy`, `/hy/auth`, `/hy/my-pets`, `/hy/feed`, `/hy/community`, and `/hy/messages` in the deployed version.

GitHub Actions validates TypeScript and production compilation; it does not verify the live database, Auth redirects or Vercel deployment.
