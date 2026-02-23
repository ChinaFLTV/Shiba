<p style="text-align: center;">
  <img src="https://raw.githubusercontent.com/ChinaFLTV/Shiba/main/assets/icon/app_icon.png" alt="Shiba Logo" width="128" height="128">
</p>

<h1 style="text-align: center;">Shiba</h1>

<p style="text-align: center;">
  Run AI large language models on your phone and chat with them — privately and offline.
</p>

<p style="text-align: center;">
  Think of it as <a href="https://ollama.com/">Ollama</a>, but for your pocket. 🐕
</p>

<p style="text-align: center;">
  Shiba won't make you an AI researcher... but it might make you feel like one.<br>
  No cloud. No API keys. No data leaves your device. Just you and your local LLM.
</p>

<p style="text-align: center;">
  <a href="README.md">简体中文</a> · English
</p>

<p style="text-align: center;">
  <img src="https://img.shields.io/github/v/release/ChinaFLTV/Shiba?style=flat-square&logo=github&label=Release" alt="Release">
  <img src="https://img.shields.io/github/stars/ChinaFLTV/Shiba?style=flat-square&logo=github" alt="Stars">
  <img src="https://img.shields.io/github/forks/ChinaFLTV/Shiba?style=flat-square&logo=github" alt="Forks">
  <img src="https://img.shields.io/github/issues/ChinaFLTV/Shiba?style=flat-square" alt="Issues">
  <img src="https://img.shields.io/badge/License-MIT-blueviolet?style=flat-square" alt="License">
  <img src="https://img.shields.io/badge/Platform-Android-brightgreen?style=flat-square&logo=android" alt="Platform">
  <img src="https://img.shields.io/badge/Flutter-3.16+-blue?style=flat-square&logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.2+-blue?style=flat-square&logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/llama.cpp-powered-orange?style=flat-square" alt="llama.cpp">
</p>

---

<details>
<summary>Table of Contents</summary>

- [Why Shiba?](#why-shiba)
- [Features](#features)
- [Screenshots](#screenshots)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Build from Source](#build-from-source)
- [Supported Models](#supported-models)
- [Architecture](#architecture)
- [Internationalization](#internationalization)
- [Contributing](#contributing)
- [FAQ](#faq)
- [License](#license)
- [Acknowledgments](#acknowledgments)

</details>

## Why Shiba?

[Ollama](https://ollama.com/) made running LLMs on your PC dead simple. Shiba does the same for your phone.

No servers to set up, no terminal commands to memorize. Download a model from Hugging Face, tap play, and start chatting — all on-device, all offline, all private. If Ollama is the desktop powerhouse, Shiba is the mobile companion that goes wherever you go.

## Features

| Feature                      | Description                                                                                                                                                                  |
|:-----------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 🤖 Local LLM Inference       | Run GGUF models directly on-device via [llama.cpp](https://github.com/ggml-org/llama.cpp), with multi-stage fallback (GPU → CPU → minimal context) for maximum compatibility |
| 🔒 Fully Offline & Private   | All inference happens locally. No cloud, no API keys, no data leaves your phone                                                                                              |
| 👁️ Multimodal Vision        | Send images to vision-capable models (LLaVA, MiniCPM-V, etc.) with automatic mmproj detection and loading                                                                    |
| 🗣️ Text-to-Speech           | Built-in offline TTS powered by [sherpa-onnx](https://github.com/k2-fsa/sherpa-onnx) MeloTTS — listen to AI responses with adjustable speed                                  |
| 🎙️ Speech-to-Text           | Offline voice input via SenseVoice — talk to your models hands-free, supporting Chinese, English, Japanese, Korean, and Cantonese                                            |
| 📥 Hugging Face Model Hub    | Browse, search, and download GGUF models directly from Hugging Face with mirror support for China                                                                            |
| ⏸️ Download Management       | Pause, resume, and cancel model downloads with progress tracking and breakpoint resume                                                                                       |
| 💬 Multi-Conversation        | Create and manage multiple chat sessions with full message history persisted in SQLite                                                                                       |
| ✏️ Message Edit & Resend     | Edit any sent message and regenerate the AI response from that point                                                                                                         |
| 🗑️ Batch Message Operations | Long-press to enter selection mode, select multiple messages, and batch delete                                                                                               |
| 🖼️ Image Compression        | Configurable image compression before sending to vision models (resolution, quality)                                                                                         |
| ⚙️ Per-Conversation Settings | Customize system prompt, temperature, top-k, top-p, max tokens, and history rounds per conversation                                                                          |
| 🌍 Multilingual UI           | English, 简体中文, 繁體中文, Deutsch, Français                                                                                                                                       |
| 🎨 Material Design 3         | Clean, modern UI with light/dark/system theme modes and dynamic theming                                                                                                      |
| 🛡️ Hardware Compatibility   | Automatic CPU feature detection (I8MM), GPU stability checks (Vulkan DeviceLost), and graceful degradation                                                                   |
| 📊 Detailed Diagnostics      | Rich error reporting with GGUF validation, file integrity hashing, SoC info, and multi-stage load diagnostics                                                                |

## Screenshots

<p style="text-align: center;">
  <img src="https://raw.githubusercontent.com/ChinaFLTV/Shiba/main/docs/screenshots/screenshot-1.jpg" alt="Screenshot 1" width="250">
  <img src="https://raw.githubusercontent.com/ChinaFLTV/Shiba/main/docs/screenshots/screenshot-2.jpg" alt="Screenshot 2" width="250">
  <img src="https://raw.githubusercontent.com/ChinaFLTV/Shiba/main/docs/screenshots/screenshot-3.jpg" alt="Screenshot 3" width="250">
  <img src="https://raw.githubusercontent.com/ChinaFLTV/Shiba/main/docs/screenshots/screenshot-4.jpg" alt="Screenshot 4" width="250">
</p>

## Getting Started

### Prerequisites

| Requirement | Version               |
|:------------|:----------------------|
| Flutter     | ≥ 3.16.0              |
| Dart        | ≥ 3.2.0               |
| Android SDK | API 33+ (Android 13+) |
| NDK         | 27.0.12077973         |

Your device should have a modern SoC with ARMv8.6-A+ (I8MM support). Snapdragon 8 Gen 1 and newer are recommended. More RAM means you can run larger models.

### Installation

Download the latest APK from the [Releases](https://github.com/ChinaFLTV/Shiba/releases) page and install it on your Android device.

### Build from Source

1. Clone the repository:

    ```bash
    git clone https://github.com/ChinaFLTV/Shiba.git
    cd Shiba
    ```

2. Install dependencies:

    ```bash
    flutter pub get
    ```

3. Generate code (Riverpod generators, localizations):

    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4. Run the app:

    ```bash
    flutter run
    ```

5. Build a release APK (with code shrinking and obfuscation enabled):

    ```bash
    flutter build apk --release
    ```

> [!NOTE]
> Release builds have ProGuard code shrinking, resource shrinking, and obfuscation enabled. The ProGuard rules are pre-configured for all native plugins (llama.cpp, sherpa-onnx, sqflite).

## Supported Models

Shiba supports any GGUF-format model compatible with llama.cpp. Browse and download models directly from Hugging Face within the app (with hf-mirror.com support for users in China).

Recommended models for mobile:

| Model               | Parameters | RAM Required | Notes                              |
|:--------------------|:-----------|:-------------|:-----------------------------------|
| Qwen 2.5            | 0.5B–3B    | 1–4 GB       | Great balance of speed and quality |
| Llama 3.2           | 1B–3B      | 2–4 GB       | Meta's compact models              |
| DeepSeek-R1-Distill | 1.5B       | ~1.1 GB      | Reasoning-focused distilled model  |
| Phi-3 Mini          | 3.8B       | ~4 GB        | Microsoft's efficient small model  |
| Gemma 2             | 2B         | ~3 GB        | Google's lightweight model         |

> [!TIP]
> Start with Q4_K_M quantized versions for the best trade-off between quality and performance on mobile. Search for "unsloth" or "ggml-org" on the in-app model hub for pre-quantized models.

For vision/multimodal support, download both the main model and its corresponding `mmproj` file from the same repository. Shiba will automatically detect and load the vision projector.

## Architecture

```
lib/
├── core/              # Constants, utilities, theme, CPU/GPU hardware checks
├── data/
│   ├── database/      # SQLite via sqflite
│   ├── models/        # Data models (Conversation, Message, LocalModel, HfModel)
│   ├── repositories/  # Data access layer
│   └── services/      # LLM inference, TTS, STT, download, Hugging Face API
├── l10n/              # Localization (ARB files + generated Dart)
├── providers/         # Riverpod state management
├── ui/
│   ├── chat/          # Chat interface, message bubbles, input bar
│   ├── home/          # Home page
│   ├── models/        # Model management, search, download UI
│   ├── settings/      # App settings (theme, language, TTS/STT, inference params)
│   └── shared/        # Reusable dialogs (TTS/STT download progress)
├── app.dart           # App root widget
└── main.dart          # Entry point
```

- State management: [Riverpod](https://riverpod.dev/) with code generation
- Local storage: SQLite via [sqflite](https://pub.dev/packages/sqflite)
- LLM inference: [llamadart](https://pub.dev/packages/llamadart) (Dart bindings for llama.cpp)
- Speech: [sherpa-onnx](https://github.com/k2-fsa/sherpa-onnx) for both TTS (MeloTTS) and STT (SenseVoice)

## Internationalization

Shiba supports 5 languages out of the box:

| Language | Code      |
|:---------|:----------|
| English  | `en`      |
| 简体中文     | `zh`      |
| 繁體中文     | `zh_Hant` |
| Deutsch  | `de`      |
| Français | `fr`      |

To add a new language, create an `app_<code>.arb` file in `lib/l10n/` and run `flutter gen-l10n`.

## Contributing

We welcome contributions of all kinds — bug fixes, new features, translations, documentation improvements.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please make sure your code follows the existing style and passes `flutter analyze` before submitting.

## FAQ

**Q: What's the relationship between Shiba and Ollama?**
A: Ollama is the go-to tool for running LLMs on desktop. Shiba brings the same philosophy to mobile — simple, local, private. They share no code, but the spirit is the same.

**Q: What devices are supported?**
A: Android 13+ (API 33+) devices with ARMv8.6-A+ CPUs. Snapdragon 8 Gen 1 and newer are recommended. iOS support is planned.

**Q: How much storage do models need?**
A: Quantized 1–3B models typically range from 0.5 GB to 2.5 GB. TTS model is ~170 MB, STT model is ~230 MB.

**Q: Can I use my own GGUF models?**
A: Yes. Download any GGUF model from Hugging Face through the in-app model hub.

**Q: Does it support GPU acceleration?**
A: Yes, when available. Shiba auto-detects the best backend (Vulkan/Metal/CPU) and falls back gracefully if GPU inference is unstable.

**Q: Why is inference slow on my device?**
A: Speed depends on your SoC, RAM, and model size. Try a smaller or more aggressively quantized model (e.g., Q4_K_S or IQ4_XS).

**Q: I'm in China, can I download models?**
A: Yes. Shiba uses hf-mirror.com as the default mirror for Hugging Face, and TTS/STT model downloads also support mirror fallback.

## License

This project is released under the [MIT License](https://opensource.org/licenses/MIT).

## Acknowledgments

Shiba is built on the shoulders of these amazing open-source projects:

- [llama.cpp](https://github.com/ggml-org/llama.cpp) — LLM inference engine
- [llamadart](https://pub.dev/packages/llamadart) — Dart bindings for llama.cpp
- [sherpa-onnx](https://github.com/k2-fsa/sherpa-onnx) — On-device TTS & STT
- [Flutter](https://flutter.dev/) — UI framework
- [Riverpod](https://riverpod.dev/) — State management
- [Hugging Face](https://huggingface.co/) — Model hub

---

<p style="text-align: center;">
  Made with ❤️ for on-device AI
</p>
