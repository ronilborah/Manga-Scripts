#!/bin/bash

# Get the Resources directory
RESOURCES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Change to Desktop for default download location
cd ~/Desktop

# Clear screen and show welcome message
clear
echo "╔════════════════════════════════════════════════════════════╗"
echo "║          MANGA DOWNLOADER - Interactive Menu              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Main menu function
show_menu() {
    echo ""
    echo "What would you like to do?"
    echo "  1) Download manga chapters"
    echo "  2) Convert downloaded chapters to PDF"
    echo "  3) Both (Download and Convert)"
    echo "  4) Exit"
    echo ""
    read -p "Enter your choice (1-4): " main_choice
    echo ""
}

# Function to get manga details
get_manga_details() {
    echo "════════════════════════════════════════════════════════════"
    echo "MANGA CONFIGURATION"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "Example URL: https://mangapill.com/chapters/2035-10103000/jigokuraku-chapter-103"
    echo "From this URL:"
    echo "  - MANGA ID is: 2035"
    echo "  - MANGA SLUG is: jigokuraku"
    echo ""
    
    read -p "Enter Manga ID (e.g., 2035): " manga_id
    read -p "Enter Manga Slug (e.g., jigokuraku): " manga_slug
    
    if [ -z "$manga_id" ] || [ -z "$manga_slug" ]; then
        echo ""
        echo "❌ Error: Both Manga ID and Slug are required!"
        return 1
    fi
    
    echo ""
    echo "✓ Configuration set:"
    echo "  Manga ID: $manga_id"
    echo "  Manga Slug: $manga_slug"
    echo ""
    
    return 0
}

# Function to get chapter selection
get_chapter_selection() {
    echo "════════════════════════════════════════════════════════════"
    echo "CHAPTER SELECTION"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "How would you like to specify chapters?"
    echo "  1) Single chapter (e.g., 103)"
    echo "  2) Multiple specific chapters (e.g., 103, 104, 105)"
    echo "  3) Range of chapters (e.g., 103 to 110)"
    echo ""
    read -p "Enter your choice (1-3): " chapter_choice
    echo ""
    
    case $chapter_choice in
        1)
            read -p "Enter chapter number: " chapter_num
            chapter_args="-c $chapter_num"
            ;;
        2)
            echo "Enter chapter numbers separated by spaces (e.g., 103 104 105.5):"
            read -p "> " chapters
            chapter_args=""
            for ch in $chapters; do
                chapter_args="$chapter_args -c $ch"
            done
            ;;
        3)
            read -p "Enter start chapter: " start_ch
            read -p "Enter end chapter: " end_ch
            chapter_args="-r $start_ch $end_ch"
            ;;
        *)
            echo "❌ Invalid choice"
            return 1
            ;;
    esac
    
    return 0
}

# Function to get output directory
get_output_directory() {
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "OUTPUT DIRECTORY"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "Current location: $(pwd)"
    echo ""
    read -p "Save to current location (Desktop)? (y/n): " use_current
    
    if [[ $use_current == "y" || $use_current == "Y" ]]; then
        output_dir="."
    else
        read -p "Enter full path for download location: " custom_dir
        if [ -n "$custom_dir" ]; then
            # Expand ~ to home directory
            output_dir="${custom_dir/#\~/$HOME}"
            mkdir -p "$output_dir" 2>/dev/null
        else
            output_dir="."
        fi
    fi
    
    echo ""
    echo "✓ Files will be saved to: $(cd "$output_dir" && pwd)"
    echo ""
}

# Function to run manga downloader with dynamic arguments
run_downloader() {
    echo "════════════════════════════════════════════════════════════"
    echo "STARTING DOWNLOAD"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    
    # Run the downloader with user's manga details passed as environment variables
    MANGA_ID="$manga_id" MANGA_SLUG="$manga_slug" python3 "$RESOURCES_DIR/manga_downloader.py" $chapter_args -o "$output_dir"
    
    download_exit_code=$?
    
    return $download_exit_code
}

# Function to run PDF converter
run_pdf_converter() {
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "PDF CONVERSION"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    
    if [ -z "$output_dir" ]; then
        echo "Enter the folder containing downloaded chapters:"
        read -p "> " pdf_folder
        pdf_folder="${pdf_folder/#\~/$HOME}"
    else
        pdf_folder="$output_dir"
    fi
    
    if [ -n "$pdf_folder" ] && [ -d "$pdf_folder" ]; then
        echo ""
        echo "Converting chapters to PDF..."
        python3 "$RESOURCES_DIR/manga_to_pdf.py" -f "$pdf_folder"
    else
        echo "❌ Error: Invalid folder path"
        return 1
    fi
}

# Main program flow
show_menu

case $main_choice in
    1)
        # Download only
        if get_manga_details; then
            if get_chapter_selection; then
                get_output_directory
                run_downloader
                
                echo ""
                echo "════════════════════════════════════════════════════════════"
                echo "Download process completed!"
                echo "════════════════════════════════════════════════════════════"
            fi
        fi
        ;;
    2)
        # Convert to PDF only
        run_pdf_converter
        echo ""
        echo "════════════════════════════════════════════════════════════"
        echo "PDF conversion completed!"
        echo "════════════════════════════════════════════════════════════"
        ;;
    3)
        # Both download and convert
        if get_manga_details; then
            if get_chapter_selection; then
                get_output_directory
                if run_downloader; then
                    echo ""
                    read -p "Download complete. Convert to PDF now? (y/n): " convert_now
                    if [[ $convert_now == "y" || $convert_now == "Y" ]]; then
                        run_pdf_converter
                    fi
                fi
                
                echo ""
                echo "════════════════════════════════════════════════════════════"
                echo "All operations completed!"
                echo "════════════════════════════════════════════════════════════"
            fi
        fi
        ;;
    4)
        echo "Goodbye!"
        exit 0
        ;;
    *)
        echo "❌ Invalid choice. Exiting..."
        exit 1
        ;;
esac

echo ""
echo "Press any key to exit..."
read -n 1 -s
