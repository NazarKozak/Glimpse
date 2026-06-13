# Glimpse

![Swift 6](https://img.shields.io/badge/Swift-6-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2017%2B%20%7C%20macOS%2014%2B-blue.svg)
![SPM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

**On-device image understanding in a few lines of Swift.** Caption, ask questions, tag, and read text from images with a small vision-language model running fully on device — no cloud, no API keys, nothing leaves the phone.

It's a task-focused façade over Apple's [MLX Swift](https://github.com/ml-explore/mlx-swift-lm) VLM stack: you pick a model, you get `caption` / `ask` / `tags` / `readText`. WhisperKit, but for vision.

```swift
import Glimpse

let glimpse = Glimpse(model: .smolVLM)

let caption = try await glimpse.caption(.cgImage(photo))
let answer  = try await glimpse.ask("How many people are in this photo?", about: .url(fileURL))
let tags    = try await glimpse.tags(in: .cgImage(photo))      // ["dog", "park", "frisbee", …]
let text    = try await glimpse.readText(in: .cgImage(receipt)) // OCR
```

## Why Glimpse

On-device VLMs are finally good enough (Apple's **FastVLM**, **SmolVLM**, Qwen2.5-VL…), and MLX Swift can run them — but it's a low-level runtime. You still wire up model download, image preprocessing, prompt templating, tokenization, and session management yourself. Glimpse is that glue, with a task-shaped API:

- 🔒 **Fully on-device** — private, offline, no key, no per-call cost.
- 🧩 **Task presets** — `caption`, `ask` (VQA), `tags`, `readText` (OCR), or `describe` with your own prompt.
- 🔀 **Swappable models** — SmolVLM (small/fast), FastVLM (low-latency), Qwen2.5-VL (stronger), or any MLX `ModelConfiguration`.
- 📥 **Model management** — downloads + caches the weights from Hugging Face, with progress.

## Install

```swift
.package(url: "https://github.com/NazarKozak/Glimpse.git", from: "0.1.0")
```

Add `"Glimpse"` to your target. Requires **iOS 17+ / macOS 14+** on **Apple silicon** (MLX runs on the GPU).

## Models

```swift
Glimpse(model: .smolVLM)        // SmolVLM-Instruct 4-bit — small, fast (default)
Glimpse(model: .fastVLM)        // Apple FastVLM — low latency
Glimpse(model: .qwen2_5VL_3B)   // Qwen2.5-VL 3B 4-bit — stronger
Glimpse(model: .custom(VLMRegistry.gemma3_4B_qat_4bit))  // any MLX configuration
```

The weights download from Hugging Face on first use and are cached. Pre-warm with progress:

```swift
let glimpse = Glimpse(model: .smolVLM)
try await glimpse.load { fraction in print("downloading \(Int(fraction * 100))%") }
```

## Input

```swift
.cgImage(cgImage)   // e.g. a camera frame or a UIImage's .cgImage
.ciImage(ciImage)
.url(fileURL)
```

## Demo

Open **`Demo/GlimpseDemo.xcodeproj`**, run on an Apple-silicon device (or simulator), pick a photo,
choose a task, and tap **Run on-device**. It downloads the model on first use (with progress) and
shows the caption / answer / tags / OCR.

> First build prompts to **Trust & Enable** the `MLXHuggingFaceMacros` macro (one-time) and needs the
> **Metal toolchain** (`xcodebuild -downloadComponent MetalToolchain`, or Xcode installs it on demand).

## Notes

- **Models are not bundled** — they download from Hugging Face on first use and are cached, so the app
  stays small. Pre-warm with `load(onProgress:)`.
- Inference runs on the GPU via MLX (Apple silicon). Building the package needs the Metal toolchain.
- Unit tests run in Xcode — the SwiftPM command-line test runner doesn't bundle MLX's Metal library,
  so from the CLI use `swift build` (CI does this).

## Roadmap

- [x] Caption / VQA / tags / OCR over SmolVLM / FastVLM / Qwen2.5-VL
- [x] Model download + cache with progress
- [ ] Streaming tokens (`AsyncSequence`)
- [x] Demo app (pick a photo → caption / VQA / tags / OCR, with download progress)
- [ ] Live camera stream → continuous understanding
- [ ] Multi-turn conversation (follow-up questions about the same image)

## License

MIT — see [LICENSE](LICENSE).
