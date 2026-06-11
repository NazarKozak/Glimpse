//
//  Glimpse.swift
//  Glimpse
//
//  Created by Nazar Kozak on 11.06.2026.
//
//  On-device image understanding in a few lines of Swift. A task-focused façade
//  over MLX Swift's VLM stack — caption, ask (VQA), tag, and OCR with a small
//  vision-language model running fully on device. No cloud, no API keys.
//

import Foundation
import CoreGraphics
import CoreImage
import MLXVLM
import MLXLMCommon
import MLXHuggingFace
import HuggingFace
import Tokenizers

/// A small on-device vision-language model.
public enum VisionModel: Sendable {
    /// SmolVLM-Instruct (4-bit) — small and fast; a good default.
    case smolVLM
    /// Apple's FastVLM — very low latency on Apple silicon.
    case fastVLM
    /// Qwen2.5-VL 3B (4-bit) — stronger, larger.
    case qwen2_5VL_3B
    /// Any MLX `ModelConfiguration` (e.g. from `VLMRegistry`, or a custom Hugging Face id).
    case custom(ModelConfiguration)

    var configuration: ModelConfiguration {
        switch self {
        case .smolVLM: VLMRegistry.smolvlm
        case .fastVLM: VLMRegistry.fastvlm
        case .qwen2_5VL_3B: VLMRegistry.qwen2_5VL3BInstruct4Bit
        case .custom(let configuration): configuration
        }
    }
}

/// An image to analyze.
public enum VisionInput: @unchecked Sendable {
    case url(URL)
    case cgImage(CGImage)
    case ciImage(CIImage)

    var mlxImage: UserInput.Image {
        switch self {
        case .url(let url): .url(url)
        case .ciImage(let image): .ciImage(image)
        case .cgImage(let image): .ciImage(CIImage(cgImage: image))
        }
    }
}

/// On-device image understanding.
///
/// ```swift
/// let glimpse = Glimpse(model: .smolVLM)
/// let caption = try await glimpse.caption(.cgImage(photo))
/// let answer  = try await glimpse.ask("How many people are here?", about: .url(fileURL))
/// ```
public actor Glimpse {
    public let model: VisionModel
    private var container: ModelContainer?

    public init(model: VisionModel = .smolVLM) {
        self.model = model
    }

    /// Downloads (if needed) and loads the model. Optional — otherwise it loads
    /// lazily on the first request. `onProgress` reports download progress 0…1.
    public func load(onProgress: (@Sendable (Double) -> Void)? = nil) async throws {
        _ = try await ensureLoaded(onProgress: onProgress)
    }

    /// Generic: describe an image with your own instruction.
    public func describe(_ input: VisionInput, prompt: String) async throws -> String {
        let container = try await ensureLoaded()
        let session = ChatSession(container)
        return try await session.respond(to: prompt, image: input.mlxImage)
    }

    /// A one-sentence caption.
    public func caption(_ input: VisionInput) async throws -> String {
        try await describe(input, prompt: "Describe this image in one concise sentence.")
    }

    /// Answer a question about the image (visual question answering).
    public func ask(_ question: String, about input: VisionInput) async throws -> String {
        try await describe(input, prompt: question)
    }

    /// Transcribe visible text (OCR).
    public func readText(in input: VisionInput) async throws -> String {
        try await describe(input, prompt: "Transcribe all text visible in this image. Output only the text, nothing else.")
    }

    /// Short tags for the main objects/concepts.
    public func tags(in input: VisionInput, max: Int = 8) async throws -> [String] {
        let raw = try await describe(
            input,
            prompt: "List up to \(max) short tags (one or two words each) for the main objects and concepts in this image, separated by commas. Output only the tags."
        )
        return Self.parseTags(raw, max: max)
    }

    // MARK: - Internals

    private func ensureLoaded(onProgress: (@Sendable (Double) -> Void)? = nil) async throws -> ModelContainer {
        if let container { return container }
        let loaded = try await loadModelContainer(
            from: #hubDownloader(),
            using: #huggingFaceTokenizerLoader(),
            configuration: model.configuration,
            progressHandler: { progress in onProgress?(progress.fractionCompleted) }
        )
        container = loaded
        return loaded
    }

    static func parseTags(_ raw: String, max: Int) -> [String] {
        let parts = raw
            .split(whereSeparator: { $0 == "," || $0 == "\n" })
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return Array(parts.prefix(max))
    }
}
