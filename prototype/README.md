# Public Site Prototype

This folder contains the static HTML site served at the GitHub Pages root.
The original MkDocs documentation site (`files/docs/`) is still built and published under
`/docs/`.

## Status
Published by `.github/workflows/pages.yml` on pushes to `main`.

## Pages
- `index.html` — home: hero (with animated Astro), role teasers, how-it-works, LinkedIn posts, team, CTA
- `roles/charity-nonprofit.html` — full nonprofit page
- `roles/junior-professional.html` — full junior professional page
- `roles/technical-expert.html` — full technical expert page
- `promises-expectations.html` — the promises between all three groups
- `faq.html` — full FAQ (expandable sections)

All pages share a header, mobile menu, footer, brand styling, and the shared motion layer
in `assets/motion.css` and `assets/tc-motion.js`. Role-page apply buttons open the local
application modal rendered by `assets/tc-forms.js`.

## Featuring LinkedIn posts ("Straight from our LinkedIn")
The homepage has a curated section showing real, embedded posts from The Technical
Collective's own LinkedIn, in a compact swipeable carousel.
To feature one, edit a single file — `assets/community-posts.js` — and paste the
post's official embed code (on the post: `···` → **"Embed this post"**). Step-by-step
instructions are at the top of that file; no coding needed, and it can be done straight
from GitHub's web editor. The section hides itself automatically when the list is empty,
so it never shows a broken/empty block. For safety, only genuine
`www.linkedin.com/embed/...` links are rendered — anything else is ignored.

## How to view it
Static HTML pages with local CSS/JS assets. Either:

- Open `prototype/index.html` directly in a browser, or
- Serve the folder: `python3 -m http.server -d prototype 8001` → http://127.0.0.1:8001

Tailwind is built into `assets/tailwind.css`. If Tailwind classes change, rebuild it from
the repository root:

```bash
npx --yes tailwindcss@3.4.17 -c prototype/tailwind.config.js -i prototype/assets/tailwind-input.css -o prototype/assets/tailwind.css --minify
```

## What it reuses from the current site
- Brand: logo, favicon, indigo/cyan palette, Inter typeface
- Content: real copy for every page (mission, roles, promises, FAQ)
- Team: real Slack profile photos (5 of 6; initials fallback for any missing)
- Icons: Salesforce Lightning Design System (CC BY-ND 4.0)
- Hero animation: Astro, the Salesforce mascot (transparent WebM/HEVC)

## Design direction
Clean & modern, multi-page. Lean homepage that points to detail pages rather than
holding all the content itself.
