import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: StatusItemController?

    private lazy var mainWindow = MainWindowController { [weak self] in
        self?.updateActivationPolicy()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = StatusItemController(
            actions: RockyActions(
                openMainWindow: { [weak self] in self?.showMainWindow() },
                quit: { NSApp.terminate(nil) }
            )
        )
        // Deliberately no window at launch — Rocky starts life in the menu bar.
    }

    /// Closing the window must not quit Rocky; it lives on in the menu bar.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    /// Clicking the Dock icon with no window open should bring one back.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag { showMainWindow() }
        return true
    }

    func showMainWindow() {
        // Changing activation policy out from under a visible popover can leave
        // it orphaned on screen, so dismiss it first.
        statusItem?.closePopover()

        // Promote before ordering the window in, otherwise the window belongs to
        // an accessory app for a moment and never properly takes key focus.
        if NSApp.activationPolicy() != .regular {
            NSApp.setActivationPolicy(.regular)
        }
        mainWindow.show()
        NSApp.activate()
    }

    /// The single place that decides whether Rocky shows a Dock icon. Everything
    /// else changes window state and lets this derive the policy, so the two can
    /// never disagree.
    private func updateActivationPolicy() {
        let desired: NSApplication.ActivationPolicy = mainWindow.isVisible ? .regular : .accessory
        guard NSApp.activationPolicy() != desired else { return }
        NSApp.setActivationPolicy(desired)
        if desired == .regular { NSApp.activate() }
    }
}
