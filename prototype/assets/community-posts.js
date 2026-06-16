/* =============================================================================
   COMMUNITY BUZZ — the posts shown in the "Community buzz" section of the home
   page. This is the ONE file the team edits to feature LinkedIn posts.

   ---------------------------------------------------------------------------
   HOW TO ADD A POST (no coding needed — about 2 minutes)
   ---------------------------------------------------------------------------
   1. On LinkedIn, open the post that mentions The Technical Collective.
   2. Copy its web address (URL). The easy way: click the "···" menu on the
      post  →  "Copy link to post".
   3. Add a new block to the list below, between the [ and ] brackets. Copy an
      existing block, paste it, and change the values. Each block looks like:

          {
            url:    "https://www.linkedin.com/posts/...",   // the post link (required)
            author: "Jane Doe",                              // who wrote it
            title:  "Salesforce Admin at Acme",              // their role / handle
            date:   "Jun 2026",                              // when (any short text)
            quote:  "Loved working with The Technical ...",  // a short excerpt
          },

   4. Keep the comma at the end of each block.
   5. Save / commit the file. The site rebuilds automatically in ~1 minute and
      your post appears.

   TIPS
   • Newest posts go at the TOP of the list — they show first.
   • Keep "quote" to a sentence or two so the cards stay tidy.
   • "title" and "date" are optional; "url" and "quote" matter most.
   • Only PUBLIC posts should be featured here.
   • To remove a post, delete its whole { ... }, block.
   ============================================================================= */

window.TC_COMMUNITY_POSTS = [

  // ⤵︎  Add new posts here (newest first). Remove these examples once you have
  //     real ones — they're just here to show the format and the layout.

  {
    url:    "https://www.linkedin.com/company/the-technical-collective/",
    author: "Example Member",
    title:  "Salesforce Administrator",
    date:   "Example",
    quote:  "This is a sample card showing how a featured LinkedIn post looks. Replace it with a real post that mentions The Technical Collective.",
  },
  {
    url:    "https://www.linkedin.com/company/the-technical-collective/",
    author: "Another Volunteer",
    title:  "Technical Architect",
    date:   "Example",
    quote:  "Add posts that @mention or #hashtag The Technical Collective by following the instructions at the top of this file.",
  },

];
