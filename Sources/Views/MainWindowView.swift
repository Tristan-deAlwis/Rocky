import SwiftUI

/// Contents of Rocky's main window. A placeholder until the feature set lands.
struct MainWindowView: View {
    var body: some View {
        VStack(spacing: 20) {
            RockLogo()
                .frame(width: 120, height: 120)
                .foregroundStyle(.secondary)

            VStack(spacing: 6) {
                Text("Rocky")
                    .font(.system(size: 28, weight: .semibold))
                Text("No features yet — this window is the scaffold.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

#Preview("Main window") {
    MainWindowView()
        .frame(width: 900, height: 600)
}
