import Foundation
import Plot
import Ink

fileprivate var markdownParser: MarkdownParser = {
    var parser = MarkdownParser()
    parser.addModifier(MarkdownModifers.linkTargetBlankModifier)
    return parser
}()

extension Node where Context == HTML.BodyContext {
    static func markdown(_ markdown: String) -> Self {
        return .raw(markdownParser.html(from: markdown))
    }
}
