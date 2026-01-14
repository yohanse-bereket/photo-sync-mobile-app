#!/bin/bash

ANDROID_STUDIO_DOWNLOAD_URL="https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2025.2.2.8/android-studio-2025.2.2.8-linux.tar.gz"
ANDROID_STUDIO_DOWNLOAD_DIR="/home/$USER/Downloads"
ANDROID_STUDIO_EXTRACT_DIR="/usr/local/android-studio"
ANDROID_COMMANDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip"
ANDROID_COMMANDLINE_TOOLS_DOWNLOAD_DIR="/home/$USER/Downloads"
ANDROID_COMMANDLINE_TOOLS_EXTRACT_DIR="/usr/local/cmdline-tools"

set -e

# Clean up any previous installations
echo "Cleaning up previous installations..."
rm -rf "$ANDROID_STUDIO_DOWNLOAD_DIR/android-studio-2025.2.2.8-linux.tar.gz"
sudo rm -rf "$ANDROID_STUDIO_EXTRACT_DIR"
rm -rf "$ANDROID_COMMANDLINE_TOOLS_DOWNLOAD_DIR/commandlinetools-linux-13114758_latest.zip"
sudo rm -rf "$ANDROID_COMMANDLINE_TOOLS_EXTRACT_DIR"

# Create necessary directories
echo "Creating directories..."
mkdir -p "$ANDROID_STUDIO_DOWNLOAD_DIR"
sudo mkdir -p "$ANDROID_STUDIO_EXTRACT_DIR"
mkdir -p "$ANDROID_COMMANDLINE_TOOLS_DOWNLOAD_DIR"
sudo mkdir -p "$ANDROID_COMMANDLINE_TOOLS_EXTRACT_DIR"

# Enable 32-bit architecture
echo "Enabling 32-bit architecture..."
sudo dpkg --add-architecture i386

# Update and install dependencies
echo "Installing dependencies..."
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt install -y libc6:i386 libncurses6:i386 libstdc++6:i386 zlib1g:i386 libbz2-1.0:i386

# Download Android Studio
echo "Downloading Android Studio..."
wget -P "$ANDROID_STUDIO_DOWNLOAD_DIR" "$ANDROID_STUDIO_DOWNLOAD_URL"

# Extract Android Studio
echo "Extracting Android Studio..."
sudo tar -xzf "$ANDROID_STUDIO_DOWNLOAD_DIR/android-studio-2025.2.2.8-linux.tar.gz" -C "$ANDROID_STUDIO_EXTRACT_DIR" --strip-components=1

# Download Android Command Line Tools
echo "Downloading Android Command Line Tools..."
wget -P "$ANDROID_COMMANDLINE_TOOLS_DOWNLOAD_DIR" "$ANDROID_COMMANDLINE_TOOLS_URL"

# Extract Android Command Line Tools
echo "Extracting Android Command Line Tools..."
sudo mkdir -p "$ANDROID_COMMANDLINE_TOOLS_EXTRACT_DIR/latest"
sudo unzip "$ANDROID_COMMANDLINE_TOOLS_DOWNLOAD_DIR/commandlinetools-linux-13114758_latest.zip" -d "$ANDROID_COMMANDLINE_TOOLS_EXTRACT_DIR/latest"

sudo mv /usr/local/cmdline-tools/latest/cmdline-tools/* /usr/local/cmdline-tools/latest/
sudo rmdir /usr/local/cmdline-tools/latest/cmdline-tools
# Set environment variables
# Android Studio and SDK environment variables
echo "export ANDROID_STUDIO_HOME=\"$ANDROID_STUDIO_EXTRACT_DIR\"" >> ~/.bashrc
echo "export ANDROID_SDK_ROOT=\"$ANDROID_COMMANDLINE_TOOLS_EXTRACT_DIR\"" >> ~/.bashrc
echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" >> ~/.bashrc

# Update PATH to include Android Studio, command-line tools, platform-tools, emulator, and Java
echo "export PATH=\"\$ANDROID_STUDIO_HOME/bin:\$ANDROID_SDK_ROOT/latest/cmdline-tools/bin:\$ANDROID_SDK_ROOT/platform-tools:\$ANDROID_SDK_ROOT/emulator:\$JAVA_HOME/bin:\$PATH\"" >> ~/.bashrc



source ~/.bashrc

# Install Java (OpenJDK 11)
echo "Installing OpenJDK 11..."
sudo apt install openjdk-17-jdk -y

# Varify path updates
echo "Verifying PATH updates..."
echo $ANDROID_SDK_ROOT
echo $ANDROID_STUDIO_HOME
echo $PATH


# Install Android SDK components
echo "Installing Android SDK components..."
sdkmanager --install "platform-tools" "platforms;android-33" "emulator" "system-images;android-33;google_apis;x86_64"

# Accept licenses automatically
yes | sdkmanager --licenses

# Verify the installation
echo "Verifying Android Studio installation..."
android-studio --version || echo "Android Studio installed. Please start it from the applications menu."
sdkmanager --list
adb --version
emulator -version
avdmanager list avds
echo "Android Studio and Command Line Tools installation completed successfully."