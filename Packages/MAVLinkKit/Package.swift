// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MAVLinkKit",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "MAVLinkKit", targets: ["MAVLinkKit"]),
    ],
    targets: [
        .target(name: "MAVLinkKit"),
        .testTarget(
            name: "MAVLinkKitTests",
            dependencies: ["MAVLinkKit"],
            resources: [.copy("Fixtures")]
        ),
    ]
)
