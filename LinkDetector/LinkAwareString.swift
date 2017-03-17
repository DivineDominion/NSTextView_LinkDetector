import Cocoa

public struct Link {
    let url: URL
}

extension NSRange {
    func offset(_ value: Int) -> NSRange {
        return NSRange(location: self.location + value, length: self.length)
    }
}

public class LinkAwareString: NSMutableString {

    fileprivate var implementation = NSMutableString()

    convenience init(string: String) {
        self.init()
        self.setString(string)
    }

    func enumerateLinks(range: NSRange, callback: @escaping (NSRange, Link) -> Void) {

        precondition(NSEqualRanges(range, paragraphRange(for: range)), "Only supports per-paragraph computation")

        enumerateSubstrings(in: range, options: .byParagraphs) { (paragraph, substringRange, enclosingRange, stop) in

            guard let paragraph = paragraph else { return }

            func forwardAndOffsetRange(range: NSRange, link: Link) {

                callback(
                    range.offset(enclosingRange.location),
                    link)
            }

            LinkMatching.detectStandardLinks(
                text: paragraph,
                callback: forwardAndOffsetRange)
            LinkMatching.detectCustomLinks(
                text: paragraph,
                callback: forwardAndOffsetRange)
        }
    }


    // MARK: Delegating to the backing mutable string

    public override var length: Int {
        return implementation.length
    }

    public override func character(at index: Int) -> unichar {
        return implementation.character(at: index)
    }

    public override func getCharacters(_ buffer: UnsafeMutablePointer<unichar>) {
        return implementation.getCharacters(buffer)
    }
    
    public override func replaceCharacters(in range: NSRange, with aString: String) {
        implementation.replaceCharacters(in: range, with: aString)
    }
}
