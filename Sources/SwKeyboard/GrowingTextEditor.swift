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

    /// - Parameter minLines: the field never renders shorter than this; it has
    ///   no upper bound, so long text is never truncated.
    public init(text: Binding<String>,
                prompt: String = "",
                minLines: Int = 1) {
        self._text = text
        self.prompt = prompt
        self.minLines = minLines
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
        TextField(prompt, text: $text, axis: .vertical)
            .lineLimit(minLines...)
            // Inside a Form/List row, the row proposes a fixed height and the
            // field otherwise renders at that proposal instead of its true
            // content height — fixedSize forces it to hug the actual text.
            .fixedSize(horizontal: false, vertical: true)
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
