# Manga Downloader App - Usage Guide

## Overview
The **Manga Downloader.app** is a portable macOS application that allows you to download manga chapters from MangaPill.com and convert them to PDF format with a simple double-click interface.

## Features
✅ **Portable** - All Python scripts are included in the app package  
✅ **Interactive Terminal UI** - Easy-to-follow prompts  
✅ **Multiple Options** - Download only, convert only, or do both  
✅ **Flexible Chapter Selection** - Single chapters, multiple chapters, or ranges  
✅ **Custom Output Locations** - Save anywhere you want  

## How to Use

### 1. Launch the App
Simply **double-click** on `Manga Downloader.app` and it will open in Terminal.

### 2. Choose Your Action
You'll see a menu with 4 options:
1. **Download manga chapters** - Download images from MangaPill
2. **Convert downloaded chapters to PDF** - Convert existing chapter folders to PDF
3. **Both** - Download and then convert to PDF
4. **Exit** - Close the app

### 3. If Downloading (Options 1 or 3):

#### Step A: Enter Manga Details
You'll need to provide:
- **Manga ID** - Found in the MangaPill URL
- **Manga Slug** - The manga name in the URL

**Example URL:** `https://mangapill.com/chapters/2035-10103000/jigokuraku-chapter-103`
- Manga ID: `2035`
- Manga Slug: `jigokuraku`

#### Step B: Select Chapters
Choose how to specify chapters:
1. **Single chapter** - Enter one chapter number (e.g., `103`)
2. **Multiple chapters** - Enter space-separated numbers (e.g., `103 104 105.5`)
3. **Range** - Enter start and end (e.g., start: `103`, end: `110`)

#### Step C: Choose Output Location
- Default: Desktop (current directory)
- Custom: Enter any full path (e.g., `/Users/yourusername/Documents/Manga`)

### 4. If Converting to PDF (Option 2):
Simply provide the folder path containing your downloaded chapter folders.

## Finding Manga Information

1. Go to [MangaPill.com](https://mangapill.com)
2. Search for your manga
3. Click on any chapter
4. Look at the URL in your browser:
   ```
   https://mangapill.com/chapters/[MANGA_ID]-[CHAPTER_ID]/[MANGA_SLUG]-chapter-[NUMBER]
   ```
5. Extract the **MANGA_ID** (first number) and **MANGA_SLUG** (manga name)

## Examples

### Example 1: Download Jujutsu Kaisen Chapter 200
```
Manga ID: 606
Manga Slug: jujutsu-kaisen
Chapter: 200
```

### Example 2: Download One Piece Chapters 1000-1010
```
Manga ID: 1357
Manga Slug: one-piece
Start: 1000
End: 1010
```

### Example 3: Download Multiple Specific Chapters
```
Manga ID: 2035
Manga Slug: jigokuraku
Chapters: 103 104 105 107.5 110
```

## Output Structure

Downloaded chapters will be saved as:
```
[manga_slug]_Chapter_XXX/
├── page_001.jpg
├── page_002.jpg
├── page_003.jpg
└── ...
```

Converted PDFs will be saved as:
```
Chapter_XXX.pdf
```

## Requirements

- **macOS 10.13 or later**
- **Python 3** (pre-installed on modern macOS)
- **Internet connection** (for downloading)

The app will automatically install required Python packages:
- `requests`
- `beautifulsoup4`
- `lxml`
- `cloudscraper`
- `Pillow`

## Troubleshooting

### "Cannot open app because it is from an unidentified developer"
1. Right-click (or Control-click) the app
2. Select "Open" from the menu
3. Click "Open" in the dialog box
4. The app will now open and be remembered as safe

### Downloads Failing
- Check your internet connection
- Verify the Manga ID and Slug are correct
- Try opening the chapter URL in a browser to confirm it exists
- Some chapters may not be available

### Python Errors
The app will automatically try to install missing packages. If it fails:
```bash
# Open Terminal and run:
pip3 install requests beautifulsoup4 lxml cloudscraper Pillow
```

## Moving the App

The app is **completely portable**! You can:
- Copy it to `/Applications`
- Move it to any folder
- Copy it to another Mac
- Share it with others

All Python scripts are included in the app package at:
```
Manga Downloader.app/Contents/Resources/
```

## Uninstalling

Simply drag `Manga Downloader.app` to the Trash. No other files are installed on your system.

## Tips

💡 **Decimal Chapters**: Some manga have chapters like 103.5 - just enter `103.5` when prompted  
💡 **Organization**: Create a dedicated manga folder like `~/Documents/Manga` for better organization  
💡 **Batch Processing**: Use the range option to download many chapters at once  
💡 **PDF Size**: PDFs can be large - a 40-page chapter might be 50-100MB  

## Credits

Original Python scripts by the Manga-Scripts repository.  
Packaged as macOS app for easy use.

---

**Enjoy your manga! 📚**
