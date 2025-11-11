#!/bin/bash
# Quick Install Script - Move Manga Downloader to Applications folder

echo "════════════════════════════════════════════════════════════"
echo "Manga Downloader - Quick Install"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "This will copy 'Manga Downloader.app' to your Applications folder."
echo ""
read -p "Continue? (y/n): " confirm

if [[ $confirm == "y" || $confirm == "Y" ]]; then
    echo ""
    echo "Copying to /Applications..."
    
    # Check if app already exists
    if [ -d "/Applications/Manga Downloader.app" ]; then
        echo "⚠️  App already exists in Applications."
        read -p "Replace it? (y/n): " replace
        if [[ $replace != "y" && $replace != "Y" ]]; then
            echo "Installation cancelled."
            exit 0
        fi
        rm -rf "/Applications/Manga Downloader.app"
    fi
    
    # Copy the app
    cp -R "Manga Downloader.app" /Applications/
    
    if [ $? -eq 0 ]; then
        echo "✅ Successfully installed to /Applications/Manga Downloader.app"
        echo ""
        echo "You can now:"
        echo "  • Find it in Launchpad"
        echo "  • Open it from Applications folder"
        echo "  • Add it to your Dock"
    else
        echo "❌ Installation failed. You may need administrator privileges."
        echo "Try: sudo cp -R 'Manga Downloader.app' /Applications/"
    fi
else
    echo "Installation cancelled."
fi

echo ""
