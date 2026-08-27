import AppKit
import SwiftUI

/// The things the dropdown can ask the app to do. Passing these in as closures
/// keeps `DropdownView` free of any reach-through to `NSApp.delegate`, so the
/// SwiftUI layer stays previewable and testable as real options are added.
struct RockyActions {
    var openMainWindow: () -> Void
    var quit: () -> Void

    /// Inert set for SwiftUI previews.
    static let preview = RockyActions(openMainWindow: {}, quit: {})
}

/// Owns the menu bar rock and the panel that drops down from it.
@MainActor
final class StatusItemController: NSObject {

    private let statusItem: NSStatusItem
    private let popover = NSPopover()

    init(actions: RockyActions) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()

        if let button = statusItem.button {
            button.image = RockLogo.menuBarImage()
            button.imagePosition = .imageOnly
            button.toolTip = "Rocky"
            button.setAccessibilityLabel("Rocky")
            button.target = self
            button.action = #selector(togglePopover)
        }

        popover.behavior = .transient  // clicking outside dismisses, for free
        popover.animates = true
        popover.contentViewController = NSHostingController(
            rootView: DropdownView(actions: actions)
        )
    }

    @objc private func togglePopover() {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }

    func closePopover() {
        guard popover.isShown else { return }
        popover.performClose(nil)
    }

    private func showPopover() {
        guard let button = statusItem.button else { return }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

        // A popover owned by an `.accessory` app does not become key on its own,
        // which makes any control that needs first responder — text fields,
        // search, steppers — silently ignore input. Forcing it here means the
        // seam is already correct when real options land.
        popover.contentViewController?.view.window?.makeKey()
    }
}
