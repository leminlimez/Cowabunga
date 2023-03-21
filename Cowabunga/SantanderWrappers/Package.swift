// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

/// Returns a URL of the sources
func pathInSources(componentToAppend: String) -> URL {
    URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .appendingPathComponent("Sources")
        .appendingPathComponent(componentToAppend)
}

let sourcesDirectory = URL(fileURLWithPath: #file)
    .deletingLastPathComponent()
    .appendingPathComponent("Sources")

let coreUITBD = sourcesDirectory.appendingPathComponent("CFrameworks/CoreUI/CoreUI.tbd")
let coreUILinkerSetting = LinkerSetting.unsafeFlags([coreUITBD.path])

let di2TBD = sourcesDirectory.appendingPathComponent("CFrameworks/DiskImages2/DiskImages2.tbd")
let di2LinkerSetting = LinkerSetting.unsafeFlags([di2TBD.path])

let coreSVGTBD = sourcesDirectory.appendingPathComponent("CFrameworks/CoreSVG/CoreSVG.tbd")
let coreSVGLinkerSetting = LinkerSetting.unsafeFlags([coreSVGTBD.path])

let package = Package(
    name: "SantanderWrappers",
    platforms: [.iOS(.v14), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "ApplicationsWrapper", targets: ["ApplicationsWrapper"]),
        .library(name: "AssetCatalogWrapper", targets: ["AssetCatalogWrapper"]),
        .library(name: "FSOperations", targets: ["FSOperations"]),
        .library(name: "SVGWrapper", targets: ["SVGWrapper"]),
        .library(name: "CompressionWrapper", targets: ["CompressionWrapper"]),
        .library(name: "DiskImagesWrapper", targets: ["DiskImagesWrapper"]),
        .library(name: "NSTask", targets: ["NSTask"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(name: "ApplicationsWrapper", dependencies: ["CFrameworks"]),
        .target(name: "AssetCatalogWrapper", dependencies: ["CFrameworks", "SVGWrapper"],
                linkerSettings: [coreUILinkerSetting]),
        .target(name: "CompressionWrapper", dependencies: ["CFrameworks"], linkerSettings: [.linkedLibrary("archive")]),
        .target(name: "DiskImagesWrapper", dependencies: ["CFrameworks"], linkerSettings: [di2LinkerSetting]),
        .target(name: "SVGWrapper", dependencies: ["CFrameworks"], linkerSettings: [coreSVGLinkerSetting]),
        
        .target(name: "FSOperations", dependencies: ["AssetCatalogWrapper"], linkerSettings: [coreUILinkerSetting]),
        .target(name: "NSTask", dependencies: ["CFrameworks"]),
        
        .testTarget(name: "FSOperationsTests", dependencies: ["FSOperations", "AssetCatalogWrapper"]),
        .testTarget(name: "CompressionTests", dependencies: ["CompressionWrapper"]),
        .testTarget(name: "DiskImagesTests", dependencies: ["DiskImagesWrapper"]),
        
        .systemLibrary(name: "CFrameworks", path: nil, pkgConfig: nil, providers: nil)
    ]
)
