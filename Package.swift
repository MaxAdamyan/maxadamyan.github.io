// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "MaxAdamyanWebsite",
    products: [
        .executable(name: "MaxAdamyanWebsite",
                    targets: ["MaxAdamyanWebsite"])
    ],
    
    dependencies: [
        .package(url: "https://github.com/johnsundell/plot.git", from: "0.3.0"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0")
    ],
    
    targets: [
        .target(
            name: "MaxAdamyanWebsite",
            dependencies: ["Plot", "Yams", "Files"]
        )
    ]
)
