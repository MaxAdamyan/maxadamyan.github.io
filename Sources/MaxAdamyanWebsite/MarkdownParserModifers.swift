import Foundation
import Ink

struct MarkdownModifers {
    static var linkTargetBlankModifier: Modifier {
        Modifier(target: .links, closure: { (input) -> String in
            var newHTML = input.html
            newHTML.insert(contentsOf: " target=\"_blank\"", at: newHTML.firstIndex(of: ">")!)
            return newHTML
        })
    }
}
