//
//  VisionController.swift
//  GlimpseDemo
//
//  Created by Nazar Kozak on 12.06.2026.
//

import SwiftUI
import Glimpse

@MainActor
@Observable
final class VisionController {
    /// Models exposed in the demo (Glimpse's `VisionModel` has an associated value, so
    /// we keep a small Hashable enum for the picker).
    enum Model: String, CaseIterable, Identifiable {
        case smolVLM = "SmolVLM"
        case fastVLM = "FastVLM"
        case qwen = "Qwen2.5-VL"
        var id: String { rawValue }
        var visionModel: VisionModel {
            switch self {
            case .smolVLM: .smolVLM
            case .fastVLM: .fastVLM
            case .qwen: .qwen2_5VL_3B
            }
        }
    }

    enum Task: String, CaseIterable, Identifiable {
        case caption = "Caption"
        case ask = "Ask"
        case tags = "Tags"
        case ocr = "OCR"
        var id: String { rawValue }
    }

    var model: Model = .smolVLM { didSet { glimpse = Glimpse(model: model.visionModel); loaded = false } }
    var task: Task = .caption
    var question = "What is in this image?"
    var image: UIImage?

    var result = ""
    var status = "Pick a photo to start."
    var downloadProgress: Double?
    var isBusy = false
    private(set) var loaded = false

    private var glimpse = Glimpse(model: .smolVLM)

    func run() async {
        guard let cgImage = image?.cgImage else { status = "Pick a photo first."; return }
        isBusy = true
        result = ""
        let input = VisionInput.cgImage(cgImage)
        let started = ContinuousClock.now
        do {
            if !loaded {
                status = "Loading \(model.rawValue)…"
                try await glimpse.load { [weak self] fraction in
                    _Concurrency.Task { @MainActor in self?.downloadProgress = fraction }
                }
                downloadProgress = nil
                loaded = true
            }
            status = "Thinking…"
            switch task {
            case .caption: result = try await glimpse.caption(input)
            case .ask: result = try await glimpse.ask(question, about: input)
            case .tags: result = try await glimpse.tags(in: input).joined(separator: " · ")
            case .ocr: result = try await glimpse.readText(in: input)
            }
            let elapsed = started.duration(to: .now)
            status = "Done in \(elapsed.formatted(.units(allowed: [.seconds], fractionalPart: .show(length: 1))))"
        } catch {
            result = ""
            status = "Error: \(error.localizedDescription)"
        }
        downloadProgress = nil
        isBusy = false
    }
}
