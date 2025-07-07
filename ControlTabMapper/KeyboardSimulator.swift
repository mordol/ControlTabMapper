
import Foundation
import CoreGraphics

class KeyboardSimulator {

    static let shared = KeyboardSimulator()

    private(set) var isControlKeyDown = false

    func pressControl() {
        if !isControlKeyDown {
            let event = CGEvent(keyboardEventSource: nil, virtualKey: 0x3B, keyDown: true)
            event?.flags = .maskControl
            event?.post(tap: .cghidEventTap)
            isControlKeyDown = true
        }
    }

    func releaseControl() {
        if isControlKeyDown {
            let event = CGEvent(keyboardEventSource: nil, virtualKey: 0x3B, keyDown: false)
            event?.flags = .maskControl
            event?.post(tap: .cghidEventTap)
            isControlKeyDown = false
        }
    }

    func pressTab() {
        let tabDown = CGEvent(keyboardEventSource: nil, virtualKey: 0x30, keyDown: true)
        tabDown?.flags = .maskControl
        tabDown?.post(tap: .cghidEventTap)

        let tabUp = CGEvent(keyboardEventSource: nil, virtualKey: 0x30, keyDown: false)
        tabUp?.flags = .maskControl
        tabUp?.post(tap: .cghidEventTap)
    }

    func performControlTab() {
        pressControl()
        pressTab()
    }

    func pressESC() {
        let escDown = CGEvent(keyboardEventSource: nil, virtualKey: 53, keyDown: true)
        escDown?.post(tap: .cghidEventTap)
        let escUp = CGEvent(keyboardEventSource: nil, virtualKey: 53, keyDown: false)
        escUp?.post(tap: .cghidEventTap)
        // After sending ESC, we should also ensure the control key is released.
        releaseControl()
    }
}
