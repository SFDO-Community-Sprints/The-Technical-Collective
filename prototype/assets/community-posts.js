/* =============================================================================
   COMMUNITY BUZZ — the LinkedIn posts shown in the "Community buzz" section of
   the home page. This is the ONE file the team edits to feature posts.

   ---------------------------------------------------------------------------
   HOW TO ADD A POST (no coding needed — about 2 minutes)
   ---------------------------------------------------------------------------
   1. On LinkedIn, open the post that mentions The Technical Collective.
   2. Click the "···" menu on the post  →  "Embed this post".
   3. LinkedIn shows a snippet of code that looks like this:

        <iframe src="https://www.linkedin.com/embed/feed/update/urn:li:share:123..."
                height="634" width="504" frameborder="0" allowfullscreen
                title="Embedded post"></iframe>

      Copy the whole snippet.
   4. Add a new line to the list below, between the [ and ] brackets, like:

        { embed: `<iframe src="https://www.linkedin.com/embed/feed/update/urn:li:share:123..." height="634" width="504" frameborder="0" allowfullscreen title="Embedded post"></iframe>` },

      • Paste LinkedIn's snippet between the back-ticks ` ` .
      • Keep the comma at the end of the line.
   5. Save / commit the file. The site rebuilds automatically in ~1 minute and
      the post appears.

   TIPS
   • Newest posts go at the TOP of the list — they show first.
   • Only PUBLIC posts can be embedded; private posts won't show.
   • To remove a post, delete its whole { ... }, line.
   • For safety, only LinkedIn embed links (www.linkedin.com/embed/...) are shown;
     anything else is ignored automatically.
   ============================================================================= */

window.TC_COMMUNITY_POSTS = [

  // ⤵︎  Add new posts here (newest first).

  { embed: `<iframe src="https://www.linkedin.com/embed/feed/update/urn:li:share:7472317496428052480?collapsed=1" height="634" width="504" frameborder="0" allowfullscreen="" title="Embedded post"></iframe>` },
  { embed: `<iframe src="https://www.linkedin.com/embed/feed/update/urn:li:ugcPost:7472755480403296256?collapsed=1" height="877" width="504" frameborder="0" allowfullscreen="" title="Embedded post"></iframe>` },
  { embed: `<iframe src="https://www.linkedin.com/embed/feed/update/urn:li:share:7232740958155542531?collapsed=1" height="614" width="504" frameborder="0" allowfullscreen="" title="Embedded post"></iframe>` },
  { embed: `<iframe src="https://www.linkedin.com/embed/feed/update/urn:li:share:7204109438209720320?collapsed=1" height="542" width="504" frameborder="0" allowfullscreen="" title="Embedded post"></iframe>` },
  { embed: `<iframe src="https://www.linkedin.com/embed/feed/update/urn:li:share:7204075600104321024?collapsed=1" height="634" width="504" frameborder="0" allowfullscreen="" title="Embedded post"></iframe>` },

];
