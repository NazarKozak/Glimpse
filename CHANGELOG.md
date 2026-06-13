# Changelog

Format follows [Keep a Changelog](https://keepachangelog.com/); versions follow SemVer.

## [Unreleased]

### Added
- `GlimpseDemo` Xcode project — pick a photo, choose a task (Caption / Ask / Tags / OCR),
  pick a model, and run on-device with model-download progress.

## [0.1.0] - 2026-06-11

Initial public release.

### Added
- `Glimpse` actor — on-device image understanding over MLX Swift VLMs.
- Task presets: `caption`, `ask` (VQA), `tags`, `readText` (OCR), and generic `describe`.
- Models: `.smolVLM`, `.fastVLM`, `.qwen2_5VL_3B`, and `.custom(ModelConfiguration)`.
- Model download + cache from Hugging Face with progress (`load(onProgress:)`).
- `VisionInput` for CGImage / CIImage / file URL.
