//
//  ContentView.swift
//  OnDeviceVLMSDKDemo
//
//  Created by Nazar Kozak on 12.06.2026.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var vision = VisionController()
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    imageArea
                    controls
                    if vision.isBusy { progressArea }
                    if !vision.result.isEmpty { resultCard }
                    Text(vision.status)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("OnDeviceVLM")
            .onChange(of: pickerItem) { _, item in loadImage(item) }
        }
    }

    private var imageArea: some View {
        ZStack {
            if let image = vision.image {
                Image(uiImage: image)
                    .resizable().scaledToFit()
                    .frame(maxHeight: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.gray.opacity(0.15))
                    .frame(height: 220)
                    .overlay {
                        ContentUnavailableView("No photo", systemImage: "photo.on.rectangle.angled")
                    }
            }
        }
    }

    private var controls: some View {
        VStack(spacing: 12) {
            PhotosPicker(selection: $pickerItem, matching: .images) {
                Label(vision.image == nil ? "Choose photo" : "Change photo", systemImage: "photo")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Picker("Model", selection: $vision.model) {
                ForEach(VisionController.Model.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .disabled(vision.isBusy)

            Picker("Task", selection: $vision.task) {
                ForEach(VisionController.Task.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .disabled(vision.isBusy)

            if vision.task == .ask {
                TextField("Ask about the image…", text: $vision.question)
                    .textFieldStyle(.roundedBorder)
                    .disabled(vision.isBusy)
            }

            Button {
                _Concurrency.Task { await vision.run() }
            } label: {
                Label("Run on-device", systemImage: "sparkles")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(vision.isBusy || vision.image == nil)
        }
    }

    private var progressArea: some View {
        VStack(spacing: 6) {
            if let progress = vision.downloadProgress {
                ProgressView(value: progress) {
                    Text("Downloading model… \(Int(progress * 100))%").font(.caption)
                }
            } else {
                ProgressView()
            }
        }
    }

    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(vision.task.rawValue.uppercased())
                .font(.caption.weight(.bold)).foregroundStyle(.secondary)
            Text(vision.result)
                .font(.body)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func loadImage(_ item: PhotosPickerItem?) {
        guard let item else { return }
        _Concurrency.Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                vision.image = uiImage
                vision.result = ""
                vision.status = "Ready — pick a task and run."
            }
        }
    }
}

#Preview {
    ContentView()
}
