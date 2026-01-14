# Flutter Project (Linux Only)

This repository contains a Flutter application. This README explains how to install Flutter and Android Studio on **Linux** and how to run the project.

---

## 1. Install Flutter on Linux

### Step 1: Download Flutter SDK

1. Open your browser and go to: [https://flutter.dev](https://flutter.dev)
2. Click **Get started** → **Install** → **Linux**
3. Download the Flutter SDK `.tar.xz` file

### Step 2: Extract Flutter

Open a terminal and run:

```bash
cd ~
tar xf ~/Downloads/flutter_linux_*.tar.xz
```

This extracts Flutter into `~/flutter`.

### Step 3: Add Flutter to PATH

Add Flutter to your PATH so you can run `flutter` commands.

```bash
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

### Step 4: Verify Installation

Run:

```bash
flutter --version
dart --version
```

---

## 2. Install Android Studio on Linux

### Step 1: Download Android Studio

1. Go to [https://developer.android.com/studio](https://developer.android.com/studio)
2. Download **Android Studio for Linux**
3. Extract the downloaded file:

```bash
tar -xvzf ~/Downloads/android-studio-*.tar.gz
```

4. Move it to `/opt`:

```bash
sudo mv ~/Downloads/android-studio /opt/
```

### Step 2: Launch Android Studio

```bash
/opt/android-studio/bin/studio.sh
```

Follow the setup wizard and accept default options.

---

## 3. Install Android SDK and Emulator

1. Open **Android Studio**
2. Go to **More Actions → SDK Manager**
3. Make sure these are installed:

   * Android SDK Platform
   * Android SDK Platform-Tools
   * Android SDK Build-Tools

### (Optional) Create an Emulator

1. Open **Device Manager**
2. Click **Create Device**
3. Choose a device (e.g., Pixel)
4. Download a system image

---

## 4. Configure Flutter with Android

Run:

```bash
flutter doctor
```

If licenses are missing:

```bash
flutter doctor --android-licenses
```

Accept all licenses.

---


## 5. Install Dependencies

```bash
flutter pub get
```

---

## 7. Run the Application


### Option A: Physical Android Device

1. Enable **Developer Options** and **USB Debugging** on your phone
2. Connect the phone via USB
3. Run:

```bash
flutter run
```

---

## Troubleshooting

* Run `flutter doctor` and follow suggested fixes
* Make sure an device is running
* Restart Android Studio if SDK is not detected