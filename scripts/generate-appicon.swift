// Renders the app icon from `RockShape` so the mark never has to be maintained
// in two places. Run it after changing the silhouette:
//
//   ./scripts/generate-appicon.sh
//
// The generated PNG is committed; this is a design-time tool, not a build step.

import AppKit
import SwiftUI

/// The rock on a rounded plate, sized to macOS icon proportions: the artwork
/// occupies ~80% of the canvas, leaving the margin macOS expects for its shadow.
struct AppIconArtwork: View {
    var showsFacet: Bool = true

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let plate = side * 0.805

            ZStack {
                RoundedRectangle(cornerRadius: plate * 0.2245, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.45, green: 0.48, blue: 0.53),
                                Color(red: 0.19, green: 0.21, blue: 0.25),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: plate, height: plate)

                RockLogo(showsFacet: showsFacet)
                    .foregroundStyle(.white)
                    .frame(width: plate * 0.56, height: plate * 0.56)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

/// One rendition macOS asks for. Every slot is rendered from the vector rather
/// than downscaled from the largest, so small sizes stay crisp.
struct Slot {
    let points: Int
    let scale: Int
    var pixels: Int { points * scale }
    var filename: String { "icon-\(points)x\(points)@\(scale)x.png" }
}

@main
struct GenerateAppIcon {

    /// The full macOS app icon set.
    static let slots: [Slot] = [16, 32, 128, 256, 512].flatMap { points in
        [Slot(points: points, scale: 1), Slot(points: points, scale: 2)]
    }

    @MainActor
    static func main() {
        let directory = CommandLine.arguments.count > 1
            ? CommandLine.arguments[1]
            : "Sources/Assets.xcassets/AppIcon.appiconset"

        for slot in slots {
            let side = CGFloat(slot.pixels)

            // The interior facet turns to mush below ~64px, where the whole icon
            // is only a few pixels of stroke. Drop it and let the silhouette carry.
            let artwork = AppIconArtwork(showsFacet: slot.pixels >= 64)
                .frame(width: side, height: side)

            let renderer = ImageRenderer(content: artwork)
            renderer.scale = 1

            guard let cgImage = renderer.cgImage else {
                fail("ImageRenderer produced no image for \(slot.filename)")
            }

            let rep = NSBitmapImageRep(cgImage: cgImage)
            rep.size = NSSize(width: side, height: side)

            guard let png = rep.representation(using: .png, properties: [:]) else {
                fail("PNG encoding failed for \(slot.filename)")
            }

            let url = URL(fileURLWithPath: directory).appendingPathComponent(slot.filename)
            do {
                try png.write(to: url)
            } catch {
                fail("\(error)")
            }
        }

        writeContentsJSON(in: directory)
        print("wrote \(slots.count) renditions to \(directory)")
    }

    /// Keeps the catalog manifest in step with whatever `slots` contains, so the
    /// two can't drift into "unassigned child" warnings.
    @MainActor
    static func writeContentsJSON(in directory: String) {
        let entries = slots.map { slot in
            """
                {
                  "filename" : "\(slot.filename)",
                  "idiom" : "mac",
                  "scale" : "\(slot.scale)x",
                  "size" : "\(slot.points)x\(slot.points)"
                }
            """
        }

        let json = """
        {
          "images" : [
        \(entries.joined(separator: ",\n"))
          ],
          "info" : {
            "author" : "xcode",
            "version" : 1
          }
        }

        """

        let url = URL(fileURLWithPath: directory).appendingPathComponent("Contents.json")
        do {
            try json.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            fail("\(error)")
        }
    }

    static func fail(_ message: String) -> Never {
        FileHandle.standardError.write(Data("error: \(message)\n".utf8))
        exit(1)
    }
}
