import SwiftUI

/// The panel that drops down when the menu bar rock is clicked.
///
/// This is the seam for Rocky's feature set: add rows to the `options` section
/// below and everything else — sizing, dismissal, focus — already works.
struct DropdownView: View {

    let actions: RockyActions

    /// Fixed width so adding rows later never requires resizing the popover.
    private let panelWidth: CGFloat = 280

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            options
            Divider()
            footer
        }
        .frame(width: panelWidth)
    }

    private var header: some View {
        HStack(spacing: 8) {
            RockLogo()
                .frame(width: 16, height: 16)
                .foregroundStyle(.primary)
            Text("Rocky")
                .font(.system(size: 13, weight: .semibold))
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    // MARK: - Options
    //
    // ┌──────────────────────────────────────────────────────────────────┐
    // │  Rocky's options go here.                                        │
    // │                                                                  │
    // │  Each one is a `DropdownRow`. Replace the placeholder below with │
    // │  rows and the panel grows to fit automatically.                  │
    // └──────────────────────────────────────────────────────────────────┘

    private var options: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("No options yet")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
        }
        .padding(.vertical, 4)
    }

    private var footer: some View {
        VStack(spacing: 2) {
            DropdownRow(title: "Open Rocky", systemImage: "macwindow", action: actions.openMainWindow)
            DropdownRow(title: "Quit Rocky", systemImage: "power", action: actions.quit)
        }
        .padding(.vertical, 6)
    }
}

/// One selectable line in the dropdown, with the hover highlight macOS menus use.
struct DropdownRow: View {

    let title: String
    var systemImage: String?
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 12))
                        .frame(width: 16)
                }
                Text(title)
                    .font(.system(size: 13))
                Spacer(minLength: 0)
            }
            .foregroundStyle(isHovering ? Color.white : Color.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(isHovering ? Color.accentColor : Color.clear)
            )
            .contentShape(RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 6)
        .onHover { isHovering = $0 }
    }
}

#Preview("Dropdown") {
    DropdownView(actions: .preview)
}
