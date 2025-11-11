#!/bin/bash

# One-time setup script to install required Python packages
# Run this once before using the Manga Downloader app

clear
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     MANGA DOWNLOADER - One-Time Package Installation      ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "This script will install the required Python packages for"
echo "the Manga Downloader app to work properly."
echo ""
echo "Packages to install:"
echo "  • requests (HTTP library)"
echo "  • beautifulsoup4 (HTML parser)"
echo "  • lxml (XML/HTML parser)"
echo "  • cloudscraper (Cloudflare bypass)"
echo "  • Pillow (Image processing)"
echo ""
read -p "Continue with installation? (y/n): " confirm
echo ""

if [[ $confirm != "y" && $confirm != "Y" ]]; then
    echo "Installation cancelled."
    exit 0
fi

# Try installing with --user flag (recommended)
echo "════════════════════════════════════════════════════════════"
echo "Installing packages with --user flag (recommended method)..."
echo "════════════════════════════════════════════════════════════"
echo ""

pip3 install --user requests beautifulsoup4 lxml cloudscraper Pillow

if [ $? -eq 0 ]; then
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "✅ SUCCESS! All packages installed successfully!"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "You can now use the Manga Downloader app!"
    echo "Double-click 'Manga Downloader.app' to launch it."
    echo ""
else
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "⚠️  Installation with --user flag failed."
    echo "Trying alternative method..."
    echo "════════════════════════════════════════════════════════════"
    echo ""
    
    # Try with --break-system-packages as fallback
    pip3 install --break-system-packages requests beautifulsoup4 lxml cloudscraper Pillow
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "════════════════════════════════════════════════════════════"
        echo "✅ SUCCESS! All packages installed successfully!"
        echo "════════════════════════════════════════════════════════════"
        echo ""
        echo "You can now use the Manga Downloader app!"
        echo "Double-click 'Manga Downloader.app' to launch it."
        echo ""
    else
        echo ""
        echo "════════════════════════════════════════════════════════════"
        echo "❌ Installation failed with both methods."
        echo "════════════════════════════════════════════════════════════"
        echo ""
        echo "Please try installing manually:"
        echo ""
        echo "Option 1 (Recommended):"
        echo "  pip3 install --user requests beautifulsoup4 lxml cloudscraper Pillow"
        echo ""
        echo "Option 2:"
        echo "  pip3 install --break-system-packages requests beautifulsoup4 lxml cloudscraper Pillow"
        echo ""
        echo "Option 3 (Using Homebrew):"
        echo "  brew install python@3"
        echo "  /opt/homebrew/bin/pip3 install requests beautifulsoup4 lxml cloudscraper Pillow"
        echo ""
    fi
fi

echo "Press any key to exit..."
read -n 1 -s
