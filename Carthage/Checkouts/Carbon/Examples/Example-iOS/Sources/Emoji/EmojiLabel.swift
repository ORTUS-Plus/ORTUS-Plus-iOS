import Carbon
import UIKit

struct EmojiLabel: IdentifiableComponent {
    var code: Int
    var onSelect: () -> Void

    var id: Int {
        return code
    }

    func renderContent() -> EmojiLabelContent {
        return .loadFromNib()
    }

    func render(in content: EmojiLabelContent) {
        content.label.text = UnicodeScalar(code).map(String.init)
        content.onSelect = onSelect
    }

    func shouldContentUpdate(with next: EmojiLabel) -> Bool {
        return code != next.code
    }

    func referenceSize(in bounds: CGRect) -> CGSize? {
        return CGSize(width: 50, height: 30)
    }
}

final class EmojiLabelContent: UIControl, NibLoadable {
    @IBOutlet var label: UILabel!

    var onSelect: (() -> Void)?

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.5 : 1
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 8
        addTarget(self, action: #selector(selected), for: .touchUpInside)
    }

    @objc func selected() {
        onSelect?()
    }
}
