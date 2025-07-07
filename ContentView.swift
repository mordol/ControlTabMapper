
import SwiftUI

struct ContentView: View {
    @State private var runningApps = NSWorkspace.shared.runningApplications
    @State private var selectedApp: NSRunningApplication?

    var body: some View {
        VStack {
            Text("ControlTabMapper Settings")
                .font(.largeTitle)
                .padding()

            Text("Select an application to enable Control-Tab mapping.")

            List(runningApps, id: \.bundleIdentifier) { app in
                Button(action: {
                    selectedApp = app
                }) {
                    HStack {
                        if let icon = app.icon {
                            Image(nsImage: icon)
                                .resizable()
                                .frame(width: 32, height: 32)
                        }
                        Text(app.localizedName ?? "Unknown App")
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .background(app.bundleIdentifier == selectedApp?.bundleIdentifier ? Color.accentColor : Color.clear)
                .cornerRadius(5)
            }
        }
        .padding()
        .onAppear {
            // Filter to only show apps with a UI
            runningApps = runningApps.filter { $0.activationPolicy == .regular }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
