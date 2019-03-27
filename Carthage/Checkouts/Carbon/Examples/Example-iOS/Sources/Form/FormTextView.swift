import UIKit
import Carbon

struct FormTextView: Component {
    var text: String?
    var onInput: (String?) -> Void

    func renderContent() -> FormTextViewContent {
        return .loadFromNib()
    }

    func render(in content: FormTextViewContent) {
        content.textView.text = text
        content.onInput = onInput
    }

    func shouldContentUpdate(with next: FormTextView) -> Bool {
        return false
    }

    func referenceSize(in bounds: CGRect) -> CGSize? {
        return nil
    }
}

final class FormTextViewContent: UIView, NibLoadable, UITextViewDelegate {
    @IBOutlet var textView: UITextView! {
        didSet {
            textView.delegate = self
        }
    }

    var onInput: ((String?) -> Void)?

    func textViewDidChange(_ textView: UITextView) {
        onInput?(textView.text)
    }
}
