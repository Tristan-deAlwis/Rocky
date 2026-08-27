import AppKit
import SwiftUI

/// Owns Rocky's single main window, created lazily and reused across opens so
/// repeated "Open Rocky" clicks never stack up duplicate windows.
@MainActor
final class MainWindowController: NSObject, NSWindowDelegate {

    private var window: NSWindow?
    private let onClose: () -> Void

    /// `windowWillClose` fires while the window is still on screen, so
    /// `NSWindow.isVisible` is still `true` at the moment we need the answer.
    /// This tracks the intent rather than the state.
    private var isClosing = false

    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }

    var isVisible: Bool { (window?.isVisible ?? false) && !isClosing }

    func show() {
        let window = self.window ?? makeWindow()
        self.window = window
        isClosing = false
        window.makeKeyAndOrderFront(nil)
    }

    private func makeWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Rocky"
        window.contentView = NSHostingView(rootView: MainWindowView())
        window.minSize = NSSize(width: 640, height: 420)
        // We hold the only strong reference and reuse this instance, so closing
        // it must not deallocate it.
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.center()
        // Restores the previous position/size if the user has moved it before.
        window.setFrameAutosaveName("RockyMainWindow")
        return window
    }

    func windowWillClose(_ notification: Notification) {
        isClosing = true
        onClose()
    }
}
