// swift-tools-version:5.2

import PackageDescription

let package = Package(name: "VCDISamples",
                      products: [
                          .library(name: "VCDI_Darwin",
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
