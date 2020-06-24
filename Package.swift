// swift-tools-version:5.2

import PackageDescription

// MARK: - Platform configuration

let platforms: [SupportedPlatform] = [
   .iOS("13.2"),
   .macOS("10.15"),
   .tvOS("13.2"),
]

let package = Package(name: "VCDISamples",
                      platforms: platforms,
                      products: [
                          .library(name: "VCDI_Darwin",
                                   type: .dynamic,
                                   targets: [
                                       "VCDI_Darwin",
                                   ]),
                      ],
                      dependencies: [
                          .package(name: "CVideoCaptureDriverInterface",
                                   url: "https://github.com/PHIAR/VideoCaptureDriverInterface.git",
                                   .branch("master")),
                      ],
                      targets: [
                          .target(name: "VCDI_Darwin",
                                  dependencies: [
                                      "CVideoCaptureDriverInterface",
                                  ]),
                      ])
