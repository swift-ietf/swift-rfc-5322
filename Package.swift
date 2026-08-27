// swift-tools-version: 6.4

import PackageDescription

extension String {
    static let rfc5322: Self = "RFC 5322"
    static let rfc5322Foundation: Self = "RFC 5322 Foundation"
}

extension Target.Dependency {
    static var rfc5322: Self { .target(name: .rfc5322) }
    static var rfc5322Foundation: Self { .target(name: .rfc5322Foundation) }
    static var rfc1123: Self { .product(name: "RFC 1123", package: "swift-rfc-1123") }
    static var standards: Self {
        .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions")
    }
    static var binary: Self {
        .product(name: "Binary", package: "swift-binary")
    }
    static var radixFormat: Self {
        .product(name: "Radix Formatter", package: "swift-radix-formatter")
    }
    static var binarySerializable: Self {
        .product(
            name: "Binary Serializable",
            package: "swift-binary-serializer"
        )
    }
    static var time: Self { .product(name: "Time", package: "swift-time") }
    static var asciiSerializer: Self {
        .product(name: "ASCII Serializer", package: "swift-ascii-serializer")
    }
    static var asciiDecimalParser: Self {
        .product(name: "ASCII Decimal Parser", package: "swift-ascii-parser")
    }
    static var asciiParser: Self {
        .product(name: "Parseable ASCII", package: "swift-ascii-parser")
    }
}

let package = Package(
    name: "swift-rfc-5322",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "RFC 5322", targets: ["RFC 5322"]),
        .library(name: "RFC 5322 Foundation", targets: ["RFC 5322 Foundation"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-ietf/swift-rfc-1123.git", branch: "main"),
        .package(
            url: "https://github.com/swift-molecules/swift-standard-library-extensions.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-binary.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-radix-formatter.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-binary-serializer.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-time.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ascii-serializer.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ascii-parser.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-incits/swift-incits-4-1986.git", branch: "main"),
        .package(
            url: "https://github.com/swift-molecules/swift-parser.git",
            branch: "main"
        ),
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
                .asciiParser,
                .product(name: "INCITS 4 1986", package: "swift-incits-4-1986"),
                .product(name: "Parser", package: "swift-parser"),
            ]
        ),
        .target(
            name: "RFC 5322 Foundation",
            dependencies: [
                .rfc5322,
                .binarySerializable,
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
                .asciiParser,
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
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
