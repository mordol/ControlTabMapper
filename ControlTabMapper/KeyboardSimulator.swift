
import Foundation
import CoreGraphics
import AppKit // Import for NSEvent

class KeyboardSimulator {

    static let shared = KeyboardSimulator()
    private var eventMonitor: Any?

    private init() {}

    func performControlTab() {
        // Stop any previous monitors before starting a new sequence.
        stopMonitoring()

        let source = CGEventSource(stateID: .hidSystemState)

        // 1. Press Control key down
        let ctrlDown = CGEvent(keyboardEventSource: source, virtualKey: 0x3B, keyDown: true)
        ctrlDown?.flags = .maskControl
        ctrlDown?.post(tap: .cghidEventTap)

        // 2. Press and release Tab key
        let tabDown = CGEvent(keyboardEventSource: source, virtualKey: 0x30, keyDown: true)
        tabDown?.flags = .maskControl
        tabDown?.post(tap: .cghidEventTap)

        let tabUp = CGEvent(keyboardEventSource: source, virtualKey: 0x30, keyDown: false)
        tabUp?.flags = .maskControl
        tabUp?.post(tap: .cghidEventTap)

        // 3. Start monitoring for events that will release the Control key.
        startMonitoring()
    }

    private func releaseControlKey() {
        let source = CGEventSource(stateID: .hidSystemState)
        let ctrlUp = CGEvent(keyboardEventSource: source, virtualKey: 0x3B, keyDown: false)
        // No need to set flags on key up
        ctrlUp?.post(tap: .cghidEventTap)
    }

    private func pressESC() {
        let source = CGEventSource(stateID: .hidSystemState)
        let escDown = CGEvent(keyboardEventSource: source, virtualKey: 53, keyDown: true)
        escDown?.post(tap: .cghidEventTap)
        let escUp = CGEvent(keyboardEventSource: source, virtualKey: 53, keyDown: false)
        escUp?.post(tap: .cghidEventTap)
    }

    private func simulateEscAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.pressESC()
        }
    }

    private func startMonitoring() {
        // Register a global event monitor.
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown, .keyDown]) { [weak self] event in
            guard let self = self else { return }

            if event.type == .keyDown {
                // If the ESC key is pressed, release Control and stop monitoring.
                if event.keyCode == 53 { // 53 is the virtual key code for the Escape key.
                    self.releaseControlKey()
                    self.stopMonitoring()
                }
            } else {
                // If a mouse button is clicked, simulate an ESC press after a short delay.
                // The simulated ESC press will then be caught by this same monitor to release the control key.
                self.simulateEscAfterDelay()
            }
        }
    }

    private func stopMonitoring() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    // A deinitializer to ensure the monitor is removed if the object is ever deallocated.
    deinit {
        stopMonitoring()
    }
}
