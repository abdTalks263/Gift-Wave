// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "GiftWave",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "GiftWave", targets: ["GiftWave"])
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0")
    ],
    targets: [
        .target(
            name: "GiftWave",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk")
            ],
            path: "Gift Wave"
        )
    ]
) 