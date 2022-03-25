// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FootballTables",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "App",
            targets: ["App"]
        ),
        .library(
            name: "MatchDashboardView",
            targets: ["MatchDashboardView"]
        ),
        .library(
            name: "StandingDashboardView",
            targets: ["StandingDashboardView"]
        ),
        .library(
            name: "MyTeamsDashboardView",
            targets: ["MyTeamsDashboardView"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "0.28.1")),
        .package(url: "https://github.com/SnapKit/SnapKit", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/Thieurom/FootballDataClient", .upToNextMajor(from: "0.3.0")),
        .package(url: "https://github.com/SDWebImage/SDWebImageSVGCoder", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/CombineCommunity/CombineExt", .upToNextMajor(from: "1.5.1"))
    ],
    targets: [
        .target(
            name: "CommonExtensions",
            dependencies: []
        ),
        .target(
            name: "CommonUI",
            dependencies: [
                .target(name: "CommonExtensions"),
                .product(name: "SnapKit", package: "SnapKit")
            ]
        ),
        .target(
            name: "Models",
            dependencies: [
                .product(name: "FootballDataClient", package: "FootballDataClient")
            ]
        ),
        .target(
            name: "ComposableExtensions",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "Theme",
            dependencies: []
        ),
        .target(
            name: "MatchViewCell",
            dependencies: [
                .target(name: "CommonExtensions"),
                .target(name: "ComposableExtensions"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FootballDataClient", package: "FootballDataClient"),
                .product(name: "SnapKit", package: "SnapKit")
            ]
        ),
        .target(
            name: "CompetitionViewCell",
            dependencies: [
                .target(name: "CommonExtensions"),
                .target(name: "ComposableExtensions"),
                .target(name: "Theme"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FootballDataClient", package: "FootballDataClient"),
                .product(name: "SDWebImageSVGCoder", package: "SDWebImageSVGCoder"),
                .product(name: "SnapKit", package: "SnapKit")
            ]
        ),
        .target(
            name: "FollowingTeamViewCell",
            dependencies: [
                .target(name: "CommonExtensions"),
                .target(name: "ComposableExtensions"),
                .target(name: "Models"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "SDWebImageSVGCoder", package: "SDWebImageSVGCoder"),
                .product(name: "SnapKit", package: "SnapKit")
            ]
        ),
        .target(
            name: "CompetitionMatchView",
            dependencies: [
                .target(name: "CommonExtensions"),
                .target(name: "CommonUI"),
                .target(name: "ComposableExtensions"),
                .target(name: "MatchViewCell"),
                .target(name: "Models"),
                .product(name: "CombineExt", package: "CombineExt"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FootballDataClient", package: "FootballDataClient"),
                .product(name: "SnapKit", package: "SnapKit")
            ]
        ),
        .target(
            name: "SectionHeaderView",
            dependencies: [
                .target(name: "CommonExtensions"),
                .product(name: "SnapKit", package: "SnapKit")
            ]
        ),
        .target(
            name: "TeamView",
            dependencies: [
                .target(name: "CommonExtensions"),
                .target(name: "CommonUI"),
                .target(name: "ComposableExtensions"),
                .target(name: "MatchViewCell"),
                .target(name: "Models"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FootballDataClient", package: "FootballDataClient"),
                .product(name: "SDWebImageSVGCoder", package: "SDWebImageSVGCoder"),
                .product(name: "SnapKit", package: "SnapKit")
            ]
        ),
        .target(
            name: "CompetitionStandingView",
            dependencies: [
                .target(name: "CommonExtensions"),
                .target(name: "ComposableExtensions"),
                .target(name: "Models"),
                .target(name: "TeamView"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FootballDataClient", package: "FootballDataClient"),
                .product(name: "SDWebImageSVGCoder", package: "SDWebImageSVGCoder"),
                .product(name: "SnapKit", package: "SnapKit")
            ]
        ),
        .target(
            name: "MatchDashboardView",
            dependencies: [
                .target(name: "CommonExtensions"),
                .target(name: "CommonUI"),
                .target(name: "CompetitionMatchView"),
                .target(name: "CompetitionViewCell"),
                .target(name: "ComposableExtensions"),
                .target(name: "MatchViewCell"),
                .target(name: "Models"),
                .product(name: "CombineExt", package: "CombineExt"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FootballDataClient", package: "FootballDataClient"),
                .product(name: "SnapKit", package: "SnapKit")
            ]
        ),
        .target(
            name: "StandingDashboardView",
            dependencies: [
                .target(name: "CommonExtensions"),
                .target(name: "CommonUI"),
                .target(name: "CompetitionStandingView"),
                .target(name: "CompetitionViewCell"),
                .target(name: "ComposableExtensions"),
                .target(name: "MatchViewCell"),
                .target(name: "Models"),
                .target(name: "Theme"),
                .target(name: "SectionHeaderView"),
                .product(name: "CombineExt", package: "CombineExt"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FootballDataClient", package: "FootballDataClient"),
                .product(name: "SnapKit", package: "SnapKit")
            ]
        ),
        .target(
            name: "MyTeamsDashboardView",
            dependencies: [
                .target(name: "CommonExtensions"),
                .target(name: "CommonUI"),
                .target(name: "ComposableExtensions"),
                .target(name: "Models"),
                .target(name: "Theme"),
                .target(name: "TeamView"),
                .target(name: "FollowingTeamViewCell"),
                .product(name: "CombineExt", package: "CombineExt"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FootballDataClient", package: "FootballDataClient"),
                .product(name: "SnapKit", package: "SnapKit")
            ]
        ),
        .target(
            name: "App",
            dependencies: [
                .target(name: "ComposableExtensions"),
                .target(name: "MatchDashboardView"),
                .target(name: "Models"),
                .target(name: "MyTeamsDashboardView"),
                .target(name: "StandingDashboardView"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FootballDataClient", package: "FootballDataClient")
            ]
        )
    ]
)
