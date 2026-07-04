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
    /// repeatedly (e.g. from `.onAppear` AND a `scenePhase == .active`
    /// handler) — installation is idempotent per window.
    ///
    /// Retries briefly because on cold launch `.onAppear` can fire before
    /// the scene reports `.foregroundActive`; a single failed lookup used
    /// to give up silently and never install the recognizer at all.
    @MainActor
    public static func installTapOutsideDismissal(attemptsRemaining: Int = 10) {
        DispatchQueue.main.async {
            guard
                let scene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first
            else {
                guard attemptsRemaining > 0 else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    installTapOutsideDismissal(attemptsRemaining: attemptsRemaining - 1)
                }
                return
            }
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

        /// UIKit-private view-type fragments that veto dismissal. Selection
        /// grabbers, the cursor, and the loupe are NOT descendants of the
        /// text view — without these, tapping a selection handle resigned
        /// first responder and collapsed the selection (double-tap-select
        /// then drag-handles was broken).
        private static let vetoFragments = [
            "EditMenu", "CalloutBar", "Keyboard",
            "TextSelection", "Grabber", "Cursor", "Loupe", "Magnifier", "TextRange",
        ]

        private static let uikitBundle = Bundle(for: UIView.self)

        /// Fragment matching applies ONLY to UIKit-framework classes. SwiftUI
        /// hosting/wrapper views embed their generic payload in the type name
        /// and routinely contain words like "Keyboard" — matching those vetoed
        /// every tap and broke tap-outside dismissal entirely. The text
        /// chrome we must protect all lives in UIKitCore.
        static func isVetoedChrome(_ view: UIView) -> Bool {
            guard Bundle(for: type(of: view)) === uikitBundle else { return false }
            let typeName = String(describing: type(of: view))
            return vetoFragments.contains { typeName.contains($0) }
        }

        /// Internal for tests: walk the view's ancestry; any text input or
        /// UIKit text-interaction chrome vetoes dismissal.
        static func shouldDismiss(forTouchOn view: UIView?) -> Bool {
            var v = view
            while let current = v {
                if current is UITextView || current is UITextField { return false }
                if isVetoedChrome(current) { return false }
                v = current.superview
            }
            return true
        }
    }

    /// Test seams for the veto logic.
    static func _shouldDismiss(forTouchOn view: UIView?) -> Bool {
        Coordinator.shouldDismiss(forTouchOn: view)
    }

    static func _isVetoedChrome(_ view: UIView) -> Bool {
        Coordinator.isVetoedChrome(view)
    }
}
#endif
