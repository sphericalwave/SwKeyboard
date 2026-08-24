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
    private let minLines: Int
    private let border: Color?
    @FocusState private var isFocused: Bool

    /// - Parameter minLines: the field never renders shorter than this; it has
    ///   no upper bound, so long text is never truncated.
    /// - Parameter border: optional stroke color. When set, the field gets
    ///   8pt padding, an ultra-thin material fill, and a 1pt rounded stroke.
    public init(text: Binding<String>,
                prompt: String = "",
                minLines: Int = 1,
                border: Color? = nil) {
        self._text = text
        self.prompt = prompt
        self.minLines = minLines
        self.border = border
    }

    /// Legacy range-based initializer. The upper bound is ignored — capping the
    /// line limit truncated long text instead of scrolling it.
    @available(*, deprecated, message: "Use minLines: instead; the upper bound is ignored.")
    public init(text: Binding<String>,
                prompt: String = "",
                lines: ClosedRange<Int>) {
        self.init(text: text, prompt: prompt, minLines: lines.lowerBound)
    }

    public var body: some View {
        Group {
            if let border {
                field
                    .padding(8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(border, lineWidth: 1))
                    .contentShape(Rectangle())
                    .onTapGesture { isFocused = true }
            } else {
                field
            }
        }
    }

    private var field: some View {
        TextField(prompt, text: $text, axis: .vertical)
            .lineLimit(minLines...)
            // Inside a Form/List row, the row proposes a fixed height and the
            // field otherwise renders at that proposal instead of its true
            // content height — fixedSize forces it to hug the actual text.
            .fixedSize(horizontal: false, vertical: true)
            .focused($isFocused)
    }
}

#if DEBUG
#Preview("GrowingTextEditor") {
    Form {
        GrowingTextEditor(
            text: .constant("A few lines of sample notes.\nThe field grows to hug its content."),
            prompt: "Notes"
        )
    }
}
#endif
