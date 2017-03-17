import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet var textView: NSTextView!

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        let text = "Lorem ipsum dolor sit amet, http://example.com/ consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur@sint.occa cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

        let attributedString = autoAddLink(string: text)
        textView.textStorage?.setAttributedString(attributedString)
    }

    func autoAddLink(string: String) -> NSAttributedString {

        let attributedString = NSMutableAttributedString(string: string)

        let linkDetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)

        linkDetector.enumerateMatches(
            in: string,
            options: [],
            range: NSRange(location: 0, length: (string as NSString).length)) { (textCheckingResult, matchingFlags, stop) in

                guard let textCheckingResult = textCheckingResult else { return }

                if let url = textCheckingResult.url {
                    let attributes = [NSLinkAttributeName : url]
                    attributedString.addAttributes(attributes, range: textCheckingResult.range)
                }
        }

        return attributedString
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

