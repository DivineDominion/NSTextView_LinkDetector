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

    func paragraphNumber(paragraphIndex: Int) -> Int {

        // TODO: Cache instead of recompute every time
        var number = 1

        self.enumerateSubstrings(
            in: NSMakeRange(0, paragraphIndex),
            options: .byParagraphs) { (substring, substringRange, enclosingRange, stop) in
                number += 1
        }

        return number
    }

    func enumerateLinks(range: NSRange, callback: @escaping (NSRange, Link) -> Void) {

        precondition(NSEqualRanges(range, paragraphRange(for: range)), "Only supports per-paragraph computation")

        enumerateSubstrings(in: range, options: .byParagraphs) { (paragraph, substringRange, enclosingRange, stop) in

            guard let paragraph = paragraph else { return }

            let paragraphRange = NSMakeRange(0, (paragraph as NSString).length)

            let linkDetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            linkDetector.enumerateMatches(
                in: paragraph,
                options: [],
                range: paragraphRange) { (textCheckingResult: NSTextCheckingResult?, flags: NSRegularExpression.MatchingFlags, stop) in

                    guard let textCheckingResult = textCheckingResult else { return }

                    if let url = textCheckingResult.url {
                        callback(textCheckingResult.range.offset(enclosingRange.location), Link(url: url))
                    }
            }

            let patterns = [
                "\\[\\[([^\\]]+)\\]\\]",
                "(#[^\\s]+)"
            ]
            for pattern in patterns {
                let linkDetector = try! NSRegularExpression(pattern: pattern, options: [])
                linkDetector.enumerateMatches(
                    in: paragraph,
                    options: [],
                    range: paragraphRange) { (textCheckingResult: NSTextCheckingResult?, flags: NSRegularExpression.MatchingFlags, stop) in

                        guard let textCheckingResult = textCheckingResult else { return }

                        // Range 0:  [[Text]]
                        // Range 1:    Text
                        let matchRange = textCheckingResult.rangeAt(0)
                        let searchString = (paragraph as NSString).substring(with: matchRange)
                        if let escapedSearchString = searchString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
                            let url = URL(string: "nv://\(escapedSearchString)") {

                            callback(matchRange.offset(enclosingRange.location), Link(url: url))
                        }
                }
            }
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
