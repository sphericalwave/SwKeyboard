//
//  KeyboardDismissal.swift
//  SwKeyboard
//
//  App-wide "tap outside to dismiss the keyboard", done right.
//
//  The naive version of this pattern (a window tap recognizer with
//  simultaneous recognition that resigns first responder on EVERY tap)
//  shipped in four apps and caused keyboard flicker and unreliable paste:
//  taps to place the cursor and taps on the system edit menu also resigned
//  first responder. This version ignores touches that land on text inputs,
//  the edit menu / callout bar, and the keyboard itself.
//
//  Install once at launch:
//      .onAppear { KeyboardDismissal.installTapOutsideDismissal() }
//

import SwiftUI

#if os(iOS)
import UIKit

public enum KeyboardDismissal {

    private static let coordinator = Coordinator()

    /// Attach the tap-outside recognizer to the key window. Safe to call
    /// repeatedly; installs once per window.
    @MainActor
    public static func installTapOutsideDismissal() {
        DispatchQueue.main.async {
            guard
                let scene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first
            else { return }
            coordinator.install(in: window)
        }
    }

    private final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        private var installedWindows = NSHashTable<UIWindow>.weakObjects()

        func install(in window: UIWindow) {
            guard !installedWindows.contains(window) else { return }
            installedWindows.add(window)
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
            tap.cancelsTouchesInView = false
            tap.requiresExclusiveTouchType = false
            tap.delegate = self
            window.addGestureRecognizer(tap)
        }

        @objc private func dismiss() {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
            )
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
            true
        }

        /// Dismiss only on taps OUTSIDE text inputs, the edit menu, and the
        /// keyboard — the part the naive implementations missed.
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldReceive touch: UITouch) -> Bool {
            Self.shouldDismiss(forTouchOn: touch.view)
        }

        /// Internal for tests: walk the view's ancestry; any text input,
        /// edit-menu, callout-bar, or keyboard view vetoes dismissal.
        static func shouldDismiss(forTouchOn view: UIView?) -> Bool {
            var v = view
            while let current = v {
                if current is UITextView || current is UITextField { return false }
                let typeName = String(describing: type(of: current))
                if typeName.contains("EditMenu") || typeName.contains("CalloutBar")
                    || typeName.contains("Keyboard") { return false }
                v = current.superview
            }
            return true
        }
    }

    /// Test seam for the veto logic.
    static func _shouldDismiss(forTouchOn view: UIView?) -> Bool {
        Coordinator.shouldDismiss(forTouchOn: view)
    }
}
#endif
