import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var scrollView: NSScrollView!

    let textStorage = LinkAwareTextStorage()

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        let text = "#Lorem ipsum dolor sit amet, http://example.com/ consectetur adipisicing elit, sed do eiusmod tempor [[incididunt #ut labore]] et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation [[ullamco / laboris]] nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur@sint.occa cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

        let linkAwareString = LinkAwareString()
        linkAwareString.setString(text)
        textStorage.content = linkAwareString

        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textView.textContainer!)
        textStorage.addLayoutManager(layoutManager)

//        textView.layoutManager?.delegate = self
//        textView.textStorage?.setAttributedString(attributedString)
//        textView.textStorage?.delegate = self
        textView.linkTextAttributes = [NSForegroundColorAttributeName : NSColor.gray]
    }

//    func visibleRange() -> NSRange {
//        let container = textView.textContainer!
//        let layoutManager = textView.layoutManager!
//        let textVisibleRect = scrollView.contentView.bounds
//        let glyphRange = layoutManager.glyphRangeForBoundingRect(textVisibleRect, inTextContainer: container)
//        return layoutManager.characterRangeForGlyphRange(glyphRange, actualGlyphRange: nil)
//    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

