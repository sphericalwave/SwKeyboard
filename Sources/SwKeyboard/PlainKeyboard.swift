//
//  PlainKeyboard.swift
//  SwKeyboard
//
//  Strips the QuickType predictive-word bar from a text field. iOS derives
//  whether to show predictive suggestions from the autocorrection setting —
//  there's no separate toggle for it — so disabling autocorrection is the
//  correct, SwiftUI-only way to remove it (no UIKit drop-down needed).
//
//  Apply per-field, not globally: fields that hold prose (MindHeist's
//  script editor, notes) genuinely want predictive text; fields that hold
//  identifiers, tags, or search terms don't.
//
//      TextField("Tag", text: $tag)
//          .plainKeyboard()
//

import SwiftUI

public extension View {
    /// Disables autocorrection, which also removes the predictive-word bar
    /// above the keyboard. Does not touch capitalization — pair with
    /// `.textInputAutocapitalization(.never)` if you want that too.
    func plainKeyboard() -> some View {
        autocorrectionDisabled(true)
    }
}
