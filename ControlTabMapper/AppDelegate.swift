
import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem!
    var eventTap: CFMachPort?
    var runLoopSource: CFRunLoopSource?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the status item.
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(named: "MenuBarIcon")
            //button.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "ControlTabMapper")
        }

        // Create the menu.
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu

        // Check for accessibility permissions
        let accessEnabled = AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary)

        if !accessEnabled {
            let alert = NSAlert()
            alert.messageText = "Accessibility Access Required"
            alert.informativeText = "ControlTabMapper needs accessibility permissions to function. Please grant access in System Settings > Privacy & Security > Accessibility, then restart the app."
            alert.alertStyle = .critical
            alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "Quit")

            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            }
            NSApp.terminate(self)
            return
        }
        
        print("Setting up event tap...")
        // Add global event monitor using CGEvent.tapCreate
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.leftMouseDown.rawValue) | (1 << CGEventType.rightMouseDown.rawValue) | (1 << CGEventType.otherMouseDown.rawValue)
        eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                     place: .headInsertEventTap,
                                     options: .listenOnly,
                                     eventsOfInterest: CGEventMask(eventMask),
                                     callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                                         if let refcon = refcon {
                                             let appDelegate = Unmanaged<AppDelegate>.fromOpaque(refcon).takeUnretainedValue()
                                             return appDelegate.handle(event: event, type: type)
                                         }
                                         return Unmanaged.passRetained(event)
                                     },
                                     userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        
        if eventTap == nil {
            print("Failed to create event tap")
            return
        } else {
            print("Event tap created successfully.")
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        if runLoopSource == nil {
            print("Failed to create run loop source.")
            return
        } else {
            print("Run loop source created successfully.")
        }
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        print("Run loop source added to current run loop.")
        
        CGEvent.tapEnable(tap: eventTap!, enable: true)
        if CGEvent.tapIsEnabled(tap: eventTap!) {
            print("Event tap is enabled.")
        } else {
            print("Failed to enable event tap.")
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

    func handle(event: CGEvent, type: CGEventType) -> Unmanaged<CGEvent>? {
        // First, check if the event should be processed based on the selected app
        guard let selectedAppIdentifier = UserDefaults.standard.string(forKey: "selectedAppIdentifier"),
              let frontmostApp = NSWorkspace.shared.frontmostApplication,
              frontmostApp.bundleIdentifier == selectedAppIdentifier else {
            // If not the selected app, release control and pass the event through
            KeyboardSimulator.shared.releaseControl()
            return Unmanaged.passRetained(event)
        }

        // Now, handle the event based on its type
        switch type {
        case .keyDown:
            if let nsEvent = NSEvent(cgEvent: event) {
                let keyCode = nsEvent.keyCode
                print("KeyDown event: keyCode=\(keyCode), modifierFlags=\(nsEvent.modifierFlags.rawValue)")

                if keyCode == 53 { // ESC key
                    print("ESC key pressed. Releasing Control key.")
                    KeyboardSimulator.shared.releaseControl()
                } else if keyCode == 99 { // F3 key
                    print("F3 pressed. Performing Control+Tab.")
                    KeyboardSimulator.shared.performControlTab()
                }
            }

        case .leftMouseDown, .rightMouseDown, .otherMouseDown:
            if KeyboardSimulator.shared.isControlKeyDown {
                print("Mouse button pressed while Control is down. Allowing click and then simulating ESC.")
                // Use asyncAfter to allow the original mouse click to be processed first.
                // We pass the original event through, and then fire ESC shortly after.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // 100ms delay
                    KeyboardSimulator.shared.pressESC()
                }
            }

        default:
            // For any other event types, do nothing special
            break
        }

        return Unmanaged.passRetained(event)
    }

    func application(_ app: NSApplication, open urls: [URL]) {
        for url in urls {
            if url.scheme == "controltabmapper" && url.host == "trigger" {
                KeyboardSimulator.shared.performControlTab()
            }
        }
    }
}
