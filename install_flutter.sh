#!/bin/bash

FLUTTER_DOWNLOAD_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.38.5-stable.tar.xz"
FLUTTER_DOWNLOAD_DIR="/home/$USER/Downloads"
FLUTTER_EXTRACT_DIR="/home/$USER/flutter"


set -e
# Clean up any previous installations
echo "Cleaning up previous installations..."
rm -rf "$FLUTTER_DOWNLOAD_DIR/flutter_linux_3.38.5-stable.tar.xz"
rm -rf "$FLUTTER_EXTRACT_DIR"

# Create necessary directories
echo "Creating directories..."
mkdir -p "$FLUTTER_DOWNLOAD_DIR"
mkdir -p "$FLUTTER_EXTRACT_DIR"

# Update and install dependencies
echo "Installing dependencies..."
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa


# Download the Flutter SDK Bundle
echo "Downloading Flutter SDK..."
wget -P "$FLUTTER_DOWNLOAD_DIR" "$FLUTTER_DOWNLOAD_URL"


# Extract the Flutter SDK
echo "Extracting Flutter SDK..."
tar -xf "$FLUTTER_DOWNLOAD_DIR/flutter_linux_3.38.5-stable.tar.xz" -C "$FLUTTER_EXTRACT_DIR"

# Add Flutter to PATH
echo "Adding Flutter to PATH..."
echo "export PATH=\"$FLUTTER_EXTRACT_DIR/flutter/bin:\$PATH\"" >> ~/.bashrc
source ~/.bashrc

# Verify the installation
echo "Verifying Flutter installation..."
flutter --version
dart --version