//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the WTFPL License.

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var scrollView: NSScrollView!

    let textStorage = LinkAwareTextStorage()

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        let text = "#Lorem ipsum dolor sit amet, http://example.com/ consectetur adipisicing elit, sed do eiusmod tempor [[incididunt #ut labore]] et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation [[ullamco / laboris]] nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur@sint.occa cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

        textStorage.content = LinkAwareString(string: text)

        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textView.textContainer!)
        textStorage.addLayoutManager(layoutManager)

        textView.linkTextAttributes = [
            NSForegroundColorAttributeName : NSColor.gray,
            NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue,
            NSUnderlineColorAttributeName : NSColor.gray
        ]
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

