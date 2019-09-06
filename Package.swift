// swift-tools-version:5.1
//  Created by Morten Bertz on 2019/09/06.
//  Copyright © 2019 telethon k.k. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "APNG",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .library(name: "ANPG", targets: ["APNG"]),
    ],
    dependencies: [
        //.package(url: "https://url/of/another/package/named/Utility", from: "1.0.0"),
    ],
    targets: [
        .target(name: "libPNG", dependencies: [],
                path:"libPNG",
                exclude:["contrib", "scripts"],
                sources: ["pngerror.c",
                          "pngtrans.c",
                          "pngmem.c",
                          "pngwrite.c",
                          "pngrio.c",
                          "pngwutil.c",
                          "png.c",
                          "pngwio.c",
                          "pngset.c",
                          "pngpread.c",
                          "pngget.c",
                          "pngread.c",
                          "pngrutil.c",
                          "pngwtran.c",
                          "pngrtran.c",
                          "/intel"],
                publicHeadersPath: "."),
        .target(name: "APNGasm", dependencies: ["libPNG"], path: "APNGasm/lib/src", exclude: ["spec"], sources: nil, publicHeadersPath: ".", cSettings: [.headerSearchPath("../../../libPNG")], cxxSettings: nil, swiftSettings: nil, linkerSettings: nil),
        .target(name: "APNG", dependencies: ["APNGasm"], path: "APNG", exclude: [], sources: nil, publicHeadersPath: ".", cSettings: [.headerSearchPath("../APNGasm/lib/src"), .headerSearchPath("../libPNG")], cxxSettings: nil, swiftSettings: nil, linkerSettings: nil),
        
        .testTarget(name: "APNGTest", dependencies: ["APNG"], path: "APNGTests", exclude: [], sources: nil, cSettings: nil, cxxSettings: nil, swiftSettings: [.define("SPM")], linkerSettings: nil)
        
    ]
)
