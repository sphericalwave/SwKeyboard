//
//  NumericTextField.swift
//  SwKeyboard
//
//  Decimal-pad field bound to `Double?`. Empty shows `placeholder` (the last
//  committed value, in grey) so the user can accept it without retyping.
//
//  Typed characters live in a string buffer. `TextField(value:format:)` parses
//  and rewrites the text on every keystroke, which slams the caret to the
//  left of the digit — this field never writes the formatted number back, so
//  the caret stays after what the user typed.
//
//      NumericTextField("1", value: $scale, isFocused: $isScaleFocused)
//          .multilineTextAlignment(.center)
//

import SwiftUI

public struct NumericTextField: View {
    @Binding private var value: Double?
    private let placeholder: String
    private let allowsFraction: Bool
    private let externalFocus: FocusState<Bool>.Binding?

    @State private var text: String
    @FocusState private var localFocus: Bool

    public init(_ placeholder: String,
                value: Binding<Double?>,
                allowsFraction: Bool = true,
                isFocused: FocusState<Bool>.Binding? = nil) {
        self.placeholder = placeholder
        self._value = value
        self.allowsFraction = allowsFraction
        self.externalFocus = isFocused
        _text = State(initialValue: value.wrappedValue.map(Self.format) ?? "")
    }

    public var body: some View {
        TextField(placeholder, text: $text)
            #if os(iOS)
            .keyboardType(allowsFraction ? .decimalPad : .numberPad)
            #endif
            .focused(externalFocus ?? $localFocus)
            .onChange(of: text) { _, newValue in
                apply(newValue)
            }
    }

    private func apply(_ newText: String) {
        let trimmed = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            value = nil
        } else if let parsed = Self.parse(trimmed) {
            value = parsed
        }
    }

    static func format(_ value: Double) -> String {
        formatter.string(from: NSNumber(value: value)) ?? ""
    }

    static func parse(_ text: String) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return formatter.number(from: trimmed)?.doubleValue
    }

    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        return formatter
    }()
}

#if DEBUG
#Preview("NumericTextField") {
    @Previewable @State var scale: Double?
    Form {
        NumericTextField("1", value: $scale)
            .multilineTextAlignment(.trailing)
    }
}
#endif
