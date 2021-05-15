//
//  Package.swift
//  TwitterLogin
//
//  Created by Manu Singh on 15/05/21.
//

import Foundation
import PackageDescription

let package = Package(name: "TwitterLogin",
                      platforms: [.macOS(.v10_12),
                                  .iOS(.v10),
                                  .tvOS(.v10),
                                  .watchOS(.v3)],
                      products: [.library(name: "TwitterLogin",
                                          targets: ["TwitterLogin"])],
                      targets: [.target(name: "TwitterLogin",
                                        path: "TwitterLogin"),
                                .testTarget(name: "TwitterLoginTests",
                                            dependencies: [],
                                            path: "Tests")],
                      swiftLanguageVersions: [.v5])

