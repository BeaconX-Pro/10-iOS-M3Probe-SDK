// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "MKMThreeProbe",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        // 客户二次开发使用：仅蓝牙 SDK 层，不包含任何 UI 页面
        .library(
            name: "MKMThreeProbeSDK",
            targets: ["MKMThreeProbeSDK"]
        ),
        // 完整组件：SDK + 全部配置页面
        .library(
            name: "MKMThreeProbe",
            targets: ["MKMThreeProbe"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/MOKO-iOS-Base-Library/MKBaseBleModule.git", from: "1.1.6"),
        .package(url: "https://github.com/MOKO-iOS-Base-Library/MKBaseModuleLibrary.git", from: "2.2.19"),
        .package(url: "https://github.com/MOKO-iOS-Base-Library/MKCustomUIModule.git", from: "2.1.14"),
        .package(url: "https://github.com/MOKO-iOS-Base-Library/MKBeaconXCustomUI.git", from: "1.0.14"),
        .package(url: "https://github.com/nordicsemi/IOS-DFU-Library.git", from: "4.17.0"),
    ],
    targets: [
        .target(
            name: "MKMThreeProbeSDK",
            dependencies: [
                "MKBaseBleModule",
            ],
            path: "MKMThreeProbe/Classes/SDK",
            publicHeadersPath: ".",
            linkerSettings: [
                .linkedFramework("CoreBluetooth"),
            ]
        ),
        .target(
            name: "MKMThreeProbe",
            dependencies: [
                "MKMThreeProbeSDK",
                "MKBaseBleModule",
                "MKBaseModuleLibrary",
                "MKCustomUIModule",
                "MKBeaconXCustomUI",
                .product(name: "NordicDFU", package: "IOS-DFU-Library"),
            ],
            path: "MKMThreeProbe",
            exclude: [
                "Classes/SDK",
                "Classes/Vendor/CTMediator",
                "Classes/Vendor/HHTransition",
                "Classes/Vendor/MLInputDodger",
            ],
            sources: ["Classes"],
            resources: [.process("Assets")],
            publicHeadersPath: "Classes/PublicHeaders",
            cSettings: [
                .headerSearchPath("Classes"),
                .headerSearchPath("Classes/ConnectManager"),
                .headerSearchPath("Classes/CTMediator"),
                .headerSearchPath("Classes/Target"),
                .headerSearchPath("Classes/Functions/AboutPage/Controller"),
                .headerSearchPath("Classes/Functions/AdvConfigPage/Controller"),
                .headerSearchPath("Classes/Functions/AdvConfigPage/Model"),
                .headerSearchPath("Classes/Functions/AdvConfigPage/View"),
                .headerSearchPath("Classes/Functions/ProbePage/Controller"),
                .headerSearchPath("Classes/Functions/ProbePage/View"),
                .headerSearchPath("Classes/Functions/QuickSwitchPage/Controller"),
                .headerSearchPath("Classes/Functions/QuickSwitchPage/Model"),
                .headerSearchPath("Classes/Functions/ScanPage/Controller"),
                .headerSearchPath("Classes/Functions/ScanPage/Model"),
                .headerSearchPath("Classes/Functions/ScanPage/View"),
                .headerSearchPath("Classes/Functions/SensorConfigPage/Controller"),
                .headerSearchPath("Classes/Functions/SensorConfigPage/Model"),
                .headerSearchPath("Classes/Functions/SensorPage/Controller"),
                .headerSearchPath("Classes/Functions/SensorPage/View"),
                .headerSearchPath("Classes/Functions/SettingPage/Controller"),
                .headerSearchPath("Classes/Functions/TabBarPage/Controller"),
                .headerSearchPath("Classes/Functions/TabBarPage/Model"),
                .headerSearchPath("Classes/Functions/UpdatePage/Controller"),
                .headerSearchPath("Classes/Functions/UpdatePage/Model"),
                .headerSearchPath("Classes/Vendor/CTMediator"),
                .headerSearchPath("Classes/Vendor/HHTransition"),
                .headerSearchPath("Classes/Vendor/MLInputDodger"),
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("CoreBluetooth"),
            ]
        )
    ]
)
