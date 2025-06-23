# How to Contribute to This Website

Hello, collaborator! This guide will show you how to easily edit and manage the content on our website directly from GitHub.

---

### Editing Page Content

All of our website pages are simple text files called Markdown files (they end in `.md`). You can find them all inside the `files/docs/` directory.

**To edit a page:**

1.  Navigate to the file you want to edit in the `files/docs/` directory.
2.  Click the **pencil icon** (✏️) in the top-right corner of the file view.
3.  Make your changes using Markdown syntax (e.g., `#` for a heading, `*` for a bullet point).
4.  When you're done, scroll down and click the **"Commit changes"** button. This saves your work and automatically updates the live website.

---

### Changing the Website's Navigation

The order and structure of the pages in the left sidebar are controlled by a single file: `files/docs/.pages`. Think of this file as the master table of contents for the site.

**How it works:**

The `.pages` file has a section called `arrange:` which is a simple list of the files and folders that appear in the navigation.

**To reorder pages:**

Simply change the order of the filenames in the `arrange:` list. The sidebar will update to match the new order.

**To create sections (like the "Roles" section):**

1.  **Create a Folder:** In the `files/docs/` directory, create a new folder.
2.  **Move Files:** Move the `.md` pages you want to group into that new folder.
3.  **Update the `.pages` file:** In the `arrange:` list, replace the individual filenames with the name of your new folder.

The website will automatically create a new, expandable section in the sidebar with the same name as your folder. It's that simple!
