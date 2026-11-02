# BADDEL — Phase 1 starter

A Next.js + Supabase foundation for an Algerian peer-to-peer marketplace for selling, buying, and exchanging products.

## Included in this phase

- Next.js App Router + TypeScript scaffold
- Arabic RTL responsive landing page
- Initial login/register page placeholders (not wired to Auth yet)
- Supabase browser/server clients and Next.js 16 `proxy.ts` session refresh
- Initial PostgreSQL schema, RLS policies, and private image bucket
- Basic category seed data

## Not implemented yet

Authentication forms, real listing CRUD, upload flows, search, messaging, exchange workflows, moderation UI, admin dashboard, notifications, reviews, payments, and verified transaction workflows are later phases. The homepage product cards are explicitly demo placeholders.

## Requirements

- Node.js 20.9+ (use a current supported LTS)
- npm
- A Supabase project

## Run locally

```bash
npm install
cp .env.example .env.local
```

Fill `.env.local` with the Project URL and Publishable key from Supabase Project Settings → API Keys / Connect. Do not put a secret/service-role key in a `NEXT_PUBLIC_` variable.

Apply the database migration:
1. Open Supabase Dashboard → SQL Editor.
2. Run `supabase/migrations/0001_initial_schema.sql`.
3. Run `supabase/seed.sql`.

Then:

```bash
npm run dev
```

Open http://localhost:3000.

## Important security review before production

This is a foundation migration, not a completed security audit. In particular:
- Review all RLS policies against real user journeys.
- Restrict profile columns exposed publicly; currently signed-in users can read profile rows, so do not store sensitive personal data in public profile columns.
- Add transactional RPCs for creating conversations and accepting/rejecting exchange offers. Direct conversation and membership inserts are intentionally disabled in this phase.
- Keep conversation membership creation server-controlled through a validated database function; never allow users to self-join arbitrary conversations.
- Add immutable audit logging for privileged operations.
- Add moderation workflow and content policy enforcement.
- Re-review storage policies and signed-URL behavior against the final listing-image upload flow.
- Restrict profile data further before launch; public-facing profile fields should not contain sensitive contact details.
- Add CAPTCHA/rate limits to signup, messaging, listing creation, and reports.
- Seed and validate official wilaya/commune data.
- Add integration tests for every RLS policy.
- Configure email templates, allowed redirect URLs, backups, monitoring, and production domains.

## Architecture decisions

- `src/app/(marketplace)` will hold public marketplace routes.
- `src/app/(auth)` will hold sign-in and sign-up routes.
- `src/app/admin` is a distinct admin application area within the same Next.js deployment.
- Admin authorization must be checked on the server and in database RLS. Hiding the admin URL is not security.
- Use the publishable Supabase key in browser/server SSR clients. Never expose a secret/service-role key to the browser.
- Payments are intentionally out of scope for the first release.
