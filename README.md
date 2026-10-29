# PetBook Pro

Multilingual landing-page prototype (English, Armenian, Russian), built with Next.js App Router and TypeScript.

## Local development

```bash
npm install
npm run dev
```

Visit http://localhost:3000, or `/en`, `/hy`, `/ru`.

## Verification

```bash
npm run lint
npm run build
```

GitHub Actions runs these checks on pull requests.

## Deployment

After reviewing and merging the pull request, import `Sedrak49/petbook-pro` into Vercel. Select the Next.js framework preset. No environment variables are needed for the landing page.

## Limitations

This is a **public UI prototype only**. It does not implement accounts, real pet profiles, pedigree validation, veterinary records, payments, or a database. Do not enter sensitive personal or medical information.
