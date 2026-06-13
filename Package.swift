// swift-tools-version: 6.0
//
//  Package.swift
//  OnDeviceVLMSDK
//
//  Created by Nazar Kozak on 11.06.2026.
//

import PackageDescription

let package = Package(
    name: "OnDeviceVLMSDK",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "OnDeviceVLMSDK", targets: ["OnDeviceVLMSDK"])
    ],
    dependencies: [
        .package(url: "https://github.com/ml-explore/mlx-swift-lm", branch: "main"),
        .package(url: "https://github.com/huggingface/swift-huggingface", from: "0.9.0"),
        .package(url: "https://github.com/huggingface/swift-transformers", from: "1.3.3")
    ],
    targets: [
        .target(
            name: "OnDeviceVLMSDK",
            dependencies: [
                .product(name: "MLXVLM", package: "mlx-swift-lm"),
                .product(name: "MLXLMCommon", package: "mlx-swift-lm"),
                .product(name: "MLXHuggingFace", package: "mlx-swift-lm"),
                .product(name: "HuggingFace", package: "swift-huggingface"),
                .product(name: "Tokenizers", package: "swift-transformers")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "OnDeviceVLMSDKTests",
            dependencies: ["OnDeviceVLMSDK"]
        )
    ]
)
