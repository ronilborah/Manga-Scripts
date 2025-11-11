#!/usr/bin/env python3
"""
Manga Downloader for MangaPill.com

SETUP:
  Edit MANGA_ID and MANGA_SLUG below to match your target manga URL.
  Example URL: https://mangapill.com/chapters/2035-10103000/jigokuraku-chapter-103
               MANGA_ID = "2035", MANGA_SLUG = "jigokuraku"

USAGE:
  python manga_downloader.py -c 103              # Download chapter 103
  python manga_downloader.py -c 103 -c 104       # Download multiple chapters
  python manga_downloader.py -r 103 110          # Download chapters 103-110
  python manga_downloader.py -c 103.5            # Download chapter 103.5 (if exists)
  python manga_downloader.py -c 103 -o ~/manga   # Save to custom directory
"""

import os
import sys
import subprocess
import time
import argparse
from urllib.parse import urljoin

# ============================================================
# MANGA CONFIGURATION - Can be set via environment variables or defaults
# ============================================================
MANGA_ID = os.environ.get("MANGA_ID", "2035")
MANGA_SLUG = os.environ.get("MANGA_SLUG", "jigokuraku")
# ============================================================

def check_and_install_packages():
    """Check for required packages and install them if missing"""
    required_packages = {
        'requests': 'requests',
        'bs4': 'beautifulsoup4',
        'lxml': 'lxml',
        'cloudscraper': 'cloudscraper'
    }
    
    missing_packages = []
    for import_name, package_name in required_packages.items():
        try:
            __import__(import_name)
        except ImportError:
            missing_packages.append(package_name)
    
    if missing_packages:
        print(f"Installing missing packages: {', '.join(missing_packages)}")
        print("(This may take a moment...)\n")
        try:
            # Try with --user flag first (recommended for macOS)
            subprocess.check_call([
                sys.executable, '-m', 'pip', 'install', '--user', *missing_packages
            ])
            print("✓ Packages installed successfully!\n")
        except subprocess.CalledProcessError:
            # If --user fails, try with --break-system-packages
            print("Trying alternative installation method...")
            try:
                subprocess.check_call([
                    sys.executable, '-m', 'pip', 'install', '--break-system-packages', *missing_packages
                ])
                print("✓ Packages installed successfully!\n")
            except subprocess.CalledProcessError as e:
                print("\n❌ Error: Failed to install required packages.")
                print(f"\nPlease manually install packages using one of these methods:")
                print(f"  Method 1 (Recommended): pip3 install --user {' '.join(missing_packages)}")
                print(f"  Method 2: pip3 install --break-system-packages {' '.join(missing_packages)}")
                print(f"\nThen run the app again.")
                input("\nPress Enter to exit...")
                sys.exit(1)

check_and_install_packages()

import requests
from bs4 import BeautifulSoup
import cloudscraper

scraper = cloudscraper.create_scraper(
    browser={'browser': 'chrome', 'platform': 'darwin', 'desktop': True}
)


def download_image(url, filepath, referer=None):
    try:
        headers = {'Referer': referer if referer else 'https://mangapill.com/'}
        response = scraper.get(url, headers=headers, timeout=30)
        response.raise_for_status()
        
        with open(filepath, 'wb') as f:
            f.write(response.content)
        return True
    except Exception as e:
        print(f"Error downloading {url}: {e}")
        return False


def get_chapter_images(chapter_url, debug=False):
    try:
        response = scraper.get(chapter_url, timeout=30)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.content, 'html.parser')
        images = []
        img_tags = soup.find_all('img', class_='js-page')
        
        if debug:
            print(f"  Debug: Found {len(img_tags)} images with class 'js-page'")
        
        for img in img_tags:
            src = img.get('data-src') or img.get('src')
            if src:
                if not src.startswith('http'):
                    src = urljoin(chapter_url, src)
                images.append(src)
                if debug and len(images) <= 3:
                    print(f"  Debug: Found image: {src}")
        
        if debug:
            print(f"  Debug: Total images extracted: {len(images)}")
        
        return images
    except Exception as e:
        print(f"Error fetching chapter page: {e}")
        if debug:
            import traceback
            traceback.print_exc()
        return []


def download_chapter(chapter_number, output_dir='downloads', failed_downloads=None):
    if failed_downloads is None:
        failed_downloads = []
    
    chapter_id = f"10{int(chapter_number):03d}000"
    chapter_url = f"https://mangapill.com/chapters/{MANGA_ID}-{chapter_id}/{MANGA_SLUG}-chapter-{int(chapter_number)}"
    
    print(f"\n{'='*60}")
    print(f"Downloading Chapter {chapter_number}")
    print(f"URL: {chapter_url}")
    print(f"{'='*60}")
    
    if chapter_number == int(chapter_number):
        chapter_folder = os.path.join(output_dir, f"{MANGA_SLUG}_Chapter_{int(chapter_number):03d}")
    else:
        chapter_folder = os.path.join(output_dir, f"{MANGA_SLUG}_Chapter_{chapter_number}")
    os.makedirs(chapter_folder, exist_ok=True)
    
    print("Fetching image URLs...")
    image_urls = get_chapter_images(chapter_url, debug=True)
    
    if not image_urls:
        print(f"No images found for chapter {chapter_number}")
        print(f"Please verify the URL is correct: {chapter_url}")
        print(f"Try opening this URL in a browser to check if the chapter exists.")
        failed_downloads.append({
            'chapter': chapter_number,
            'reason': 'No images found',
            'page': 'N/A'
        })
        return 0
    
    print(f"Found {len(image_urls)} images")
    
    downloaded = 0
    for idx, img_url in enumerate(image_urls, 1):
        ext = 'jpg'
        if '.png' in img_url.lower():
            ext = 'png'
        elif '.jpeg' in img_url.lower():
            ext = 'jpeg'
        elif '.webp' in img_url.lower():
            ext = 'webp'
        
        filename = f"page_{idx:03d}.{ext}"
        filepath = os.path.join(chapter_folder, filename)
        
        existing_file = None
        for check_ext in ['jpg', 'jpeg', 'png', 'webp']:
            check_path = os.path.join(chapter_folder, f"page_{idx:03d}.{check_ext}")
            if os.path.exists(check_path):
                existing_file = check_path
                break
        
        if existing_file:
            print(f"  [{idx}/{len(image_urls)}] Skipping page_{idx:03d} (already exists)")
            downloaded += 1
            continue
        
        print(f"  [{idx}/{len(image_urls)}] Downloading {filename}...")
        if download_image(img_url, filepath, referer=chapter_url):
            downloaded += 1
            time.sleep(2.0)
        else:
            print(f"  Failed to download page {idx}")
            print(f"  Retrying in 3 seconds...")
            time.sleep(3)
            if download_image(img_url, filepath, referer=chapter_url):
                downloaded += 1
                print(f"  ✓ Retry successful")
                time.sleep(2.0)
            else:
                failed_downloads.append({
                    'chapter': chapter_number,
                    'page': idx,
                    'filename': filename,
                    'url': img_url
                })
    
    print(f"\nChapter {chapter_number} complete: {downloaded}/{len(image_urls)} images downloaded")
    return downloaded


def main():
    parser = argparse.ArgumentParser(
        description=f'Download {MANGA_SLUG} chapters from mangapill.com',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  Download a single chapter:
    python manga_downloader.py -c 85
  
  Download a decimal chapter (if it exists):
    python manga_downloader.py -c 202.5
  
  Download a range of chapters (whole numbers):
    python manga_downloader.py -r 85 100
  
  Download multiple specific chapters:
    python manga_downloader.py -c 85 -c 86 -c 87.5
  
  Specify output directory:
    python manga_downloader.py -c 85 -o ~/manga/vinland_saga

Note: To download a different manga, edit MANGA_ID and MANGA_SLUG at the top of this file.
        """
    )
    
    parser.add_argument('-c', '--chapter', type=float, action='append',
                        help='Chapter number to download (can be used multiple times, supports decimals like 202.5)')
    parser.add_argument('-r', '--range', nargs=2, type=float, metavar=('START', 'END'),
                        help='Download a range of chapters (inclusive, supports decimals)')
    parser.add_argument('-o', '--output', default='.',
                        help='Output directory (default: current directory)')
    
    args = parser.parse_args()
    
    # Determine which chapters to download
    chapters = []
    if args.chapter:
        chapters.extend(args.chapter)
    if args.range:
        start, end = args.range
        current = int(start)
        end_int = int(end)
        while current <= end_int:
            chapters.append(float(current))
            current += 1
    
    if not chapters:
        print("Error: Please specify at least one chapter to download")
        print("Use -h for help")
        return
    
    chapters = sorted(set(chapters))
    
    print(f"Starting download...")
    print(f"Chapters to download: {', '.join(map(str, chapters))}")
    print(f"Output directory: {args.output}")
    
    os.makedirs(args.output, exist_ok=True)
    failed_downloads = []
    
    total_images = 0
    for chapter in chapters:
        count = download_chapter(chapter, args.output, failed_downloads)
        total_images += count
    
    print(f"\n{'='*60}")
    print(f"Download Complete!")
    print(f"Total chapters: {len(chapters)}")
    print(f"Total images: {total_images}")
    print(f"Location: {os.path.abspath(args.output)}")
    print(f"{'='*60}")
    
    if failed_downloads:
        print(f"\n{'='*60}")
        print(f"FAILED DOWNLOADS SUMMARY")
        print(f"{'='*60}")
        print(f"Total failed: {len(failed_downloads)}\n")
        
        chapters_with_failures = {}
        for failure in failed_downloads:
            chapter = failure['chapter']
            if chapter not in chapters_with_failures:
                chapters_with_failures[chapter] = []
            chapters_with_failures[chapter].append(failure)
        
        for chapter in sorted(chapters_with_failures.keys()):
            failures = chapters_with_failures[chapter]
            print(f"Chapter {chapter}:")
            for failure in failures:
                if failure.get('page') == 'N/A':
                    print(f"  - {failure.get('reason', 'Unknown error')}")
                else:
                    print(f"  - Page {failure['page']}: {failure.get('filename', 'N/A')}")
            print()
        
        print(f"{'='*60}")
    else:
        print("\n✓ All files downloaded successfully!")



if __name__ == "__main__":
    main()
