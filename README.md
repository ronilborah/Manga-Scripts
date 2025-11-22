# Manga Downloader & PDF Converter

Download manga chapters from MangaPill.com and convert them to PDF files - available as both a macOS app and Python scripts.

## 🚀 Quick Start (macOS App - Recommended)

### Using the App

1. **Double-click** `Manga Downloader.app`
2. Choose your action:
   - Download chapters
   - Convert chapters to PDF
   - Both (Download + Convert)
3. Follow the interactive prompts

### Finding Manga Information

When prompted, you can either:

- **Paste a MangaPill URL** (easiest): `https://mangapill.com/chapters/2035-10103000/jigokuraku-chapter-103`
- **Enter manually**: Manga ID (`2035`) and Slug (`jigokuraku`)

### Chapter URL Prefix

Some manga use different URL prefixes:

- **Option 1: 10** (most common) - e.g., `1-10364000`
- **Option 2: 20** (some manga like Berserk) - e.g., `1-20364000`

The app will prompt you to select the correct prefix.

### Chapter Selection Examples

- **Single**: `103`
- **Multiple**: `103 104 105 107.5`
- **Range**: Start: `103`, End: `110`

### Popular Manga Examples

| Manga          | ID   | Slug           |
| -------------- | ---- | -------------- |
| One Piece      | 1357 | one-piece      |
| Jujutsu Kaisen | 606  | jujutsu-kaisen |
| Chainsaw Man   | 1096 | chainsaw-man   |
| Berserk        | 1    | berserk        |

---

## 🐍 Python Scripts (Advanced)

### Installation

```bash
git clone https://github.com/ronilborah/Manga-Scripts
cd Manga-Scripts

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate  # macOS/Linux
# or .venv\Scripts\activate  # Windows

# Packages auto-install on first run, or install manually:
pip install requests beautifulsoup4 lxml cloudscraper Pillow
```

### Configuration

Edit `manga_downloader.py`:

```python
MANGA_ID = "2035"           # From URL
MANGA_SLUG = "jigokuraku"   # From URL
CHAPTER_PREFIX = "10"       # Usually "10", sometimes "20"
```

### Usage

**Download chapters:**

```bash
python3 manga_downloader.py -c 103              # Single chapter
python3 manga_downloader.py -c 103 -c 104       # Multiple
python3 manga_downloader.py -r 103 110          # Range
python3 manga_downloader.py -c 103 -o ~/manga   # Custom location
```

**Convert to PDF:**

```bash
python3 manga_to_pdf.py -f .                    # Current directory
python3 manga_to_pdf.py -f /path/to/folder      # Specific folder
```

### Output Structure

**Downloaded chapters:**

```
jigokuraku_Chapter_103/
  ├── page_001.jpg
  ├── page_002.jpg
  └── ...
```

**PDFs:**

```
Chapter_103.pdf
Chapter_104.pdf
```

---

## ✨ Features

✅ **Portable macOS App** - All dependencies included  
✅ **Interactive Terminal UI** - Easy-to-follow prompts  
✅ **URL Parsing** - Paste full MangaPill URLs  
✅ **Flexible Chapter Selection** - Single, multiple, or ranges  
✅ **Decimal Chapter Support** - Handle chapters like 103.5  
✅ **Auto Package Installation** - Installs missing dependencies  
✅ **Path Handling** - Handles quoted paths and spaces  
✅ **Back Navigation** - Type 'back' at any prompt  
✅ **Restart Option** - Continue downloading without relaunching

---

## 🛠️ Troubleshooting

**App won't open on first launch:**

- Right-click → Open → Click "Open" to bypass Gatekeeper

**Python environment issues:**

- Scripts automatically use `--user` flag for package installation
- Works with macOS externally-managed Python environments

**Path errors:**

- Paths with spaces are supported
- Quotes in pasted paths are automatically removed

---

## 📝 Complete Workflow

### Using the App

1. Double-click `Manga Downloader.app`
2. Paste manga URL or enter ID/Slug
3. Select chapter prefix (10 or 20)
4. Choose chapters to download
5. Select output location
6. Wait for download to complete
7. Convert to PDF if desired

### Using Python Scripts

```bash
source .venv/bin/activate
python3 manga_downloader.py -r 100 110
python3 manga_to_pdf.py -f .
deactivate
```
