import XCTest
import SwiftUI
@testable import SwKeyboard

final class SwKeyboardTests: XCTestCase {

    func testGrowingTextEditorInstantiates() {
        _ = GrowingTextEditor(text: .constant("hello"), prompt: "Notes", lines: 2...6)
    }

    func testPlainKeyboardModifierComposes() {
        _ = TextField("Tag", text: .constant("")).plainKeyboard()
    }

    func testScrollDismissModifierComposes() {
        _ = ScrollView { Text("content") }.dismissesKeyboardOnScroll()
    }

    #if os(iOS)
    @MainActor
    func testStandardKeyboardBehaviorComposes() {
        _ = Text("root").standardKeyboardBehavior()
    }
    #endif

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
    func testFragmentVetoOnlyAppliesToUIKitClasses() {
        // App/SwiftUI classes whose names contain veto words must NOT veto —
        // SwiftUI hosting views embed generic payloads full of words like
        // "Keyboard", and matching them killed tap-outside dismissal.
        final class MyKeyboardAvoidingContainer: UIView {}
        final class CursorHighlightView: UIView {}
        XCTAssertTrue(KeyboardDismissal._shouldDismiss(forTouchOn: MyKeyboardAvoidingContainer()))
        XCTAssertTrue(KeyboardDismissal._shouldDismiss(forTouchOn: CursorHighlightView()))
        XCTAssertFalse(KeyboardDismissal._isVetoedChrome(MyKeyboardAvoidingContainer()))
    }

    @MainActor
    func testRealUIKitTextChromeIsVetoed() {
        // Instantiate actual UIKit-private selection chrome where possible;
        // skip gracefully if the class name changes in a future OS.
        for name in ["UITextRangeView", "UICalloutBar"] {
            guard let cls = NSClassFromString(name) as? UIView.Type else { continue }
            let view = cls.init()
            XCTAssertFalse(KeyboardDismissal._shouldDismiss(forTouchOn: view), name)
        }
    }

    @MainActor
    func testDismissalAllowedOnPlainViews() {
        XCTAssertTrue(KeyboardDismissal._shouldDismiss(forTouchOn: UIView()))
        XCTAssertTrue(KeyboardDismissal._shouldDismiss(forTouchOn: nil))
    }
    #endif
}
