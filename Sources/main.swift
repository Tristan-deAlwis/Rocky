import AppKit

// Rocky uses the AppKit lifecycle rather than SwiftUI's `App`/`Scene` lifecycle.
// Every view in the app is still SwiftUI — they are hosted via NSHostingView.
//
// The reason for the manual bootstrap: Rocky must launch *without* opening a
// window and *without* a Dock icon, then acquire both on demand. SwiftUI's scene
// lifecycle opens a window at launch (suppressing that needs macOS 15+) and
// interacts poorly with flipping `NSApp.setActivationPolicy` at runtime. Owning
// `main` costs a handful of lines and makes both behaviours exact.

// Top-level code in main.swift is nonisolated, but it does run on the main
// thread — which is exactly what `assumeIsolated` asserts.
MainActor.assumeIsolated {
    let app = NSApplication.shared

    // `NSApplication.delegate` is a weak reference, so the delegate has to be
    // kept alive here for the lifetime of the process.
    let delegate = AppDelegate()
    app.delegate = delegate

    // Start as an accessory: menu bar only, no Dock icon, no app menu.
    // AppDelegate promotes to `.regular` the moment a window is shown.
    app.setActivationPolicy(.accessory)

    withExtendedLifetime(delegate) {
        app.run()
    }
}
