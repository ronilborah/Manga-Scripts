#!/usr/bin/env python3
"""
Manga Chapter to PDF Converter
Converts each chapter folder (containing images) into a single PDF file
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path

# Auto-install required packages if missing
def check_and_install_packages():
    """Check for required packages and install them if missing"""
    required_packages = {
        'PIL': 'Pillow',
    }
    
    missing_packages = []
    for import_name, package_name in required_packages.items():
        try:
            __import__(import_name)
        except ImportError:
            missing_packages.append(package_name)
    
    if missing_packages:
        print(f"Installing missing packages: {', '.join(missing_packages)}")
        try:
            subprocess.check_call([
                sys.executable, '-m', 'pip', 'install', *missing_packages
            ])
            print("Packages installed successfully!\n")
        except subprocess.CalledProcessError as e:
            print("Error: Failed to install required packages.")
            print(f"Please manually install: pip install {' '.join(missing_packages)}")
            sys.exit(1)

# Check and install dependencies
check_and_install_packages()

# Now import the packages
from PIL import Image


def select_folder():
    """Prompt user to enter folder path or use current directory"""
    print("Enter the full path to the parent folder containing chapter folders")
    print("(or press Enter to use current directory):")
    folder_path = input("> ").strip()
    
    if not folder_path:
        folder_path = os.getcwd()
    
    # Remove quotes if user copied path with quotes
    folder_path = folder_path.strip('"').strip("'")
    
    # Expand ~ to home directory
    folder_path = os.path.expanduser(folder_path)
    
    return folder_path


def natural_sort_key(filename):
    """Generate a key for natural sorting (handles numbers in strings properly)"""
    import re
    # Split filename into text and number parts
    parts = re.split(r'(\d+)', filename.lower())
    # Convert numeric parts to integers for proper sorting
    return [int(part) if part.isdigit() else part for part in parts]


def get_chapter_number(folder_name):
    """Extract chapter number from folder name"""
    # Try to extract number from folder name
    import re
    
    # Look for patterns like "Chapter_339", "Chapter 339", "c339", etc.
    patterns = [
        r'Chapter[_\s]+(\d+)',
        r'chapter[_\s]+(\d+)',
        r'Ch[_\s]+(\d+)',
        r'ch[_\s]+(\d+)',
        r'c(\d+)',
        r'(\d+)',  # Just numbers
    ]
    
    for pattern in patterns:
        match = re.search(pattern, folder_name, re.IGNORECASE)
        if match:
            return match.group(1)
    
    return folder_name


def get_image_files(folder_path):
    """Get all image files from a folder, sorted by name"""
    image_extensions = {'.jpg', '.jpeg', '.png', '.webp', '.bmp', '.gif'}
    image_files = []
    
    for file in os.listdir(folder_path):
        file_path = os.path.join(folder_path, file)
        if os.path.isfile(file_path):
            ext = os.path.splitext(file)[1].lower()
            if ext in image_extensions:
                image_files.append(file_path)
    
    # Sort using natural sorting (page_2 comes before page_10)
    image_files.sort(key=lambda x: natural_sort_key(os.path.basename(x)))
    
    return image_files


def images_to_pdf(image_files, output_pdf):
    """Convert a list of image files to a single PDF"""
    if not image_files:
        return False
    
    try:
        # Open all images and convert to RGB (PDF requires RGB)
        images = []
        for img_path in image_files:
            img = Image.open(img_path)
            
            # Convert to RGB if necessary
            if img.mode in ('RGBA', 'LA', 'P'):
                # Create a white background
                rgb_img = Image.new('RGB', img.size, (255, 255, 255))
                if img.mode == 'P':
                    img = img.convert('RGBA')
                rgb_img.paste(img, mask=img.split()[-1] if img.mode in ('RGBA', 'LA') else None)
                img = rgb_img
            elif img.mode != 'RGB':
                img = img.convert('RGB')
            
            images.append(img)
        
        # Save as PDF
        if images:
            first_image = images[0]
            other_images = images[1:] if len(images) > 1 else []
            
            first_image.save(
                output_pdf,
                'PDF',
                resolution=100.0,
                save_all=True,
                append_images=other_images
            )
            return True
    except Exception as e:
        print(f"Error creating PDF: {e}")
        return False
    
    return False


def process_chapters(parent_folder):
    """Process all chapter folders in the parent folder"""
    if not parent_folder or not os.path.exists(parent_folder):
        print("Invalid folder selected")
        return
    
    print(f"\n{'='*60}")
    print(f"Processing chapters in: {parent_folder}")
    print(f"{'='*60}\n")
    
    # Get all subdirectories
    subdirs = [d for d in os.listdir(parent_folder) 
               if os.path.isdir(os.path.join(parent_folder, d))]
    
    if not subdirs:
        print("No chapter folders found in the selected directory")
        return
    
    subdirs.sort()
    
    success_count = 0
    failed_chapters = []
    
    for subdir in subdirs:
        chapter_path = os.path.join(parent_folder, subdir)
        chapter_number = get_chapter_number(subdir)
        
        print(f"Processing: {subdir}")
        
        # Get all images in the chapter folder
        image_files = get_image_files(chapter_path)
        
        if not image_files:
            print(f"  ⚠ No images found in {subdir}")
            failed_chapters.append({'folder': subdir, 'reason': 'No images found'})
            continue
        
        print(f"  Found {len(image_files)} images")
        
        # Create PDF filename
        pdf_filename = f"Chapter_{chapter_number}.pdf"
        pdf_path = os.path.join(parent_folder, pdf_filename)
        
        # Check if PDF already exists
        if os.path.exists(pdf_path):
            print(f"  ⚠ PDF already exists: {pdf_filename} (skipping)")
            success_count += 1
            continue
        
        # Convert to PDF
        print(f"  Creating PDF: {pdf_filename}...")
        if images_to_pdf(image_files, pdf_path):
            print(f"  ✓ Successfully created {pdf_filename}")
            success_count += 1
        else:
            print(f"  ✗ Failed to create PDF for {subdir}")
            failed_chapters.append({'folder': subdir, 'reason': 'PDF creation failed'})
    
    # Print summary
    print(f"\n{'='*60}")
    print(f"CONVERSION SUMMARY")
    print(f"{'='*60}")
    print(f"Total chapter folders: {len(subdirs)}")
    print(f"Successfully converted: {success_count}")
    print(f"Failed: {len(failed_chapters)}")
    print(f"PDFs saved to: {parent_folder}")
    print(f"{'='*60}")
    
    if failed_chapters:
        print(f"\nFailed Conversions:")
        for failure in failed_chapters:
            print(f"  - {failure['folder']}: {failure['reason']}")
        print()


def main():
    parser = argparse.ArgumentParser(
        description='Convert manga chapter folders to PDF files',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  Interactive mode (prompts for folder):
    python manga_to_pdf.py
  
  Specify folder directly:
    python manga_to_pdf.py -f /path/to/parent/folder
    python manga_to_pdf.py -f ~/Documents/HxH
  
  Use current directory:
    cd /path/to/parent/folder
    python manga_to_pdf.py -f .
        """
    )
    
    parser.add_argument('-f', '--folder', type=str,
                        help='Parent folder containing chapter folders')
    
    args = parser.parse_args()
    
    print("Manga Chapter to PDF Converter")
    print("="*60)
    
    # Get folder path
    if args.folder:
        parent_folder = os.path.expanduser(args.folder)
    else:
        print("\nSelect the parent folder containing your chapter folders")
        print("Each chapter folder should contain the manga page images")
        print()
        parent_folder = select_folder()
    
    if not parent_folder:
        print("No folder provided. Exiting...")
        return
    
    # Validate folder exists
    if not os.path.exists(parent_folder):
        print(f"Error: Folder does not exist: {parent_folder}")
        return
    
    if not os.path.isdir(parent_folder):
        print(f"Error: Path is not a directory: {parent_folder}")
        return
    
    # Process all chapters
    process_chapters(parent_folder)
    
    print("\nConversion complete!")


if __name__ == "__main__":
    main()
