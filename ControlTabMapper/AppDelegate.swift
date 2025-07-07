
import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the status item.
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "ControlTabMapper")
        }

        // Create the menu.
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu

        // Add global event monitor
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown, .keyDown]) { event in
            guard let selectedAppIdentifier = UserDefaults.standard.string(forKey: "selectedAppIdentifier"),
                  let frontmostApp = NSWorkspace.shared.frontmostApplication,
                  frontmostApp.bundleIdentifier == selectedAppIdentifier else {
                KeyboardSimulator.shared.releaseControl()
                return
            }

            if event.type == .keyDown && event.keyCode == 53 { // ESC key
                KeyboardSimulator.shared.releaseControl()
            } else if event.type == .keyDown && event.keyCode == 0x09 && event.modifierFlags.contains(.shift) { // Shift + F3 key
                KeyboardSimulator.shared.performControlTab()
            } else if event.type != .keyDown {
                KeyboardSimulator.shared.releaseControl()
            }
        }
    }

    @objc func openSettings() {
        // Open the settings window.
        if #available(macOS 13.0, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }

    func application(_ app: NSApplication, open urls: [URL]) {
        for url in urls {
            if url.scheme == "controltabmapper" && url.host == "trigger" {
                KeyboardSimulator.shared.performControlTab()
            }
        }
    }
}
