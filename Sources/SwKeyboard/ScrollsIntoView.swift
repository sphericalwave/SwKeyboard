//
//  ScrollsIntoView.swift
//  SwKeyboard
//
//  Scrolls a focused field above the keyboard. Form/List/ScrollView don't
//  reliably keep the focused row visible on their own (especially low rows
//  in a tall form) — this closes that gap explicitly via ScrollViewReader,
//  driven by the call site's own FocusState.
//
//      @FocusState private var focusedField: Field?
//
//      ScrollViewReader { proxy in
//          Form {
//              TextField("Name", text: $name)
//                  .focused($focusedField, equals: .name)
//                  .id(Field.name)
//                  .scrollsIntoView(id: Field.name, isFocused: focusedField == .name, proxy: proxy)
//          }
//      }
//

import SwiftUI

public extension View {
    /// Scrolls this view (tagged with `id`) into view when `isFocused`
    /// becomes true. Pair with `.focused(_:equals:)` and `.id(_:)` using the
    /// same id, inside a `ScrollViewReader`.
    func scrollsIntoView<ID: Hashable>(
        id: ID, isFocused: Bool, proxy: ScrollViewProxy, anchor: UnitPoint = .center
    ) -> some View {
        onChange(of: isFocused) { _, focused in
            guard focused else { return }
            withAnimation {
                proxy.scrollTo(id, anchor: anchor)
            }
        }
    }
}
