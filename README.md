# Manga Downloader & PDF Converter

A Python-based tool to download manga chapters from MangaPill.com and convert them into PDF files.

## Quick Start (macOS)

```bash
# Navigate to where you want to save manga (can be anywhere)
cd ~/Downloads  # or any folder you prefer

# Clone the repository
git clone <your-repo-url>
cd <repo-name>

# Create and activate virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Edit manga_downloader.py to set MANGA_ID and MANGA_SLUG (see Configuration section)

# Download chapters (example: chapters 100-110)
python3 manga_downloader.py -r 100 110

# Convert to PDFs
python3 manga_to_pdf.py -f .

# Deactivate when done
deactivate
```

## Features

- 📥 Download manga chapters as individual images
- 📚 Convert chapter folders to PDF files
- 🔄 Automatic retry for failed downloads
- 🛡️ Cloudflare bypass using cloudscraper
- 📊 Download summary with failed downloads report
- 🎯 Support for decimal chapters (e.g., 103.5)
- 🖼️ Multiple image format support (JPG, PNG, WebP)

## Prerequisites

- Python 3.7 or higher
- Internet connection
- macOS, Linux, or Windows

## Installation

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd <repo-name>
```

### 2. Create a Virtual Environment

**macOS/Linux:**
```bash
python3 -m venv .venv
source .venv/bin/activate
```

**Windows:**
```bash
python -m venv .venv
.venv\Scripts\activate
```

### 3. Install Required Packages

The scripts will auto-install missing packages when run, but you can manually install them:

```bash
pip install requests beautifulsoup4 lxml cloudscraper Pillow
```

## Usage

### Manga Downloader

#### Configuration

Before downloading, edit the top of `manga_downloader.py` to set your target manga:

```python
MANGA_ID = "2035"        # Found in the manga URL
MANGA_SLUG = "jigokuraku"  # Found in the manga URL
```

**How to find these values:**

Visit the manga chapter page on MangaPill.com. The URL structure is:
```
https://mangapill.com/chapters/{MANGA_ID}-10{chapter}000/{MANGA_SLUG}-chapter-{chapter}
```

Example: `https://mangapill.com/chapters/2035-10103000/jigokuraku-chapter-103`
- `MANGA_ID` = `2035`
- `MANGA_SLUG` = `jigokuraku`

#### Download Commands

**Download a single chapter:**
```bash
python manga_downloader.py -c 103
```

**Download multiple specific chapters:**
```bash
python manga_downloader.py -c 103 -c 104 -c 105
```

**Download a range of chapters:**
```bash
python manga_downloader.py -r 103 110
```

**Download decimal chapters:**
```bash
python manga_downloader.py -c 103.5
```

**Specify custom output directory:**
```bash
python manga_downloader.py -c 103 -o ~/Downloads/manga
```

#### Output Structure

Downloaded chapters are saved in folders named:
```
{manga_slug}_Chapter_{number}/
  page_001.jpg
  page_002.jpg
  ...
```

Example: `jigokuraku_Chapter_103/`

### PDF Converter

After downloading chapters, convert them to PDF files:

#### Commands

**Interactive mode (prompts for folder):**
```bash
python manga_to_pdf.py
```

**Specify folder directly:**
```bash
python manga_to_pdf.py -f /path/to/manga/folder
```

**Use current directory:**
```bash
cd /path/to/manga/folder
python manga_to_pdf.py -f .
```

#### Output

PDFs are created in the parent folder:
```
Chapter_103.pdf
Chapter_104.pdf
Chapter_105.pdf
```

## Complete Workflow Example

```bash
# 1. Activate virtual environment
source .venv/bin/activate  # macOS/Linux
# or
.venv\Scripts\activate     # Windows

# 2. Edit manga_downloader.py to set MANGA_ID and MANGA_SLUG

# 3. Download chapters
python manga_downloader.py -r 100 110

# 4. Convert to PDFs
python manga_to_pdf.py -f .

# 5. Deactivate virtual environment when done
deactivate
```

## Troubleshooting

### 403 Forbidden Errors
The script uses `cloudscraper` to bypass Cloudflare protection. If you still encounter 403 errors:
- Check if the manga URL is correct
- Try updating cloudscraper: `pip install --upgrade cloudscraper`

### No Images Found
- Verify the chapter exists on MangaPill.com
- Check that `MANGA_ID` and `MANGA_SLUG` are correct
- Try opening the URL in a browser first

### Failed Downloads
The script will show a summary of failed downloads at the end. You can:
- Re-run the same command (it skips existing files)
- Check your internet connection
- Wait a few minutes and retry

## Dependencies

- **requests** - HTTP library for downloads
- **beautifulsoup4** - HTML parsing
- **lxml** - XML/HTML parser
- **cloudscraper** - Cloudflare bypass
- **Pillow** - Image processing and PDF creation

## Notes

- Default delay between downloads: 2 seconds (to be respectful to servers)
- Failed downloads are automatically retried once with 3-second delay
- Existing files are skipped automatically
- PDFs are created with 100 DPI resolution

## Legal Disclaimer

This tool is for personal use only. Please respect copyright laws and the terms of service of the websites you access. Only download content you have the right to access.

## License

MIT License - Feel free to modify and distribute as needed.

## Contributing

Issues and pull requests are welcome! Please feel free to contribute improvements.
