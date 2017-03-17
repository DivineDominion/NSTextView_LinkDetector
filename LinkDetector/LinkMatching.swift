//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation

public struct LinkMatching {

    public static func detectStandardLinks(text: String, callback: @escaping (NSRange, Link) -> Void) {

        let textRange = NSMakeRange(0, (text as NSString).length)

        guard let linkDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            preconditionFailure("NSDataDetector could not be initialized")
        }

        linkDetector.enumerateMatches(
            in: text,
            options: [],
            range: textRange) { (textCheckingResult: NSTextCheckingResult?, flags: NSRegularExpression.MatchingFlags, stop) in

                guard let textCheckingResult = textCheckingResult else { return }

                if let url = textCheckingResult.url {
                    callback(textCheckingResult.range, Link(url: url))
                }
        }
    }

    enum Patterns {
        static let wikiLink = "\\[\\[([^\\]]+)\\]\\]"
        static let hashtag = "(#[^\\s]+)"
    }

    /// Cach of the regex after parsing the pattern speeds up
    /// the many iterations.
    fileprivate static var cachedMatchers: [NSRegularExpression] = {

        return [Patterns.wikiLink, Patterns.hashtag].map { pattern in

            guard let linkDetector = try? NSRegularExpression(pattern: pattern, options: []) else {
                preconditionFailure("Invalid pattern: \(pattern)")
            }

            return linkDetector
        }
    }()

    public static func detectCustomLinks(text: String, callback: @escaping (NSRange, Link) -> Void) {

        let nsText = text as NSString
        let textRange = NSMakeRange(0, (text as NSString).length)

        for linkDetector in LinkMatching.cachedMatchers {

            linkDetector.enumerateMatches(
                in: text,
                options: [],
                range: textRange) { (textCheckingResult: NSTextCheckingResult?, flags: NSRegularExpression.MatchingFlags, stop) in

                    guard let textCheckingResult = textCheckingResult else { return }

                    // Range 0:  [[Text]]
                    // Range 1:    Text
                    let matchRange = textCheckingResult.rangeAt(0)
                    let searchString = nsText.substring(with: matchRange)
                    if let escapedSearchString = searchString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
                        let url = URL(string: "nv://\(escapedSearchString)") {
                        
                        callback(matchRange, Link(url: url))
                    }
            }
        }
    }
}
