import PackageDescription

let package = Package(
	name: "JSONClient",
	dependencies: [
		.Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2)
	],
	exclude: []
)
