#!/bin/bash

# Get the Resources directory
RESOURCES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Change to Desktop for default download location
cd ~/Desktop

# Global variables
manga_id=""
manga_slug=""
chapter_prefix="10"  # Usually 10, sometimes 20
chapter_args=""
output_dir=""

# Clear screen and show welcome message
clear
echo "╔════════════════════════════════════════════════════════════╗"
echo "║          MANGA DOWNLOADER - Interactive Menu              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "TIP: Type 'back' at any prompt to go back to the previous step"
echo ""

# Main menu function
show_menu() {
    while true; do
        echo ""
        echo "What would you like to do?"
        echo "  1) Download manga chapters"
        echo "  2) Convert downloaded chapters to PDF"
        echo "  3) Both (Download and Convert)"
        echo "  4) Exit"
        echo ""
        read -p "Enter your choice (1-4): " main_choice
        echo ""
        
        case $main_choice in
            1|2|3|4)
                return 0
                ;;
            *)
                echo "❌ Invalid choice. Please enter 1, 2, 3, or 4."
                ;;
        esac
    done
}

# Function to parse manga URL and extract ID and slug
parse_manga_url() {
    local url="$1"
    
    # Remove any leading/trailing whitespace
    url=$(echo "$url" | xargs)
    
    # Check if it's a MangaPill URL
    if [[ ! "$url" =~ mangapill\.com ]]; then
        return 1
    fi
    
    # Extract manga ID and slug from URL
    # URL format: https://mangapill.com/chapters/2035-10103000/jigokuraku-chapter-103
    # Or: https://mangapill.com/manga/2035/jigokuraku
    
    if [[ "$url" =~ /chapters/([0-9]+)-[0-9]+/([^/]+)-chapter ]]; then
        manga_id="${BASH_REMATCH[1]}"
        manga_slug="${BASH_REMATCH[2]}"
        return 0
    elif [[ "$url" =~ /manga/([0-9]+)/([^/]+) ]]; then
        manga_id="${BASH_REMATCH[1]}"
        manga_slug="${BASH_REMATCH[2]}"
        return 0
    fi
    
    return 1
}

# Function to get manga details with URL parsing support
get_manga_details() {
    while true; do
        echo "════════════════════════════════════════════════════════════"
        echo "MANGA CONFIGURATION"
        echo "════════════════════════════════════════════════════════════"
        echo ""
        echo "You can either:"
        echo "  1) Paste a MangaPill URL (recommended)"
        echo "  2) Enter Manga ID and Slug manually"
        echo ""
        echo "Example URL: https://mangapill.com/chapters/2035-10103000/jigokuraku-chapter-103"
        echo ""
        
        read -p "Paste MangaPill URL or enter Manga ID [or 'back']: " input
        
        if [[ "$input" == "back" ]]; then
            echo ""
            return 2  # Signal to go back
        fi
        
        if [ -z "$input" ]; then
            echo ""
            echo "❌ Error: Input cannot be empty!"
            echo ""
            continue
        fi
        
        # Try to parse as URL first
        if parse_manga_url "$input"; then
            echo ""
            echo "✓ Parsed from URL:"
            echo "  Manga ID: $manga_id"
            echo "  Manga Slug: $manga_slug"
            echo ""
            
            # Ask for chapter prefix
            while true; do
                echo "What is the chapter URL prefix for this manga?"
                echo "  1) 10 (most common - e.g., 1-10364000)"
                echo "  2) 20 (e.g., 1-20364000)"
                echo ""
                read -p "Enter 1 or 2 [default: 1]: " prefix_choice
                
                if [ -z "$prefix_choice" ] || [[ "$prefix_choice" == "1" ]]; then
                    chapter_prefix="10"
                    break
                elif [[ "$prefix_choice" == "2" ]]; then
                    chapter_prefix="20"
                    break
                else
                    echo "❌ Invalid choice. Please enter 1 or 2."
                    echo ""
                fi
            done
            echo ""
            
            read -p "Is this correct? (y/n): " confirm
            
            if [[ $confirm == "y" || $confirm == "Y" ]]; then
                return 0  # Success
            else
                echo ""
                echo "Let's try again..."
                echo ""
                continue
            fi
        fi
        
        # If not a URL, treat as Manga ID and ask for slug
        manga_id="$input"
        echo ""
        echo "Manga ID set to: $manga_id"
        
        read -p "Enter Manga Slug (e.g., jigokuraku) [or 'back' to re-enter]: " manga_slug
        
        if [[ "$manga_slug" == "back" ]]; then
            echo ""
            continue  # Re-prompt for manga details
        fi
        
        if [ -z "$manga_slug" ]; then
            echo ""
            echo "❌ Error: Manga Slug cannot be empty!"
            echo ""
            continue
        fi
        
        # Ask for chapter prefix
        while true; do
            echo ""
            echo "What is the chapter URL prefix for this manga?"
            echo "  1) 10 (most common - e.g., 1-10364000)"
            echo "  2) 20 (e.g., 1-20364000)"
            echo ""
            read -p "Enter 1 or 2 [default: 1]: " prefix_choice
            
            if [ -z "$prefix_choice" ] || [[ "$prefix_choice" == "1" ]]; then
                chapter_prefix="10"
                break
            elif [[ "$prefix_choice" == "2" ]]; then
                chapter_prefix="20"
                break
            else
                echo "❌ Invalid choice. Please enter 1 or 2."
                echo ""
            fi
        done
        
        echo ""
        echo "✓ Configuration set:"
        echo "  Manga ID: $manga_id"
        echo "  Manga Slug: $manga_slug"
        echo "  Chapter Prefix: $chapter_prefix"
        echo ""
        read -p "Is this correct? (y/n): " confirm
        
        if [[ $confirm == "y" || $confirm == "Y" ]]; then
            return 0  # Success
        else
            echo ""
            echo "Let's try again..."
            echo ""
        fi
    done
}

# Function to get chapter selection with validation and back option
get_chapter_selection() {
    while true; do
        echo "════════════════════════════════════════════════════════════"
        echo "CHAPTER SELECTION"
        echo "════════════════════════════════════════════════════════════"
        echo ""
        echo "How would you like to specify chapters?"
        echo "  1) Single chapter (e.g., 103)"
        echo "  2) Multiple specific chapters (e.g., 103, 104, 105)"
        echo "  3) Range of chapters (e.g., 103 to 110)"
        echo "  b) Back to manga configuration"
        echo ""
        read -p "Enter your choice (1-3 or 'b'): " chapter_choice
        echo ""
        
        if [[ "$chapter_choice" == "b" || "$chapter_choice" == "back" ]]; then
            return 2  # Signal to go back
        fi
        
        case $chapter_choice in
            1)
                while true; do
                    read -p "Enter chapter number [or 'back']: " chapter_num
                    
                    if [[ "$chapter_num" == "back" ]]; then
                        echo ""
                        break  # Go back to chapter selection menu
                    fi
                    
                    if [ -z "$chapter_num" ]; then
                        echo "❌ Error: Chapter number cannot be empty!"
                        continue
                    fi
                    
                    chapter_args="-c $chapter_num"
                    echo "✓ Will download chapter: $chapter_num"
                    echo ""
                    read -p "Confirm? (y/n): " confirm
                    
                    if [[ $confirm == "y" || $confirm == "Y" ]]; then
                        return 0  # Success
                    else
                        echo ""
                    fi
                done
                ;;
            2)
                while true; do
                    echo "Enter chapter numbers separated by spaces (e.g., 103 104 105.5)"
                    read -p "[or 'back']: " chapters
                    
                    if [[ "$chapters" == "back" ]]; then
                        echo ""
                        break  # Go back to chapter selection menu
                    fi
                    
                    if [ -z "$chapters" ]; then
                        echo "❌ Error: Please enter at least one chapter number!"
                        continue
                    fi
                    
                    chapter_args=""
                    for ch in $chapters; do
                        chapter_args="$chapter_args -c $ch"
                    done
                    
                    echo "✓ Will download chapters: $chapters"
                    echo ""
                    read -p "Confirm? (y/n): " confirm
                    
                    if [[ $confirm == "y" || $confirm == "Y" ]]; then
                        return 0  # Success
                    else
                        echo ""
                    fi
                done
                ;;
            3)
                while true; do
                    read -p "Enter start chapter [or 'back']: " start_ch
                    
                    if [[ "$start_ch" == "back" ]]; then
                        echo ""
                        break  # Go back to chapter selection menu
                    fi
                    
                    if [ -z "$start_ch" ]; then
                        echo "❌ Error: Start chapter cannot be empty!"
                        continue
                    fi
                    
                    read -p "Enter end chapter [or 'back']: " end_ch
                    
                    if [[ "$end_ch" == "back" ]]; then
                        continue  # Re-prompt for start chapter
                    fi
                    
                    if [ -z "$end_ch" ]; then
                        echo "❌ Error: End chapter cannot be empty!"
                        continue
                    fi
                    
                    chapter_args="-r $start_ch $end_ch"
                    echo "✓ Will download chapters: $start_ch to $end_ch"
                    echo ""
                    read -p "Confirm? (y/n): " confirm
                    
                    if [[ $confirm == "y" || $confirm == "Y" ]]; then
                        return 0  # Success
                    else
                        echo ""
                    fi
                done
                ;;
            *)
                echo "❌ Invalid choice. Please enter 1, 2, 3, or 'b'."
                echo ""
                ;;
        esac
    done
}

# Function to get output directory with validation
get_output_directory() {
    while true; do
        echo ""
        echo "════════════════════════════════════════════════════════════"
        echo "OUTPUT DIRECTORY"
        echo "════════════════════════════════════════════════════════════"
        echo ""
        echo "Current location: $(pwd)"
        echo ""
        read -p "Save to current location (Desktop)? (y/n/back): " use_current
        
        if [[ "$use_current" == "back" ]]; then
            return 2  # Signal to go back
        fi
        
        if [[ $use_current == "y" || $use_current == "Y" ]]; then
            output_dir="."
            echo ""
            echo "✓ Files will be saved to: $(cd "$output_dir" && pwd)"
            echo ""
            return 0
        elif [[ $use_current == "n" || $use_current == "N" ]]; then
            while true; do
                read -p "Enter full path for download location [or 'back']: " custom_dir
                
                if [[ "$custom_dir" == "back" ]]; then
                    echo ""
                    break  # Go back to the y/n prompt
                fi
                
                if [ -z "$custom_dir" ]; then
                    echo "❌ Using current directory instead."
                    output_dir="."
                else
                    # Remove quotes, expand ~, and remove escape characters
                    output_dir="${custom_dir//\'/}"  # Remove single quotes
                    output_dir="${custom_dir//\"/}"  # Remove double quotes
                    output_dir="${output_dir/#\~/$HOME}"  # Expand ~
                    output_dir="${output_dir//\\/}"  # Remove backslashes
                    
                    # Try to create directory
                    if mkdir -p "$output_dir" 2>/dev/null; then
                        echo ""
                        echo "✓ Files will be saved to: $(cd "$output_dir" && pwd)"
                        echo ""
                        return 0
                    else
                        echo "❌ Error: Could not create directory. Please try again."
                        continue
                    fi
                fi
                
                echo ""
                echo "✓ Files will be saved to: $(cd "$output_dir" && pwd)"
                echo ""
                return 0
            done
        else
            echo "❌ Please enter 'y', 'n', or 'back'."
            echo ""
        fi
    done
}

# Function to run manga downloader with dynamic arguments
run_downloader() {
    echo "════════════════════════════════════════════════════════════"
    echo "STARTING DOWNLOAD"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    
    # Debug: Show what we're passing
    # echo "DEBUG: manga_id=$manga_id manga_slug=$manga_slug chapter_prefix=$chapter_prefix chapter_args=$chapter_args output_dir=$output_dir"
    
    # Run the downloader with user's manga details passed as environment variables
    MANGA_ID="$manga_id" MANGA_SLUG="$manga_slug" CHAPTER_PREFIX="$chapter_prefix" python3 "$RESOURCES_DIR/manga_downloader.py" $chapter_args -o "$output_dir"
    
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
        while true; do
            echo "Enter the folder containing downloaded chapters:"
            read -p "[or 'back' to cancel]: " pdf_folder
            
            if [[ "$pdf_folder" == "back" ]]; then
                echo "PDF conversion cancelled."
                return 1
            fi
            
            # Remove quotes, expand ~, and remove backslashes
            pdf_folder="${pdf_folder//\'/}"  # Remove single quotes
            pdf_folder="${pdf_folder//\"/}"  # Remove double quotes
            pdf_folder="${pdf_folder/#\~/$HOME}"  # Expand ~
            pdf_folder="${pdf_folder//\\/}"  # Remove backslashes
            
            if [ -n "$pdf_folder" ] && [ -d "$pdf_folder" ]; then
                break
            else
                echo "❌ Error: Invalid folder path. Please try again."
                echo ""
            fi
        done
    else
        pdf_folder="$output_dir"
    fi
    
    echo ""
    echo "Converting chapters to PDF..."
    python3 "$RESOURCES_DIR/manga_to_pdf.py" -f "$pdf_folder"
}

# Main program loop - allows restarting
while true; do
    show_menu
    
    case $main_choice in
        1)
            # Download only
            download_completed=false
            while true; do
                if get_manga_details; then
                    while true; do
                        get_chapter_selection
                        exit_code=$?
                        
                        if [ $exit_code -eq 2 ]; then
                            # User chose to go back
                            echo "Going back to manga configuration..."
                            echo ""
                            break
                        elif [ $exit_code -eq 0 ]; then
                            # Success, proceed to output directory
                            while true; do
                                get_output_directory
                                exit_code=$?
                                
                                if [ $exit_code -eq 2 ]; then
                                    # User chose to go back
                                    echo "Going back to chapter selection..."
                                    echo ""
                                    break
                                elif [ $exit_code -eq 0 ]; then
                                    # Everything configured, start download
                                    run_downloader
                                    
                                    echo ""
                                    echo "════════════════════════════════════════════════════════════"
                                    echo "Download process completed!"
                                    echo "════════════════════════════════════════════════════════════"
                                    download_completed=true
                                    
                                    # Exit all loops
                                    break 3
                                fi
                            done
                        fi
                    done
                else
                    exit_code=$?
                    if [ $exit_code -eq 2 ]; then
                        # User chose to go back from manga details
                        echo "Going back to main menu..."
                        echo ""
                        break
                    fi
                fi
            done
            
            # Ask if user wants to restart after download
            if [ "$download_completed" = true ]; then
                echo ""
                read -p "Download another manga? (y/n): " restart_choice
                if [[ $restart_choice == "y" || $restart_choice == "Y" ]]; then
                    clear
                    echo "╔════════════════════════════════════════════════════════════╗"
                    echo "║          MANGA DOWNLOADER - Interactive Menu              ║"
                    echo "╚════════════════════════════════════════════════════════════╝"
                    echo ""
                    echo "TIP: Type 'back' at any prompt to go back to the previous step"
                    echo ""
                    continue  # Restart the main loop
                else
                    break  # Exit the main loop
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
            echo ""
            read -p "Convert another folder or return to main menu? (y/n): " restart_choice
            if [[ $restart_choice == "y" || $restart_choice == "Y" ]]; then
                clear
                echo "╔════════════════════════════════════════════════════════════╗"
                echo "║          MANGA DOWNLOADER - Interactive Menu              ║"
                echo "╚════════════════════════════════════════════════════════════╝"
                echo ""
                echo "TIP: Type 'back' at any prompt to go back to the previous step"
                echo ""
                continue  # Restart the main loop
            else
                break  # Exit the main loop
            fi
            ;;
        3)
            # Both download and convert
            download_completed=false
            while true; do
                if get_manga_details; then
                    while true; do
                        get_chapter_selection
                        exit_code=$?
                        
                        if [ $exit_code -eq 2 ]; then
                            echo "Going back to manga configuration..."
                            echo ""
                            break
                        elif [ $exit_code -eq 0 ]; then
                            while true; do
                                get_output_directory
                                exit_code=$?
                                
                                if [ $exit_code -eq 2 ]; then
                                    echo "Going back to chapter selection..."
                                    echo ""
                                    break
                                elif [ $exit_code -eq 0 ]; then
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
                                    download_completed=true
                                    
                                    break 3
                                fi
                            done
                        fi
                    done
                else
                    exit_code=$?
                    if [ $exit_code -eq 2 ]; then
                        echo "Going back to main menu..."
                        echo ""
                        break
                    fi
                fi
            done
            
            # Ask if user wants to restart after download
            if [ "$download_completed" = true ]; then
                echo ""
                read -p "Download another manga? (y/n): " restart_choice
                if [[ $restart_choice == "y" || $restart_choice == "Y" ]]; then
                    clear
                    echo "╔════════════════════════════════════════════════════════════╗"
                    echo "║          MANGA DOWNLOADER - Interactive Menu              ║"
                    echo "╚════════════════════════════════════════════════════════════╝"
                    echo ""
                    echo "TIP: Type 'back' at any prompt to go back to the previous step"
                    echo ""
                    continue  # Restart the main loop
                else
                    break  # Exit the main loop
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
    
    # If we get here without continuing, break the main loop
    break
done

echo ""
echo "Press any key to exit..."
read -n 1 -s
