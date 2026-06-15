# FunSwap

FunSwap is a high-performance, offline-first mobile application built with Flutter that enables users to convert, compress, and manage files locally on their device. 

The application utilizes native compilation, multithreading, and low-level processing libraries to support conversions across images, documents, audio, and video files without relying on external servers, ensuring user privacy and data security.

## Core Capabilities

- **Offline Media Transcoding**: Uses FFmpeg to convert and transcode audio and video files locally with real-time progress monitoring.
- **Isolate-driven Document Processing**: Parses XML document trees (`docx`), Excel sheets (`xlsx`), and CSV streams, and generates PDF documents. Large operations are offloaded to background isolates to prevent UI thread blocking.
- **Image Manipulation & Serialization**: Fast image processing (PNG, JPG, JPEG, WebP, BMP, ICO) with custom quality controls.
- **Session Persistence & State Isolation**: Clean architecture design using BLoC/Cubit for decoupled business logic and SharedPreferences for persistent user settings.
- **Multilingual Support**: Supports Uzbek, Russian, and English with instant on-the-fly UI rebuilds.

## Architecture

FunSwap conforms to Clean Architecture guidelines divided into three main layers:
- **Presentation**: UI screens, platform widgets, and state controllers (BLoC/Cubit).
- **Domain**: Business rules (Entities, Repositories, Use Cases).
- **Data**: Infrastructure details (Data sources, Repository implementations, local services).

This separation of concerns makes it easy to add new converters or customize saving and tracking features.

## Getting Started

### Prerequisites

- Flutter SDK (v3.22.0 or higher recommended)
- Dart SDK (v3.4.0 or higher)
- Android SDK / iOS Development Environment

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/aza4k/FunSwap.git
   cd FunSwap
   ```

2. Fetch dependencies:
   ```bash
   flutter pub get
   ```

3. Generate custom assets (launcher icons):
   ```bash
   flutter pub run flutter_launcher_icons
   ```

4. Build and run:
   ```bash
   flutter run
   ```

## Development & Refactoring Achievements

During recent refactoring cycles, the codebase underwent substantial structural cleanups:
- **Presentation Decoupling**: Direct repository requests inside the presentation layer were refactored into a BLoC/Cubit state pattern.
- **Multithreading Integration**: Heavy processes like CSV-to-Excel and Image-to-PDF compilation were shifted from the main event loop to separate `Isolate`s, resolving application hangs on large files.
- **Storage Centralization**: Transient user settings (theme, notifications, auto-delete intervals) were centralized under a unified `PreferencesService` using `shared_preferences`.
- **Warning Thresholds**: Added file size safety gates to prevent device Out-Of-Memory (OOM) crashes by warning users before loading exceptionally large files.

<div align="center">

MIT License · © [aza4k](https://github.com/aza4k)

<br/>

Developed by **[fundev](https://fundev.uz)** Team

</div>
