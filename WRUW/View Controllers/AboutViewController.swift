import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var wruwInfoText: UITextView!
    @IBOutlet weak var appInfoText: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTextView(textView: wruwInfoText)
        setupTextView(textView: appInfoText)
    }

    func setupTextView(textView: UITextView) {
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.dataDetectorTypes = .all
        textView.isSelectable = true

        textView.linkTextAttributes = [
            .foregroundColor: ThemeManager.current().wruwMainOrangeColor,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }
}
