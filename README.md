<img src="https://capsule-render.vercel.app/api?type=waving&color=0:6C3483,100:02569B&height=200&section=header&text=FunSwap&fontSize=80&fontColor=ffffff&fontAlignY=38&desc=Convert.%20Compress.%20Manage.%20All%20Offline.&descAlignY=60&descSize=18" width="100%"/>

<div align="right">

[![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![FFmpeg](https://img.shields.io/badge/FFmpeg-powered-007808?style=for-the-badge)](https://ffmpeg.org)
[![License](https://img.shields.io/badge/MIT-license-F59E0B?style=for-the-badge)](LICENSE)

</div>

---

```
  No servers.   No uploads.   No tracking.
  Every conversion happens on your device.
```

---

<br/>

<table>
<tr>
<td width="50%" valign="top">

### 🎬 Audio & Video
FFmpeg running fully on-device.
Real-time progress. Zero upload.

`MP4` `MKV` `AVI` `MOV` `MP3` `WAV` `AAC` `FLAC`

</td>
<td width="50%" valign="top">

### 🖼 Images
Pixel-level processing with custom
quality and compression controls.

`PNG` `JPG` `JPEG` `WebP` `BMP` `ICO`

</td>
</tr>
<tr>
<td width="50%" valign="top">

### 📄 Documents
Background `Isolate` processing —
large files, zero UI freezes.

`DOCX→PDF` `XLSX→CSV` `CSV→XLSX` `→PDF`

</td>
<td width="50%" valign="top">

### 🌐 Languages
Instant on-the-fly UI rebuilds.
No restart needed.

`Uzbek` `Russian` `English`

</td>
</tr>
</table>

<br/>

---

## Architecture

```
  ┌─────────────────────────────────────────┐
  │           PRESENTATION                  │
  │   Screens  ·  Widgets  ·  BLoC/Cubit   │
  └───────────────────┬─────────────────────┘
                      │
  ┌───────────────────▼─────────────────────┐
  │              DOMAIN                     │
  │   Entities  ·  Use Cases  ·  Repos      │
  │   Pure Dart — zero dependencies         │
  └───────────────────┬─────────────────────┘
                      │
  ┌───────────────────▼─────────────────────┐
  │               DATA                      │
  │   FFmpeg  ·  Isolates  ·  Preferences  │
  │   Repository implementations            │
  └─────────────────────────────────────────┘
```

> Adding a new converter = one Use Case + one Data Source. Nothing else changes.

<br/>

---

## Engineering Highlights

&nbsp;&nbsp;🧵 &nbsp;**Multithreading** — CSV→Excel and Image→PDF run in background `Isolate`s. Zero UI freezes on large files.

&nbsp;&nbsp;🛡 &nbsp;**Memory Safety** — File size gates before loading. OOM crashes eliminated.

&nbsp;&nbsp;🔄 &nbsp;**BLoC Refactor** — Direct repo calls removed from UI layer. Fully decoupled presentation.

&nbsp;&nbsp;⚙️ &nbsp;**PreferencesService** — Theme, notifications, auto-delete unified under one service.

<br/>

---

## Quick Start

```bash
git clone https://github.com/aza4k/FunSwap.git && cd FunSwap

flutter pub get
flutter pub run flutter_launcher_icons
flutter run
```

**Prerequisites:** Flutter `3.22+` · Dart `3.4+` · Android SDK or iOS environment

<br/>

---

## Stack

```yaml
framework:    Flutter 3.22+  /  Dart 3.4+
state:        BLoC / Cubit
architecture: Clean Architecture
media:        FFmpeg Kit Flutter
documents:    xml · excel · pdf · csv
storage:      SharedPreferences → PreferencesService
```

<br/>

---

## Project Structure

```
lib/
├── core/
│   ├── services/
│   │   ├── ffmpeg_service.dart
│   │   ├── preferences_service.dart
│   │   └── isolate_worker.dart
│   └── utils/
│       └── file_size_guard.dart
├── features/
│   ├── video/       # data · domain · presentation
│   ├── document/    # data · domain · presentation
│   └── image/       # data · domain · presentation
├── l10n/            # uz · ru · en
└── main.dart
```

<br/>

---

<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:02569B,100:6C3483&height=120&section=footer" width="100%"/>

MIT License · © [aza4k](https://github.com/aza4k) · Developed by **[fundev](https://fundev.uz)**

</div>
