// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "MKMThreeProbe",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "MKMThreeProbe",
            targets: ["MKMThreeProbe"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/MOKO-iOS-Base-Library/MKBaseBleModule.git", from: "1.1.6"),
        .package(url: "https://github.com/MOKO-iOS-Base-Library/MKBaseModuleLibrary.git", from: "2.2.15"),
        .package(url: "https://github.com/MOKO-iOS-Base-Library/MKCustomUIModule.git", from: "2.1.14"),
        .package(url: "https://github.com/MOKO-iOS-Base-Library/MKBeaconXCustomUI.git", from: "1.0.14"),
    ],
    targets: [
        .target(
            name: "MKMThreeProbe",
            dependencies: [
                "MKBaseBleModule",
                "MKBaseModuleLibrary",
                "MKCustomUIModule",
                "MKBeaconXCustomUI",
            ],
            path: "MKMThreeProbe",
            exclude: [
                "Classes/Functions/UpdatePage",  // NordicDFU 4.16.0 无 SPM
            ],
            sources: ["Classes"],
            resources: [.process("Assets")],
            publicHeadersPath: "Classes/PublicHeaders",
            cSettings: [
                .headerSearchPath("Classes"),
                .headerSearchPath("Classes/ConnectManager"),
                .headerSearchPath("Classes/CTMediator"),
                .headerSearchPath("Classes/SDK"),
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
