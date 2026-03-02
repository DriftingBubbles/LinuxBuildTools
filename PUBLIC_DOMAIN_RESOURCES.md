# Public Domain & Open Knowledge Resources

This guide lists reputable sources for **public domain** and openly licensed content you can use in offline libraries, local servers, and educational distributions.

## Quick legal note

- **Public domain** works are generally free to copy, modify, and redistribute.
- Many resources are instead published under **open licenses** (for example, Creative Commons). Always check each item’s license page.
- Laws vary by country, especially for older works and recordings. Verify local rules before redistribution.

---

## Books and Documentation

### Project Gutenberg
- Website: https://www.gutenberg.org/
- What it provides: Public domain ebooks (mostly classics), available in multiple formats.
- Why it matters: One of the largest and oldest curated collections of public domain books.
- Good for: Literature libraries, language reading packs, and offline education bundles.

### Internet Archive (Texts)
- Website: https://archive.org/details/texts
- What it provides: Books, manuals, scans, and historical documents (license varies by item).
- Good for: Historical references, technical manuals, and niche documentation.

### Wikisource
- Website: https://wikisource.org/
- What it provides: Source texts and historical documents, often in the public domain.
- Good for: Primary-source reading collections.

### Standard Ebooks
- Website: https://standardebooks.org/
- What it provides: High-quality, proofread public domain ebooks.
- Good for: Clean ebook collections with consistent formatting.

---

## Encyclopedic and Learning Content

### Wikipedia
- Website: https://www.wikipedia.org/
- License model: Mostly CC BY-SA content (not public domain), with some media under other licenses.
- Why it matters: Broad, continuously updated reference material.
- Offline option: Use Kiwix-compatible dumps for offline access.

### Wikiversity
- Website: https://www.wikiversity.org/
- License model: Primarily open-licensed educational content.
- What it provides: Learning resources, courses, and study materials.
- Good for: Structured self-learning libraries and local educational hubs.

### Wikibooks
- Website: https://www.wikibooks.org/
- What it provides: Open textbooks and instructional material.
- Good for: Curriculum-style offline reference sets.

---

## Music and Audio (Public Domain / Open)

### Musopen
- Website: https://musopen.org/
- What it provides: Public domain classical music, sheet music, and educational recordings.
- Good for: Classical collections and educational use.

### Free Music Archive
- Website: https://freemusicarchive.org/
- What it provides: Music under various open licenses.
- Important: Check the exact license terms per track.

### Internet Archive (Audio)
- Website: https://archive.org/details/audio
- What it provides: Music, spoken word, old-time radio, and field recordings.
- Important: License/public-domain status depends on each upload.

### Wikimedia Commons (Audio)
- Website: https://commons.wikimedia.org/wiki/Category:Audio_files
- What it provides: Audio files with license metadata.
- Good for: Reusable clips with visible attribution/license details.

---

## Practical selection checklist

When adding items to your local/offline library:

1. Confirm the item’s license or public-domain status.
2. Save source URL and license text/metadata alongside the file.
3. Prefer sources with clear provenance and moderation.
4. Keep a small manifest (CSV/JSON/Markdown) of title, source, and license.

### Attribution template

Use this minimal template in your `SOURCES.md` or `LICENSES.md`:

```text
Title:
Author/Publisher:
Source URL:
License:
Attribution required: Yes/No
Date accessed:
Notes:
```

---

## Suggested use with this repository

- Use the download/sync scripts in this repo to cache content and package your environment.
- Pair this guide with Kiwix-based offline knowledge sets for Wikipedia and educational resources.
- Keep a `SOURCES.md` or `LICENSES.md` file for each content bundle you distribute.
