import XCTest
import SwiftUI
@testable import SwKeyboard

final class SwKeyboardTests: XCTestCase {

    func testGrowingTextEditorInstantiates() {
        _ = GrowingTextEditor(text: .constant("hello"), prompt: "Notes", lines: 2...6)
    }

    #if os(iOS)
    @MainActor
    func testDismissalVetoedOnTextInputs() {
        XCTAssertFalse(KeyboardDismissal._shouldDismiss(forTouchOn: UITextView()))
        XCTAssertFalse(KeyboardDismissal._shouldDismiss(forTouchOn: UITextField()))
    }

    @MainActor
    func testDismissalVetoedOnDescendantsOfTextInputs() {
        let tv = UITextView()
        let child = UIView()
        tv.addSubview(child)
        XCTAssertFalse(KeyboardDismissal._shouldDismiss(forTouchOn: child))
    }

    @MainActor
    func testDismissalVetoedOnTextInteractionChrome() {
        // Selection handles / cursor / loupe are private UIKit classes; the
        // veto matches on type-name fragments, so stand-ins verify the walk.
        final class UITextSelectionGrabberStub: UIView {}
        final class UIStandardTextCursorViewStub: UIView {}
        final class UITextLoupeStub: UIView {}
        XCTAssertFalse(KeyboardDismissal._shouldDismiss(forTouchOn: UITextSelectionGrabberStub()))
        XCTAssertFalse(KeyboardDismissal._shouldDismiss(forTouchOn: UIStandardTextCursorViewStub()))
        XCTAssertFalse(KeyboardDismissal._shouldDismiss(forTouchOn: UITextLoupeStub()))
    }

    @MainActor
    func testDismissalAllowedOnPlainViews() {
        XCTAssertTrue(KeyboardDismissal._shouldDismiss(forTouchOn: UIView()))
        XCTAssertTrue(KeyboardDismissal._shouldDismiss(forTouchOn: nil))
    }
    #endif
}
