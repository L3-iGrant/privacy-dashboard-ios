// swift-tools-version:5.9
import PackageDescription
import Foundation

let package = Package(
    name: "PrivacyDashboardiOS",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "PrivacyDashboardiOS",
            targets: ["PrivacyDashboardiOS"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.0")),
        .package(url: "https://github.com/hackiftekhar/IQKeyboardManager.git", from: "8.0.1"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.2"),
        .package(url: "https://github.com/huri000/SwiftEntryKit", from: "2.0.0"),
        //.package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "8.0.0")),
        .package(url: "https://github.com/decentralised-dataexchange/ExpandableLabel", from: "2025.10.1"),
        .package(url: "https://github.com/yonat/StepProgressView", from: "1.6.1"),
        .package(url: "https://github.com/decentralised-dataexchange/SDStateTableView", from: "2025.10.1"),
        .package(url: "https://github.com/melvitax/DateHelper.git", from: "5.0.1")
    ],
    targets: [
        .target(
            name: "PrivacyDashboardiOS",
            dependencies: ["Alamofire",
            .product(name: "IQKeyboardManagerSwift", package: "IQKeyboardManager"),
            //"Kingfisher",
            "ExpandableLabel",
            "SwiftyJSON",
            "SDStateTableView",
            "SwiftEntryKit",
            "DateHelper",
            "StepProgressView"
            ])
    ]
)
