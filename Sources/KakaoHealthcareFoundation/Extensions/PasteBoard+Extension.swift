import Foundation
import SwiftUI

#if os(macOS)
import AppKit
public typealias Pasteboard = NSPasteboard
#else
import UIKit
public typealias Pasteboard = UIPasteboard
#endif

public extension Pasteboard {
    func copyText(_ text: String) {
#if os(macOS)
        self.clearContents()
        self.setString(text, forType: .string)
#else
        self.string = text
#endif
    }
#if os(iOS)
    func copyImage(_ image: UIImage) {
        self.image = image
    }
#endif
}
