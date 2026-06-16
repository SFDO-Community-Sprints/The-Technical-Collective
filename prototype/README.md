# Next-version site prototype (WIP)

A **work-in-progress** prototype of a redesigned, multi-page site for The Technical Collective.

This is intentionally separate from the live documentation site (`files/docs/`, built with
MkDocs). It explores a modern, marketing-style design as a possible "next version" — fully
self-contained, with no links back to the current live site, so it can be shared as a
standalone working prototype.

## Status
🚧 Prototype / for review — **not** the live site, and not wired into the deploy.

## Pages
- `index.html` — home: hero (with animated Astro), role teasers, how-it-works, community buzz, team, CTA
- `roles/charity-nonprofit.html` — full nonprofit page
- `roles/junior-professional.html` — full junior professional page
- `roles/technical-expert.html` — full technical expert page
- `promises-expectations.html` — the promises between all three groups
- `faq.html` — full FAQ (expandable sections)

All pages share a header (with working mobile menu), footer, and the brand styling.
"Apply" buttons link to the real Google Form applications; the FAQ/expert pages link to
the project email.

## Featuring LinkedIn posts ("Community buzz")
The homepage has a curated **Community buzz** section that shows real, embedded LinkedIn
posts. To feature one, edit a single file — `assets/community-posts.js` — and paste the
post's official embed code (on the post: `···` → **"Embed this post"**). Step-by-step
instructions are at the top of that file; no coding needed, and it can be done straight
from GitHub's web editor. The section hides itself automatically when the list is empty,
so it never shows a broken/empty block. For safety, only genuine
`www.linkedin.com/embed/...` links are rendered — anything else is ignored.

## How to view it
Single self-contained HTML pages (Tailwind via CDN, no build step). Either:

- Open `prototype/index.html` directly in a browser, or
- Serve the folder: `python3 -m http.server -d prototype 8001` → http://127.0.0.1:8001

## What it reuses from the current site
- Brand: logo, favicon, indigo/cyan palette, Inter typeface
- Content: real copy for every page (mission, roles, promises, FAQ)
- Team: real Slack profile photos (5 of 6; initials fallback for any missing)
- Icons: Salesforce Lightning Design System (CC BY-ND 4.0)
- Hero animation: Astro, the Salesforce mascot (transparent WebM/HEVC)

## Design direction
Clean & modern, multi-page. Lean homepage that points to detail pages rather than
holding all the content itself.
