
import Foundation
import CoreGraphics

class KeyboardSimulator {

    static let shared = KeyboardSimulator()

    private var controlKeyDown = false

    func pressControl() {
        if !controlKeyDown {
            let event = CGEvent(keyboardEventSource: nil, virtualKey: 0x3B, keyDown: true)
            event?.flags = .maskControl
            event?.post(tap: .cghidEventTap)
            controlKeyDown = true
        }
    }

    func releaseControl() {
        if controlKeyDown {
            let event = CGEvent(keyboardEventSource: nil, virtualKey: 0x3B, keyDown: false)
            event?.flags = .maskControl
            event?.post(tap: .cghidEventTap)
            controlKeyDown = false
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
}
