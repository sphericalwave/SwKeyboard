//
//  DoneKeyboardToolbar.swift
//  SwKeyboard
//
//  A trailing "Done" button above the keyboard that resigns first responder.
//
//      TextEditor(text: $script)
//          .doneKeyboardToolbar()
//

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
