// swift-tools-version: 6.4

import PackageDescription

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
        .library(
            name: "RFC 5322",
            targets: ["RFC 5322"]
        ),
        .library(
            name: "RFC 5322 Foundation",
            targets: ["RFC 5322 Foundation"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-ietf/swift-rfc-1123.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-standard-library-extensions.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-binary.git",
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
            url: "https://github.com/swift-atoms/swift-time.git",
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
        .package(
            url: "https://github.com/swift-incits/swift-incits-4-1986.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-parser.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-byte.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-cursor.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-checkpoint.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-iterator.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-cursor-parser.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-either.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-pair.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-pair-parser.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-iterator-parser.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "RFC 5322",
            dependencies: [
                .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions"),
                .product(name: "Binary", package: "swift-binary"),
                .product(name: "Radix Formatter", package: "swift-radix-formatter"),
                .product(name: "Binary Serializable", package: "swift-binary-serializer"),
                .product(name: "Time", package: "swift-time"),
                .product(name: "RFC 1123", package: "swift-rfc-1123"),
                .product(name: "ASCII Serializer", package: "swift-ascii-serializer"),
                .product(name: "ASCII Decimal Parser", package: "swift-ascii-parser"),
                .product(name: "Parseable ASCII", package: "swift-ascii-parser"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Byte Standard Library Integration", package: "swift-byte"),
                .product(name: "Cursor", package: "swift-cursor"),
                .product(name: "Checkpoint", package: "swift-checkpoint"),
                .product(name: "Iterator", package: "swift-iterator"),
                .product(name: "Iterator Protocol", package: "swift-iterator"),
                .product(name: "Cursor Parser Many", package: "swift-cursor-parser"),
                .product(name: "Cursor Parser Optionally", package: "swift-cursor-parser"),
                .product(name: "Parser Error", package: "swift-parser"),
                .product(name: "Parser Skip", package: "swift-parser"),
                .product(name: "Iterator Parser", package: "swift-iterator-parser"),
                .product(name: "Parser Map", package: "swift-parser"),
                .product(name: "Parser Sequence", package: "swift-parser"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Pair", package: "swift-pair"),
                .product(name: "Pair Parser", package: "swift-pair-parser"),
                .product(name: "INCITS 4 1986", package: "swift-incits-4-1986"),
                .product(name: "Parser", package: "swift-parser"),
            ]
        ),
        .target(
            name: "RFC 5322 Foundation",
            dependencies: [
                .target(name: "RFC 5322"),
                .product(name: "Binary Serializable", package: "swift-binary-serializer"),
                .product(name: "Byte", package: "swift-byte"),
            ]
        ),
        .testTarget(
            name: "RFC 5322 Foundation Tests",
            dependencies: [
                .target(name: "RFC 5322"),
                .target(name: "RFC 5322 Foundation"),
            ]
        ),
        .testTarget(
            name: "RFC 5322 Tests",
            dependencies: [
                .target(name: "RFC 5322"),
                .product(name: "Parseable ASCII", package: "swift-ascii-parser"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Byte Standard Library Integration", package: "swift-byte"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

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
