# Salesforce — Technical Collective form intake

Server side for the website application forms. The static site (GitHub Pages)
posts form submissions to a **public Salesforce Site** endpoint, which creates
records in the **Technical Collective** org. No credentials live in the website
or this repo — the logic runs server-side as a locked-down Site Guest User.

## What's here (`tc-forms/force-app/main/default/`)
- `classes/TC_FormIntake.cls` — `@RestResource` at `/services/apexrest/tc/intake`.
  - `formType: "charity"` → creates an **Account + Contact**.
  - `formType: "professional"` → creates a **Contact**.
  - Core fields map to standard fields; other answers are stored in `Description`.
  - Honeypot field `website_url2` silently drops bot submissions.
- `classes/TC_FormIntakeTest.cls` — tests (7, all passing).
- `pages/TC_FormSiteHome.page` — placeholder home page for the Site.
- `sites/TCForms.site-meta.xml` — the public Visualforce Site (`/forms`).
- `permissionsets/TC_Form_Guest.permissionset-meta.xml` — guest user access:
  **create-only** on Account/Contact + run the Apex class. No read*/edit/delete.
- `corsWhitelistOrigins/` — allows the GitHub Pages origin to call the endpoint.

## Live endpoint
`https://technicalcollective.my.salesforce-sites.com/forms/services/apexrest/tc/intake`

## Deploy / re-deploy
```
cd salesforce/tc-forms
sf project deploy start --target-org formint \
  --source-dir force-app --test-level RunSpecifiedTests --tests TC_FormIntakeTest
```
The guest-user permission-set assignment is a one-time step (already done).

## Notes
- This is a **production** org — submissions create real records.
- To add a new allowed website origin, add another file under
  `corsWhitelistOrigins/` and deploy.
