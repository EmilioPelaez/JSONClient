// swift-tools-version:4.0
import PackageDescription

let name = "JSONClient"
let package = Package(name: name,
                      products: [.library(name: name, targets: [name])],
                      dependencies: [.package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.0.0"))],
                      targets: [.target(name: name, dependencies: ["Vapor"], path: "Sources")]
)
