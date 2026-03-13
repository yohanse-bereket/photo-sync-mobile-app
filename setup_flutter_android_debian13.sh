#!/usr/bin/env bash
# Prepares a clean Debian 13 (Trixie) machine to build a Flutter Android APK.
#
# Usage:
#   REPO_URL="https://github.com/your-org/your-flutter-app.git" \
#   PROJECT_DIR_NAME="your-flutter-app" \
#   bash setup_flutter_android_debian13.sh
#
# Optional overrides:
#   FLUTTER_DIR, ANDROID_HOME, PROJECTS_DIR, ANDROID_API_LEVEL, BUILD_TOOLS_VERSION

set -e

########################################
# Configuration (can be overridden via env vars)
########################################
FLUTTER_DIR="${FLUTTER_DIR:-/opt/flutter}"
ANDROID_HOME="${ANDROID_HOME:-/opt/android-sdk}"
ANDROID_SDK_ROOT="$ANDROID_HOME"
# Preferred URL can be overridden, but Google periodically changes the latest
# file naming format. We therefore support multiple fallbacks below.
CMDLINE_TOOLS_ZIP_URL="${CMDLINE_TOOLS_ZIP_URL:-https://dl.google.com/android/repository/commandlinetools-linux-latest.zip}"
PROFILE_SCRIPT="/etc/profile.d/android-flutter-env.sh"
PROJECTS_DIR="${PROJECTS_DIR:-$HOME/projects}"
REPO_URL="${REPO_URL:-REPO_URL}"
PROJECT_DIR_NAME="${PROJECT_DIR_NAME:-flutter-app}"
ANDROID_API_LEVEL="${ANDROID_API_LEVEL:-34}"
BUILD_TOOLS_VERSION="${BUILD_TOOLS_VERSION:-34.0.0}"

########################################
# Helpers
########################################
log() {
  echo
  echo "==> $*"
}

fail() {
  echo
  echo "ERROR: $*" >&2
  exit 1
}

cleanup() {
  [ -n "${TMP_ZIP:-}" ] && [ -f "$TMP_ZIP" ] && rm -f "$TMP_ZIP"
  [ -n "${TMP_DIR:-}" ] && [ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR"
}
trap cleanup EXIT

download_android_cmdline_tools() {
  # Try user-provided/default URL first, then known fallback revisions used by Google.
  # This avoids hard failures when Google deprecates a "latest" alias.
  local candidate_urls=()
  candidate_urls+=("$CMDLINE_TOOLS_ZIP_URL")
  candidate_urls+=("https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip")
  candidate_urls+=("https://dl.google.com/android/repository/commandlinetools-linux-12266719_latest.zip")
  candidate_urls+=("https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip")

  local url
  for url in "${candidate_urls[@]}"; do
    log "Trying Android command-line tools URL: $url"
    if curl -fL --retry 5 --retry-delay 2 "$url" -o "$TMP_ZIP"; then
      log "Downloaded Android command-line tools from: $url"
      return 0
    fi
    echo "Warning: failed to download from $url, trying next candidate..." >&2
  done

  fail "Unable to download Android command-line tools. Override CMDLINE_TOOLS_ZIP_URL with a valid package URL and re-run."
}

# Use sudo when not running as root.
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
else
  command -v sudo >/dev/null 2>&1 || fail "This script needs root privileges (run as root or install sudo)."
  SUDO="sudo"
fi

# Ensure apt is non-interactive on fresh machines.
export DEBIAN_FRONTEND=noninteractive

########################################
# 1) Install required system dependencies using apt
########################################
log "Updating apt package index..."
$SUDO apt-get update

log "Installing system dependencies (including Java 17)..."
$SUDO apt-get install -y \
  ca-certificates \
  curl \
  git \
  unzip \
  xz-utils \
  zip \
  wget \
  tar \
  file \
  libglu1-mesa \
  libstdc++6 \
  libc6-i386 \
  openjdk-17-jdk

########################################
# 2) Install Java 17 (already installed above) + verify
########################################
log "Verifying Java installation..."
java -version
javac -version

########################################
# 3) Install latest stable Flutter SDK in /opt/flutter
########################################
log "Installing Flutter SDK (stable) into $FLUTTER_DIR ..."
if [ -d "$FLUTTER_DIR/.git" ]; then
  log "Flutter directory already exists. Updating to latest stable..."
  $SUDO git -C "$FLUTTER_DIR" fetch --depth 1 origin stable
  $SUDO git -C "$FLUTTER_DIR" checkout stable
  $SUDO git -C "$FLUTTER_DIR" reset --hard origin/stable
else
  $SUDO rm -rf "$FLUTTER_DIR"
  $SUDO git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

# Ensure current non-root user can use Flutter without sudo.
if [ -n "$SUDO" ]; then
  $SUDO chown -R "$USER":"$USER" "$FLUTTER_DIR"
fi

########################################
# 4) Install Android SDK command line tools
########################################
log "Installing Android SDK command-line tools into $ANDROID_HOME ..."
$SUDO mkdir -p "$ANDROID_HOME/cmdline-tools"
TMP_ZIP="$(mktemp /tmp/cmdline-tools-XXXXXX.zip)"
TMP_DIR="$(mktemp -d /tmp/android-cmdline-tools-XXXXXX)"

log "Downloading Android command-line tools..."
download_android_cmdline_tools

unzip -q "$TMP_ZIP" -d "$TMP_DIR"

# Zip extracts to a directory named cmdline-tools; place it under latest/
$SUDO rm -rf "$ANDROID_HOME/cmdline-tools/latest"
$SUDO mkdir -p "$ANDROID_HOME/cmdline-tools/latest"
$SUDO cp -r "$TMP_DIR/cmdline-tools/." "$ANDROID_HOME/cmdline-tools/latest/"

if [ -n "$SUDO" ]; then
  $SUDO chown -R "$USER":"$USER" "$ANDROID_HOME"
fi

########################################
# 7) Configure environment variables (current + future shells)
########################################
log "Configuring ANDROID_HOME and PATH for current shell and future logins..."

export ANDROID_HOME="$ANDROID_HOME"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$FLUTTER_DIR/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

$SUDO tee "$PROFILE_SCRIPT" >/dev/null <<EOP
# Added by Flutter/Android setup script
export ANDROID_HOME="$ANDROID_HOME"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$FLUTTER_DIR/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:\$PATH"
EOP

# shellcheck disable=SC1090
. "$PROFILE_SCRIPT"

########################################
# 5) Install Android packages automatically
########################################
log "Installing Android SDK packages (platform-tools, build-tools, platforms)..."
# License acceptance first avoids package-install prompts in non-interactive runs.
yes | sdkmanager --sdk_root="$ANDROID_HOME" --licenses >/dev/null

sdkmanager --sdk_root="$ANDROID_HOME" \
  "platform-tools" \
  "build-tools;$BUILD_TOOLS_VERSION" \
  "platforms;android-$ANDROID_API_LEVEL"

########################################
# 6) Accept Android licenses automatically (final pass)
########################################
log "Running final Android SDK license acceptance pass..."
yes | sdkmanager --sdk_root="$ANDROID_HOME" --licenses >/dev/null

########################################
# 8) Verify setup using flutter doctor
########################################
log "Running flutter doctor..."
flutter doctor -v

########################################
# 9) Clone Flutter project
########################################
if [ "$REPO_URL" = "REPO_URL" ]; then
  fail "REPO_URL is still the placeholder value. Run with: REPO_URL='https://github.com/your-org/your-flutter-app.git' bash $0"
fi

log "Cloning Flutter project from $REPO_URL ..."
mkdir -p "$PROJECTS_DIR"
cd "$PROJECTS_DIR"

if [ -d "$PROJECT_DIR_NAME/.git" ]; then
  log "Project directory exists; pulling latest changes..."
  git -C "$PROJECT_DIR_NAME" pull --ff-only
else
  git clone "$REPO_URL" "$PROJECT_DIR_NAME"
fi

cd "$PROJECT_DIR_NAME"

########################################
# 10) Run flutter pub get
########################################
log "Running flutter pub get..."
flutter pub get

########################################
# 11) Build release APK
########################################
log "Building release APK..."
flutter build apk --release

log "Done. APK should be available under: $PROJECTS_DIR/$PROJECT_DIR_NAME/build/app/outputs/flutter-apk/"
log "To load environment variables in a new shell: source $PROFILE_SCRIPT"
