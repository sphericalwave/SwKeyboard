//
//  StandardKeyboardBehavior.swift
//  SwKeyboard
//
//  App-wide keyboard defaults that only need setting once. Unlike
//  `plainKeyboard()` (a per-field opt-in), scroll-to-dismiss is a container
//  setting SwiftUI cascades from a parent to every descendant
//  ScrollView/List/Form — so it belongs at the app root, not on each screen.
//

import SwiftUI

public extension View {
    /// Interactive scroll-to-dismiss for every scrollable view beneath this
    /// one. Apply ONCE near your app's root (e.g. the root view's body) —
    /// the setting cascades to descendant ScrollView/List/Form, so
    /// individual screens don't need to opt in.
    func dismissesKeyboardOnScroll() -> some View {
        scrollDismissesKeyboard(.interactively)
    }

    /// One call for the two app-wide keyboard behaviors most apps want
    /// everywhere: tap outside dismisses the keyboard (see
    /// `KeyboardDismissal`), and scrolling any Form/List/ScrollView
    /// dismisses it interactively. Apply once near your app's root.
    #if os(iOS)
    @MainActor
    func standardKeyboardBehavior() -> some View {
        dismissesKeyboardOnScroll()
            .onAppear { KeyboardDismissal.installTapOutsideDismissal() }
    }
    #endif
}
