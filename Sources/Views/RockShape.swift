import SwiftUI

/// The Rocky logo: a vector outline of a rock.
///
/// This is the single source of truth for the mark. It is defined in normalized
/// unit space and scaled into whatever rect it is given, so the same definition
/// serves the 18pt menu bar icon and the 1024pt app icon without a second asset
/// to keep in sync. Editing the silhouette means editing `outline` below.
struct RockShape: Shape {

    /// Draws the interior facet line that reads as a rock face rather than a
    /// featureless blob. Disable it at very small sizes if it muddies.
    var showsFacet: Bool = true

    /// Boulder silhouette, clockwise from the bottom-left corner, in unit space
    /// with y increasing downward (SwiftUI's convention).
    private static let outline: [CGPoint] = [
        CGPoint(x: 0.10, y: 0.88),  // bottom-left
        CGPoint(x: 0.02, y: 0.63),  // left face
        CGPoint(x: 0.20, y: 0.36),  // upper-left shoulder
        CGPoint(x: 0.42, y: 0.18),  // peak
        CGPoint(x: 0.63, y: 0.22),  // top-right dip
        CGPoint(x: 0.86, y: 0.40),  // upper-right shoulder
        CGPoint(x: 0.98, y: 0.66),  // right face
        CGPoint(x: 0.88, y: 0.88),  // bottom-right
    ]

    /// Open polyline suggesting a fracture plane across the face. Both ends land
    /// on the outline rather than radiating from an interior point — a facet that
    /// meets in the middle reads as clock hands instead of stone.
    private static let facet: [CGPoint] = [
        CGPoint(x: 0.28, y: 0.30),
        CGPoint(x: 0.50, y: 0.53),
        CGPoint(x: 0.87, y: 0.58),
    ]

    /// Stroke width that keeps the mark legible at any size.
    static func lineWidth(for rect: CGRect) -> CGFloat {
        min(rect.width, rect.height) * 0.075
    }

    func path(in rect: CGRect) -> Path {
        // Inset by half the stroke so the outline never clips at the edges.
        let inset = Self.lineWidth(for: rect) / 2
        let box = rect.insetBy(dx: inset, dy: inset)

        func place(_ p: CGPoint) -> CGPoint {
            CGPoint(x: box.minX + p.x * box.width,
                    y: box.minY + p.y * box.height)
        }

        let pts = Self.outline.map(place)
        // Corner radius is generous enough to soften the polygon into something
        // rock-like, but small enough that the facets stay readable.
        let radius = min(box.width, box.height) * 0.08

        var path = Path()

        // Rounded polygon: start midway along the first edge so every corner —
        // including the one we started from — gets the same arc treatment.
        let start = CGPoint(x: (pts[0].x + pts[1].x) / 2,
                            y: (pts[0].y + pts[1].y) / 2)
        path.move(to: start)
        for i in 1...pts.count {
            let corner = pts[i % pts.count]
            let next = pts[(i + 1) % pts.count]
            path.addArc(tangent1End: corner, tangent2End: next, radius: radius)
        }
        path.closeSubpath()

        if showsFacet {
            let facet = Self.facet.map(place)
            path.move(to: facet[0])
            for point in facet.dropFirst() {
                path.addLine(to: point)
            }
        }

        return path
    }
}

/// The logo rendered as a stroked outline, ready to drop into any layout.
struct RockLogo: View {
    var showsFacet: Bool = true

    var body: some View {
        GeometryReader { geo in
            let rect = CGRect(origin: .zero, size: geo.size)
            RockShape(showsFacet: showsFacet)
                .stroke(
                    style: StrokeStyle(
                        lineWidth: RockShape.lineWidth(for: rect),
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
        }
    }
}

extension RockLogo {
    /// Standard macOS menu bar icon metric.
    static let menuBarSize: CGFloat = 18

    /// Renders the logo as a *template* image, which lets AppKit recolor it for
    /// light/dark menu bars and for the highlighted state automatically. Without
    /// `isTemplate`, the icon would stay black and vanish against a dark menu bar.
    @MainActor
    static func menuBarImage() -> NSImage {
        let side = menuBarSize
        let renderer = ImageRenderer(
            content: RockLogo()
                .padding(1)
                .frame(width: side, height: side)
        )
        renderer.scale = 2

        guard let image = renderer.nsImage else {
            // Fall back to a stock symbol rather than showing an empty status
            // item, which would look like the app failed to launch.
            let fallback = NSImage(
                systemSymbolName: "circle.hexagongrid",
                accessibilityDescription: "Rocky"
            ) ?? NSImage()
            fallback.isTemplate = true
            return fallback
        }

        image.size = NSSize(width: side, height: side)
        image.isTemplate = true
        return image
    }
}

#Preview("Rock logo") {
    VStack(spacing: 24) {
        RockLogo().frame(width: 160, height: 160)
        HStack(spacing: 16) {
            RockLogo().frame(width: 18, height: 18)
            RockLogo(showsFacet: false).frame(width: 18, height: 18)
        }
    }
    .padding(32)
}
