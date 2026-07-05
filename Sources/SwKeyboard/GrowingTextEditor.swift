//
//  GrowingTextEditor.swift
//  SwKeyboard
//
//  Multiline text input that grows with its content — the supported
//  replacement for the `TextEditor(...).scrollDisabled(true)` + hidden
//  mirror-`Text` hack (which broke caret tracking inside Forms: after a
//  long paste the insertion point ended up under the keyboard).
//
//  Built on `TextField(axis: .vertical)`, so the containing Form/ScrollView
//  scrolls to follow the caret natively.
//

import SwiftUI

public struct GrowingTextEditor: View {
    @Binding private var text: String
    private let prompt: String
    private let lineRange: ClosedRange<Int>

    public init(text: Binding<String>,
                prompt: String = "",
                lines: ClosedRange<Int> = 1...12) {
        self._text = text
        self.prompt = prompt
        self.lineRange = lines
    }

    public var body: some View {
        TextField(prompt, text: $text, axis: .vertical)
            .lineLimit(lineRange.lowerBound...lineRange.upperBound)
            // Inside a Form/List row, the row proposes a fixed height and the
            // field otherwise renders at that proposal instead of its true
            // content height — fixedSize forces it to hug the actual text.
            .fixedSize(horizontal: false, vertical: true)
    }
}
