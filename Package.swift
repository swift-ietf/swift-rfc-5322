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
            name: "RFC 5322 Foundation Integration",
            targets: ["RFC 5322 Foundation Integration"]
        ),
    ],
    traits: [
        .trait(name: "Coder", description: "Wire coders for RFC 5322 types")
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
            url: "https://github.com/swift-atoms/swift-time.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-calendar.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-calendar-gregorian.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-ascii.git",
            branch: "main",
            traits: [
                .trait(name: "Coder", condition: .when(traits: ["Coder"])),
                .trait(name: "Parser", condition: .when(traits: ["Coder"])),
                .trait(name: "Serializer", condition: .when(traits: ["Coder"])),
            ]
        ),
        .package(
            url: "https://github.com/swift-incits/swift-incits-4-1986.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-byte.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-binary.git",
            branch: "main",
            traits: [
                .trait(name: "Serializer", condition: .when(traits: ["Coder"])),
            ]
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-coder.git",
            branch: "main",
            traits: [
                .trait(name: "Carrier", condition: .when(traits: ["Coder"])),
                .trait(name: "Checkpoint", condition: .when(traits: ["Coder"])),
                .trait(name: "Choice", condition: .when(traits: ["Coder"])),
                .trait(name: "Either", condition: .when(traits: ["Coder"])),
                .trait(name: "IteratorLeaves", condition: .when(traits: ["Coder"])),
                .trait(name: "Map", condition: .when(traits: ["Coder"])),
                .trait(name: "Pair", condition: .when(traits: ["Coder"])),
                .trait(name: "Predicate", condition: .when(traits: ["Coder"])),
                .trait(name: "Repetition", condition: .when(traits: ["Coder"])),
                .trait(name: "Skip", condition: .when(traits: ["Coder"])),
            ]
        ),
        .package(url: "https://github.com/swift-atoms/swift-cursor.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-either.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-pair.git", branch: "main"),
        .package(
            url: "https://github.com/swift-atoms/swift-parser.git",
            branch: "main",
            traits: [
                .trait(name: "Always", condition: .when(traits: ["Coder"])),
                .trait(name: "Append", condition: .when(traits: ["Coder"])),
                .trait(name: "Choice", condition: .when(traits: ["Coder"])),
                .trait(name: "Either", condition: .when(traits: ["Coder"])),
                .trait(name: "FlatMap", condition: .when(traits: ["Coder"])),
                .trait(name: "Iterator", condition: .when(traits: ["Coder"])),
                .trait(name: "IteratorLeaves", condition: .when(traits: ["Coder"])),
                .trait(name: "Map", condition: .when(traits: ["Coder"])),
                .trait(name: "Pair", condition: .when(traits: ["Coder"])),
                .trait(name: "Predicate", condition: .when(traits: ["Coder"])),
                .trait(name: "Product", condition: .when(traits: ["Coder"])),
                .trait(name: "Repetition", condition: .when(traits: ["Coder"])),
                .trait(name: "Skip", condition: .when(traits: ["Coder"])),
            ]
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-serializer.git",
            branch: "main",
            traits: [
                .trait(name: "Either", condition: .when(traits: ["Coder"])),
                .trait(name: "Map", condition: .when(traits: ["Coder"])),
                .trait(name: "Pair", condition: .when(traits: ["Coder"])),
                .trait(name: "Repetition", condition: .when(traits: ["Coder"])),
            ]
        ),
    ],
    targets: [
        .target(
            name: "RFC 5322",
            dependencies: [
                .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions"),
                .product(name: "Time", package: "swift-time"),
                .product(name: "Calendar", package: "swift-calendar"),
                .product(name: "Calendar Gregorian", package: "swift-calendar-gregorian"),
                .product(name: "RFC 1123", package: "swift-rfc-1123"),
                .product(name: "ASCII", package: "swift-ascii"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "INCITS 4 1986", package: "swift-incits-4-1986"),
                .product(name: "Coder", package: "swift-coder", condition: .when(traits: ["Coder"])),
                .product(name: "Cursor", package: "swift-cursor", condition: .when(traits: ["Coder"])),
                .product(name: "Either", package: "swift-either", condition: .when(traits: ["Coder"])),
                .product(name: "Parser", package: "swift-parser", condition: .when(traits: ["Coder"])),
                .product(name: "Serializer", package: "swift-serializer", condition: .when(traits: ["Coder"])),
                .product(name: "Binary", package: "swift-binary", condition: .when(traits: ["Coder"])),
                .product(name: "Pair", package: "swift-pair", condition: .when(traits: ["Coder"])),
            ]
        ),
        .target(
            name: "RFC 5322 Foundation Integration",
            dependencies: [
                .target(name: "RFC 5322"),
                .product(name: "Byte", package: "swift-byte"),
            ]
        ),
        .testTarget(
            name: "RFC 5322 Foundation Integration Tests",
            dependencies: [
                .target(name: "RFC 5322"),
                .target(name: "RFC 5322 Foundation Integration"),
            ]
        ),
        .testTarget(
            name: "RFC 5322 Tests",
            dependencies: [
                .target(name: "RFC 5322"),
                .product(name: "ASCII", package: "swift-ascii"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Time", package: "swift-time"),
                .product(name: "Coder", package: "swift-coder", condition: .when(traits: ["Coder"])),
                .product(name: "Cursor", package: "swift-cursor", condition: .when(traits: ["Coder"])),
                .product(name: "Parser", package: "swift-parser", condition: .when(traits: ["Coder"])),
                .product(name: "Serializer", package: "swift-serializer", condition: .when(traits: ["Coder"])),
                .product(name: "Binary", package: "swift-binary", condition: .when(traits: ["Coder"])),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
            .strictMemorySafety(),
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            .enableUpcomingFeature("InferIsolatedConformances"),
            .enableExperimentalFeature("Lifetimes"),
            .treatAllWarnings(as: .error),
        ]
}
