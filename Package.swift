// swift-tools-version: 6.2

import PackageDescription

extension String {
    static let rfc5322: Self = "RFC 5322"
    static let rfc5322Foundation: Self = "RFC 5322 Foundation"
}

extension Target.Dependency {
    static var rfc5322: Self { .target(name: .rfc5322) }
    static var rfc5322Foundation: Self { .target(name: .rfc5322Foundation) }
    static var rfc1123: Self { .product(name: "RFC 1123", package: "swift-rfc-1123") }
    static var standards: Self { .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions") }
    static var binary: Self { .product(name: "Binary Primitives", package: "swift-binary-primitives") }
    static var radixFormat: Self { .product(name: "Radix Format Primitives", package: "swift-radix-formatter-primitives") }
    static var binarySerializable: Self { .product(name: "Binary Serializable Primitives", package: "swift-binary-serializer-primitives") }
    static var time: Self { .product(name: "Time Primitives", package: "swift-time-primitives") }
    static var asciiSerializer: Self {
        .product(name: "ASCII Serializer Primitives", package: "swift-ascii-serializer-primitives")
    }
    static var asciiDecimalParser: Self {
        .product(name: "ASCII Decimal Parser Primitives", package: "swift-ascii-parser-primitives")
    }
    static var incits_4_1986: Self {
        .product(name: "INCITS 4 1986", package: "swift-incits-4-1986")
    }
}

let package = Package(
    name: "swift-rfc-5322",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(name: "RFC 5322", targets: ["RFC 5322"]),
        .library(name: "RFC 5322 Foundation", targets: ["RFC 5322 Foundation"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-ietf/swift-rfc-1123.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-standard-library-extensions.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-binary-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-radix-formatter-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-binary-serializer-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-time-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-ascii-serializer-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-ascii-parser-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-incits/swift-incits-4-1986.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-parser-primitives.git", branch: "main")
    ],
    targets: [
        .target(
            name: "RFC 5322",
            dependencies: [
                .standards,
                .binary,
                .radixFormat,
                .binarySerializable,
                .time,
                .rfc1123,
                .asciiSerializer,
                .asciiDecimalParser,
                .incits_4_1986,
                .product(name: "Parser Primitives", package: "swift-parser-primitives")
            ]
        ),
        .target(
            name: "RFC 5322 Foundation",
            dependencies: [
                .rfc5322,
                .binarySerializable
            ]
        ),
        .testTarget(
            name: "RFC 5322 Foundation Tests",
            dependencies: [
                "RFC 5322",
                "RFC 5322 Foundation",
            ]
        ),
        .testTarget(
            name: "RFC 5322 Tests",
            dependencies: [
                "RFC 5322",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
    var foundation: Self { self + " Foundation" }
}

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
