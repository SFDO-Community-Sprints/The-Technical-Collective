# Next-version site prototype (WIP)

A **work-in-progress** prototype of a redesigned landing page for The Technical Collective.

This is intentionally separate from the live documentation site (`files/docs/`, built with
MkDocs). It explores a modern, marketing-style landing page as a possible "next version."

## Status
🚧 Prototype / for review — **not** the live site, and not wired into the deploy.

## How to view it
It's a single self-contained HTML file (Tailwind via CDN, no build step). Either:

- Open `prototype/index.html` directly in a browser, or
- Serve the folder: `python3 -m http.server -d prototype 8001` → http://127.0.0.1:8001

## What it reuses from the current site
- Brand: logo, favicon, indigo/cyan palette, Inter typeface
- Content: mission copy, the three role descriptions, steering-committee names
- The "Get involved" buttons link out to the existing role pages on the live site

## Design direction
Clean & modern: hero → role cards → how-it-works → team → call-to-action.
