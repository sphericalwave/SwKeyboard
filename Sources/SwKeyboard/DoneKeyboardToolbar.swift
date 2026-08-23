//
//  DoneKeyboardToolbar.swift
//  SwKeyboard
//
//  A trailing "Done" button above the keyboard that resigns first responder.
//
//      TextEditor(text: $script)
//          .doneKeyboardToolbar()
//
//  Apply ONCE per screen, on the Form/NavigationStack/container — not on
//  each field. SwiftUI merges every `.toolbar(placement: .keyboard)` group
//  currently mounted in the hierarchy into one bar, so two sibling fields
//  that each call this independently produce two stacked "Done" buttons.

import SwiftUI

public extension View {
    @ViewBuilder
    func doneKeyboardToolbar(_ title: String = "Done") -> some View {
        #if os(iOS)
        toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(title) {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
                    )
                }
            }
        }
        #else
        self
        #endif
    }
}
