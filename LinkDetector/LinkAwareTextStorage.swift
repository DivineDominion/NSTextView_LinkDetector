//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the WTFPL License.

import Cocoa

public class LinkAwareTextStorage: NSTextStorage {

    fileprivate let cache = NSMutableAttributedString()
    public override var string: String { return cache.string }

    lazy var fontManager: NSFontManager = NSFontManager()

    public var content: LinkAwareString? {
        didSet {
            contentUpdated()
        }
    }

    fileprivate func contentUpdated() {

        guard let content = content else { return }

        beginEditing()

        let oldRange = NSMakeRange(0, cache.length)
        let difference = content.length - cache.length
        cache.replaceCharacters(in: oldRange, with: content as String)
        self.edited(.editedCharacters, range: oldRange, changeInLength: difference)

        self.updateAttributes(changedRange: NSMakeRange(0, content.length))

        endEditing()
    }

    public override func replaceCharacters(in range: NSRange, with str: String) {

        guard let content = content else {
            preconditionFailure("Set content first")
        }

        content.replaceCharacters(in: range, with: str)
        cache.replaceCharacters(in: range, with: str)

        self.edited(.editedCharacters, range: range, changeInLength: (str as NSString).length - range.length)
    }

    public override func setAttributes(_ attrs: [String : Any]?, range: NSRange) {

        cache.setAttributes(attrs, range: range)

        self.edited(.editedAttributes, range: range, changeInLength: 0)
    }

    public override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [String : Any] {

        return cache.attributes(at: location, effectiveRange: range)
    }

    public override func processEditing() {

        super.processEditing()

        self.updateAttributes(changedRange: self.editedRange)
    }

    fileprivate func updateAttributes(changedRange range: NSRange) {

        guard let paragraphRange = self.content?.paragraphRange(for: range) else {
            preconditionFailure("Set content first")
        }

        // Clear
        self.removeAttribute(NSLinkAttributeName, range: paragraphRange)
//        self.setAttributes([:], range: paragraphRange) // clears ALL attributes

        self.content?.enumerateLinks(range: paragraphRange) { (range, link) in
            self.addLinkAttribute(range: range, url: link.url)
        }
    }

    fileprivate func addLinkAttribute(range: NSRange, url: URL) {

        self.addAttribute(NSLinkAttributeName, value: url, range: range)
    }
}
