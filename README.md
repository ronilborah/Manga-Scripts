# Manga Downloader & PDF Converter

A Python-based tool to download manga chapters from MangaPill.com and convert them into PDF files.

## Quick Start (macOS)

```bash
# Navigate to where you want to save manga (can be anywhere)
cd ~/Documents


# Clone the repository
git clone https://github.com/ronilborah/Manga-Scripts
cd Manga-Scripts

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
