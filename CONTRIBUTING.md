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

---

### How to Add to the Sprint Gallery

Our "Sprint Gallery" page showcases photos from our past events. Adding a new photo is easy:

1.  **Upload the Image:**
    *   Navigate to the `files/docs/assets/img/` directory in the repository.
    *   Click the **"Add file"** button and choose **"Upload files"**.
    *   Upload your new photo here.

2.  **Add the Image to the Gallery Page:**
    *   Go to the `files/docs/gallery.md` file and click the **pencil icon** (✏️) to edit it.
    *   Inside the `<div class="sprint-gallery-grid">`, copy the following code block:

    ```html
    <figure class="sprint-image">
      <img src="../assets/img/YOUR-IMAGE-FILENAME.jpg" alt="A short description of the image">
      <figcaption>Month Year: A brief caption for the photo.</figcaption>
    </figure>
    ```

    *   **Paste** this block into the grid.
    *   **Replace** `YOUR-IMAGE-FILENAME.jpg` with the actual filename of the photo you uploaded.
    *   **Update** the `alt` text and the `figcaption` to describe the new photo.
    *   **Commit your changes.** The website will automatically update with the new photo, perfectly formatted.
