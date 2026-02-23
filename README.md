<p style="text-align: center;">
  <img src="https://raw.githubusercontent.com/ChinaFLTV/Shiba/main/assets/icon/app_icon.png" alt="Shiba Logo" width="128" height="128">
</p>

<h1 style="text-align: center;">Shiba</h1>

<p style="text-align: center;">
  在手机上运行 AI 大语言模型，离线私密对话。
</p>

<p style="text-align: center;">
  可以把它理解为移动端的 <a href="https://ollama.com/">Ollama</a>。🐕
</p>

<p style="text-align: center;">
  Shiba 不会让你变成 AI 研究员……但可能会让你觉得自己是。<br>
  无需云端，无需 API Key，数据不离开设备。只有你和本地大模型的对话。
</p>

<p style="text-align: center;">
  简体中文 · <a href="README_EN.md">English</a>
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
<summary>目录</summary>

- [为什么选择 Shiba？](#为什么选择-shiba)
- [功能特性](#功能特性)
- [截图预览](#截图预览)
- [快速开始](#快速开始)
  - [环境要求](#环境要求)
  - [安装](#安装)
  - [从源码构建](#从源码构建)
- [支持的模型](#支持的模型)
- [项目结构](#项目结构)
- [国际化](#国际化)
- [参与贡献](#参与贡献)
- [常见问题](#常见问题)
- [许可证](#许可证)
- [致谢](#致谢)

</details>

## 为什么选择 Shiba？

[Ollama](https://ollama.com/) 让在 PC 上运行大模型变得无比简单。Shiba 把同样的体验带到了手机上。

不需要搭建服务器，不需要记命令行。从 Hugging Face 下载模型，点击开始，就能对话——全部在设备上完成，全程离线，完全私密。如果说 Ollama 是桌面端的大模型利器，那 Shiba 就是你口袋里的 AI 伙伴。

## 功能特性

| 特性                   | 说明                                                                                                         |
|:---------------------|:-----------------------------------------------------------------------------------------------------------|
| 🤖 本地大模型推理           | 通过 [llama.cpp](https://github.com/ggml-org/llama.cpp) 直接在设备上运行 GGUF 模型，支持多阶段回退策略（GPU → CPU → 最小上下文），最大化兼容性 |
| 🔒 完全离线与隐私           | 所有推理在本地完成，无需云端、无需 API Key，数据永远不会离开你的手机                                                                     |
| 👁️ 多模态图片理解          | 向视觉模型（LLaVA、MiniCPM-V 等）发送图片，自动检测并加载 mmproj 视觉投影器                                                          |
| 🗣️ 文字转语音（TTS）       | 内置离线 TTS 引擎，基于 [sherpa-onnx](https://github.com/k2-fsa/sherpa-onnx) MeloTTS，可朗读 AI 回复，支持调节语速               |
| 🎙️ 语音转文字（STT）       | 离线语音输入，基于 SenseVoice 模型，支持中文、英文、日语、韩语、粤语，解放双手与模型对话                                                         |
| 📥 Hugging Face 模型中心 | 直接在应用内浏览、搜索、下载 GGUF 模型，国内用户自动使用 hf-mirror.com 镜像                                                           |
| ⏸️ 下载管理              | 支持暂停、续传、取消模型下载，断点续传，实时进度追踪                                                                                 |
| 💬 多会话管理             | 创建和管理多个聊天会话，完整消息历史持久化存储在 SQLite 中                                                                          |
| ✏️ 消息编辑与重发           | 编辑已发送的消息，从该节点重新生成 AI 回复                                                                                    |
| 🗑️ 批量消息操作           | 长按进入选择模式，多选消息，批量删除                                                                                         |
| 🖼️ 图片压缩             | 发送图片前可配置压缩参数（分辨率、质量），减少视觉模型处理负担                                                                            |
| ⚙️ 会话级参数设置           | 每个会话独立配置系统提示词、Temperature、Top-K、Top-P、最大生成长度、历史轮数                                                          |
| 🌍 多语言界面             | 支持中文、英文、繁體中文、德语、法语                                                                                         |
| 🎨 Material Design 3 | 简洁现代的 UI，支持亮色/暗色/跟随系统主题切换                                                                                  |
| 🛡️ 硬件兼容性检测          | 自动检测 CPU 特性（I8MM）、GPU 稳定性（Vulkan DeviceLost），不兼容时优雅降级                                                      |
| 📊 详细诊断信息            | 丰富的错误报告，包含 GGUF 校验、文件完整性哈希、SoC 信息、多阶段加载诊断                                                                  |

## 截图预览

<p style="text-align: center;">
  <img src="https://raw.githubusercontent.com/ChinaFLTV/Shiba/main/docs/screenshots/screenshot-1.jpg" alt="截图1" width="250">
  <img src="https://raw.githubusercontent.com/ChinaFLTV/Shiba/main/docs/screenshots/screenshot-2.jpg" alt="截图2" width="250">
  <img src="https://raw.githubusercontent.com/ChinaFLTV/Shiba/main/docs/screenshots/screenshot-3.jpg" alt="截图3" width="250">
</p>

## 快速开始

### 环境要求

| 依赖          | 版本                   |
|:------------|:---------------------|
| Flutter     | ≥ 3.16.0             |
| Dart        | ≥ 3.2.0              |
| Android SDK | API 33+（Android 13+） |
| NDK         | 27.0.12077973        |

设备需要较新的 SoC，推荐 ARMv8.6-A+（支持 I8MM 指令集），如骁龙 8 Gen 1 及以上。内存越大，可运行的模型越大。

### 安装

从 [Releases](https://github.com/ChinaFLTV/Shiba/releases) 页面下载最新 APK，安装到 Android 设备即可。

### 从源码构建

1. 克隆仓库：

    ```bash
    git clone https://github.com/ChinaFLTV/Shiba.git
    cd Shiba
    ```

2. 安装依赖：

    ```bash
    flutter pub get
    ```

3. 生成代码（Riverpod 生成器、本地化文件）：

    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4. 运行应用：

    ```bash
    flutter run
    ```

5. 构建 Release APK（已开启代码压缩和混淆）：

    ```bash
    flutter build apk --release
    ```

> [!NOTE]
> Release 构建已开启 ProGuard 代码压缩、资源压缩和混淆。ProGuard 规则已为所有原生插件（llama.cpp、sherpa-onnx、sqflite）预配置。

## 支持的模型

Shiba 支持所有与 llama.cpp 兼容的 GGUF 格式模型。可以在应用内直接从 Hugging Face 浏览和下载模型（国内用户自动使用 hf-mirror.com 镜像）。

推荐在移动设备上使用的模型：

| 模型                  | 参数量     | 所需内存    | 备注           |
|:--------------------|:--------|:--------|:-------------|
| Qwen 2.5            | 0.5B–3B | 1–4 GB  | 速度与质量的良好平衡   |
| Llama 3.2           | 1B–3B   | 2–4 GB  | Meta 的紧凑模型   |
| DeepSeek-R1-Distill | 1.5B    | ~1.1 GB | 推理能力强的蒸馏模型   |
| Phi-3 Mini          | 3.8B    | ~4 GB   | 微软的高效小模型     |
| Gemma 2             | 2B      | ~3 GB   | Google 的轻量模型 |

> [!TIP]
> 建议从 Q4_K_M 量化版本开始，这是移动端质量与性能的最佳平衡点。在应用内模型中心搜索 "unsloth" 或 "ggml-org" 可以找到预量化模型。

如需图片理解（多模态）功能，请从同一仓库下载主模型和对应的 `mmproj` 文件。Shiba 会自动检测并加载视觉投影器。

## 项目结构

```
lib/
├── core/              # 常量、工具类、主题、CPU/GPU 硬件检测
├── data/
│   ├── database/      # SQLite 数据库（sqflite）
│   ├── models/        # 数据模型（会话、消息、本地模型、HF 模型）
│   ├── repositories/  # 数据访问层
│   └── services/      # LLM 推理、TTS、STT、下载、Hugging Face API
├── l10n/              # 国际化（ARB 文件 + 生成的 Dart 代码）
├── providers/         # Riverpod 状态管理
├── ui/
│   ├── chat/          # 聊天界面、消息气泡、输入栏
│   ├── home/          # 首页
│   ├── models/        # 模型管理、搜索、下载界面
│   ├── settings/      # 应用设置（主题、语言、TTS/STT、推理参数）
│   └── shared/        # 可复用对话框（TTS/STT 下载进度）
├── app.dart           # 应用根组件
└── main.dart          # 入口文件
```

- 状态管理：[Riverpod](https://riverpod.dev/)（带代码生成）
- 本地存储：SQLite（[sqflite](https://pub.dev/packages/sqflite)）
- LLM 推理：[llamadart](https://pub.dev/packages/llamadart)（llama.cpp 的 Dart 绑定）
- 语音：[sherpa-onnx](https://github.com/k2-fsa/sherpa-onnx)，TTS 使用 MeloTTS，STT 使用 SenseVoice

## 国际化

Shiba 开箱即用支持 5 种语言：

| 语言       | 代码        |
|:---------|:----------|
| English  | `en`      |
| 简体中文     | `zh`      |
| 繁體中文     | `zh_Hant` |
| Deutsch  | `de`      |
| Français | `fr`      |

添加新语言：在 `lib/l10n/` 下创建 `app_<语言代码>.arb` 文件，然后运行 `flutter gen-l10n`。

## 参与贡献

我们欢迎各种形式的贡献——Bug 修复、新功能、翻译、文档改进，每一份贡献都很重要。

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'feat: 添加某个功能'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 发起 Pull Request

提交前请确保代码风格一致，并通过 `flutter analyze` 检查。

## 常见问题

**Q：Shiba 和 Ollama 是什么关系？**
A：Ollama 是桌面端运行大模型的首选工具。Shiba 把同样的理念带到了移动端——简单、本地、私密。两者没有代码关联，但精神一脉相承。

**Q：支持哪些设备？**
A：Android 13+（API 33+）且 CPU 支持 ARMv8.6-A+（I8MM）的设备。推荐骁龙 8 Gen 1 及以上。iOS 支持在计划中。

**Q：模型需要多少存储空间？**
A：因模型而异。量化后的 1–3B 模型通常在 0.5 GB 到 2.5 GB 之间。TTS 模型约 170 MB，STT 模型约 230 MB。

**Q：可以使用自己的 GGUF 模型吗？**
A：可以。通过应用内模型中心从 Hugging Face 下载任何 GGUF 模型即可。

**Q：支持 GPU 加速吗？**
A：支持。Shiba 会自动检测最佳后端（Vulkan/Metal/CPU），如果 GPU 推理不稳定会自动回退到 CPU。

**Q：为什么推理速度很慢？**
A：推理速度取决于 SoC、内存和模型大小。尝试使用更小或量化程度更高的模型（如 Q4_K_S 或 IQ4_XS）。

**Q：国内可以下载模型吗？**
A：可以。Shiba 默认使用 hf-mirror.com 作为 Hugging Face 镜像，TTS/STT 模型下载也支持镜像回退。

## 许可证

本项目基于 [MIT 许可证](https://opensource.org/licenses/MIT) 发布。

## 致谢

Shiba 基于以下优秀的开源项目构建：

- [llama.cpp](https://github.com/ggml-org/llama.cpp) — 大模型推理引擎
- [llamadart](https://pub.dev/packages/llamadart) — llama.cpp 的 Dart 绑定
- [sherpa-onnx](https://github.com/k2-fsa/sherpa-onnx) — 端侧语音处理（TTS & STT）
- [Flutter](https://flutter.dev/) — UI 框架
- [Riverpod](https://riverpod.dev/) — 状态管理
- [Hugging Face](https://huggingface.co/) — 模型中心

---

<p style="text-align: center;">
  用 ❤️ 为端侧 AI 而作
</p>
